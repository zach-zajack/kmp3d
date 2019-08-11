module KMP3D
  class Object < Type
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

    def settings_names(i)
      "Object ID #{@table[i + 1][0]}"
    end
  end
end
