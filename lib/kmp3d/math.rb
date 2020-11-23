module KMP3D
  module KMPMath
    module_function

    def matrix_to_euler(array)
      # solution based off http://www.gregslabaugh.net/publications/euler.pdf
      if array[1].abs == 1.0
        sign = array[1] <=> 0
        rot = []
        rot.y = 90 * sign
        rot.x = Math.atan2(array[8] * sign, -array[4] * sign).radians
        rot.z = 0
      else
        r1 = []
        r2 = []
        r1.y = Math.asin(array[1]).radians
        cos = Math.cos(r1.y.degrees)
        r1.x = Math.atan2(-array[9] / cos, array[5] / cos).radians
        r1.z = Math.atan2(array[2] / cos, array[0] / cos).radians
        r2.y = 180 - r1.y
        r2.x = Math.atan2(array[9] / cos, -array[5] / cos).radians
        r2.z = Math.atan2(-array[2] / cos, -array[0] / cos).radians
        rot = if r1.select { |v| v.abs < 1e-5 }.length >= \
                 r2.select { |v| v.abs < 1e-5 }.length then r1
              else r2
              end
      end
      rot.map! { |r| r > 180 + 1e-5 ? r - 360 : r }
      return rot
    end

    def euler_to_matrix(x, y, z)
      [
        Math.cos(y) * Math.cos(z),
        Math.sin(x) * Math.sin(y) * Math.cos(z) - Math.cos(x) * Math.sin(z),
        Math.cos(x) * Math.sin(y) * Math.cos(z) + Math.sin(x) * Math.sin(z),

        Math.cos(y) * Math.sin(z),
        Math.sin(x) * Math.sin(y) * Math.sin(z) + Math.cos(x) * Math.cos(z),
        Math.cos(x) * Math.sin(y) * Math.sin(z) - Math.sin(x) * Math.cos(z),

        -Math.sin(y),
        Math.sin(x) * Math.cos(y),
        Math.cos(x) * Math.cos(y)
      ]
    end

    def euler_equal?(euler1, euler2)
      euler_to_matrix(*euler1).zip(euler_to_matrix(*euler2)).all? do |e1, e2|
        (e1 - e2).abs < 1e-5
      end
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
      Geom::Transformation.interpolate(p1, p2, t).origin
    end

    def bezier_at(pts, t)
      return pts[0] if pts.length == 1

      pts = Array.new(pts.length - 1) { |i| lerp(pts[i], pts[i + 1], t) }
      bezier_at(pts, t)
    end

    def intersect_area?(area, pt)
      min = area.bounds.min
      max = area.bounds.max
      min.x < pt.x && min.y < pt.y && min.z < pt.z && \
        max.x > pt.x && max.y > pt.y && max.z > pt.z
    end
  end
end
