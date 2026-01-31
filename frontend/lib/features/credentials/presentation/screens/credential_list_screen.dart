import 'package:flutter/material.dart';
import 'package:frontend/features/credentials/data/credential_model.dart';
import 'package:frontend/features/credentials/data/credential_service.dart';

class CredentialListScreen extends StatefulWidget {
  const CredentialListScreen({super.key});

  @override
  State<CredentialListScreen> createState() => _CredentialListScreenState();
}

class _CredentialListScreenState extends State<CredentialListScreen> {
  final CredentialService _service = CredentialService();
  late Future<List<Credential>> _credsFuture;

  @override
  void initState() {
    super.initState();
    _credsFuture = _service.getMyCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Credentials')),
      body: FutureBuilder<List<Credential>>(
        future: _credsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
           if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return const Center(child: Text('No credentials yet. Take some assessments!'));
          }
          
          final creds = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: creds.length,
            itemBuilder: (context, index) {
              final c = creds[index];
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.skillName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text("Level: ${c.level}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Score: ${c.score}%"),
                      const SizedBox(height: 8),
                      Text("Issued: ${c.issuedAt.split('T')[0]}"),
                      const SizedBox(height: 16),
                      Text("ID: ${c.id}", style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
