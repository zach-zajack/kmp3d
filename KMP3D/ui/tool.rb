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
      @dlg.add_action_callback("deleteRow") { |_, id| delete_row(id) }
      @dlg.add_action_callback("selectRow") { |_, id| select_point(id) }
      @dlg.add_action_callback("inputChange") { |_, id| edit_value(id) }
    end

    def set_group
      type.group = @dlg.get_element_value("currentGroup").to_i
      refresh_html
    end

    def add_group
      type.add_group
      refresh_html
    end

    def delete_row(id)
      type.on_external_settings? ? delete_group(id) : delete_point(id)
      refresh_html
    end

    def delete_group(id)
      type.table.delete_at(id.to_i)
      Data.model.start_operation("Remove Group and Settings", true)
      Data.kmp3d_entities(type.type_name).each do |ent|
        ent.remove_kmp3d_settings(type.type_name) if \
          ent.kmp3d_settings(type.type_name)[0] == id
      end
      KMP3D::Data.model.commit_operation
    end

    def delete_point(id)
      KMP3D::Data.model.start_operation("Remove KMP3D Settings From Point", true)
      ent = Data.get_entity(type.type_name, id)
      ent.remove_kmp3d_settings(type.type_name)
      KMP3D::Data.model.commit_operation
    end

    def select_point(id)
      ent = Data.get_entity(type.type_name, id)
      if Data.selection.include?(ent)
        Data.selection.remove(ent)
      else
        Data.selection.add(ent)
      end
      refresh_html
    end

    def edit_value(table_id)
      id = table_id.split(",").first
      row = table_id.split(",").last
      value = @dlg.get_element_value(table_id)
      type.on_external_settings? ? \
        edit_group_value(value, id, row) : edit_point_value(value, id, row)
    end

    def edit_group_value(value, id, row)
      if Data::PATTERNS[type.external_settings[row.to_i].type].match(value).nil?
        refresh_html
        return
      end
      type.table[id.to_i + 1][row.to_i] = value
    end

    def edit_point_value(value, id, row)
      if Data::PATTERNS[type.settings[row.to_i].type].match(value).nil?
        refresh_html
        return
      end
      ent = Data.get_entity(type.type_name, id)
      ent.kmp3d_settings_insert(type.type_name, row.to_i, value)
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
      return "" unless type.external_settings
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
      return "" unless type.external_settings
      tag(:button, :onclick => callback("addGroup")) { "Add Group" }
    end

    def generate_head
      tag(:head) do
        tag(:style) { @css }
      end
    end

    def generate_body
      tag(:body) do
        tag(:div, {:class => "table"}) { type.to_html } + \
        tag(:div, {:class => "types"}) { types + type_groups + group_button }
      end
    end
  end
end
