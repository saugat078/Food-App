import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:grocery_shop_app/inner_screens/feeds_screen.dart';
import 'package:grocery_shop_app/inner_screens/on_sale_screen.dart';
import 'package:grocery_shop_app/models/products_model.dart';
import 'package:grocery_shop_app/providers/products_provider.dart';
import 'package:grocery_shop_app/services/global_methods.dart';
import 'package:grocery_shop_app/services/utils.dart';
import 'package:grocery_shop_app/widgets/feed_items.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/on_sale_widget.dart';

class HomeScreen extends StatefulWidget {
    static const routeName = "/HomeScreen";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _offerImages = [];
  @override
  void initState() {
    super.initState();
    _fetchOfferImages();
  }

  Future<void> _fetchOfferImages() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('offers').get();
      final List<String> imageUrls = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();

      setState(() {
        _offerImages = imageUrls;
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final Utils utils = Utils(context);
    final themeState = utils.getTheme;
    final size = MediaQuery.of(context).size;
    final Color color = Utils(context).color;
    final productProviders = Provider.of<ProductsProvider>(context);
    List<ProductModel> allProducts = productProviders.getProducts;
    List<ProductModel> productsOnSale = productProviders.getOnSaleProducts;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 14 / 9,
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return _offerImages.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : Image.network(
                          _offerImages[index],
                          fit: BoxFit.cover,
                        );
                },
                autoplay: true,
                itemCount: _offerImages.isEmpty ? 1 : _offerImages.length,
                pagination: const SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    builder: DotSwiperPaginationBuilder(
                        color: Colors.white, activeColor: Colors.red)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
              child: Column(
                children: [
                  _buildSectionHeader('On sale', OnSaleScreen.routeName),
                  SizedBox(height: size.height * 0.01),
                  _buildOnSaleList(productsOnSale, size),
                  SizedBox(height: size.height * 0.02),
                  _buildSectionHeader('Our products', FeedsScreen.routeName),
                  SizedBox(height: size.height * 0.01),
                  _buildProductGrid(allProducts, size),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String routeName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(
          text: title,
          color: Utils(context).color,
          textSize: 22,
          isTitle: true,
        ),
        TextButton(
          onPressed: () {
            GlobalMethods.navigateTo(ctx: context, routeName: routeName);
          },
          child: TextWidget(
            text: 'View all',
            maxLines: 1,
            color: Colors.blue,
            textSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildOnSaleList(List<ProductModel> productsOnSale, Size size) {
      print('Products on sale: ${productsOnSale.toList()}');
        print('Products on sale: ${productsOnSale.map((p) => "${p.id}: ${p.title}").toList()}');


    return Container(height:size.width*0.35,
      child: ListView.builder(
        itemCount: productsOnSale.length < 10 ? productsOnSale.length : 10,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) {
            print('Building item at index $index');
      
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: ChangeNotifierProvider.value(
              value: productsOnSale[index],
              child: OnSaleWidget()
      
      ,
            ),
          );
        },
      ),
    );
  }
  

  Widget _buildProductGrid(List<ProductModel> allProducts, Size size) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 600 ? 4 : 2,
        childAspectRatio: size.width > 600 ? 0.7 : 0.68,
        crossAxisSpacing: size.width * 0.03,
        mainAxisSpacing: size.height * 0.02,
      ),
      itemCount: allProducts.length < 4 ? allProducts.length : 4,
      itemBuilder: (ctx, index) {
        return ChangeNotifierProvider.value(
          value: allProducts[index],
          child: const FeedsWidget(),
        );
      },
    );
  }
}