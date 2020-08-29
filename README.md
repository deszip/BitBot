# <img src="https://github.com/deszip/BitBot/raw/master/icon.png" width="64"> BitBot

![Build Status](https://app.bitrise.io/app/6db55ab6a5f1d22f/status.svg?token=XJCgNQGZP1aSbbEsrU1Jqw&branch=develop)

### About
BitBot is unofficial Bitrise CI client for macOS. It uses Bitrise public API for all of its features. Before use add your personal access token and application build trigger tokens in the account list.

BitBot was built to work for my current project so it definitely lacks a lot of functionality available via Bitrise API and is full of bugs. Feel free to drop me a line if you found one or need a feature.

BitBot and I are not associated or affiliated with Bitrise in any way.

### Install
Get BitBot from the [AppStore](https://apps.apple.com/ua/app/bitbot/id1469773841?l=ru&mt=12).

This will give you automated updates which is handy.

Don't forget to rate it if you liked it :)

# ![BitBot](https://github.com/deszip/BitBot/raw/master/screenshot-1.png)
# ![BitBot](https://github.com/deszip/BitBot/raw/master/screenshot-2.png)
# ![BitBot](https://github.com/deszip/BitBot/raw/master/screenshot-3.png)


### Building
- Clone the repo
- Run `pod install --repo-update` in the root directory
- Open Bitrise.xcworkspace file
- Build Bitrise target or export binary

Or you can just grab .dmg file from [releases](https://github.com/deszip/BitBot/releases/latest) section.

### Account credentials
To use BitBot you need to provide your account access token. You can generate it on your account settings page.

### Contributing
BitBot was built for my personal needs and thus lacks lots of features from the Bitrise public API. Feel free to make PRs, open issues etc.
