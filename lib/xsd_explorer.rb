@loaded ||= []

# Returns a hash with the appropriate file paths for the provided splat.
def load_paths(splat)
  paths = {}
  paths[:root] = File.expand_path(File.join([File.dirname(__FILE__), ".."]))
  paths[:schema_root] = File.join([paths[:root], "public", "schemas"])
  paths[:schema_file] = File.join([paths[:schema_root], splat])
  paths[:include_path] = File.dirname(paths[:schema_file])
  paths[:cache_file] = File.join([paths[:root], "cache", splat])
  paths[:s3_root] = s3.directories.get(ENV['S3_BUCKET_NAME'])
  paths[:s3_key] = "cache/" + (ENV['RACK_ENV'] || 'develoment') + "/" + splat.join("/")
  
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

# Returns the Nokogiri::XML object that stores the +xs:include+ files that are encountered
# in the main file. When associated references are found later in the document, the script
# can insert the referenced element by pulling it from this object.
def includes
  default_file = File.join(File.dirname(__FILE__), "..", "views", "default.xsd")
  @includes ||= Nokogiri.XML(File.open(default_file))
end

# Returns a connection to AWS S3 for cache storage.
def s3
  @conn ||= Fog::Storage.new({
    :provider => 'AWS',
    :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
    :region => ENV['AWS_REGION']
  })
end

# Save the cached file to S3
def save_cached_file(paths)
  cache_file_token = paths[:s3_root].files.create(
    :key    => paths[:s3_key],
    :body   => File.open(paths[:cache_file]),
    :public => true
  )
  puts " -> Persisted cache file to S3: #{cache_file_token.public_url}"
end

# Returns the cached file header - which is really a Fog::Storage::AWS::File.
def cached_file_header(paths)
  f = paths[:s3_root].files.head(paths[:s3_key])
end

# Returns the current value of the processing queue for the requested file.
def processing_status(paths)
  status = {
    current: Resque.redis.hget('processing', paths[:s3_key]).to_f,
    max:     Resque.redis.hget('ceiling', paths[:s3_key]).to_f,
    complete: false
  }
  status[:progress] = status[:current] / status[:max]
  if status[:progress].nan? || status[:progress] == Float::INFINITY
    status[:progress] = nil
  else
    status[:progress] = (status[:progress] * 100).floor
    status[:complete] = true if status[:progress] > 99
  end
  return status
end