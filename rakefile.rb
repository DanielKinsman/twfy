require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => [:test]

Rake::TestTask.new do |t|
    #t.libs << "test"
    t.test_files = FileList['tests/test*.rb']
    t.verbose = true
end

namespace :test do

  desc 'Measures test coverage'
  task :coverage do
    rm_f "coverage"
    system("rcov --text-summary -Ilib -x/Library/ tests/test_*.rb")
    system("open coverage/index.html") if PLATFORM['darwin']
  end

end
