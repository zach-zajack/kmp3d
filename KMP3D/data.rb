module KMP3D
  module Data
    module_function

    def model
      Sketchup.active_model
    end

    def entities
      model.entities
    end

    def selection
      model.selection
    end

    def kmp3d_entities
      entities.select { |ent| ent.kmp3d_object? }
    end

    def get_entity(type_name, id)
      entities.each { |ent| return ent if ent.kmp3d_id(type_name) == id }
    end

    def types
      @types
    end

    def reload_types
      @types = [
        KTPT.new, ENPT.new, ITPT.new, CKPT.new, GOBJ.new,
        POTI.new, JGPT.new, CNPT.new, MSPT.new, STGI.new
      ]
    end
  end
end
