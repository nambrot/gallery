class CreateGalleryIdentities < ActiveRecord::Migration
  def change
    create_table :gallery_identities do |t|
      t.string :uid
      t.string :provider
      t.string :name
      t.string :link

      t.timestamps
    end

    add_index :gallery_identities, [:uid, :provider], :unique => true
  end
end
