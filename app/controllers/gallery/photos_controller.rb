require_dependency "gallery/application_controller"

module Gallery
  class PhotosController < ApplicationController
    respond_to :json
    
    if respond_to?('caches_action')
      caches_action :index
    end

    def index
      album = Album.find_by_id(params[:album_id])
      album = Album.find_by_uid_and_provider(params[:album_id].split('-').first, params[:album_id].split('-').last) unless album
      photos = album.photos
      if album.public
        respond_with photos, :only => [:id, :album_id, :source, :name, :aspect_ratio, :thumbnail]
      else
        respond_with []
      end
    end

  end
end
