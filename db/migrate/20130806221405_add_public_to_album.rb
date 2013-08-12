class AddPublicToAlbum < ActiveRecord::Migration
  def change
    add_column :gallery_albums, :public, :boolean, default: false
  end
end
