# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveCatalyst
      module Helpers
        class CatalystEngine
          include Constants

          def initialize
            @catalysts = {}
            @reactions = {}
          end

          def create_catalyst(catalyst_type:, domain:, potency: 0.5, specificity: 0.5, **)
            raise ArgumentError, "invalid catalyst_type: #{catalyst_type}" unless CATALYST_TYPES.include?(catalyst_type.to_sym)

            evict_oldest_catalyst if @catalysts.size >= MAX_CATALYSTS
            catalyst = Catalyst.new(
              catalyst_type: catalyst_type.to_sym,
              domain:        domain,
              potency:       potency,
              specificity:   specificity
            )
            @catalysts[catalyst.id] = catalyst
            catalyst
          end

          def create_reaction(reaction_type:, reactants:, activation_energy: ACTIVATION_ENERGY, **)
            raise ArgumentError, "invalid reaction_type: #{reaction_type}" unless REACTION_TYPES.include?(reaction_type.to_sym)

            evict_oldest_reaction if @reactions.size >= MAX_REACTIONS
            reaction = Reaction.new(
              reaction_type:     reaction_type.to_sym,
              reactants:         reactants,
              activation_energy: activation_energy
            )
            @reactions[reaction.id] = reaction
            reaction
          end

          def apply_catalyst(catalyst_id:, reaction_id:)
            catalyst = @catalysts[catalyst_id]
            reaction = @reactions[reaction_id]

            return { success: false, reason: :catalyst_not_found } unless catalyst
            return { success: false, reason: :reaction_not_found } unless reaction
            return { success: false, reason: :already_completed }  if reaction.complete?

            reaction.apply_catalyst!(catalyst)
            {
              success:          true,
              activation_energy: reaction.activation_energy,
              catalyst_id:      catalyst_id,
              reaction_id:      reaction_id
            }
          end

          def attempt_reaction(reaction_id:, energy_input:)
            reaction = @reactions[reaction_id]
            return { success: false, reason: :not_found } unless reaction
            return { success: false, reason: :already_completed } if reaction.complete?

            completed = reaction.attempt!(energy_input)
            {
              success:          true,
              completed:        completed,
              yield_value:      reaction.yield_value,
              yield_label:      reaction.yield_label,
              catalyzed:        reaction.catalyzed?,
              activation_energy: reaction.activation_energy
            }
          end

          def degrade_all!
            @catalysts.each_value(&:degrade!)
          end

          def recharge_catalyst(catalyst_id:, amount:)
            catalyst = @catalysts[catalyst_id]
            return { success: false, reason: :not_found } unless catalyst

            catalyst.recharge!(amount)
            { success: true, potency: catalyst.potency, potency_label: catalyst.potency_label }
          end

          def all_catalysts
            @catalysts.values
          end

          def all_reactions
            @reactions.values
          end

          def completed_reactions
            @reactions.values.select(&:complete?)
          end

          def catalyzed_rate
            completed = completed_reactions
            return 0.0 if completed.empty?

            catalyzed_count = completed.count(&:catalyzed?)
            (catalyzed_count.to_f / completed.size).round(10)
          end

          def catalyst_report
            completed     = completed_reactions
            catalyzed_cnt = completed.count(&:catalyzed?)
            avg_potency   = if @catalysts.empty?
                              0.0
                            else
                              (@catalysts.values.sum(&:potency) / @catalysts.size).round(10)
                            end

            {
              total_catalysts: @catalysts.size,
              total_reactions: @reactions.size,
              completed:       completed.size,
              catalyzed_count: catalyzed_cnt,
              catalyzed_rate:  catalyzed_rate,
              avg_potency:     avg_potency,
              powerful_count:  @catalysts.values.count(&:powerful?),
              inert_count:     @catalysts.values.count(&:inert?)
            }
          end

          private

          def evict_oldest_catalyst
            oldest_id = @catalysts.min_by { |_id, c| c.created_at }&.first
            @catalysts.delete(oldest_id) if oldest_id
          end

          def evict_oldest_reaction
            oldest_id = @reactions.min_by { |_id, r| r.created_at }&.first
            @reactions.delete(oldest_id) if oldest_id
          end
        end
      end
    end
  end
end
