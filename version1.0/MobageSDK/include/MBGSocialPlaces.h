//
//  MBGSocialPlaces.h
//  mobage
//
//  Created by zfpan on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "MBGError.h"
#import "MBGOption.h"
#import "MBGResult.h"


@interface MBGSocialPlaces : NSObject <CLLocationManagerDelegate>

/*!
 * @abstract get currunt loacation information.
 * @discussion <b>Note:</b> Limited to 30 key/value pairs per user per game.  Maximum key name limited to 32 bytes. Maximum value limited to 1024 bytes.
 * @param successCB Retrieves the location success.
 * @param onError The callback interface that handles errors.
 *
 */
+ (void) getLocationonSuccess:(void (^)(CLLocation *))successCB onError:(void (^)(MBGError *))errorCB;

/*!
 * @abstract update currunt loacation information.
 * @discussion <b>Note:</b> Limited to 30 key/value pairs per user per game.  Maximum key name limited to 32 bytes. Maximum value limited to 1024 bytes.
 * @param onSuccess Retrieves the updated entries.
 * @param onError The callback interface that handles errors.
 *
 */
+ (void) updateLocationonSuccess:(void (^)())successCB onError:(void (^)(MBGError *))errorCB;


@end
