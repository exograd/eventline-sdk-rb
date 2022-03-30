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

require("json")

module Eventline
  class Context
    attr_reader(:event, :task_parameters, :instance_id, :identities)

    # Returns the current project id when the function is called in an Eventline instance.
    #
    # @return String
    def self.current_project_id
      ENV["EVENTLINE_PROJECT_ID"].to_s
    end

    # Returns the current project name when the function is called in an Eventline
    # instance.
    #
    # @return String
    def self.current_project_name
      ENV["EVENTLINE_PROJECT_NAME"].to_s
    end

    # Returns the current pipeline id when the function is called in an Eventline
    # instance.
    #
    # @return String
    def self.current_pipeline_id
      ENV["EVENTLINE_PIPELINE_ID"].to_s
    end

    # Returns the current task id when the function is called in an Eventline instance.
    #
    # @return String
    def self.current_task_id
      ENV["EVENTLINE_TASK_ID"].to_s
    end

    # Load and return a context object.
    #
    # @raise [Errno::ENOENT]
    # @raise [Errno::EACCES]
    # @raise [JSON::ParserError]
    #
    # @return Eventline::Context
    def self.load
      filename = ENV.fetch("EVENTLINE_CONTEXT_PATH", "/eventline/task/context")
      file = IO.read(filename)
      data = JSON.parse(file)
      context = new
      context.from_h(data)
      context
    end

    def initialize
    end

    # Load context from a hash object.
    #
    # @raise [KeyError]
    #
    # @return nil
    def from_h(data)
      @event = data.fetch("event")
      @task_parameters = data.fetch("task_parameters")
      @instance_id = data.fetch("instance_id").to_i
      @identities = data.fetch("identities")
      nil
    end
  end
end
