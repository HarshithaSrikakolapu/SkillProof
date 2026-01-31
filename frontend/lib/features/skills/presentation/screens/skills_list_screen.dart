import 'package:flutter/material.dart';
import 'package:frontend/features/skills/data/assessment_service.dart';
import 'package:frontend/features/skills/data/skill_model.dart';
import 'package:frontend/features/skills/presentation/screens/assessment_list_screen.dart';

class SkillsListScreen extends StatefulWidget {
  const SkillsListScreen({super.key});

  @override
  State<SkillsListScreen> createState() => _SkillsListScreenState();
}

class _SkillsListScreenState extends State<SkillsListScreen> {
  final AssessmentService _assessmentService = AssessmentService();
  List<Skill> _skills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  Future<void> _fetchSkills() async {
    try {
      final skills = await _assessmentService.getSkills();
      if (mounted) {
        setState(() {
          _skills = skills;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load skills: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skills', style: Theme.of(context).textTheme.titleLarge),
            Text('Validate your real-world abilities', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_membership, color: Color(0xFF6C63FF)),
            onPressed: () => Navigator.pushNamed(context, '/credentials'),
            tooltip: 'My Credentials',
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: Color(0xFF6C63FF)),
            onPressed: () => Navigator.pushNamed(context, '/user_certificates'),
            tooltip: 'Upload Certs',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Color(0xFF6C63FF)),
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
            tooltip: 'Stats',
          ),
          IconButton(
             icon: const Icon(Icons.logout, color: Colors.redAccent),
             onPressed: () {
               // Show confirmation dialog
               showDialog(
                 context: context,
                 builder: (context) => AlertDialog(
                   title: const Text('Logout'),
                   content: const Text('Are you sure you want to logout?'),
                   actions: [
                     TextButton(
                       onPressed: () => Navigator.pop(context),
                       child: const Text('Cancel'),
                     ),
                     TextButton(
                       onPressed: () {
                         Navigator.pop(context); // Close dialog
                         // Perform logout
                         Navigator.pushReplacementNamed(context, '/login');
                       },
                       child: const Text('Logout', style: TextStyle(color: Colors.red)),
                     ),
                   ],
                 ),
               );
             },
             tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSkills,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _skills.isEmpty 
              ? const Center(child: Text("No skills available yet."))
              : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _skills.length,
              itemBuilder: (context, index) {
                final skill = _skills[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssessmentListScreen(skill: skill),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Card(
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  skill.name.isNotEmpty ? skill.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    skill.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    skill.description ?? 'No description available.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchSkills,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
