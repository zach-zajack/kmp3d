module KMP3D
  class Type
    include HTMLHelpers

    attr_reader :name, :group_settings, :settings, :model
    attr_accessor :group, :selected_points

    Settings = Struct.new(:type, :prompt, :default)
    PATTERNS = {
      :int16 => /^[-]?\d+$/,
      :float => /^[-]?\d*\.?\d+$/
    }

    def initialize(model_type = "point")
      @model = Data.model.definitions.load("#{DIR}/models/#{model_type}.skp")
      @group = 0
      @selected_points = []
      if @group_settings
        @group_inputs = []
        add_group
        add_new_group_settings
      end
    end

    def add_to_component(component)
      component.definition = @model
      component.name += component_settings
    end

    def add_to_model(pos)
      point = Geom::Point3d.new(pos)
      component = Data.entities.add_instance(@model, point)
      component.name = component_settings
    end

    def add_group
      @group_inputs << @group_settings.map { |s| s.default }
    end

    def to_html
      tag(:table) do
        if @group == groups
          table_rows(@group_inputs, @group_settings) * ""
        else
          table_rows(inputs, @settings) * ""
        end
      end
    end

    def component_settings
      "#{type_name}" \
      "(#{@group}," \
      "#{inputs.length - 1}," \
      "#{inputs.last * ','}) "
    end

    def inputs
      inputs = [@settings.map { |s| s.default }]
      Data.kmp3d_entities.each do |ent|
        settings = ent.kmp3d_settings(type_name)
        next if settings.nil? || settings[0] != @group.to_s
        inputs << settings[2..-1]
      end
      return inputs
    end

    def type_name
      self.class.name
    end

    def groups
      @group_settings.nil? ? 1 : @group_inputs.length - 1
    end

    protected

    def add_new_group_settings
      @group_inputs << @group_inputs.last
    end

    def table_rows(inputs, settings)
      id = -1
      inputs.map do |row|
        tag(:tr, row_attribs(id)) do
          if id < 0
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
      row.zip(settings).map do |col, setting|
        table_id += 1
        tag(:td) { table_input("#{id},#{table_id}", col, setting) }
      end
    end

    def prompt_columns(row, settings)
      row.zip(settings).map do |col, setting|
        tag(:th) { tag(:span) { setting.prompt } }
      end
    end

    def row_attribs(id)
      attribs = {}
      attribs[:class] = "selected" if @selected_points.include?(id.to_s)
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
