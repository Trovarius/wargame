require 'spec_helper'

describe Squad do
  let(:squad) {Factory :squad}
  it {should have_many :planets}
  it {should have_and_belong_to_many :units }
  it {should have_many :fleets}
  context 'buying and selling units' do
    let(:unit) {Factory :unit}
    before(:each) do
      squad.units << unit
    end
    context 'buying ships' do
      it 'should be able to buy units and remove credits accordingly' do
        squad.credits = 2000
        squad.units.first.price = 1000
        squad.buy squad.units.first, 2
        squad.credits.should be_zero
      end

      it 'should not be able to buy a unit they dont have access to' do
        squad.units.clear
        squad.buy(unit, 1).should be_false
      end

      it 'should be able to buy a unit they have access to' do
        squad.buy(unit, 1).should be_true
      end

      it 'should add the unit to the list of Fleets' do
        squad.buy unit, 1
        squad.fleets.should_not be_empty
      end

      it 'should be able to accumulate same ship models' do
        squad.buy unit, 1
        squad.buy unit, 1
        squad.fleets.count.should be 1
      end

      it 'should be able buy units and send them specifically to pool' do
        squad.buy unit, 1
        first = squad.fleets.first
        first.planet = Factory :planet
        first.save
        squad.buy unit, 1
        squad.fleets.count.should be 2
      end
    end

    context 'selling units' do
      before(:each) do
        squad.units.first.price = 1000
        squad.units.first.save!
        squad.buy squad.units.first, 2
        squad.credits = 0
      end

      it 'should restore half credits when selling a unit' do
        squad.sell squad.units.first, 2
        squad.credits.should be 1000
      end

      it 'should remove the adequate quantity' do
        squad.sell squad.units.first, 1
        squad.fleets.should_not be_empty
      end
    end
    context 'aggregating profits' do
      let(:planet) {Factory :planet}
      before(:each) do
        planet.save
        planet.credits = 1000
        squad.planets << planet
        squad.credits = 0
        squad.save
      end

      it 'should generate profits only when you have a ship on it' do
        squad.generate_profits!
        squad.credits.should == 0
      end
    end
    context 'moving through phases' do
      it 'should be able to go through the move phase' do
        squad.end_move_round
        squad.move?.should be_true
      end
    end

  end

end

