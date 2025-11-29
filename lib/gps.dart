import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VistaMapa extends StatelessWidget {
  final double latitude;
  final double longitude;
  const VistaMapa({super.key, required this.latitude, required this.longitude});
  @override
  Widget build(BuildContext context) {
    final punto=LatLng(latitude, longitude);
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: punto,
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: punto,
                width: 60,
                height: 60,
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Volver al inicio',
            child: const Icon(Icons.home),
          ),
    );
  }
}
