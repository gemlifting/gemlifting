class GemCategoriesController < ApplicationController

  # GET /categories
  def index

  end

  # GET /categories/:id
  def show
    category!
    gem_chart

    @page_title = category!.name
    @page_description = category!.description
  end

  private

  def category!
    @category ||= GemCategory.eager_load(:subcategories, :gem_objects).friendly.find(params[:id])
    @gem_objects = @category.gem_objects.page(params[:page])

    @category
  end

  def gem_chart
    @gem_chart ||= category!.top_downloaded_gems
  end
end
