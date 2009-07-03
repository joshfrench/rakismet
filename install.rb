File.open(File.join(RAILS_ROOT, %w(config initializers rakismet.rb)) , 'w') do |f|
  f.puts "Rakismet::KEY  = ''"
  f.puts "Rakismet::URL  = ''"
  f.puts "Rakismet::HOST = 'rest.akismet.com'"
end