/**
 * MBGOption.h
 */

#import <Foundation/Foundation.h>


/*!
 * @abstract
 */
@interface MBGOption : NSObject {

	NSInteger _start;
	NSInteger _count;
}
/*!
 * @abstract
 */
@property (nonatomic, assign) NSInteger start;
/*!
 * @abstract
 */
@property (nonatomic, assign) NSInteger count;

/*!
 * @abstract
 */
+ (id)option;

+ (id)optionWithStartCount:(NSInteger) start count:(NSInteger)count;


@end
