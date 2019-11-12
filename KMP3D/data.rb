module KMP3D
  module Data
    module_function

    def model
      Sketchup.active_model
    end

    def entities
      model.active_entities
    end

    def selection
      model.selection
    end

    def layers
      model.layers
    end

    def kmp3d_entities(type_name)
      entities.select { |ent| ent.type?(type_name) }
    end

    def get_entity(type_name, id)
      return kmp3d_entities(type_name)[id.to_i]
    end

    def types
      @types
    end

    def type_by_name(name)
      @types.select { |type| type.type_name == name }.first
    end

    def hybrid_types
      @hybrid_types
    end

    def css
      css = Sketchup.read_default("KMP3D", "CSS", "default")
      css = "default" unless File.exist?("#{DIR}/css/#{css}.css")
      File.open("#{DIR}/css/#{css}.css").read
    end

    def css_themes
      Dir["#{DIR}/css/*.css"].map { |f| f[f.rindex(/[\\\/]/)+1...-4] }
    end

    def load_def(name)
      model.definitions.load("#{DIR}/models/#{name}.skp")
    end

    def reload(observer)
      model.add_observer(observer)
      selection.add_observer(observer)
      @types = [
        KTPT.new, ENPT.new, ITPT.new, CKPT.new, GOBJ.new,
        POTI.new, JGPT.new, CNPT.new, MSPT.new, STGI.new, Hybrid.new
      ]
      @hybrid_types = [
        KTPT.new, ENPT.new, ITPT.new,
        POTI.new, JGPT.new, CNPT.new, MSPT.new
      ]
      Dir["#{DIR}/models/*.skp"].each do |f|
        load_def(f[f.rindex(/[\\\/]/)+1...-4])
      end
      @types.each { |t| layers.add(t.name).visible = false }
    end
  end
end
