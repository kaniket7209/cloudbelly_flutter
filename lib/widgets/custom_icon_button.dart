import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomIconButton extends StatelessWidget {
  IconData ic;
  Color color;
  Color boxColor;
  String text;

  final Function? onTap;
  CustomIconButton(
      {required this.ic,
      this.onTap,
      this.color = Colors.cyan,
      this.boxColor = Colors.white,
      this.text = ''});

  @override
  Widget build(BuildContext context) {
    if (color == Colors.cyan) color = Color.fromRGBO(38, 115, 140, 1);
    return TouchableOpacity(
      onTap: onTap as void Function()?,
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          shadows: [
            BoxShadow(
              offset: Offset(0, 4),
              color: Color.fromRGBO(31, 111, 109, 0.5),
              blurRadius: 20,
            )
          ],
          color: boxColor,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 10,
              cornerSmoothing: 1,
            ),
          ),
        ),
        child: text == ''
            ? Icon(
                ic,
                color: color,
              )
            : text == 'notification'
                ? Transform.rotate(
                    angle: 25 * 3.1415926535 / 180, //
                    child: Icon(
                      ic,
                      color: color,
                    ),
                  )
                : Center(
                    child: Text(
                      '<<',
                      style: TextStyle(
                        color: Color(0xFFFA6E00),
                        fontSize: 24,
                        fontFamily: 'Kavoon',
                        fontWeight: FontWeight.w900,
                        height: 0.04,
                        letterSpacing: 0.66,
                      ),
                    ),
                  ),
      ),
    );
  }
}

class ZoomIconButton extends StatefulWidget {
  final bool IsLiked;
  final Function setLikeToFeed;

  ZoomIconButton({required this.IsLiked, required this.setLikeToFeed});

  @override
  _ZoomIconButtonState createState() => _ZoomIconButtonState();
}

class _ZoomIconButtonState extends State<ZoomIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _liked = false;

  @override
  void initState() {
    print(widget.IsLiked);
    super.initState();
    setState(() {
      _liked = widget.IsLiked;
    });
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addListener(() {
      setState(() {});
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    widget.setLikeToFeed(!_liked);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Transform.scale(
        scale: _animation.value,
        child: Icon(
          _liked ? Icons.favorite : Icons.favorite_border,
          color: _liked ? Colors.red : Color.fromRGBO(177, 217, 216, 1),
          // fill: ,
          // size: 40,
        ),
      ),
    );
  }
}
