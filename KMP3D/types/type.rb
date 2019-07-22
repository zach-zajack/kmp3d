module KMP3D
  class Type
    include HTMLHelpers

    attr_reader :name, :group_settings, :settings, :model
    attr_accessor :group, :group_inputs

    Settings = Struct.new(:type, :prompt, :default)
    PATTERNS = {
      :int16 => /^[-]?\d+$/,
      :float => /^[-]?\d*\.?\d+$/
    }

    def initialize(model_type = "point")
      @model = Data.model.definitions.load("#{DIR}/models/#{model_type}.skp")
      @group = 0
      @group_inputs = Data.model.get_attribute("KMP3D", type_name, ["0", "0"]) \
        if @group_settings
    end

    def save_group_settings
      return unless @group_settings
      Data.model.set_attribute("KMP3D", type_name, @group_inputs)
    end

    def add_to_component(component)
      component.definition = @model unless @model == "point"
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
        if on_group_settings?
          table_rows(@group_inputs, @group_settings) * ""
        else
          table_rows(inputs, @settings) * ""
        end
      end
    end

    def component_settings
      "#{type_name}(#{@group},#{inputs.last * ','}) "
    end

    def inputs
      inputs = [@settings.map { |s| s.default }]
      Data.kmp3d_entities(type_name).each do |ent|
        settings = ent.kmp3d_settings(type_name)
        next if settings[0] != @group.to_s # spot 1 is for the group number
        inputs << settings[1..-1]
      end
      return inputs
    end

    def type_name
      self.class.name
    end

    def groups
      @group_settings.nil? ? 1 : @group_inputs.length - 1
    end

    def on_group_settings?
      @group == groups
    end

    protected

    def entities_before_group
      ents_before_group = Data.kmp3d_entities(type_name).select do |ent|
        ent.kmp3d_settings(type_name)[0].to_i < @group
      end
      return ents_before_group.length
    end

    def table_rows(inputs, settings)
      offset = (on_group_settings? ? 0 : entities_before_group)
      id = offset - 1
      inputs.map do |row|
        tag(:tr, row_attribs(id)) do
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
      attribs[:class] = "selected" if Data.any_kmp3d_entity?(type_name, id)
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
