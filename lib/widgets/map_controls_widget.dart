import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../providers/theme_provider.dart';

class MapControlsWidget extends StatelessWidget {
  const MapControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          width: 48,
          height: 96, // Увеличено в два раза (48 * 2)
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Expanded(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.zoom_in,
                    color: themeProvider.textColor,
                    size: 20, // Увеличен размер иконки
                  ),
                  onPressed: () {
                    context.read<MapProvider>().zoomIn();
                  },
                ),
              ),
              Container(
                height: 1,
                color: themeProvider.textColor.withOpacity(0.3),
              ),
              Expanded(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.zoom_out,
                    color: themeProvider.textColor,
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
      },
    );
  }
}

