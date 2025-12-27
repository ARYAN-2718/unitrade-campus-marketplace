import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SafeZonesMap extends StatelessWidget {
  final LatLng campusCenter = const LatLng(31.7754, 76.9861); // IIT Mandi example

  final List<Map<String, dynamic>> safeZones = const [
    {
      'name': 'Main Library Entrance',
      'lat': 31.7759,
      'lng': 76.9872,
    },
    {
      'name': 'Student Activity Center',
      'lat': 31.7745,
      'lng': 76.9856,
    },
    {
      'name': 'Campus Security Office',
      'lat': 31.7762,
      'lng': 76.9849,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final markers = safeZones.map((zone) {
      return Marker(
        markerId: MarkerId(zone['name']),
        position: LatLng(zone['lat'], zone['lng']),
        infoWindow: InfoWindow(title: zone['name']),
      );
    }).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Safe Exchange Zones",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Meet only at verified, high-traffic campus locations for safety.",
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: campusCenter,
                zoom: 16,
              ),
              markers: markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.directions),
            label: const Text("Open in Google Maps"),
            onPressed: () async {
              final url =
                  "https://www.google.com/maps/search/?api=1&query=${campusCenter.latitude},${campusCenter.longitude}";
              if (await canLaunchUrl(Uri.parse(url))) {
                launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
      ],
    );
  }
}
