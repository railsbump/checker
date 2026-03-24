require "spec_helper"
require "yaml"

RSpec.describe "check_bundler workflow" do
  let(:workflow_path) do
    File.expand_path("../../../.github/workflows/check_bundler.yml", __dir__)
  end

  it "defines a parseable workflow_dispatch trigger" do
    workflow = YAML.safe_load_file(workflow_path)
    trigger_config = workflow.fetch("on") { workflow.fetch(true) }

    expect(trigger_config.fetch("workflow_dispatch").fetch("inputs")).to include(
      "dependencies"
    )
  end
end
