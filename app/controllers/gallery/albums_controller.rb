require_dependency "gallery/application_controller"

module Gallery
  class AlbumsController < ApplicationController
    def index
      @albums = Album.published
    end
  end
end
