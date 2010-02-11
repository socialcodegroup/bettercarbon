class CreateRefinedGoodsAndServicesValues < ActiveRecord::Migration
  def self.up
    create_table :refined_goods_and_services_values do |t|
      t.float    :other
      t.float    :clothing
      t.float    :furnishings
      t.float    :other_goods
      t.float    :services
      t.float    :actual_footprint
      t.integer  :query_id
      t.timestamps
    end
  end

  def self.down
    drop_table :refined_goods_and_services_values
  end
end
