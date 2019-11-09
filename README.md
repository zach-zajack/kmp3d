# KMP3D
KMP3D is a [Google SketchUp](https://www.sketchup.com/) plugin that functions as a 3D interface for [Mario Kart Wii](https://en.wikipedia.org/wiki/Mario_Kart_Wii)'s [KMP](http://wiki.tockdom.com/wiki/KMP) files, which deal with coordinate information, such as checkpoints, item routes, or respawn positions. Points are represented using spheres and vectors, depending on the point type.

![Screenshot of KMP3D](https://raw.githubusercontent.com/zach-zajack/kmp3d/master/KMP3D/images/screenshot.png)

## Installation
### For SketchUp 2013-2016
1. Download the `.rbz` file under [Releases](https://github.com/zach-zajack/kmp3d/releases).
2. In SketchUp, go to `Window` -> `Preferences` -> `Extensions` -> `Install Extension...`, and select the file.

### For SketchUp 2017+
1. Download the `.rbz` file under [Releases](https://github.com/zach-zajack/kmp3d/releases).
2. In SketchUp, go to `Window` -> `Extension Manager` -> `Install Extension...`, and select the file.

### For SketchUp 6-8
1. Download the `.rbz` file under [Releases](https://github.com/zach-zajack/kmp3d/releases).
2. Rename the `.rbz` extension to `.zip`.
3. Extract the contents of the folder into the `Plugins` folder in SketchUp's Program Files for Windows, or Applications folder for Mac.

## Usage and Features

### Adding and combining points
* Points can be added to the model by pointing and clicking in the desired area. If a given type of point is a vector, the second click determines what direction the point is facing in the horizontal (x-z) plane. Points will automatically take the settings from the previous point.
* Points of different types can be hybridized using the "Hybrid" option at the bottom of the list of types, allowing two or more points of different types to share the same model.
* Points can also be combined, similar to hybrid points. However, combining updates points that have previously been placed. This can be done by hovering over and clicking the previously placed point.
**Note:** the order of the point for either type will be at the time the former point was placed.

### Editing points
* Points can be translated, rotated, and scaled using any SketchUp tool or plugin. When exporting, KMP3D will automatically adjust for these changes.
* Settings can be edited through the use of input tables. These include group settings, which have their own tab for editing.
* Points can be selected and deselected either by clicking on the points in SketchUp, or in the input table's ID section. From here, any normal SketchUp operation can be done on them.

### Exporting KMP3D points
* Exporting KMP3D points can be done under `Plugins` -> `KMP3D` -> `Export WKMPT...`. Files can be converted through downloading and installing [Wiimm's SZS Tools](http://wiki.tockdom.com/wiki/Wiimms_SZS_Tools), and using the `wkmpt encode <filename>` command.

## Reference

### Point types
Point types are different classifications of coordinates, containing different information and settings within each type. These differences are listed below:

| ID   | Name            | Grouped | Model      | Supported Settings
|------|-----------------|---------|------------|--------------------
| KTPT | Start Positions | No      | Vector     | Player Index, Padding
| ENPT | Enemy Routes    | Yes     | Point      | Size, Settings 1 & 2
| ITPT | Item Routes     | Yes     | Point      | Size, Settings 1 & 2
| CKPT | Checkpoints     | Yes     | Checkpoint | Respawn ID, Type
| GOBJ | Objects         | Yes     | Custom     | Route, Settings 1-8, Flag
| POTI | Routes          | Yes     | Point      | Settings 1 & 2
| JGPT | Respawns        | No      | Vector     | Index, Range
| CNPT | Cannons         | No      | Vector     | Shoot Effect
| MSPT | End Positions   | No      | Vector     | Size
| STGI | Stage Info      | No      | N/A        | Lap Count, Pole Position, Driver Distance, Speed Modifier

## Future Plans
- Direct KMP importing/exporting
- Updated models
- Preview of paths
- Ability to reorder points
- Comprehensive database for GOBJ points and their settings
- Ability to import from WKMPT files
- CAME and AREA support
