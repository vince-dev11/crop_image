import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Image Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Crop Image Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final CropController controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  double rotationValue = 0;

  ui.Image? croppedImage;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Column(
        children: [

          Expanded(
            child: CropImage(
              controller: controller,
              image: Image.asset('assets/sample.jpg'),
              paddingSize: 25,
              alwaysMove: true,
              maximumImageSize: 500,
            ),
          ),

          const SizedBox(height: 10),

          /// ROTATION SLIDER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [

                const Text("Rotation"),

                Slider(
                  min: -45,
                  max: 45,
                  value: rotationValue,
                  onChanged: (v) {

                    setState(() {
                      rotationValue = v;
                    });

                    controller.rotate(v);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          _buildButtons(),

          const SizedBox(height: 10),

          if (croppedImage != null)
            SizedBox(
              height: 200,
              child: Image(
                image: UiImageProvider(croppedImage!),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildButtons() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        /// RESET
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {

            controller.rotation = const CropRotation(0);
            controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
            controller.aspectRatio = 1;

            setState(() {
              rotationValue = 0;
            });
          },
        ),

        /// ASPECT RATIO
        IconButton(
          icon: const Icon(Icons.aspect_ratio),
          onPressed: _aspectRatios,
        ),

        /// ROTATE LEFT
        IconButton(
          icon: const Icon(Icons.rotate_left),
          onPressed: () {

            controller.rotateLeft(5);

            setState(() {
              rotationValue -= 5;
            });
          },
        ),

        /// ROTATE RIGHT
        IconButton(
          icon: const Icon(Icons.rotate_right),
          onPressed: () {

            controller.rotateRight(5);

            setState(() {
              rotationValue += 5;
            });
          },
        ),

        /// CROP
        TextButton(
          onPressed: _finished,
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> _aspectRatios() async {

    final value = await showDialog<double>(
      context: context,
      builder: (context) {

        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [

            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1),
              child: const Text('Free'),
            ),

            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1),
              child: const Text('Square'),
            ),

            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2),
              child: const Text('2:1'),
            ),

            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),

            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4 / 3),
              child: const Text('4:3'),
            ),

            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16 / 9),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );

    if (value != null) {

      controller.aspectRatio = value == -1 ? null : value;

      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _finished() async {

    final image = await controller.croppedBitmap();

    setState(() {
      croppedImage = image;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Cropped Image"),
          content: SizedBox(
            height: 250,
            child: Image(
              image: UiImageProvider(image),
            ),
          ),
        );
      },
    );
  }
}