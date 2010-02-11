class TransitionToAuthlogic < ActiveRecord::Migration
  def self.up
    change_column :users, :crypted_password, :string, :limit => 128,
      :null => false, :default => ""
    add_column :users, :persistence_token, :string, :null => false
  end

  def self.down
    remove_column :users, :persistence_token
    change_column :users, :salt, :string, :limit => 128,
      :null => false, :default => ""
  end
end
