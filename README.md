# MCDebuggingTools - Extermination helper

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

## Adding to your project

If you're using [`CocoaPods`](http://cocoapods.org/), there's nothing simpler.
Add the following to your [`Podfile`](http://docs.cocoapods.org/podfile.html)
and run `pod install`.

```objective-c
pod 'MCDebuggingTools', :git => 'https://github.com/mirego/MCDebuggingTools.git'
```

Don't forget to `#import "MCMemoryWarningGenerators.h"` where it's needed.


## License

MCDebuggingTools is © 2013 [Mirego](http://www.mirego.com) and may be freely
distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).
See the [`LICENSE.md`](https://github.com/mirego/MCDebuggingTools/blob/master/LICENSE.md) file.

## About Mirego

Mirego is a team of passionate people who believe that work is a place where you can innovate and have fun.
We proudly built mobile applications for
[iPhone](http://mirego.com/en/iphone-app-development/ "iPhone application development"),
[iPad](http://mirego.com/en/ipad-app-development/ "iPad application development"),
[Android](http://mirego.com/en/android-app-development/ "Android application development"),
[Blackberry](http://mirego.com/en/blackberry-app-development/ "Blackberry application development"),
[Windows Phone](http://mirego.com/en/windows-phone-app-development/ "Windows Phone application development") and
[Windows 8](http://mirego.com/en/windows-8-app-development/ "Windows 8 application development").
Learn more about our team at [life.mirego.com](http://life.mirego.com "Join our mobile design and development team").