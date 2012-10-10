//
//  NDIphoneCustomView.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-2-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vector>
#import <string>
#import "NDUICustomView.h"

using namespace NDEngine;

@interface NDIphoneCustomView : UIView <UITextFieldDelegate>
{		
	NSMutableArray *m_edits;
	NSMutableArray *m_radioButtons;
	NSMutableArray *m_buttons;
	
	UIButton *m_btnOk;
	UIButton *m_btnCancle;
	
	NDUICustomView *_nduiCustomView;
	
	int m_activeRadioButtonIndex;
}
@property (nonatomic, assign)NDUICustomView *nduiCustomView;

- (void)SetEditNumbers:(NSUInteger)numbers Tags:(NSArray *)tags Titles:(NSArray *)titles;
- (void)SetEditText:(const char*)text Index:(NSUInteger)editIndex;
- (NSString *)GetEditTextWithIndex:(NSUInteger)editIndex;
- (void)SetEditPassword:(bool)password Index:(NSUInteger)editIndex;
- (bool)EditIsPasswordWithIndex:(NSUInteger)editIndex;
- (void)SetEditMaxLength:(NSUInteger)maxLength Index:(NSUInteger)editIndex;
- (NSUInteger)GetEditMaxLengthWithIndex:(NSUInteger)editIndex;
- (void)SetEditMinLength:(NSUInteger)minLength Index:(NSUInteger)editIndex;
- (NSUInteger)GetEditMinLengthWithIndex:(NSUInteger)editIndex;

- (void)SetRadioButtonNumbers:(NSUInteger)numbers Tags:(NSArray *)tags Titles:(NSArray *)titles;
- (int)GetActiveRadioButtonIndex;
- (int)GetActiveRadioButtonTag;
- (void)SetActiveRadioButtonWithIndex:(NSUInteger)index;

- (void)SetOrtherButtonNumbers:(NSUInteger)numbers Tags:(NSArray *)tags Titles:(NSArray *)titles;

- (void)SetOkCancleButtonPosY:(NSUInteger)y;

- (void)SetOkTitle:(const char*)text;

- (void)SetCancelTitle:(const char*)text;

@end
