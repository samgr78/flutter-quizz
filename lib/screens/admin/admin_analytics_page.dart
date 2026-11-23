import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/test_result.dart';
import '../../services/question_service.dart';
import '../../services/result_service.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  static const double _passThresholdPercent = 70.0;

  final _questionService = QuestionService();
  final _resultService = ResultService();

  bool _loading = true;
  String? _errorMessage;

  List<TestResult> _results = [];
  List<String> _availableYears = [];
  List<String> _disciplines = [];

  String? _selectedAcademicYear;
  String? _selectedDiscipline;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final questionsByCategory = await _questionService.getQuestions();
      final results = await _resultService.getResults();

      final Set<String> categories = {
        ...questionsByCategory.keys,
        ...results.map((r) => r.category),
      }..removeWhere((c) => c.trim().isEmpty);

      final sortedCategories = categories.toList()..sort();

      final Set<String> years = {
        ...results.map((r) => r.schoolYear),
      }..removeWhere((y) => y.trim().isEmpty);

      final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
      if (sortedYears.isEmpty) {
        sortedYears.add('2025-2026');
      }

      if (!mounted) return;
      setState(() {
        _results = results;
        _disciplines = sortedCategories;
        _availableYears = sortedYears;

        _selectedAcademicYear = sortedYears.contains(_selectedAcademicYear)
            ? _selectedAcademicYear
            : sortedYears.first;

        _selectedDiscipline = sortedCategories.contains(_selectedDiscipline)
            ? _selectedDiscipline
            : (sortedCategories.isNotEmpty ? sortedCategories.first : null);

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible de charger les statistiques : $e';
        _loading = false;
      });
    }
  }

  bool _isPassed(TestResult r) {
    if (r.total <= 0) return false;
    return ((r.score / r.total) * 100.0) >= _passThresholdPercent;
  }

  Map<String, double> _computeRates(Iterable<TestResult> items) {
    final validItems = items.where((r) => r.total > 0).toList();
    if (validItems.isEmpty) {
      return {'success': 0.0, 'failure': 0.0};
    }

    final passedCount = validItems.where(_isPassed).length;
    final successRate = (passedCount / validItems.length) * 100.0;
    final failureRate = 100.0 - successRate;

    return {'success': successRate, 'failure': failureRate};
  }

  Map<String, double> _getGlobalRates(String? year) {
    final filtered = _results.where((r) => year == null || r.schoolYear == year);
    return _computeRates(filtered);
  }

  Map<String, double> _getDisciplineRates(String? discipline, String? year) {
    if (discipline == null) {
      return {'success': 0.0, 'failure': 0.0};
    }
    final filtered = _results.where(
      (r) =>
          r.category == discipline && (year == null || r.schoolYear == year),
    );
    return _computeRates(filtered);
  }

  @override
  Widget build(BuildContext context) {
    final globalRates = _getGlobalRates(_selectedAcademicYear);
    final disciplineRates = _getDisciplineRates(
      _selectedDiscipline,
      _selectedAcademicYear,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse des résultats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _loadAnalyticsData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: ListTile(
                        title: const Text('Année scolaire'),
                        trailing: DropdownButton<String>(
                          value: _selectedAcademicYear,
                          items: _availableYears
                              .map(
                                (y) => DropdownMenuItem(value: y, child: Text(y)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedAcademicYear = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWide = constraints.maxWidth > 760;
                        final double cardWidth = isWide
                            ? math.min(380.0, (constraints.maxWidth - 32) / 2)
                            : math.min(380.0, constraints.maxWidth);

                        return Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPieCard(
                              width: cardWidth,
                              title:
                                  'Taux global (${_selectedAcademicYear ?? ''})',
                              successRate: globalRates['success']!,
                              failureRate: globalRates['failure']!,
                            ),
                            const SizedBox(height: 16, width: 16),
                            _buildPieCard(
                              width: cardWidth,
                              title:
                                  'Discipline : ${_selectedDiscipline ?? 'Aucune'}',
                              successRate: disciplineRates['success']!,
                              failureRate: disciplineRates['failure']!,
                              trailing: _disciplines.isEmpty
                                  ? null
                                  : DropdownButton<String>(
                                      value: _selectedDiscipline,
                                      items: _disciplines
                                          .map(
                                            (d) => DropdownMenuItem(
                                              value: d,
                                              child: Text(d),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(
                                            () => _selectedDiscipline = val,
                                          );
                                        }
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
    );
  }

  Widget _buildPieCard({
    required double width,
    required String title,
    required double successRate,
    required double failureRate,
    Widget? trailing,
  }) {
    final bool hasData = (successRate + failureRate) > 0;

    return SizedBox(
      width: width,
      height: 360,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: PieChartPainter(
                    successRate: successRate,
                    failureRate: failureRate,
                    trackColor: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasData
                    ? 'Réussite : ${successRate.toStringAsFixed(1)}% • Échec : ${failureRate.toStringAsFixed(1)}%'
                    : 'Aucune donnée disponible',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendIndicator(color: Colors.green, text: 'Réussite (≥70%)'),
                  SizedBox(width: 16),
                  _LegendIndicator(color: Colors.red, text: 'Échec (<70%)'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double successRate;
  final double failureRate;
  final Color trackColor;

  PieChartPainter({
    required this.successRate,
    required this.failureRate,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = math.min(size.width, size.height) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double strokeWidth = radius * 0.28;
    final double arcRadius = (radius * 0.8) - (strokeWidth / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: arcRadius);

    final double total = successRate + failureRate;

    if (total <= 0) {
      final Paint neutralPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor
        ..isAntiAlias = true;
      canvas.drawCircle(center, arcRadius, neutralPaint);
      return;
    }

    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    final double successAngle = (successRate / total) * 2 * math.pi;
    final double failureAngle = (failureRate / total) * 2 * math.pi;

    arcPaint.color = Colors.green;
    canvas.drawArc(rect, -math.pi / 2, successAngle, false, arcPaint);

    arcPaint.color = Colors.red;
    canvas.drawArc(
      rect,
      (-math.pi / 2) + successAngle,
      failureAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) =>
      oldDelegate.successRate != successRate ||
      oldDelegate.failureRate != failureRate ||
      oldDelegate.trackColor != trackColor;
}

class _LegendIndicator extends StatelessWidget {
  const _LegendIndicator({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}