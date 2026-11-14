import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/plant_health_report_entity.dart';

/// Card presenting high-level botanical health condition, severity, and health score.
class HealthStatusCard extends StatelessWidget {
  const HealthStatusCard({
    super.key,
    required this.report,
  });

  final PlantHealthReportEntity report;

  Color _getSeverityColor(HealthSeverity severity) {
    switch (severity) {
      case HealthSeverity.none:
        return const Color(0xFF2E7D32); // Deep emerald
      case HealthSeverity.mild:
        return const Color(0xFFE65100); // Warm amber
      case HealthSeverity.moderate:
        return const Color(0xFFD84315); // Rust orange
      case HealthSeverity.severe:
        return const Color(0xFFC62828); // Crimson
    }
  }

  Color _getSeverityBg(HealthSeverity severity) {
    switch (severity) {
      case HealthSeverity.none:
        return const Color(0xFFE8F5E9);
      case HealthSeverity.mild:
        return const Color(0xFFFFF3E0);
      case HealthSeverity.moderate:
        return const Color(0xFFFBE9E7);
      case HealthSeverity.severe:
        return const Color(0xFFFFEBEE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(report.severity);
    final severityBg = _getSeverityBg(report.severity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.sageGreen.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Status badge and Health Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Severity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: severityBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: severityColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: severityColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${report.severity.label} Severity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: severityColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Health Score Gauge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.sageGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 14,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${report.healthScore}/100 Health',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space16),

          // Primary Status Title
          Text(
            report.healthStatus,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),

          // Botanical Name & Confidence
          Row(
            children: [
              const Icon(
                Icons.spa_rounded,
                size: 16,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  report.scientificName != null
                      ? '${report.plantName} (${report.scientificName})'
                      : report.plantName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warmIvory,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${report.confidence}% Match',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
