/*
 *  IphoneInput.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "IphoneInput.h"
#include "NDDirector.h"
#include "define.h"

NS_NDENGINE_BGN

#if 0
#include "CCDirectorIOS.h"
using namespace NDEngine;

static CGFloat s_fMove	= 0.0f;
@interface NSIphoneInput : NSObject <UITextFieldDelegate>
{
	UITextField* tfContent;
	CIphoneInput* _iphoneInput;
	BOOL _bAutoAjust;
	CGFloat _fKeyBoardHeight;
	//CGFloat _fMove;
}

@property(nonatomic, retain) UITextField* tfContent;

- (void)SetIphoneInput:(CIphoneInput*) input;
- (void)AutoAdjust:(BOOL) bAuto;
-(void) orientationChanged:(NSNotification *)notification;
-(void)KeyBoardWillShow:(NSNotification*)notification;
-(void)keyBoardWasHidden:(NSNotification*)notification;
-(void)ChangeView:(float) fMove;

@end

@implementation NSIphoneInput

@synthesize tfContent;

-(id) init
{
	if( (self=[super init]) ) {
		tfContent			= nil;
		_iphoneInput		= NULL;
		_bAutoAjust			= false;
		_fKeyBoardHeight	= 162.0f;//216.0f;
		//_fMove				= 0.0f;
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(KeyBoardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(orientationChanged:) 
													 name:UIDeviceOrientationDidChangeNotification 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyBoardWasHidden:) 
													 name:UIKeyboardDidHideNotification
													 object:nil];
#ifdef __IPHONE_5_0
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 5.0) 
		{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyBoardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        }
#endif
	}
	
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UIDeviceOrientationDidChangeNotification 
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UIKeyboardWillShowNotification 
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
												 name:UIKeyboardDidHideNotification
											   object:nil];
#ifdef __IPHONE_5_0
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (version >= 5.0) 
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:UIKeyboardWillChangeFrameNotification 
													  object:nil];
	}
#endif
	[self ChangeView: 0.0f];
	[tfContent resignFirstResponder];
	[tfContent removeFromSuperview];
	[tfContent release];
	[super dealloc];
}

-(void) orientationChanged:(NSNotification *)notification
{	
	if (tfContent == nil) 
	{
		return;
	}
	CGAffineTransform t = tfContent.transform;
	UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    ccDeviceOrientation cor = (ccDeviceOrientation)orientation;
	BOOL bChangeKeyBoardPlace	= FALSE;
    if (cor == (ccDeviceOrientation)UIDeviceOrientationLandscapeLeft)
    {
        tfContent.transform = CGAffineTransformRotate(t, 3.141592f);
		bChangeKeyBoardPlace	= TRUE;
    }
    if (cor == (ccDeviceOrientation)UIDeviceOrientationLandscapeRight) 
	{
        tfContent.transform		= CGAffineTransformRotate(t, 3.141592f);
		bChangeKeyBoardPlace	= TRUE;
    }
	if (bChangeKeyBoardPlace)
	{
		[tfContent resignFirstResponder];
	}
}
-(void)KeyBoardWillShow:(NSNotification*)notification
{
	if (nil == tfContent || NO == [tfContent isFirstResponder])
	{
		return;
	}
	NSDictionary* info	= [notification userInfo];
	CGSize kbSize		= [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	_fKeyBoardHeight	= kbSize.width;
	CGRect bounds	= tfContent.frame;
	ccDeviceOrientation cor = [[CCDirector sharedDirector] deviceOrientation];
	if ((ccDeviceOrientation)UIDeviceOrientationLandscapeLeft == cor)
	{
		CGRect rectScr	= [[UIScreen mainScreen] bounds];
		if (bounds.origin.x < _fKeyBoardHeight)
		{
			[self ChangeView: bounds.origin.x - _fKeyBoardHeight];
		}
	}
	else if ((ccDeviceOrientation)UIDeviceOrientationLandscapeRight == cor)
	{
		CGRect rectScr	= [[UIScreen mainScreen] bounds];
		float fH		= rectScr.size.width - bounds.origin.x - bounds.size.width;
		if (fH  < _fKeyBoardHeight)
		{
			[self ChangeView:_fKeyBoardHeight - fH];
		}
	}
}

-(void)keyBoardWasHidden:(NSNotification*)notification
{
	if (nil == tfContent || NO == [tfContent isFirstResponder])
	{
		return;
	}
	[self ChangeView: 0.0f];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (_bAutoAjust && tfContent)
	{
		CGRect bounds	= tfContent.frame;
		ccDeviceOrientation cor = [[CCDirector sharedDirector] deviceOrientation];
		if ((ccDeviceOrientation)UIDeviceOrientationLandscapeLeft == cor)
		{
		if (bounds.origin.x < _fKeyBoardHeight)
		{
			[self ChangeView: bounds.origin.x - _fKeyBoardHeight];
			}
		}
		else if ((ccDeviceOrientation)UIDeviceOrientationLandscapeRight == cor)
		{
			CGRect rectScr	= [[UIScreen mainScreen] bounds];
			float fH		= rectScr.size.width - bounds.origin.x - bounds.size.width;
			if (fH  < _fKeyBoardHeight)
			{
				[self ChangeView:_fKeyBoardHeight - fH];
			}
		}
	}

	if (_iphoneInput)
	{
		_iphoneInput->SetInputState(true);
	}
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (_bAutoAjust && tfContent)
	{
		[self ChangeView: 0.0f];
	}
    
    if (_iphoneInput)
	{
		CInputBase* input = _iphoneInput->GetInputDelegate();
		if (input)
		{
            input->OnInputFinish(input);
		}
	}
	
	if (_iphoneInput)
	{
		_iphoneInput->SetInputState(false);
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (_iphoneInput)
	{
		CInputBase* input = _iphoneInput->GetInputDelegate();
		if (input && !input->OnInputReturn(input))
		{
			return NO;
		}
	}
	[tfContent resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	/*
	 NSUInteger len = [string length] + [[textField text] length] - range.length;
	 if (len > MAX_CHAT_INPUT) {
	 return NO;
	 }
	 */
	if (_iphoneInput)
	{
		CInputBase* input = _iphoneInput->GetInputDelegate();
		if (input && !input->OnInputTextChange(input, [string UTF8String]))
		{
			return NO;
		}
        
        unsigned int nLengthLimit = _iphoneInput->GetLengthLimit();
        //** chh 2012-08-14 **//
        if(range.location >= nLengthLimit){
            return NO;
        }
	}
	
	return YES;
}

