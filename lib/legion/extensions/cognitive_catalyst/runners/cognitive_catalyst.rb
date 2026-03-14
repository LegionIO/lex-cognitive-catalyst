# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveCatalyst
      module Runners
        module CognitiveCatalyst
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def create_catalyst(catalyst_type:, domain:, potency: nil, specificity: nil, engine: nil, **)
            e = engine || default_engine
            unless Helpers::Constants::CATALYST_TYPES.include?(catalyst_type.to_sym)
              raise ArgumentError, "invalid catalyst_type: #{catalyst_type}"
            end

            opts = {
              catalyst_type: catalyst_type.to_sym,
              domain:        domain
            }
            opts[:potency]     = potency     unless potency.nil?
            opts[:specificity] = specificity unless specificity.nil?

            catalyst = e.create_catalyst(**opts)
            Legion::Logging.debug "[cognitive_catalyst] create_catalyst id=#{catalyst.id[0..7]} " \
                                  "type=#{catalyst_type} domain=#{domain} potency=#{catalyst.potency.round(2)}"
            { success: true, catalyst: catalyst.to_h }
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_catalyst] create_catalyst failed: #{e.message}"
            { success: false, reason: e.message }
          end

          def create_reaction(reaction_type:, reactants:, activation_energy: nil, engine: nil, **)
            e = engine || default_engine
            unless Helpers::Constants::REACTION_TYPES.include?(reaction_type.to_sym)
              raise ArgumentError, "invalid reaction_type: #{reaction_type}"
            end

            opts = {
              reaction_type: reaction_type.to_sym,
              reactants:     Array(reactants)
            }
            opts[:activation_energy] = activation_energy unless activation_energy.nil?

            reaction = e.create_reaction(**opts)
            Legion::Logging.debug "[cognitive_catalyst] create_reaction id=#{reaction.id[0..7]} " \
                                  "type=#{reaction_type} reactants=#{reaction.reactants.size}"
            { success: true, reaction: reaction.to_h }
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_catalyst] create_reaction failed: #{e.message}"
            { success: false, reason: e.message }
          end

          def apply_catalyst(catalyst_id:, reaction_id:, engine: nil, **)
            e = engine || default_engine
            result = e.apply_catalyst(catalyst_id: catalyst_id, reaction_id: reaction_id)
            Legion::Logging.debug '[cognitive_catalyst] apply_catalyst ' \
                                  "catalyst=#{catalyst_id[0..7]} reaction=#{reaction_id[0..7]} " \
                                  "success=#{result[:success]}"
            result
          end

          def attempt_reaction(reaction_id:, energy_input:, engine: nil, **)
            e = engine || default_engine
            result = e.attempt_reaction(reaction_id: reaction_id, energy_input: energy_input)
            Legion::Logging.debug "[cognitive_catalyst] attempt_reaction id=#{reaction_id[0..7]} " \
                                  "energy=#{energy_input} completed=#{result[:completed]}"
            result
          end

          def recharge(catalyst_id:, amount:, engine: nil, **)
            e = engine || default_engine
            result = e.recharge_catalyst(catalyst_id: catalyst_id, amount: amount)
            Legion::Logging.debug "[cognitive_catalyst] recharge id=#{catalyst_id[0..7]} " \
                                  "amount=#{amount} potency=#{result[:potency]&.round(2)}"
            result
          end

          def list_catalysts(engine: nil, **)
            e = engine || default_engine
            catalysts = e.all_catalysts
            Legion::Logging.debug "[cognitive_catalyst] list_catalysts count=#{catalysts.size}"
            { success: true, catalysts: catalysts.map(&:to_h), count: catalysts.size }
          end

          def catalyst_status(engine: nil, **)
            e = engine || default_engine
            report = e.catalyst_report
            Legion::Logging.debug "[cognitive_catalyst] catalyst_status total=#{report[:total_catalysts]} " \
                                  "reactions=#{report[:total_reactions]} rate=#{report[:catalyzed_rate].round(2)}"
            { success: true }.merge(report)
          end

          private

          def default_engine
            @default_engine ||= Helpers::CatalystEngine.new
          end
        end
      end
    end
  end
end
