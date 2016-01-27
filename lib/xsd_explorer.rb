@loaded ||= []

# Returns a hash with the appropriate file paths for the provided splat.
def load_paths(splat)
  paths = {}
  paths[:root] = File.expand_path(File.join([File.dirname(__FILE__), ".."]))
  paths[:schema_root] = File.join([paths[:root], "public", "schemas"])
  paths[:schema_file] = File.join([paths[:schema_root], splat])
  paths[:include_path] = File.dirname(paths[:schema_file])
  paths[:cache_file] = File.join([paths[:root], "cache", splat])
  paths[:inprocess_file] = paths[:cache_file] + ".inprocess"
  dirname = File.dirname(paths[:cache_file])
  unless File.directory?(dirname)
    FileUtils.mkdir_p(dirname)
  end
  return paths
end

# Load the XML file available at the path specified and return a Nokogiri::XML object.
# If the file defines any includes (+<xs:include>+ elements), this method recursively
# appends these includes into the special global @includes file for later inclusion in
# the view files.
def load_xml(file_path)
  include_file = nil
  if (@loaded.include?(file_path))
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
  @loaded << file_path
  return xml
end

def includes
  default_file = File.join(File.dirname(__FILE__), "..", "views", "default.xsd")
  @includes ||= Nokogiri.XML(File.open(default_file))
end
