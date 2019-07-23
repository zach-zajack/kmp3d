module KMP3D
  class CNPT < Type
    def initialize
      @name = "Cannons"
      @settings = [Settings.new(:float, "Size", "25.0")]
      @step = 0
      super("vector")
    end

    def add_to_component(component)
      component.definition = @model
      super(component)
    end

    def add_to_model(pos)
      if @step == 0
        @step = 1
        @prev = pos
      elsif @step == 1
        @step = 0
        angle = Math::PI - Math.atan2(pos.x - @prev.x, pos.y - @prev.y)
        add_point(@prev, angle)
      end
    end

    def helper_text
      case @step
      when 0 then "(Step 1/2) Click to place the start position of cannon."
      when 1 then "(Step 2/2) Click to place the end position of cannon."
      end
    end

    private

    def add_point(pos, angle)
      Data.model.start_operation("Add KMP3D Point", true)
      point = Geom::Point3d.new(pos)
      comp = Data.entities.add_instance(@model, point)
      comp.transform!(Geom::Transformation.rotation(point, [0, 0, 1], angle))
      comp.name = "KMP3D " + component_settings
      Data.model.commit_operation
    end
  end
end
