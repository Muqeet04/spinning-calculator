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
