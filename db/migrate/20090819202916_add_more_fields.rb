class AddMoreFields < ActiveRecord::Migration
  def self.up
    add_column :refined_transportation_values, :fuel_type, :integer
    add_column :refined_transportation_values, :vehicle_size, :integer
    add_column :refined_food_values, :eat_organic_food, :integer
  end

  def self.down
    remove_column :refined_food_values, :eat_organic_food
    remove_column :refined_transportation_values, :vehicle_size
    remove_column :refined_transportation_values, :fuel_type
  end
end
