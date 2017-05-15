module RoutesCoverage
  module Adapters
    class AtExit
      def self.use coverer=nil
        #NB: at_exit order is important, for example minitest uses it to run, need to install our handler before it

        RoutesCoverage.reset!
        at_exit do
          next if RoutesCoverage.pid != Process.pid
          RoutesCoverage.perform_report
          exit
        end
      end
    end
  end
end
