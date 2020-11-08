module KMP3D
  require "#{DIR}/lib/kmp3d/math"
  require "#{DIR}/lib/kmp3d/ui/camera_preview"
  require "#{DIR}/lib/kmp3d/ui/html_helpers"
  require "#{DIR}/lib/kmp3d/ui/callbacks"
  require "#{DIR}/lib/kmp3d/ui/observer"
  require "#{DIR}/lib/kmp3d/ui/tool"
  require "#{DIR}/lib/kmp3d/ui/table"
  require "#{DIR}/lib/kmp3d/types/type"
  require "#{DIR}/lib/kmp3d/types/point"
  require "#{DIR}/lib/kmp3d/types/vector"
  require "#{DIR}/lib/kmp3d/types/checkpoint"
  require "#{DIR}/lib/kmp3d/types/object"
  require "#{DIR}/lib/kmp3d/types/area"
  require "#{DIR}/lib/kmp3d/types/camera"
  require "#{DIR}/lib/kmp3d/types/stage_info"
  require "#{DIR}/lib/kmp3d/types/hybrid"
  require "#{DIR}/lib/kmp3d/util/binary_parser"
  require "#{DIR}/lib/kmp3d/util/binary_writer"
  require "#{DIR}/lib/kmp3d/util/kcl_importer"
  require "#{DIR}/lib/kmp3d/util/kmp_importer"
  require "#{DIR}/lib/kmp3d/util/kmp_exporter"
  require "#{DIR}/lib/kmp3d/objects"
  require "#{DIR}/lib/kmp3d/entity"
  require "#{DIR}/lib/kmp3d/data"

  tool = Tool.new
  tool_cmd = UI::Command.new("KMP3D Tool") { Data.model.select_tool(tool) }
  tool_cmd.small_icon = tool_cmd.large_icon = "#{DIR}/app/images/tool.png"

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
