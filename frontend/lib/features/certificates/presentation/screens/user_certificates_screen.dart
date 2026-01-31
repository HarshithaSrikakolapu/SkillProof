import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/features/certificates/data/certificate_model.dart';
import 'package:frontend/features/certificates/data/certificate_service.dart';
import 'package:intl/intl.dart';

class CertificateListScreen extends StatefulWidget {
  const CertificateListScreen({super.key});

  @override
  State<CertificateListScreen> createState() => _CertificateListScreenState();
}

class _CertificateListScreenState extends State<CertificateListScreen> {
  final CertificateService _service = CertificateService();
  List<Certificate> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  Future<void> _fetchCertificates() async {
    try {
      final certs = await _service.getCertificates();
      if (mounted) {
        setState(() {
          _certificates = certs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _showUploadDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController issuerController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    String? filePath;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Upload Certificate'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TextField(
                     controller: nameController,
                     decoration: const InputDecoration(labelText: 'Certificate Name'),
                   ),
                   const SizedBox(height: 12),
                   TextField(
                     controller: issuerController,
                     decoration: const InputDecoration(labelText: 'Issuing Organization'),
                   ),
                   const SizedBox(height: 12),
                   TextField(
                     controller: dateController,
                     decoration: const InputDecoration(
                       labelText: 'Issue Date (YYYY-MM-DD)', 
                       hintText: '2023-12-31'
                     ),
                   ),
                   const SizedBox(height: 16),
                   ElevatedButton.icon(
                     onPressed: () async {
                       final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
                       if (result != null) {
                         setStateDialog(() {
                            filePath = result.files.single.path;
                         });
                       }
                     },
                     icon: Icon(filePath == null ? Icons.upload_file : Icons.check),
                     label: Text(filePath == null ? 'Select File' : 'File Selected'),
                   ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                   if (filePath != null && nameController.text.isNotEmpty) {
                     Navigator.pop(context);
                     _upload(nameController.text, issuerController.text, dateController.text, filePath!);
                   }
                },
                child: const Text('Upload'),
              )
            ],
          );
        });
      },
    );
  }
  
  Future<void> _upload(String name, String issuer, String date, String path) async {
     setState(() { _isLoading = true; });
     try {
       await _service.uploadCertificate(name: name, issuer: issuer, issueDate: date, filePath: path);
       await _fetchCertificates();
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded!')));
     } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
       setState(() { _isLoading = false; });
     }
  }

  Future<void> _delete(int id) async {
     try {
       await _service.deleteCertificate(id);
       _fetchCertificates();
     } catch (e) {
       // ignore
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Certificates')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _certificates.isEmpty 
            ? const Center(child: Text('No certificates uploaded yet.'))
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _certificates.length,
              itemBuilder: (context, index) {
                final cert = _certificates[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(cert.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${cert.issuer} • ${cert.issueDate}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => _delete(cert.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        label: const Text('Upload'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
