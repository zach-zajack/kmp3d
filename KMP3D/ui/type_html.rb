module KMP3D
  module TypeHTML
    def to_html
      tag(:table) do
        if on_external_settings?
          table_rows(@table, @external_settings) * ""
        else table_rows(inputs, @settings) * ""
        end
      end
    end

    def row_html(ent)
      id = Data.entities_in_group(type_name, group_id(@group)).length - 1
      kmp3d_id = ent.kmp3d_id(type_name)
      settings = ent.kmp3d_settings[1..-1]
      tag(:tr, row_attribs(kmp3d_id, false)) do
        col_html(id, kmp3d_id, settings, @settings)
      end
    end

    protected

    def table_rows(inputs, settings)
      id = -1
      inputs.map do |row|
        if on_external_settings?
          kmp3d_id = id
        else
          kmp3d_id = row.shift
          selected = row.shift
        end
        tag(:tr, row_attribs(kmp3d_id, selected)) do
          if id < 0
            cols = tag(:th) { "ID" } + prompt_columns(row, settings) * ""
          else
            cols = col_html(id, kmp3d_id, row, settings)
          end
          id += 1
          next cols
        end
      end
    end

    def col_html(id, kmp3d_id, row, settings)
      tag(:td, :onclick => callback("selectRow", kmp3d_id)) { id } + \
        table_columns(kmp3d_id, row, settings) * ""
    end

    def table_columns(id, row, settings)
      table_id = -1
      table = row.zip(settings).map do |col, setting|
        next if setting.type == :hidden
        table_id += 1
        tag(:td, :onclick => callback("focusRow", id)) do
          table_input("#{id},#{table_id}", col, setting)
        end
      end
      table << tag(:td, :class => "delete") do
        tag(:button, :onclick => callback("deleteRow", id+1)) { "&#x2715;" }
      end
    end

    def prompt_columns(row, settings)
      table = row.zip(settings).map do |col, setting|
        next if setting.type == :hidden
        tag(:th) { tag(:span) { setting.prompt } }
      end
      table << tag(:th, :style => "width:20px") { "" }
    end

    def row_attribs(id, selected)
      return {} if id.to_i < 0
      attribs = {:id => "row#{id}"}
      attribs[:class] = "selected" if !on_external_settings? && selected
      return attribs
    end

    def table_input(id, value, setting)
      attributes = {
        :id => id,
        :onchange => callback("inputChange", id),
        :value => value
      }
      case setting.type
      when :text then tag(:input, attributes.merge(:type => "text"))
      when :dropdown then select(value.to_i, attributes, setting.opts)
      when :checkbox then checkbox("", attributes, value == "true")
      when :path
        attributes = {:id => id, :onclick => callback("objPathChange", id)}
        path = value.path
        tag(:button, attributes) { path[path.rindex(/[\\\/]/) + 1..-1] }
      end
    end
  end
end
