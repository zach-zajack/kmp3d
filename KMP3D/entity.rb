class Sketchup::Entity
  def kmp3d_object?
    false
  end

  def type?(type_name)
    false
  end

  def kmp3d_settings
    nil
  end

  def kmp3d_settings_insert(index, value)
  end

  def kmp3d_id(type_name)
    nil
  end
end

class Sketchup::ComponentInstance
  def kmp3d_object?
    name[0, 5] == "KMP3D"
  end

  def type?(type_name)
    name.include?(type_name)
  end

  def kmp3d_settings
    start_end = kmp3d_settings_start_end
    return if start_end.nil?
    index_start, index_end = start_end
    return name[index_start..index_end].split(",")
  end

  def kmp3d_settings_insert(index, value)
    start_end = kmp3d_settings_start_end
    return if start_end.nil?
    index_start, index_end = start_end
    settings = kmp3d_settings
    settings[index + 1] = value # spot 1 is for the group number
    name_clone = name
    name_clone[index_start..index_end] = settings.join(",")
    self.name = name_clone
  end

  def kmp3d_id(type_name)
    KMP3D::Data.kmp3d_entities(type_name).index(self).to_s
  end

  def kmp3d_settings_start_end
    return unless kmp3d_object?
    return [
      index_start = name.index("(") + 1,
      index_end   = name.index(")") - 1
    ]
  end
end
