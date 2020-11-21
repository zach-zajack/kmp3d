module KMP3D
  require "#{DIR}/test/kmp3d_test"
  require "#{DIR}/test/test_import_export"

  rebuild_random = UI::Command.new("1:1 Rebuild, Random file") do
    path = Dir["#{DIR}/test/kmps/*.kmp"].shuffle.first
    TestImportExport.new(path)
  end

  rebuild_all = UI::Command.new("1:1 Rebuild, All files") do
    Dir["#{DIR}/test/kmps/*.kmp"].each do |path|
      TestImportExport.new(path)
    end
  end

  menu = UI.menu.add_submenu("KMP3D Test")
  menu.add_item(rebuild_random)
  menu.add_item(rebuild_all)
end
