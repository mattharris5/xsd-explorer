require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'sinatra/partial'
require 'coderay'
require 'uri'

set :partial_template_engine, :erb
enable :partial_underscores

get '/' do
  erb "<a href='schema'>xSre</a>"
end

get '/schema' do
  @doc = Nokogiri::XML(File.open("./public/schemas/NADM/3.3/Report/SIFNAxSRE.xsd")) do |config|
    config.noblanks.noent.xinclude.nsclean
  end
  @includes = Nokogiri.XML("<?xml version=\"1.0\"?><xs:schema xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" elementFormDefault=\"qualified\"></xs:schema>")
  @doc.search("//xs:include").each do |node|
    xml = Nokogiri::XML(File.open("./public/schemas/NADM/3.3/Report/#{node['schemaLocation']}")) do |config|
      config.noblanks.noent.xinclude.nsclean
    end
    @includes.root << xml.root.children
  end
  erb :schema
end
