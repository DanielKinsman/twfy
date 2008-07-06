require 'yaml'

class Configuration
  # TODO: Could have conflicts between these and names in the configuration file
  attr_reader :database_host, :database_user, :database_password, :database_name, :file_image_path, :members_xml_path, :xml_path
  
  @@conf = nil
  
  def initialize
    if @@conf.nil?
      # Load the configuration
      @@conf = YAML::load( File.open( "#{File.dirname(__FILE__)}/../configuration.yml" ) )
      @@conf = {} if !@@conf
    end
    
    # Load the information from the mysociety configuration
    require "#{web_root}/rblib/config"
    MySociety::Config.set_file("#{web_root}/twfy/conf/general")
    @database_host = MySociety::Config.get('DB_HOST')
    @database_user = MySociety::Config.get('DB_USER')
    @database_password = MySociety::Config.get('DB_PASSWORD')
    @database_name = MySociety::Config.get('DB_NAME')
    @file_image_path = MySociety::Config.get('FILEIMAGEPATH')
    @members_xml_path = MySociety::Config.get('PWMEMBERS')
    @xml_path = MySociety::Config.get('RAWDATA')
  end
  
  # Ruby magic
  def method_missing(method_id)
    name = method_id.id2name
    if @@conf.has_key?(name)
      @@conf[name]
    else
      super
    end
  end
end
