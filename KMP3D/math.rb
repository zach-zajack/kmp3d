module KMP3D
  module KMPMath
    module_function

    def determinant(array)
      array[0]*array[6]*array[9] + array[0]*array[5]*array[10] + \
      array[1]*array[6]*array[8] + array[1]*array[4]*array[10] + \
      array[2]*array[5]*array[8] + array[2]*array[4]*array[9]
    end

    def matrix_to_euler(array)
      # solution based off http://www.gregslabaugh.net/publications/euler.pdf
      if array[1].abs == 1.0
        sign = -array[1] <=> 0
        rot = []
        rot.y = -90*sign
        rot.x = Math.atan2(array[8]*sign, array[4]*sign).radians
        rot.z = 0
      else
        r1 = []
        r2 = []
        r1.y = Math.asin(array[1]).radians
        cos = Math.cos(r1.y.degrees)
        r1.x = Math.atan2(-array[9]/cos, array[5]/cos).radians
        r1.z = Math.atan2(array[2]/cos, array[0]/cos).radians
        r2.y = 180 - r1.y
        r2.x = Math.atan2(array[9]/cos, -array[5]/cos).radians
        r2.z = Math.atan2(-array[2]/cos, -array[0]/cos).radians
        if r1.select { |v| v.abs < 1e-6 }.length >= \
           r2.select { |v| v.abs < 1e-6 }.length then rot = r1
        else rot = r2
        end
      end
      return rot
    end

    def checkpoint_transform(x, y, angle, scale)
      angle = (90 - angle).degrees
      scale *= 1500
      x1 = x - scale * Math.cos(angle)
      y1 = y - scale * Math.sin(angle)
      x2 = x + scale * Math.cos(angle)
      y2 = y + scale * Math.sin(angle)
      return [x1, y1, x2, y2]
    end

    def lerp(p1, p2, t)
      Geom::Transformation.interpolate(p1, p2, t)
    end

    def bezier_at(pts, t)
      return pts[0] if pts.length == 1
      bezier_at(Array.new(pts.length - 1) { |i| lerp(pts[i], pts[i+1], t) }, t)
    end
  end
end
