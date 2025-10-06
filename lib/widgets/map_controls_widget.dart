import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';

class MapControlsWidget extends StatelessWidget {
  const MapControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF151515) : Colors.grey[900];
    
    return Container(
      width: 48,
      height: 96, // Увеличено в два раза (48 * 2)
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: 20, // Увеличен размер иконки
              ),
              onPressed: () {
                context.read<MapProvider>().zoomIn();
              },
            ),
          ),
          Container(
            height: 1,
            color: Colors.white24,
          ),
          Expanded(
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.zoom_out,
                color: Colors.white,
                size: 20, // Увеличен размер иконки
              ),
              onPressed: () {
                context.read<MapProvider>().zoomOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

