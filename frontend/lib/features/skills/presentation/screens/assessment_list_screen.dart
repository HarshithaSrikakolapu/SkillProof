import 'package:flutter/material.dart';
import 'package:frontend/features/skills/data/skill_model.dart';
import 'package:frontend/features/skills/data/assessment_service.dart';
import 'package:frontend/features/skills/presentation/screens/assessment_task_screen.dart';

class AssessmentListScreen extends StatefulWidget {
  final Skill skill;
  const AssessmentListScreen({super.key, required this.skill});

  @override
  State<AssessmentListScreen> createState() => _AssessmentListScreenState();
}

class _AssessmentListScreenState extends State<AssessmentListScreen> {
  final AssessmentService _service = AssessmentService();
  late Future<List<Assessment>> _assessmentsFuture;

  @override
  void initState() {
    super.initState();
    _assessmentsFuture = _service.getAssessments(widget.skill.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.skill.name} Assessments')),
      body: FutureBuilder<List<Assessment>>(
        future: _assessmentsFuture,
        builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return const Center(child: Text('No assessments found.'));
          }
          
          final assessments = snapshot.data!;
          return ListView.builder(
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              final item = assessments[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text("${item.difficultyLevel} • ${item.timeLimitMinutes} mins"),
                  trailing: FilledButton(
                    onPressed: () async {
                      try {
                         final uaId = await _service.startAssessment(item.id);
                         if (uaId != null && context.mounted) {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => AssessmentTaskScreen(
                             assessment: item,
                             userAssessmentId: uaId
                           )));
                         }
                      } catch (e) {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                         }
                      }
                    }, 
                    child: const Text('Start')
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
