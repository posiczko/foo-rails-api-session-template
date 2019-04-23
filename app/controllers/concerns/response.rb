module Response
  extend ActiveSupport::Concern

  def json_response(object, status = :ok)
    render json: object, status: status
  end

  def render_jsonapi_from(serializer_for:,
                          object:,
                          status:,
                          message: nil)

    http_code = Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(status)
    string_status = case status
                    when 500..599
                      "fail"
                    when 400..499
                      "error"
                    else
                      "success"
                    end
    serializer_class = serializer_for.to_s.titlecase.tr(" ", "") << "Serializer"
    message = message.present? ? { message: message } : {}
    code = status.present? ? { code: http_code, status: string_status } : {}

    params = { params:
                 code.merge(message)
    }

    json_response(serializer_class.constantize.new(object, params).serialized_json, status)
  end
end
