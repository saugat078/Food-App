import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/controllers/MenuControllerr.dart';
import 'package:grocery_admin_panel/widgets/gird_order_products.dart';
import 'package:provider/provider.dart';
import '../responsive.dart';
import '../services/utils.dart';
import '../widgets/grid_products.dart';
import '../widgets/header.dart';
import '../widgets/side_menu.dart';

class OrderProductsScreen extends StatefulWidget {
  const OrderProductsScreen({Key? key, required this.orderId}) : super(key: key);
  final String orderId;
  @override
  State<OrderProductsScreen> createState() => _OrderProductsScreenState();
}


class _OrderProductsScreenState extends State<OrderProductsScreen> {

  
  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    return Scaffold(
      key: context.read<MenuControllerr>().getgridscaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              const Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
                // It takes 5/6 part of the screen
                flex: 5,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Header(
                          fct: () {
                            context
                                .read<MenuControllerr>()
                                .controlProductsMenu();
                          },
                          title: 'All Products of Order No: ${widget.orderId.substring(0, 8)}',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Responsive(
                          mobile: OrderProductGridWidget(
                            crossAxisCount: size.width < 650 ? 2 : 4,
                            childAspectRatio:
                                size.width < 650 && size.width > 350
                                    ? 1.1
                                    : 0.8,
                            isInMain: false,
                            orderId: widget.orderId
                          ),
                          desktop: OrderProductGridWidget(
                            childAspectRatio: size.width < 1400 ? 0.8 : 1.05,
                            isInMain: false,
                            orderId: widget.orderId
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
