import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Login extends StatefulWidget{
  const Login({super.key});
  @override
  _LoginState createState()=> _LoginState();
}

class _LoginState extends State<Login>{
  final _correoController=TextEditingController();
  final _contrasenaController=TextEditingController();

  Future<bool> validarUsuario() async {
    try{
      final url=Uri.parse('http://192.168.1.72:8000/login');
      final response=await http.post(
        url,
        headers: {'Content-Type':'application/json'},
        body: jsonEncode({
          'us_correo':_correoController.text.trim(),
          'us_password':_contrasenaController.text.trim(),
        }),
      );
      print('Codigo de estado: ${response.statusCode}');
      if(response.statusCode == 200){
        final datos=jsonDecode(response.body);
        final usuario=datos['usuario'];
        final id_us=usuario['id_us'];
        final nombre=usuario['us_nom'];
        final correo=datos['us_correo'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:Text('Bienvenido: $nombre')),
        );
        _correoController.clear();
        _contrasenaController.clear();
        Navigator.pushReplacementNamed(context,
        '/ver_paquetes',
        arguments:{
          'id_us':id_us,
          'us_nom':nombre,
          'us_correo':correo,
        },);
        return true;
      }else if(response.statusCode==401){
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content:Text('Correo o contraseña incorrectos')));
        return false;
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en el servidor')),
        );
        return false;
      }
    }catch(e){
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), 
        child: Container(
          decoration:const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF66D9BD),
                Color(0xFF66D996),
              ], //azul oscuro a medio
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Color(0xFFAED9CF),
            elevation: 0,
            title: const Text(
              'Inicio de sesion',
              style:TextStyle(color: Colors.black),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        decoration:const BoxDecoration(
          gradient: LinearGradient(
            colors: [
                Color(0xFF66D9BD),
                Color(0xFF66D996),
            ], //azul claro a azul oscuro
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child:SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child:Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _correoController,
                      decoration: InputDecoration(labelText: 'Correo', prefixIcon: Icon(Icons.email)),
                    ),
                    TextField(
                      controller: _contrasenaController,
                      decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: validarUsuario,
                      child: Text('Iniciar sesion'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}