# frozen_string_literal: true

module RoutesCoverage
  class Auditor
    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.formatter = ->(_severity, _datetime, _progname, msg) { "#{msg}\n" }
      end
    end

    def controllers
      @controllers ||= begin
        logger.info "Eager-loading app to collect controllers"
        Rails.application.eager_load!

        logger.info "Collecting controllers"
        if defined?(ActionController::API)
          ActionController::Base.descendants + ActionController::API.descendants
        else
          # older rails
          ActionController::Base.descendants
        end
      end
    end

    def controllers_hash
      @controllers_hash ||= controllers.index_by { |controller| controller.name.sub(/Controller$/, "").underscore }
    end

    def controller_class_by_name(controller_name)
      controller = controllers_hash[controller_name]
      return controller if controller

      @missing_controllers ||= Set.new
      return if @missing_controllers.include?(controller_name)

      controllers_hash[controller_name] ||= "#{controller_name}_controller".classify.constantize
      logger.warn "Controller #{controller_name} was not collected, but exists"
      controllers_hash[controller_name]
    rescue NameError
      @missing_controllers << controller_name
      logger.warn "Controller #{controller_name} looks not existing"
      nil
    end

    def existing_actions_usage_hash
      @existing_actions_usage_hash ||= begin
        logger.info "Collecting actions"
        controller_actions = controllers.map do |controller|
          # cannot use controller.controller_name - it has no namespace, same thing without demodulize:
          controller_name = controller.name.sub(/Controller$/, "").underscore
          controller.action_methods.map { |action| "#{controller_name}##{action}" }
        end
        controller_actions.flatten.map { |action| [action, 0] }.to_h
      end
    end

    def all_routes
      # NB: there're no engines
      @all_routes ||= RoutesCoverage._collect_all_routes
    end

    def perform
      require 'routes_coverage'
      routes = all_routes

      @missing_actions = Hash.new(0)
      @existing_actions_usage_hash = nil
      routes.each do |route|
        next unless route.respond_to?(:requirements) && route.requirements[:controller]

        action = "#{route.requirements[:controller]}##{route.requirements[:action]}"
        if existing_actions_usage_hash[action]
          existing_actions_usage_hash[action] += 1
        else
          # there may be inheritance or implicit renders
          controller_instance = controller_class_by_name(route.requirements[:controller])&.new
          unless controller_instance&.available_action?(route.requirements[:action])
            if controller_instance.respond_to?(route.requirements[:action])
              logger.warn "No action, but responds: #{action}"
            end
            @missing_actions[action] += 1
          end
        end
      end
    end

    def missing_actions
      perform unless @missing_actions
      @missing_actions
    end

    def unused_actions
      perform unless @existing_actions_usage_hash

      root = "#{Rails.root}/" # rubocop:disable Rails/FilePath
      @unused_actions ||= begin
        # methods with special suffixes are obviously not actions, reduce noise:
        unused_actions_from_hash = existing_actions_usage_hash.reject do |action, count|
          count.positive? || action.end_with?('?') || action.end_with?('!') || action.end_with?('=')
        end

        unused_actions_from_hash.keys.map do |action|
          controller_name, action_name = action.split('#', 2)
          controller = controller_class_by_name(controller_name)&.new
          method = controller.method(action_name.to_sym)
          if method&.source_location && method.source_location.first.start_with?(root)
            "#{method.source_location.first.sub(root, '')}:#{method.source_location.second} - #{action}"
          else
            action
          end
        end.uniq.sort
      end
    end

    def print_missing_actions
      logger.info "\nMissing #{missing_actions.count} actions:"

      # NB: for singular `resource` there may be unnecessary `index` in suggestions
      restful_actions = %w[index new create show edit update destroy].freeze

      declared_restful = all_routes.select { |route|
        route.respond_to?(:requirements) && route.requirements[:controller] &&
        restful_actions.include?(route.requirements[:action])
      }.group_by{ |route| route.requirements[:controller]}

      missing_actions.keys.map { |action| action.split('#', 2) }.group_by(&:first).each do |(controller, actions)|
        missing = actions.map(&:last)
        next if missing.empty?

        undeclared_restful = restful_actions - declared_restful[controller].map{|r| r.requirements[:action] }
        logger.info([
          "#{controller}:",
          (if (restful_actions & missing).any?
            "#{(missing & restful_actions).join(', ')}"\
            ", except: %i[#{(restful_actions & (missing + undeclared_restful)).join(' ')}]"\
            ", only: %i[#{(restful_actions - (missing + undeclared_restful)).join(' ')}]"
          end),
          (if (missing - restful_actions).any?
            ",  Missing custom: #{(missing - restful_actions).join(', ')}"
          end)

        ].compact.join(' '))
      end
    end

    def print_unused_actions
      logger.info "Unused #{unused_actions.count} actions:"
      unused_actions.each { |action| logger.info action }
    end
  end
end
