require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'sinatra/partial'
require 'coderay'
require 'uri'

set :partial_template_engine, :erb
enable :partial_underscores

get '/' do
  erb "<a href='/schema/NADM/3.3/Report/SIFNAxSRE.xsd'>xSre</a>"
end

get '/schema/*' do
  schema_root = settings.root, "public", "schemas"
  schema_file = File.join(schema_root, params['splat'])
  default_file = File.join(settings.root, "views", "default.xsd")
  include_path = File.dirname(schema_file)
  
  @doc = Nokogiri::XML(File.open(schema_file)) do |config|
    config.noblanks.noent.xinclude.nsclean
  end
  @includes = Nokogiri.XML(File.open(default_file))
  @doc.search("//xs:include").each do |node|
    include_file = File.join(File.expand_path(File.join(include_path, node['schemaLocation'])))
    xml = Nokogiri::XML(File.open(include_file)) do |config|
      config.noblanks.noent.xinclude.nsclean
    end
    @includes.root << xml.root.children
  end
  erb :schema
end
