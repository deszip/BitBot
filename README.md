# BitBot

### About
BitBot is unofficial Bitrise CI client for macOS. It uses Bitrise public API for all of it's features. Before use add your personal access token and application build trigger tokens in account list.

BitBot was built to work for my current project so it definitely lacks a lot of functionality available via Bitrise API and is full of bugs. Fell free to drop me a line if you found one or need a feature.

BitBot and me are not associated or affiliated with Bitrise in any way.

### Building
- Clone the repo
- Run `pod install` in root directory
- Open Bitrise.xcworkspace file
- Build Bitrise target or export binary

### Account credentials
To use BitBot you need to provide your account token in account access token.
You can generate it on your account settings page.

To use 'rebuild' feature you also need build token which is specific for each app.
You can find it under 'code' tab in app settings. Add it by selecting you app in accounts list and selecting 'add build key...' from the context menu.

### Contributing
BitBot was built for my personal needs and thus lacks lots of features from the Bitrise public API.
Feel free to make PRs, open issues etc.
