require "sinatra"
require "sinatra/reloader"
require "http"
require 'uri'
require 'net/http'
require "sinatra/cookies"

token = ENV.fetch("BEARER_TOKEN")


get("/") do
 
  erb(:home)
end

get("/movielist") do
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

erb(:list)
end

post("/add_to_watchlist/:id/:title") do
  title = params[:title]
  watchlist = request.cookies['watchlist']

  if watchlist.nil?
    # If the cookie doesn't exist, create a new array with the movie title
    watchlist = [title]
  else
    # If the cookie exists, parse the JSON and add the movie title to the array
    watchlist = JSON.parse(watchlist)
    watchlist.push(title)
  end

  # Save the updated watchlist back to the cookie
  response.set_cookie('watchlist', value: watchlist.to_json, expires: Time.now + 3600)

  # Redirect the user to the home page or wherever appropriate
  # redirect("/my_watchlist")
   erb(:watchlist)
end

get("/my_watchlist") do
  watchlist = request.cookies['watchlist']

  # Check if the 'watchlist' cookie exists and parse it as a JSON array
  if watchlist.nil?
    @movies = []
  else
    @movies = JSON.parse(watchlist)
  end

  erb(:my_watchlist)
end
