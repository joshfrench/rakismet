require  'spec_helper'

PROC = proc { author.reverse }

class BlockAkismetModel
  include Rakismet::Model
  rakismet_attrs :author => PROC
end

describe BlockAkismetModel do

  before do
    @block = BlockAkismetModel.new
    comment_attrs.each_pair { |k,v| @block.stub!(k).and_return(v) }
  end

  it "should accept a block" do
    BlockAkismetModel.akismet_attrs[:comment_author].should eql(PROC)
  end

  it "should eval block with self = instance" do
    data = @block.send(:akismet_data)
    data[:comment_author].should eql(comment_attrs[:author].reverse)
  end
end
