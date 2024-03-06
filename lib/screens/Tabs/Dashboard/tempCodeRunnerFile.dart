return showModalBottomSheet(
      // useSafeArea: true,
      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        // print(data);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                        topLeft:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                        topRight:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.9,
                width: double.infinity,
                padding: EdgeInsets.only(
                    left: 6.w,
                    right: 6.w,
                    top: 2.h,
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TouchableOpacity(
                        onTap: () {
                          return Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 1.h, horizontal: 3.w),
                            width: 65,
                            height: 9,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFA6E00),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TouchableOpacity(
                            onTap: () {
                              print('march');
                            },
                            child: Container(
                                height: 4.h,
                                width: 30.w,
                                decoration: const ShapeDecoration(
                                  color: Color.fromRGBO(177, 217, 216, 1),
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius.all(
                                      SmoothRadius(
                                          cornerRadius: 15, cornerSmoothing: 1),
                                    ),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '05 March, 2024',
                                    style: TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 12,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w400,
                                      height: 0.14,
                                      letterSpacing: 0.36,
                                    ),
                                  ),
                                )),
                          )
                        ],
                      ),
                      Space(2.h),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Make your list',
                            style: TextStyle(
                              color: Color(0xFF094B60),
                              fontSize: 30,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w600,
                              height: 0.02,
                              letterSpacing: 0.90,
                            ),
                          ),
                          Text(
                            'Powered by BellyAI',
                            style: TextStyle(
                              color: Color(0xFFFA6E00),
                              fontSize: 13,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                              height: 0.15,
                            ),
                          )
                        ],
                      ),
                      SheetWidget(
                        dataList: dataList,
                        // updateDataList: dataList,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );