# coding: utf-8
class DivisionsController < ApplicationController
  def index
    @divisions = Division.order(:id)
  end

  def show_workers
    @workers = Worker.where('', params[:division_code])
  end
end