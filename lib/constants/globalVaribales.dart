import 'package:flutter/material.dart';

class GlobalVariables {
  static final GlobalVariables _instance = GlobalVariables._internal();

  // List<String> bankNames = [
  //   'State Bank of India',
  //   'ICICI Bank',
  //   'HDFC Bank',
  //   'Axis Bank',
  //   'Punjab National Bank',
  //   'Kotak Mahindra Bank',
  //   'Bank of Baroda',
  //   'Canara Bank',
  //   'Union Bank of India',
  //   'IDBI Bank',
  //   'Bank of India',
  //   'IndusInd Bank',
  //   'Yes Bank',
  //   'Federal Bank',
  //   'South Indian Bank',
  //   'Karur Vysya Bank',
  //   'Punjab & Sind Bank',
  //   'Central Bank of India',
  //   'Indian Bank',
  //   'Indian Overseas Bank',
  //   'UCO Bank',
  //   'Syndicate Bank',
  //   'Dena Bank',
  //   'Vijaya Bank',
  //   'Andhra Bank',
  //   'Bank of Maharashtra',
  //   'Corporation Bank',
  //   'Oriental Bank of Commerce',
  //   'United Bank of India',
  //   'Allahabad Bank',
  //   'Jammu & Kashmir Bank',
  //   // Add more banks as needed
  // ];

  List<String> bankNames = [
    'Airtel Payments Bank',
    'Andhra Pradesh Grameena Vikas',
    'Andhra Pragathi Grameena Bank',
    'Arunachal Pradesh Rural Bank',
    'Assam Gramin Vikash Bank',
    'AU Small Finance Bank',
    'Bank of Baroda',
    'Bank of India',
    'Bank of Maharashtra',
    'Baroda Gujarat Gramin Bank',
    'Canara Bank',
    'Capital Small Finance Bank',
    'Central Bank of India',
    'Chaitanya Godavari Gramin Bank',
    'Chhattisgarh Rajya Gramin Bank',
    'Dakshin Bihar Gramin Bank',
    'DCB Bank',
    'Dhanlaxmi Bank',
    'Ellaquai Dehati Bank',
    'Equitas Small Finance Bank',
    'ESAF Small Finance Bank',
    'Fincare Small Finance Bank',
    'Fino Payments Bank',
    'HDFC Bank',
    'Himachal Pradesh Gramin Bank',
    'ICICI Bank',
    'IDBI Bank',
    'IDFC First Bank',
    'India Post Payments Bank',
    'Indian Bank',
    'Indian Overseas Bank',
    'IndusInd Bank',
    'Jammu & Kashmir Bank',
    'Jammu And Kashmir Grameen Bank',
    'Jana Small Finance Bank',
    'Jharkhand Rajya Gramin Bank',
    'Karnataka Bank',
    'Karur Vysya Bank',
    'Kotak Mahindra Bank',
    'Nainital Bank',
    'North East Small Finance Bank',
    'NSDL Payments Bank',
    'Paytm Payments Bank',
    'Punjab and Sind Bank',
    'Punjab National Bank',
    'RBL Bank',
    'Saptagiri Gramin Bank',
    'Sarva Haryana Gramin Bank',
    'Saurashtra Gramin Bank',
    'Shivalik Small Finance Bank',
    'South Indian Bank',
    'State Bank of India',
    'Suryoday Small Finance Bank',
    'Tamilnad Mercantile Bank',
    'UCO Bank',
    'Ujjivan Small Finance Bank',
    'Union Bank of India',
    'Unity Small Finance Bank',
    'Utkarsh Small Finance Bank',
    'Uttar Bihar Gramin Bank',
    'Yes Bank'
  ];

  // Your global variables go here
  String myGlobalVariable = "Initial Value";

  factory GlobalVariables() {
    return _instance;
  }

  int store_setup_number = 1;

  void set_store_setup_number(int num) {
    store_setup_number = num;
  }

  Widget ErrorBuilderForImage(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Error loading image'),
    );
  }

  Widget loadingBuilderForImage(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  GlobalVariables._internal();
}
