require("net/https")
require("openssl")
require("set")
require("json")

module Eventline
  class Client
    class RequestError < StandardError
      attr_reader(:status, :code, :data)

      def initialize(status, code, data, message)
        super(message)
        @status = status
        @code = code
        @data = data
      end
    end

    PUBLIC_KEY_PIN_SET = Set[
      "gg3x7U4UrWfTUpYNy9wL2+GYOQhi3fg5UTn5pzA67gc="
    ].freeze

    def initialize(project_id:, host: "api.eventline.net", port: 443, token: "")
      store = OpenSSL::X509::Store.new
      store.add_file(File.expand_path("cacert.pem", __dir__ + "/../data"))

      @token = ENV.fetch("EVCLI_API_KEY", token.to_s)

      @project_id = project_id.to_s

      @mut = Mutex.new
      @conn = Net::HTTP.new(host, port)

      @conn.keep_alive_timeout = 30

      @conn.open_timeout = 30
      @conn.read_timeout = 30
      @conn.write_timeout = 30

      @conn.use_ssl = true
      @conn.verify_mode = OpenSSL::SSL::VERIFY_PEER
      @conn.cert_store = store
      @conn.verify_callback = lambda do |preverify_ok, cert_store|
        return false if !preverify_ok

        public_key = cert_store.chain.first.public_key.to_der
        fingerprint = OpenSSL::Digest::SHA256.new(public_key).base64digest
        PUBLIC_KEY_PIN_SET.include?(fingerprint)
      end
    end

    def call(request, body = nil)
      request.content_type = "application/json"
      request.content_length = body.to_s.bytesize

      request["Accept"] = "application/json"
      request["User-Agent"] = "Eventline/1.0 (platform; ruby) eventline-sdk"
      request["Authorization"] = "Bearer #{@token}"
      request["X-Eventline-Project-Id"] = @project_id

      response = @mut.synchronize do
        @conn.request(request, body)
      end

      data = if response.content_type == "application/json"
               begin
                 JSON.parse(response.body)
               rescue
                 raise(
                   RequestError.new(
                     response.code.to_i,
                     "invalid_json",
                     response.body,
                     "invalid json body"
                   )
                 )
               end
             else
               response.body
             end

      if response.code.to_i < 200 || response.code.to_i >= 300
        if response.content_type == "application/json"
          raise(
            RequestError.new(
              response.code.to_i,
              data.fetch("code", "unknown_error"),
              data.fetch("data", {}),
              data.fetch("error")
            )
          )
        else
          raise(
            RequestError.new(
              response.code.to_i,
              "invalid_json",
              response.body,
              "invalid json body"
            )
          )
        end
      end

      data
    end
  end
end
