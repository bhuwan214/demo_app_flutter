// import 'package:flutter/material.dart';
// import'productpage.dart';

// class BottomBarExample extends StatefulWidget {
//   const BottomBarExample({super.key});

//   @override
//   State<BottomBarExample> createState() => _BottomBarExampleState();
// }

// class _BottomBarExampleState extends State<BottomBarExample> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const Center(child: Text("🏠 Home Page")),
//     const ProductPage(),
//     const Center(child: Text("🛒 Cart Page")),
//     const Center(child: Text("👤 Profile Page")),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Shop"),
//         backgroundColor: Colors.teal,
//         centerTitle: true,
//       ),
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: Colors.teal,
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: "Home",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_bag),
//             label: "Products",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: "Cart",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Profile",
//           ),
//         ],
//       ),
//     );
//   }
// }
