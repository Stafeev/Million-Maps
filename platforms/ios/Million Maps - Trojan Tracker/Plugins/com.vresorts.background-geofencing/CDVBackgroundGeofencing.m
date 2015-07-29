//////  CDVBackgroundGeoLocation////  Created by Chein-Hsing Lu <dreadlord1110@gmail.com> on 2015-04-06//#import "CDVBackgroundGeofencing.h"#import <Cordova/CDVJSON.h>// Debug sounds for bg-geolocation life-cycle events.// http://iphonedevwiki.net/index.php/AudioServices#define msgreceived            1307@implementation NSString (Contains)- (BOOL)myContainsString:(NSString*)other {    NSRange range = [self rangeOfString:other];    return range.length != 0;}@end@implementation CDVBackgroundGeofencing {        UIBackgroundTaskIdentifier bgTask;    NSDate *lastBgTaskAt;    NSError *locationError;    UILocalNotification *localNotification;    NSNotificationCenter *notification_center;    CDVLocationData *locationData;    CLLocation *lastLocation;    NSInteger locationAcquisitionAttempts;    CLActivityType activityType;    NSString *callback_id;}@synthesize geofences;@synthesize locationManager;@synthesize syncCallbackId;@synthesize enterTime;@synthesize name_map = name_map;@synthesize offer_uuid_map = offer_uuid_map;@synthesize lat_map = lat_map;@synthesize lon_map = lon_map;@synthesize radius_map = raduis_map;@synthesize uuid_map = uuid_map;@synthesize issubscribe_map = issubscribe_map;@synthesize desc_map = desc_map;- (void)pluginInitialize{    [self locationManagerSetup];        [super pluginInitialize];        bgTask = UIBackgroundTaskInvalid;        notification_center = [NSNotificationCenter defaultCenter];        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSuspend:) name:UIApplicationDidEnterBackgroundNotification object:nil];        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume:) name:UIApplicationWillEnterForegroundNotification object:nil];        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause:) name:UIApplicationWillEnterForegroundNotification object:nil];}-(void)locationManagerSetup{    if(!self.locationManager) self.locationManager = [[CLLocationManager alloc] init];    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;    self.locationManager.distanceFilter = 25; // meters    self.locationManager.delegate = self;        geofences = [NSMutableArray arrayWithArray:[[self.locationManager monitoredRegions] allObjects]];        NSString *version = [[UIDevice currentDevice] systemVersion];    if ([version floatValue] >= 8.0f) //for iOS8    {        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {            [self.locationManager requestAlwaysAuthorization];        }        [self.locationManager requestWhenInUseAuthorization];    }        localNotification = [[UILocalNotification alloc] init];    localNotification.timeZone = [NSTimeZone defaultTimeZone];}- (void) configure:(CDVInvokedUrlCommand*)command{    self.name_map = [NSMutableDictionary dictionaryWithCapacity:75];    self.uuid_map = [NSMutableDictionary dictionaryWithCapacity:75];    self.offer_uuid_map = [NSMutableDictionary dictionaryWithCapacity:75];    self.lat_map = [NSMutableDictionary dictionaryWithCapacity:75];    self.lon_map = [NSMutableDictionary dictionaryWithCapacity:75];    self.radius_map = [NSMutableDictionary dictionaryWithCapacity:75];    self.issubscribe_map = [NSMutableDictionary dictionaryWithCapacity:75];    self.desc_map = [NSMutableDictionary dictionaryWithCapacity:75];    //delete the previous geofence point    for (CLRegion *monitored in [self.locationManager monitoredRegions])        [self.locationManager stopMonitoringForRegion:monitored];            //fetch json and add them into geofence data    NSArray *array = [command arguments];    NSDictionary *result = [array objectAtIndex:0];    NSArray *places = [result objectForKey:@"places"];    NSUInteger count = 0;    for(NSDictionary *results in places)    {        NSDictionary *geofence = [results objectForKey:@"geofence"];        //if geofence is null then ignore        if (geofence == NULL) {continue;}        NSString *uuid = [results objectForKey:@"uuid"];        NSString *name = [results objectForKey:@"place_name"];        NSString *short_desc = [results objectForKey:@"short_desc"];        NSString *latitude = [geofence objectForKey:@"latitude"];        NSString *longitude = [geofence objectForKey:@"longitude"];        NSString *is_subscribed = [results objectForKey:@"is_subscribed"];        NSString *radius = [geofence objectForKey:@"radius"];        NSString *offer_uuid = [results objectForKey:@"offer_uuid"];        //add the place information in map for later use        //such as ufferuuid, raduis, lat_lon...        if(uuid !=nil && offer_uuid != nil && longitude != nil && latitude != nil && radius != nil && name != nil && short_desc!=nil)        {            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];            f.numberStyle = NSNumberFormatterDecimalStyle;            NSNumber *lat = [f numberFromString:latitude];            NSNumber *lon = [f numberFromString:longitude];            NSNumber *rad = [f numberFromString:radius];            CLLocationCoordinate2D coord;            coord.longitude = (CLLocationDegrees)[lon doubleValue];            coord.latitude = (CLLocationDegrees)[lat doubleValue];                        [name_map setObject:uuid forKey:name];            [uuid_map setObject:name forKey:uuid];            [offer_uuid_map setObject:offer_uuid forKey:name];            [lat_map setObject:lat forKey:name];            [lon_map setObject:lon forKey:name];            [raduis_map setObject:rad forKey:name];            [issubscribe_map setObject:is_subscribed forKey:name];            [desc_map setObject:short_desc forKey:name];            if ([is_subscribed myContainsString:@"true"] && count<20)            {                count++;                [self addPlace:coord name:name radius:rad];            }        }            }        if(count == 20) NSLog(@"Exceed 20 geofences!!");        self.syncCallbackId = command.callbackId;        // ios 8 requires permissions to send local-notifications        UIApplication *app = [UIApplication sharedApplication];    if ([app respondsToSelector:@selector(registerUserNotificationSettings:)])    {        [app registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];    }    }//-(void) addPlace:(CDVInvokedUrlCommand *)command//{////    CLLocationDegrees lattitude = [[command argumentAtIndex:(0)] doubleValue];//    CLLocationDegrees longitude = [[command argumentAtIndex:(1)] doubleValue];//    NSString *name = [[command argumentAtIndex:(2)] stringValue];//    double radius = [[command argumentAtIndex:(3)] doubleValue];////    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lattitude, longitude);//    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coor radius:radius identifier:name];//    [locationManager startMonitoringForRegion:region];//    [self notify:[NSString stringWithFormat:@"Place %@ is added to monitoring",name]];//}////-(void) deletePlace:(CDVInvokedUrlCommand *)command//{//    CLLocationDegrees lattitude = [[command argumentAtIndex:(0)] doubleValue];//    CLLocationDegrees longitude = [[command argumentAtIndex:(1)] doubleValue];//    NSString *name = [[command argumentAtIndex:(2)] stringValue];//    double radius = [[command argumentAtIndex:(3)] doubleValue];////    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lattitude, longitude);//    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coor radius:radius identifier:name];//    [locationManager stopMonitoringForRegion:region];//    [self notify:[NSString stringWithFormat:@"Place %@ is deleted from monitoring",name]];//}- (void) enablePlace:(CDVInvokedUrlCommand*)command{    NSArray *array = [command arguments];    NSDictionary *place = [array objectAtIndex:0];    NSString *key = [place objectForKey:@"place_uuid"];    NSString *name = [uuid_map objectForKey:key];    CLLocationDegrees lattitude = [[lat_map objectForKey:name]doubleValue];    CLLocationDegrees longitude = [[lon_map objectForKey:name]doubleValue];    NSNumber *radius = [raduis_map objectForKey:name];    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lattitude, longitude);        if([self checkNumberOfMonitoredRegions]<20)    {        [self addPlace:coor name:name radius:radius];    }            //check if the geofence is within the range to be triggered, if yes, the triggered it without update any list    //else add the geofence to longlist    CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(lastLocation.coordinate.latitude,lastLocation.coordinate.longitude);    NSNumber *threshold = [NSNumber numberWithInt:500];    if([self calculateDistanceInMetersBetweenCoord:coor coord:currentCoords]<threshold)    {        CLRegion *region = [[CLRegion alloc]initCircularRegionWithCenter:coor radius:[radius doubleValue] identifier:name];        [self locationManager:self.locationManager didEnterRegion:region];    }    else    {        [issubscribe_map setValue:@"true" forKey:name];    }        CDVPluginResult* result = nil;    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];    }- (void) disablePlace:(CDVInvokedUrlCommand*)command{    NSArray *array = [command arguments];    NSDictionary *place = [array objectAtIndex:0];    NSString *key = [place objectForKey:@"place_uuid"];    NSString *name = [uuid_map objectForKey:key];    CLLocationDegrees lattitude = [[lat_map objectForKey:name]doubleValue];    CLLocationDegrees longitude = [[lon_map objectForKey:name]doubleValue];    NSNumber *radius = [raduis_map objectForKey:name];    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lattitude, longitude);        [self disablePlace:coor name:name radius:radius];    //update the subscribed status in issubscribe_map    [issubscribe_map setValue:@"false" forKey:name];        CDVPluginResult* result = nil;    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];}- (void) getCurrentLocation:(CDVInvokedUrlCommand *)command{    //    //TO DO: transfer format to json  {lat:, lng:}    CDVPluginResult* result = nil;    NSMutableDictionary *returnInfo = [self locationToHash:lastLocation];    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];}/** *  Start geofencing */- (void) start:(CDVInvokedUrlCommand*)command{    [self startUpdatingLocation];    CDVPluginResult* result = nil;    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];}/** *  Stop geofencing */- (void) stop:(CDVInvokedUrlCommand*)command{    [self stopUpdatingLocation];        //delete the previous geofence point    for (CLRegion *monitored in [self.locationManager monitoredRegions])        [self.locationManager stopMonitoringForRegion:monitored];        //delete stored geofences in long list    [issubscribe_map removeAllObjects];    [uuid_map removeAllObjects];    [lat_map removeAllObjects];    [lon_map removeAllObjects];    [raduis_map removeAllObjects];    [offer_uuid_map removeAllObjects];        CDVPluginResult* result = nil;    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];}- (void) setOnNotificationClickedCallback:(CDVInvokedUrlCommand *)command{    callback_id = command.callbackId;}/**********************************************/-(void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{    }- (void) didReceiveLocalNotification:(NSNotification *)notification{        NSDictionary *dict = [[notification object]userInfo];        NSError *error;    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];    NSString *json_result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json_result];    [pluginResult setKeepCallbackAsBool:YES]; // here we tell Cordova not to cleanup the callback id after sendPluginResult()    [self.commandDelegate sendPluginResult:pluginResult callbackId:callback_id];    }- (NSUInteger) checkNumberOfMonitoredRegions{    NSArray* name = [issubscribe_map allKeys];    NSUInteger monitoredNumber = 0;    for (int i=0; i<[name count]; i++)    {        if([[issubscribe_map objectForKey:name[i]] myContainsString:@"true"])        {            monitoredNumber++;        }    }    return monitoredNumber;}-(NSMutableDictionary*) locationToHash:(CLLocation*)location{    NSMutableDictionary *returnInfo;    returnInfo = [NSMutableDictionary dictionaryWithCapacity:10];    [returnInfo setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];    [returnInfo setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];        return returnInfo;}-(void) addPlace:(CLLocationCoordinate2D) coordinate            name:(NSString *)name radius:(NSNumber *) radius{        CLRegion *region = [[CLRegion alloc]initCircularRegionWithCenter:coordinate radius:[radius doubleValue] identifier:name];    //NSLog(@"lat is %f and lon is %f and radius is %@ and name is %@",coordinate.latitude,coordinate.longitude,radius,name);    [self.locationManager startMonitoringForRegion:region];    }-(void) disablePlace:(CLLocationCoordinate2D) coordinate                name:(NSString *)name radius:(NSNumber *) radius{    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:[radius doubleValue] identifier:name];    [self.locationManager stopMonitoringForRegion:region];    [issubscribe_map setValue:@"false" forKey:name];    }-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{    [self notify:region.identifier];    [self disablePlace:[region center] name:[region identifier] radius:[NSNumber numberWithDouble:[region radius]]];            NSMutableDictionary *msg = [[NSMutableDictionary alloc]init];    NSString *offer_uuid =[name_map objectForKey:region.identifier];    //NSString *place_name = [place_name_map objectForKey:message];    [msg setObject:offer_uuid forKey:@"place_uuid"];        NSError *error;    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msg options:NSJSONWritingPrettyPrinted error:&error];    //NSString *json_result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];            //NSURL *url = [NSURL URLWithString:urlasStirng];    NSURL *url =[NSURL URLWithString:@"http://xixixhalu-test.apigee.net/proxy/tripPlanner/disablePlaceSubscription"];    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];    [request setHTTPMethod:@"PUT"];    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];    [request setHTTPBody:jsonData];        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];    if(connection)    {        NSLog(@"Unsubscribe request sent!");    }}- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{    //NSLog(@"- CDVBackgroundGeoLocation exit region");    //NSDate *leaveTime = [NSDate date];    //NSString *name = [place_name_map objectForKey:region.identifier];    //NSTimeInterval stayingTime = [leaveTime timeIntervalSinceDate:enterTime];    //[self notify:[NSString stringWithFormat:@"Leaves %@, stays for %f",name,stayingTime]];    //[self.locationManager st]}/**********************************************/- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {    NSInteger nRadius = 6371; // Earth's radius in Kilometers    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);    double lat1InRadians = coord1.latitude * (M_PI/180);    double lat2InRadians = coord2.latitude * (M_PI/180);    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));    double nD = nRadius * nC;    // convert to meters    return @(nD*1000);}-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{    lastLocation = [locations lastObject];        BOOL static first_time = TRUE;    if(first_time)//enter if user is already in the monitored region, then enter didEnterMonitoredRegion manually once    {        [self checkFirstTime];        first_time = FALSE;    }            //0.0.6 algorithm    if(self.locationManager.desiredAccuracy == kCLLocationAccuracyHundredMeters)//enter to check whether to start using GPS    {        NSSet *monitoredRegions = self.locationManager.monitoredRegions;                //dynamically add top 20 nearest geofences into monitored        if([self checkNumberOfMonitoredRegions]>20)        {            [self updateTop20Geofences];        }                if(monitoredRegions)        {            [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)             {                 CLLocationCoordinate2D centerCoords =region.center;                 CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(lastLocation.coordinate.latitude,lastLocation.coordinate.longitude);                 NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];                 if([currentLocationDistance floatValue] < 500)//if distance is less than 500, start using GPS                 {                     NSLog(@"Start using GPS");                     self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;                     self.locationManager.distanceFilter = 10;                                      }             }];        }    }        else if(self.locationManager.desiredAccuracy == kCLLocationAccuracyNearestTenMeters)    {        NSSet *monitoredRegions = self.locationManager.monitoredRegions;        NSUInteger count = [monitoredRegions count];        if(monitoredRegions)        {            __block NSUInteger out_of_500 = 0;            [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)             {                 CLLocationCoordinate2D centerCoords =region.center;                 CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(lastLocation.coordinate.latitude,lastLocation.coordinate.longitude);                 NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];                 if([currentLocationDistance floatValue] > 500)                 {                     out_of_500++;                 }                                  if(out_of_500 == count)//if all the geofences are out of 500 meter, then use wifi                 {                     NSLog(@"Start using Wifi");                     self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;                     self.locationManager.distanceFilter = 25;                 }             }];        }                //dynamically add top 20 nearest geofences into monitored        if([self checkNumberOfMonitoredRegions]>20 && [monitoredRegions count]< 5)        {            [self updateTop20Geofences];        }    }    }- (void) checkFirstTime{        NSSet *monitoredRegions = self.locationManager.monitoredRegions;        if(monitoredRegions)    {        [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)         {             CLLocationCoordinate2D centerCoords =region.center;             CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(lastLocation.coordinate.latitude,lastLocation.coordinate.longitude);             CLLocationDistance radius = region.radius;                          NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];             if([currentLocationDistance floatValue] < radius)             {                 //stop Monitoring Region temporarily                 [self.locationManager stopMonitoringForRegion:region];                                  [self locationManager:self.locationManager didEnterRegion:region];                 //start Monitoing Region again.                 //[self.locationManager startMonitoringForRegion:region];             }         }];    }}- (void) updateTop20Geofences{    //delete the previous geofence point    for (CLRegion *monitored in [self.locationManager monitoredRegions])        [self.locationManager stopMonitoringForRegion:monitored];        NSArray* name = [issubscribe_map allKeys];    NSMutableArray *places = [NSMutableArray arrayWithCapacity:0];    for (int i=0; i<[name count]; i++)    {        if([[issubscribe_map objectForKey:name[i]] myContainsString:@"true"])        {            [places addObject:name[i]];        }    }        CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(lastLocation.coordinate.latitude,lastLocation.coordinate.longitude);        NSArray *sortedArray = [places sortedArrayUsingComparator:^NSComparisonResult(NSString *p1, NSString *p2){        CLLocationCoordinate2D coord1;        coord1.longitude = (CLLocationDegrees)[[lon_map objectForKey:p1] doubleValue];        coord1.latitude = (CLLocationDegrees)[[lat_map objectForKey:p1] doubleValue];                CLLocationCoordinate2D coord2;        coord2.longitude = (CLLocationDegrees)[[lon_map objectForKey:p2] doubleValue];        coord2.latitude = (CLLocationDegrees)[[lat_map objectForKey:p2] doubleValue];                return [[self calculateDistanceInMetersBetweenCoord:coord1 coord:currentCoords] compare:[self calculateDistanceInMetersBetweenCoord:coord2 coord:currentCoords]];            }];    NSLog(@"dynamic geofences sorted");    for (int i=0; i<20; i++)    {        CLLocationCoordinate2D coord1;        coord1.longitude = (CLLocationDegrees)[[lon_map objectForKey:sortedArray[i]] doubleValue];        coord1.latitude = (CLLocationDegrees)[[lat_map objectForKey:sortedArray[i]] doubleValue];        [self addPlace:coord1 name:sortedArray[i] radius:[raduis_map objectForKey:sortedArray[i]]];            }    NSLog(@"last 20 geofences updated");    }- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region              withError:(NSError *)error{    NSLog(@"Monitored regions are %lu",(unsigned long)[[self.locationManager monitoredRegions]count]);    NSLog(@"Encounter error when start monitoring for region %@",region.identifier);    NSLog(@"%@ happens.",error.description);}- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{    NSLog(@"- CDVBackgroundGeoLocation locationManager failed:  %@", error);        //[self notify:[NSString stringWithFormat:@"Location error: %@", error.localizedDescription]];        locationError = error;        switch(error.code) {//        case kCLErrorLocationUnknown://        case kCLErrorNetwork://        case kCLErrorRegionMonitoringDenied://            [self stopUpdatingLocation];//        case kCLErrorRegionMonitoringSetupDelayed://        case kCLErrorRegionMonitoringResponseDelayed://        case kCLErrorGeocodeFoundNoResult://        case kCLErrorGeocodeFoundPartialResult://        case kCLErrorGeocodeCanceled://            break;//        case kCLErrorDenied://            [self stopUpdatingLocation];//            UIAlertView *alert_1 = [[UIAlertView alloc] initWithTitle:@"No network connection"//                                                            message:@"You must be connected to the internet to use this app."//                                                           delegate:nil//                                                  cancelButtonTitle:@"OK"//                                                  otherButtonTitles:nil];//            //                                default:            [self stopUpdatingLocation];            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location access denied error"                                                            message:@"You must enable the location access permission to continue use this application."                                                           delegate:nil                                                  cancelButtonTitle:@"OK"                                                  otherButtonTitles:nil];            [alert show];                }}- (void) stopUpdatingLocation{    [self.locationManager stopUpdatingLocation];}- (void) startUpdatingLocation{    [self.locationManager startUpdatingLocation];}- (NSTimeInterval) locationAge:(CLLocation*)location{    return -[location.timestamp timeIntervalSinceNow];}- (void) notify:(NSString*)message{    NSMutableDictionary *msg = [[NSMutableDictionary alloc]init];    NSString *offer_id =[offer_uuid_map objectForKey:message];    //NSString *place_name = [place_name_map objectForKey:message];    [msg setObject:offer_id forKey:@"offerUuid"];    [msg setObject:message forKey:@"placeName"];        localNotification.fireDate = [NSDate date];    localNotification.userInfo = msg;    //localNotification.alertBody = [NSString stringWithFormat:@"You just got an offer from %@ !",message];    localNotification.alertTitle = message;    localNotification.alertBody = [desc_map objectForKey:message];    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];    AudioServicesPlaySystemSound(msgreceived);}/** * If you don't stopMonitoring when application terminates, the app will be awoken still when a * new location arrives, essentially monitoring the user's location even when they've killed the app. * Might be desirable in certain apps. */- (void)applicationWillTerminate:(UIApplication *)application{    [self.locationManager stopUpdatingLocation];}- (void)dealloc{    self.locationManager.delegate = nil;}-(UIBackgroundTaskIdentifier) createBackgroundTask{    lastBgTaskAt = [NSDate date];    return [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{        [self stopBackgroundTask];    }];}- (void) stopBackgroundTask{    UIApplication *app = [UIApplication sharedApplication];    NSLog(@"- CDVBackgroundGeoLocation stopBackgroundTask (remaining t: %f)", app.backgroundTimeRemaining);    if (bgTask != UIBackgroundTaskInvalid)    {        [app endBackgroundTask:bgTask];        bgTask = UIBackgroundTaskInvalid;    }}///**// * Suspend.  Turn on passive location services// */-(void) onSuspend:(NSNotification *) notification{    NSLog(@"- CDVBackgroundGeoLocation suspend");}///**@// * Resume// */-(void) onResume:(NSNotification *) notification{    NSLog(@"- CDVBackgroundGeoLocation resume");}-(void) onPause:(NSNotification *) notification{    NSLog(@"- CDVBackgroundGeoLocation onpause");}-(void) onPause{    }-(void) onResume{    }-(void) onReset{    }- (void) onAppTerminate{    [self stopUpdatingLocation];}@end