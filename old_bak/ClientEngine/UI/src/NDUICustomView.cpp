//
//  NDUICustomView.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-2-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDUICustomView.h"
#import "NDDirector.h"
#import "NDIphoneCustomView.h"


namespace NDEngine
{
	IMPLEMENT_CLASS(NDUICustomView, NDUINode)
	
	NDUICustomView::NDUICustomView()
	{
		m_showed = false;
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		m_iphoneCustomView = [[NDIphoneCustomView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
		m_iphoneCustomView.nduiCustomView = this;
		
	}
	
	NDUICustomView::~NDUICustomView()
	{
		if (m_showed) 
		{
			[m_iphoneCustomView removeFromSuperview];
		}
		[m_iphoneCustomView release];
	}
	
	void NDUICustomView::SetEdit(unsigned int numbers, const std::vector<int>& tags, const std::vector<std::string>& titles)
	{
		NSMutableArray *tagAry = [[NSMutableArray alloc] init];
		for (unsigned int i = 0; i < tags.size(); i++) 
		{
			[tagAry addObject:[NSNumber numberWithInt:tags.at(i)]];
		}

		NSMutableArray *titleAry = [[NSMutableArray alloc] init];
		for (unsigned int i = 0; i < titles.size(); i++) 
		{
			[titleAry addObject:[NSString stringWithUTF8String:titles.at(i).c_str()]];
		}
		
		[m_iphoneCustomView SetEditNumbers:numbers Tags:tagAry Titles:titleAry];
		
		[tagAry release];
		[titleAry release];
		
	}
	
	void NDUICustomView::SetEditText(const char* text, unsigned int editIndex)
	{
		[m_iphoneCustomView SetEditText:text Index:editIndex];
	}
	
	std::string NDUICustomView::GetEditText(unsigned int editIndex)
	{
		NSString *res = [m_iphoneCustomView GetEditTextWithIndex:editIndex];
		if (res) 
		{
			return std::string([res UTF8String]);
		}
		return "";
	}
	
	void NDUICustomView::SetEditPassword(bool password, unsigned int editIndex)
	{
		[m_iphoneCustomView SetEditPassword:password Index:editIndex];
	}
	
	bool NDUICustomView::EditIsPassword(unsigned int editIndex)
	{
		return [m_iphoneCustomView EditIsPasswordWithIndex:editIndex];
	}
	
	void NDUICustomView::SetEditMaxLength(unsigned int maxLength, unsigned int editIndex)
	{
		[m_iphoneCustomView SetEditMaxLength:maxLength Index:editIndex];
	}
	
	unsigned int NDUICustomView::GetEditMaxLength(unsigned int editIndex)
	{
		return [m_iphoneCustomView GetEditMaxLengthWithIndex:editIndex];
	}
	
	void NDUICustomView::SetEditMinLength(unsigned int minLength, unsigned int editIndex)
	{
		[m_iphoneCustomView SetEditMinLength:minLength Index:editIndex];
	}
	
	unsigned int NDUICustomView::GetEditMinLength(unsigned int editIndex)
	{
		return [m_iphoneCustomView GetEditMinLengthWithIndex:editIndex];
	}	
	
	void NDUICustomView::SetRadioButton(unsigned int numbers, const std::vector<int>& tags, const std::vector<std::string>& titles)
	{
		NSMutableArray *tagAry = [[NSMutableArray alloc] init];
		for (unsigned int i = 0; i < tags.size(); i++) 
		{
			[tagAry addObject:[NSNumber numberWithInt:tags.at(i)]];
		}
		
		NSMutableArray *titleAry = [[NSMutableArray alloc] init];
		for (unsigned int i = 0; i < titles.size(); i++) 
		{
			[titleAry addObject:[NSString stringWithUTF8String:titles.at(i).c_str()]];
		}
		
		[m_iphoneCustomView SetRadioButtonNumbers:numbers Tags:tagAry Titles:titleAry];
		
		[tagAry release];
		[titleAry release];
	}
	
	int NDUICustomView::GetActiveRadioButtonIndex()
	{
		return [m_iphoneCustomView GetActiveRadioButtonIndex];
	}
	
	int NDUICustomView::GetActiveRadioButtonTag()
	{
		return [m_iphoneCustomView GetActiveRadioButtonTag];
	}
	
	void NDUICustomView::SetActiveRadioButtonWithIndex(unsigned int index)
	{
		[m_iphoneCustomView SetActiveRadioButtonWithIndex:index];
	}
	
	void NDUICustomView::SetButton(unsigned int numbers, const std::vector<int>& tags, const std::vector<std::string>& titles)
	{
		NSMutableArray *tagAry = [[NSMutableArray alloc] init];
		for (unsigned int i = 0; i < tags.size(); i++) 
		{
			[tagAry addObject:[NSNumber numberWithInt:tags.at(i)]];
		}
		
		NSMutableArray *titleAry = [[NSMutableArray alloc] init];
		for (unsigned int i = 0; i < titles.size(); i++) 
		{
			[titleAry addObject:[NSString stringWithUTF8String:titles.at(i).c_str()]];
		}
		
		[m_iphoneCustomView SetOrtherButtonNumbers:numbers Tags:tagAry Titles:titleAry];
		
		[tagAry release];
		[titleAry release];
	}	
	
	void NDUICustomView::Show()
	{
		if (m_showed) 
			return;
		
		UIWindow *win = [UIApplication sharedApplication].keyWindow; 
		[win addSubview:m_iphoneCustomView];
		
		m_showed = true;
	}
	
	void NDUICustomView::Hide()
	{
		if (m_showed) 
		{
			[m_iphoneCustomView removeFromSuperview];
			m_showed = false;
		}		
	}
	
	void NDUICustomView::ShowAlert(const char* pszAlert)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NDCommonCString_RETNS("tip") message:[NSString stringWithUTF8String:pszAlert] delegate:nil cancelButtonTitle:NDCommonCString_RETNS("haode") otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	void NDUICustomView::SetOkCancleButtonPosY(unsigned int y)
	{
		[m_iphoneCustomView SetOkCancleButtonPosY:y];
	}
	
	void NDUICustomView::SetOkTitle(const char* text)
	{
		[m_iphoneCustomView SetOkTitle:text];
	}
	
	void NDUICustomView::SetCancelTitle(const char* text)
	{
		[m_iphoneCustomView SetCancelTitle:text];
	}
	
	////////////////////////////////
	//delegates
	bool NDUICustomViewDelegate::OnCustomViewConfirm(NDUICustomView* customView)
	{
		return true;
	}
	
	void NDUICustomViewDelegate::OnCustomViewCancle(NDUICustomView* customView)
	{
	}
	
	void NDUICustomViewDelegate::OnCustomViewOrtherButtonClick(NDUICustomView* customView, unsigned int ortherButtonIndex, int ortherButtonTag)
	{
	}
	
	void NDUICustomViewDelegate::OnCustomViewRadioButtonSelected(NDUICustomView* customView, unsigned int radioButtonIndex, int ortherButtonTag)
	{
	}
	
}
