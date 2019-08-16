# oauth2_flutter

Low dependency oauth2 flutter package. This package uses the official dart oauth2 pub and the official flutter webview package.

## Getting Started

A constant oauthmanager can be created when the application starts. If the onCredentialsChanged parameter is set it will be called with a string that should be saved whenever it is called. When the application loads it should load the string from wherever it is saved and pass it to the reauthenticate method.

Reauthenticate and login both return an authenticated client that automatically handles updating the access token and refresh tokens. Any calls that need to be authenticated should be made using the returned client. Whenever the tokens are refreshed the onCredentialsChanged method will be called with the new tokens.