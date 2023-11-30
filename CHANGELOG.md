## 3.0.1

- UI fixes and custom theming enhancements

## 3.0.1-beta02

- Added new method `getApprovedChains()`

## 3.0.1-beta01

- Fix an issue where MetaMask would not show the sign modal if dApp is on different chain than the wallet

## 3.0.0

- Production version!
- Minor fixes on session proposal and wallet redirection after connection
- Minor bug fixes

## 3.0.0-beta19

- Chain switching enhancements
- Smoother animations
- UI changes and bug fixes

## 3.0.0-beta18

- Fixes some issues with optionalNamespaces
- Fixes an issue where using includedWallets was causing a exception
- UI fixes and bug fixes

## 3.0.0-beta17

- UI fixes

## 3.0.0-beta16

- UI fixes

## 3.0.0-beta15

- Fix a bug where Safe wallet was confused with SafePal wallet

## 3.0.0-beta14

- UI Fixes based on designs

## 3.0.0-beta13

- Minor changes on analyzer

## 3.0.0-beta12

- Improvements during chain switchng by properly catching errors and rejections and highlighting non-approved chains by the connected wallet.
  
## 3.0.0-beta10

- Fix a bug where QR Code wasn't readable anymore after user rejects connection from within the chosen wallet app

## 3.0.0-beta09

- More improvements

## 3.0.0-beta08

- UI improvements

## 3.0.0-beta07

- Performance and responsiveness improvements
- Bug fixes

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
