require  'spec_helper'

EXTRA = { :extra => :extra, :another => lambda { } }

class ExtendedAkismetModel
  include Rakismet::Model
  rakismet_attrs EXTRA.dup
end

describe ExtendedAkismetModel do
  it "should include additional attributes" do
    [:extra, :another].each do |field|
      ExtendedAkismetModel.akismet_attrs[field].should eql(EXTRA[field])
    end
  end
end
