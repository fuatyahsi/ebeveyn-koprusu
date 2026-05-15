import 'package:ebeveyn_koprusu/features/admin/presentation/screens/admin_screen.dart';
import 'package:ebeveyn_koprusu/features/auth/presentation/screens/auth_screen.dart';
import 'package:ebeveyn_koprusu/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:ebeveyn_koprusu/features/checklists/presentation/screens/checklists_screen.dart';
import 'package:ebeveyn_koprusu/features/children/presentation/screens/children_screen.dart';
import 'package:ebeveyn_koprusu/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:ebeveyn_koprusu/features/decisions/presentation/screens/decisions_screen.dart';
import 'package:ebeveyn_koprusu/features/documents/presentation/screens/documents_screen.dart';
import 'package:ebeveyn_koprusu/features/disputes/presentation/screens/disputes_screen.dart';
import 'package:ebeveyn_koprusu/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:ebeveyn_koprusu/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:ebeveyn_koprusu/features/family/presentation/screens/family_screen.dart';
import 'package:ebeveyn_koprusu/features/handover/presentation/screens/handover_screen.dart';
import 'package:ebeveyn_koprusu/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:ebeveyn_koprusu/features/personal_journal/presentation/screens/personal_journal_screen.dart';
import 'package:ebeveyn_koprusu/features/reports/presentation/screens/reports_screen.dart';
import 'package:ebeveyn_koprusu/features/settings/presentation/screens/settings_screen.dart';
import 'package:ebeveyn_koprusu/features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'package:ebeveyn_koprusu/features/visionary/presentation/screens/visionary_features_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_shell.dart';
import 'package:ebeveyn_koprusu/core/services/supabase_service.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final client = SupabaseService.client;
    if (client == null) return null;

    final isSignedIn = client.auth.currentSession != null;
    final isAuthRoute = state.matchedLocation == '/auth';
    final isWelcomeRoute = state.matchedLocation == '/welcome';

    if (!isSignedIn && !isAuthRoute && !isWelcomeRoute) {
      return '/auth';
    }
    if (isSignedIn && isAuthRoute) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AppShell()),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpensesScreen(),
    ),
    GoRoute(path: '/family', builder: (context, state) => const FamilyScreen()),
    GoRoute(
      path: '/children',
      builder: (context, state) => const ChildrenScreen(),
    ),
    GoRoute(
      path: '/handover',
      builder: (context, state) => const HandoverScreen(),
    ),
    GoRoute(
      path: '/contacts',
      builder: (context, state) => const ContactsScreen(),
    ),
    GoRoute(
      path: '/documents',
      builder: (context, state) => const DocumentsScreen(),
    ),
    GoRoute(
      path: '/decisions',
      builder: (context, state) => const DecisionsScreen(),
    ),
    GoRoute(
      path: '/disputes',
      builder: (context, state) => const DisputesScreen(),
    ),
    GoRoute(
      path: '/journal',
      builder: (context, state) => const PersonalJournalScreen(),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/checklists',
      builder: (context, state) => const ChecklistsScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/subscriptions',
      builder: (context, state) => const SubscriptionsScreen(),
    ),
    GoRoute(
      path: '/visionary',
      builder: (context, state) => const VisionaryFeaturesScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
  ],
);
