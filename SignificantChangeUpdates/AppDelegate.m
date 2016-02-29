//
//  AppDelegate.m
//  SignificantChangeUpdates
//
//  Created by quke on 16/2/26.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import "ViewController.h"

@interface AppDelegate ()<CLLocationManagerDelegate>
@property(nonatomic,strong)CLLocationManager * locationManager;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    [self.window makeKeyAndVisible];
    [self postLocalNotificationWithMsg:@"didFinishLaunchingWithOptions"];
    [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self startLocation];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    UIAlertController * alerC = [UIAlertController alertControllerWithTitle:[[notification userInfo] objectForKey:@"Msg"]  message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alerC addAction:action];
    
    [self.window.rootViewController presentViewController:alerC animated:YES completion:NULL];
}

- (void)startLocation
{
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            [self.locationManager requestAlwaysAuthorization]; //
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
    }
    [_locationManager startMonitoringSignificantLocationChanges];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation * lastlocation = [locations lastObject];
    [self postLocalNotificationWithMsg:[NSString stringWithFormat:@"locations update %@",lastlocation.timestamp]];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}

- (void)postLocalNotificationWithMsg:(NSString *)msg
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notification.fireDate = [NSDate date];
        
        notification.repeatInterval = kCFCalendarUnitDay;
        notification.alertBody   = msg;
        notification.soundName = UILocalNotificationDefaultSoundName;
        //        notification.applicationIconBadgeNumber++;
        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
        aUserInfo[@"Msg"] = msg;
        notification.userInfo = aUserInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
