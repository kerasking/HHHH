/**
 * MBGUser.h 
 */

#import <Foundation/Foundation.h>

/*!
 * @abstract User Data object for People API
 * @discussion 
 */
@interface MBGUser : NSObject
{
	NSString *_id;
	NSString *_displayName;
	NSString *_nickname;
	NSString *_aboutMe;
	BOOL _hasApp;
	NSInteger _age;
	NSString *_birthday;
	NSString *_gender;
	NSString *_thumbnailUrl;
	NSString *_jobType;
	NSString *_bloodType;
	BOOL _ageRestricted;
	BOOL _isVerified;
	
}

/*!
 * @abstract
 */
@property (nonatomic, retain) NSString* id;

/*!
 * @abstract
 */
@property (nonatomic, retain) NSString* displayName;
/*!
 * @abstract
 */
@property (nonatomic, retain) NSString* nickname;
/*!
 * @abstract
 */
@property (nonatomic, retain) NSString* aboutMe;
/*!
 * @abstract 
 */
@property BOOL hasApp;
/*!
 * @abstract
 */
@property (nonatomic, assign) NSInteger age;
/*!
 * @abstract
 */
@property (nonatomic, retain) NSString* birthday;
/*!
 * @abstract
 */
@property (nonatomic, retain) NSString* gender;
/*!
 * @abstract 
 */
@property (nonatomic, retain) NSString* thumbnailUrl;
/*!
 * @abstract
 */
@property (nonatomic, retain) NSString* jobType;
/*!
 * @abstract
 */
@property (nonatomic, retain) NSString* bloodType;
/*!
 * @abstract 
 */
@property BOOL ageRestricted;
/*!
 * @abstract 
 */
@property BOOL isVerified;

@end
