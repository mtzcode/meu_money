import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Money'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bem-vindo, ${user?.email ?? 'Usuário'}!',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
