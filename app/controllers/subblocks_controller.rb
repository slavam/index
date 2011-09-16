# coding: utf-8
class SubblocksController < ApplicationController
  before_filter :find_block, :only => [:new, :create]
  
  def new
    @subblock = Subblock.new
  end
  
  def create
    @subblock = @block.subblocks.build(params[:subblock])
    if not @subblock.save
      render :new
    else
      redirect_to :controller => 'directions', :action => 'show_eigen_subblocks', :block_id => params[:block_id]
    end
  end
  
private
  def find_block
    @block = Block.find params[:block_id]
  end
end