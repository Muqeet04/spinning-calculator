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
      subtitle: 'Textile spinning mill engineering, balancing, and profitability calculation suite.',
      child: Column(
        children: [
          // Sleek Corporate User Card
          Container(
            margin: const EdgeInsets.only(bottom: 28),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: SpinColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SpinColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: SpinColors.royalBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(color: SpinColors.royalBlue.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.person, color: SpinColors.royalBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Muqeet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: SpinColors.textPrimary)),
                        Text('Textile Operations · Online / Offline Active', style: TextStyle(fontSize: 12, color: SpinColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SpinColors.emeraldGlow,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: SpinColors.emerald.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: SpinColors.emerald, size: 12),
                      SizedBox(width: 4),
                      Text('Offline Ready', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SpinColors.emerald)),
                    ],
                  ),
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
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: crossAxisCount == 2 ? 3.6 : 2.5,
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: SpinColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Spin Logic v1.0 • Verified offline mathematical precision',
                style: TextStyle(color: SpinColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
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
          border: Border.all(color: SpinColors.borderLight, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SpinColors.coolGreyBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SpinColors.borderLight),
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: SpinColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: SpinColors.textSecondary, fontSize: 12.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, color: SpinColors.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}
