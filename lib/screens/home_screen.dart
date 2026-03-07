import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/auth_ui_service.dart';
import '../services/localization_service.dart';

/// Dashboard screen – lives inside AppShell's IndexedStack.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalCrops = 0;
  int totalFarmers = 0;
  int pendingTasks = 0;
  int activeAlerts = 0;

  bool isLoading = true;
  String? errorMessage;

  bool get _isAdmin => AuthService.session?.isAdmin ?? false;
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Parallel API calls for faster loading
      final results = await Future.wait([
        ApiService.getCrops(pageSize: 1),
        ApiService.getFarmers(pageSize: 1),
        ApiService.getTasks(status: 'Pending', pageSize: 1),
        ApiService.getWeatherAlertsCount(),
      ]);

      if (!mounted) return;
      setState(() {
        totalCrops = ((results[0] as Map)['count'] as num?)?.toInt() ?? 0;
        totalFarmers = ((results[1] as Map)['count'] as num?)?.toInt() ?? 0;
        pendingTasks = ((results[2] as Map)['count'] as num?)?.toInt() ?? 0;
        activeAlerts = (results[3] as num?)?.toInt() ?? 0;
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
        errorMessage = 'Failed to load dashboard data.';
        isLoading = false;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.tr('Dashboard')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => AuthUiService.confirmAndLogout(context),
          ),
          // Language switcher
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: LocalizationService.languageNotifier.value,
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.black87),
                items: LocalizationService.supportedLanguages
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    LocalizationService.setLanguage(v);
                    setState(() {});
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      _buildGreeting(theme),
                      const SizedBox(height: 20),
                      _buildStatGrid(theme),
                      const SizedBox(height: 24),
                      _buildTipsCard(theme),
                    ],
                  ),
                ),
    );
  }

  // ── Greeting ──────────────────────────────────────────
  Widget _buildGreeting(ThemeData theme) {
    final name = AuthService.session?.fullName ?? 'Farmer';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting,',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54),
        ),
        Text(
          name,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          _isAdmin ? 'Administrator' : 'Farmer',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
        ),
      ],
    );
  }

  // ── Stat grid ─────────────────────────────────────────
  Widget _buildStatGrid(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _statTile(theme, 'Crops', totalCrops, Icons.grass, const Color(0xFF27AE60)),
        _statTile(theme, 'Farmers', totalFarmers, Icons.people, const Color(0xFF2980B9)),
        _statTile(theme, 'Pending Tasks', pendingTasks, Icons.assignment_outlined, const Color(0xFFF39C12)),
        _statTile(theme, 'Alerts', activeAlerts, Icons.warning_amber_rounded, const Color(0xFFE74C3C)),
      ],
    );
  }

  Widget _statTile(ThemeData theme, String label, int value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: color.withAlpha(30), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
        ],
      ),
    );
  }

  // ── Tips card ─────────────────────────────────────────
  Widget _buildTipsCard(ThemeData theme) {
    final tips = <String>[
      'Check weather alerts before planning field work.',
      'Add reminders to tasks so you never miss a deadline.',
      'Use the crop comparison tool to pick the best variety.',
      'Keep your profile up to date for personalised recommendations.',
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Quick Tips', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45)),
                      Expanded(child: Text(t, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.black26),
            const SizedBox(height: 16),
            Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
