# MCDebuggingTools - Extermination helper
[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/MCDebuggingTools/badge.png)](https://cocoadocs.org/docsets/MCDebuggingTools)
[![Badge w/ Platform](https://cocoapod-badges.herokuapp.com/p/MCDebuggingTools/badge.png)](https://cocoadocs.org/docsets/MCDebuggingTools)

Collection of debuging tools that can be added to your project

## Usage

```objective-c
#import "AppDelegate.h"
#import "MCMemoryWarningGenerators.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
  // Force memory warnings to occur every 60 seconds. Helps you ensure you're
  // handling them properly.
  PERFORM_MEMORY_WARNING_AT_INTERVAL(60);
#endif


#ifdef DEBUG
  // Allocate a block of memory every 30 seconds. Helps ensure your application
  // can survive low memory conditions.
  ALLOCATE_MEMORY_BLOCK_AT_INTERNAL(30);
#endif

  return YES;
}
```

### MCMemoryWarrningGenerator
Extremely simple to use tool to simulate low memory conditions in your
application so you can ensure that it behaves correctly when receiving memory
warnings.

```objective-c
// generates a simulated memory warning continuously at the specified interval
// in seconds.
PERFORM_MEMORY_WARNING_AT_INTERVAL(interval);
```

```objective-c
// Allocates blocks of 5MB of memory continuously at the specified interval
// in seconds.
ALLOCATE_MEMORY_BLOCK_AT_INTERNAL(interval)
```

### MCServerEnvironment
MCServerEnvironment helps to switch client base URL easily.

```objective-c
// Before initializing your MCServerEnvironment and client objects, 
// create every URLs needed for your environment switcher
NSURL *devURL = [NSURL URLWithString:@"http://localhost"];
NSURL *ciURL = [NSURL URLWithString:@"http://api.yourserver.ci.com/"];
NSURL *qaURL = [NSURL URLWithString:@"http://api.yourserver.qa.com/"];
NSURL *stagingURL = [NSURL URLWithString:@"http://api.yourserver.staging.com/"];
NSURL *productionURL = [NSURL URLWithString:@"http://api.yourserver.prod.com/"];

// A default URL is required at MCServerEnvironment initialization
NSURL *defaultURL = nil;

#ifdef PROD_API
    defaultURL = stagingURL;
#elif STAGING_API
    defaultURL = stagingURL;
#elif QA_API
    defaultURL = qaURL;
#elif DEBUG
    defaultURL = ciURL;
#endif

// Create MCServerEnvironment object with needed URLs
_serverEnvironment = [[MCServerEnvironment alloc] initWithDefaultURL:defaultURL developmentURL:nil ciURL:ciURL qaURL:qaURL stagingURL:stagingURL productionURL:productionURL otherURLs:nil];

// Create your client object with MCServerEnvironment URL method
AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[_serverEnvironment URL]];
``` 
```objective-c
// Required
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Tell MCServerEnvironment an URL Scheme has been called and give it a presenter view controller
    // If the URL host is equals to "env", a view controller will be presented  
    [_serverEnvironment openURL:url presenterViewController:self.window.rootViewController completionBlock:nil];
    return YES;
}

// Optional
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // This will show an alert for 3 seconds with the setted base URL if it's not the default
    [_serverEnvironment showDebugAlert];
}
```


## Adding to your project

If you're using [`CocoaPods`](http://cocoapods.org/), there's nothing simpler.
Add the following to your [`Podfile`](http://docs.cocoapods.org/podfile.html)
and run `pod install`.

```ruby
pod 'MCDebuggingTools', :git => 'https://github.com/mirego/MCDebuggingTools.git'
```

Don't forget to `#import "MCMemoryWarningGenerators.h"` where it's needed.


## License

MCDebuggingTools is © 2013 [Mirego](http://www.mirego.com) and may be freely
distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).
See the [`LICENSE.md`](https://github.com/mirego/MCDebuggingTools/blob/master/LICENSE.md) file.

## About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We're team of [talented people](http://life.mirego.com) who imagine and build beautiful web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
