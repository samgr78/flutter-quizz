import 'package:flutter/material.dart';
import '../../models/test_result.dart';
import '../../services/result_service.dart';

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
    // Tri décroissant par date 
    results.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _allResults = results;
      _loading = false;
    });
  }

  // Liste unique des années scolaires triées par ordre décroissant
  List<String> get _availableSchoolYears {
    final years = _allResults.map((r) => r.schoolYear).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  // Filtrage combiné (Recherche Nom/Prénom + Année scolaire)
  List<TestResult> get _filteredResults {
    return _allResults.where((r) {
      //Filtre par Année scolaire
      if (_selectedSchoolYear != null && r.schoolYear != _selectedSchoolYear) {
        return false;
      }

      //Filtre par recherche Nom / Prénom
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchLastName = r.lastName.toLowerCase().contains(query);
        final matchFirstName = r.firstName.toLowerCase().contains(query);
        final matchFullName = '${r.firstName} ${r.lastName}'.toLowerCase().contains(query);
        if (!matchLastName && !matchFirstName && !matchFullName) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () {
              setState(() => _loading = true);
              _loadResults();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                //Indicateurs de performances générales
                _buildSummaryCards(),

                //Zone de Filtres (Recherche Nom/Prénom + Année scolaire)
                _buildFilterBar(),

                const Divider(height: 1),

                //Liste des résultats des candidats
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun résultat correspondant',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final result = filtered[index];
                            return _buildResultCard(result);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Cartes de statistiques globales
  Widget _buildSummaryCards() {
    if (_allResults.isEmpty) return const SizedBox.shrink();

    final totalTests = _allResults.length;
    final totalScore = _allResults.fold<int>(0, (sum, r) => sum + r.score);
    final totalQuestions = _allResults.fold<int>(0, (sum, r) => sum + r.total);
    final avgPercentage = totalQuestions > 0 ? (totalScore / totalQuestions) * 100 : 0.0;
    final uniqueCandidates = _allResults.map((r) => r.email).toSet().length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Row(
        children: [
          _buildStatCard('Tests passés', '$totalTests', Icons.assignment_outlined),
          _buildStatCard('Moyenne globale', '${avgPercentage.toStringAsFixed(1)} %', Icons.analytics_outlined),
          _buildStatCard('Candidats', '$uniqueCandidates', Icons.people_outline),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Barre de filtres : recherche textuelle et sélection d'année
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Recherche par Nom ou Prénom
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher un candidat (Nom / Prénom)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
            },
          ),
          const SizedBox(height: 8),

          // Menu déroulant pour l'Année Scolaire
          DropdownButtonFormField<String?>(
            value: _selectedSchoolYear,
            decoration: const InputDecoration(
              labelText: 'Année scolaire',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        ],
      ),
    );
  }


  Widget _buildResultCard(TestResult result) {
    final candidateName = '${result.firstName} ${result.lastName}'.trim();
    final displayName = candidateName.isEmpty ? result.email : candidateName;
    final percentage = result.percentage;


    final badgeColor = percentage >= 70
        ? Colors.green
        : percentage >= 50
            ? Colors.orange
            : Colors.red;

    final dateFormatted =
        '${result.date.day.toString().padLeft(2, '0')}/${result.date.month.toString().padLeft(2, '0')}/${result.date.year} à ${result.date.hour.toString().padLeft(2, '0')}:${result.date.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '${result.score}/${result.total}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Détails du candidat et du quiz
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Quiz : ${result.category}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        dateFormatted,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          result.schoolYear,
                          style: const TextStyle(fontSize: 10),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}