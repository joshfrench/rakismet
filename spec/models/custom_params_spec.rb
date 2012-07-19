require  'spec_helper'

MAPPED_PARAMS = { :comment_type => :type2, :author => :author2, :content => :content2,
                  :author_email => :author_email2, :author_url => :author_url2,
                  :user_role => :user_role2 }

class CustomAkismetModel
  include Rakismet::Model
  rakismet_attrs MAPPED_PARAMS.dup
end


describe CustomAkismetModel do
  it "should override default mappings" do
    [:comment_type, :author, :author_url, :author_email, :content, :user_role].each do |field|
      fieldname = field.to_s =~ %r(^comment_) ? field : "comment_#{field}".intern
       CustomAkismetModel.akismet_attrs[fieldname].should eql(MAPPED_PARAMS[field])
     end
  end
end
