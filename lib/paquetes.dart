import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VerPaquetes extends StatefulWidget {
  const VerPaquetes({super.key});
  @override
  _VerPaquetesState createState() => _VerPaquetesState();
}

class _VerPaquetesState extends State<VerPaquetes> {
  List<dynamic> paquetes = [];
  bool isLoading = true;
  int? id_us;
  String? us_nom;
  final ImagePicker _picker = ImagePicker();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      id_us = args['id_us'];
      us_nom = args['us_nom'];
    }
    if (id_us != null) {
      cargarPaquetes();
    }
  }

  Future<void> cargarPaquetes() async {
    if (id_us == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse('http://192.168.1.72:8000/mostrar/paquetes/$id_us');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          paquetes = jsonDecode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          isLoading = false;
          paquetes = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se encontraron paquetes")),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar los paquetes:${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexion: $e')));
    }
  }

  Future<bool> _solicitarPermisos() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
    ].request();
    bool cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    bool locationGranted = statuses[Permission.location]?.isGranted ?? false;
    if (!cameraGranted || !locationGranted) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se necesitan permisos de camara y ubicacion'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<Position?> _obtenerUbicacion() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activa los servicios de ubicacion')),
        );
        return null;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Ubicacion:${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error obteniendo ubicacion: $e')));
      return null;
    }
  }

  Future<void> _tomarFoto(int id_paq) async {
    try {
      bool permisosOk = await _solicitarPermisos();
      if (!permisosOk) return;
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (foto == null) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se tomo ninguna foto')),
        );
        return;
      }
      Position? position = await _obtenerUbicacion();
      if (position == null) {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }
      Navigator.pop(context);
    _mostrarPreviewEntrega(id_paq, foto, position);
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
  }


    //   await _enviarEntrega(id_paq, foto, position);
    //   if (!mounted) return;
    //   Navigator.pop(context);
    // } catch (e) {
    //   if (!mounted) return;
    //   Navigator.pop(context);
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Error:$e')));
    // }
  }
  void _mostrarPreviewEntrega(int id_paq, XFile foto, Position pos) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Confirmar entrega",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Foto tomada
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(foto.path),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),

            // MAPA OPENSTREETMAP
            SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(pos.latitude, pos.longitude),
                  zoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.jpg?key=Eh0TEfB10qbbG3j2Zrk9",
                    userAgentPackageName: "com.example.app",
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(pos.latitude, pos.longitude),
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.location_pin,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // BOTÓN CONFIRMAR
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // cierra el modal
                _enviarEntrega(id_paq, foto, pos);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text(
                "Confirmar entrega",
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Future<void> _enviarEntrega(int id_paq, XFile foto, Position position) async {
    try {
      final url = Uri.parse("http://192.168.1.72:8000/registro/entrega");
      var request = http.MultipartRequest('POST', url);
      request.fields['id_paq'] = id_paq.toString();
      request.fields['en_latitud'] = position.latitude.toString();
      request.fields['en_longitud'] = position.longitude.toString();
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          foto.path,
          filename: 'entrega_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      print('Paquete: $id_paq');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final datos = jsonDecode(responseBody);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${datos['mensaje']}'),
            backgroundColor: Colors.green,
          ),
        );
        cargarPaquetes();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${response.statusCode}:$responseBody'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error enviando a API: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error enviando datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cerrarSesion() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66D9BD), Color(0xFF66D996)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFFAED9CF),
            elevation: 0,
            title: Text(
              us_nom != null ? 'Paquetes de $us_nom' : 'Lista de paquetes',
              style: const TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black),
                tooltip: "Cerrar sesión",
                onPressed: () {
                  _cerrarSesion();
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF66D9BD), Color(0xFF66D996)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : paquetes.isEmpty
            ? const Center(
                child: Text(
                  'No hay entregas por ahora',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: paquetes.length,
                itemBuilder: (context, index) {
                  final paquete = paquetes[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF00439B),
                        child: Text(
                          '${paquete['id_paq']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        paquete['paq_nom'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Direccion: ${paquete['paq_dir']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              color: Color(0xFF00439B),
                              size: 28,
                            ),
                            onPressed: () {
                              _tomarFoto(paquete['id_paq']);
                            },
                            tooltip: 'Registrar entrega',
                          ),
                          const Icon(
                            Icons.local_shipping,
                            color: Color(0xFF00439B),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
