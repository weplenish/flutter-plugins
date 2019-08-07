# login_with_amazon

A flutter plugin to use Amazon's native platform implementations of [Login With Amazon](https://developer.amazon.com/docs/login-with-amazon/minitoc-lwa-overview.html).

## Getting Started

The api key must be changed on a per platform basis in accordance with the following instructions.

- [Android](https://developer.amazon.com/docs/login-with-amazon/create-android-project.html#add-api-key)
- [iOS](https://developer.amazon.com/docs/login-with-amazon/register-ios.html#ios-bundle-id-and-api-keys)

### Methods

- `LoginWithAmazon`
  - `Future<Map> login(Map<String, dynamic> scopes)`
  - `Future<void> logout()`
  - `Future<String> getAccessToken(Map<String, dynamic> scopes)`

#### Scopes should match amazon scopes.

```
{
  'alexa:all': {
    'productID': 'SomeProductId',
    'productInstanceAttributes': {
      'deviceSerialNumber': 'serialNumberHere',
    },
  },
}
```

#### If a scope has no scopeData like the profile scope it should map to null.

`{'profile': null}`

#### Multiple scopes can be also be passed in all at once.

```
{
  'profile': null,
  'alexa:all': {
    'productID': 'SomeProductId',
    'productInstanceAttributes': {
      'deviceSerialNumber': 'serialNumberHere',
    },
  },
  'dash:replenish': {
    'device_model': 'SomeDeviceModel',
    'serial': 'serialNumberHere',
    'is_test_device': true
  },
}
```

### Usage

This plugin allows users to log in with their Amazon accounts. It has a single sign on feel and uses the official platform packages created by Amazon. Like the Amazon platform packages it will only ask to authorize an account if logged in or login if not already logged in.
