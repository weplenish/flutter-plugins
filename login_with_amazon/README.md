# login_with_amazon

A flutter plugin to use Amazon's native platform implementations of [Login With Amazon](https://developer.amazon.com/docs/login-with-amazon/minitoc-lwa-overview.html). Like the Amazon platform packages it will only ask to authorize if already logged in on the device (single sign on). Alternatively it will ask to login.

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

#### Login Response

The response from using the login method is a map of the AuthorizeResult. It is dependent on the scope.

```
{
    'accessToken': 'access token result',
    'user': {
        'userEmail': 'user email result',
        'userId': 'user id result',
        'userName': 'user name result',
        'userPostalCode': 'user postal code result',
        'user info': 'user info as a Map<String,String> result',
    },
}
```
