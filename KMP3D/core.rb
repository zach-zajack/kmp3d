module KMP3D
  require "#{DIR}/ui/html_helpers"
  require "#{DIR}/ui/observer"
  require "#{DIR}/ui/tool"
  require "#{DIR}/types/type"
  require "#{DIR}/types/ktpt"
  require "#{DIR}/types/enpt"
  require "#{DIR}/types/itpt"
  require "#{DIR}/types/ckpt"
  require "#{DIR}/types/gobj"
  require "#{DIR}/types/poti"
  require "#{DIR}/types/jgpt"
  require "#{DIR}/types/cnpt"
  require "#{DIR}/types/mspt"
  require "#{DIR}/types/stgi"
  require "#{DIR}/entity"
  require "#{DIR}/data"

  tool = Tool.new
  tool_cmd = UI::Command.new("KMP3D Tool") { Data.model.select_tool(tool) }
  tool_cmd.small_icon = tool_cmd.large_icon = "#{DIR}/images/tool.png"
  Sketchup.add_observer(tool)
  Data.selection.add_observer(tool)
  Data.reload_types

  menu = UI.menu.add_submenu("KMP3D")
  menu.add_item(tool_cmd)

  toolbar = UI::Toolbar.new("KMP3D")
  toolbar.add_item(tool_cmd)
  toolbar.show
end
