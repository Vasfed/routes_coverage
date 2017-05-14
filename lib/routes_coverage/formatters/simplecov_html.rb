require "erb"
require "cgi"
require "fileutils"
require "digest/sha1"
require "time"

module RoutesCoverage
  module Formatters
    class SimpleCovHtml < Base
      def format
        #TODO: copy assets, if simplecov does not generate a report along us

        # Dir[File.join(File.dirname(__FILE__), "../public/*")].each do |path|
        #   FileUtils.cp_r(path, asset_output_path)
        # end

        routes_filename = "routes.html"

        File.open(File.join(output_path, routes_filename), "wb") do |file|
          file.puts template("layout").result(binding)
        end

        "Routes coverage is #{result.coverage}% Report generated to #{output_path}/#{routes_filename}"
      end

      private

      def template(name)
        ERB.new(File.read(File.join(File.dirname(__FILE__), "html_views", "#{name}.erb")))
      end

      def output_path
        SimpleCov.coverage_path
      end

      def asset_output_path
        return @asset_output_path if defined?(@asset_output_path) && @asset_output_path
        @asset_output_path = File.join(output_path, "assets", SimpleCov::Formatter::HTMLFormatter::VERSION)
        FileUtils.mkdir_p(@asset_output_path)
        @asset_output_path
      end

      def assets_path(name)
        File.join("./assets", SimpleCov::Formatter::HTMLFormatter::VERSION, name)
      end

      # Returns the html for the given source_file
      def formatted_source_file(source_file)
        template("source_file").result(binding)
      end

      # Returns a table containing the given source files
      def route_group_result(title, result)
        title_id = title.gsub(/^[^a-zA-Z]+/, "").gsub(/[^a-zA-Z0-9\-\_]/, "")
        # Silence a warning by using the following variable to assign to itself:
        # "warning: possibly useless use of a variable in void context"
        # The variable is used by ERB via binding.
        title_id = title_id
        template("route_group").result(binding)
      end

      def coverage_css_class(covered_percent)
        if covered_percent > 90
          "green"
        elsif covered_percent > 80
          "yellow"
        else
          "red"
        end
      end

      def strength_css_class(covered_strength)
        if covered_strength > 1
          "green"
        elsif covered_strength == 1
          "yellow"
        else
          "red"
        end
      end

      def hits_css_class hits
        hits > 0 ? 'green' : 'red'
      end

      # Return a (kind of) unique id for the source file given. Uses SHA1 on path for the id
      def id(source_file)
        Digest::SHA1.hexdigest(source_file.filename)
      end

      def timeago(time)
        "<abbr class=\"timeago\" title=\"#{time.iso8601}\">#{time.iso8601}</abbr>"
      end

    end
  end
end
