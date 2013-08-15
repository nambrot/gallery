require_dependency "gallery/application_controller"

module Gallery
  class Admin::AdminController < ApplicationController
    before_filter :login_required
    def index
      @identities = Identity.all
      @public_albums = Album.published
      @private_albums = Album.private
      configpath = Rails.root.join('config', 'gallery_api_keys.yml')
      @providers = YAML.load(ERB.new(File.new(configpath).read).result).keys
    end
  end
end
