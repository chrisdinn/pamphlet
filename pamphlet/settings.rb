module Pamphlet
  #
  # Settings
  # 
  # Make settings available as a convenient hash-like object
  # 
  class Settings < Hash
    
    def initialize(settings_file)
      super
      @settings_file = settings_file
      reload!
    end
    
    def self.load(settings_file)
      new(settings_file)
    end
    
    def reload!
      replace(load_from_file)
    end
    
    def clear
      super
      write_to_file
    end
    
    def []=(setting, value)
      self.store(setting, value)
      write_to_file
    end
    
    private
    
    def load_from_file
      File.exist?(@settings_file) ? YAML.load(File.read(@settings_file)).to_hash : {}
    end
    
    def write_to_file
      File.open(@settings_file, 'w') {|f| f.write(self.to_yaml) }
    end
          
  end
  
end