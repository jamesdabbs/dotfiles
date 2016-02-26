require "json"
require "net/http"

class Github
  class Client
    attr_reader :username

    def initialize opts={}
      @username = opts.fetch :username
    end

    def password
      @_password ||= (print "Github password >"; gets.chomp)
    end

    def keys
      request "/users/#{username}/keys"
    end

    def register_key title, contents
      return if keys.any? { |k| k.fetch("key").strip == contents.strip }

      request "/user/keys",
        verb: Net::HTTP::Post,
        authorized: true,
        body: {
          title: title,
          key:   contents
        }
    end

    def request endpoint, opts={}
      verb = opts[:verb] || Net::HTTP::Get
      uri = URI("https://api.github.com#{endpoint}")

      response = nil
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = verb.new uri
        request["Content-type"] = "application/json"

        if opts[:authorized]
          request.basic_auth username, password
        end
        if body = opts[:body]
          request.body = body.to_json
        end
        
        response = http.request request
      end

      JSON.parse response.body
    end
  end
end
