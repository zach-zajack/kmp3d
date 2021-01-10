require "sketchup"
require "extensions"
require "open-uri"
require "tempfile"
require "json"

module KMP3D
  module_function

  DIR = File.join(File.dirname(__FILE__), "kmp3d")
  URL = "https://api.github.com/repositories/198107090/releases/latest"
  VERSION = "v7.0"

  def check_updates
    json = JSON.parse(open(URL).read)
    new_ver = json["tag_name"]
    return if new_ver == VERSION

    msg = "A new version of KMP3D (#{new_ver}) was found. " \
          "Would you like to update?"
    return if UI.messagebox(msg, MB_YESNO) == IDNO

    rbz = open(json["assets"][0]["browser_download_url"]).read
	  path = "#{DIR}/kmp3d.rbz"
    File.open(path, "wb") { |f| f.write(rbz) }
    begin
      Sketchup.install_from_archive(path, false)
    rescue Interrupt
    rescue Exception => error
      UI.messagebox("Error during unzip: " + error.to_s)
    end
  end

  unless file_loaded?(__FILE__)
    check_updates
    kmp3d = SketchupExtension.new("KMP3D", "#{DIR}/kmp3d")
    kmp3d.version = VERSION
    kmp3d.description = "A 3D interface for KMP files."
    Sketchup.register_extension(kmp3d, true)
    file_loaded(__FILE__)
  end
end
