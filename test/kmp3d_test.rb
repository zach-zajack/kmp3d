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

    def assert_equal(v1, v2, msg)
      match = (v1 == v2) || \
        (v1.is_a?(Float) || v2.is_a?(Float)) && (v1 - v2).abs < 1e-5
      assert(match, msg + " mismatch: #{v1} != #{v2}")
    end
  end
end
