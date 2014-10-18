$root = File.expand_path('../../../', __FILE__)
require "#{$root}/spec_helper"

describe Rawscsi do
  it 'must be defined' do
    Rawscsi::VERSION.should_not be_nil
  end
end