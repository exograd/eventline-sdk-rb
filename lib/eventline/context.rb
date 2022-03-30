require("json")

module Eventline
  class Context
    def self.current_project_id
      ENV["EVENTLINE_PROJECT_ID"].to_s
    end

    def self.current_project_name
      ENV["EVENTLINE_PROJECT_NAME"].to_s
    end

    def self.current_pipeline_id
      ENV["EVENTLINE_PIPELINE_ID"].to_s
    end

    def self.current_task_id
      ENV["EVENTLINE_TASK_ID"].to_s
    end
  end
end
