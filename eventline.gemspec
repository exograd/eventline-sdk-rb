Gem::Specification.new do |spec|
  spec.name = "eventline"
  spec.version = "0.1.0"
  spec.authors = ["Exograd SAS"]
  spec.email = ["support@exograd.com"]

  spec.summary = "Eventline Ruby SDK."
  spec.description =  "Eventline is a scheduling platform where you can define and run " +
                      "custom tasks in a safe environment."
  spec.homepage = "https://docs.eventline.net"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/exograd/rb-eventline-sdk/issues",
    "changelog_uri" => "https://github.com/exograd/rb-eventline-sdk/blob/master/CHANGELOG.md",
    "github_repo" => "ssh://github.com/exograd/rb-eventline-sdk",
    "homepage_uri" => "https://docs.eventline.net",
    "source_code_uri" => "https://github.com/exograd/rb-eventline-sdk",
  }

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]
end
