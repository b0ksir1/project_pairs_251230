import 'package:flutter/material.dart';

class AdminSideItem extends StatelessWidget {

  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const AdminSideItem({
    super.key,
    required this.icon,
    required this.text,
    required this.selected,
    required this.onTap,
  });

 @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF1E293B) : Colors.transparent;
    final color = selected ? Colors.white : const Color(0xFF9CA3AF);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(fontSize: 13, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}