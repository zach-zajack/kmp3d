module KMP3D
  class TestRotations < KMP3DTest
    def initialize(amount)
      super
      @vec = KMP3D::Vector.new
      puts "Testing rotations #{amount} times..."
      Data.model.start_operation("Test rotations", true)
      amount.times { test_euler_matrix_conversion }
      Data.model.commit_operation
      print_results
    end

    def test_euler_matrix_conversion
      euler1 = Array.new(3) { rand(-180..180).degrees }
      matrix = KMP3D::KMPMath.euler_to_matrix(*euler1)
      comp   = @vec.import(ORIGIN, euler1, 0, [])
      euler2 = comp.kmp_transform[3..-1].map { |r| r.degrees }
      assert_euler_equal(euler1, euler2, "Test")
      comp.erase!
    end
  end
end
