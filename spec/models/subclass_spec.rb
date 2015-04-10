require  'spec_helper'

class Subclass < AkismetModel
end

describe Subclass do
  it "should inherit parent's rakismet attrs" do
    expect(Subclass.akismet_attrs).to eql(AkismetModel.akismet_attrs) # key/value equality
  end

  it "should get a new copy of parent's rakismet attrs" do
    expect(Subclass.akismet_attrs).not_to equal(AkismetModel.akismet_attrs) # object equality
  end
end
