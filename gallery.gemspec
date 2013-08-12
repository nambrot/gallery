$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gallery/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gallery"
  s.version     = Gallery::VERSION
  s.authors     = ["Nam Chu Hoai"]
  s.email       = ["nambrot@gmail.com"]
  s.homepage    = "https://www.github.com/nambrot/gallery"
  s.summary     = "An easy gem to include a gallery to your site"
  s.description = "An easy gem to include a gallery to your site"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0.rc1"
  s.add_dependency "omniauth"
  s.add_dependency "omniauth-google-oauth2"
  s.add_dependency "omniauth-facebook"
  s.add_dependency 'sass-rails'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'bourbon'
  s.add_development_dependency "sqlite3"
end


# config options
# run in process or background job
# path at which is mounted (for omniauth)
# authentication methods