require  'spec_helper'

MAPPED_PARAMS = { :comment_type => :type2, :author => :author2, :content => :content2,
                  :author_email => :author_email2, :author_url => :author_url2,
                  :permalink => :permalink2 }

class CustomAkismetModel
  include Rakismet::Model
  rakismet_attrs MAPPED_PARAMS.dup
end


describe CustomAkismetModel do
  it "should override default mappings" do
    CustomAkismetModel.akismet_attrs[:comment_type].should eql(:type2)
    CustomAkismetModel.akismet_attrs[:comment_author].should eql(:author2)
    CustomAkismetModel.akismet_attrs[:comment_content].should eql(:content2)
    CustomAkismetModel.akismet_attrs[:comment_author_email].should eql(:author_email2)
    CustomAkismetModel.akismet_attrs[:comment_author_url].should eql(:author_url2)
    CustomAkismetModel.akismet_attrs[:permalink].should eql(:permalink2)
  end
end
