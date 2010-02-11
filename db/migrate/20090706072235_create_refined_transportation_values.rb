class CreateRefinedTransportationValues < ActiveRecord::Migration
  def self.up
    create_table :refined_transportation_values do |t|
      t.float    :miles_driven
      t.float    :mpg
      t.float    :actual_footprint
      t.integer  :query_id
      t.timestamps
    end
  end

  def self.down
    drop_table :refined_transportation_values
  end
end
