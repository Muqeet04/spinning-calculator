import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../widgets/page_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _modules = [
    (
      Icons.factory_outlined,
      'Production Calculation',
      'Carding, draw frame, comber, simplex, ring frame, winding',
      '/production',
    ),
    (
      Icons.swap_horiz,
      'Count Conversion',
      'Ne, Nm, Tex, Denier — convert between yarn count systems',
      '/count-conversion',
    ),
    (
      Icons.cleaning_services_outlined,
      'Blow Room & Card Waste',
      'Waste %, lap/sliver output, combined process loss',
      '/blow-room-waste',
    ),
    (
      Icons.payments_outlined,
      'Profit/Loss Calculations',
      'Cotton blend table, spindle-cost & per-count cost',
      '/profit-loss',
    ),
    (
      Icons.speed,
      'Pressure Conversion',
      'Bar, PSI, kg/cm², kPa, mmHg, atm conversions',
      '/pressure-conversion',
    ),
    (
      Icons.water_drop_outlined,
      'Relative Humidity Calculator',
      'Dry & wet bulb to RH% psychrometer reading',
      '/humidity',
    ),
    (
      Icons.flag_outlined,
      'Target Count Feasibility',
      'Screen a cotton lot against a target Ne count',
      '/target-feasibility',
    ),
    (
      Icons.autorenew,
      'Ring Doff & Roving Consumption',
      'Doff time, roving packages, OPS from yarn count',
      '/ring-doff',
    ),
    (
      Icons.warehouse_outlined,
      'New Mills Plan',
      'Bags required to blow room lines, cards & simplex machines',
      '/new-mills-plan',
    ),
    (
      Icons.balance,
      'Spin Plan (auto-balance)',
      'Auto-balance every department from ring frame',
      '/spin-plan',
    ),
  ];

  @override
  Widget build(BuildContext context) => PageScaffold(
    title: 'MM spinning calculator',
    subtitle:
        'Complete 10-module engineering, plant balancing, and costing suite for spinning mills.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [SpinColors.royalBlue, SpinColors.emerald],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const FittedBox(
                      child: Text(
                        'MM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Muqeet Mahmood',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.verified,
                              color: SpinColors.royalBlue,
                              size: 16,
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'muqeetmahmood8@gmail.com',
                          style: TextStyle(
                            color: SpinColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lead Engineer & Owner',
                          style: TextStyle(
                            color: SpinColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: SpinColors.emerald, size: 18),
                  Text(
                    'Active & Offline',
                    style: TextStyle(
                      color: SpinColors.emerald,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
            final columns = constraints.maxWidth > 800 * scale.clamp(1, 1.5)
                ? 2
                : 1;
            final width = (constraints.maxWidth - 18 * (columns - 1)) / columns;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                for (final module in _modules)
                  SizedBox(
                    width: width,
                    child: _buildModuleCard(context, module),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: const Text(
            '© MM spinning calculator • Designed & Engineered by Muqeet Mahmood (muqeetmahmood8@gmail.com)',
            textAlign: TextAlign.center,
            style: TextStyle(color: SpinColors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: SpinColors.cardWhite,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: SpinColors.borderLight),
  );

  Widget _buildModuleCard(
    BuildContext context,
    (IconData, String, String, String) module,
  ) => Material(
    color: SpinColors.cardWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: SpinColors.borderLight),
    ),
    child: InkWell(
      onTap: () => context.go(module.$4),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 112),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SpinColors.coolGreyBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(module.$1, color: SpinColors.royalBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    module.$2,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    module.$3,
                    style: const TextStyle(
                      color: SpinColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: SpinColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
