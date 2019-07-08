require 'sinatra'
require "sinatra/reloader" if development?
require 'digest/sha1'

OBJECTS_DIR_PATH = './objects'
MAIN_BRANCH_NAME = 'master'

def read_file(name)
  dir = File.join(OBJECTS_DIR_PATH, params['name'])
  raise 'dir not found' unless FileTest.exist?(dir)

  hash = Digest::SHA1.hexdigest(MAIN_BRANCH_NAME);
  path = File.join(OBJECTS_DIR_PATH, params['name'], hash)
  raise 'file not found' unless FileTest.exist?(path)

  File.open(path) do |f|
    return f.read
  end
end

get '/' do
  'Hello world!'
end

get '/:name' do
  read_file(params['name'])
end

get '/:name/add' do
  erb :add, locals: {name: 'hoge'}
end

post '/:name/post' do
  "#{params[:name]} #{params[:key]} #{params[:value]}"
end
