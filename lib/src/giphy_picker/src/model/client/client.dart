import 'dart:async';
import 'dart:convert';
// import 'package:giphy_picker/src/model/client/collection.dart';
// import 'package:giphy_picker/src/model/client/gif.dart';
// import 'package:giphy_picker/src/model/client/languages.dart';
// import 'package:giphy_picker/src/model/client/rating.dart';
// import 'package:http/http.dart';

import 'package:chat_pickers/src/giphy_picker/src/model/client/type.dart';

import '../client/collection.dart';
import '../client/gif.dart';
import '../client/languages.dart';
import '../client/rating.dart';
// import '../../../../http/lib/http.dart';
import 'package:http/http.dart';

class GiphyClient {
  static final baseUri = Uri(scheme: 'https', host: 'api.giphy.com');

  final String _apiKey;
  final Client _client;

  GiphyClient({
    required String apiKey,
    Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? Client();

   Future<GiphyCollection> trending({
    int offset = 0,
    int limit = 30,
    String rating = GiphyRating.g,
    bool sticker = true,
    String type = GiphyType.stickers
  }) async {
    return _fetchCollection(
      baseUri.replace(
        path: type ==GiphyType.emoji ? 'v1/${GiphyType.emoji}' :'v1/$type/trending',
        queryParameters: <String, String>{
          'offset': '$offset',
          'limit': '$limit',
          'rating': rating,
        },
      ),
    );
  }

  Future<GiphyCollection> emojis({
    int offset = 0,
    int limit = 30,
    String rating = GiphyRating.g,
    String lang = GiphyLanguage.english,
  }) async {
    return _fetchCollection(
      baseUri.replace(
        path: 'v1/${GiphyType.emoji}',
        queryParameters: <String, String>{
          'offset': '$offset',
          'limit': '$limit',
          'rating': rating,
          'lang': lang,
        },
      ),
    );
  }

  Future<GiphyCollection> search(
    String query, {
    int offset = 0,
    int limit = 30,
    String rating = GiphyRating.g,
    String lang = GiphyLanguage.english,
    bool sticker = false,
  }) async {
    return _fetchCollection(
      baseUri.replace(
        path: sticker ? 'v1/stickers/search' : 'v1/gifs/search',
        queryParameters: <String, String>{
          'q': query,
          'offset': '$offset',
          'limit': '$limit',
          'rating': rating,
          'lang': lang,
        },
      ),
    );
  }

  Future<GiphyGif> random({
    String? tag,
    String rating = GiphyRating.g,
    bool sticker = false,
  }) async {
    return _fetchGif(
      baseUri.replace(
        path: sticker ? 'v1/stickers/random' : 'v1/gifs/random',
        queryParameters: <String, String>{
          if (tag != null) 'tag': tag,
          'rating': rating,
        },
      ),
    );
  }

  Future<GiphyGif> byId(String id) async =>
      _fetchGif(baseUri.replace(path: 'v1/gifs/$id'));

  Future<GiphyGif> _fetchGif(Uri uri) async {
    final response = await _getWithAuthorization(uri);

    return GiphyGif.fromJson((json.decode(response.body)
        as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<GiphyCollection> _fetchCollection(Uri uri) async {
    final response = await _getWithAuthorization(uri);

    return GiphyCollection.fromJson(
        json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Response> _getWithAuthorization(Uri uri) async {
    final uriString = uri
        .replace(
          queryParameters: Map<String, String>.from(uri.queryParameters)
            ..putIfAbsent('api_key', () => _apiKey),
        )
        .toString();
    final response = await _client.get(Uri.parse(uriString));

    if (response.statusCode == 200) {
      return response;
    } else {
      throw GiphyClientError(response.statusCode, response.body);
    }
  }
}

class GiphyClientError {
  final int statusCode;
  final String exception;

  GiphyClientError(this.statusCode, this.exception);

  @override
  String toString() {
    return 'GiphyClientError{statusCode: $statusCode, exception: $exception}';
  }
}
