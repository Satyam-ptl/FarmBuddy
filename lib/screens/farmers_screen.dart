import 'package:flutter/material.dart';
import '../models/farmer_model.dart';  // Import Farmer model
import '../services/api_service.dart';  // Import API service
import '../services/auth_service.dart';
import '../services/auth_ui_service.dart';
import '../services/localization_service.dart';

/// Farmers screen - shows list of all farmers
class FarmersScreen extends StatefulWidget {
  const FarmersScreen({super.key});

  @override
  State<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends State<FarmersScreen> {
  List<Farmer> farmers = [];  // List of farmers
  List<FarmerCrop> mySelectedCrops = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isLoading = true;
  String? errorMessage;

  bool get _isAdmin => AuthService.session?.isAdmin ?? false;
  List<Farmer> get _filteredFarmers {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return farmers;
    return farmers.where((farmer) {
      return farmer.fullName.toLowerCase().contains(q) ||
          farmer.city.toLowerCase().contains(q) ||
          farmer.state.toLowerCase().contains(q) ||
          farmer.phoneNumber.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadFarmers();  // Load farmers when screen opens
  }

  /// Load farmers from Django API
  Future<void> loadFarmers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getFarmers(pageSize: 100);
      final List<dynamic> farmersJson = (response['results'] as List<dynamic>? ?? []);
      final List<Farmer> loadedFarmers = farmersJson
          .map((json) => Farmer.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      var selectedCrops = <FarmerCrop>[];
      if (!_isAdmin) {
        final cropsResponse = await ApiService.getFarmerCrops(pageSize: 200);
        final cropsJson = (cropsResponse['results'] as List<dynamic>? ?? []);
        selectedCrops = cropsJson
            .map((item) => FarmerCrop.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }

      setState(() {
        farmers = loadedFarmers;
        mySelectedCrops = selectedCrops;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final handled = await AuthUiService.handleAuthError(
        context,
        e,
        message: 'Session expired. Please sign in again.',
      );
      if (handled) return;
      setState(() {
        errorMessage = 'Failed to load farmers: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.tr('Farmers')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => AuthUiService.confirmAndLogout(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadFarmers,
            tooltip: LocalizationService.tr('Refresh'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by name, phone, city or state',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close),
                      )
                    : null,
                isDense: true,
              ),
            ),
          ),
          if (!_isAdmin)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My selected crops',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      if (mySelectedCrops.isEmpty)
                        const Text(
                          'No crops selected yet. Go to Crops tab and add one for tasks.',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: mySelectedCrops
                              .map(
                                (crop) => Chip(
                                  label: Text('${crop.cropName} (${crop.status})'),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
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
                              onPressed: loadFarmers,
                              child: Text(LocalizationService.tr('Retry')),
                            ),
                          ],
                        ),
                      )
                    : _filteredFarmers.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty ? 'No farmers found' : 'No matches for "$_searchQuery"',
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: loadFarmers,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredFarmers.length,
                              itemBuilder: (context, index) {
                                final farmer = _filteredFarmers[index];
                                return _buildFarmerCard(farmer);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  /// Build a card widget for a farmer
  Widget _buildFarmerCard(Farmer farmer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showFarmerDetails(farmer);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Farmer name
              Text(
                farmer.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('${farmer.city}, ${farmer.state}'),
                ],
              ),
              const SizedBox(height: 4),

              // Phone
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(farmer.phoneNumber),
                ],
              ),
              const SizedBox(height: 4),

              // Land area
              Row(
                children: [
                  const Icon(Icons.landscape, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('Land: ${farmer.landAreaHectares} hectares'),
                ],
              ),
              const SizedBox(height: 8),

              // Experience level chip
              Row(
                children: [
                  Chip(
                    label: Text(farmer.experienceLevel),
                    backgroundColor: _getExperienceColor(farmer.experienceLevel),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(farmer.preferredLanguage),
                    backgroundColor: Colors.blue.shade100,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color for experience level
  Color _getExperienceColor(String level) {
    switch (level) {
      case 'Expert':
        return Colors.green.shade200;
      case 'Intermediate':
        return Colors.orange.shade200;
      case 'Beginner':
        return Colors.blue.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  /// Show farmer details dialog
  void _showFarmerDetails(Farmer farmer) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(farmer.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', farmer.email),
              _buildDetailRow('Phone', farmer.phoneNumber),
              _buildDetailRow('Address', farmer.address),
              _buildDetailRow('City', farmer.city),
              _buildDetailRow('State', farmer.state),
              _buildDetailRow('Postal Code', farmer.postalCode),
              _buildDetailRow('Language', farmer.preferredLanguage),
              _buildDetailRow('Land Area', '${farmer.landAreaHectares} hectares'),
              _buildDetailRow('Soil Type', farmer.soilType),
              _buildDetailRow('Experience', farmer.experienceLevel),
              _buildDetailRow('Contact Method', farmer.contactMethod),
            ],
          ),
        ),
        actions: [
          if (!_isAdmin)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditFarmerDialog(farmer);
              },
              child: const Text('Edit Profile'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditFarmerDialog(Farmer farmer) {
    final phoneController = TextEditingController(text: farmer.phoneNumber);
    final addressController = TextEditingController(text: farmer.address);
    final cityController = TextEditingController(text: farmer.city);
    final stateController = TextEditingController(text: farmer.state);
    final postalController = TextEditingController(text: farmer.postalCode);
    final landController = TextEditingController(text: farmer.landAreaHectares.toString());

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Farmer Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
              TextField(controller: stateController, decoration: const InputDecoration(labelText: 'State')),
              TextField(controller: postalController, decoration: const InputDecoration(labelText: 'Postal Code')),
              TextField(
                controller: landController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Land Area (hectares)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ApiService.updateFarmer(farmer.id, {
                  'first_name': farmer.firstName,
                  'last_name': farmer.lastName,
                  'email': farmer.email,
                  'phone_number': phoneController.text.trim(),
                  'address': addressController.text.trim(),
                  'city': cityController.text.trim(),
                  'state': stateController.text.trim(),
                  'postal_code': postalController.text.trim(),
                  'preferred_language': farmer.preferredLanguage,
                  'land_area_hectares': double.tryParse(landController.text.trim()) ?? farmer.landAreaHectares,
                  'soil_type': farmer.soilType,
                  'experience_level': farmer.experienceLevel,
                  'contact_method': farmer.contactMethod,
                });

                if (!mounted) return;
                navigator.pop();
                await loadFarmers();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to update profile: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      phoneController.dispose();
      addressController.dispose();
      cityController.dispose();
      stateController.dispose();
      postalController.dispose();
      landController.dispose();
    });
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
