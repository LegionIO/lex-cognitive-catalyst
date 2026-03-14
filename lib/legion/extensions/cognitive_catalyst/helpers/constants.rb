# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveCatalyst
      module Helpers
        module Constants
          # Catalyst types — categories of experiences/insights that accelerate reactions
          CATALYST_TYPES = %i[experience insight analogy pattern emotion].freeze

          # Reaction types — categories of cognitive transformations
          REACTION_TYPES = %i[synthesis decomposition exchange neutralization precipitation].freeze

          # Storage limits
          MAX_CATALYSTS = 500
          MAX_REACTIONS = 200

          # Activation energy — minimum energy to complete a reaction without a catalyst
          ACTIVATION_ENERGY = 0.6

          # How much a catalyst lowers the activation energy threshold
          CATALYST_REDUCTION = 0.3

          # Potency degradation rate from environmental wear (not from use)
          POTENCY_DECAY = 0.02

          # Bonus added when catalyst specificity matches reaction domain
          SPECIFICITY_BONUS = 0.15

          # Potency labels — range-based classification of catalyst strength
          POTENCY_LABELS = {
            (0.8..)     => :powerful,
            (0.6...0.8) => :strong,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :weak,
            (..0.2)     => :inert
          }.freeze

          # Yield labels — range-based classification of reaction output quality
          YIELD_LABELS = {
            (0.8..)     => :excellent,
            (0.6...0.8) => :good,
            (0.4...0.6) => :fair,
            (0.2...0.4) => :poor,
            (..0.2)     => :negligible
          }.freeze
        end
      end
    end
  end
end
