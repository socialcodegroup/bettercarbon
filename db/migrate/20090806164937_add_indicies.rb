class AddIndicies < ActiveRecord::Migration
  def self.up
    add_index :queries, :street_address
    add_index :queries, :lat
    add_index :queries, :lng
    
    add_index :query_tags, :query_id
    add_index :query_tags, :tag_id
    
    add_index :refined_air_travel_values, :num_short_trips
    add_index :refined_air_travel_values, :num_medium_trips
    add_index :refined_air_travel_values, :num_long_trips
    add_index :refined_air_travel_values, :num_extended_trips
    add_index :refined_air_travel_values, :query_id
    
    add_index :refined_food_values, :meat_fish_protein
    add_index :refined_food_values, :cereals_bakery_products
    add_index :refined_food_values, :dairy
    add_index :refined_food_values, :fruits_and_veg
    add_index :refined_food_values, :eating_out
    add_index :refined_food_values, :other
    add_index :refined_food_values, :other_foods
    add_index :refined_food_values, :query_id
    
    add_index :refined_goods_and_services_values, :other
    add_index :refined_goods_and_services_values, :clothing
    add_index :refined_goods_and_services_values, :furnishings
    add_index :refined_goods_and_services_values, :other_goods
    add_index :refined_goods_and_services_values, :services
    add_index :refined_goods_and_services_values, :query_id
    
    add_index :refined_housing_values, :electricity_costs
    add_index :refined_housing_values, :natural_gas_costs
    add_index :refined_housing_values, :other_fuel_costs
    add_index :refined_housing_values, :water_and_sewage_costs
    add_index :refined_housing_values, :square_feet_of_household
    add_index :refined_housing_values, :query_id
    
    add_index :refined_transportation_values, :miles_driven
    add_index :refined_transportation_values, :mpg
    add_index :refined_transportation_values, :query_id
    add_index :refined_transportation_values, :miles_public_transport
    
    add_index :tags, :phrase
    add_index :tags, :frequency
  end
  
  def self.down
    remove_index :queries, :street_address
    remove_index :queries, :lat
    remove_index :queries, :lng

    remove_index :query_tags, :query_id
    remove_index :query_tags, :tag_id

    remove_index :refined_air_travel_values, :num_short_trips
    remove_index :refined_air_travel_values, :num_medium_trips
    remove_index :refined_air_travel_values, :num_long_trips
    remove_index :refined_air_travel_values, :num_extended_trips
    remove_index :refined_air_travel_values, :query_id

    remove_index :refined_food_values, :meat_fish_protein
    remove_index :refined_food_values, :cereals_bakery_products
    remove_index :refined_food_values, :dairy
    remove_index :refined_food_values, :fruits_and_veg
    remove_index :refined_food_values, :eating_out
    remove_index :refined_food_values, :other
    remove_index :refined_food_values, :other_foods
    remove_index :refined_food_values, :query_id

    remove_index :refined_goods_and_services_values, :other
    remove_index :refined_goods_and_services_values, :clothing
    remove_index :refined_goods_and_services_values, :furnishings
    remove_index :refined_goods_and_services_values, :other_goods
    remove_index :refined_goods_and_services_values, :services
    remove_index :refined_goods_and_services_values, :query_id

    remove_index :refined_housing_values, :electricity_costs
    remove_index :refined_housing_values, :natural_gas_costs
    remove_index :refined_housing_values, :other_fuel_costs
    remove_index :refined_housing_values, :water_and_sewage_costs
    remove_index :refined_housing_values, :square_feet_of_household
    remove_index :refined_housing_values, :query_id

    remove_index :refined_transportation_values, :miles_driven
    remove_index :refined_transportation_values, :mpg
    remove_index :refined_transportation_values, :query_id
    remove_index :refined_transportation_values, :miles_public_transport

    remove_index :tags, :phrase
    remove_index :tags, :frequency
  end
end
