class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def get_selected_movies(params)
    if params[:ratings]
      @selected_ratings = params[:ratings].keys
      @movies = Movie.where(:rating => @selected_ratings)
      @movies
    else
      @all_selected = true
      @movies = Movie.all
    end
  end
  
  def index
    @selected_ratings = []
    @all_selected = false
    @all_ratings = Movie.get_ratings
    if params.has_key?(:sort)
      @movies = get_selected_movies(params).order(params[:sort])
      if params[:sort] == "title"
        @title_header = "hilite"
      elsif params[:sort] == "release_date"
        @release_date_header = "hilite"
      end
    else
      @movies = get_selected_movies(params)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
