module KMP3D
  require "#{DIR}/math"
  require "#{DIR}/ui/camera_preview"
  require "#{DIR}/ui/html_helpers"
  require "#{DIR}/ui/callbacks"
  require "#{DIR}/ui/observer"
  require "#{DIR}/ui/tool"
  require "#{DIR}/ui/type_html"
  require "#{DIR}/types/type"
  require "#{DIR}/types/point"
  require "#{DIR}/types/vector"
  require "#{DIR}/types/checkpoint"
  require "#{DIR}/types/object"
  require "#{DIR}/types/area"
  require "#{DIR}/types/camera"
  require "#{DIR}/types/stage_info"
  require "#{DIR}/types/hybrid"
  require "#{DIR}/util/binary_parser"
  require "#{DIR}/util/binary_writer"
  require "#{DIR}/util/kcl_importer"
  require "#{DIR}/util/kmp_importer"
  require "#{DIR}/util/kmp_exporter"
  require "#{DIR}/objects"
  require "#{DIR}/entity"
  require "#{DIR}/data"

  tool = Tool.new
  tool_cmd = UI::Command.new("KMP3D Tool") { Data.model.select_tool(tool) }
  tool_cmd.small_icon = tool_cmd.large_icon = "#{DIR}/images/tool.png"

  kcl_importer_cmd = UI::Command.new("Import KCL...") { KCLImporter.import }
  kmp_exporter_cmd = UI::Command.new("Export KMP...") { KMPExporter.export }
  kmp_importer_cmd = UI::Command.new("Import KMP...") do
    Data.reload(tool)
    Data.load_kmp3d_model
    KMPImporter.import
    tool.refresh_html
  end

  Sketchup.add_observer(tool)
  Data.signal_reload

  menu = UI.menu.add_submenu("KMP3D")
  menu.add_item(tool_cmd)
  menu.add_item(kmp_exporter_cmd)
  menu.add_item(kmp_importer_cmd)
  menu.add_item(kcl_importer_cmd)

  toolbar = UI::Toolbar.new("KMP3D")
  toolbar.add_item(tool_cmd)
  toolbar.show
end
