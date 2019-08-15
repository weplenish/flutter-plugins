import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oauth2/oauth2.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// a manager for handling oauth 2 methods
@immutable
class OAuthManager {
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final String identifier;
  final String redirectUrl;
  final String secret;
  final String scope;
  final void Function(String) onCredentialsChanged;

  /// create an oauthmanager
  /// [onCredentialsChanged] a function that is called whenever the credentials are changed
  /// it should be used to save the string passed to it.
  const OAuthManager(
    this.authorizationEndpoint,
    this.tokenEndpoint,
    this.identifier,
    this.redirectUrl, {
    this.secret,
    this.onCredentialsChanged,
    this.scope = '',
  });

  void Function(Credentials) get _onCredentialsRefreshed =>
      onCredentialsChanged == null
          ? null
          : (Credentials creds) {
              onCredentialsChanged(creds.toJson());
            };

  Uri _addParametersAndScope(
    Uri endpoint, {
    Map<String, String> urlParameters = const {},
  }) =>
      endpoint.replace(
        queryParameters: {
          'scope': scope,
          ...endpoint.queryParameters,
          ...urlParameters,
        },
      );

  /// performs a resource owner login with oauth2
  Future<Client> resourceOwnerLogin(
    String username,
    String password, {
    Map<String, String> urlParameters,
  }) =>
      resourceOwnerPasswordGrant(
        _addParametersAndScope(
          authorizationEndpoint,
          urlParameters: urlParameters,
        ),
        username,
        password,
        identifier: identifier,
        secret: secret,
      );

  /// reauthenticate saved credentials, throws error if it fails
  /// [savedCredentials] the string that is returned by onCredentialsChanged
  Future<Client> reauthenticate(String savedCredentials) async {
    final client = Client(
      Credentials.fromJson(savedCredentials),
      identifier: identifier,
      secret: secret,
      onCredentialsRefreshed: _onCredentialsRefreshed,
    );
    return await client.refreshCredentials();
  }

  /// creates a webview dialog to login via oauth2
  Future<Client> login({
    @required BuildContext context,
    Map<String, String> urlParameters,
    double popupHeight = 600,
    double popupWidth,
  }) async {
    final grant = new AuthorizationCodeGrant(
      identifier,
      _addParametersAndScope(
        authorizationEndpoint,
        urlParameters: urlParameters,
      ),
      _addParametersAndScope(
        tokenEndpoint,
        urlParameters: urlParameters,
      ),
      secret: secret,
      onCredentialsRefreshed: _onCredentialsRefreshed,
    );

    final url = grant.getAuthorizationUrl(Uri.parse(redirectUrl));

    final uriResponse = await showDialog<Uri>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          final screenSize = MediaQuery.of(context).size;
          return AlertDialog(
            contentPadding: EdgeInsets.all(4),
            content: Container(
              constraints: BoxConstraints(
                maxHeight: popupHeight,
              ),
              width: popupWidth ?? screenSize.shortestSide * .85,
              child: WebView(
                initialUrl: url.toString(),
                javascriptMode: JavascriptMode.unrestricted,
                navigationDelegate: (req) {
                  if (!req.url.startsWith(redirectUrl)) {
                    return NavigationDecision.navigate;
                  }
                  Navigator.of(context, rootNavigator: true)
                      .pop(Uri.parse(req.url));
                  return NavigationDecision.prevent;
                },
              ),
            ),
          );
        });

    if (uriResponse == null) {
      return null;
    }

    final client =
        await grant.handleAuthorizationResponse(uriResponse.queryParameters);

    if (_onCredentialsRefreshed != null) {
      _onCredentialsRefreshed(client.credentials);
    }

    return client;
  }
}
