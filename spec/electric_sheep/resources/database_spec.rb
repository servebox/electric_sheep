require 'spec_helper'

describe ElectricSheep::Resources::Database do
  include Support::Options
  include Support::Hosted

  it do
    defines_options :name
    requires :name
  end

  it 'lets the world know its type' do
    subject.new.type.must_equal 'database'
  end
end
