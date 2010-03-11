# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100304180004) do

  create_table "claimed_addresses", :force => true do |t|
    t.integer  "query_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacted_twitter_users", :force => true do |t|
    t.string   "screen_name"
    t.text     "from_tweet_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "housing_stats", :force => true do |t|
    t.string   "state"
    t.float    "electricity_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "electricity_emissions"
    t.float    "natural_gas_price"
  end

  create_table "queries", :force => true do |t|
    t.string   "input"
    t.string   "street_address"
    t.float    "lat"
    t.float    "lng"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.float    "algorithmic_footprint"
    t.text     "tags_cache"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "suggestion"
    t.integer  "facebook_uid",          :limit => 8
  end

  add_index "queries", ["city"], :name => "index_queries_on_city"
  add_index "queries", ["country"], :name => "index_queries_on_country"
  add_index "queries", ["lat"], :name => "index_queries_on_lat"
  add_index "queries", ["lng"], :name => "index_queries_on_lng"
  add_index "queries", ["state"], :name => "index_queries_on_state"
  add_index "queries", ["street_address"], :name => "index_queries_on_street_address"
  add_index "queries", ["zip"], :name => "index_queries_on_zip"

  create_table "query_tags", :force => true do |t|
    t.integer  "query_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "query_tags", ["query_id"], :name => "index_query_tags_on_query_id"
  add_index "query_tags", ["tag_id"], :name => "index_query_tags_on_tag_id"

  create_table "refined_air_travel_values", :force => true do |t|
    t.float    "num_short_trips"
    t.float    "num_medium_trips"
    t.float    "num_long_trips"
    t.float    "num_extended_trips"
    t.float    "actual_footprint"
    t.integer  "query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refined_air_travel_values", ["num_extended_trips"], :name => "index_refined_air_travel_values_on_num_extended_trips"
  add_index "refined_air_travel_values", ["num_long_trips"], :name => "index_refined_air_travel_values_on_num_long_trips"
  add_index "refined_air_travel_values", ["num_medium_trips"], :name => "index_refined_air_travel_values_on_num_medium_trips"
  add_index "refined_air_travel_values", ["num_short_trips"], :name => "index_refined_air_travel_values_on_num_short_trips"
  add_index "refined_air_travel_values", ["query_id"], :name => "index_refined_air_travel_values_on_query_id"

  create_table "refined_food_values", :force => true do |t|
    t.float    "meat_fish_protein"
    t.float    "cereals_bakery_products"
    t.float    "dairy"
    t.float    "fruits_and_veg"
    t.float    "eating_out"
    t.float    "other"
    t.integer  "other_foods"
    t.float    "actual_footprint"
    t.integer  "query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "eat_organic_food"
  end

  add_index "refined_food_values", ["cereals_bakery_products"], :name => "index_refined_food_values_on_cereals_bakery_products"
  add_index "refined_food_values", ["dairy"], :name => "index_refined_food_values_on_dairy"
  add_index "refined_food_values", ["eating_out"], :name => "index_refined_food_values_on_eating_out"
  add_index "refined_food_values", ["fruits_and_veg"], :name => "index_refined_food_values_on_fruits_and_veg"
  add_index "refined_food_values", ["meat_fish_protein"], :name => "index_refined_food_values_on_meat_fish_protein"
  add_index "refined_food_values", ["other"], :name => "index_refined_food_values_on_other"
  add_index "refined_food_values", ["other_foods"], :name => "index_refined_food_values_on_other_foods"
  add_index "refined_food_values", ["query_id"], :name => "index_refined_food_values_on_query_id"

  create_table "refined_foods_goods_and_services_values", :force => true do |t|
    t.float    "meat_fish_protein"
    t.float    "cereals_bakery_products"
    t.float    "dairy"
    t.float    "fruits_and_veg"
    t.float    "eating_out"
    t.float    "other"
    t.float    "clothing"
    t.float    "furnishings"
    t.float    "other_goods"
    t.float    "services"
    t.float    "actual_footprint"
    t.integer  "other_foods"
    t.integer  "query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "refined_goods_and_services_values", :force => true do |t|
    t.float    "other"
    t.float    "clothing"
    t.float    "furnishings"
    t.float    "other_goods"
    t.float    "services"
    t.float    "actual_footprint"
    t.integer  "query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refined_goods_and_services_values", ["clothing"], :name => "index_refined_goods_and_services_values_on_clothing"
  add_index "refined_goods_and_services_values", ["furnishings"], :name => "index_refined_goods_and_services_values_on_furnishings"
  add_index "refined_goods_and_services_values", ["other"], :name => "index_refined_goods_and_services_values_on_other"
  add_index "refined_goods_and_services_values", ["other_goods"], :name => "index_refined_goods_and_services_values_on_other_goods"
  add_index "refined_goods_and_services_values", ["query_id"], :name => "index_refined_goods_and_services_values_on_query_id"
  add_index "refined_goods_and_services_values", ["services"], :name => "index_refined_goods_and_services_values_on_services"

  create_table "refined_housing_values", :force => true do |t|
    t.float    "electricity_costs"
    t.float    "natural_gas_costs"
    t.float    "other_fuel_costs"
    t.float    "water_and_sewage_costs"
    t.float    "square_feet_of_household"
    t.float    "actual_footprint"
    t.integer  "query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refined_housing_values", ["electricity_costs"], :name => "index_refined_housing_values_on_electricity_costs"
  add_index "refined_housing_values", ["natural_gas_costs"], :name => "index_refined_housing_values_on_natural_gas_costs"
  add_index "refined_housing_values", ["other_fuel_costs"], :name => "index_refined_housing_values_on_other_fuel_costs"
  add_index "refined_housing_values", ["query_id"], :name => "index_refined_housing_values_on_query_id"
  add_index "refined_housing_values", ["square_feet_of_household"], :name => "index_refined_housing_values_on_square_feet_of_household"
  add_index "refined_housing_values", ["water_and_sewage_costs"], :name => "index_refined_housing_values_on_water_and_sewage_costs"

  create_table "refined_transportation_values", :force => true do |t|
    t.float    "miles_driven"
    t.float    "mpg"
    t.float    "actual_footprint"
    t.integer  "query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "miles_public_transport"
    t.integer  "fuel_type"
    t.integer  "vehicle_size"
  end

  add_index "refined_transportation_values", ["miles_driven"], :name => "index_refined_transportation_values_on_miles_driven"
  add_index "refined_transportation_values", ["miles_public_transport"], :name => "index_refined_transportation_values_on_miles_public_transport"
  add_index "refined_transportation_values", ["mpg"], :name => "index_refined_transportation_values_on_mpg"
  add_index "refined_transportation_values", ["query_id"], :name => "index_refined_transportation_values_on_query_id"

  create_table "tags", :force => true do |t|
    t.string   "phrase"
    t.integer  "frequency",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["frequency"], :name => "index_tags_on_frequency"
  add_index "tags", ["phrase"], :name => "index_tags_on_phrase"

  create_table "users", :force => true do |t|
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 128, :default => "", :null => false
    t.string   "salt",                      :limit => 128, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "reset_code"
    t.string   "persistence_token",                                        :null => false
    t.integer  "facebook_uid",              :limit => 8
    t.string   "facebook_session_key"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
