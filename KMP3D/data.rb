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

    def kmp3d_entities(type_name)
      entities.select { |ent| ent.kmp3d_object? && ent.type?(type_name) }
    end

    def get_entity(type_name, id)
      entities.each { |ent| return ent if ent.kmp3d_id(type_name) == id.to_s }
    end

    def any_kmp3d_entity?(type_name, id)
      selection.any? { |ent| ent.kmp3d_id(type_name) == id.to_s }
    end

    def types
      @types
    end

    def reload(observer)
      selection.add_observer(observer)
      @types = [
        KTPT.new, ENPT.new, ITPT.new, CKPT.new, GOBJ.new,
        POTI.new, JGPT.new, CNPT.new, MSPT.new, STGI.new
      ]
    end
  end
end
