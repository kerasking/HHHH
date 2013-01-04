//
//  MBGLBSUser.h
//  mobage
//
//  Created by Zhichen Geng on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
/*!
 * @abstract User Data object for LBS API
 * @discussion 
 */

@interface MBGSocialUserLocation : NSObject

{
	NSString *_id;
    double _distance;
    double _altitude;
    double _accuracy;
    NSString *_updatedtime;
    NSString *_nickname;
    NSString *_thumbnailUrl;
    NSString *_gender;
    CLLocationCoordinate2D _coordinate;
	
}

/*!
 * @abstract
 */
@property (nonatomic, retain) NSString* id;

@property (nonatomic, retain) NSString* updatedtime;
@property (nonatomic, retain) NSString* nickname;
@property (nonatomic, retain) NSString* thumbnailUrl;
@property (nonatomic, retain) NSString* gender;

@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, assign) double distance;

@property (nonatomic, assign) double altitude;

@property (nonatomic, assign) double accuracy;



@end
