/**
 * MBGTWBalanceImage.h
 */

#import <Foundation/Foundation.h>
#import "MBGBalanceImage.h"

@interface MBGTWBalanceImage : MBGBalanceImage {
	CGFloat _ratio;
	NSInteger _fontSize;
	UIColor * _color;
}
-(id)initWithFrame:(CGRect)frame color:(UIColor *)color fontSize:(NSInteger)size;
-(void) update;

@end
