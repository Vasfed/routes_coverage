require "erb"
require "cgi"
require "fileutils"
require "digest/sha1"
require "time"

module RoutesCoverage
  module Formatters
    class Html < Base
      def format
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

      def root(root = nil)
        # TODO: config for this
        return SimpleCov.root if defined? SimpleCov
        return @root if defined?(@root) && root.nil?

        @root = File.expand_path(root || Dir.getwd)
      end

      def coverage_dir(dir = nil)
        # TODO: config for this
        return SimpleCov.coverage_dir if defined? SimpleCov
        return @coverage_dir if defined?(@coverage_dir) && dir.nil?

        @coverage_path = nil # invalidate cache
        @coverage_dir = (dir || "coverage")
      end

      def output_path
        @coverage_path ||= File.expand_path(coverage_dir, root).tap do |path|
          FileUtils.mkdir_p path
        end
      end

      def project_name
        return SimpleCov.project_name if defined? SimpleCov

        @project_name ||= File.basename(root.split("/").last).capitalize.tr("_", " ")
      end

      def asset_content(name)
        File.read(File.expand_path("../../../compiled_assets/#{name}", File.dirname(__FILE__)))
      end

      def style_asset_link
        "<style>\n#{asset_content 'routes.css'}</style>"
      end

      def route_group_result(title_id, title, result)
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

      def hits_css_class(hits)
        hits > 0 ? 'cov' : 'uncov'
      end

      def timeago(time)
        "<abbr class=\"timeago\" title=\"#{time.iso8601}\">#{time.iso8601}</abbr>"
      end

      def all_result_groups
        return @all_result_groups if @all_result_groups

        @all_result_groups = [
          {
            id: 'all_routes',
            name: 'All Routes',
            result: result
          }
        ]
        @all_result_groups += groups.map do |group_name, group_result|
          {
            id: group_name.gsub(/^[^a-zA-Z]+/, "").gsub(/[^a-zA-Z0-9\-_]/, ""),
            name: group_name,
            result: group_result
          }
        end

        @all_result_groups
      end
    end
  end
end
