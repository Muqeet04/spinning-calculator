import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../widgets/page_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'MM spinning calculator',
      subtitle: 'Complete 10-module engineering, plant balancing, and costing suite for spinning mills.',
      child: Column(
        children: [
          // Owner & Creator Profile Card
          Container(
            margin: const EdgeInsets.only(bottom: 28),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: SpinColors.cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SpinColors.borderLight, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [SpinColors.royalBlue, SpinColors.emerald],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: SpinColors.royalBlue.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'MM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Muqeet Mahmood',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: SpinColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.verified, color: SpinColors.royalBlue, size: 16),
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          'muqeetmahmood8@gmail.com • Lead Engineer & Owner',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: SpinColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SpinColors.emeraldGlow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SpinColors.emerald.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: SpinColors.emerald, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Active & Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: SpinColors.emerald,
                        ),
                      ),
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
          const SizedBox(height: 44),
          // Creator Ownership Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: SpinColors.coolGreyBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SpinColors.borderLight),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.copyright, size: 14, color: SpinColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'MM spinning calculator • Designed & Engineered by Muqeet Mahmood (muqeetmahmood8@gmail.com)',
                  style: TextStyle(
                    color: SpinColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
