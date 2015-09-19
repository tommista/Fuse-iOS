//
//  AppDelegate.m
//  Fuse
//
//  Created by Tommy Brown on 9/18/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "AppDelegate.h"
#import "DrawerViewController.h"
#import <MMDrawerController.h>
#import "PlaylistViewController.h"
#import <Spotify/SPTAuth.h>
#import "Secrets.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [UINavigationBar appearance].barTintColor = UIColorFromRGB(0xF97242);
    [UINavigationBar appearance].tintColor = UIColorFromRGB(0xEEEEEE);
    [UINavigationBar appearance].translucent = NO;
    
    [[SPTAuth defaultInstance] setClientID:SPOTIFY_CLIENT_ID];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:@"fuse://spotify"]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];
    
    _spotifyPlayer = [SpotifyPlayer getSharedPlayer];
    
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    [application performSelector:@selector(openURL:)
                      withObject:loginURL afterDelay:0.1];
    
    DrawerViewController *drawerViewController = [[DrawerViewController alloc] initWithNibName:@"DrawerViewController" bundle:nil];
    
    PlaylistViewController *middleViewController = [[PlaylistViewController alloc] initWithNibName:@"PlaylistViewController" bundle:nil];
    UINavigationController *middleNav = [[UINavigationController alloc] initWithRootViewController:middleViewController];
    
    _drawerController = [[MMDrawerController alloc] initWithCenterViewController:middleNav leftDrawerViewController:drawerViewController];
    _drawerController.openDrawerGestureModeMask = (MMOpenDrawerGestureModePanningCenterView);
    _drawerController.closeDrawerGestureModeMask = (MMCloseDrawerGestureModePanningDrawerView | MMCloseDrawerGestureModePanningCenterView);
    self.window.rootViewController = _drawerController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            
            if (error != nil) {
                NSLog(@"*** Auth error: %@", error);
                return;
            }
            
            // Call the -playUsingSession: method to play a track
            [_spotifyPlayer setSession:session];
        }];
        return YES;
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
