//
//  NDIphoneCustomView.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-2-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDIphoneCustomView.h"
#import "define.h"
#import "NDUtility.h"

#define CONTROL_INTERVAL	2
#define LABEL_HEIGHT		20
#define LABEL_WIDTH			476
#define EDIT_HEIGHT			30
#define	EDIT_WIDTH			476
#define RADIO_BUTTON_HEIGHT 30
#define RADIO_BUTTON_WIDTH	30
#define BUTTON_HEIGHT		30
#define BUTTON_WIDTH		80

#define IMAGE_RADIO_BUTTON_ON [NSString stringWithFormat:@"%s", GetImgPath("radio-on.png")]
#define IMAGE_RADIO_BUTTON_OFF [NSString stringWithFormat:@"%s", GetImgPath("radio-off.png")]


@implementation NDIphoneCustomView

@synthesize nduiCustomView = _nduiCustomView;

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) 
	{	
		m_edits = [[NSMutableArray alloc] init];
		m_radioButtons = [[NSMutableArray alloc] init];
		m_buttons = [[NSMutableArray alloc] init];
		
		_nduiCustomView = nil;
		m_activeRadioButtonIndex = -1;
		
		m_btnOk = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		m_btnOk.frame = CGRectMake(100, 280, 60, 30);
		[m_btnOk setTitle:NDCommonCString_RETNS("Ok") forState:UIControlStateNormal];
		[m_btnOk addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:m_btnOk];
		
		m_btnCancle = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		m_btnCancle.frame = CGRectMake(300, 280, 60, 30);
		[m_btnCancle setTitle:NDCommonCString_RETNS("Cancel") forState:UIControlStateNormal];
		[m_btnCancle addTarget:self action:@selector(cancleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:m_btnCancle];
		
		self.backgroundColor = [UIColor grayColor];
		
		CGAffineTransform transForm = CGAffineTransformMakeRotation(degreesToRadian(90));
		[self setCenter:CGPointMake(160, 240)];
		[self setTransform:transForm];
	}
	return self;
}

- (void)dealloc
{
	[m_edits release];
	[m_radioButtons release];
	[m_buttons release];
	
	[super dealloc];
}

- (void)SetOkCancleButtonPosY:(NSUInteger)y
{
	CGRect rect = m_btnOk.frame;
	m_btnOk.frame = CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
	rect = m_btnCancle.frame;
	m_btnCancle.frame = CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
}

