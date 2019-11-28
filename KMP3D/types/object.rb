module KMP3D
  class Object < Type
    def model
      model_for(@table[@group + 1][0])
    end

    def transform(comp, pos)
      comp.transform!(Geom::Transformation.translation(pos))
    end

    def advance_steps(pos)
      0
    end

    def helper_text
      "Click to add a new point. " \
      "Place on an existing point to combine settings."
    end

    def import(pos, rot, scale, group, settings)
      comp = Data.entities.add_instance(model_for(group), pos)
      comp.transform!(Geom::Transformation.rotation(pos, [1, 0, 0],  rot[0]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 0, 1],  rot[1]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 1, 0], -rot[2]))
      comp.name = "KMP3D #{type_name}(#{group},#{settings * ','})"
      comp.layer = name
    end

    def group_id(i)
      @table[i + 1][0].to_i
    end

    private

    def model_for(i)
      case i.to_s
      when "101" then Data.load_def("itembox")
      else Data.load_def("point")
      end
    end
  end
end
