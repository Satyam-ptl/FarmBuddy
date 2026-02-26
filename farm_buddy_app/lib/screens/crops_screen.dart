import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../services/api_service.dart';
import '../services/localization_service.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  List<Crop> crops = [];
  List<Map<String, dynamic>> recommendations = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedSeason = 'All';
  String selectedSoil = 'All';
  String selectedState = '';
  final TextEditingController stateController = TextEditingController();
  final TextEditingController landAreaController = TextEditingController(text: '1');

  int? compareCropAId;
  int? compareCropBId;
  int? calculatorCropId;

  double? calculatedSeedKg;
  double? calculatedFertilizerKg;
  double? calculatedWaterLiters;
  String? calculatorError;

  final List<String> seasons = ['All', 'Kharif', 'Rabi', 'Summer'];
  final List<String> soils = ['All', 'Clay', 'Sandy', 'Loamy', 'Mixed'];

  @override
  void initState() {
    super.initState();
    loadCrops();
  }

  Future<void> loadCrops() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getCrops(
        season: selectedSeason == 'All' ? null : selectedSeason,
        soilType: selectedSoil == 'All' ? null : selectedSoil,
        state: selectedState.isEmpty ? null : selectedState,
        pageSize: 100,
      );

      final List<dynamic> cropsJson = (response['results'] as List<dynamic>? ?? []);
      final loadedCrops = cropsJson
          .map((json) => Crop.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      if (loadedCrops.isNotEmpty) {
        compareCropAId ??= loadedCrops.first.id;
        compareCropBId ??= loadedCrops.length > 1 ? loadedCrops[1].id : loadedCrops.first.id;
        calculatorCropId ??= loadedCrops.first.id;
      }

      setState(() {
        crops = loadedCrops;
        isLoading = false;
      });

      await loadRecommendations();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load crops: $e';
        isLoading = false;
      });
    }
  }

  Future<void> loadRecommendations() async {
    if (selectedSeason == 'All') {
      setState(() {
        recommendations = [];
      });
      return;
    }

    try {
      final recs = await ApiService.getCropRecommendations(
        selectedSeason,
        soilType: selectedSoil == 'All' ? null : selectedSoil,
        state: selectedState.isEmpty ? null : selectedState,
      );

      setState(() {
        recommendations = recs
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      });
    } catch (_) {
      setState(() {
        recommendations = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.tr('Crops')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadCrops,
            tooltip: LocalizationService.tr('Refresh'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  '${LocalizationService.tr('Season')}: ',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSeason,
                    isExpanded: true,
                    items: seasons
                        .map((season) => DropdownMenuItem(value: season, child: Text(season)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSeason = value!;
                      });
                      loadCrops();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text(
                  '${LocalizationService.tr('Soil')}: ',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSoil,
                    isExpanded: true,
                    items: soils
                        .map((soil) => DropdownMenuItem(value: soil, child: Text(soil)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSoil = value!;
                      });
                      loadCrops();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: stateController,
                    decoration: const InputDecoration(
                      hintText: 'State filter (e.g. Maharashtra)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        selectedState = value.trim();
                      });
                      loadCrops();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedState = stateController.text.trim();
                      });
                      loadCrops();
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
          if (recommendations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService.tr('Recommendations'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendations.length > 8 ? 8 : recommendations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final rec = recommendations[index];
                        return Chip(label: Text(rec['crop_name']?.toString() ?? ''));
                      },
                    ),
                  ),
                ],
              ),
            ),
          _buildCompareSection(),
          _buildInputCalculatorSection(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: loadCrops,
                              child: Text(LocalizationService.tr('Retry')),
                            ),
                          ],
                        ),
                      )
                    : crops.isEmpty
                        ? Center(child: Text(LocalizationService.tr('No crops found')))
                        : RefreshIndicator(
                            onRefresh: loadCrops,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: crops.length,
                              itemBuilder: (context, index) {
                                final crop = crops[index];
                                return _buildCropCard(crop);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(Crop crop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showCropDetails(crop),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      crop.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Chip(
                    label: Text(crop.season),
                    backgroundColor: _getSeasonColor(crop.season),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.terrain, size: 16, color: Colors.brown),
                  const SizedBox(width: 4),
                  Text('${LocalizationService.tr('Soil')}: ${crop.soilType}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('Duration: ${crop.growthDurationDays} days'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.agriculture, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('Yield: ${crop.expectedYieldPerHectare} kg/hectare'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeasonColor(String season) {
    switch (season) {
      case 'Kharif':
        return Colors.green.shade100;
      case 'Rabi':
        return Colors.orange.shade100;
      case 'Summer':
        return Colors.yellow.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Crop? _findCropById(int? cropId) {
    if (cropId == null) return null;
    for (final crop in crops) {
      if (crop.id == cropId) return crop;
    }
    return null;
  }

  double _seedRatePerHectare(String cropName) {
    final name = cropName.toLowerCase();
    if (name.contains('rice')) return 45;
    if (name.contains('wheat')) return 100;
    if (name.contains('maize') || name.contains('corn')) return 20;
    if (name.contains('cotton')) return 20;
    if (name.contains('soy')) return 75;
    if (name.contains('mustard')) return 6;
    if (name.contains('groundnut') || name.contains('peanut')) return 130;
    return 40;
  }

  double _fertilizerRatePerHectare(Crop crop) {
    final hint = crop.fertilizerRequired.toLowerCase();
    if (hint.contains('high')) return 220;
    if (hint.contains('medium')) return 150;
    if (hint.contains('low')) return 90;
    return 140;
  }

  void _calculateInputs() {
    final area = double.tryParse(landAreaController.text.trim());
    final crop = _findCropById(calculatorCropId);

    if (area == null || area <= 0 || crop == null) {
      setState(() {
        calculatorError = 'Enter valid land area and crop.';
        calculatedSeedKg = null;
        calculatedFertilizerKg = null;
        calculatedWaterLiters = null;
      });
      return;
    }

    final seedKg = _seedRatePerHectare(crop.name) * area;
    final fertilizerKg = _fertilizerRatePerHectare(crop) * area;
    final totalGrowthWeeks = crop.growthDurationDays / 7.0;
    final totalWaterMm = crop.waterRequiredMmPerWeek * totalGrowthWeeks;
    final waterLiters = totalWaterMm * area * 10000;

    setState(() {
      calculatorError = null;
      calculatedSeedKg = seedKg;
      calculatedFertilizerKg = fertilizerKg;
      calculatedWaterLiters = waterLiters;
    });
  }

  Widget _buildCompareSection() {
    if (crops.isEmpty) {
      return const SizedBox.shrink();
    }

    final cropA = _findCropById(compareCropAId);
    final cropB = _findCropById(compareCropBId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Compare Crops',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      value: compareCropAId,
                      isExpanded: true,
                      items: crops
                          .map((crop) => DropdownMenuItem<int>(
                                value: crop.id,
                                child: Text(crop.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          compareCropAId = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<int>(
                      value: compareCropBId,
                      isExpanded: true,
                      items: crops
                          .map((crop) => DropdownMenuItem<int>(
                                value: crop.id,
                                child: Text(crop.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          compareCropBId = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (cropA != null && cropB != null) ...[
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Metric')),
                      DataColumn(label: Text(cropA.name)),
                      DataColumn(label: Text(cropB.name)),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('Season')),
                        DataCell(Text(cropA.season)),
                        DataCell(Text(cropB.season)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Soil')),
                        DataCell(Text(cropA.soilType)),
                        DataCell(Text(cropB.soilType)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Duration (days)')),
                        DataCell(Text('${cropA.growthDurationDays}')),
                        DataCell(Text('${cropB.growthDurationDays}')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Yield (kg/ha)')),
                        DataCell(Text(cropA.expectedYieldPerHectare.toStringAsFixed(1))),
                        DataCell(Text(cropB.expectedYieldPerHectare.toStringAsFixed(1))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Water (mm/week)')),
                        DataCell(Text(cropA.waterRequiredMmPerWeek.toStringAsFixed(1))),
                        DataCell(Text(cropB.waterRequiredMmPerWeek.toStringAsFixed(1))),
                      ]),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCalculatorSection() {
    if (crops.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Input Calculator',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: calculatorCropId,
                isExpanded: true,
                items: crops
                    .map((crop) => DropdownMenuItem<int>(
                          value: crop.id,
                          child: Text(crop.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    calculatorCropId = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: landAreaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Land area (hectares)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateInputs,
                  child: const Text('Calculate Inputs'),
                ),
              ),
              if (calculatorError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(calculatorError!, style: const TextStyle(color: Colors.red)),
                ),
              if (calculatedSeedKg != null &&
                  calculatedFertilizerKg != null &&
                  calculatedWaterLiters != null) ...[
                const SizedBox(height: 8),
                Text('Seeds needed: ${calculatedSeedKg!.toStringAsFixed(1)} kg'),
                Text('Fertilizer needed: ${calculatedFertilizerKg!.toStringAsFixed(1)} kg'),
                Text('Water needed: ${calculatedWaterLiters!.toStringAsFixed(0)} liters'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCropDetails(Crop crop) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${crop.name} - ${LocalizationService.tr('Crop Guide')}'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: ApiService.getCropDetail(crop.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snapshot.data!;
            final guides = (data['guides'] as List<dynamic>? ?? []);
            final guide = guides.isNotEmpty
                ? Map<String, dynamic>.from(guides.first as Map)
                : <String, dynamic>{};

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow(LocalizationService.tr('Season'), crop.season),
                  _buildDetailRow(LocalizationService.tr('Soil'), crop.soilType),
                  _buildDetailRow(LocalizationService.tr('Temperature'), '${crop.optimalTemperatureMax}°C'),
                  _buildDetailRow(
                    LocalizationService.tr('Watering'),
                    guide['watering_schedule']?.toString() ?? '-',
                  ),
                  _buildDetailRow(
                    LocalizationService.tr('Fertilizer'),
                    guide['fertilizer_schedule']?.toString() ?? crop.fertilizerRequired,
                  ),
                  _buildDetailRow(
                    LocalizationService.tr('Disease'),
                    guide['disease_management']?.toString() ?? '-',
                  ),
                  _buildDetailRow(
                    LocalizationService.tr('Harvest'),
                    guide['harvesting_instructions']?.toString() ?? '-',
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalizationService.tr('Close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stateController.dispose();
    landAreaController.dispose();
    super.dispose();
  }
}
