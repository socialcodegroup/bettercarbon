class CreateHousingStats < ActiveRecord::Migration
  def self.up
    create_table :housing_stats do |t|
      t.string    :state
      t.float     :electricity_price
      t.timestamps
    end
  end

  def self.down
    drop_table :housing_stats
  end
end
