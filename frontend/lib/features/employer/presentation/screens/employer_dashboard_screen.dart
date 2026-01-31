import 'package:flutter/material.dart';
import 'package:frontend/features/employer/data/employer_service.dart';
import 'package:frontend/features/auth/data/user_model.dart';
import 'package:frontend/features/employer/presentation/screens/candidate_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/presentation/auth_provider.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  final EmployerService _service = EmployerService();
  final TextEditingController _searchController = TextEditingController();
  List<User> _candidates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _search(''); 
  }

  Future<void> _search(String query) async {
    setState(() { _isLoading = true; });
    try {
      final candidates = await _service.searchCandidates(query);
      if (mounted) {
        setState(() { _candidates = candidates; });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
               Provider.of<AuthProvider>(context, listen: false).logout();
               Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Candidates',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search('');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _candidates.isEmpty 
                  ? const Center(child: Text("No candidates found."))
                  : ListView.builder(
                      itemCount: _candidates.length,
                      itemBuilder: (context, index) {
                        final user = _candidates[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text(user.email[0].toUpperCase())),
                            title: Text(user.email),
                            subtitle: const Text('Learner'),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => CandidateProfileScreen(userId: user.id))
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
