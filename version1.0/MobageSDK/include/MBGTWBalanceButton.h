/**
 * MBGCNBalanceButton.h
 */

#import <Foundation/Foundation.h>
#import "MBGBalanceButton.h"

@interface MBGTWBalanceButton : MBGBalanceButton {
    UIButton* _button;
	UILabel* _currencyName;
	UIImageView* _balanceImage;
	UIImageView* _coinImage;
	CGRect _mainRect;
	CGFloat _ratio;
}
@property(nonatomic, retain) UIView* button;
@property(nonatomic, retain) UILabel* currencyName;
@property(nonatomic, retain) UIImageView* coinImage;
@property(nonatomic, retain) UIImageView* balanceImage;

- (void)update;

@end
