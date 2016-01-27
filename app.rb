require 'rubygems'
require 'sinatra/base'
require 'nokogiri'
require 'sinatra/partial'
require 'coderay'
require 'uri'
require 'erubis'
require 'tilt/erubis'
require 'fileutils'
require 'resque'
require 'yaml'
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
  
    if (File.exist?(@paths[:cache_file]) && !params[:refresh])
      puts " -> Returning from cache: #{@paths[:cache_file]}"
      return [200, File.read(@paths[:cache_file])]
    elsif (File.exist?(@paths[:inprocess_file]) && !params[:refresh])
      return [200, erb(:loading)]
    else
      Resque.enqueue(Worker, params['splat'])
      return [200, erb(:loading)]
    end
  end
  
  # Generate and cache the schema output.
  post '/schema/*' do
    @loaded ||= []
    @paths = load_paths(params['splat'])
    FileUtils.touch(@paths[:inprocess_file])
    @doc = load_xml(@paths[:schema_file])
    @includes = includes
    erb(:schema)
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



