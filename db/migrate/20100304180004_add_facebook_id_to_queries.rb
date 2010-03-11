class AddFacebookIdToQueries < ActiveRecord::Migration
  def self.up
    add_column :queries, :facebook_uid, :integer, :limit => 8
  end

  def self.down
    remove_column :queries, :facebook_uid
  end
end
