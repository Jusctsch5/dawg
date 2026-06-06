import 'dart:math' as math;

import 'package:dawg/common_defines.dart';
import 'package:dawg/ui/avatar/wireframe_camera.dart';
import 'package:dawg/ui/avatar/wireframe_equipment.dart';
import 'package:dawg/ui/avatar/wireframe_figure.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:dawg/ui/avatar/wireframe_pose_3d.dart';
import 'package:dawg/ui/avatar/wireframe_avatar_painter.dart';
import 'package:flutter/material.dart';

/// Builds the correct [CustomPainter] for a [WireframeFigurePose].
class WireframePainterFactory {
  static CustomPainter create({
    required WireframeFigurePose pose,
    required Color color,
    List<Equipment> equipment = const [],
    double strokeWidth = 2.5,
    double jointRadius = 4.0,
    double headRadiusFactor = 0.045,
    double paddingFactor = 0.08,
    double figureAspectRatio = 0.45,
    WireframeCamera? camera,
  }) {
    final resolvedCamera = camera ?? WireframeCamera.workout;
    if (pose is FlatWireframeFigurePose) {
      return WireframeAvatarPainter(
        pose: pose.pose,
        color: color,
        equipment: equipment,
        strokeWidth: strokeWidth,
        jointRadius: jointRadius,
        headRadiusFactor: headRadiusFactor,
        paddingFactor: paddingFactor,
        figureAspectRatio: figureAspectRatio,
      );
    }

    if (pose is ProjectedWireframeFigurePose) {
      return WireframeAvatar3dPainter(
        pose: pose.pose,
        color: color,
        equipment: equipment,
        strokeWidth: strokeWidth * 0.52,
        jointRadius: 1.2,
        headRadiusFactor: headRadiusFactor * 0.8,
        paddingFactor: paddingFactor,
        figureAspectRatio: figureAspectRatio,
        camera: resolvedCamera,
      );
    }

    throw ArgumentError('Unknown WireframeFigurePose: ${pose.runtimeType}');
  }
}

/// Volumetric 3D wireframe: front/back shells, depth posts, depth-sorted draw.
class WireframeAvatar3dPainter extends CustomPainter {
  WireframeAvatar3dPainter({
    required this.pose,
    required this.color,
    this.equipment = const [],
    this.strokeWidth = 1.3,
    this.jointRadius = 1.2,
    this.headRadiusFactor = 0.045,
    this.paddingFactor = 0.08,
    this.figureAspectRatio = 0.45,
    this.camera,
  });

  final WireframePose3d pose;
  final Color color;
  final List<Equipment> equipment;
  final double strokeWidth;
  final double jointRadius;
  final double headRadiusFactor;
  final double paddingFactor;
  final double figureAspectRatio;
  final WireframeCamera? camera;

  WireframeCamera get _camera => camera ?? WireframeCamera.workout;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = _figureBounds(size);
    final scale = bounds.height / 200;
    final projected = <String, Offset>{};
    final depth = <String, double>{};

    for (final entry in pose.joints.entries) {
      projected[entry.key] = _mapPoint(_camera.projectNormalized(entry.value), bounds);
      depth[entry.key] = _camera.depthKey(entry.value);
    }

    final sortedBones = pose.bones.toList()
      ..sort((a, b) {
        final za = _boneDepth(a, depth);
        final zb = _boneDepth(b, depth);
        return za.compareTo(zb);
      });

    final dotRadius = jointRadius * scale;
    final headCenter = projected[pose.headJoint] ?? bounds.center;
    final headRadius = bounds.height * headRadiusFactor;

    for (final bone in sortedBones) {
      final from = projected[bone.from];
      final to = projected[bone.to];
      if (from == null || to == null) continue;

      final bonePaint = Paint()
        ..color = _boneColor(bone, depth)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _boneStrokeWidth(bone, scale)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (WireframeEquipment.equipmentForBone(bone, equipment) != null) {
        _styleEquipmentBone(bonePaint, bone, scale);
      }

      canvas.drawLine(from, to, bonePaint);
    }

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * scale;

    canvas.drawCircle(headCenter, headRadius, headPaint);

    final sortedJoints = pose.joints.keys.toList()
      ..sort((a, b) => (depth[a] ?? 0).compareTo(depth[b] ?? 0));

