import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';

import 'widget.dart';
import 'utils.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  /// Variables
  dynamic imageFile;
  var pic;
  var response;
  bool _isImageDetected = false;
  String message = "";
  bool _isLoading = false;
  var _isCapture = false;
  var _isUpload = false;
  var _currentTabIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  /// Widget
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    Widget loadingIndicator = _isLoading ? Loader() : Container();
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {},
                            child: Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: screenWidth / 18)),
                        const SizedBox(width: 10.0),
                        Text(
                          'Visual Inspector',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth / 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                height: screenHeight * 0.06,
                color: const Color.fromARGB(255, 6, 69, 121),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        if (_currentTabIndex != 0) {
                          setState(() {
                            _currentTabIndex = 0;
                          });
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: screenHeight * 0.06,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Colors.white,
                          width: _currentTabIndex == 0 ? 3.0 : 0.0,
                        ))),
                        width: screenWidth * 0.15,
                        child: Text(
                          'Image',
                          style: TextStyle(
                              color: _currentTabIndex == 0
                                  ? Colors.white
                                  : Theme.of(context).secondaryHeaderColor,
                              fontSize: screenWidth / 25,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        if (_currentTabIndex != 1) {
                          setState(() {
                            _currentTabIndex = 1;
                          });
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: screenHeight * 0.06,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Colors.white,
                          width: _currentTabIndex == 1 ? 5.0 : 0.0,
                        ))),
                        width: screenWidth * 0.15,
                        child: Text(
                          'Damages',
                          style: TextStyle(
                              color: _currentTabIndex == 1
                                  ? Colors.white
                                  : Theme.of(context).secondaryHeaderColor,
                              fontSize: screenWidth / 25,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                color: Colors.white,
                child: buildTopBar(),
              ))
            ],
          ),
        ),
        Align(
          alignment: FractionalOffset.center,
          child: loadingIndicator,
        )
      ]),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () async {
                imageFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                setState(() {
                  imageFile != null ? _isCapture = true : false;
                  _isCapture ? imagePreview() : Container();
                });
              },
              child: const Icon(Icons.photo_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () async {
                imageFile = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                setState(() {
                  imageFile != null ? _isCapture = true : false;
                  _isCapture ? imagePreview() : Container();
                });
              },
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }

  imagePreview() {
    return _isCapture
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3,
                //width: 50,
                alignment: Alignment.topCenter,
                child: PhotoView(
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.transparent),
                  imageProvider: FileImage(File(imageFile!.path)),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      print("------------------");
                      // var uri = Uri.parse(
                      //     "https://8000-royal-waterfall-91429335.eu-ws2.runcode.io/uploadfile/");
                      var uri = Uri.parse(
                          "http://65.108.78.245:8000/uploadfile/en-image/");

                      var request = http.MultipartRequest(
                        'POST',
                        uri,
                      )..files.add(await http.MultipartFile.fromPath(
                          'file', imageFile!.path));
                      var streamedResponse = await request.send();

                      response =
                          await http.Response.fromStream(streamedResponse);
                      print("============================");
                      print(response.body);
                      var data = json.decode(response.body);
                      if (data["message"] == "No damage detected") {
                        setState(() {
                          message = data["message"];
                          _isCapture = false;
                          _isImageDetected = false;
                          _isLoading = false;
                        });
                        print(data["message"]);
                      } else {
                        setState(() {
                          _isCapture = false;
                          _isImageDetected = true;
                          _isLoading = false;
                          imageFile = base64Decode(data['image']);
                        });
                      }
                    },
                    child: const Text("Upload")),
              )
            ],
          )
        : Container(
            height: MediaQuery.of(context).size.height / 3,
            //width: 50,
            alignment: Alignment.center,
            child: _isImageDetected
                ? PhotoView(
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.transparent),
                    imageProvider: MemoryImage(imageFile),
                  )
                : Center(
                    child: Text(message),
                  ),
          );
  }

  buildTopBar() {
    if (_currentTabIndex == 0) {
      return SwipeDetector(
        onSwipeLeft: (offset) {
          setState(() {
            _currentTabIndex = 1;
          });
        },
        child: imageFile == null
            ? const Center(child: Text("Please Pick The Image"))
            : Container(
                child: imageFile == null
                    ? Text(message)
                    : Container(
                        alignment: Alignment.center,
                        child: imagePreview(),
                      )),
      );
    } else if (_currentTabIndex == 1) {
      return SwipeDetector(
          onSwipeRight: (offset) {
            setState(() {
              _currentTabIndex = 0;
            });
          },
          child: const Center(
            child: Text("List"),
          ));
    }
  }
}
