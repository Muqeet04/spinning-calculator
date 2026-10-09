import 'package:go_router/go_router.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/count_conversion_screen.dart';
import '../ui/screens/pressure_conversion_screen.dart';
import '../ui/screens/humidity_screen.dart';
import '../ui/screens/ring_doff_screen.dart';
import '../ui/screens/production_screen.dart';
import '../ui/screens/new_mills_plan_screen.dart';
import '../ui/screens/spin_plan_screen.dart';
import '../ui/screens/profit_loss_screen.dart';
import '../ui/screens/blow_room_waste_screen.dart';
import '../ui/screens/target_feasibility_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/count-conversion',
      builder: (context, state) => const CountConversionScreen(),
    ),
    GoRoute(
      path: '/pressure-conversion',
      builder: (context, state) => const PressureConversionScreen(),
    ),
    GoRoute(
      path: '/humidity',
      builder: (context, state) => const HumidityScreen(),
    ),
    GoRoute(
      path: '/ring-doff',
      builder: (context, state) => const RingDoffScreen(),
    ),
    GoRoute(
      path: '/production',
      builder: (context, state) => const ProductionScreen(),
    ),
    GoRoute(
      path: '/blow-room-waste',
      builder: (context, state) => const BlowRoomWasteScreen(),
    ),
    GoRoute(
      path: '/target-feasibility',
      builder: (context, state) => const TargetFeasibilityScreen(),
    ),
    GoRoute(
      path: '/profit-loss',
      builder: (context, state) => const ProfitLossScreen(),
    ),
    GoRoute(
      path: '/new-mills-plan',
      builder: (context, state) => const NewMillsPlanScreen(),
    ),
    GoRoute(
      path: '/spin-plan',
      builder: (context, state) => const SpinPlanScreen(),
    ),
  ],
);