    for (final jointId in sortedJoints) {
      if (jointId == pose.headJoint) continue;
      if (WireframeEquipment.isEquipmentJoint(jointId) &&
          !WireframeEquipment.isWeightPlateJoint(jointId)) {
        continue;
      }
      final point = projected[jointId];
      if (point == null) continue;

      if (WireframeEquipment.isWeightPlateJoint(jointId)) {
        final platePaint = Paint()
          ..color = WireframeEquipment.freeWeightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * scale * 1.1;
        canvas.drawCircle(point, dotRadius * 2.2, platePaint);
        continue;
      }

      final alpha = _jointAlpha(jointId, depth[jointId] ?? 0);
      final jointPaint = Paint()
        ..color = color.withOpacity(alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, dotRadius * _jointSizeScale(jointId) * (0.7 + alpha * 0.3), jointPaint);
    }
  }

  void _styleEquipmentBone(Paint paint, WireframeBone bone, double scale) {
    final item = WireframeEquipment.equipmentForBone(bone, equipment);
    if (item == null) return;
    paint
      ..color = WireframeEquipment.colorFor(item)
      ..strokeWidth = strokeWidth * scale * WireframeEquipment.strokeScaleFor(item);
  }

  double _boneDepth(WireframeBone bone, Map<String, double> depth) {
    final a = depth[bone.from] ?? 0;
    final b = depth[bone.to] ?? 0;
    return (a + b) / 2;
  }

  Color _boneColor(WireframeBone bone, Map<String, double> depth) {
    final layer = _boneLayer(bone);
    switch (layer) {
      case _BoneLayer.depthPost:
        return color.withOpacity(0.62);
      case _BoneLayer.back:
        return color.withOpacity(0.58);
      case _BoneLayer.backLimb:
        return color.withOpacity(0.62);
      case _BoneLayer.front:
      case _BoneLayer.spine:
        return color;
    }
  }

  double _boneStrokeWidth(WireframeBone bone, double scale) {
    final layer = _boneLayer(bone);
    final base = strokeWidth * scale;
    switch (layer) {
      case _BoneLayer.depthPost:
        return base * 0.75;
      case _BoneLayer.back:
      case _BoneLayer.backLimb:
        return base * 0.85;
      case _BoneLayer.front:
      case _BoneLayer.spine:
        return base;
    }
  }

  _BoneLayer _boneLayer(WireframeBone bone) {
    final from = bone.from;
    final to = bone.to;
    if (_isDepthPost(from, to)) return _BoneLayer.depthPost;
    if (_isBack(from) && _isBack(to)) return _BoneLayer.back;
    if (_isBack(from) || _isBack(to)) return _BoneLayer.backLimb;
    if (from == 'head' || from == 'neck' || from == 'chest' || from == 'pelvis') {
      return _BoneLayer.spine;
    }
    return _BoneLayer.front;
  }

  bool _isDepthPost(String a, String b) {
    return (_isFront(a) && _isBack(b)) || (_isBack(a) && _isFront(b));
  }

  bool _isFront(String id) {
    return id.endsWith('FL') ||
        id.endsWith('FR') ||
        id == 'chest' ||
        id == 'pelvis' ||
        id.startsWith('rib') && (id.endsWith('FL') || id.endsWith('FR'));
  }

  bool _isBack(String id) {
    return id.endsWith('BL') ||
        id.endsWith('BR') ||
        id == 'chestBack' ||
        id == 'pelvisBack' ||
        id.startsWith('rib') && (id.endsWith('BL') || id.endsWith('BR'));
  }

  double _jointSizeScale(String id) {
    if (id.startsWith('grip')) return 1.15;
    if (id.startsWith('arm') || id.startsWith('thigh') || id.startsWith('shin')) return 0.55;
    if (id.startsWith('rib')) return 0.45;
    if (id.startsWith('elbow') || id.startsWith('knee') || id.startsWith('wrist') || id.startsWith('ankle')) {
      return 0.75;
    }
    return 0.9;
  }

  double _jointAlpha(String id, double z) {
    if (_isBack(id)) return 0.58;
    if (id == 'chestBack' || id == 'pelvisBack') return 0.62;
    return 1.0;
  }

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

  Offset _mapPoint(Offset normalized, Rect bounds) {
    return Offset(
      bounds.left + normalized.dx * bounds.width,
      bounds.top + normalized.dy * bounds.height,
    );
  }

  @override
  bool shouldRepaint(covariant WireframeAvatar3dPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.color != color ||
        oldDelegate.equipment != equipment ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate._camera.yaw != _camera.yaw;
  }
}

enum _BoneLayer { spine, front, back, backLimb, depthPost }
