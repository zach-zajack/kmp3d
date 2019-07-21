module KMP3D
  class Tool
    include HTMLHelpers
    include Observer

    def initialize
      @dlg = UI::WebDialog.new("KMP3D", false, "KMP3D")
      @ip = Sketchup::InputPoint.new
      @css = File.open("#{DIR}/css/default.css").read
      add_callbacks
    end

    def type
      Data.types[type_index]
    end

    def type_name
      type.class.name
    end

    def type_index
      @dlg.get_element_value("currentType").to_i
    end

    def refresh_html
      @dlg.set_html(generate_head + generate_body)
    end

    private

    def add_callbacks
      @dlg.add_action_callback("refresh") { refresh_html }
      @dlg.add_action_callback("setGroup") { set_group }
      @dlg.add_action_callback("addGroup") { add_group }
      @dlg.add_action_callback("selectRow") { |_, id| select_point(id) }
      @dlg.add_action_callback("inputChange") { |_, id| edit_point(id) }
    end

    def set_group
      type.group = @dlg.get_element_value("currentGroup").to_i
      refresh_html
    end

    def add_group
      type.add_group
      refresh_html
    end

    def select_point(id)
      ent = Data.get_entity(type_name, id)
      if Data.selection.include?(ent)
        Data.selection.remove(ent)
        type.selected_points.delete(id)
      else
        Data.selection.add(ent)
        type.selected_points << id
      end
      refresh_html
    end

    def edit_point(table_id)
      id     = table_id.split(",").first
      row_id = table_id.split(",").last
      value = @dlg.get_element_value(table_id)
      ent = Data.get_entity(type_name, id)
      ent.kmp3d_settings_insert(type_name, row_id.to_i, value)
    end

    def group_index
      @dlg.get_element_value("currentGroup").to_i
    end

    def types
      select(type_index,
        :id => "currentType",
        :size => 10,
        :onchange => callback("refresh"),
        *Data.types.map { |type| type.name }
      )
    end

    def type_groups
      return "" unless type.group_settings
      len = type.groups
      size = [len + 1, 10].min
      select(type.group,
        :id => "currentGroup",
        :size => size,
        :onchange => callback("setGroup"),
        *(0..len).map { |i| i == len ? "Group Settings" : "Group #{i}" }
      )
    end

    def group_button
      return "" unless type.group_settings
      tag(:button, :onclick => callback("addGroup")) { "Add Group" }
    end

    def generate_head
      tag(:head) do
        tag(:style) { @css }
      end
    end

    def generate_body
      tag(:body) do
        tag(:div, {:class => "types"}) { types + type_groups + group_button } + \
        tag(:div, {:class => "table"}) { type.to_html }
      end
    end
  end
end
