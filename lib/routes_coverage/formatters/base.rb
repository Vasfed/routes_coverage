module RoutesCoverage
  module Formatters
    class Base
      def initialize result, settings
        @result = result
        @settings = settings
      end

      attr_reader :result
      attr_reader :settings
    end
  end
end
