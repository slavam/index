# coding: utf-8
class DivisionsController < ApplicationController
  before_filter :find_division, :only => 'show_workers'
  def index
    @divisions = Division.order(:id)
  end

  def show_workers
    @workers = Worker.select([:lastname, :firstname, :soname, :staffname]).where('code_division like ?', params[:division_code]+'%')
  end
  private
  def find_division
    @division = Division.select([:name]).where('code = ?',params[:division_code]).first
  end
end