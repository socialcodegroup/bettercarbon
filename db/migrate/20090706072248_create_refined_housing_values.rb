class CreateRefinedHousingValues < ActiveRecord::Migration
  def self.up
    create_table :refined_housing_values do |t|
      t.float    :electricity_costs
      t.float    :natural_gas_costs
      t.float    :other_fuel_costs
      t.float    :water_and_sewage_costs
      t.float    :square_feet_of_household
      t.float    :actual_footprint
      t.integer  :query_id
      t.timestamps
    end
  end

  def self.down
    drop_table :refined_housing_values
  end
end
