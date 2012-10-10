//
//  NDIphoneEdit.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDIphoneEdit.h"
#import "NDUILayer.h"
#import "NDDirector.h"
#import "define.h"

@implementation NDIphoneEdit

@synthesize textField = _textField, nduiLayer = _nduiLayer, nduiEdit = _nduiEdit, maxLength = _maxLength, minLength = _minLength;

static NDIphoneEdit *default_NDIphoneEdit = nil;
+ (id)defaultEdit
{
	if (default_NDIphoneEdit == nil) 
	{
		default_NDIphoneEdit = [[NDIphoneEdit alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
	}
	return default_NDIphoneEdit;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) 
	{
		_nduiLayer = nil;
		_nduiEdit  = nil;
		_maxLength = -1;
		_minLength = -1;
		
		_textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 460, 30)];
		_textField.borderStyle = UITextBorderStyleRoundedRect;
		_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_textField.returnKeyType = UIReturnKeyDone;
		_textField.delegate = self;		
		[self addSubview:_textField];
		[_textField release];
		
		m_lblNote = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 460, 30)];
		m_lblNote.text = @"";
		m_lblNote.textColor = [UIColor redColor];
		m_lblNote.backgroundColor = [UIColor grayColor];
		[self addSubview:m_lblNote];
		[m_lblNote release];
		
		m_btnOk = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		m_btnOk.frame = CGRectMake(100, 100, 60, 30);
		[m_btnOk setTitle:NDCommonCString_RETNS("Ok") forState:UIControlStateNormal];
		[m_btnOk addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:m_btnOk];
		
		m_btnCancle = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		m_btnCancle.frame = CGRectMake(300, 100, 60, 30);
		[m_btnCancle setTitle:NDCommonCString_RETNS("Cancel") forState:UIControlStateNormal];
		[m_btnCancle addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:m_btnCancle];
		
		self.backgroundColor = [UIColor grayColor];
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		CGAffineTransform transForm = CGAffineTransformMakeRotation(degreesToRadian(90));
		[self setCenter:CGPointMake(winSize.height / 2, winSize.width / 2)];
		[self setTransform:transForm];
	}
	return self;
}

- (void)buttonClick:(id)sender
{
	if (_nduiLayer) 
	{		
		if (sender == m_btnOk) 
		{
			_nduiLayer->IphoneEditInputFinish(_nduiEdit);
			[self removeFromSuperview];
		}
		else if (sender == m_btnCancle)
		{
			_nduiLayer->IphoneEditInputCancle(_nduiEdit);
			[self removeFromSuperview];
		}
	}		
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (_minLength > 0) 
	{
		if (_textField.text.length < (unsigned int)_minLength)
		{
			m_lblNote.text = [NSString stringWithFormat:@"%@%d%@", 
							  NDCString_RETNS("InputSmallLimit"),
							  _minLength,
							  NDCString_RETNS("ge")];
			return NO;
		}
	}
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{	
	BOOL ret = YES;
	if (_maxLength > -1) 
	{
		//if (range.location > (unsigned int)_maxLength) 
//		{
//			m_lblNote.text = [NSString stringWithFormat:@"输入的字符数不可超过%d个", _maxLength + 1];
//			return NO;			
//		}
			
		NSUInteger len = [string length] + [[textField text] length] - range.length;
		if (len > (NSUInteger)(_maxLength)) {
			m_lblNote.text = [NSString stringWithFormat:@"%@%d%@", 
							  NDCString_RETNS("InputBigLimit"),
							  _maxLength + 1,
							 NDCString_RETNS("ge")];
//			m_lblNote.text = [NSString stringWithFormat:@"%s%d%s", 
//							  NDCString("InputBigLimit"),
//							  _maxLength + 1,
//							  NDCString("ge")];
			return NO;
		}
		
		/*if (range.length == (NSUInteger)0) 
		{
			if (textField) 
			{
				NSString *text = [textField text];
				if ([text length] > (NSUInteger)(_maxLength))
				{
					m_lblNote.text = [NSString stringWithFormat:@"输入的字符数不可超过%d个", _maxLength + 1];
					return NO;
				}
			}
		}*/
	}
	
	if (_nduiEdit) 
	{
		NDUIEditDelegate* delegate = dynamic_cast<NDUIEditDelegate*> (_nduiEdit->GetDelegate());
		if (delegate) 
		{
			ret = delegate->OnEditInputCharcters(_nduiEdit, [string UTF8String]);
		}
	}
	
	m_lblNote.text = @"";
	
	return ret;
}

@end
