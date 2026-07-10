import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart';

/// The 12 Munro areas, each with its own completed/selected marker colour.
/// Must match the slugs used for the `completed-<slug>.svg` and
/// `selected-<slug>.svg` files in assets/munro-icons-svg/.
const List<String> munroAreas = [
  'Angus',
  'Argyll',
  'Cairngorms',
  'Fort William',
  'Islands',
  'Kintail',
  'Loch Lomond',
  'Loch Ness',
  'Perthshire',
  'Sutherland',
  'Torridon',
  'Ullapool',
];

String munroAreaSlug(String area) => area.toLowerCase().replaceAll(' ', '-');

/// Rasterizes an SVG asset into PNG bytes, for use as a Mapbox point
/// annotation image (which requires a raster image, not a vector one).
Future<Uint8List> loadSvgMarker(String assetPath, {int size = 100}) async {
  final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetPath), null);

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final scale = size / pictureInfo.size.width;
  canvas.scale(scale);
  canvas.drawPicture(pictureInfo.picture);
  final picture = recorder.endRecording();

  final image = await picture.toImage(size, size);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();

  pictureInfo.picture.dispose();
  picture.dispose();
  image.dispose();

  return bytes;
}

/// Loads the full set of area-coloured Munro marker icons: a single
/// uncompleted icon, plus a completed and selected icon per area.
class MunroMarkerIcons {
  final Uint8List uncompleted;
  final Map<String, Uint8List> completed;
  final Map<String, Uint8List> selected;

  const MunroMarkerIcons({
    required this.uncompleted,
    required this.completed,
    required this.selected,
  });

  static Future<MunroMarkerIcons> load({int size = 100}) async {
    final uncompleted = await loadSvgMarker('assets/munro-icons-svg/uncompleted.svg', size: size);

    final completed = <String, Uint8List>{};
    final selected = <String, Uint8List>{};
    for (final area in munroAreas) {
      final slug = munroAreaSlug(area);
      completed[slug] = await loadSvgMarker('assets/munro-icons-svg/completed-$slug.svg', size: size);
      selected[slug] = await loadSvgMarker('assets/munro-icons-svg/selected-$slug.svg', size: size);
    }

    return MunroMarkerIcons(uncompleted: uncompleted, completed: completed, selected: selected);
  }

  Uint8List completedFor(String area) => completed[munroAreaSlug(area)] ?? uncompleted;

  Uint8List selectedFor(String area) => selected[munroAreaSlug(area)] ?? uncompleted;
}
