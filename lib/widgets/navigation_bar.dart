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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const selectedColor = Colors.blue;

    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: widget.selectedIndex == index
                ? selectedColor
                : (isDarkMode ? Colors.white54 : Colors.grey),
          ),
          Text(
            label,
            style: TextStyle(
              color: widget.selectedIndex == index
                  ? selectedColor
                  : (isDarkMode ? Colors.white54 : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: 65,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: isDarkMode
        //     ? []
        //     : [
        //         BoxShadow(
        //           color: Colors.black.withAlpha(20),
        //           blurRadius: 10,
        //           spreadRadius: 5,
        //         ),
        //       ],
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
