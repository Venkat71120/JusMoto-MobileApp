import 'package:flutter/material.dart';

class ImagePLWidget extends StatelessWidget {
  final double size;
  const ImagePLWidget({
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: size,
          width: size,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/loading_image.png'),
                  opacity: .5)),
        ),
      ],
    );
  }
}
