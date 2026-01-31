import 'package:flutter/material.dart';
import 'package:frontend/features/skills/data/skill_model.dart';
import 'package:frontend/features/skills/data/assessment_service.dart';
import 'package:file_picker/file_picker.dart';

class AssessmentTaskScreen extends StatefulWidget {
  final Assessment assessment;
  final int userAssessmentId;

  const AssessmentTaskScreen({super.key, required this.assessment, required this.userAssessmentId});

  @override
  State<AssessmentTaskScreen> createState() => _AssessmentTaskScreenState();
}

class _AssessmentTaskScreenState extends State<AssessmentTaskScreen> {
  final AssessmentService _service = AssessmentService();
  final _githubController = TextEditingController();
  final _answerController = TextEditingController();
  
  List<String> _selectedFiles = [];
  bool _isSubmitting = false;

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.whereType<String>().toList();
      });
    }
  }

  Future<void> _submit() async {
    setState(() { _isSubmitting = true; });
    try {
      await _service.submitAssessment(
        widget.userAssessmentId, 
        {
          'text_answer': _answerController.text,
          'github_link': _githubController.text,
        },
        filePaths: _selectedFiles
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission Successful!')));
        Navigator.pop(context); // Go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract description/task from content JSON if possible, otherwise use generic description
    // For now assuming content has 'questions' list
    final content = widget.assessment.content;

    return Scaffold(
      appBar: AppBar(title: Text(widget.assessment.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructions', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(widget.assessment.description),
            const SizedBox(height: 16),
            const Divider(),
            
            Text('Your Answer', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
             TextField(
              controller: _answerController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type your explanation or code here...',
              ),
            ),
             const SizedBox(height: 16),

             Text('GitHub/Project Link', style: Theme.of(context).textTheme.titleMedium),
             const SizedBox(height: 8),
             TextField(
              controller: _githubController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://github.com/user/repo',
                prefixIcon: Icon(Icons.link)
              ),
            ),

            const SizedBox(height: 16),
            Text('Evidence (Screenshots/Videos/Code)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Files'),
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._selectedFiles.map((f) => Text(f.split('/').last)).toList(), // Display filenames
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('Submit Assessment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
