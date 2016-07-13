#!/usr/bin/env ruby

require 'net/http'
require 'json'

url = URI.parse('http://jsonplaceholder.typicode.com/users')
request = Net::HTTP::Get.new(url.to_s)
response = Net::HTTP.start(url.host, url.port) do |http|
  http.request(request)
end

users = JSON.parse(response.body)
users.each do |user|
  puts "%s <%s>" % [user["name"], user["email"]]
end
