---
layout: post
title: "Dependency Injection for Objective-C"
date: 2014-05-28 23:01
comments: true
categories: iOS, Objective-C
---

Despite what some [people](http://david.heinemeierhansson.com/2014/tdd-is-dead-long-live-testing.html) think, TDD is alive and well. Fast running tests are awesome and breaking dependencies is the key to fast, isolated unit tests. Reliable tests give us the confidence to aggressively clean our code and add new features.

In iOS and OS X it is common to use singleton or singleton style service objects for app wide functionality. Apple provides several of these singleton service objects that are used in most applications. `[NSUserDefaults standardUserDefaults];` and `[NSNotificationCenter defaultCenter];` for example.

Both `NSUserDefaults` and `NSNotificationCenter` are notoriously painful to isolate in unit tests. `NSUserDefaults` is challenging because it writes to disk and has the potential of poluting the real running application after the test suite has run and we are back to using the app in the simulator. `NSNotificationCenter` introduces the possibility of test pollution due to it's global nature. Wouldn't it be nice if we had a system to seemlessly inject fake versions of these in our tests? 

We do.

At [GoSpotCheck](http://www.gospotcheck.com) we have a mechanism for injecting all of Apple's as well as all of our own singleton style dependencies. When running in the simulator or on a device the real service objects are injected. When the test target is running fake service objects are injected.

The rest of this post will detail out our approach to dependency injection. To keep things easy to understand the example is intentionally simplistic. The sample project [Injections](https://github.com/steam/injections) is not organized like our production application and the test suite is XCTest in order to reduce the amount of setup needed to try it out. We use [Cedar](https://github.com/pivotal/cedar) and [Expecta](https://github.com/specta/expecta) at GoSpotCheck.

The example below shows how to dependency inject a fake `AFNetworkReachabilityManager` from [Mattt Thompson's](https://twitter.com/mattt) fantastic [AFNetworking](https://github.com/AFNetworking/AFNetworking) library. AFNetworking is a great network request library for iOS and OS X.

`AFNetworkReachabilityManager` provides hooks for checking on, and being notified of a device's internet connectivity. To unit test online/offline conditional behavior in an app we need to be able control (or fake) the `AFNetworkReachabilityManager's` reported connection status. This example may seem like a lot of code is required to fake the connection status. That using a mocking framework like [OCMock](http://ocmock.org/) might be simpler. It would be. For one off stubbing and mocking OCMock is great. However, in a large production application fakes are usually a better choice in my opinion. Application state is more straightforward with a system of injected fakes than one off mocking, especially for system wide service objects. These techniques are especially useful when unit testing true service objects that make network requests and return deserialized model objects.

Injections is a simple application that displays the device's connection status when launched. Follow the setup below to see it in action.

{% img /images/injections.jpg %}

##Setup
```
$ git clone git@github.com:steam/injections.git

``` 

We'll be looking at a handful of classes and categories.

`Environment` is the class that initializes all the services. In a real application you'd see properties for a `NSNotificationCenter`, `NSUserDefaults` and all other singleton style service objects here. These will be referenced by the `UIViewController+Injections` category and made available to all `UIViewControllers` that want access.

``` objective-c Environment.h
#import <Foundation/Foundation.h>

@class AFNetworkReachabilityManager;

@interface Environment : NSObject

@property (strong, nonatomic, readonly) AFNetworkReachabilityManager *reachabilityManager;

+ (Environment *)singleton;
- (BOOL)isTestEnvironment;

@end
```

The key part to take note of is `-initializeServices`. We call `[self isTestEnvironment]` to determine if we are in the test environment. If `- (BOOL)isTestEnvironment` returns true then we initialize fake services, otherwise we initialize the real `reachabilityManager`.

``` objective-c Environment.m
...
- (void)initializeServices
{
    if ([self isTestEnvironment])
    {
        [self performSelector:@selector(initializeFakeServices)];
        return;
    }

    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
}

- (BOOL)isTestEnvironment {
    return [self respondsToSelector:@selector(initializeFakeServices)];
}
...
```

The magic happens with `[self respondsToSelector:@selector(initializeFakeServices)]`. In the non-test target this will return false. In the test target it will return true because of the `Environment+Fake` category imported in `ViewControllerTests.m`.

``` objective-c Environment+Fake.m
#import "Environment+Fake.h"
#import "FakeReachabilityManager.h"

@implementation Environment (Fake)

- (void)initializeFakeServices
{
    [self setValue:[FakeReachabilityManager sharedManager] forKey:@"reachabilityManager"];
}

@end
```

`Environment+Fake` sets `[FakeReachabilityManager sharedManager]` as the value for `self.reachabilityManager`. We'll see below that `ViewController` will use the fake version of `self.reachabilityManager` in the test target while using the real `reachabilityManager` in the non-test target.

The `UIViewController+Injections` category is in charge of defining methods that returns each of the services we want to expose to our view controllers. In this case `reachabilityManager` is returned from the `Environment` singleton object. This method will return either the real or fake version of the `reachabilityManager` depending on the target.

```objective-c UIViewController+Injections.m

@implementation UIViewController (Injections)

- (AFNetworkReachabilityManager *)reachabilityManager
{
    return [Environment singleton].reachabilityManager;
}

@end
```

`ViewController` uses the `reachabilityManager` to determine what text to display to the user. If `self.reachabilityManger.networkReachabilityStatus` is reachable the label's text is set to "online", if not then it is set to "offline". Take note of the `@property (strong, nonatomic) AFNetworkReachabilityManager *reachabilityManager;` declaration in the header as well as it's corresponding `@dynamic reachabilityManager;` in the implementation file. All `UIViewController` subclasses have access to the `UIViewController+Injections` category methods which allows them to be set as properties on each `ViewController` subclass and dynamically evaluated at runtime.

```objective-c ViewController.h
#import <UIKit/UIKit.h>

@class AFNetworkReachabilityManager;

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *internetStatusLabel;

/* "Injected" properties -- Each should have a corresponding @dynamic directive */
@property (strong, nonatomic) AFNetworkReachabilityManager *reachabilityManager;

@end
```

```objective-c ViewController.m

#import "ViewController.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

@implementation ViewController

@dynamic reachabilityManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displayOnlineStatus];
}

- (void)displayOnlineStatus
{
    BOOL reachable = self.reachabilityManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable;

    if (reachable)
    {
        self.internetStatusLabel.text = NSLocalizedString(@"online", nil);
    }
    else
    {
        self.internetStatusLabel.text = NSLocalizedString(@"offline", nil);
    }
}

@end
```

The final two pieces of the puzzle are in our test suite. `ViewControllerTests.m` and `FakeReachabilityManager` take care of the rest.

First, `FakeReachabilityManager` provides access to toggling the reported connection status as online or offline.

```objective-c FakeReachabilityManager.h
#import "AFNetworkReachabilityManager.h"

@interface FakeReachabilityManager : AFNetworkReachabilityManager

- (void)setOffline;
- (void)setOnline;

@end
```

By calling `-setOffline` or `-setOnline` we're able to override `- (AFNetworkReachabilityStatus)networkReachabilityStatus` having it return the value of `self.fakeStatus` set in the `-setOffline` or `-setOnline` calls.

```objective-c FakeReachabilityManager.m

@interface FakeReachabilityManager()
@property (nonatomic, assign) AFNetworkReachabilityStatus fakeStatus;
@end


@implementation FakeReachabilityManager

- (void)setOffline
{
    self.fakeStatus = AFNetworkReachabilityStatusNotReachable;
}

- (void)setOnline
{
    self.fakeStatus = AFNetworkReachabilityStatusReachableViaWWAN;
}

- (AFNetworkReachabilityStatus)networkReachabilityStatus
{
    return self.fakeStatus;
}

@end
```

Finally, we make use of our `FakeReachabilityManager` in `ViewControllerTests.m`.

```objective-c ViewControllerTests.m
#import <XCTest/XCTest.h>
#import "Environment+Fake.h"
#import "ViewController.h"
#import "FakeReachabilityManager.h"


@interface ViewControllerTests : XCTestCase

@property (nonatomic, strong) ViewController *controller;

@end


@implementation ViewControllerTests

- (void)setUp
{
    [super setUp];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.controller = (ViewController *)[storyboard instantiateInitialViewController];
    [self.controller loadView];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testOnlineLabelDisplaysOfflineWhenOffline
{
    FakeReachabilityManager *manager = (FakeReachabilityManager *)self.controller.reachabilityManager;
    [manager setOffline];

    [self.controller viewDidLoad];

    NSString *expectedResult = @"offline";
    NSString *text = self.controller.internetStatusLabel.text;

    XCTAssertTrue([text isEqualToString:expectedResult], @"Strings are not equal %@ %@", text, expectedResult);
}

- (void)testOnlineLabelDisplaysOnlineWhenOnline
{
    FakeReachabilityManager *manager = (FakeReachabilityManager *)self.controller.reachabilityManager;
    [manager setOnline];

    [self.controller viewDidLoad];

    NSString *expectedResult = @"online";
    NSString *text = self.controller.internetStatusLabel.text;

    XCTAssertTrue([text isEqualToString:expectedResult], @"Strings are not equal %@ %@", text, expectedResult);
}


@end
```

By toggling our `reachabilityManager's` online status through the fake we are able to write assertions about the label's text for both online and offline states.

##Summary

* `Environment` handles the setup of service objects.
* `Environment+Fake` sets fake services in the test target.
* `UIViewController+Injections` provides service access to `UIViewControllers`.
* `@dynamic` accessors makes this possible.
* `ViewControllerTests.m` is able to use the fake service object and control the external dependency.

As I mentioned above, this example feels like overkill for this particular use case due to the simplicity of the app. In practice however this technique makes it possible to have fine grain control over a host of complicated services and objects. When your app has hundreds of classes and thousands of tests you'll see your hard work paid back many times over. The tests will run fast and predictably (our current test suite takes under 15 seconds to run ~1400 tests). TDD and near complete test coverage can only happen when you have confidence in the test suite and you can execute them fast enough to do it often. Breaking dependencies on asynchronous code and hard to control state is crucial.

Approach this in a different way? Completely disagree? Love the technique? Reach out and let me know on twitter [@sdougherty](https://twitter.com/sdougherty).