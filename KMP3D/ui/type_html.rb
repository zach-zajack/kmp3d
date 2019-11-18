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

    def show_group?
      external_settings
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
            cols = tag(:td, :onclick => callback("selectRow", kmp3d_id)) { id }
            cols += table_columns(kmp3d_id, row, settings) * ""
          end
          id += 1
          next cols
        end
      end
    end

    def table_columns(id, row, settings)
      table_id = -1
      table = row.zip(settings).map do |col, setting|
        next if setting.type == :hidden
        table_id += 1
        tag(:td) { table_input("#{id},#{table_id}", col, setting) }
      end
      table << tag(:td, :style => "width:20px") do
        tag(:button, :onclick => callback("deleteRow", id)) { "&#x2715;" }
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
      attribs = {:id => "row#{id}"}
      attribs[:class] = "selected" if selected
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
      end
    end
  end
end
