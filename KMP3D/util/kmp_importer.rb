module KMP3D
  module KMPImporter
    module_function

    def import
      path = UI.openpanel("Select a file to import from.")
      Data.model.start_operation("Import")
      @parser = BinaryParser.new(path)
      read_header
    end

    def read_header
      error("wrong file type") unless @parser.read(4) == "RKMD"
      @parser.read_uint32 # file length
      sections = @parser.read_uint16
      @header_length = @parser.read_uint16
      @parser.read_uint32 # version
      section_offsets = Array.new(sections) { @parser.read_uint32 }
      section_offsets.each { |section_offset| read_section(section_offset) }
    end

    def read_section(section_offset)
      @parser.head = @header_length + section_offset
      section_id = @parser.read(4)
      entries = @parser.read_uint16
      @parser.read_uint16 # extra data
      puts "loading #{section_id}"

    end

    def import_ktpt

    end

    def error(message)
      Data.model.abort_operation
      UI.messagebox("Error: #{message}!")
    end
  end
end
