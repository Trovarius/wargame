require 'spec_helper'

describe Fleet do
  it {should belong_to :squad}
  it {should belong_to :planet}
  it {should belong_to :unit}
  it {should belong_to :destination}

  let(:unit) {Factory :fleet}

  context 'moving and attacking' do
    let(:planet) {Factory :planet}
    it 'should be flagged as a moving unit when moving' do
      unit.move 1, planet
      unit.should be_moving
    end

    it 'should have a destination planet when moving' do
      unit.move 1, planet
      unit.destination.should == planet
    end
  end

  context 'capturing units' do
    let(:squad) {Factory :squad}
    before(:each) do
      unit.quantity = 1
    end

    it 'should remove units from the current fleet' do
      unit.captured! 1, squad
      unit.quantity.should be 0
    end

    it 'should remove fleet if quantity equals zero' do
      unit.captured! 1, squad
      unit.should be_new_record
    end

    it 'should transfer fleet to another squad' do
      unit.captured! 1, squad
      squad.fleets.count.should be 1
    end

    context 'related to captured fleet' do
      before(:each) do
        unit.captured! 1, squad
      end
      let(:captured_unit) {squad.fleets.first}
  
      it 'should have the captured quantity' do
        captured_unit.quantity.should be 1
      end 
    end
   

  end


end

