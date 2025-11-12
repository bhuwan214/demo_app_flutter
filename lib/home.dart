import 'package:flutter/material.dart';
import 'productpage.dart';
import 'profile_page.dart';
// import 'widget/themetoggle.dart';

class HomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomePage({
    Key? key,
    required this.themeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    // final theme = Theme.of(context);

      final pages = [
      HomeBody(
        // themeMode: widget.themeMode,
        // onThemeChanged: widget.onThemeChanged,
      ),
      const ProductPage(),
      const Center(child: Text("🛒 Cart Page....")),
     ProfilePage(
         themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
     ),
    ];

    return Scaffold(
      // body: ThemeToggle(widget: widget),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Products",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: "Profile"),
        ],
      ),
    );
  }
}


class HomeBody extends StatelessWidget{
   
   const HomeBody({
    super.key,
 
   });

   @override 
   Widget build(BuildContext context){
    return  ListView(
      padding:const EdgeInsets.all(16),
      children:[const SizedBox(height:10),
      // ThemeToggle(themeMode:themeMode,
      // onThemeChanged:onThemeChanged),
      
      SizedBox(height: 30,),

     ]
      );
   }
   
}


