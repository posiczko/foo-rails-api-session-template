module Concerns
  module ErrorHandler
    extend ActiveSupport::Concern

    included do
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      rescue_from ActiveRecord::RecordInvalid do |e|
        render_errors(Api::Errors.from_exception(e),
          status: :unprocessable_entity)
      end

      rescue_from StandardError do |e|
        render_errors(Api::Errors.from_exception(e),
          status: :internal_server_error)
      end
    end

    def render_error_from(message:, code: nil, status:)
      code ||= Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(status).to_s
      error = Api::Error.new(code: code, message: message)
      render_errors([error], status: status)
    end

    def render_errors(errors, status: :unprocessable_entity)
      json_response(
        {
          errors: errors,
        },
        status,
      )
    end

    def not_found
      render_error(message: "Resource not found.", status: :not_found)
    end
  end
end
