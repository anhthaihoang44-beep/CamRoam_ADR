import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/coord_formatter.dart';

enum OverlayStyle { classic, modern, cyberHud }

class GpsCameraScreen extends StatefulWidget {
  const GpsCameraScreen({super.key});

  @override
  State<GpsCameraScreen> createState() => _GpsCameraScreenState();
}

class _GpsCameraScreenState extends State<GpsCameraScreen> {
  CameraController? _camController;
  List<CameraDescription> _cameras = [];
  int _selectedCamera = 0;
  bool _flashOn = false;

  // Overlay toggles
  bool _showAddress = true;
  bool _showTime = true;
  bool _showDate = true;
  bool _showCoords = true;
  OverlayStyle _overlayStyle = OverlayStyle.classic;

  // GPS data
  String _address = 'Fetching location...';
  String _coords = '';
  String _time = '';
  String _date = '';

  bool _isTaking = false;
  String? _lastPhotoPath;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _startGps();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    await _setupCamera(_selectedCamera);
  }

  Future<void> _setupCamera(int index) async {
    _camController?.dispose();
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await controller.initialize();
      if (mounted) {
        setState(() => _camController = controller);
      }
    } catch (_) {}
  }

  void _startGps() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
        ).listen((pos) async {
          final now = DateTime.now();
          final coordStr = CoordFormatter.format(pos.latitude, pos.longitude);
          String addrStr = '$coordStr';
          try {
            final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
            if (placemarks.isNotEmpty) {
              final p = placemarks.first;
              addrStr = '${p.street ?? ''}, ${p.locality ?? ''}'.replaceAll(RegExp(r'^,\s*'), '');
            }
          } catch (_) {}

          if (mounted) {
            setState(() {
              _address = addrStr;
              _coords = coordStr;
              _time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
              _date = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
            });
          }
        });
      } else {
        setState(() {
          _address = 'Permission denied';
          _coords = '';
        });
      }
    } catch (_) {}
  }

  Future<void> _takePhoto() async {
    if (_isTaking || _camController == null || !_camController!.value.isInitialized) return;
    setState(() => _isTaking = true);
    try {
      final xFile = await _camController!.takePicture();
      final Uint8List rawBytes = await xFile.readAsBytes();
      final Uint8List watermarked = await _burnOverlay(rawBytes);

      final tmpDir = await getTemporaryDirectory();
      final path = '${tmpDir.path}/roamcam_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(path).writeAsBytes(watermarked);

      await Gal.putImage(path, album: 'RoamCam');
      setState(() => _lastPhotoPath = path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📸 Photo saved to gallery!'),
            backgroundColor: AppColors.emerald.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () => Share.shareXFiles(
                [XFile(path)],
                text: 'Captured with RoamCam',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.liveRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  Future<Uint8List> _burnOverlay(Uint8List rawBytes) async {
    final image = img.decodeImage(rawBytes);
    if (image == null) return rawBytes;

    // Build overlay text lines
    final lines = <String>[];
    if (_showAddress && _address.isNotEmpty) lines.add('📍 $_address');
    if (_showTime && _time.isNotEmpty) lines.add('🕐 $_time');
    if (_showDate && _date.isNotEmpty) lines.add('📅 $_date');
    if (_showCoords && _coords.isNotEmpty) lines.add('🛰️ $_coords');

    if (lines.isEmpty) return img.encodeJpg(image, quality: 92) as Uint8List;

    // Draw text box
    final boxH = 22 * lines.length + 20;
    final boxW = 440;
    final x0 = 20;
    final y0 = 20;

    for (int by = y0; by < y0 + boxH && by < image.height; by++) {
      for (int bx = x0; bx < x0 + boxW && bx < image.width; bx++) {
        final pixel = image.getPixel(bx, by);
        // Darken pixels for semi-transparent overlay
        image.setPixel(
          bx, by,
          img.ColorFloat32.rgb(
            pixel.r * 0.3,
            pixel.g * 0.3,
            pixel.b * 0.3,
          ),
        );
      }
    }

    // Draw each line with img library drawString
    for (int i = 0; i < lines.length; i++) {
      img.drawString(
        image,
        lines[i],
        font: img.arial14,
        x: x0 + 10,
        y: y0 + 10 + i * 22,
        color: img.ColorRgb8(0, 229, 255), // AppColors.cyan
      );
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 92));
  }

  @override
  void dispose() {
    _camController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasCamera = _camController != null && _camController!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (hasCamera)
            Positioned.fill(child: CameraPreview(_camController!))
          else
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 60, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('Camera unavailable', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),

          // Overlay HUD
          if (hasCamera)
            Positioned(
              top: 100,
              left: 16,
              child: _buildOverlayWidget(),
            ),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    _CamButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.pop(),
                    ),
                    // Style selector
                    DropdownButton<OverlayStyle>(
                      value: _overlayStyle,
                      dropdownColor: AppColors.surfaceCard,
                      style: const TextStyle(color: AppColors.cyan, fontSize: 12),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.tune, color: AppColors.cyan, size: 18),
                      items: const [
                        DropdownMenuItem(value: OverlayStyle.classic, child: Text('Classic')),
                        DropdownMenuItem(value: OverlayStyle.modern, child: Text('Modern')),
                        DropdownMenuItem(value: OverlayStyle.cyberHud, child: Text('Cyber HUD')),
                      ],
                      onChanged: (v) => setState(() => _overlayStyle = v!),
                    ),
                    // Flash
                    _CamButton(
                      icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                      onTap: () async {
                        setState(() => _flashOn = !_flashOn);
                        await _camController?.setFlashMode(
                          _flashOn ? FlashMode.torch : FlashMode.off,
                        );
                      },
                    ),
                    // Flip camera
                    _CamButton(
                      icon: Icons.flip_camera_ios_rounded,
                      onTap: () async {
                        _selectedCamera = (_selectedCamera + 1) % _cameras.length;
                        await _setupCamera(_selectedCamera);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overlay toggles row
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _ToggleChip(label: 'Address', enabled: _showAddress, onToggle: (v) => setState(() => _showAddress = v)),
                  const SizedBox(width: 6),
                  _ToggleChip(label: 'Time', enabled: _showTime, onToggle: (v) => setState(() => _showTime = v)),
                  const SizedBox(width: 6),
                  _ToggleChip(label: 'Date', enabled: _showDate, onToggle: (v) => setState(() => _showDate = v)),
                  const SizedBox(width: 6),
                  _ToggleChip(label: 'Coords', enabled: _showCoords, onToggle: (v) => setState(() => _showCoords = v)),
                ],
              ),
            ),
          ),

          // Bottom shutter bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: GestureDetector(
                    onTap: _takePhoto,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: _isTaking ? 68 : 76,
                      height: _isTaking ? 68 : 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isTaking ? AppColors.cyan.withOpacity(0.7) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayWidget() {
    final lines = <String>[];
    if (_showAddress) lines.add(_address);
    if (_showTime) lines.add(_time);
    if (_showDate) lines.add(_date);
    if (_showCoords) lines.add(_coords);

    if (lines.isEmpty) return const SizedBox.shrink();

    switch (_overlayStyle) {
      case OverlayStyle.classic:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: _buildLines(lines, AppColors.textPrimary),
        );
      case OverlayStyle.modern:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((l) => Text(l, style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            shadows: [Shadow(blurRadius: 6, color: Colors.black)],
          ))).toList(),
        );
      case OverlayStyle.cyberHud:
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cyan, width: 1.2),
              ),
              child: _buildLines(lines, AppColors.cyan),
            ),
            Positioned(
              top: -1,
              left: -1,
              child: Container(width: 10, height: 2, color: AppColors.cyan),
            ),
            Positioned(
              top: -1,
              left: -1,
              child: Container(width: 2, height: 10, color: AppColors.cyan),
            ),
          ],
        );
    }
  }

  Widget _buildLines(List<String> lines, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines.map((l) => Text(l, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w600))).toList(),
    );
  }
}

class _CamButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CamButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _ToggleChip({required this.label, required this.enabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!enabled),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? AppColors.cyan.withOpacity(0.8) : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: enabled ? AppColors.cyan : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.black : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

