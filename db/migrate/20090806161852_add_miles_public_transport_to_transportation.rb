class AddMilesPublicTransportToTransportation < ActiveRecord::Migration
  def self.up
    add_column :refined_transportation_values, :miles_public_transport, :float
    RefinedTransportationValue.all.each do |v|
      v.update_attribute(:miles_public_transport, 0)
    end
  end

  def self.down
    remove_column :refined_transportation_values, :miles_public_transport
  end
end
