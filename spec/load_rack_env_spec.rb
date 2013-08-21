require_relative 'spec_helper'

describe "App Runner: Loading bundler groups based on RACK_ENV" do
  before do
    self.app_template_path = app_template_fixture("load_rack_env_group")
  end

  it "loads the group whose name is specified by RACK_ENV" do
    start_app({'RACK_ENV'=>'foo'})
    app_request('/').body.must_equal('foo')
  end

  it "loads the development group if specified" do
    start_app({'RACK_ENV'=>'development'})
    app_request('/').body.must_equal('development')
  end

  it "loads no groups if nothing is specified" do
    start_app({'RACK_ENV'=>''})
    app_request('/').body.must_equal('')
  end

  it "loads the development group if RACK_ENV is unset" do
    start_app({'RACK_ENV'=>nil})
    app_request('/').body.must_equal('development')
  end
end
