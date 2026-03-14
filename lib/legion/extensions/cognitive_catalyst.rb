# frozen_string_literal: true

require 'securerandom'

require_relative 'cognitive_catalyst/version'
require_relative 'cognitive_catalyst/helpers/constants'
require_relative 'cognitive_catalyst/helpers/catalyst'
require_relative 'cognitive_catalyst/helpers/reaction'
require_relative 'cognitive_catalyst/helpers/catalyst_engine'
require_relative 'cognitive_catalyst/runners/cognitive_catalyst'
require_relative 'cognitive_catalyst/client'

module Legion
  module Extensions
    module CognitiveCatalyst
      extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)
    end
  end
end
