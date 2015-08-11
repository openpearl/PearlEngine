class PearlPluginGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  # Creates an empty json file. Place the storyboard json for the plugin in this file.
  def generate_storyboard
    create_file "lib/pearl_engine/json_files/#{file_name}.json"
  end

  # Creates a plugin.rb file and populates it with the common method stubs.
  def generate_plugin
    template "pearl_plugin_model.rb", "app/models/pearl_engine/plugins/#{file_name}_plugin.rb"
  end

end
