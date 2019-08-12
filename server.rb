require 'sinatra'
require "sinatra/reloader" if development?
require 'digest/sha1'
require 'json'

OBJECTS_DIR_PATH = 'objects'
REF_DIR_PATH = 'refs'
MAIN_BRANCH_NAME = 'HEAD'

def ref_path(name)
  File.join(OBJECTS_DIR_PATH, name, MAIN_BRANCH_NAME)
end

def master_path(name)
  hash = nil
  File.open(ref_path(name)) do |f|
    hash = f.read.chomp
  end
  File.join(OBJECTS_DIR_PATH, name, hash)
end

def resource_path(name, hash)
  File.join(OBJECTS_DIR_PATH, name, hash)
end

def dir(name)
  File.join(OBJECTS_DIR_PATH, name)
end

def exist_resource?(name)
  return false unless FileTest.exist?(dir(name))

  FileTest.exist?(master_path(name))
end

def read_file(name)
  raise 'resource not found' unless exist_resource?(name)

  File.open(master_path(name)) do |f|
    return f.read
  end
end

def add_file(name, key, val)
  raise 'resource not found' unless exist_resource?(name)

  json = nil
  File.open(master_path(name), 'r') do |f|
    json = JSON.parse(f.read)
  end
  json[key] = val

  hash = Digest::SHA1.hexdigest(json.to_json)
  path = resource_path(name, hash)
  File.open(path, 'w') do |f|
    f.write(json.to_json)
  end

  File.open(ref_path(name), 'w') do |f|
    f.write(hash)
  end
end

def resources
  Dir.glob("#{OBJECTS_DIR_PATH}/*").map { |r| File.basename(r) }
end

def new_resource(name)
  Dir.mkdir(dir(name), 0666)
end

get '/' do
  erb :top, locals: { resources: resources, host: request.host }
end

get '/add' do
  erb :new_resource
end

post '/post' do
  new_resource(params[:name])
  redirect "/", 303
end

get '/:name' do
  name = params['name']
  json_hash = JSON.parse(read_file(name))
  erb :view, locals: { name: name, json: JSON.pretty_generate(json_hash) }
end

get '/:name/add' do
  name = params['name']
  erb :add, locals: { name: name }
end

post '/:name/post' do
  add_file(params[:name], params[:key], params[:value])

  redirect "/#{params[:name]}", 303
end
