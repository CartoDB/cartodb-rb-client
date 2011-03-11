module CartoDB
  class CartoError < Exception

    def initialize(uri, method, http_response)
      @uri            = uri
      @method         = method
      @error_messages = ['undefined CartoDB error']
      @status_code    = 400

      if http_response
        @status_code = http_response.code
        json = Utils.parse_json(http_response)
        @error_messages = json['errors'] if json
      end

    end

    def to_s
      <<-EOF
        There were errors running the #{@method.upcase} request "#{@uri}":
        #{@error_messages.map{|e| "- #{e}"}.join("\n")}
      EOF
    end
  end
end