- (void)SetIphoneInput:(CIphoneInput*) input
{
	_iphoneInput	= input;
}

- (void)AutoAdjust:(BOOL) bAuto
{
	_bAutoAjust		= bAuto;
}

-(void)ChangeView:(float) fMove
{
	float fMoveDis	= -(s_fMove) + fMove; 
	s_fMove			= fMove;
	
	CGAffineTransform t = [[CCDirector sharedDirector] openGLView].transform;
	[[CCDirector sharedDirector] openGLView].transform = CGAffineTransformTranslate(t, -fMoveDis, 0);
}

@end
#endif 

CIphoneInput::CIphoneInput()
{
	m_inputCommon	= NULL;
	//m_inputIphone	= NULL;
	m_bAutoAdjust	= false;
	m_bInputState	= false;
	m_bShow			= false;
}

CIphoneInput::~CIphoneInput()
{
#if 0
	//if (m_inputIphone.tfContent && m_inputIphone.tfContent.superview)
    if (m_bShow)
	{
		[m_inputIphone.tfContent resignFirstResponder];
		[m_inputIphone.tfContent removeFromSuperview];
	}
	[m_inputIphone release];
#endif 
}

void CIphoneInput::Init()
{
#if 0
	m_inputIphone	= [[NSIphoneInput alloc] init];
	UITextField* tf = [[UITextField alloc] init];
	//tf.borderStyle = UITextBorderStyleRoundedRect;
	tf.clearButtonMode = UITextFieldViewModeWhileEditing;

	/*
	ccDeviceOrientation cor = [[CCDirector sharedDirector] deviceOrientation];
	if ((ccDeviceOrientation)UIDeviceOrientationLandscapeLeft == cor)
	{
		tf.transform = CGAffineTransformMakeRotation(3.141592f/2.0f);
	}
	else if ((ccDeviceOrientation)UIDeviceOrientationLandscapeRight == cor)
	{
		tf.transform = CGAffineTransformMakeRotation(-3.141592f/2.0f);
	}*/
	
	tf.textColor = [UIColor blueColor];
	tf.returnKeyType = UIReturnKeyDone;
	tf.delegate = m_inputIphone;
	[m_inputIphone SetIphoneInput:this];
	m_inputIphone.tfContent	=  tf;
	[[[CCDirector sharedDirector] openGLView] addSubview:m_inputIphone.tfContent];
	[tf release];
#endif 
}

void CIphoneInput::Show()
{
#if 0
	if (m_inputIphone.tfContent && nil == m_inputIphone.tfContent.superview)
	{
		[[[CCDirector sharedDirector] openGLView] addSubview:m_inputIphone.tfContent];
		[m_inputIphone.tfContent becomeFirstResponder];
	}
	m_bShow		= true;
#endif
}

