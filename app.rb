require "sinatra"
require "sinatra/reloader"
require 'uri'
require 'net/http'
require "sinatra/cookies"

token = ENV.fetch("BEARER_TOKEN")

# Enable sessions and set a secret key for encryption
enable :sessions
# set :session_secret, 'your_session_secret_here'

get("/") do

  url = URI("https://api.themoviedb.org/3/trending/movie/week")
  
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(url)
  request["accept"] = 'application/json'
  request["Authorization"] = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzMTAyMTAwZTE0NjEwNWFkY2U5YjE0YWM4MDFkNTQwNyIsInN1YiI6IjYzNzJiZGQyYmYwZjYzMDBkYzhlMTEwYiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.2srIeTBaKovQSYKNh8NRtc7ATEGli38880nIb-_RK9U'
  
  response = http.request(request)
  parsed_response = JSON.parse(response.read_body)
  @trending = parsed_response
  
  erb(:home)
end

get("/movie") do
   movie = params.fetch("movie")

# Taken from TMDB Api Docs
url = URI("https://api.themoviedb.org/3/search/movie?query=#{movie}")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["accept"] = 'application/json'
request["Authorization"] = "Bearer #{token}"

response = http.request(request)
parsed_response = JSON.parse(response.read_body)


@res = parsed_response
@title = @res.dig("results" ,0, "original_title")
poster = @res.dig("results", 0, "poster_path")
@overview = @res.dig("results" ,0, "overview")
@release_date = @res.dig("results" ,0, "release_date")
@avg_rating = @res.dig("results" ,0, "vote_average")
@id = @res.dig("results", 0, "id")
@image_url = "https://image.tmdb.org/t/p/w300/#{poster}"

@image_url = "https://image.tmdb.org/t/p/w300/#{poster}"

  # Retrieve the current list of movies from the session, or initialize it to an empty array
  movies = session[:movies] || []

  # Add the movie title to the list
  movies << @title

  # Store the updated list of movie titles in the session cookie
  session[:movies] = movies

erb(:list)
end

get("/trending_movie/:title") do
    movie = params.fetch(:title)
 
 # Taken from TMDB Api Docs
 url = URI("https://api.themoviedb.org/3/search/movie?query=#{movie}")
 
 http = Net::HTTP.new(url.host, url.port)
 http.use_ssl = true
 
 request = Net::HTTP::Get.new(url)
 request["accept"] = 'application/json'
 request["Authorization"] = "Bearer #{token}"
 
 response = http.request(request)
 parsed_response = JSON.parse(response.read_body)
 
 
 @res = parsed_response
 @title = @res.dig("results" ,0, "original_title")
 poster = @res.dig("results", 0, "poster_path")
 @overview = @res.dig("results" ,0, "overview")
 @release_date = @res.dig("results" ,0, "release_date")
 @avg_rating = @res.dig("results" ,0, "vote_average")
 @id = @res.dig("results", 0, "id")
 @image_url = "https://image.tmdb.org/t/p/w300/#{poster}"
 
 @image_url = "https://image.tmdb.org/t/p/w300/#{poster}"

  # Retrieve the current list of movies from the session, or initialize it to an empty array
  movies = session[:movies] || []

  # Add the movie title to the list
  movies << @title

  # Store the updated list of movie titles in the session cookie
  session[:movies] = movies
 
  erb(:list)
end


# Route to display the watchlist view
get '/watchlist' do
  # Retrieve the list of movie titles from the session cookie
  @watchlist = session[:movies] || []

  # Render the watchlist view
  erb :watchlist
end

# Route to handle the form submission for adding a movie to the watchlist
post '/add_to_watchlist' do
  puts params.inspect
  begin
    movie_title = params[:title]

    # Retrieve the current list of movies from the session, or initialize it to an empty array
    movies = session[:movies] || []

    # Check if the movie title is not already in the watchlist
    unless movies.include?(movie_title)
      # Add the movie title to the list
      movies << movie_title
    end

    # Store the updated list of movie titles in the session cookie
    session[:movies] = movies

    # Render the list view again with the updated watchlist
  erb :added
  rescue => e
    status 500
    "Error: #{e.message}"
  end
end
