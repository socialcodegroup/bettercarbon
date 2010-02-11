class CreateClaimedAddresses < ActiveRecord::Migration
  def self.up
    create_table :claimed_addresses do |t|
      t.integer :query_id
      t.integer :user_id
      t.text :suggestion_1
      t.text :suggestion_2
      t.text :suggestion_3
      t.timestamps
    end
  end

  def self.down
    drop_table :claimed_addresses
  end
end
