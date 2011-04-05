class GenericFleet < ActiveRecord::Base
  belongs_to :squad
  belongs_to :planet
  belongs_to :generic_unit

  after_save :destroy_if_empty

  def captured! quantity, squad
    self.quantity = self.quantity - quantity
    captured_fleet = self.clone
    captured_fleet.squad = squad
    captured_fleet.quantity = quantity
    captured_fleet.save
    save
  end

  def type?(type)
    generic_unit.is_a? type
  end

  def to_s
    "Type: #{generic_unit.name} Planet: #{planet.name} Quantity: #{self.quantity}"
  end

  def destroy_if_empty
    destroy if self.quantity == 0
  end


end

