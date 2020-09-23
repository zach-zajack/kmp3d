module KMP3D
  module Callbacks
    def add_callbacks
      @dlg.add_action_callback("puts") { |_, str| puts str }
      @dlg.add_action_callback("refresh") { refresh_html }
      @dlg.add_action_callback("addGroup") { add_group }
      @dlg.add_action_callback("focusRow") { |_, id| focus_row(id) }
      @dlg.add_action_callback("deleteRow") { |_, id| delete_row(id) }
      @dlg.add_action_callback("selectRow") { |_, id| select_row(id) }
      @dlg.add_action_callback("switchType") { |_, id| switch_type(id) }
      @dlg.add_action_callback("switchGroup") { |_, id| switch_group(id) }
      @dlg.add_action_callback("inputChange") { |_, id| edit_value(id) }
      @dlg.add_action_callback("objPathChange") { |_, id| obj_path_change(id) }
      @dlg.add_action_callback("setHybridType") { |_, id| set_hybrid_type(id) }
      @dlg.add_action_callback("setHybridGroup") { set_hybrid_group }
      @dlg.add_action_callback("typesScroll") { |_, px| @scroll_types = px }
      @dlg.add_action_callback("tableScroll") { |_, px| @scroll_table = px }
    end

    def add_group
      @type.add_group
      refresh_html
    end

    def delete_row(id)
      @type.on_external_settings? ? delete_group(id) : delete_point(id)
      refresh_html
    end

    def focus_row(id)
      return if @type.on_external_settings?
      ent = Data.get_entity(@type.type_name, id)
      unless @prev_focus.nil?
        Data.selection.remove(@prev_focus)
        update_row(@prev_focus)
      end
      Data.selection.add(ent)
      update_row(ent)
      @prev_focus = ent
    end

    def delete_group(id)
      gid = @type.group_id(id.to_i - 1)
      @type.table.delete_at(id.to_i)
      Data.model.start_operation("Remove #{@type.type_name} Group #{gid}")
      Data.entities.erase_entities(Data.entities_in_group(@type.type_name, gid))
      if @type.sequential_id?
        Data.entities_after_group(@type.type_name, gid).each do |ent|
          ent.edit_setting(0, ent.kmp3d_group.to_i - 1)
        end
      end
      KMP3D::Data.model.commit_operation
      @type.group -= 1
      refresh_html
    end

    def delete_point(id)
      KMP3D::Data.model.start_operation("Remove KMP3D Point")
      Data.get_entity(@type.type_name, id.to_i - 1).erase!
      KMP3D::Data.model.commit_operation
      refresh_html
    end

    def select_row(id)
      @type.on_external_settings? ? select_group(id) : select_point(id)
    end

    def select_group(id)
      selected_ents = Data.entities_in_group(@type.type_name, id)
      selected = (selected_ents - @prev_selection) != []
      selected_ents.each do |ent|
        selected ? Data.selection.add(ent) : Data.selection.remove(ent)
      end
      selected ? \
        @prev_selection += selected_ents : @prev_selection -= selected_ents
      @dlg.execute_script(toggle_select(id, selected))
    end

    def select_point(id)
      ent = Data.get_entity(@type.type_name, id)
      Data.selection.toggle(ent)
      @prev_selection << ent
      update_row(ent)
    end

    def edit_value(table_id)
      id = table_id.split(",").first
      row = table_id.split(",").last
      value = @dlg.get_element_value(table_id)
      value = "false" if value == "true"
      value = "true" if value == "false"
      @type.on_external_settings? ? \
        edit_group_value(value, id, row) : edit_point_value(value, id, row)
    end

    def edit_group_value(value, row, col)
      setting = @type.external_settings[col.to_i]
      @type.update_group(value, row, col) if setting_valid?(setting, value)
      refresh_html
    end

    def edit_point_value(value, id, col)
      ent = Data.get_entity(@type.type_name, id)
      setting = @type.settings[col.to_i]
      @type.update_setting(ent, value, col) if setting_valid?(setting, value)
      update_row(ent)
    end

    def set_hybrid_type(id)
      # includes nil
      @type.hybrid_types[id] = @dlg.get_element_value("hybrid#{id}") != "true"
      refresh_html
    end

    def set_hybrid_group
      value = @dlg.get_element_value("hybridGroup")
      @type.group = value.to_i if valid?(:byte, value)
      refresh_html
    end

    def switch_type(id)
      @type.step = 0
      @type_index = id.to_i
      refresh_html
    end

    def switch_group(id)
      @type.step = 0
      @type.group = id.to_i
      refresh_html
    end

    def obj_path_change(table_id)
      id = table_id.split(",").first
      row = table_id.split(",").last
      path = Data.model.definitions.load(UI.openpanel(
        "Select a file to import from.", Data.model_dir, "SKP|*.skp||"
      ))
      @type.update_group(path, id, row)
      refresh_html
    end

    private

    def setting_valid?(setting, value)
      setting.type != :text || valid?(setting.input, value)
    end

    def valid_int_within(value, min, max)
      /^(0x(\d|[A-f])+|-?\d+)$/.match(value) \
      && min <= value.to_i && value.to_i <= max
    end

    def valid?(input, value)
      case input
      when :obj then !Objects::LIST[value].nil?
      when :byte then valid_int_within(value, 0, 0xFF)
      when :bytes
        value != "" && \
        value.split(",", -1).all? { |v| valid_int_within(v, 0, 0xFF) }
      when :float then /^[-]?\d*\.?\d+$/.match(value)
      when :int16 then valid_int_within(value, -0x7FFF, 0x7FFF)
      when :uint16 then valid_int_within(value, 0, 0xFFFF)
      end
    end
  end
end
