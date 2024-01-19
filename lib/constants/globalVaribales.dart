class GlobalVariables {
  static final GlobalVariables _instance = GlobalVariables._internal();

  List<String> bankNames = [
    'State Bank of India',
    'ICICI Bank',
    'HDFC Bank',
    'Axis Bank',
    'Punjab National Bank',
    'Kotak Mahindra Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Union Bank of India',
    'IDBI Bank',
    'Bank of India',
    'IndusInd Bank',
    'Yes Bank',
    'Federal Bank',
    'South Indian Bank',
    'Karur Vysya Bank',
    'Punjab & Sind Bank',
    'Central Bank of India',
    'Indian Bank',
    'Indian Overseas Bank',
    'UCO Bank',
    'Syndicate Bank',
    'Dena Bank',
    'Vijaya Bank',
    'Andhra Bank',
    'Bank of Maharashtra',
    'Corporation Bank',
    'Oriental Bank of Commerce',
    'United Bank of India',
    'Allahabad Bank',
    'Jammu & Kashmir Bank',
    // Add more banks as needed
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

  GlobalVariables._internal();
}
