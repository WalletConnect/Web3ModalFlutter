# web3modal_flutter

WalletConnect Web3Modal implementation in Flutter.

This package is still heavily in testing and is not ready for production use.

Expect large changes to the API and functionality.

## Setup

To get the modal to work properly you need to create two objects.

The first is the `Web3ModalTheme` which is used to style the modal.

```dart
// Example of Web3ModalTheme
return Web3ModalTheme(
  data: Web3ModalThemeData.darkMode,
  child: MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const MyHomePage(title: 'Web3Modal Sign Example'),
  ),
);
```

The second is the Web3ModalService which is your primary class for opening, closing, disconnecting, etc.

```dart
Web3ModalService service = Web3ModalService(
  projectId: projectId, 
  metadata: const PairingMetadata(
    name: 'Flutter WalletConnect',
    description: 'Flutter Web3Modal Sign Example',
    url: 'https://walletconnect.com/',
    icons: ['https://walletconnect.com/walletconnect-logo.png'],
  ),
);
await service.init();
```

The service must be initialized before it can be used.

Now that those two things are setup in your application, you can call `_service.open()` to open the modal.

To make things easy, you can use the Web3ModalConnect widget to open the modal.
This is a button that chanages its state based on the modal and connection.
This widget requires the web3ModalService to be passed in.

```dart
Web3ModalConnect(
  web3ModalService: _service,
),
```

## iOS Setup

For each app you would like to be able to deep link to, you must add that app's link into the `ios/Runner/Info.plist` file like so:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>metamask</string>
  <string>rainbow</string>
  <string>trust</string>
</array>
```

## Android Setup

I have not yet tested this on Android, but I believe it should work without any additional setup.

## Detailed Usage

You can launch the currently connected wallet by calling `service.launchCurrentWallet()`.

### Commands

`dart run build_runner build --delete-conflicting-outputs`


