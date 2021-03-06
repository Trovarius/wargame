class Squad < ActiveRecord::Base

  default_scope :order => 'id ASC'

  has_many :planets
  has_many :generic_fleets
  has_many :facility_fleets
  has_many :fleets

  def faction=(faction)
    write_attribute(:faction, FACTIONS.rindex(faction))
  end

  def faction
    FACTIONS[read_attribute(:faction)] if read_attribute(:faction)
  end

  def buy unit, quantity, planet
    if (unit.belongs?(faction)) and (unit.is_a? Facility)
      self.credits = self.credits - (unit.price * quantity)
      new_fleet = FacilityFleet.create(:generic_unit => unit, :quantity => quantity, :planet => planet, :balance => 0)
      generic_fleets << new_fleet
      save
    else
      false
    end
  end

  def generate_profits!
    planets.each do |planet|
      self.credits = self.credits + planet.credits_per_turn
      save
    end
  end

  def change_producing_unit facility_fleet, unit
      facility_fleet.producing_unit = unit
      facility_fleet.save!
  end

  def random_planet_but planet
    planets_array = planets.to_a - [planet]
    return false if planets_array.empty?
    random_planet = planets_array[rand(planets_array.size)]
  end

  def warp_facility_on planet
    facility_model = Facility.allowed_for(faction).last
    facility = facility_fleets.new(:facility => facility_model, :planet => planet)
    facility.save!
  end

  def warp_units total_value, unit, planet
    if unit == CapitalShip
      units = unit.allowed_for(faction).where(:price => 500..2000)
    else
      units = unit.allowed_for(faction).all
    end
    random_unit = units[rand(units.size)]
    unit_count = 0
    while (total_value >= random_unit.price)
      unit_count += 1
      total_value -= random_unit.price
    end
    fleet = fleets.new(:generic_unit_id => random_unit.id, :planet => planet, :quantity => unit_count)
    fleet.save!
  end

  def populate_planets
    planets.each do |planet|
      warp_units 4000, Fighter, planet
      warp_units 2000, CapitalShip, planet
      warp_units 1000, Trooper, planet
      warp_facility_on planet
    end
    save!
  end

  def transfer_credits quantity, destination
    if self.credits >= quantity && self != destination
      self.debit quantity
      destination.deposit quantity
    end
  end

  def debit quantity
    self.credits -= quantity
    save
  end

  def deposit quantity
    self.credits += quantity
    save
  end

  def ready!
    self.ready = true
    save
    Round.getInstance.check_state
  end

end
