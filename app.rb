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

class XsdExplorer < Sinatra::Base
  register Sinatra::Partial
  
  set :partial_template_engine, :erb
  enable :partial_underscores

  # Home Page and main index.
  get '/' do
    erb "<a href='/schema/NADM/3.3/Report/SIFNAxSRE.xsd'>xSre</a>"
  end

  # Load up a schema specified by the URL path.
  get '/schema/*' do
    @info = Resque.info
    @paths = load_paths(params['splat'])
    @status = processing_status(@paths)
    @file = params[:refresh] ? nil : cached_file_header(@paths)
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
  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end  
  end
  
  # start the server if ruby file executed directly
  run! if app_file == $0
end



