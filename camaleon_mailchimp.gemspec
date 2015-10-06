$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'camaleon_mailchimp/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = 'camaleon_mailchimp'
  s.version = CamaleonMailchimp::VERSION
  s.authors = ['Raúl Anatol']
  s.email = ['raul@natol.es']
  s.homepage = ''
  s.summary = ': Summary of CamaleonMailchimp.'
  s.description = ': Description of CamaleonMailchimp.'
  s.license = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4.2', '>= 4.2.4'
  s.add_dependency 'gibbon', '~> 2.0'
end
