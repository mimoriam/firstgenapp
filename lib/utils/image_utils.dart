import 'package:flutter_svg/flutter_svg.dart';

class ImageUtils {
  static const String peopleBgSVG = 'images/backgrounds/people_bg.svg';
  static void svgPrecacheImage() {
    const cacheSvgImages = [ImageUtils.peopleBgSVG];

    for (String element in cacheSvgImages) {
      var loader = SvgAssetLoader(element);
      svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  }
}
