import 'dart:math' as math;

import 'package:dawg/common_defines.dart';
import 'package:dawg/ui/avatar/wireframe_equipment.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:flutter/material.dart';

class WireframeAvatarPainter extends CustomPainter {
  WireframeAvatarPainter({
    required this.pose,
    required this.color,
    this.equipment = const [],
    this.strokeWidth = 2.5,
    this.jointRadius = 4.0,
    this.headRadiusFactor = 0.045,
    this.paddingFactor = 0.08,
    this.figureAspectRatio = 0.45,
  });

  final WireframePose pose;
  final Color color;
  final List<Equipment> equipment;
  final double strokeWidth;
  final double jointRadius;
  final double headRadiusFactor;
  final double paddingFactor;

  /// Width divided by height of the figure layout box (standing person is taller than wide).
  final double figureAspectRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = _figureBounds(size);
    final scale = bounds.height / 200;

    final jointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final bonePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final headCenter = _mapJoint(pose.headJoint, bounds);
    final headRadius = bounds.height * headRadiusFactor;
    final dotRadius = jointRadius * scale;

    canvas.drawCircle(headCenter, headRadius, bonePaint);

    for (final bone in pose.bones) {
      final from = pose.joints[bone.from];
      final to = pose.joints[bone.to];
      if (from == null || to == null) continue;

      final linePaint = WireframeEquipment.equipmentForBone(bone, equipment) != null
          ? (Paint()
            ..color = WireframeEquipment.colorFor(WireframeEquipment.equipmentForBone(bone, equipment)!)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth *
                scale *
                WireframeEquipment.strokeScaleFor(WireframeEquipment.equipmentForBone(bone, equipment)!)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round)
          : bonePaint;

      canvas.drawLine(_mapPoint(from, bounds), _mapPoint(to, bounds), linePaint);
    }

    for (final entry in pose.joints.entries) {
      if (entry.key == pose.headJoint) continue;
      if (WireframeEquipment.isEquipmentJoint(entry.key) &&
          !WireframeEquipment.isWeightPlateJoint(entry.key)) {
        continue;
      }

      if (WireframeEquipment.isWeightPlateJoint(entry.key)) {
        final platePaint = Paint()
          ..color = WireframeEquipment.freeWeightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * scale * 1.1;
        canvas.drawCircle(_mapPoint(entry.value, bounds), dotRadius * 2.4, platePaint);
        continue;
      }

      canvas.drawCircle(_mapPoint(entry.value, bounds), dotRadius, jointPaint);
    }
  }

  /// Fits the figure inside [size] with uniform scaling and centers it.
  Rect _figureBounds(Size size) {
    final padding = size.shortestSide * paddingFactor;
    final availW = math.max(0.0, size.width - padding * 2);
    final availH = math.max(0.0, size.height - padding * 2);

    late double figW;
    late double figH;

    if (availW / availH > figureAspectRatio) {
      figH = availH;
      figW = figH * figureAspectRatio;
    } else {
      figW = availW;
      figH = figW / figureAspectRatio;
    }

    final left = (size.width - figW) / 2;
    final top = (size.height - figH) / 2;
    return Rect.fromLTWH(left, top, figW, figH);
  }

  Offset _mapJoint(String jointId, Rect bounds) {
    final point = pose.joints[jointId];
    if (point == null) return bounds.center;
    return _mapPoint(point, bounds);
  }

  Offset _mapPoint(Offset normalized, Rect bounds) {
    return Offset(
      bounds.left + normalized.dx * bounds.width,
      bounds.top + normalized.dy * bounds.height,
    );
  }

  @override
  bool shouldRepaint(covariant WireframeAvatarPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.color != color ||
        oldDelegate.equipment != equipment ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.figureAspectRatio != figureAspectRatio;
  }
}
