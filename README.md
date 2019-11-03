# KMP3D
KMP3D is a [Google SketchUp](https://www.sketchup.com/) plugin that functions as a 3D interface for [Mario Kart Wii](https://en.wikipedia.org/wiki/Mario_Kart_Wii)'s [KMP](http://wiki.tockdom.com/wiki/KMP) files, which deal with coordinate information, such as checkpoints, item routes, or respawn positions. Points are represented using spheres and vectors, depending on the point type.

## Installation
update later

## Usage and Features

### Adding points
Points can be added to the model by pointing and clicking in the desired area. If a given type of point is a vector, the second click determines what direction the point is facing in the horizontal (x-z) plane.

### Combining points
Points can similarly be combined, if points are different types. This can be done by hovering over a point of a different type and clicking on it.
**Note:** the order of the point for either type will be at the time the former point was placed.

### Translating, rotating, and scaling points
Points can be translated, rotated, and scaled using any SketchUp tool or plugin. When exporting, KMP3D will automatically adjust for these changes.

### Editing settings
Settings can be edited through the use of input tables. Settings mostly follow [KMP Cloud](http://wiki.tockdom.com/wiki/KMP_Cloud)'s naming and organization.

### Selecting points
Points can be selected and deselected either by clicking on the points in SketchUp, or in the input table's ID section. From here, any normal SketchUp operation can be done on them.

### Adding or removing groups
Groups allow certain points to be classified as certain paths, if the type allows for it. Groups can be added from the `Add group` button, and removed with the `X` button under the `Group settings` tab.

### Editing groups
Editing groups can be done under the `Group settings` tab.

### Split paths
One common use for groups is for split paths. For example, split paths for item routes would result in 3 routes: one for the main road, `G0`, and two for each different path in the split, `G1` and `G2`. These can then be joined with `G0`'s `Next Group` parameter as `G1, G2`, and `G1` and `G2`'s parameters as `G0`.

### Exporting KMP3D points
WKMPT files are essentially an intermediary file type used by [Wiimm's SZS Tools](http://wiki.tockdom.com/wiki/Wiimms_SZS_Tools). Exporting KMP3D points can be done under `Plugins` -> `KMP3D` -> `Export WKMPT...`. Files can be converted through downloading and installing [Wiimm's SZS Tools](http://wiki.tockdom.com/wiki/Wiimms_SZS_Tools), and using the `wkmpt encode <filename>` command.

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
- Replace textboxes with other input types, e.g. checkboxes or dropdowns
- Ability to import from WKMPT files
- Comprehensive database for GOBJ points and their settings
- CAME and AREA support
- Ability to reorder points
- Preview of paths
- Updated models
- Direct KMP exporting
