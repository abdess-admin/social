import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview placeholder
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Video recording & upload\nwill be implemented in Step 4',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Top controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () {
                      // Close camera
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.flash_off, color: Colors.white, size: 28),
                        onPressed: () {
                          // Toggle flash
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 28),
                        onPressed: () {
                          // Switch camera
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bottom controls
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.photo_library, color: Colors.white),
                      ),
                      // Capture button
                      GestureDetector(
                        onTap: () {
                          // Capture photo/video
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Effects button
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.auto_fix_high, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Mode selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeButton('Photo', false),
                      const SizedBox(width: 24),
                      _buildModeButton('Video', true),
                      const SizedBox(width: 24),
                      _buildModeButton('Story', false),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, bool isSelected) {
    return Text(
      label,
      style: TextStyle(
        color: isSelected ? Colors.white : Colors.grey,
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
