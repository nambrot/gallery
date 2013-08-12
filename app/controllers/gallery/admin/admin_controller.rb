require_dependency "gallery/application_controller"

module Gallery
  class Admin::AdminController < ApplicationController
    def index
      @identities = Identity.all
      @public_albums = Album.published
      @private_albums = Album.private
    end
  end
end
