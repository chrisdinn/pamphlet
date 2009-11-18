module Pamphlet
  
  SETTINGS_FILE = "settings.yml"
  
  # All parts of Pamphlet share a single settings file
  def self.settings
    @settings = YAML.load(File.read(SETTINGS_FILE)).to_hash
  end
  
end