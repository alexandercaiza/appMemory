import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:java/GamePage.dart';
import 'login_screen.dart'; // Asegúrate de importar tu pantalla de login
import 'GamePage.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juego de Memoria'),
        actions: [
          // Botón de "Salir"
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        color: Colors.cyan[100], // Color de fondo celeste
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título con color negro
                Text(
                  'Juego de Memoria',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Título con color negro
                  ),
                ),
                SizedBox(height: 40), // Espacio entre el título y los botones

                // Animación para el botón "Jugar"
                SlideInButton(
                  onPressed: () {
                    _startGame(context);
                  },
                  text: 'Jugar',
                ),
                SizedBox(height: 10), // Espacio entre los botones

                // Animación para el botón "APIs"
                SlideInButton(
                  onPressed: () {
                    _openApis(context);
                  },
                  text: 'APIs',
                ),
                SizedBox(height: 10), // Espacio entre los botones

                // Animación para el botón "Salir"
                SlideInButton(
                  onPressed: () => _logout(context),
                  text: 'Salir',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para iniciar el juego
  void _startGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage()),
    );
  }

  // Función para acceder a las APIs
  void _openApis(BuildContext context) {
    print('Accediendo a las APIs');
    // Aquí puedes agregar la lógica para acceder a las APIs
  }

  // Función para cerrar sesión
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    // Vuelve a la pantalla de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen()), // Asegúrate de tener la pantalla LoginScreen
    );
  }
}

// Widget personalizado para la animación de los botones
class SlideInButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const SlideInButton({Key? key, required this.onPressed, required this.text})
      : super(key: key);

  @override
  _SlideInButtonState createState() => _SlideInButtonState();
}

class _SlideInButtonState extends State<SlideInButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1), // Duración de la animación
      curve: Curves.easeInOut, // Tipo de curva para suavizar la animación
      transform: Matrix4.translationValues(
          0, 0, 0), // Comienza desde la posición inicial
      child: ElevatedButton(
        onPressed: widget.onPressed,
        child: Text(widget.text,
            style:
                TextStyle(fontSize: 18)), // Aumentamos el tamaño de la fuente
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          backgroundColor:
              Colors.blue[200], // Color azul suave para el fondo del botón
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          textStyle: TextStyle(
              fontSize: 18), // Aumentamos el tamaño de la fuente en el botón
        ),
      ),
    );
  }
}
