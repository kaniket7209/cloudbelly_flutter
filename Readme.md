
# For box -shadow color codes..  (use this  in widget builder)
String? userType = Provider.of<Auth>(context, listen: false).userData?['user_type'];
Color boxShadowColor;

if (userType == 'Vendor') {
    boxShadowColor = const Color.fromRGBO(10, 76, 97, 0.5);
} else if (userType == 'Customer') {
    boxShadowColor = const Color(0xBC73BC).withOpacity(0.5);
} else if (userType == 'Supplier') {
    boxShadowColor = Color.fromARGB(0, 115, 188, 150).withOpacity(0.5);
} else {
    boxShadowColor = const Color.fromRGBO(
        77, 191, 74, 0.6); // Default color if user_type is none of the above
}

