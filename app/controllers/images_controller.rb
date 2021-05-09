require 'base64'
require 'json'
require 'net/https'

class ImagesController < ApplicationController
  before_action :set_image, only: %i[ show edit update destroy ]

  # GET /images or /images.json
  def index
    @images = Image.all()
  end

  # GET /images/1 or /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new()
  end

  # GET /images/1/edit
  def edit
  end

  # GET /images/imageSearch
  def image_search
    @image = Image.new()
  end

  # search image repository using tags
  def tag_search
    if params[:search].blank? 
      @images = Image.all()
      render 'images/index'
    else
      @images = Image.all()
      tag_array = Array.new
      tags = params[:search]

      tag_array = tags.delete_suffix(',').split(',')
      @search_results = helpers.find_images(tag_array)
      
      render 'images/searchResults'
    end
  end

  # search image repository using an image file
  def find_images
    if params.has_key?(:image) 
      @images = Image.all()
      @image = Image.new()
      @image.tags = ""
      helpers.fetch_tags(find_images_params)

      tag_array = Array.new()
      tags = @image.tags
      tag_array = tags.delete_suffix(',').split(',')
      @search_results = helpers.find_images(tag_array)
    
      render 'images/searchResults'
    else
      @images = Image.all()
      render 'images/index'
    end

    
  end

  # POST /images or /images.json
  def create
    @image = Image.new(image_params)

    debugger

    # fetch tags from google vision API
    helpers.fetch_tags(image_params)

    @image.image_file.attach(image_params[:image_file])

    respond_to do |format|
      if @image.save()
        format.html { redirect_to @image, notice: "Image was successfully created." }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1 or /images/1.json
  def update

    params = image_params
    params["tags"] = params["tags"].delete_suffix(',')

    respond_to do |format|
      if @image.update(params)
        format.html { redirect_to @image, notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1 or /images/1.json
  def destroy
    @image.destroy()
    respond_to do |format|
      format.html { redirect_to images_url, notice: "Image was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def image_params
      params.require(:image).permit(:name, :tags, :image_file)
    end

    def tag_search_params
      params.require(:search)
    end

    def find_images_params
      params.require(:image).permit(:tags, :image_file)
    end
    
end
