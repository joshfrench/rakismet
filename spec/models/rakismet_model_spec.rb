require  'spec_helper'

describe AkismetModel do

  before do
    @model = AkismetModel.new
    comment_attrs.each_pair { |k,v| @model.stub!(k).and_return(v) }
  end

  it "should have default mappings" do
    [:comment_type, :author, :author_email, :author_url, :content, :permalink].each do |field|
      fieldname = field.to_s =~ %r(^comment_) ? field : "comment_#{field}".intern
      AkismetModel.akismet_attrs[fieldname].should eql(field)
     end
    AkismetModel::akismet_attrs[:user_role].should eql(:user_role)
  end

  it "should have request mappings" do
    [:user_ip, :user_agent, :referrer].each do |field|
      AkismetModel.akismet_attrs[field].should eql(field)
     end
  end

  it "should populate comment type" do
    @model.send(:akismet_data)[:comment_type].should == comment_attrs[:comment_type]
  end

  describe ".spam?" do

    it "should use request variables from Rakismet.request if absent in model" do
      [:user_ip, :user_agent, :referrer].each do |field|
        @model.should_not respond_to(:field)
      end
      Rakismet.stub!(:request).and_return(request)
      Rakismet.should_receive(:akismet_call).
                with('comment-check', akismet_attrs.merge(:user_ip => '127.0.0.1',
                                                          :user_agent => 'RSpec',
                                                          :referrer => 'http://test.host/referrer'))
      @model.spam?
    end

    it "should send http_headers from Rakismet.request if present" do
      Rakismet.stub!(:request).and_return(request_with_headers)
      Rakismet.should_receive(:akismet_call).
                with('comment-check', akismet_attrs.merge(:user_ip => '127.0.0.1',
                                                          :user_agent => 'RSpec',
                                                          :referrer => 'http://test.host/referrer',
                                                          'HTTP_USER_AGENT' => 'RSpec',
                                                          'HTTP_REFERER' => 'http://test.host/referrer'))
      @model.spam?
    end

    it "should cache result of #spam?" do
      Rakismet.should_receive(:akismet_call).once
      @model.spam?
      @model.spam?
    end

    it "should be true if comment is spam" do
      Rakismet.stub!(:akismet_call).and_return('true')
      @model.should be_spam
    end

    it "should be false if comment is not spam" do
      Rakismet.stub!(:akismet_call).and_return('false')
      @model.should_not be_spam
    end

    it "should set akismet_response" do
      Rakismet.stub!(:akismet_call).and_return('response')
      @model.spam?
      @model.akismet_response.should eql('response')
    end

    it "should not throw an error if request vars are missing" do
      Rakismet.stub!(:request).and_return(empty_request)
      lambda { @model.spam? }.should_not raise_error(NoMethodError)
    end
  end


  describe ".spam!" do
    it "should call Base.akismet_call with submit-spam" do
      Rakismet.should_receive(:akismet_call).with('submit-spam', akismet_attrs)
      @model.spam!
    end

    it "should mutate #spam?" do
      Rakismet.stub!(:akismet_call)
      @model.instance_variable_set(:@_spam, false)
      @model.spam!
      @model.should be_spam
    end
  end

  describe ".ham!" do
    it "should call Base.akismet_call with submit-ham" do
      Rakismet.should_receive(:akismet_call).with('submit-ham', akismet_attrs)
      @model.ham!
    end

    it "should mutate #spam?" do
      Rakismet.stub!(:akismet_call)
      @model.instance_variable_set(:@_spam, true)
      @model.ham!
      @model.should_not be_spam
    end
  end

end