- (void)SetEditNumbers:(NSUInteger)numbers Tags:(NSArray *)tags Titles:(NSArray *)titles
{
	NDAsssert(numbers == [tags count] && numbers == [titles count]);
	
	CGPoint startPos = CGPointMake(CONTROL_INTERVAL, CONTROL_INTERVAL);
	
	if ([m_edits count] > 0) 
	{
		for (NSUInteger i = [m_edits count] - 1; i >= numbers; i--) 
		{
			NSDictionary *dict = [m_edits objectAtIndex:i];
			
			UITextField *textField = [dict objectForKey:@"edit"];
			[textField removeFromSuperview];
			
			UILabel *label = [dict objectForKey:@"editLabel"];
			[label removeFromSuperview];
			
			[m_edits removeObjectAtIndex:i];
		}
	}	
	
	for (NSUInteger i = [m_edits count]; i < numbers; i++) 
	{
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		
		int nLines = [[(NSString*)[titles objectAtIndex:i] componentsSeparatedByString:@"\n"] count];
		nLines <= 0 ? nLines = 1 : 0;
		
		UILabel *label = [[UILabel alloc] initWithFrame:
						  CGRectMake(startPos.x, 
									 startPos.y + (LABEL_HEIGHT * nLines + CONTROL_INTERVAL + EDIT_HEIGHT + CONTROL_INTERVAL) * i,
									 LABEL_WIDTH, 
									 LABEL_HEIGHT * nLines)];
		[label setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
		[dict setObject:label forKey:@"editLabel"];
		[self addSubview:label];
		[label release];
		
		UITextField *textField = [[UITextField alloc] initWithFrame:
								  CGRectMake(startPos.x, 
											 label.frame.origin.y + LABEL_HEIGHT * nLines + CONTROL_INTERVAL, 
											 EDIT_WIDTH, 
											 EDIT_HEIGHT)];
		textField.borderStyle = UITextBorderStyleRoundedRect;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.returnKeyType = UIReturnKeyDone;
		textField.delegate = self;	
		[dict setObject:textField forKey:@"edit"];		
		[self addSubview:textField];
		[textField release];
		
		[dict setObject:[NSNumber numberWithInt:-1] forKey:@"editMaxLength"];
		[dict setObject:[NSNumber numberWithInt:0] forKey:@"editMinLength"];
		
		[m_edits addObject:dict];
		[dict release];
	}
	
	for (NSUInteger i = 0; i < [titles count]; i++) 
	{
		NSDictionary *dict = [m_edits objectAtIndex:i];
		
		UILabel *label = [dict objectForKey:@"editLabel"];
		label.text = [titles objectAtIndex:i];
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		
		UITextField *textField = [dict objectForKey:@"edit"];
		[textField setTag:[[tags objectAtIndex:i] intValue]];
	}
}

- (void)SetEditText:(const char*)text Index:(NSUInteger)editIndex
{
	if (editIndex < [m_edits count]) 
	{
		NSDictionary *dict = [m_edits objectAtIndex:editIndex];
		UITextField *textField = [dict objectForKey:@"edit"];
		textField.text = [NSString stringWithUTF8String:text];
	}
}

- (NSString *)GetEditTextWithIndex:(NSUInteger)editIndex
{
	if (editIndex < [m_edits count]) 
	{
		NSDictionary *dict = [m_edits objectAtIndex:editIndex];
		UITextField *textField = [dict objectForKey:@"edit"];
		return textField.text;
	}
	return nil;
}

- (void)SetEditPassword:(bool)password Index:(NSUInteger)editIndex
{
	if (editIndex < [m_edits count]) 
	{
		NSDictionary *dict = [m_edits objectAtIndex:editIndex];
		UITextField *textField = [dict objectForKey:@"edit"];
		textField.secureTextEntry = password;
	}
}

- (bool)EditIsPasswordWithIndex:(NSUInteger)editIndex
{
	if (editIndex < [m_edits count]) 
	{
		NSDictionary *dict = [m_edits objectAtIndex:editIndex];
		UITextField *textField = [dict objectForKey:@"edit"];
		return textField.secureTextEntry;
	}
	return false;
}

- (void)SetEditMaxLength:(NSUInteger)maxLength Index:(NSUInteger)editIndex
{
	if (editIndex < [m_edits count]) 
	{
		NSMutableDictionary *dict = [m_edits objectAtIndex:editIndex];
		[dict setObject:[NSNumber numberWithInt:maxLength] forKey:@"editMaxLength"];
	}
}

- (NSUInteger)GetEditMaxLengthWithIndex:(NSUInteger)editIndex
{
	if (editIndex < [m_edits count]) 
	{
		NSDictionary *dict = [m_edits objectAtIndex:editIndex];
		return [[dict objectForKey:@"editMaxLength"] intValue];
	}
	return -1;
}

- (void)SetEditMinLength:(NSUInteger)minLength Index:(NSUInteger)editIndex
{
	if (editIndex < [m_edits count]) 
	{
		NSMutableDictionary *dict = [m_edits objectAtIndex:editIndex];
		[dict setObject:[NSNumber numberWithInt:minLength] forKey:@"editMinLength"];
	}
}

- (NSUInteger)GetEditMinLengthWithIndex:(NSUInteger)editIndex
{
	if (editIndex < [m_edits count]) 
	{
		NSDictionary *dict = [m_edits objectAtIndex:editIndex];
		return [[dict objectForKey:@"editMinLength"] intValue];
	}
	return -1;
}

- (void)SetRadioButtonNumbers:(NSUInteger)numbers Tags:(NSArray *)tags Titles:(NSArray *)titles
{
	NDAsssert(numbers == [tags count] && numbers == [titles count]);
	
	CGPoint startPos;
	if ([m_edits count] > 0) 
	{
		NSDictionary *dict = [m_edits lastObject];
		UITextField *textField = [dict objectForKey:@"edit"];
		startPos = CGPointMake(CONTROL_INTERVAL, textField.frame.origin.y + textField.frame.size.height + CONTROL_INTERVAL);
	}
	else 
	{
		startPos = CGPointMake(CONTROL_INTERVAL, CONTROL_INTERVAL);
	}
	
	
	if ([m_radioButtons count] > 0) 
	{
		for (NSUInteger i = [m_radioButtons count] - 1; i >= numbers; i--) 
		{
			NSDictionary *dict = [m_radioButtons objectAtIndex:i];
			
			UIButton *button = [dict objectForKey:@"radioButton"];
			[button removeFromSuperview];
			
			UILabel *label = [dict objectForKey:@"radioButtonLabel"];
			[label removeFromSuperview];
			
			[m_radioButtons removeObjectAtIndex:i];
		}
	}	
	
	for (NSUInteger i = [m_radioButtons count]; i < numbers; i++) 
	{
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		
		UIButton *button = [[UIButton alloc] initWithFrame:
							CGRectMake(startPos.x, 
									   startPos.y + (RADIO_BUTTON_HEIGHT + CONTROL_INTERVAL) * i,
									   RADIO_BUTTON_WIDTH, 
									   RADIO_BUTTON_WIDTH)];
		[button setImage:[UIImage imageWithContentsOfFile:IMAGE_RADIO_BUTTON_OFF] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(radioButtonClick:) forControlEvents:UIControlEventTouchUpInside];
		[dict setObject:button forKey:@"radioButton"];
		[self addSubview:button];
		[button release];			
		
		UILabel *label = [[UILabel alloc] initWithFrame:
						  CGRectMake(button.frame.origin.x + button.frame.size.width + CONTROL_INTERVAL, 
									 button.frame.origin.y + (button.frame.size.height - LABEL_HEIGHT) / 2,
									 LABEL_WIDTH, 
									 LABEL_HEIGHT)];
		[label setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
		[dict setObject:label forKey:@"radioButtonLabel"];
		[self addSubview:label];
		[label release];
		
		[dict setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
		
		[m_radioButtons addObject:dict];		
		[dict release];		
		
	}
	
	for (NSUInteger i = 0; i < [titles count]; i++) 
	{
		NSMutableDictionary *dict = [m_radioButtons objectAtIndex:i];
		
		if (i == 0) 
		{
			[dict setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
			UIButton *button = [dict objectForKey:@"radioButton"];
			[button setImage:[UIImage imageWithContentsOfFile:IMAGE_RADIO_BUTTON_ON] forState:UIControlStateNormal];
		}
		
		UILabel *label = [dict objectForKey:@"radioButtonLabel"];
		label.text = [titles objectAtIndex:i];
		
		UIButton *button = [dict objectForKey:@"radioButton"];
		[button setTag:[[tags objectAtIndex:i] intValue]];
	}
}

- (int)GetActiveRadioButtonIndex
{
	return m_activeRadioButtonIndex;
}

- (int)GetActiveRadioButtonTag
{
	if (m_activeRadioButtonIndex >= 0 && [m_radioButtons count] > (NSUInteger)m_activeRadioButtonIndex) 
	{
		NSDictionary *dict = [m_radioButtons objectAtIndex:m_activeRadioButtonIndex];
		UIButton *radioButton = [dict objectForKey:@"radioButton"];
		return radioButton.tag;
	}
	return -1;
}

- (void)SetActiveRadioButtonWithIndex:(NSUInteger)index
{
	if (index < [m_radioButtons count]) 
	{
		NSDictionary *dict = [m_radioButtons objectAtIndex:index];
		UIButton *radioButton = [dict objectForKey:@"radioButton"];
		[self radioButtonClick:radioButton];
	}
}

- (void)SetOrtherButtonNumbers:(NSUInteger)numbers Tags:(NSArray *)tags Titles:(NSArray *)titles
{
	NDAsssert(numbers == [tags count] && numbers == [titles count]);
	
	CGPoint startPos;
	if ([m_radioButtons count] > 0) 
	{
		NSDictionary *dict = [m_radioButtons lastObject];
		UIButton *button = [dict objectForKey:@"radioButton"];
		startPos = CGPointMake(CONTROL_INTERVAL, button.frame.origin.y + button.frame.size.height + CONTROL_INTERVAL);
	}
	else if ([m_edits count] > 0) 
	{
		NSDictionary *dict = [m_edits lastObject];
		UITextField *textField = [dict objectForKey:@"edit"];
		startPos = CGPointMake(CONTROL_INTERVAL, textField.frame.origin.y + textField.frame.size.height + CONTROL_INTERVAL);
	}
	else 
	{
		startPos = CGPointMake(CONTROL_INTERVAL, CONTROL_INTERVAL);
	}
	
	if ([m_buttons count] > 0) 
	{
		for (NSUInteger i = [m_buttons count] - 1; i >= numbers; i--) 
		{
			NSDictionary *dict = [m_buttons objectAtIndex:i];
			
			UIButton *button = [dict objectForKey:@"button"];
			[button removeFromSuperview];
			
			[m_buttons removeObjectAtIndex:i];
		}
	}	
	
	for (NSUInteger i = [m_buttons count]; i < numbers; i++) 
	{
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		button.frame = CGRectMake(startPos.x + (BUTTON_WIDTH + CONTROL_INTERVAL * 10) * (i % 5), 
								  startPos.y + (BUTTON_HEIGHT + CONTROL_INTERVAL) * (i / 5), 
								  BUTTON_WIDTH, 
								  BUTTON_HEIGHT);
		[button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
		
		[dict setObject:button forKey:@"button"];
		[self addSubview:button];			
				
		[m_buttons addObject:dict];		
		[dict release];		
		
	}
	
	for (NSUInteger i = 0; i < [titles count]; i++) 
	{
		NSDictionary *dict = [m_buttons objectAtIndex:i];
		
		UIButton *button = [dict objectForKey:@"button"];
		[button setTag:[[tags objectAtIndex:i] intValue]];
		[button setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
	}
}

- (NSMutableDictionary *)dictionaryInArray:(NSArray *)array withObject:(id)object key:(NSString *)key
{
	for (NSUInteger i = 0; i < [array count]; i++) 
	{
		NSMutableDictionary *dict = [array objectAtIndex:i];
		
		id dictObject = [dict objectForKey:key];
		if (dictObject == object) 
		{
			return dict;
		}
	}
	return nil;
}

#pragma mark --
#pragma mark delegates

- (void)radioButtonClick:(id)sender
{
	UIButton *button = sender;	
	[button setImage:[UIImage imageWithContentsOfFile:IMAGE_RADIO_BUTTON_ON] forState:UIControlStateNormal];
	
	for (NSUInteger i = 0; i < [m_radioButtons count]; i++) 
	{
		NSDictionary *dict = [m_radioButtons objectAtIndex:i];
		UIButton *radioButton = [dict objectForKey:@"radioButton"];
		if (radioButton != button) 
		{
			[radioButton setImage:[UIImage imageWithContentsOfFile:IMAGE_RADIO_BUTTON_OFF] forState:UIControlStateNormal];
		}
	}
	
	if (_nduiCustomView) 
	{		
		NSUInteger j = 0;		
		for (; j < [m_radioButtons count]; j++) 
		{
			NSDictionary *dict = [m_radioButtons objectAtIndex:j];
			UIButton *radioButton = [dict objectForKey:@"radioButton"];
			if (radioButton == button) 
			{
				break;
			}
		}
		
		m_activeRadioButtonIndex = j;
		
		NDUICustomViewDelegate* delegate = dynamic_cast<NDUICustomViewDelegate*> (_nduiCustomView->GetDelegate());
		if (delegate) 
			delegate->OnCustomViewRadioButtonSelected(_nduiCustomView, m_activeRadioButtonIndex, button.tag);
	}
}

- (void)buttonClick:(id)sender
{
	if (_nduiCustomView) 
	{
		UIButton *button = sender;
		
		NSUInteger i = 0;		
		for (; i < [m_buttons count]; i++) 
		{
			NSDictionary *dict = [m_buttons objectAtIndex:i];
			UIButton *ortherButton = [dict objectForKey:@"button"];
			if (ortherButton == button) 
			{
				break;
			}
		}
		
		NDUICustomViewDelegate* delegate = dynamic_cast<NDUICustomViewDelegate*> (_nduiCustomView->GetDelegate());
		if (delegate) 
			delegate->OnCustomViewOrtherButtonClick(_nduiCustomView, i, button.tag);
	}
}

- (void)okButtonClick:(id)sender
{
	if (_nduiCustomView) 
	{
		NDUICustomViewDelegate* delegate = dynamic_cast<NDUICustomViewDelegate*> (_nduiCustomView->GetDelegate());
		if (delegate) {
			if (delegate->OnCustomViewConfirm(_nduiCustomView)) {
				SAFE_DELETE_NODE(_nduiCustomView);
			}
		}
	}	
}

- (void)cancleButtonClick:(id)sender
{
	if (_nduiCustomView) 
	{
		NDUICustomViewDelegate* delegate = dynamic_cast<NDUICustomViewDelegate*> (_nduiCustomView->GetDelegate());
		if (delegate) 
			delegate->OnCustomViewCancle(_nduiCustomView);
		
		SAFE_DELETE_NODE(_nduiCustomView);
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSMutableDictionary *dict = [self dictionaryInArray:m_edits withObject:textField key:@"edit"];
	if (dict) 
	{
		NSUInteger minLength = [[dict objectForKey:@"editMinLength"] intValue];		
		if (textField.text.length < minLength) 
		{
			return NO;
		}		
	}
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{	
	NSMutableDictionary *dict = [self dictionaryInArray:m_edits withObject:textField key:@"edit"];
	if (dict) 
	{
		NSUInteger maxLength = [[dict objectForKey:@"editMaxLength"] intValue];	
		
		if (range.length == (NSUInteger)0) 
		{
			if (textField) 
			{
				NSString *text = [textField text];
				if ([text length] >= maxLength)
				{
					return NO;
				}
			}
		}
//		if (range.location >= maxLength) 
//		{
//			return NO;
//		}
	}	
	return YES;
}

- (void)SetOkTitle:(const char*)text
{
	if (!text) 
		[m_btnOk setTitle:@"" forState:UIControlStateNormal];
	else 
		[m_btnOk setTitle:[NSString stringWithUTF8String:text] forState:UIControlStateNormal];
}

- (void)SetCancelTitle:(const char*)text
{
	if (!text) 
		[m_btnCancle setTitle:@"" forState:UIControlStateNormal];
	else 
		[m_btnCancle setTitle:[NSString stringWithUTF8String:text] forState:UIControlStateNormal];
}

@end
