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
    File.delete(@paths[:inprocess_file])
    puts " -> Done."
    
  end
end

