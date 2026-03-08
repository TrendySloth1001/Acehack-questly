import 'dart:math';

/// Centralized map configuration — dark CartoDB tiles.
class MapConstants {
  MapConstants._();

  /// Dark tile provider (CartoDB Dark Matter) — free, no API key.
  static const String darkTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

  static const List<String> subdomains = ['a', 'b', 'c', 'd'];

  /// Convert a radius in kilometers to degrees latitude (approximate).
  static double kmToLatDegrees(double km) => km / 111.32;

  /// Zoom level that roughly fits a given radius (km) on screen.
  static double zoomForRadius(double radiusKm) {
    // At zoom 15, ~1.5 km fits on a phone screen width.
    // Each zoom level doubles the coverage.
    const baseZoom = 15.0;
    const baseRadiusKm = 1.5;
    final ratio = radiusKm / baseRadiusKm;
    return baseZoom - (log(ratio) / ln2);
  }
}
