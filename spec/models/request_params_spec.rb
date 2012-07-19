require  'spec_helper'

class RequestParams
  include Rakismet::Model
  attr_accessor :user_ip, :user_agent, :referrer
end

describe RequestParams do
    before do
      @model = RequestParams.new
      attrs = comment_attrs(:user_ip => '192.168.0.1', :user_agent => 'Rakismet', :referrer => 'http://localhost/referrer')
      attrs.each_pair { |k,v| @model.stub!(k).and_return(v) }
    end

  it "should use local values even if Rakismet.request is populated" do
    Rakismet.stub(:request).and_return(request)
    Rakismet.should_receive(:akismet_call).
              with('comment-check', akismet_attrs.merge(:user_ip => '192.168.0.1',
                                                        :user_agent => 'Rakismet',
                                                        :referrer => 'http://localhost/referrer'))
    @model.spam?
  end
end
