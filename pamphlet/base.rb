module Pamphlet
  
  SETTINGS_FILE = "settings.yml"
    
  # All parts of Pamphlet share a single settings instance
  def self.settings
    @settings = Pamphlet::Settings.load(SETTINGS_FILE)
  end
  
  class Base
    def call(env)
      [200, {'Content-Type' => 'text/html'}, "Damn this pamphlet is interesting."]
    end
  end
  
end