import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../widgets/page_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Spin Logic',
      subtitle: 'Plan, balance and cost your spinning mill, from blow room to winding.',
      child: Column(
        children: [
          // User Card matching ref video
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: SpinColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: Color(0xFF3B82F6), width: 4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Muqeet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SpinColors.navyDark)),
                        Text('XYZ · xyz', style: TextStyle(fontSize: 12, color: SpinColors.textGrey)),
                      ],
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    side: BorderSide(color: SpinColors.textGrey.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Switch user', style: TextStyle(fontSize: 13, color: SpinColors.textGrey)),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: crossAxisCount == 2 ? 3.5 : 2.5,
                children: [
                  _buildModuleCard(context, '🏭', 'Production Calculation', 'Carding, draw frame, comber, simplex, ring frame, winding', '/production'),
                  _buildModuleCard(context, '🔄', 'Count Conversion', 'Ne, Nm, Tex, Denier — convert between yarn count systems', '/count-conversion'),
                  _buildModuleCard(context, '🧹', 'Blow Room & Card Waste', 'Waste %, lap/sliver output, combined process loss', '/blow-room-waste'),
                  _buildModuleCard(context, '💰', 'Profit/Loss Calculations', 'Cotton blend table, spindle-cost & per-count cost', '/profit-loss'),
                  _buildModuleCard(context, '🔧', 'Pressure Conversion', 'Bar, PSI, kg/cm², kPa, mmHg, atm conversions', '/pressure-conversion'),
                  _buildModuleCard(context, '💧', 'Relative Humidity Calculator', 'Dry & wet bulb to RH% psychrometer reading', '/humidity'),
                  _buildModuleCard(context, '🎯', 'Target Count Feasibility', 'Screen a cotton lot against a target Ne count', '/target-feasibility'),
                  _buildModuleCard(context, '🧶', 'Ring Doff & Roving Consumption', 'Doff time, roving packages, OPS from yarn count', '/ring-doff'),
                  _buildModuleCard(context, '🏗️', 'New Mills Plan', 'Bags required to blow room lines, cards & simplex machines', '/new-mills-plan'),
                  _buildModuleCard(context, '⚖️', 'Spin Plan (auto-balance)', 'Auto-balance every department from ring frame', '/spin-plan'),
                ],
              );
            },
          ),
          const SizedBox(height: 48),
          const Text(
            'Works fully offline.',
            style: TextStyle(color: SpinColors.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, String icon, String title, String description, String route) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: SpinColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: SpinColors.amber, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: SpinColors.navyDark, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: SpinColors.textGrey, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: SpinColors.amber),
          ],
        ),
      ),
    );
  }
}
