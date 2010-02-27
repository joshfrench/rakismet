class Rakismet::Filter
  def self.filter(controller)
    Rakismet::Base.current_request = controller.request
    yield
    Rakismet::Base.current_request = nil
  end
end