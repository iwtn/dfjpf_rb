require 'sinatra'
require "sinatra/reloader" if development?
require 'digest/sha1'
require 'json'

OBJECTS_DIR_PATH = 'objects'
REF_DIR_PATH = 'refs'
MAIN_BRANCH_NAME = 'master'

def ref_path(name)
  File.join(OBJECTS_DIR_PATH, name, REF_DIR_PATH, MAIN_BRANCH_NAME)
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

get '/' do
  'Hello world!'
end

get '/:name' do
  json_hash = JSON.parse(read_file(params['name']))
  erb :view, locals: { name: 'hoge', json: JSON.pretty_generate(json_hash) }
end

get '/:name/add' do
  erb :add, locals: {name: 'hoge'}
end

post '/:name/post' do
  add_file(params[:name], params[:key], params[:value])

  redirect "/#{params[:name]}", 303
end
