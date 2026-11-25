import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Guide'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ExpansionTile(
            leading: Icon(Icons.login, color: Color(0xFF0D9488)),
            title: Text('Kaise Login karein?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  '1. Welcome screen par "Log in" button par click karein.\n'
                  '2. Apna registered Email Address aur Password likhein.\n'
                  '3. "Log In" button dabakar app ke andar enter ho jayein.',
                  style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ExpansionTile(
            leading: Icon(Icons.support_agent, color: Color(0xFF0D9488)),
            title: Text('Medical AI Assistant ko kaise use karein?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Login karne ke baad aap chat interface par apni health ya medical query type kar sakte hain. AI aapko foran behtareen medical insights aur information provide karega.',
                  style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ExpansionTile(
            leading: Icon(Icons.security, color: Color(0xFF0D9488)),
            title: Text('Kya mera data safe hai?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Bilkul! Aapka tamam medical data aur queriesfully encrypted aur secure rakhi jati hain.',
                  style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

