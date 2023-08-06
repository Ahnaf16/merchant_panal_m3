import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/feature/delivery/view/delivery_view.dart';
import 'package:merchant_m3/feature/version_manager/view/version_manager_view.dart';
import 'package:merchant_m3/feature/auth/model/auth_state_model.dart';
import 'package:merchant_m3/feature/auth/provider/auth_provider.dart';
import 'package:merchant_m3/feature/auth/view/login_view.dart';
import 'package:merchant_m3/feature/campaign/view/add_update_campaign_view.dart';
import 'package:merchant_m3/feature/campaign/view/campaign_details_view.dart';
import 'package:merchant_m3/feature/campaign/view/campaign_list_view.dart';
import 'package:merchant_m3/feature/dash/view/dash_view.dart';
import 'package:merchant_m3/feature/employee/provider/employee_provider.dart';
import 'package:merchant_m3/feature/employee/view/add_edit_employee_view.dart';
import 'package:merchant_m3/feature/employee/view/employee_list.dart';
import 'package:merchant_m3/feature/flash/view/flash_sale_view.dart';
import 'package:merchant_m3/feature/navigation/root_navigation_view.dart';
import 'package:merchant_m3/feature/news/view/news_view.dart';
import 'package:merchant_m3/feature/orders/view/order_details.dart';
import 'package:merchant_m3/feature/orders/view/order_list_view.dart';
import 'package:merchant_m3/feature/point_of_sale/view/pos_view.dart';
import 'package:merchant_m3/feature/products/view/product_add_edit.dart';
import 'package:merchant_m3/feature/products/view/product_details_view.dart';
import 'package:merchant_m3/feature/products/view/product_list_view.dart';
import 'package:merchant_m3/feature/slider/view/slider_view.dart';
import 'package:merchant_m3/feature/tools/view/tools_view.dart';
import 'package:merchant_m3/feature/voucher/view/voucher_view.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:merchant_m3/routes/pages/splash.dart';
import 'package:merchant_m3/routes/route_names.dart';

import 'package:routemaster/routemaster.dart';

import 'pages/no_access.dart';

class RouteLogger extends RoutemasterObserver {
  @override
  void didChangeRoute(RouteData routeData, Page page) {
    log('route: ${routeData.fullPath}', name: 'Route');
  }
}

