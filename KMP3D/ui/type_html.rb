module KMP3D
  module TypeHTML
    def to_html
      tag(:table) do
        if on_external_settings?
          table_rows(@table, @external_settings) * ""
        else
          table_rows(inputs, @settings) * ""
        end
      end
    end

    def show_group?
      external_settings && use_points?
    end

    protected

    def table_rows(inputs, settings)
      offset = (on_external_settings? ? 0 : entities_before_group)
      id = offset - 1
      inputs.map do |row|
        selected = row.shift unless on_external_settings?
        tag(:tr, row_attribs(id, selected)) do
          if id < offset
            cols = tag(:th) { "ID" } + prompt_columns(row, settings) * ""
          else
            cols = tag(:td, {:onclick => callback("selectRow", id)}) { id } + \
            table_columns(id, row, settings) * ""
          end
          id += 1
          next cols
        end
      end
    end

    def table_columns(id, row, settings)
      table_id = -1
      table = row.zip(settings).map do |col, setting|
        table_id += 1
        tag(:td) { table_input("#{id},#{table_id}", col, setting) }
      end
      table << tag(:td) { delete_button(id) }
    end

    def delete_button(id)
      tag(:button, :onclick => callback("deleteRow", id)) { "x" }
    end

    def prompt_columns(row, settings)
      row.zip(settings).map do |col, setting|
        tag(:th) { tag(:span) { setting.prompt } }
      end
    end

    def row_attribs(id, selected)
      attribs = {}
      attribs[:class] = "selected" if selected
      return attribs
    end

    def table_input(id, value, setting)
      tag(:input,
        :id => id,
        :type => "text",
        :onchange => callback("inputChange", id),
        :value => value
      )
    end
  end
end
