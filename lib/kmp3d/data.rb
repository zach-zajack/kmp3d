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

    def model_dir
      path = Data.model.path
      rindex = path.rindex(/[\\\/]/)
      return "" if rindex.nil?
      return path[0..rindex]
    end

    def model_name
      path = Data.model.path
      rindex = path.rindex(/[\\\/]/)
      return "course" if rindex.nil?
      return path[rindex + 1...-4]
    end

    def set_layer_visible(type_name)
      # prev layers
      @layers.each { |name| layers[name].visible = false }
      @layers = [type_name]
      @layers << "Routes"   if type_name == "Cameras"
      @layers << "Cameras"  if type_name == "Area"
      @layers << "Respawns" if type_name == "Checkpoints"
      @layers.each { |name| layers[name].visible = true }
    end

    def kmp3d_entities(type_name)
      entities.select { |ent| ent.type?(type_name) }
    end

    def entities_in_group(type_name, group)
      entities.select do |ent|
        next unless ent.type?(type_name)
        ent.type?(type_name) && ent.kmp3d_group.to_i == hexify(group)
      end
    end

    def entities_before_group(type_name, group)
      entities.select do |ent|
        ent.type?(type_name) && ent.kmp3d_group.to_i < hexify(group)
      end
    end

    def entities_after_group(type_name, group)
      entities.select do |ent|
        ent.type?(type_name) && ent.kmp3d_group.to_i > hexify(group)
      end
    end

    def get_entity(type_name, id)
      return kmp3d_entities(type_name)[hexify(id)]
    end

    def hexify(data)
      data.to_s[0,2] == "0x" ? data.hex : data.to_i
    end

    def types
      @types
    end

    def type_by_typename(name)
      @types.select { |type| type.type_name == name }.first
    end

    def type_by_name(name)
      @types.select { |type| type.name == name }.first
    end

    def hybrid_types
      @hybrid_types
    end

    def load_def(name)
      model.definitions.load("#{DIR}/app/skps/#{name}.skp")
    end

    def load_obj(id)
      path = "objects/#{Objects::LIST[id].model}"
      File.file?("#{DIR}/app/skps/#{path}.skp") ? \
        load_def(path) : load_def("point")
    end

    def load_kmp3d_model
      return if model.get_attribute("KMP3D", "KMP3D-model?", false)
      Dir["#{DIR}/app/skps/*.skp"].each { |d| model.definitions.load(d) }
      @types.each { |t| layers.add(t.name).visible = false }
      model.set_attribute("KMP3D", "KMP3D-model?", true)
    end

    def reload(observer)
      return unless @reload
      @layers = []
      @reload = false
      model.add_observer(observer)
      selection.add_observer(observer)
      @types = [
        KTPT.new, ENPT.new, ITPT.new, CKPT.new, GOBJ.new, POTI.new,
        AREA.new, CAME.new, JGPT.new, CNPT.new, MSPT.new, STGI.new, Hybrid.new
      ]
      @hybrid_types = [
        KTPT.new, ENPT.new, ITPT.new,
        POTI.new, JGPT.new, CNPT.new, MSPT.new
      ]
    end

    def signal_reload
      @reload = true
    end
  end
end
