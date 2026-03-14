# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveCatalyst
      module Helpers
        class Catalyst
          include Constants

          attr_reader :id, :catalyst_type, :domain, :potency, :specificity,
                      :uses_count, :created_at

          def initialize(catalyst_type:, domain:, potency: 0.5, specificity: 0.5)
            @id            = SecureRandom.uuid
            @catalyst_type = catalyst_type
            @domain        = domain
            @potency       = potency.clamp(0.0, 1.0)
            @specificity   = specificity.clamp(0.0, 1.0)
            @uses_count    = 0
            @created_at    = Time.now.utc
          end

          # Apply this catalyst to a reaction — increments uses_count but does NOT reduce potency
          # Catalysts are not consumed by use; they are reusable accelerators
          # Returns activation_reduction = potency * specificity
          def catalyze!(reaction_type)
            @uses_count += 1
            activation_reduction = (@potency * @specificity).round(10)
            activation_reduction
          end

          # Degrade from environmental wear (not from use)
          def degrade!
            @potency = (@potency - POTENCY_DECAY).clamp(0.0, 1.0).round(10)
          end

          # Recharge by increasing potency
          def recharge!(amount)
            @potency = (@potency + amount).clamp(0.0, 1.0).round(10)
          end

          def powerful?
            @potency >= 0.8
          end

          def inert?
            @potency < 0.2
          end

          def specific?
            @specificity >= 0.7
          end

          def broad?
            @specificity < 0.3
          end

          def potency_label
            POTENCY_LABELS.find { |range, _| range.cover?(@potency) }&.last || :inert
          end

          def to_h
            {
              id:            @id,
              catalyst_type: @catalyst_type,
              domain:        @domain,
              potency:       @potency,
              specificity:   @specificity,
              uses_count:    @uses_count,
              potency_label: potency_label,
              powerful:      powerful?,
              inert:         inert?,
              specific:      specific?,
              broad:         broad?,
              created_at:    @created_at
            }
          end
        end
      end
    end
  end
end
