class CreateGalleryPhotos < ActiveRecord::Migration
  def change
    create_table :gallery_photos do |t|
      t.integer :album_id
      t.text :images
      t.string :source
      t.string :name
      t.string :url
      t.string :uid
      t.string :provider
      t.float :aspect_ratio

      t.timestamps
    end

    add_index :gallery_photos, [:uid, :provider], :unique => true
  end
end
