module JsonHelper
  def json
    # Reparse and never memoize as response may change
    (lambda do
      JSON.parse(response.body, symbolize_names: true)
    end).call
  end

  def json_request_headers
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end
end

RSpec.configure do |config|
  config.include JsonHelper, type: :request
  config.include JsonHelper, type: :feature
end
