import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authToken = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).accentColor,
            )),
        child: Column(
          children: [
            Container(
              child: Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ProductDetailScreen.routeName,
                      arguments: product.id,
                    );
                  },
                  child: Hero(
                    tag: product.id,
                    child: FadeInImage(
                      placeholder:
                          AssetImage('assets/images/product-placeholder.png'),
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              product.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '${product.price} EGP',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    cart.addItem(product.id, product.price, product.title);
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added item to cart!',
                        ),
                        duration: Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            cart.removeSingleItem(product.id);
                          },
                        ),
                      ),
                    );
                  },
                  color: Colors.green,
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                Consumer<Product>(
                  builder: (ctx, product, _) => IconButton(
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      product.toggleFavoriteStatus(
                          authToken.token, authToken.userId);
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
