module KMP3D
  require "#{DIR}/test/kmp3d_test"
  require "#{DIR}/test/test_import_export"

  menu = UI.menu.add_submenu("KMP3D Tests")

  rebuild_files = menu.add_submenu("1:1 Rebuild file")

  Dir["#{DIR}/test/kmps/*.kmp"].each do |path|
    cmd = UI::Command.new(path[path.rindex(%r{[\\/]}) + 1..-1]) do
      TestImportExport.new(path)
    end
    rebuild_files.add_item(cmd)
  end

  rebuild_all = UI::Command.new("1:1 Rebuild all files") do
    Dir["#{DIR}/test/kmps/*.kmp"].each do |path|
      TestImportExport.new(path)
    end
  end

  menu.add_item(rebuild_all)
end
