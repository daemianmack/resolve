class CategoriesController < ApplicationController

  def index
    @categories = Category.find(:all) #TODO probably want to limit category visibility through permissions
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  def show
    @category = Category.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @items }
    end
  end
end
