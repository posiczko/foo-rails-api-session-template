class SessionSerializer
  include FastJsonapi::ObjectSerializer

  attribute :username
  meta do |_object, params|
    message = params.has_key?(:message) ? { message: params[:message] } : {}
    {
      code: params[:code],
      status: params[:status],
    }.merge(message)
  end
end