final routeProvider = Provider.autoDispose<RoutemasterDelegate>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    log(authState.status.toString());
    final isAuthenticated = authState == const AuthState.authenticated();
    final employee = ref.watch(permissionProvider);

    final routemasterDelegate = RoutemasterDelegate(
      observers: [RouteLogger()],
      routesBuilder: (context) {
        if (authState == const AuthState.unauthenticated()) {
          return RouteMap(
            onUnknownRoute: (path) => const Redirect(RoutesName.login),
            routes: {
              RoutesName.login: (route) =>
                  const MaterialPage(child: LoginView()),
            },
          );
        }

        Page guardPage({
          required Widget child,
          required EPermissions permission,
        }) {
          final hasPermission = employee?.can(permission);

          final widget = Center(
            child: switch (hasPermission) {
              null => const SplashScreen(),
              false => const NoAccessPage(),
              true => child,
            },
          );

          return isAuthenticated
              ? MaterialPage(child: widget)
              : const MaterialPage(child: SplashScreen());
        }

        // ROUTE MAPS ------------------------------------------------
        return RouteMap(
          onUnknownRoute: (path) {
            log(path, name: 'unknown');
            return const Redirect(RoutesName.root);
          },
          routes: {
            RoutesName.root: (_) {
              return authState == const AuthState.loading()
                  ? const MaterialPage(child: SplashScreen())
                  : IndexedPage(
                      child: const RootNavigationView(),
                      paths: RoutesName.panePage(context),
                      backBehavior: TabBackBehavior.history,
                    );
            },
            RoutesName.dash: (route) {
              return splashGuard(
                canNavigate: isAuthenticated,
                page: const MaterialPage(child: DashView()),
              );
            },
            RoutesName.products: (route) => splashGuard(
                  canNavigate: isAuthenticated,
                  page: const MaterialPage(child: ProductListView()),
                ),
            RoutesName.productsDetails(':id'): (route) {
              final id = route.pathParameters['id'];
              return splashGuard(
                canNavigate: isAuthenticated,
                page: MaterialPage(
                  child: ProductDetailsView(id: id),
                  name: 'PRODUCT Details',
                ),
              );
            },
            RoutesName.addProducts: (route) {
              return guardPage(
                permission: EPermissions.productAdd,
                child: const ProductAddEdit(null),
              );
            },
            RoutesName.editProducts(':id'): (route) {
              final id = route.pathParameters['id'];
              return guardPage(
                permission: EPermissions.productUpdate,
                child: ProductAddEdit(id),
              );
            },
            RoutesName.orders: (route) => guardPage(
                  permission: EPermissions.ordersView,
                  child: const OrderListView(),
                ),
            RoutesName.ordersDetails(':id'): (route) {
              final id = route.pathParameters['id'];
              return guardPage(
                permission: EPermissions.ordersView,
                child: OrderDetailsView(id),
              );
            },
            RoutesName.more: (route) => splashGuard(
                  canNavigate: isAuthenticated,
                  page: const MaterialPage(child: ToolsView()),
                ),
            RoutesName.campaign: (route) => splashGuard(
                  canNavigate: isAuthenticated,
                  page: const MaterialPage(child: CampaignListView()),
                ),
            RoutesName.campaignDetails(':title'): (route) {
              final title = route.pathParameters['title'];
              return splashGuard(
                canNavigate: isAuthenticated,
                page: MaterialPage(child: CampaignDetailsView(title!)),
              );
            },
            RoutesName.addCampaign: (route) => guardPage(
                  permission: EPermissions.campaignAdd,
                  child: const AddUpdateCampaignView(null),
                ),
            RoutesName.editCampaign(':title'): (route) {
              final title = route.pathParameters['title'];
              return guardPage(
                permission: EPermissions.campaignAdd,
                child: AddUpdateCampaignView(title),
              );
            },
            RoutesName.flash: (route) => guardPage(
                  permission: EPermissions.flashAdd,
                  child: const FlashView(),
                ),
            RoutesName.pos: (route) {
              final orderId = route.queryParameters['id'];
              return guardPage(
                permission: EPermissions.pointOfSale,
                child: POSView(orderId),
              );
            },
            RoutesName.appVersion: (route) => splashGuard(
                  canNavigate: isAuthenticated,
                  page: Guard(
                    builder: () => const MaterialPage(child: AppVersionView()),
                    canNavigate: (info, context) => employee?.isDev ?? false,
                    onNavigationFailed: (info, context) =>
                        const MaterialPage(child: NoAccessPage()),
                  ),
                ),
            RoutesName.employee: (route) => splashGuard(
                  canNavigate: isAuthenticated,
                  page: const MaterialPage(child: EmployeeListView()),
                ),
            RoutesName.addEmployee: (route) => guardPage(
                  permission: EPermissions.employeeManage,
                  child: const AddEditEmployeeView(null),
                ),
            RoutesName.editEmployee(':uid'): (route) {
              final title = route.pathParameters['uid'];

              return guardPage(
                permission: EPermissions.employeeManage,
                child: AddEditEmployeeView(title),
              );
            },
            RoutesName.voucher: (route) => splashGuard(
                  canNavigate: isAuthenticated,
                  page: const MaterialPage(child: VoucherView()),
                ),
            RoutesName.delivery: (route) => guardPage(
                  permission: EPermissions.deliveryCharge,
                  child: const DeliveryView(),
                ),
            RoutesName.slider: (route) => splashGuard(
                  canNavigate: isAuthenticated,
                  page: const MaterialPage(child: SliderView()),
                ),
            RoutesName.news: (route) => splashGuard(
                  canNavigate: isAuthenticated,
                  page: const MaterialPage(child: NewsView()),
                ),
          },
        );
      },
    );

    return routemasterDelegate;
  },
);

Page<dynamic> splashGuard({required Page page, required bool canNavigate}) {
  return canNavigate ? page : const MaterialPage(child: SplashScreen());
}
