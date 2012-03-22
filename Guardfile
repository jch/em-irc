# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
end

guard 'rspec', :version => 2, :cli => '--tag ~integration' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('lib/em-irc.rb')        { "spec" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard 'yard', :stdout => '/dev/null' do
  watch(%r{lib/.+\.rb})
end