void CIphoneInput::Hide()
{
#if 0
	if (m_inputIphone.tfContent && nil != m_inputIphone.tfContent.superview)
	{
		[m_inputIphone.tfContent resignFirstResponder];
		[m_inputIphone.tfContent removeFromSuperview];
	}
	m_bShow		= false;
#endif 
}

bool CIphoneInput::IsShow()
{
	return m_bShow;
}
void CIphoneInput::SetFrame(float fX, float fY, float fW, float fH)
{
#if 0
	NDDirector& director	= *(NDDirector::DefaultDirector());
	CGSize winsize = director.GetWinPoint();
    float fScale	= director.GetScaleFactor();
	
	if (director.IsEnableRetinaDisplay())
	{
		/*
		float fScale	= director.GetScaleFactor();
		float fScaleY	= director.GetScaleFactorY();
		
		fX	/= fScale;
		fY	/= fScaleY;
		fW	/= fScale;
		fH	/= fScaleY;
		*/
		fX	/= fScale;
		fY	/= fScale;
		fW	/= fScale;
		fH	/= fScale;
	}
	
	
	if (m_inputIphone && m_inputIphone.tfContent)
	{
		ccDeviceOrientation cor = [[CCDirector sharedDirector] deviceOrientation];
		if ((ccDeviceOrientation)UIDeviceOrientationLandscapeLeft == cor)
		{
            m_inputIphone.tfContent.frame	= CGRectMake(winsize.height - fY - fH, fX, fH, fW);
			m_inputIphone.tfContent.transform = CGAffineTransformMakeRotation(3.141592f/2.0f);
		}
		else if ((ccDeviceOrientation)UIDeviceOrientationLandscapeRight == cor)
		{
			m_inputIphone.tfContent.frame	= CGRectMake(fY, winsize.width - fX - fW, fH, fW);
			m_inputIphone.tfContent.transform = CGAffineTransformMakeRotation(-3.141592f/2.0f);
		}
	}
#endif 
}

void CIphoneInput::SetInputDelegate(CInputBase* input)
{
	m_inputCommon	= input;
}

CInputBase* CIphoneInput::GetInputDelegate()
{
	return m_inputCommon;
}

void CIphoneInput::SetText(const char* text)
{
#if 0
	if (m_inputIphone && m_inputIphone.tfContent)
	{
		NSString *content = [NSString stringWithUTF8String:(text == NULL ? "" : text)];
		m_inputIphone.tfContent.text = content;
	}
#endif 
}

const char* CIphoneInput::GetText()
{
#if 0
	if (m_inputIphone && m_inputIphone.tfContent && m_inputIphone.tfContent.text)
	{
		return [m_inputIphone.tfContent.text UTF8String];
	}
#endif	
	return "";
 
}

void CIphoneInput::EnableSafe(bool bEnable)
{
#if o
	if (m_inputIphone && m_inputIphone.tfContent)
	{
		m_inputIphone.tfContent.secureTextEntry = bEnable;
	}
#endif 
}

void CIphoneInput::EnableAutoAdjust(bool bEnable)
{
#if 0
	if (m_inputIphone && m_inputIphone)
	{
		[m_inputIphone AutoAdjust:bEnable];
	}
	
	m_bAutoAdjust	= bEnable;
#endif 
}

bool CIphoneInput::IsInputState()
{
	return m_bInputState;
}

void CIphoneInput::SetStyleNone()
{
#if 0
	if (m_inputIphone && m_inputIphone.tfContent)
	{
		m_inputIphone.tfContent.borderStyle = UITextBorderStyleNone;
	}
#endif 
}
void CIphoneInput::SetTextColor(float fR, float fG, float fB, float fA)
{
#if 0
	if (m_inputIphone && m_inputIphone.tfContent)
	{
		m_inputIphone.tfContent.textColor = [UIColor colorWithRed:fR green:fB blue:fB alpha:fA];
	}	
#endif 
}
void CIphoneInput::SetFontSize(int nFontSize)
{
#if 0
	if (m_inputIphone && m_inputIphone.tfContent)
	{
		m_inputIphone.tfContent.font = [UIFont systemFontOfSize:nFontSize];
	}
#endif 
}
void CIphoneInput::SetInputState(bool bSet)
{
	m_bInputState	= bSet;
}
//////////////////////////////////////////////////////
void CIphoneInput::SetLengthLimit(unsigned int nLengthLimit)
{
    m_usLengthLimit = nLengthLimit;
}
//////////////////////////////////////////////////////
unsigned int CIphoneInput::GetLengthLimit(void)
{
    return m_usLengthLimit;
}

NS_NDENGINE_END