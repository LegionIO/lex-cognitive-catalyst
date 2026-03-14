# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveCatalyst
      module Helpers
        class Reaction
          include Constants

          attr_reader :id, :reaction_type, :reactants, :activation_energy,
                      :yield_value, :catalyzed, :catalyst_id, :completed, :created_at

          def initialize(reaction_type:, reactants:, activation_energy: ACTIVATION_ENERGY)
            @id               = SecureRandom.uuid
            @reaction_type    = reaction_type
            @reactants        = Array(reactants)
            @activation_energy = activation_energy.clamp(0.0, 1.0)
            @yield_value      = 0.0
            @catalyzed        = false
            @catalyst_id      = nil
            @completed        = false
            @created_at       = Time.now.utc
          end

          # Apply a catalyst to lower the activation energy threshold
          def apply_catalyst!(catalyst)
            reduction = catalyst.catalyze!(@reaction_type)
            @activation_energy = (@activation_energy - reduction).clamp(0.0, 1.0).round(10)
            @catalyzed         = true
            @catalyst_id       = catalyst.id
          end

          # Attempt to complete the reaction with given energy input
          # Completes if energy_input >= activation_energy; yield based on energy surplus
          def attempt!(energy_input)
            return false if @completed
            return false if energy_input < @activation_energy

            @completed = true
            surplus = (energy_input - @activation_energy).clamp(0.0, 1.0)
            @yield_value = (0.5 + (surplus * 0.5)).clamp(0.0, 1.0).round(10)
            true
          end

          def complete?
            @completed
          end

          def catalyzed?
            @catalyzed
          end

          # Completed spontaneously — without a catalyst
          def spontaneous?
            @completed && !@catalyzed
          end

          def yield_label
            YIELD_LABELS.find { |range, _| range.cover?(@yield_value) }&.last || :negligible
          end

          def to_h
            {
              id:                @id,
              reaction_type:     @reaction_type,
              reactants:         @reactants,
              activation_energy: @activation_energy,
              yield_value:       @yield_value,
              yield_label:       yield_label,
              catalyzed:         @catalyzed,
              catalyst_id:       @catalyst_id,
              completed:         @completed,
              spontaneous:       spontaneous?,
              created_at:        @created_at
            }
          end
        end
      end
    end
  end
end
