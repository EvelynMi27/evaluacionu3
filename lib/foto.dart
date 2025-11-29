import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FotoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FotoPage extends StatefulWidget {
  const FotoPage({super.key});
  @override
  _FotoPageState createState() => _FotoPageState();
}

class _FotoPageState extends State<FotoPage> {
  Uint8List? _imageBytes;
  XFile? _pickedFile;
  final picker = ImagePicker();
  final descripcionController = TextEditingController();
  String? uploadedImageUrl;
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _pickedFile = pickedFile;
      });
      print("Foto tomada:${pickedFile.name}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto tomada correctamente")),
      );
    } else {
      print("No se tomo una foto");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No se tomo ninguna foto")));
    }
  }

  Future subirFoto() async {
    if (_pickedFile == null || _imageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Primero toma una foto")));
      return;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/fotos/'),
    );
    request.fields['descripcion'] = descripcionController.text;
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        _imageBytes!,
        filename: _pickedFile!.name,
      ),
    );
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      var data = json.decode(respStr);
      setState(() {
        uploadedImageUrl = data['foto']['ruta_foto'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto subida correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("Error al subir la foto: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al subir la foto"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Widget mostrarImagenLocal(){
    if(_imageBytes==null) return const Text("No hay imagen seleccionada");
    return Image.memory(_imageBytes!, width: 300);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text("Subir Foto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            mostrarImagenLocal(),
            const SizedBox(height: 10),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: getImage, child: const Text("Tomar foto")),
            ElevatedButton(onPressed: subirFoto, child: const Text("Subir a API")),
          ],
        ),
      ),
    );    
  }
}
