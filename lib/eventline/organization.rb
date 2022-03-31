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
  class Organization
    attr_accessor(:id, :name, :address, :postal_code, :city, :country,
      :contact_email_address, :non_essential_mail_opt_in, :vat_id_number)

    # Fetch the organization associated with the credentials currently used by the client.
    #
    # @param [Eventline::Client] client
    #
    # @raise [Eventline::Client::RequestError]
    #
    # @return Eventline::Organization
    def self.retrieve(client)
      request = Net::HTTP::Get.new("/v0/org")
      response = client.call(request)
      organization = new
      organization.from_h(response)
      organization
    end

    def initialize
    end

    # Load organization from a hash object.
    #
    # @raise [KeyError]
    #
    # @return Eventline::Organization
    def from_h(data)
      @id = data.fetch("id")
      @name = data.fetch("name")
      @address = data.fetch("address", nil)
      @postal_code = data.fetch("postal_code", nil)
      @city = data.fetch("city", nil)
      @country = data.fetch("country", nil)
      @contact_email_address = data.fetch("contact_email_address")
      @non_essential_mail_opt_in = data.fetch("non_essential_mail_opt_in")
      @vat_id_number = data["vat_id_number"]
    end
  end
end
