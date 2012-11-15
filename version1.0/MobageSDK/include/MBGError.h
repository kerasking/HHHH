/**
 * MBGError.h
 */

#import <Foundation/Foundation.h>

/*!
 * @abstract Error Data object for all Mobage API
 * @discussion 
 */
@interface MBGError : NSObject
{
	NSInteger _code;
	NSString *_description;
}

/*!
 * @abstract Error code
 */
@property (nonatomic, assign) NSInteger code;
/*!
 * @abstract Error description
 */
@property (nonatomic, retain) NSString* description;

/*!
 * @abstract returns Error Data object
 */
+ (id)error;

/*!
 * @abstract returns Error Data object with designated error code and description
 */
+ (id)errorWithCode:(NSInteger)code description:(NSString *) desc;

@end
