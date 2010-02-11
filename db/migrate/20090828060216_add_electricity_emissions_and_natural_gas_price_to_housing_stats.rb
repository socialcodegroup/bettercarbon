class AddElectricityEmissionsAndNaturalGasPriceToHousingStats < ActiveRecord::Migration
  def self.up
    add_column :housing_stats, :electricity_emissions, :float
    add_column :housing_stats, :natural_gas_price, :float
  end

  def self.down
    remove_column :housing_stats, :natural_gas_price
    remove_column :housing_stats, :electricity_emissions
  end
end
