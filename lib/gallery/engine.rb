require 'omniauth'
require 'omniauth-google-oauth2'
require 'omniauth-facebook'

module Gallery
  class Engine < ::Rails::Engine
    isolate_namespace Gallery
  end
end
