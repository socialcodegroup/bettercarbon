class CreateRefinedAirTravelValues < ActiveRecord::Migration
  def self.up
    create_table :refined_air_travel_values do |t|
      t.float    :num_short_trips
      t.float    :num_medium_trips
      t.float    :num_long_trips
      t.float    :num_extended_trips
      t.float    :actual_footprint
      t.integer  :query_id
      t.timestamps
    end
  end

  def self.down
    drop_table :refined_air_travel_values
  end
end
