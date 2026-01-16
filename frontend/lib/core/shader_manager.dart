import 'dart:ui';
import 'package:flutter/services.dart';

class ShaderManager {
  static final ShaderManager _instance = ShaderManager._internal();
  factory ShaderManager() => _instance;
  ShaderManager._internal();

  FragmentProgram? nebulaProgram;

  Future<void> initialize() async {
    try {
      nebulaProgram = await FragmentProgram.fromAsset('shaders/nebula.frag');
    } catch (e) {
      // Fallback or log error
      print('Failed to load shader: $e');
    }
  }

  bool get isReady => nebulaProgram != null;
}
