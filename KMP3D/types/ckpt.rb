module KMP3D
  class CKPT < Type
    def initialize
      @name = "Checkpoints"
      @external_settings = [Settings.new(:int, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:int, "Respawn ID", "0"),
        Settings.new(:int, "Checkpoint Type", "-1")
      ]
      @groups = []
      @step = 0
      super("checkpoint")
    end

    def add_to_component(component)
    end

    def add_to_model(pos)
      if @step == 0
        @step = 1
        @points = [pos]
      elsif @step == 1
        @step = 2
        @points << pos
      elsif @step == 2
        @step = 0
        calc_transformation(pos)
      end
    end

    def helper_text
      case @step
      when 0 then "(Step 1/3) Click to place one end of the checkpoint."
      when 1 then "(Step 2/3) Click to place the other end of the checkpoint."
      when 2 then "(Step 3/3) Click in direction of the checkpoint."
      end
    end

    private

    def calc_transformation(pos)
      pos1, pos2 = @points
      avg = [(pos1.x + pos2.x)/2, (pos1.y + pos2.y)/2, (pos1.z + pos2.z)/2]
      slope = (pos1.y - pos2.y)/(pos1.x - pos2.x)
      angle = Math.atan(slope)
      angle += slope * (pos.x - pos1.x) + pos1.y < pos.y ? \
        Math::PI/2 : -Math::PI/2
      scale = pos1.distance(pos2).to_m / 3000 # 3000m is the length of the model
      add_point(avg, angle, scale)
    end

    def add_point(pos, angle, scale)
      Data.model.start_operation("Add KMP3D Point", true)
      point = Geom::Point3d.new(pos)
      comp = Data.entities.add_instance(@model, point)
      comp.transform!(Geom::Transformation.scaling(point, 1.0, scale, 1.0))
      comp.transform!(Geom::Transformation.rotation(point, [0, 0, 1], angle))
      comp.name = "KMP3D " + component_settings
      Data.model.commit_operation
    end
  end
end
