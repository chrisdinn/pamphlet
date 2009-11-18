module Pamphlet
  
  SETTINGS_FILE = "settings.yml"
  
  # All parts of Pamphlet share a single settings file
  def self.settings
    @settings = YAML.load(File.read(SETTINGS_FILE)).to_hash
  end
  
  class Base
    def call(env)
      [200, {'Content-Type' => 'text/html'}, "Damn this pamphlet is interesting."]
    end
  end
  
end