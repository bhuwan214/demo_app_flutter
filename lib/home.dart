import 'package:flutter/material.dart';
import 'productpage.dart';

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

    final theme = Theme.of(context);

      final pages = [
      HomeBody(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      const ProductPage(),
      const Center(child: Text("🛒 Cart Page....")),
      const Center(child: Text("👤 Profile Page")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home — Theme Demo'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
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
   
   final ThemeMode themeMode;
   final ValueChanged<ThemeMode> onThemeChanged;

   const HomeBody({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
   });

   @override 
   Widget build(BuildContext context){
    return  ListView(
      padding:const EdgeInsets.all(16),
      children:[const SizedBox(height:10),
      ThemeToggle(themeMode:themeMode,
      onThemeChanged:onThemeChanged),
      
      SizedBox(height: 30,),
   const Text(
          "🏠 Welcome to Home Page!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),      ]
      );
   }
   
}




class ThemeToggle extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ThemeToggle({super.key, required this.themeMode, required this.onThemeChanged,});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                "Light mode",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: themeMode == ThemeMode.dark,

                onChanged: (v) =>
                    onThemeChanged(v ? ThemeMode.dark : ThemeMode.light),
              ),
              const SizedBox(width: 8),
              Text(
                'Dark mode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
