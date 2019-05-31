# frozen_string_literal: true

module HelpScout
  class API
    class BadRequest < StandardError; end
    class NotAuthorized < StandardError; end
    class NotFound < StandardError; end
    class InternalError < StandardError; end
    class ThrottleLimitReached < StandardError; end

    BASE_URL = 'https://api.helpscout.net/v2/'

    attr_writer :access_token

    def access_token
      @access_token ||= HelpScout::API::AccessToken.create
    end

    def get(path, params = {})
      send_request(:get, path, params)
    end

    def patch(path, params)
      send_request(:patch, path, params)
    end

    def post(path, params)
      send_request(:post, path, params)
    end

    def put(path, params)
      send_request(:put, path, params)
    end

    private

    def handle_response(result) # rubocop:disable AbcSize, MethodLength
      case result.status
      when 400
        raise BadRequest, result.body&.dig('validationErrors')
      when 401
        raise NotAuthorized, result.body&.dig('error_description')
      when 404
        raise NotFound, 'Resource Not Found'
      when 429
        raise ThrottleLimitReached, result.body&.dig('error')
      when 500, 501, 503
        raise InternalError, result.body&.dig('error')
      end

      HelpScout::Response.new(result)
    end

    def send_request(action, path, params)
      connection = HelpScout::API::Client.new.connection
      response = connection.send(action, path, params.compact)

      if response.status == 401 && HelpScout.configuration.automatically_generate_tokens
        self.access_token = HelpScout::API::AccessToken.create
        response = connection.send(action, path, params.compact)
      end

      handle_response(response)
    end
  end
end
