import 'package:flutter/cupertino.dart';
import 'app_colors.dart' as AppColors;
import 'package:flutter/material.dart';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  List popularSongs;
  ScrollController _scrollController;
  TabController _tabController;

  ReadData() async{
    await DefaultAssetBundle.of(context).loadString("json/popularSongs.json").then((s) {
      setState(() {
        popularSongs = json.decode(s);
      });
    });
  }

  @override 
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    ReadData();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.menu, size: 24, color: Colors.black),
                      Row(
                        children: [
                          Icon(Icons.search),
                          SizedBox(width: 10,),
                          Icon(Icons.notifications)
                        ],
                      ),
                    ],
                  ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Text("Music App", style: TextStyle(fontSize: 30)),

                  )
                ],
              ),

              SizedBox(height: 20,),
              Container(
                height: 180,
                child: Stack(
                  children: [

                    Positioned(
                      top: 0,
                      left: -20,
                      right: 0,

                    child: Container(
                      height: 180,
                      child: PageView.builder(
                          controller: PageController(viewportFraction: 0.8),
                          itemCount: popularSongs==null?0:popularSongs.length,
                          itemBuilder: (_, i){
                        return Container(
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(popularSongs[i]["image"]),
                              fit: BoxFit.fill,
                            )
                          ),
                        );
                      }),
                    )
                  )
                  ]
                ),
              ),

              Expanded(child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (BuildContext context, bool inScroll){
                  return [
                    SliverAppBar(
                      pinned: true,
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(50),
                        child: Container(
                          margin: const EdgeInsets.all(0),
                          child: TabBar(
                            indicatorPadding: const EdgeInsets.all(0),
                            indicatorSize: TabBarIndicatorSize.label,
                            labelPadding: const EdgeInsets.all(0),
                            controller: _tabController,
                            isScrollable: true,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 7,
                                  offset: Offset(0, 0)
                                )
                              ]
                            ),
                            tabs: [
                              Container(
                                width: 120,
                                height: 50,
                                child: Text(
                                  "New", style: TextStyle(color: Colors.white),

                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 7,
                                      offset: Offset(0, 0)
                                    )
                                  ]
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ];
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}
