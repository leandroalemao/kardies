class PlacesController < ApplicationController

  def create
    @place = current_user.places.new(place_params)

    if @place.save
      flash[:notice] = "Place has been saved"
      redirect_to root_path
    else
      @users = User.all
      render 'home/index'
    end

  end

  private

  def place_params
    params.require(:place).permit(:country, :city, :visit_date)
  end
end
