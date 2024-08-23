import 'package:akshaya_flutter/app_enterance/language_screen.dart';
import 'package:akshaya_flutter/app_enterance/splash_screen.dart';
import 'package:akshaya_flutter/authentication/login_otp_screen.dart';
import 'package:akshaya_flutter/authentication/login_screen.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/crop_maintenance_visits_screen.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/farmer_passbook_screen.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/ffb_collection_screen.dart';
import 'package:akshaya_flutter/screens/main_screen.dart';
import 'package:akshaya_flutter/navigation/app_routes.dart';
import 'package:akshaya_flutter/navigation/page_not_found.dart';
import 'package:akshaya_flutter/screens/customer_care_screen.dart/customer_care_screen.dart';
import 'package:akshaya_flutter/screens/home_screen/home_screen.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/my3f_screen.dart';
import 'package:akshaya_flutter/screens/profile_screen/profile_screen.dart';
import 'package:akshaya_flutter/screens/requests_screen.dart/screens/requests_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
//MARK: Branches
final _homeBranchNavigatorKey = GlobalKey<NavigatorState>();
final _profileBranchNavigatorKey = GlobalKey<NavigatorState>();
final _my3fBranchNavigatorKey = GlobalKey<NavigatorState>();
final _requestsBranchNavigatorKey = GlobalKey<NavigatorState>();
final _customerCareBranchNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: Routes.splashScreen.path,
  // initialLocation: Routes.screenHome.path,
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  errorPageBuilder: (context, state) {
    return const CupertinoPage(child: PageNotFound());
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, child) => MainScreen(navigationShell: child),
      branches: <StatefulShellBranch>[
        //MARK: Branch 1
        StatefulShellBranch(
            navigatorKey: _homeBranchNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: Routes.homeScreen.path,
                name: Routes.homeScreen.name,
                builder: (context, state) => const HomeScreen(),
                /* routes: <RouteBase>[
                  GoRoute(
                    path: Routes.screenSearch.path,
                    name: Routes.screenSearch.name,
                    pageBuilder: (context, state) => CupertinoPage(
                      key: state.pageKey,
                      child: const SearchMobile(),
                    ),
                  ),
                ], */
              ),
            ]),
        //MARK: Branch 2
        StatefulShellBranch(
            navigatorKey: _profileBranchNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: Routes.profileScreen.path,
                name: Routes.profileScreen.name,
                builder: (context, state) => const ProfileScreen(),
                /* routes: <RouteBase>[
                  GoRoute(
                    path: Routes.screenSearch.path,
                    name: Routes.screenSearch.name,
                    pageBuilder: (context, state) => CupertinoPage(
                      key: state.pageKey,
                      child: const SearchMobile(),
                    ),
                  ),
                ], */
              ),
            ]),
        //MARK: Branch 3
        StatefulShellBranch(
          navigatorKey: _my3fBranchNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: Routes.my3fScreen.path,
              name: Routes.my3fScreen.name,
              builder: (context, state) => const My3fScreen(),
            )
          ],
        ),

        //MARK: Branch 4
        StatefulShellBranch(
          navigatorKey: _requestsBranchNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: Routes.requestsScreen.path,
              name: Routes.requestsScreen.name,
              builder: (context, state) => const RequestsScreen(),
              /*  routes: <RouteBase>[
               
               ], */
            )
          ],
        ),

        //MARK: Branch 5
        StatefulShellBranch(
          navigatorKey: _customerCareBranchNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: Routes.customerCareScreen.path,
              name: Routes.customerCareScreen.name,
              builder: (context, state) => const CustomerCareScreen(),
              // routes: <RouteBase>[],
            )
          ],
        ),
      ],
    ),

    //MARK: Other Screens
    GoRoute(
      path: Routes.testScreen.path,
      name: Routes.testScreen.name,
      pageBuilder: (context, state) =>
          CupertinoPage(key: state.pageKey, child: const PageNotFound()),
    ),
    GoRoute(
      path: Routes.splashScreen.path,
      name: Routes.splashScreen.name,
      pageBuilder: (context, state) =>
          CupertinoPage(key: state.pageKey, child: const SplashScreen()),
    ),
    GoRoute(
      path: Routes.languageScreen.path,
      name: Routes.languageScreen.name,
      pageBuilder: (context, state) =>
          CupertinoPage(key: state.pageKey, child: const LanguageScreen()),
    ),
    GoRoute(
      path: Routes.loginScreen.path,
      name: Routes.loginScreen.name,
      pageBuilder: (context, state) =>
          CupertinoPage(key: state.pageKey, child: const LoginScreen()),
    ),
    GoRoute(
      path: Routes.ffbCollectionScreen.path,
      name: Routes.ffbCollectionScreen.name,
      pageBuilder: (context, state) =>
          CupertinoPage(key: state.pageKey, child: const FfbCollectionScreen()),
    ),
    GoRoute(
      path: Routes.farmerPassbookScreen.path,
      name: Routes.farmerPassbookScreen.name,
      pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey, child: const FarmerPassbookScreen()),
    ),
    GoRoute(
      path: Routes.cropMaintenanceVisitsScreen.path,
      name: Routes.cropMaintenanceVisitsScreen.name,
      pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey, child: const CropMaintenanceVisitsScreen()),
    ),

    GoRoute(
      path: '${Routes.loginOtpScreen.path}/:mobile',
      name: Routes.loginOtpScreen.name,
      pageBuilder: (context, state) {
        final mobile = state.pathParameters['mobile'];
        return CupertinoPage(
          key: state.pageKey,
          child: LoginOtpScreen(
            mobile: mobile!,
          ),
        );
      },
    ),
  ],
);
