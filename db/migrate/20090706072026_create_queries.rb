class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.string   :input
      t.string   :street_address
      t.float    :lat
      t.float    :lng
      t.string   :city
      t.string   :state
      t.string   :zip
      t.string   :country
      t.float    :algorithmic_footprint
      t.text     :tags_cache
      t.timestamps
    end
  end

  def self.down
    drop_table :queries
  end
end
