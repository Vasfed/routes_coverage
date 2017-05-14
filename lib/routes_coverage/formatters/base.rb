module RoutesCoverage
  module Formatters
    class Base
      def initialize result, groups, settings
        @result = result
        @groups = groups
        @settings = settings
      end

      attr_reader :result
      attr_reader :groups
      attr_reader :settings
    end
  end
end
