import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Animated radar and scanning beam effect over the plant image during AI diagnosis.
class AnalysisLoadingView extends StatefulWidget {
  const AnalysisLoadingView({
    super.key,
    required this.imagePath,
    required this.stageMessage,
  });

  final String imagePath;
  final String stageMessage;

  @override
  State<AnalysisLoadingView> createState() => _AnalysisLoadingViewState();
}

class _AnalysisLoadingViewState extends State<AnalysisLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Plant Image Container with Scanning Beam
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radius16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radius16 - 2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base Plant Image
                File(widget.imagePath).existsSync()
                    ? Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.sageGreen,
                        child: const Icon(
                          Icons.local_florist_rounded,
                          size: 64,
                          color: AppColors.primaryGreen,
                        ),
                      ),

                // Dark botanical overlay for scanning contrast
                Container(
                  color: AppColors.darkGreen.withValues(alpha: 0.25),
                ),

                // Animated Scanning Laser Line
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment(0, (_scanAnimation.value * 2) - 1),
                      child: Container(
                        width: double.infinity,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.9),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Corner brackets
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildCorner(true, true),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildCorner(true, false),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: _buildCorner(false, true),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: _buildCorner(false, false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space32),

        // Indeterminate Circular Spinner in Primary Green
        const SizedBox(
          width: 38,
          height: 38,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: AppSpacing.space20),

        // Live Stage Text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.stageMessage.isEmpty
                ? 'Diagnosing plant health...'
                : widget.stageMessage,
            key: ValueKey<String>(widget.stageMessage),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),

        const Text(
          'AI is evaluating tissue coloration and leaf symptoms',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}
