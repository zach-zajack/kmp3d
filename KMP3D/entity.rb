class Sketchup::Entity
  def kmp3d_object?
    false
  end

  def type?(type_name)
    false
  end

  def kmp3d_settings(type_name)
  end

  def kmp3d_settings_insert(type_name, index, value)
    nil
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

  def kmp3d_settings(type_name)
    start_end = kmp3d_settings_start_end(type_name)
    return if start_end.nil?
    index_start, index_end = start_end
    return name[index_start..index_end].split(",")
  end

  def kmp3d_settings_insert(type_name, index, value)
    start_end = kmp3d_settings_start_end(type_name)
    return if start_end.nil?
    index_start, index_end = start_end
    settings = kmp3d_settings(type_name)
    settings[index + 1] = value # spot 1 is for the group number
    name_clone = name
    name_clone[index_start..index_end] = settings.join(",")
    self.name = name_clone
  end

  def kmp3d_id(type_name)
    KMP3D::Data.kmp3d_entities(type_name).index(self).to_s
  end

  def kmp3d_settings_start_end(type_name)
    return unless kmp3d_object?
    index = name.index(type_name)
    return if index.nil?
    return [
      index_start = name.index("(", index) + 1,
      index_end   = name.index(")", index) - 1
    ]
  end
end
