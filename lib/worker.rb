require 'resque'
Resque.redis = ENV['REDIS_URL']
Resque.logger.formatter = Resque::VeryVerboseFormatter.new
Resque.logger.level = Logger::DEBUG

class Worker
  @queue = :default

  def self.perform(params)
    puts "Generating output for #{params.inspect}"
    @paths = load_paths(params)
    request = Rack::MockRequest.new(XsdExplorer)
    output = request.post("/schema/" + params.join("/")).body
    puts " -> Outputting cache to #{@paths[:cache_file]} (size: #{output.length})"
    File.write(@paths[:cache_file], output)
    save_cached_file(@paths)
    puts " -> Done."
  end
  
  def self.update_progress(key, node_or_val)
    return Resque.redis.hset('processing', key, node_or_val) if node_or_val.is_a?(Integer)
    return Resque.redis.hincrby('processing', key, 1) if node_or_val.ancestors.size <= 2
  end
  
  def self.update_ceiling(key, ceiling)
    Resque.redis.hset('ceiling', key, ceiling)
  end
end

