import 'package:flutter/material.dart';

class NavigationBarBuild extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const NavigationBarBuild({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBarBuild> {
  Widget _buildNavItem(IconData icon, int index, String label) {
    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: widget.selectedIndex == index ? Colors.blue : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: widget.selectedIndex == index ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withAlpha(20),
        //     blurRadius: 10,
        //     spreadRadius: 5,
        //   ),
        // ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 0, 'Trang chủ'),
          _buildNavItem(Icons.dashboard, 1, 'Danh mục'),
          _buildNavItem(Icons.favorite, 2, 'Yêu thích'),
          _buildNavItem(Icons.settings, 3, 'Cài đặt'),
        ],
      ),
    );
  }
}
