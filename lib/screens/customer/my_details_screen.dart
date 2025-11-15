import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../widgets/custom_card.dart';

class MyDetailsScreen extends StatelessWidget {
  const MyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final data = Provider.of<DataProvider>(context);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user')));
    }

    final totalOrders =
        data.orders.where((o) => o.customerId == user.id).length;
    final activeOrders = data.orders
        .where(
            (o) => o.customerId == user.id && o.status.name.contains('pending'))
        .length;

    String address = '';
    if (user is Customer) {
      address = [user.address, user.city, user.state, user.country]
          .where((e) => (e ?? '').toString().isNotEmpty)
          .join(', ');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(theme, 'Name', user.name, LucideIcons.user),
                  const SizedBox(height: 12),
                  _row(theme, 'Email', user.email, LucideIcons.mail),
                  const SizedBox(height: 12),
                  _row(theme, 'Phone', (user as dynamic).phone ?? '-',
                      LucideIcons.phone),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(theme, 'Address', address.isNotEmpty ? address : '-',
                      LucideIcons.mapPin),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat(theme, 'Total Orders', totalOrders.toString(),
                      LucideIcons.package),
                  _stat(theme, 'Current', activeOrders.toString(),
                      LucideIcons.timer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(ThemeData theme, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(label,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        )
      ],
    );
  }
}
