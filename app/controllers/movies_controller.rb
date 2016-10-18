class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_selected = false
    @all_ratings = Movie.get_ratings
    redirect_required = true
    
    # Clear all settings for filtering and sorting. Nuke the session.
    if (params[:clear_settings])
      session.clear
    end
    
    # If session[] is empty, then we can assign session[:ratings] = @all_ratings.
    # If there is no ratings specified in params then we have to display movies
    # with all possible ratings.
    if !session[:sort] && !session[:ratings]
      session[:ratings] = @all_ratings
    end
    
    #If we have a new parameter to sort by update session[:sort].
    if params[:sort]
      session[:sort] = params[:sort]
      redirect_required = false
    end
    
    #If we have a new parameter to display movies by ratings, update
    # session[:ratings]. Previously stored ratings may be an array
    # instead of a hash. So handle both the cases.
    if params[:ratings]
      if params[:ratings].is_a?(Hash)
        @selected_ratings = params[:ratings].keys
      else
        @selected_ratings = params[:ratings]
      end
      session[:ratings] = @selected_ratings
      redirect_required = false
    end
    
    # Redirect required is turned to false only when the parameters are passed
    # explicity in the URI through params[]. If parameters are not passed
    # through params, we call redirect_to by passing the same parameters
    # through URI.
    if redirect_required
      flash.keep
      redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    end
    
    # Filter by ratings and sort by a parameter.
    if session[:sort] && session[:ratings]
      @movies = Movie.where(:rating => session[:ratings]).order(session[:sort])
      if session[:sort] == "title"
        @title_header = "hilite"
      elsif session[:sort] == "release_date"
        @release_date_header = "hilite"
      end
    # Only sort by a parameter.
    elsif session[:sort]
      @movies = Movie.all.order(session[:sort])
      if session[:sort] == "title"
        @title_header = "hilite"
      elsif session[:sort] == "release_date"
        @release_date_header = "hilite"
      end
    # Only filter by ratings.
    elsif session[:ratings]
      @movies = Movie.where(:rating => @selected_ratings)
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
