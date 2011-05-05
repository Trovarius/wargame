class FacilityFleetsController < ApplicationController

  def index
  end

  def edit
    @facility = FacilityFleet.find(params[:id])
    @units = Unit.allowed_for(current_squad.faction) #nao sei pq diabos ele nao mostra nada quando é da classe Unit!!!
  end

  def update
    @facility = FacilityFleet.find(params[:id])
    @producing_unit = Unit.find(params[:facility_fleet][:producing_unit])
    current_squad.change_producing_unit @facility, @producing_unit
    redirect_to :fleets
  end

end

