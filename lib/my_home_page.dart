import 'package:flutter/cupertino.dart';
import 'app_colors.dart' as AppColors;
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                          itemCount: 5,
                          itemBuilder: (_, i){
                        return Container(
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage("https://i.ytimg.com/vi/0BdlKkvjEgA/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCFyfS5NqZv3VoJoW2htUI3GoLS8Q"),
                              fit: BoxFit.fill,
                            )
                          ),
                        );
                      }),
                    )
                  )
                  ]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
