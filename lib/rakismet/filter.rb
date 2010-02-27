class Rakismet::Filter
  def self.filter(controller)
    begin
      Rakismet::Base.current_request = controller.request
      yield
    ensure
      Rakismet::Base.current_request = nil
    end
  end
end