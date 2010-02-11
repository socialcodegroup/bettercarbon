class AddMoreIndicies < ActiveRecord::Migration
  def self.up
    add_index :queries, :city
    add_index :queries, :state
    add_index :queries, :zip
    add_index :queries, :country
  end

  def self.down
    remove_index :queries, :city
    remove_index :queries, :state
    remove_index :queries, :zip
    remove_index :queries, :country
  end
end
