require "sketchup"
require "extensions"

module KMP3D
  DIR = File.join(File.dirname(__FILE__), "kmp3d")

  unless file_loaded?(__FILE__)
    kmp3d = SketchupExtension.new("KMP3D", "#{DIR}/kmp3d")
    kmp3d.version = "7.0"
    kmp3d.description = "A 3D interface for KMP files."
    Sketchup.register_extension(kmp3d, true)
    file_loaded(__FILE__)
  end
end
