//
//  AppDelegate.m
//  UseExternalPlayer
//
//  Created by Catherine Zhao on 2016-03-04.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "PlistSettingViewController.h"

@interface AppDelegate ()

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //setting = [[PlistSettingViewController alloc] init];
    DBSession *dbSession = [[DBSession alloc]initWithAppKey:@"v7qvmmcql1k3leu" appSecret:@"n24c2enkvp10mdl" root:kDBRootAppFolder];
    [dbSession updateAccessToken:@"9uu88jm18fhverki" accessTokenSecret:@"6zxgx2dbtnnjpqv" forUserId:@"551438413"];
    [DBSession setSharedSession:dbSession];
    [PlistSettingViewController populateLocalDictionary];
    
    return YES;
}

-(PlistSettingViewController*)getPlistViewController {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    for (UINavigationController *view in navigationController.viewControllers) {
        
        //when found, do the same thing to find the MasterViewController under the nav controller
        if ([view isKindOfClass:[PlistSettingViewController class]]) {
            return (PlistSettingViewController*)view;
        }
    }
    return NULL;
}
            

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            PlistSettingViewController *plistViewController = [self getPlistViewController];
            [plistViewController setRestClient];
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //[self storeUserId];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //[self storeUserId];
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
    //[self storeUserId];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
