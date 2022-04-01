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

require("eventline/client")

module Eventline
  class Account
    attr_accessor(:id, :org_id, :creation_time, :disabled, :email_address, :name, :role,
      :last_login_time, :last_project_id, :settings)

    # Fetch an account by identifier.
    #
    # @param [Eventline::Client] client
    # @param [String] id
    #
    # @raise [Eventline::Client::RequestError]
    #
    # @return Eventline::Account
    def self.retrieve(client, id)
      request = Net::HTTP::Get.new(File.join("/v0/accounts/id", id))
      response = client.call(request)
      account = new
      account.from_h(response)
      account
    end

    def initialize
    end

    # Load account from a hash object.
    #
    # @raise [KeyError]
    #
    # @return Eventline::Account
    def from_h(data)
      @id = data.fetch("id")
      @org_id = data.fetch("org_id")
      @creation_time = data.fetch("creation_time")
      @disabled = data.fetch("disabled")
      @email_address = data.fetch("email_address")
      @name = data["name"]
      @role = data.fetch("role")
      @last_login_time = data["last_login_time"]
      @last_project_id = data["last_project_id"]
      @settings = data.fetch("settings")
    end
  end
end
