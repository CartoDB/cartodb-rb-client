module CartoDB
  class CartoError < Exception

    HTTP_MESSAGES = {
                      401 => 'Unauthorized request',
                      404 => 'Not found',
                      500 => 'Server error'
                    }

    def initialize(uri, method = nil, http_response = nil)
      @uri            = uri
      @method         = method
      @error_messages = ['undefined CartoDB error']
      @status_code    = 400
      @error_messages = [uri] if method == nil && http_response == nil

      if http_response
        @status_code = http_response.code
        @error_messages = custom_error(http_response) || standard_error(@status_code)
      end

    end

    def to_s
      <<-EOF
        #{http_error_message_header}
        #{format_error_messages}
      EOF
      .strip
    end

    def http_error_message_header
      if @method && @uri
        %{There were errors running the #{@method.upcase} request "#{@uri}":}
      end
    end
    private :http_error_message_header

    def custom_error(http_response)
      json = Utils.parse_json(http_response)
      json['errors'] if json
    end

    def standard_error(status_code)
      "#{status_code} - #{HTTP_MESSAGES[status_code.to_i]}"
    end
    private :standard_error

    def format_error_messages
      return '' unless @error_messages
      if @error_messages.is_a?(String)
        @error_messages
      elsif @error_messages.is_a?(Array) && @error_messages.count == 1
        @error_messages.first
      else
        @error_messages.map{|e| "- #{e}"}.join("\n")
      end
    end
    private :format_error_messages

  end
end