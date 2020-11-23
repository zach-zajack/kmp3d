module KMP3D
  require "#{DIR}/test/kmp3d_test"
  require "#{DIR}/test/test_import_export"
  require "#{DIR}/test/test_rotations"

  menu = UI.menu.add_submenu("KMP3D Tests")

  rebuild_files = menu.add_submenu("1:1 Rebuild file")
  Dir["#{DIR}/test/kmps/*.kmp"].each do |path|
    cmd = UI::Command.new(File.basename(path)) { TestImportExport.new(path) }
    rebuild_files.add_item(cmd)
  end

  rebuild_all = UI::Command.new("1:1 Rebuild all files") do
    Dir["#{DIR}/test/kmps/*.kmp"].each { |path| TestImportExport.new(path) }
  end
  menu.add_item(rebuild_all)

  test_rotations = menu.add_submenu("Test rotations")
  [5, 100, 1000].each do |amount|
    cmd = UI::Command.new("#{amount} times") { TestRotations.new(amount) }
    test_rotations.add_item(cmd)
  end
end
