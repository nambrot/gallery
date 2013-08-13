require_dependency "gallery/application_controller"

module Gallery
  class Admin::AlbumsController < ApplicationController

    before_filter :login_required

    def set_public
      album = Album.find(params[:album_id])
      album.update_attributes(:public => true)
      redirect_to :back, :notice => "Album #{album.name} set public"
    end

    def set_private
      album = Album.find(params[:album_id])
      album.update_attributes(:public => false)
      redirect_to :back, :notice => "Album #{album.name} set private"
    end

    def fetch_photos
      album = Album.find(params[:album_id])
      album.fetch_photos
      redirect_to :back, :notice => "Photos fetched"
    end

    def show
      @album = Album.find(params[:id])
    end

  end
end
