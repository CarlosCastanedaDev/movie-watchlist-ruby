require "sinatra"
require "sinatra/reloader"
require 'uri'
require 'net/http'
require "sinatra/cookies"

token = ENV.fetch("BEARER_TOKEN")

enable :sessions

# Homepage route
get("/") do 
  erb(:home)
end

# Route to display searched movie
get("/movie") do
   movie = params.fetch("movie").capitalize

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

erb(:list)
end

get("/pick_a_movie") do
  movie = params.fetch("movie").capitalize
  # Taken from TMDB Api Docs
url = URI("https://api.themoviedb.org/3/search/movie?query=#{movie}")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["accept"] = 'application/json'
request["Authorization"] = "Bearer #{token}"

response = http.request(request)
parsed_response = JSON.parse(response.read_body)
@trending = parsed_response

@trending_movies = []
@trending_posters = []

@trending['results'].first(5).each do |movie|
  @trending_movies << movie.dig("original_title")
  @trending_posters << movie.dig( "poster_path")

  # @trending_date << movie.dig("release_date")
end
# @res = parsed_response
# @title = @res.dig("results" ,0, "original_title")
# poster = @res.dig("results", 0, "poster_path")
# @release_date = @res.dig("results" ,0, "release_date")
# @image_url = "https://image.tmdb.org/t/p/w100/#{poster}"
  erb(:listof5)
end

# Route to display top 5 trending movies, changes weekly
get("/trending") do
  url = URI("https://api.themoviedb.org/3/trending/movie/week")
  
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(url)
  request["accept"] = 'application/json'
  request["Authorization"] = "Bearer #{token}"
  
  response = http.request(request)
  parsed_response = JSON.parse(response.read_body)
  @trending = parsed_response

  @trending_movies = []
  @trending_posters = []
  @trending['results'].first(5).each do |movie|
    @trending_movies << movie.dig("original_title")
    @trending_posters << movie.dig( "poster_path")
  end

  erb(:trending)
end

# Route to display the watchlist view
get('/watchlist') do
  # Retrieve the list of movie titles from the session cookie
  @watchlist = session[:movies] || []

  erb(:watchlist)
end

# Route to handle the form submission for adding a movie to the watchlist
post('/add_to_watchlist') do
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

  erb(:added)
end
