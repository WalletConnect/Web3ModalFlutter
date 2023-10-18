## 3.0.0-beta06

- Bug fixes
  
## 3.0.0-beta05

- Minor changes in documenation

## 3.0.0-beta04

- Remove completely the dependency from walletconnet_modal_flutter
- Bug fixes
  
## 3.0.0-beta03

- Fix responsiveness and minor bug fixes

## 3.0.0-beta01

- Prioritizing user's installed wallet apps

## 3.0.0-alpha06

- [BREAKING] Migration to web3modal API and refactor of explorer service. (later to be called apiService)

## 3.0.0-alpha05

- Core services refactor

## 3.0.0-alpha04

- Decreased even more the dependency from WalletConnectModalFlutter
- Enhanced `Web3ModalTheme` class and subclasses to increase and make easier customization. See (https://docs.walletconnect.com/web3modal/flutter/theming)[https://docs.walletconnect.com/web3modal/flutter/theming]

## 3.0.0-alpha03

- Removed /sign subfolder under example/ and changed documentation to improve pub points.

## 3.0.0-alpha02

- Minor fixes on example app and project structure

## 3.0.0-alpha01

- [BREAKING CHANGES] First alpha release of new Web3Modal V3

## 2.0.1

- Updated to WalletConnectModal `2.1.8`

## 2.0.0

- Migrated to relying on WalletConnectModalFlutter
- Massive changes to the API. Please read the updated documentation.

## 1.2.1

- Updated `Web3ModalTheme` to include multiple radius's
- Added `buttonRadius` override to `Web3ModalButton`
- Multiple bug fixes for URL launching and installation detection
- Readme updated to include how to setup Android 11+ deep linking

## 1.2.0

- Updated `Web3ModalService` to require initialization and accept multiple kinds of inputs
- Updated `Web3ModalTheme` to accept a `data` parameter, the theme is actually applied and can be modified as you wish

## 1.1.2

- Redirects working on mobile
- Theme updates
- Bug fixes

## 1.1.1

- Fixed modal having white background
- Removed `eth_signTransaction` from EVM required namespace so that certain wallets would start working
- Launch wallet function goes straight to the wallet now, if possible
- Wallet search added

## 1.1.0

- Recommended and excluded wallets
- Modal toasts added
- Color issues resolved
- Added `launchCurrentWallet` function to `web3modal_service`, it opens up the webpage of the connected wallet, it doesn't redirect to the wallet yet
- Bug fixes

## 1.0.0

- Initial release
