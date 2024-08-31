import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageGeneration extends StatefulWidget {
  @override
  _ImageGenerationState createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _imageData;

  Future<void> _askBellyAI() async {
    print("Button clicked");

    setState(() {
      _isLoading = true;
      _imageData = null; // Clear previous image
    });

    SystemChannels.textInput.invokeMethod('TextInput.hide');

    final prompt = _promptController.text.trim();
    print("Prompt: $prompt");

    if (prompt.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await Provider.of<Auth>(context, listen: false)
          .bellyAiTextToImage(prompt);

      if (response != null) {
        setState(() {
          _imageData = response;
        });
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadImage() async {
    if (_imageData == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/generated_image.jpg';
      final file = File(filePath);

      await file.writeAsBytes(_imageData!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to $filePath')),
      );
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image')),
      );
    }
  }

  void _showInputBottomSheet(BuildContext context) {
    print("_isLoading $_isLoading");
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                  topLeft: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                  topRight: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                ),
              ),
            ),
            child: Wrap(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 5,
                      decoration: ShapeDecoration(
                        color: Color(0xffFA6E00),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 15,
                            cornerSmoothing: 1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Write your requirement here..',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff1B7997),
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _promptController,
                      style: TextStyle(
                        color: Color(0xff0A4C61),
                        height: 1.2,
                        fontSize: 20,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.bold,
                      ),
                      cursorColor: Color(0xff0A4C61),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintMaxLines: 3,
                        hintStyle: TextStyle(
                          color: Color(0xff0A4C61).withOpacity(0.4),
                          height: 1.2,
                          fontSize: 20,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: 'Describe the image you want to generate...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              if (FocusScope.of(context).hasFocus) {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                              }

                              setState(() {
                                _isLoading = true;
                              });
                              Navigator.of(context).pop();

                              _askBellyAI();
                            },
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: const Offset(5, 6),
                                color: Color(0xffFA6E00).withOpacity(0.51),
                                blurRadius: 30,
                              ),
                            ],
                            color: _isLoading ? Colors.grey : Color(0xffFA6E00),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text(
                                  'Generate Image',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEFF9FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 0,vertical: 20),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 30,
                          cornerSmoothing: 1,
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0xffA5C8C7).withOpacity(0.4),
                          blurRadius: 25,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Image.asset(
                                'assets/images/back_double_arrow.png',
                                color: Color(0xffFA6E00),
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                'Belly AI \nText to Image Generation',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Product Sans Black',
                                  color: Color(0xff0A4C61),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (_isLoading)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 30.h),
                                Container(
                                  constraints: BoxConstraints(maxWidth: 100.w),
                                  child: Lottie.asset(
                                    'assets/Animation - panda.json',
                                    width: 100.w,
                                  ),
                                ),
                                Text(
                                  'Loading ...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Color(0xff0A4C61),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_imageData != null)
                          Column(
                            children: [
                              SizedBox(height: 30,),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.centerLeft,
                                  child: Text(_promptController.text.trim(),style: TextStyle(fontFamily: 'Product Sans',fontSize: 18,fontWeight: FontWeight.bold,color: Color(0xff1B7997)),)),
                              if (_imageData !=
                                  null) // Ensure image data is not null
                                Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.width *
                                      1, // Fixed height based on screen width
                                   decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        offset: const Offset(0, 3),
                        color: Color(0xff1B7997).withOpacity(0.31),
                        blurRadius: 30,
                      ),
                    ],
                    color: Color(0xffFA6E00),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 15,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.memory(
                                      _imageData!,
                                      fit: BoxFit
                                          .cover, // Use BoxFit.cover to ensure the image fills the container
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.width * 0.75,
                                  color: Colors
                                      .grey[300], // Placeholder color or image
                                  child: Center(
                                    child: Text(
                                      'No Image Available',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _downloadImage,
                                icon: Icon(Icons.download_rounded),
                                label: Text('Download Image'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xff0A4C61),
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 15,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                              ),
                            ],
                          )
                        else
                          Center(
                            child: Text(
                              'No image generated yet.',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0A4C61),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showInputBottomSheet(context),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        offset: const Offset(5, 6),
                        color: Color(0xffFA6E00).withOpacity(0.51),
                        blurRadius: 30,
                      ),
                    ],
                    color: Color(0xffFA6E00),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 15,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Generate Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
