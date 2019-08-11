module KMP3D
  require "#{DIR}/ui/html_helpers"
  require "#{DIR}/ui/callbacks"
  require "#{DIR}/ui/observer"
  require "#{DIR}/ui/tool"
  require "#{DIR}/ui/type_html"
  require "#{DIR}/types/type"
  require "#{DIR}/types/point"
  require "#{DIR}/types/vector"
  require "#{DIR}/types/object"
  require "#{DIR}/types/checkpoint"
  require "#{DIR}/types/stage_info"
  require "#{DIR}/types/type_classes"
  require "#{DIR}/util/wkmpt_exporter"
  require "#{DIR}/entity"
  require "#{DIR}/data"

  tool = Tool.new
  tool_cmd = UI::Command.new("KMP3D Tool") { Data.model.select_tool(tool) }
  tool_cmd.small_icon = tool_cmd.large_icon = "#{DIR}/images/tool.png"

  exporter_cmd = UI::Command.new("Export WKMPT...") \
    { Data.model.select_tool(WKMPTExporter.export) }

  Sketchup.add_observer(tool)
  Data.reload(tool)

  menu = UI.menu.add_submenu("KMP3D")
  menu.add_item(tool_cmd)
  menu.add_item(exporter_cmd)

  toolbar = UI::Toolbar.new("KMP3D")
  toolbar.add_item(tool_cmd)
  toolbar.show
end
