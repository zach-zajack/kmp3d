module KMP3D
  class Type
    include HTMLHelpers

    attr_reader :name, :external_settings, :settings, :model
    attr_accessor :group, :table

    Settings = Struct.new(:type, :prompt, :default)

    def initialize(model_type = "point")
      @model = Data.load_def(model_type)
      @group = 0
      if @external_settings # external settings deal with groups, mostly
        @table = Data.model.get_attribute("KMP3D", \
          type_name, [Array.new(@external_settings.length)])
        add_group if @table.length == 1
      end
    end

    def save_settings
      return unless @external_settings
      Data.model.set_attribute("KMP3D", type_name, @table)
    end

    def add_to_component(comp)
      return if comp.type?("KMP3D::CKPT") || comp.type?("KMP3D::GOBJ")
      Data.model.start_operation("Add Settings to KMP3D Point", true)
      comp.definition = @model if comp.definition == Data.load_def("point")
      comp.name += component_settings
      Data.model.commit_operation
    end

    def add_to_model(pos)
      Data.model.start_operation("Add KMP3D Point", true)
      point = Geom::Point3d.new(pos)
      component = Data.entities.add_instance(@model, point)
      component.name = "KMP3D " + component_settings
      Data.model.commit_operation
    end

    def helper_text
      "Click to add a new point. Place on an existing point to combine settings."
    end

    def add_group
      @table << @external_settings.map { |s| s.default }
    end

    def to_html
      tag(:table) do
        if on_external_settings?
          table_rows(@table, @external_settings) * ""
        else
          table_rows(inputs, @settings) * ""
        end
      end
    end

    def component_settings
      "#{type_name}(#{@group},#{inputs.last * ','}) "
    end

    def inputs
      # settings added due to next point using previous settings
      inputs = [@settings.map { |s| s.default }]
      Data.kmp3d_entities(type_name).each do |ent|
        settings = ent.kmp3d_settings(type_name)
        next if settings[0] != @group.to_s # spot 1 is for the group number
        inputs << settings[1..-1]
      end
      return inputs
    end

    def type_name
      self.class.name[7..-1]
    end

    def groups
      @external_settings.nil? ? 1 : @table.length - 1
    end

    def on_external_settings?
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
      offset = (on_external_settings? ? 0 : entities_before_group)
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
