class AddTokenToIdentity < ActiveRecord::Migration
  def change
    add_column :gallery_identities, :token, :string
  end
end
