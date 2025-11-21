// ═══════════════════════════════════════════════════════════
// 📡 INDICADOR DE CONEXIÓN
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class ConnectionIndicator extends StatelessWidget {
  final bool isConnected;

  const ConnectionIndicator({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected 
            ? AppColors.safe.withOpacity(0.2) 
            : AppColors.danger.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected ? AppColors.safe : AppColors.danger,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? AppColors.safe : AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'Conectado' : 'Desconectado',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isConnected ? AppColors.safe : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
