class CreateRefinedFoodsGoodsAndServicesValues < ActiveRecord::Migration
  def self.up
    create_table :refined_foods_goods_and_services_values do |t|
      t.float    :meat_fish_protein
      t.float    :cereals_bakery_products
      t.float    :dairy
      t.float    :fruits_and_veg
      t.float    :eating_out
      t.float    :other
      t.float    :clothing
      t.float    :furnishings
      t.float    :other_goods
      t.float    :services
      t.float    :actual_footprint
      t.integer  :other_foods
      t.integer  :query_id
      t.timestamps
    end
  end

  def self.down
    drop_table :refined_foods_goods_and_services_values
  end
end
