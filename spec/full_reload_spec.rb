require_relative 'spec_helper'

VENDOR_GEM_CODE_PATH = 'vendor/full_reload_test_gem/lib/full_reload_test_gem.rb'
INITIAL_STRING = "This file was not watched.\nThis string is from a gem."

describe "App Runner: Full Reloading" do
  before do
    self.app_template_path = app_template_fixture("full_reload")
  end

  it "does not reload when a file that isn't watched is changed" do
    start_app
    app_request('/').body.must_equal(INITIAL_STRING)
    change_file('file.notwatched', /not watched/, 'changed')
    # The whole point of this is that a change is NOT fired off--so we
    # can't wait for that.  Sleep to give it time to wrongly trigger,
    # if it were going to.
    sleep(3)
    app_request('/').body.must_match(/^This file was not watched/)
  end

  it "reloads the app when config.ru changes, but not the gem" do
    start_app
    app_request('/').body.must_equal(INITIAL_STRING)
    change_file('file.notwatched', /not watched/, 'changed')
    change_file(VENDOR_GEM_CODE_PATH, /from a gem/, 'also changed but will not be reflected')
    change_file('config.ru', /be reflected.../, 'comment changed just to trigger')
    watch_until_change_detected
    app_request('/').body.must_equal("This file was changed.\nThis string is from a gem.")
  end

  it "reloads the entire app, including gems, when Gemfile is changed" do
    start_app
    app_request('/').body.must_equal(INITIAL_STRING)
    change_file('file.notwatched', /not watched/, 'changed')
    change_file(VENDOR_GEM_CODE_PATH, /from a gem/, 'from a gem and this time it will show changes')
    change_file('Gemfile', /sample Gemfile/, 'sample changed Gemfile')
    watch_until_change_detected
    app_request('/').body.must_equal("This file was changed.\nThis string is from a gem and this time it will show changes.")
  end

  it "recovers if the app becomes unstartable" do
    change_file('Gemfile', /^#A sample/, 'THIS LINE IS BAD')
    start_app
    change_file('Gemfile', /^THIS LINE IS BAD/, '# Now this line is OK again')
    watch_until_change_detected
    app_request('/').body.must_equal(INITIAL_STRING)
  end
end
