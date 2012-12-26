require_relative 'spec_helper'

describe "App Runner: Normal Operation" do
  before do
    self.app_template_path = app_template_fixture('hello')
  end

  it "runs the application" do
    start_app
    app_request('/').body.must_match(/^Hello, world!/)
  end

  it "reloads the application when a ruby file changes" do
    start_app
    app_request('/').body.must_match(/^Hello, world!/)
    change_file('config.ru', /world/, "Dolly")
    watch_until_change_detected
    app_request('/').body.must_match(/^Hello, Dolly!/)
  end
end
