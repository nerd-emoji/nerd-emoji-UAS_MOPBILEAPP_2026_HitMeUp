import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class CommunityHttpResponseData {
  const CommunityHttpResponseData({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  final int statusCode;
  final Object body;
  final Map<String, String> headers;
}

enum CommunityHttpScenario {
  success,
  delayedSuccess,
  empty,
  fetchError,
  joinError,
}

class CommunityHttpMocks {
  CommunityHttpMocks._();

  static int communitiesFetchCalls = 0;
  static int addMemberCalls = 0;

  static void reset() {
    communitiesFetchCalls = 0;
    addMemberCalls = 0;
  }

  static HttpClient createHttpClient({
    CommunityHttpScenario scenario = CommunityHttpScenario.success,
  }) {
    return _FakeHttpClient(
      scenario: scenario,
      resolver: _resolveResponse,
    );
  }

  static CommunityHttpResponseData _resolveResponse(
    String method,
    Uri uri,
    String body,
    CommunityHttpScenario scenario,
  ) {
    final path = uri.path;

    if (method == 'GET' && path == '/api/communities/') {
      communitiesFetchCalls += 1;
      if (scenario == CommunityHttpScenario.fetchError) {
        return const CommunityHttpResponseData(
          statusCode: HttpStatus.internalServerError,
          body: {'detail': 'failed'},
        );
      }

      if (scenario == CommunityHttpScenario.empty) {
        return const CommunityHttpResponseData(
          statusCode: HttpStatus.ok,
          body: [],
        );
      }

      return CommunityHttpResponseData(
        statusCode: HttpStatus.ok,
        body: [
          {
            'id': 1,
            'name': 'Sample Community',
            'description': 'A place for testing',
            'totalParticipants': 12,
            'communityPicture': null,
          },
          {
            'id': 2,
            'name': 'Other Community',
            'description': 'Another testing space',
            'totalParticipants': 5,
            'communityPicture': null,
          },
        ],
      );
    }

    if (method == 'POST' && RegExp(r'^/api/communities/\d+/add-member/$').hasMatch(path)) {
      addMemberCalls += 1;
      if (scenario == CommunityHttpScenario.joinError) {
        return const CommunityHttpResponseData(
          statusCode: HttpStatus.internalServerError,
          body: {'detail': 'join failed'},
        );
      }

      return const CommunityHttpResponseData(
        statusCode: HttpStatus.ok,
        body: {'detail': 'added'},
      );
    }

    if (method == 'GET' && RegExp(r'^/api/communities/\d+/$').hasMatch(path)) {
      final parts = path.split('/').where((segment) => segment.isNotEmpty).toList();
      final id = int.tryParse(parts[2]) ?? 1;
      return CommunityHttpResponseData(
        statusCode: HttpStatus.ok,
        body: {
          'id': id,
          'name': id == 1 ? 'Sample Community' : 'Other Community',
          'description': 'Testing community details',
          'totalParticipants': 12,
          'communityPicture': null,
        },
      );
    }

    if (method == 'GET' && path == '/api/community-messages/') {
      return const CommunityHttpResponseData(
        statusCode: HttpStatus.ok,
        body: [],
      );
    }

    return const CommunityHttpResponseData(
      statusCode: HttpStatus.notFound,
      body: {'detail': 'Not found'},
    );
  }
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient({
    required this.scenario,
    required this.resolver,
    this.responseDelay = Duration.zero,
  });

  final CommunityHttpScenario scenario;
  final CommunityHttpResponseData Function(
    String method,
    Uri uri,
    String body,
    CommunityHttpScenario scenario,
  ) resolver;
  final Duration responseDelay;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  bool autoUncompress = true;

  @override
  bool Function(X509Certificate cert, String host, int port)? badCertificateCallback;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _FakeHttpClientRequest(
      method,
      url,
      resolver,
      scenario,
      responseDelay,
    );
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl('POST', url);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl('PUT', url);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl('PATCH', url);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl('DELETE', url);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl('HEAD', url);

  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) {
    return openUrl(method, Uri.parse('http://$host:$port$path'));
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) => open('GET', host, port, path);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) => open('POST', host, port, path);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) => open('PUT', host, port, path);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) => open('PATCH', host, port, path);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) => open('DELETE', host, port, path);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) => open('HEAD', host, port, path);

  @override
  void close({bool force = false}) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(
    this._method,
    this.url,
    this._resolver,
    this._scenario,
    this._responseDelay,
  );

  final String _method;
  final Uri url;
  final CommunityHttpResponseData Function(
    String method,
    Uri uri,
    String body,
    CommunityHttpScenario scenario,
  ) _resolver;
  final CommunityHttpScenario _scenario;
  final Duration _responseDelay;
  final _FakeHttpHeaders _headers = _FakeHttpHeaders();
  final BytesBuilder _body = BytesBuilder(copy: false);

  @override
  Encoding _requestEncoding = utf8;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  bool bufferOutput = true;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  Future<HttpClientResponse> close() async {
    if (_responseDelay > Duration.zero) {
      await Future<void>.delayed(_responseDelay);
    }

    final responseData = _resolver(
      method,
      url,
      utf8.decode(_body.takeBytes()),
      _scenario,
    );
    return _FakeHttpClientResponse(responseData);
  }

  @override
  void add(List<int> data) {
    _body.add(data);
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      _body.add(chunk);
    }
  }

  @override
  Future<void> write(Object? object) async {
    _body.add(_requestEncoding.encode(object.toString()));
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    _body.add(_requestEncoding.encode(objects.join(separator)));
  }

  @override
  void writeCharCode(int charCode) {
    _body.add(_requestEncoding.encode(String.fromCharCode(charCode)));
  }

  @override
  void writeln([Object? object = '']) {
    _body.add(_requestEncoding.encode('${object.toString()}\n'));
  }

  @override
  Future<HttpClientResponse> get done => close();

  @override
  Future<void> flush() async {}

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Encoding get encoding => utf8;

  @override
  set encoding(Encoding value) {
    _requestEncoding = value;
  }

  @override
  String get method => _method;

  @override
  Uri get uri => url;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends StreamView<List<int>> implements HttpClientResponse {
  _FakeHttpClientResponse(CommunityHttpResponseData data)
      : _data = data,
        super(Stream<List<int>>.fromIterable([
          utf8.encode(jsonEncode(data.body)),
        ]));

  final CommunityHttpResponseData _data;

  @override
  int get statusCode => _data.statusCode;

  @override
  int get contentLength => utf8.encode(jsonEncode(_data.body)).length;

  @override
  HttpHeaders get headers => _FakeHttpHeaders.fromMap(_data.headers);

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => true;

  @override
  String get reasonPhrase => '';

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => const [];

  @override
  Future<Socket> detachSocket() => throw UnsupportedError('detachSocket is not supported in tests.');

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  _FakeHttpHeaders();

  factory _FakeHttpHeaders.fromMap(Map<String, String> headers) {
    final fake = _FakeHttpHeaders();
    headers.forEach((key, value) {
      fake.set(key, value);
    });
    return fake;
  }

  final Map<String, List<String>> _values = <String, List<String>>{};

  @override
  ContentType? contentType;

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _values.putIfAbsent(name.toLowerCase(), () => <String>[]).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = <String>[value.toString()];
  }

  @override
  String? value(String name) {
    return _values[name.toLowerCase()]?.first;
  }

  @override
  void removeAll(String name) {
    _values.remove(name.toLowerCase());
  }

  @override
  void clear() {
    _values.clear();
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(action);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}