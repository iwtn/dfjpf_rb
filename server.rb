require 'sinatra'
require "sinatra/reloader" if development?
require 'digest/sha1'
require 'json'
require './resource.rb'

get '/' do
  erb :top, locals: { resources: Resource.list, host: request.host }
end

get '/add' do
  erb :new_resource, locals: { type: Resource::OBJECT_NAME }
end

get '/add_list' do
  erb :new_resource, locals: { type: Resource::LIST_NAME }
end

post '/post' do
  empty_json = Resource::DEFAULT_RESOUCE_MAP[params[:type]]
  resource = Resource.new
  resource.new_resource(params[:name], empty_json)
  redirect "/", 303
end

get '/:name' do
  name = params['name']
  resource = Resource.new
  json_hash = JSON.parse(resource.read_file(name))
  erb :view, locals: { name: name, json: JSON.pretty_generate(json_hash) }
end

get '/:name/add' do
  name = params['name']
  erb :add, locals: { name: name }
end

post '/:name/post' do
  resource = Resource.new
  resource.add_file(params[:name], params[:key], params[:value])

  redirect "/#{params[:name]}", 303
end
