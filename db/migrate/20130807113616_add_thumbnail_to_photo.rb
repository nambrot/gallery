class AddThumbnailToPhoto < ActiveRecord::Migration
  def change
    add_column :gallery_photos, :thumbnail, :string
    remove_columns :gallery_photos, :images
  end
end
