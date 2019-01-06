# BitBot

### About
BitBot is unofficial Bitrise CI client for macOS. It uses Bitrise public API for all of its features. Before use add your personal access token and application build trigger tokens in the account list.

BitBot was built to work for my current project so it definitely lacks a lot of functionality available via Bitrise API and is full of bugs. Feel free to drop me a line if you found one or need a feature.

BitBot and I are not associated or affiliated with Bitrise in any way.

# ![BitBot](https://github.com/deszip/BitBot/raw/master/screenshot-1.png)

### Building
- Clone the repo
- Run `pod install` in the root directory
- Open Bitrise.xcworkspace file
- Build Bitrise target or export binary

Or you can just grab .dmg file from releases section.

### Account credentials
To use BitBot you need to provide your account token in the account access token. You can generate it on your account settings page.

To use 'rebuild' feature you also need build token which is specific for each app. You can find it under the 'code' tab in app settings. Add it by selecting your app in accounts list and selecting 'add build key...' from the context menu.

# ![BitBot](https://github.com/deszip/BitBot/raw/master/screenshot-2.png)

### Contributing
BitBot was built for my personal needs and thus lacks lots of features from the Bitrise public API. Feel free to make PRs, open issues etc.
