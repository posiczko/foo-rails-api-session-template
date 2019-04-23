class PagesController < ApplicationController
  def index
    respond_to do |format|
      format.html { render body: nil }
      format.json { render json: {} }
    end
  end
end
