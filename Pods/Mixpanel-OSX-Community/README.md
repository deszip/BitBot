# Using Mixpanel Analytics on OS X #

`pod "Mixpanel-OSX-Community", :git => "https://github.com/orta/mixpanel-osx-unofficial.git"`

This is an unofficial port of the Mixpanel API to Cocoa, its built with cocoapods in mind.
You can install this manually, the only framework you'll need is SystemConfiguration I think.

Ideally I'll keep this up to date in order to keep [ARAnalytics](https://github.com/orta/ARAnalytics/) relevant. As I use Mixpanel personally. If you work at Mixpanel and would like to take over, that'd be super-ace. Thanks.

# Initializing Mixpanel #
The first thing you need to do is initialize Mixpanel with your project token.
We recommend doing this in `applicationDidFinishLaunching:` or
`application:didFinishLaunchingWithOptions` in your Application delegate. 
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

	    // Override point for customization after application launch.
		[Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];

	    // Add the view controller's view to the window and display.
	    [window addSubview:viewController.view];
	    [window makeKeyAndVisible];
	    return YES;
	}
	
# Tracking Events #
After initializing the Mixpanel object, you are ready to track events. This can
be done with the following code snippet:

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Clicked Button"];
	
If you want to add properties to the event you can do the following:

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Player Create" 
         properties:[NSDictionary dictionaryWithObjectsAndKeys:@"Female", @"Gender", @"Premium", @"Plan", nil]];

# Setting People Properties #
Use the `people` accessor on the Mixpanel object to make calls to the Mixpanel
People API. Unlike Mixpanel Engagement, you must explicitly set the distinct ID
for the current user in Mixpanel People.

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people identify:@"user123"];
    [mixpanel.people set:@"Bought Premium Plan" to:[NSDate date]];

To send your users push notifications through Mixpanel People, register device
tokens as follows.

    - (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
        [self.mixpanel.people addPushDeviceToken:devToken];
    }

# ARC #
The Mixpanel library supports ARC as of v2.1.0.

For versions before v2.1.0:
To integrate with an ARC project: Go to Project > Target > Build Phases, double-click on
each Mixpanel file and add the flag: `-fno-objc-arc`.

# Logging #
You can turn on Mixpanel logging by adding the following Preprocessor Macros in
Build Settings: `MIXPANEL_LOG=1` and `MIXPANEL_DEBUG=1`. Setting
`MIXPANEL_LOG=1` will cause the Mixpanel library to log tracked events and set
People properties. Setting `MIXPANEL_DEBUG=1` will cause Mixpanel to log
everything it's doing—queuing, formatting and uploading data—in a very
fine-grained way, and is useful for understanding how the library works and
debugging issues.

# Further Documentation #
1. [Events iOS Library Documentation](https://mixpanel.com/docs/integration-libraries/iphone)
2. [People iOS Library Documentation](https://mixpanel.com/docs/people-analytics/iphone)
3. [Full Headerdoc API Reference](https://mixpanel.com/site_media/doctyl/uploads/iPhone-spec/Classes/Mixpanel/index.html)

[copy]: https://raw.github.com/mixpanel/mixpanel-iphone/master/Docs/Images/copy.png "Copy"
[project]: https://raw.github.com/mixpanel/mixpanel-iphone/master/Docs/Images/project.png "Project"
