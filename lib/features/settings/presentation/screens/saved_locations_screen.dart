import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/features/settings/presentation/widgets/saved_location_card.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  // Mock data for demonstration
  final List<Map<String, String>> _savedLocations = [
    {
      'name': 'Home',
      'address': 'Terminal 1 Berlin Brandenburg Airport\nMelli-Beese-Ring 1',
    },
    {
      'name': 'Office',
      'address': 'Terminal 1 Berlin Brandenburg Airport\nMelli-Beese-Ring 1',
    },
    {
      'name': 'Work',
      'address': 'Terminal 1 Berlin Brandenburg Airport\nMelli-Beese-Ring 1',
    },
    {
      'name': 'Gym',
      'address': 'Terminal 1 Berlin Brandenburg Airport\nMelli-Beese-Ring 1',
    },
  ];

  void _handleEdit(String locationName) {
    // TODO: Implement edit functionality
    debugPrint('Edit location: $locationName');
  }

  void _handleDelete(String locationName) {
    // TODO: Implement delete functionality
    debugPrint('Delete location: $locationName');
  }

  void _handleAddLocation() {
    // TODO: Implement add location functionality
    debugPrint('Add new location');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.saved_locations), centerTitle: true),
      child: Stack(
        children: [
          // Scrollable list of saved locations
          ListView.separated(
            padding: const EdgeInsets.only(
              top: AppSizes.p16,
              bottom: 100, // Extra padding for FAB
            ),
            itemCount: _savedLocations.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.p12),
            itemBuilder: (context, index) {
              final location = _savedLocations[index];

              return SavedLocationCard(
                locationName: location['name']!,
                address: location['address']!,
                onEdit: () => _handleEdit(location['name']!),
                onDelete: () => _handleDelete(location['name']!),
              );
            },
          ),

          // Floating Action Button
          Positioned(
            right: 20,
            bottom: 30,
            child: FloatingActionButton(
              onPressed: _handleAddLocation,
              backgroundColor: colors.brand,
              shape: const CircleBorder(), // ✅ force circle
              child: Icon(
                Icons.add,
                color: context.appColors.textPrimary,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
