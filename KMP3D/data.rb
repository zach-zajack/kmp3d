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

    def load_def(name)
      model.definitions.load("#{DIR}/models/#{name}.skp")
    end

    def reload(observer)
      model.add_observer(observer)
      selection.add_observer(observer)
      @types = [
        KTPT.new, ENPT.new, ITPT.new, CKPT.new, GOBJ.new,
        POTI.new, JGPT.new, CNPT.new, MSPT.new, STGI.new
      ]
    end

    PATTERNS = {
      :int => /^(0x(\d|[A-f])+|-?\d+)?$/,
      :bool => /^(0|1)$/,
      :float => /^[-]?\d*\.?\d+$/
    }
  end
end
