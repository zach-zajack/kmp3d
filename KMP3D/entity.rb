class Sketchup::Entity
  def kmp3d_object?
    false
  end

  def model_type
    nil
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

  def model_type
    definition.path[definition.path.rindex(/[\\\/]/)+1...-4]
  end

  def type?(type_name)
    name.include?(type_name)
  end

  def kmp3d_settings
    name[name.index("(") + 1..name.index(")") - 1].split("|")
  end

  def edit_setting(index, value)
    settings = kmp3d_settings
    settings[index] = value
    name_clone = name
    name_clone[name.index("(") + 1..name.index(")") - 1] = settings.join("|")
    self.name = name_clone
  end

  def kmp3d_id(type_name)
    KMP3D::Data.kmp3d_entities(type_name).index(self)
  end

  def kmp3d_group
    kmp3d_settings[0]
  end

  def kmp_transform
    array = transformation.to_a
    pos = []
    pos.x =  array[12].to_m
    pos.y =  array[14].to_m
    pos.z = -array[13].to_m
    return pos if model_type == "point" && !type?("GOBJ")
    sign = KMP3D::KMPMath.determinant(array) <=> 0
    scale = []
    scale.x = array[0...3].distance([0,0,0])
    scale.y = array[8...11].distance([0,0,0]) * sign
    scale.z = array[4...7].distance([0,0,0])
    array = \
      array[0...3].map  { |a| a/scale.x } + [array[3]] + \
      array[4...7].map  { |a| a/scale.z } + [array[7]] + \
      array[8...11].map { |a| a/scale.y } + array[11..-1]
    rot = KMP3D::KMPMath.matrix_to_euler(array)
    return pos + rot if model_type == "vector"
    if model_type == "checkpoint"
      return KMP3D::KMPMath.checkpoint_transform(pos.x, pos.z, rot.y, scale.z)
    end
    return pos + rot + scale
  end
end
