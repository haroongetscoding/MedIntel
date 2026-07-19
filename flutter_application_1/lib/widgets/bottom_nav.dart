// *bottom nav*
// // import 'package:flutter/material.dart';

// // class MedIntelBottomNav extends StatelessWidget {
// //   final int currentIndex;
// //   final Function(int) onTap;

// //   const MedIntelBottomNav({
// //     Key? key,
// //     required this.currentIndex,
// //     required this.onTap,
// //   }) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         color: Color(0xFF1962A1),
// //         borderRadius: BorderRadius.only(
// //           topLeft: Radius.circular(30),
// //           topRight: Radius.circular(30),
// //         ),
// //       ),
// //       child: ClipRRect(
// //         borderRadius: const BorderRadius.only(
// //           topLeft: Radius.circular(30),
// //           topRight: Radius.circular(30),
// //         ),
// //         child: BottomNavigationBar(
// //           currentIndex: currentIndex,
// //           onTap: onTap,
// //           type: BottomNavigationBarType.fixed,
// //           backgroundColor: const Color(0xFF1962A1),
// //           selectedItemColor: Colors.white,
// //           unselectedItemColor: Colors.white60,
// //           showSelectedLabels: false,
// //           showUnselectedLabels: false,
// //           items: const [
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.home_filled, size: 28),
// //               label: 'Home',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.chat_bubble_outline_rounded, size: 26),
// //               label: 'AI Chat',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.calendar_month_outlined, size: 26),
// //               label: 'Appointments',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.search_rounded, size: 28),
// //               label: 'Search',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.person_outline_rounded, size: 28),
// //               label: 'Profile',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';

// class MedIntelBottomNav extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const MedIntelBottomNav({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFF1962A1),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//         child: BottomNavigationBar(
//           currentIndex: currentIndex,
//           onTap: onTap,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: const Color(0xFF1962A1),
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white60,
//           showSelectedLabels: false,
//           showUnselectedLabels: false,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_filled, size: 28),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.chat_bubble_outline_rounded, size: 26),
//               label: 'AI Chat',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_month_outlined, size: 26),
//               label: 'Appointments',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.search_rounded, size: 28),
//               label: 'Search',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline_rounded, size: 28),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class MedIntelBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MedIntelBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.chat_bubble_rounded,
    Icons.task_alt_rounded,
    Icons.search_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF1962A1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_icons.length, (index) {
              final isSelected = currentIndex == index;

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: isSelected ? 44 : 38,
                  height: isSelected ? 44 : 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.18)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icons[index],
                    color: Colors.white,
                    size: isSelected ? 24 : 21,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}