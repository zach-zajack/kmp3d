module KMP3D
  class KMP3DTest
    def initialize(*_args)
      puts "------------------------------------"
      Data.signal_reload
      Data.reload(self)
      Data.load_kmp3d_model
      @passed = 0
      @total  = 0
    end

    def print_results
      puts "------------------"
      puts "Passed: #{@passed}"
      puts "Failed: #{@total - @passed}"
      puts "Total: #{@total}"
      puts ""
    end

    def assert(value, msg)
      @total += 1
      if value
        @passed += 1
      else
        puts "* Assertion failed: #{msg}"
      end
    end

    def assert_euler_equal(euler1, euler2, msg)
      matrix1 = KMP3D::KMPMath.euler_to_matrix(*euler1)
      matrix2 = KMP3D::KMPMath.euler_to_matrix(*euler2)
      match = matrix1.zip(matrix2).all? { |e1, e2| (e1 - e2).abs < 1e-5 }
      # approximate for better readability
      euler1.map! { |o| o.radians.to_i }
      euler2.map! { |n| n.radians.to_i }
      assert(match, "#{msg} Rotation mismatch: #{euler1} != #{euler2}")
    end

    def assert_equal(v1, v2, msg)
      match = (v1 == v2) || \
        (v1.is_a?(Float) || v2.is_a?(Float)) && (v1 - v2).abs < 1e-5
      assert(match, msg + " mismatch: #{v1} != #{v2}")
    end
  end
end
