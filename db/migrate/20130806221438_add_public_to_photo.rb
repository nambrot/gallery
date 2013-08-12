class AddPublicToPhoto < ActiveRecord::Migration
  def change
    add_column :gallery_photos, :public, :boolean, default: true
  end
end
