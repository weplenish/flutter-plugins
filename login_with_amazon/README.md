# login_with_amazon

A flutter plugin to use Amazon's native platform implementations of [Login With Amazon](https://developer.amazon.com/docs/login-with-amazon/minitoc-lwa-overview.html).

## Getting Started

The api key must be changed on a per platform basis in accordance with the following instructions.

- [Android](https://developer.amazon.com/docs/login-with-amazon/create-android-project.html#add-api-key)
- [iOS](https://developer.amazon.com/docs/login-with-amazon/register-ios.html#ios-bundle-id-and-api-keys)

### Methods

- LoginWithAmazon
  - Future<Map> login(Map<String, dynamic> scopes)
  - Future<void> logout()
  - Future<String> getAccessToken(Map<String, dynamic> scopes)
