require 'csv'
require 'geokit'

include Geokit::Geocoders

namespace :default_data do
  desc "Add the default tags into the DB"
  task :tags => :environment do
    CSV.open(File.join(RAILS_ROOT, 'lib', 'default_data', 'tags.csv'), 'r') do |row|
      Tag.create(:phrase => row[0], :frequency => row[1].to_i)
    end
  end
  
  desc "Add the default housing table data into the DB"
  task :housing_table => :environment do
    CSV.open(File.join(RAILS_ROOT, 'lib', 'default_data', 'housing-stats.csv'), 'r') do |row|
      HousingStat.create(:state => row[0], :electricity_emissions => row[1].to_f, :electricity_price => row[2].to_f, :natural_gas_price => row[3].to_f)
    end
  end
  
  # desc "Add the default elec prices into the DB"
  # task :electricity_prices => :environment do
  #   CSV.open(File.join(RAILS_ROOT, 'lib', 'default_data', 'retail-electric.csv'), 'r') do |row|
  #     HousingStat.create(:state => row[0], :electricity_price => (row[1].to_f / 100.0))
  #   end
  # end
  
  desc "mturk_survey_1 data"
  task :mturk_survey_1 => :environment do
    CSV.open(File.join(RAILS_ROOT, 'lib', 'default_data', 'mturk_survey_1_seed_data.csv'), 'r') do |row|
      calculator_input = CalculatorInput.new(:address => row[1], :tags => '') rescue nil
      
      if calculator_input.blank? || calculator_input.user_input.new_record?
        # ignore
      else
        CarbonCalculator.modules.each { |m|
          case m.to_s
          when "Modules::Transportation"
            m.process_input(calculator_input, {:miles_driven => row[5], :mpg => row[4]})
          when "Modules::AirTravel"
            m.process_input(calculator_input, {:num_short_trips => row[6], :num_medium_trips => row[7], :num_long_trips => row[8], :num_extended_trips => row[9]})
          when "Modules::HomeEnergy"
            m.process_input(calculator_input, {:electricity_costs => row[10], :natural_gas_costs => row[11], :other_fuel_costs => row[12], :water_and_sewage_costs => row[13], :square_feet_of_household => row[14]})
          when "Modules::Food"
            m.process_input(calculator_input, {:meat_fish_protein => row[15], :cereals_bakery_products => row[16], :dairy => row[17], :fruits_and_veg => row[18], :eating_out => row[19], :other_foods => row[20]})
          when "Modules::GoodsAndServices"
            m.process_input(calculator_input, {:clothing => row[22], :furnishings => row[23], :other_goods => row[21], :services => row[24]})
          end
        }
        calculator_input.user_input.reload
        calculator_result = CarbonCalculator.process(calculator_input)
        calculator_input.user_input.update_attributes(:algorithmic_footprint => calculator_result.total_footprint)
      end
    end
  end
  
  desc "mturk_survey_2 data"
  task :mturk_survey_2 => :environment do
    CSV.open(File.join(RAILS_ROOT, 'lib', 'default_data', 'new-bcc-data.csv'), 'r') do |row|
      calculator_input = CalculatorInput.new(:address => "#{row[0]}, #{row[1]}", :tags => '') rescue nil
      
      if calculator_input.blank? || calculator_input.user_input.new_record?
        # ignore
      else
        CarbonCalculator.modules.each { |m|
          case m.to_s
          when "Modules::Transportation"
            m.process_input(calculator_input, {:miles_driven => row[2], :mpg => row[3], :fuel_type => row[4], :vehicle_size => row[5], :miles_public_transport => row[7]})
          when "Modules::AirTravel"
            m.process_input(calculator_input, {:num_short_trips => row[8], :num_medium_trips => row[9], :num_long_trips => row[10], :num_extended_trips => row[11]})
          when "Modules::HomeEnergy"
            m.process_input(calculator_input, {:electricity_costs => row[12], :natural_gas_costs => row[13], :other_fuel_costs => row[14], :water_and_sewage_costs => row[15]})
          when "Modules::Food"
            m.process_input(calculator_input, {:meat_fish_protein => row[16], :cereals_bakery_products => row[17], :dairy => row[18], :fruits_and_veg => row[19], :eating_out => row[20], :other_foods => row[21], :eat_organic_food => row[22]})
          when "Modules::GoodsAndServices"
            m.process_input(calculator_input, {:clothing => row[23], :furnishings => row[24], :other_goods => row[25], :services => row[26]})
          end
        }
        calculator_input.user_input.reload
        calculator_result = CarbonCalculator.process(calculator_input)
        calculator_input.user_input.update_attributes(:suggestion => row[27], :algorithmic_footprint => calculator_result.total_footprint)
      end
    end
  end
  
  desc "mturk_survey_3 data"
  task :mturk_survey_3 => :environment do
    CSV.open(File.join(RAILS_ROOT, 'lib', 'default_data', 'bcc_data_3-249.csv'), 'r') do |row|
      calculator_input = CalculatorInput.new(:address => "#{row[1]}, #{row[2]} #{row[3]}", :tags => '') rescue nil
      
      if calculator_input.blank? || calculator_input.user_input.new_record?
        # ignore
      else
        CarbonCalculator.modules.each { |m|
          case m.to_s
          when "Modules::Transportation"
            m.process_input(calculator_input, {:miles_driven => row[4], :mpg => row[5], :fuel_type => row[9], :vehicle_size => row[8], :miles_public_transport => row[7]})
          when "Modules::AirTravel"
            m.process_input(calculator_input, {:num_short_trips => row[10], :num_medium_trips => row[11], :num_long_trips => row[12], :num_extended_trips => row[13]})
          when "Modules::HomeEnergy"
            m.process_input(calculator_input, {:electricity_costs => row[14], :natural_gas_costs => row[15], :other_fuel_costs => row[16], :water_and_sewage_costs => row[17], :square_feet_of_household => row[18]})
          when "Modules::Food"
            m.process_input(calculator_input, {:meat_fish_protein => row[19], :cereals_bakery_products => row[20], :dairy => row[21], :fruits_and_veg => row[22], :eating_out => row[23], :other_foods => row[24], :eat_organic_food => row[25]})
          when "Modules::GoodsAndServices"
            m.process_input(calculator_input, {:clothing => row[26], :furnishings => row[27], :other_goods => row[28], :services => row[29]})
          end
        }
        calculator_input.user_input.reload
        calculator_result = CarbonCalculator.process(calculator_input)
        calculator_input.user_input.update_attributes(:suggestion => row[30], :algorithmic_footprint => calculator_result.total_footprint)
      end
    end
  end
  
  
  desc "mturk_survey_4 data"
  task :mturk_survey_4 => :environment do
    CSV.open(File.join(RAILS_ROOT, 'lib', 'default_data', 'bcc_data_3_283.csv'), 'r') do |row|
      calculator_input = CalculatorInput.new(:address => "#{row[0]}, #{row[1]} #{row[2]}", :tags => '') rescue nil
      
      if calculator_input.blank? || calculator_input.user_input.new_record?
        # ignore
      else
        CarbonCalculator.modules.each { |m|
          case m.to_s
          when "Modules::Transportation"
            m.process_input(calculator_input, {:miles_driven => row[3], :mpg => row[4], :fuel_type => row[8], :vehicle_size => row[7], :miles_public_transport => row[6]})
          when "Modules::AirTravel"
            m.process_input(calculator_input, {:num_short_trips => row[9], :num_medium_trips => row[10], :num_long_trips => row[11], :num_extended_trips => row[12]})
          when "Modules::HomeEnergy"
            m.process_input(calculator_input, {:electricity_costs => row[13], :natural_gas_costs => row[14], :other_fuel_costs => row[15], :water_and_sewage_costs => row[16], :square_feet_of_household => row[17]})
          when "Modules::Food"
            m.process_input(calculator_input, {:meat_fish_protein => row[18], :cereals_bakery_products => row[19], :dairy => row[20], :fruits_and_veg => row[21], :eating_out => row[22], :other_foods => row[23], :eat_organic_food => row[24]})
          when "Modules::GoodsAndServices"
            m.process_input(calculator_input, {:clothing => row[25], :furnishings => row[26], :other_goods => row[27], :services => row[28]})
          end
        }
        calculator_input.user_input.reload
        calculator_result = CarbonCalculator.process(calculator_input)
        calculator_input.user_input.update_attributes(:suggestion => row[29], :algorithmic_footprint => calculator_result.total_footprint)
      end
    end
  end
  
  desc "Add all default data into the DB"
  task :all => [:mturk_survey_2, :mturk_survey_3, :mturk_survey_4]
end