require "sinatra"
require "sinatra/reloader"
require 'uri'
require 'net/http'
require "sinatra/cookies"

token = ENV.fetch("BEARER_TOKEN")


get("/") do
 
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

erb(:list)
end
