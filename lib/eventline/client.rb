# Copyright (c) 2021-2022 Exograd SAS.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require("net/https")
require("openssl")
require("set")
require("json")

module Eventline
  class Client
    class ListResponse
      attr_reader(:elements, :next, :previous)

      def initialize(elements, _next, _previous)
        @elements = elements

        @next = Pagination.new(_next.to_h)
        @previous = Pagination.new(_previous.to_h)
      end
    end

    class Pagination
      attr_reader(:after, :before, :sort, :size, :order)

      def initialize(opts)
        @after = opts["after"]
        @before = opts["before"]
        @sort = opts["sort"]
        @size = opts["size"]
        @order = opts["order"]
      end
    end

    # @attr_reader status [Integer] The HTTP response status code.
    # @attr_reader code [String] The API error code.
    # @attr_reader data [String, Hash] The HTTP response body.
    # @attr_reader message [String] The human readable message.
    class RequestError < StandardError
      attr_reader(:status, :code, :data)

      # @param status [Integer]
      # @param code [String]
      # @param data [String,Hash]
      # @param message [String]
      def initialize(status, code, data, message)
        super(message)
        @status = status
        @code = code
        @data = data
      end
    end

    PUBLIC_KEY_PIN_SET = Set[
      "820df1ed4e14ad67d352960dcbdc0bdbe198390862ddf8395139f9a7303aee07"
    ].freeze

    # @param project_id [String]
    # @param host [String]
    # @param port [Integer]
    # @param token [String]
    def initialize(project_id:, host: "api.eventline.net", port: 443, token: "")
      store = OpenSSL::X509::Store.new
      store.add_file(File.expand_path("cacert.pem", __dir__ + "/../data"))

      @token = ENV.fetch("EVENTLINE_API_KEY", token.to_s)

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
        fingerprint = OpenSSL::Digest::SHA256.new(public_key).hexdigest
        PUBLIC_KEY_PIN_SET.include?(fingerprint)
      end
    end

    # Execute an HTTP request on the connection.
    #
    # @param request [HTTPRequest] the HTTP request to execute
    # @param body [String] the HTTP request body
    #
    # @raise [RequestError] if the server not responds with 2xx status.
    # @raise [SocketError]
    # @raise [Timeout::Error]
    #
    # @return [String, Hash]
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
