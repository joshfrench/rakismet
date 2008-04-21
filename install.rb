File.open(File.join(RAILS_ROOT, %w(config initializers rakismet.rb)) , 'w') do |f|
  f.puts "Rakismet::KEY = ''\nRakismet::URL = ''"
end