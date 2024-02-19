import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: must_be_immutable
class AppwideBanner extends StatefulWidget {
  // const AppwideBanner({super.key});
  double height;
  AppwideBanner({super.key, this.height = 300});

  @override
  State<AppwideBanner> createState() => _AppwideBannerState();
}

class _AppwideBannerState extends State<AppwideBanner>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 800, // Set the maximum width to 800
        ),
        child: Provider.of<Auth>(context, listen: true).cover_image == ''
            ? Container(
                width: 100.w,
                height: widget.height == 300 ? 30.h : widget.height,
                decoration: ShapeDecoration(
                  color: Color(0xFFB1D9D8),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                        bottomLeft:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                        bottomRight:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
                  ),
                ))
            : Container(
                width: 100.w,
                height: widget.height == 300 ? 30.h : widget.height,
                decoration: ShapeDecoration(
                  color: Color(0xFFB1D9D8),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                        bottomLeft:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                        bottomRight:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
                  ),
                ),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius.only(
                      bottomLeft:
                          SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                      bottomRight:
                          SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
                  child: Image.network(
                    Provider.of<Auth>(context, listen: true).cover_image,
                    fit: BoxFit.cover,
                    loadingBuilder: GlobalVariables().loadingBuilderForImage,
                    errorBuilder: GlobalVariables().ErrorBuilderForImage,
                  ),
                ),
              ),
      ),
    );
  }
}
