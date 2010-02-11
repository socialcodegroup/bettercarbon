class AddSuggestionToQueries < ActiveRecord::Migration
  def self.up
    add_column :queries, :suggestion, :text
    remove_column :claimed_addresses, :suggestion_1
    remove_column :claimed_addresses, :suggestion_2
    remove_column :claimed_addresses, :suggestion_3
  end

  def self.down
    add_column :claimed_addresses, :suggestion_3, :text
    add_column :claimed_addresses, :suggestion_2, :text
    add_column :claimed_addresses, :suggestion_1, :text
    remove_column :queries, :suggestion
  end
end
