require  'spec_helper'

PROC = proc { author.reverse }

class BlockAkismetModel
  include Rakismet::Model
  rakismet_attrs :author => PROC
end

describe BlockAkismetModel do
  before do
    @block = BlockAkismetModel.new
    comment_attrs.each_pair { |k,v| allow(@block).to receive(k){v} }
  end

  it "should accept a block" do
    expect(BlockAkismetModel.akismet_attrs[:comment_author]).to eql(PROC)
  end

  it "should eval block with self = instance" do
    data = @block.send(:akismet_data)
    expect(data[:comment_author]).to eql(comment_attrs[:author].reverse)
  end
end
