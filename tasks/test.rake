desc "Run all specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', 'spec/spec.opts', '--format progress']
  t.spec_files = FileList['spec/**/*.spec']
end

desc "Profile the specs"
Spec::Rake::SpecTask.new(:profile) do |t|
  t.spec_opts = ['--options', 'spec/spec.opts', '--format profile']
  t.spec_files = FileList['spec/**/*.spec']
end
