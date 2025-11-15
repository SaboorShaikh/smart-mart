import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/address.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.user?.id;
    final theme = Theme.of(context);

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Delivery Addresses')),
        body: const Center(child: Text('Please login to manage addresses')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Addresses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/customer/address/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: StreamBuilder<List<AddressModel>>(
        stream: FirestoreService.streamAddresses(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off,
                      size: 48, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('No saved addresses'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final a = items[index];
              return Dismissible(
                key: ValueKey(a.id),
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) =>
                    FirestoreService.deleteAddress(userId, a.id),
                child: Material(
                  elevation: 6,
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.9),
                  shadowColor: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.18),
                              theme.colorScheme.secondary.withOpacity(0.16),
                            ],
                          ),
                        ),
                        child: Icon(Icons.location_on_rounded,
                            color: theme.colorScheme.primary),
                      ),
                      title: Text(
                        '${a.label} • ${a.street}${a.houseNumber != null && a.houseNumber!.isNotEmpty ? ' ${a.houseNumber}' : ''}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          a.placeName ??
                              '${a.latitude.toStringAsFixed(5)}, ${a.longitude.toStringAsFixed(5)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing:
                          Icon(Icons.edit, color: theme.colorScheme.primary),
                      onTap: () =>
                          Get.toNamed('/customer/address/edit', arguments: a),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
