# frozen_string_literal: true

module RoutesCoverage
  module Formatters
    class Base
      def initialize(result, groups, settings)
        @result = result
        @groups = groups
        @settings = settings
      end

      attr_reader :result, :groups, :settings
    end
  end
end
