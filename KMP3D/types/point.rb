module KMP3D
  class Point < Type
    def initialize
      super("point")
    end

    def add_to_component(comp)
      Data.model.start_operation("Add Settings to KMP3D Point", true)
      comp.name += component_settings
      comp.definition = Data.load_def(comp.model_path)
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
      "Click to add a new point. " \
      "Place on an existing point to combine settings."
    end
  end
end
