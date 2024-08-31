import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:provider/provider.dart';
import 'package:cloudbelly_app/api_service.dart'; // Assuming you have this file to handle API calls

class BellyGPTPage extends StatefulWidget {
  @override
  _BellyGPTPageState createState() => _BellyGPTPageState();
}

class _BellyGPTPageState extends State<BellyGPTPage> {
  final TextEditingController _promptController = TextEditingController();
  List<Widget> _formattedResponseWidgets = [];
  bool _isLoading = false;

  Future<void> _askBellyGPT() async {
     setState(() {
      _isLoading = true;
    });
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      // Handle empty input
      return;
    }

   

    try {
      final response = await Provider.of<Auth>(context, listen: false)
          .askBellyGPT(prompt); // Replace this with your actual API call

      setState(() {
        _formattedResponseWidgets = _formatResponse(response);
      });
    } catch (error) {
      print('Error: $error');
      // Handle error, maybe show a Snackbar or Toast
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Widget> _formatResponse(String response) {
    List<Widget> widgets = [];
    bool isListOpen = false;

    // Split the text into lines
    List<String> lines = response.split('\n');

    for (String line in lines) {
      if (line.isEmpty) continue;

      // Handle bold text
      if (line.contains("**")) {
        line = line.replaceAll("**", "");
        widgets.add(Text(
          line,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Product Sans', color: Color(0xff1B7997)),
        ));
      } else if (RegExp(r'^\d+\..*').hasMatch(line) || line.startsWith('* ')) {
        // Handle list items
        if (!isListOpen) {
          isListOpen = true;
          widgets.add(SizedBox(height: 10));
        }
        widgets.add(Text("• ${line.replaceAll(RegExp(r'^\d+\.\s*|\*\s*'), '')}",
            style: TextStyle(fontSize: 16,color: Color(0xff1B7997),fontFamily: 'Product Sans')));
      } else {
        if (isListOpen) {
          isListOpen = false;
          widgets.add(SizedBox(height: 10));
        }
        widgets.add(Text(
          line,
          style: TextStyle(fontSize: 16,color: Color(0xff1B7997),fontFamily: 'Product Sans'),
        ));
      }
    }

    return widgets;
  }

  void _showInputBottomSheet(BuildContext context) {
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
                      decoration: BoxDecoration(
                        color: Color(0xffFA6E00).withOpacity(0.50),
                        borderRadius: BorderRadius.circular(12),
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
                      maxLines: null, // Allow the TextField to expand
                      decoration: InputDecoration(
                        hintMaxLines: 3,
                        hintStyle: TextStyle(
                          color: Color(0xff0A4C61).withOpacity(0.4),
                          height: 1.2,
                          fontSize: 20,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                        ),
                        hintText:
                            'Give me a diet plan to gain weight, I am allergic to milk. What should I eat?',
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
                      onTap: _isLoading ? null : _askBellyGPT, // Prevent multiple taps
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
                            color: _isLoading ? Colors.grey : Color(0xffFA6E00), // Disable color if loading
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : Text(
                                  'Ask bellyGPT',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 20,
                          cornerSmoothing: 1,
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            Text(
                              'BellyGPT',
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Product Sans',
                                color: Color(0xff0A4C61),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (_formattedResponseWidgets.isNotEmpty)
                          ..._formattedResponseWidgets,
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
                    'Ask bellyGPT',
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
      ),
    );
  }
}