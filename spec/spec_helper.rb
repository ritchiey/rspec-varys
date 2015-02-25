
Dir.glob(::File.expand_path('../support/*.rb', __FILE__)).each { |f| require_relative f }
Dir.glob(::File.expand_path('../../lib/*.rb', __FILE__)).each { |f| require_relative f }

