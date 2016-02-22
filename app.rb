require 'rubygems'
require 'sinatra/base'
require 'nokogiri'
require 'sinatra/partial'
require 'sinatra/json'
require 'coderay'
require 'uri'
require 'erubis'
require 'tilt/erubis'
require 'fileutils'
require 'resque'
require 'yaml'
require 'fog'
require_relative 'lib/xsd_explorer'
require_relative 'lib/worker'
require_relative 'lib/helpers'

class XsdExplorer < Sinatra::Base
  register Sinatra::Partial
  
  set :partial_template_engine, :erb
  enable :partial_underscores

  # Home Page and main index.
  get '/' do
    @paths = load_paths(["/"], false)
    @files = list_files("#{@paths[:schema_root]}/NADM/*")
    erb(:index)
  end

  # Load up a schema specified by the URL path.
  get '/schema/*' do
    @info = Resque.info
    @paths = load_paths(params['splat'])
    @status = processing_status(@paths)
    @file = params[:refresh] ? nil : cached_file_header(@paths)
    @load_direct = params[:direct]
    Resque.redis.hdel('location', @paths[:s3_key]) if params[:refresh]
    Resque.enqueue(Worker, params['splat']) unless @file
    erb(:loading)
  end
  
  # Generate and cache the schema output.
  post '/schema/*' do
    @loaded ||= []
    @paths = load_paths(params['splat'])
    Worker.update_progress @paths[:s3_key], 0
    @doc = load_xml(@paths[:schema_file])
    Worker.update_ceiling @paths[:s3_key], @doc.xpath('.//*[not(*)]').size
    @includes = includes
    erb(:schema, layout: false)
  end
  
  # Get a json representation of the current processing status
  get '/status/*' do
    @paths = load_paths(params['splat'])
    json processing_status(@paths)
  end
  
  # Helpers for sinatra
  helpers Helpers
  
  # start the server if ruby file executed directly
  run! if app_file == $0
end



