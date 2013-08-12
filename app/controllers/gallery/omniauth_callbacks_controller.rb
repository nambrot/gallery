require_dependency "gallery/application_controller"

module Gallery
  class OmniauthCallbacksController < ApplicationController
    def callback
      @omniauth_hash = request.env["omniauth.auth"]
      @omniauth_hash.provider = 'google' if @omniauth_hash.provider == "google_oauth2"

      identity = Identity.find_by_uid_and_provider(@omniauth_hash.uid, @omniauth_hash.provider)
      identity.update_attributes({:token => @omniauth_hash.credentials.token}) if identity
      identity = Identity.create parse_omniauth_hash_to_identity(@omniauth_hash) unless identity

      redirect_to admin_path
    end

    def parse_omniauth_hash_to_identity(omniauth_hash)
      case omniauth_hash.provider
      when 'facebook'
        return { :uid => @omniauth_hash.uid, :provider => @omniauth_hash.provider, :token => @omniauth_hash.credentials.token, :name => @omniauth_hash.info.name, :link => @omniauth_hash.extra.raw_info.link }
      when 'eyeem'
        return { :uid => @omniauth_hash.uid, :provider => @omniauth_hash.provider, :token => @omniauth_hash.credentials.token, :name => @omniauth_hash.info.name, :link => @omniauth_hash.extra.raw_info.user.webUrl }
      when 'google'
        return { :uid => @omniauth_hash.uid, :provider => @omniauth_hash.provider, :token => @omniauth_hash.credentials.token, :name => @omniauth_hash.info.name, :link => @omniauth_hash.extra.raw_info.link }
      end
    end
  end
end
