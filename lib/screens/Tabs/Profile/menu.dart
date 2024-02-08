import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      child: FutureBuilder(
        future: Provider.of<Auth>(context, listen: false).getMenu(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<dynamic> data = snapshot.data as List<dynamic>;
            data = data.reversed.toList();
            print(data);
            return ListView.builder(
                padding: const EdgeInsets.only(),
                itemCount: (data as List<dynamic>).length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap:
                    true, // Allow the GridView to shrink-wrap its content
                addAutomaticKeepAlives: true,
                itemBuilder: (context, index) {
                  data[index]['VEG'] == null ? data[index]['VEG'] = true : null;
                  // data[index]['description'] =
                  //     'Indian delicacies served with tasty gravy, all from your very own kitchen...';

                  return data[index]['VEG'] != null
                      ? MenuItem(data: data[index])
                      : SizedBox.shrink();
                });
          } else
            return Center(
              child: Container(
                height: 20,
                width: 20,
                child: const CircularProgressIndicator(),
              ),
            );
        },
      ),
    );
  }
}
