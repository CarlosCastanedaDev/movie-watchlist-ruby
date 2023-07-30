require "sinatra"
require "sinatra/reloader"
require "http"
require 'uri'
require 'net/http'


token = ENV.fetch("bearer_token")


get("/") do
 
  erb(:home)
end

get("/movielist") do
   movie = params.fetch("movie")
#   url = "https://api.themoviedb.org/3/search/movie?api_key=#{key}&language=en-US&page=1&include_adult=false&query=#{movie}"

# response = HTTP.get(url)

# @parsed_response = JSON.parse(response)



url = URI("https://api.themoviedb.org/3/search/movie?query=#{movie}")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["accept"] = 'application/json'
request["Authorization"] = "Bearer #{bearer_token}"

response = http.request(request)
parsed_response = JSON.parse(response.read_body)
@res = parsed_response
@info = @res.dig("results" ,0, "original_title")
poster = @res.dig("results", 0, "poster_path")

@image_url = "https://image.tmdb.org/t/p/w500/#{poster}"
erb(:list)
end
