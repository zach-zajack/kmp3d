require "sketchup.rb"
require "extensions.rb"

module KMP3D
  DIR = File.dirname(__FILE__) + "/KMP3D"

  unless file_loaded?(__FILE__)
    kmp3d = SketchupExtension.new("KMP3D", "#{DIR}/core")
    kmp3d.version = "1.2.0"
    kmp3d.description = "A 3D interface for KMP files."
    Sketchup.register_extension(kmp3d, true)
    file_loaded(__FILE__)
  end
end
