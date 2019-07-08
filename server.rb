require 'sinatra'
require "sinatra/reloader" if development?

OBJECTS_DIR_PATH = './objects'

get '/' do
  'Hello world!'
end

get '/:name' do
  path = File.join(OBJECTS_DIR_PATH, params['name'])
  raise 'file not found' unless FileTest.exist?(path)

  File.open(path) do |f|
    return f.read
  end
end
