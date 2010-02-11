class CreateRefinedFoodValues < ActiveRecord::Migration
  def self.up
    create_table :refined_food_values do |t|
      t.float    :meat_fish_protein
      t.float    :cereals_bakery_products
      t.float    :dairy
      t.float    :fruits_and_veg
      t.float    :eating_out
      t.float    :other
      t.integer  :other_foods
      t.float    :actual_footprint
      t.integer  :query_id
      t.timestamps
    end
  end

  def self.down
    drop_table :refined_food_values
  end
end
