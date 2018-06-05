class BlocksController < ApplicationController

  def index
    @blocks = blocks_collection.all
  end

  def new
    @block = blocks_collection.new
    render :action => 'new', :layout => !request.xhr?
  end

  def create
    @block = blocks_collection.new(block_params)

    raise StandardError unless @block.valid?

    @block.save ? flash[:notice] = l('notice_successful_create') : flash.now[:error] = l('html_block.activerecord.errors.create')
    redirect_to :action => 'index'
  rescue StandardError
    flash.now[:error] = l('html_block.activerecord.errors.create')
    render :action => 'new', :layout => !request.xhr?
  end

  def edit
    @block = blocks_collection.find_by(params[:id])
  end

  def update
    @block = blocks_collection.find_by(params[:id])

    @block.update(block_params) ? flash[:notice] = l('notice_successful_update') : flash.now[:error] = l('html_block.activerecord.errors.update')

    raise StandardError unless @block.valid?

    redirect_to :action => 'index'
  rescue StandardError
    render :action => 'new', :layout => !request.xhr?
  end

  def destroy
    @block = blocks_collection.find_by(params[:id])
    @block.destroy!

    flash[:notice] = l('notice_successful_delete')

    redirect_to :action => 'index'
  end

  private

  def block_params
    params.require(:block).permit(:text, :address, :link_type)
  end

  def blocks_collection
    Block
  end
end
