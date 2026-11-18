import 'package:flutter/material.dart';

import '../../models/test_result.dart';
import '../../services/result_service.dart';
import 'admin_analytics_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _resultService = ResultService();
  final _searchController = TextEditingController();

  List<TestResult> _allResults = [];
  bool _loading = true;

  String _searchQuery = '';
  String? _selectedSchoolYear;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    final results = await _resultService.getResults();
    results.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _allResults = results;
      _loading = false;
    });
  }

  List<String> get _availableSchoolYears {
    final years = _allResults.map((r) => r.schoolYear).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<TestResult> get _filteredResults {
    return _allResults.where((r) {
      if (_selectedSchoolYear != null && r.schoolYear != _selectedSchoolYear) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchLastName = r.lastName.toLowerCase().contains(query);
        final matchFirstName = r.firstName.toLowerCase().contains(query);
        final matchFullName =
            '${r.firstName} ${r.lastName}'.toLowerCase().contains(query);
        if (!matchLastName && !matchFirstName && !matchFullName) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Analyser les résultats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAnalyticsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Rechercher par nom ou prénom',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedSchoolYear,
                    decoration: const InputDecoration(
                      labelText: 'Année scolaire',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Toutes les années'),
                      ),
                      for (final year in _availableSchoolYears)
                        DropdownMenuItem<String?>(
                          value: year,
                          child: Text(year),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSchoolYear = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('Aucun résultat trouvé'))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final result = filtered[index];
                              final candidateName =
                                  '${result.firstName} ${result.lastName}'
                                      .trim();
                              final name = candidateName.isEmpty
                                  ? result.email
                                  : candidateName;

                              return Card(
                                child: ListTile(
                                  title: Text(name),
                                  subtitle: Text(
                                    '${result.category} • ${result.schoolYear} • ${_formatDate(result.date)}',
                                  ),
                                  trailing: Text(
                                    '${result.score} / ${result.total}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
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