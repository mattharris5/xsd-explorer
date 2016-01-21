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
  include_path = File.dirname(schema_file)
  include_file = nil
  
  @doc = load_xml(schema_file)
  @includes = includes
  erb :schema
end

def load_xml(file_path)
  if (loaded.include?(file_path))
    puts " -> Skipping #{file_path}"
    return nil
  end
  puts " -> Loading #{file_path}"
  xml = Nokogiri::XML(File.open(file_path)) do |config|
    config.noblanks.noent.xinclude.nsclean
  end
  xml.search("//xs:include").each do |node|
    include_file = File.expand_path(File.join(File.dirname(file_path), node['schemaLocation']))
    include_xml = load_xml(include_file)
    includes.root << include_xml.root.children if include_xml
  end
  loaded << file_path
  return xml
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
  
  def loaded
    @loaded ||= []
  end

  def includes
    default_file = File.join(settings.root, "views", "default.xsd")
    @includes ||= Nokogiri.XML(File.open(default_file))
  end
end