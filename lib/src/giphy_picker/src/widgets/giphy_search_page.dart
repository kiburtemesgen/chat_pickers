import 'package:chat_pickers/src/giphy_picker/src/model/client/type.dart';
import 'package:flutter/material.dart';
import '../../src/widgets/giphy_search_view.dart';

class GiphySearchPage extends StatelessWidget {
  final Widget? title;

  const GiphySearchPage({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: title),
        body: SafeArea(child: GiphySearchView(type: GiphyType.gifs,), bottom: false));
  }
}
