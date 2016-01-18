# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-exec_cron"
  gem.version       = "0.0.2"
  gem.summary       = %q{executes external programs with cron syntax.}
  gem.description   = %q{executes external programs with cron syntax.}
  gem.license       = "MIT"
  gem.authors       = ["Hiroshi Toyama"]
  gem.email         = "toyama0919@gmail.com"
  gem.homepage      = "https://github.com/toyama0919/fluent-plugin-exec_cron"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency "parse-cron"
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'fluentd'
  gem.add_development_dependency 'pry', '~> 0.10.1'
  gem.add_development_dependency 'rake', '~> 10.3.2'
  gem.add_development_dependency 'rubocop', '~> 0.24.1'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'yard', '~> 0.8'
end
