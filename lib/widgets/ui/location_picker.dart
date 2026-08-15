import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

const _nominatimUserAgent = 'FoodRescueSync/1.0 (student project)';
const _dhakaFallback = LatLng(23.81, 90.41);

typedef PickedLocation = ({double lat, double lng, String address});
typedef _SearchResult = ({double lat, double lng, String label});

/// Great-circle distance between two coordinates, in kilometers.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLng = _degToRad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degToRad(double deg) => deg * (math.pi / 180);

/// Opens a full-screen map (OpenStreetMap tiles via flutter_map) letting
/// the user search an address or tap the map directly to pick a point.
/// Returns null if the user backs out without confirming.
Future<PickedLocation?> pickLocation(
  BuildContext context, {
  LatLng? initial,
  String? initialAddress,
}) {
  return Navigator.of(context).push<PickedLocation>(
    MaterialPageRoute(
      builder: (_) => _LocationPickerPage(initial: initial, initialAddress: initialAddress),
    ),
  );
}

class _LocationPickerPage extends StatefulWidget {
  final LatLng? initial;
  final String? initialAddress;
  const _LocationPickerPage({this.initial, this.initialAddress});

  @override
  State<_LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<_LocationPickerPage> {
  final _mapController = MapController();
  final _searchCtrl = TextEditingController();
  LatLng? _picked;
  String? _address;
  bool _resolvingAddress = false;
  bool _searching = false;
  List<_SearchResult> _results = [];
  Timer? _debounce;
  int _searchToken = 0;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
    _address = widget.initialAddress;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Live, debounced search-as-you-type — fires ~500ms after the user
  /// stops typing (and only once at least 3 characters are entered) so we
  /// don't hammer Nominatim's free tier on every keystroke.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(value));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    final token = ++_searchToken;
    setState(() {
      _searching = true;
      _results = [];
    });
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(query)}&format=json&limit=5&accept-language=en',
      );
      final response = await http.get(uri, headers: {'User-Agent': _nominatimUserAgent});
      if (!mounted || token != _searchToken) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _results = data
              .map((r) => (
                    lat: double.parse(r['lat'] as String),
                    lng: double.parse(r['lon'] as String),
                    label: r['display_name'] as String,
                  ))
              .toList();
        });
      } else {
        _showError('Search failed. Please try again.');
      }
    } catch (_) {
      if (mounted) _showError('Could not reach the search service. Check your connection.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _resolvingAddress = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json&accept-language=en',
      );
      final response = await http.get(uri, headers: {'User-Agent': _nominatimUserAgent});
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() => _address = data['display_name'] as String? ?? _fallbackLabel(point));
      } else {
        setState(() => _address = _fallbackLabel(point));
      }
    } catch (_) {
      if (mounted) setState(() => _address = _fallbackLabel(point));
    } finally {
      if (mounted) setState(() => _resolvingAddress = false);
    }
  }

  String _fallbackLabel(LatLng point) => 'Pinned location (${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)})';

  void _selectResult(_SearchResult result) {
    _debounce?.cancel();
    final point = LatLng(result.lat, result.lng);
    setState(() {
      _picked = point;
      _address = result.label;
      _results = [];
      _searchCtrl.clear();
    });
    _mapController.move(point, 15);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _picked = point;
      _results = [];
    });
    _reverseGeocode(point);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: const Color(0xFFDC2626)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final center = _picked ?? widget.initial ?? _dhakaFallback;

    return Scaffold(
      appBar: AppBar(title: const Text('Set Location')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search an English address...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                    : IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () => _search(_searchCtrl.text)),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          if (_results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(_results[i].label, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => _selectResult(_results[i]),
                ),
              ),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.foodrescue.sync',
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
                if (_picked != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _picked!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Color(0xFFE53238), size: 40),
                    ),
                  ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resolvingAddress
                        ? 'Resolving address...'
                        : (_address ?? (_picked == null ? 'Tap the map or search to pick a location' : _fallbackLabel(_picked!))),
                    style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _picked == null
                          ? null
                          : () => Navigator.of(context).pop((
                                lat: _picked!.latitude,
                                lng: _picked!.longitude,
                                address: _address ?? _fallbackLabel(_picked!),
                              )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Confirm Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
