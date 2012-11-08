//
//  NDUIDialog.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-24.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDUIDialog.h"
#include "NDUIButton.h"
#include "NDDirector.h"
#include "NDScene.h"
#include "NDPath.h"
#include "CCPointExtension.h"
#include "NDConstant.h"
#include "basedefine.h"


#include <sstream>

namespace NDEngine
{
IMPLEMENT_CLASS(NDUIDialog, NDUILayer)

#define COLOR_TITLE (ccc4(255, 233, 154, 255))
#define COLOR_TITLE_BODER (ccc4(35, 89, 96, 255))
#define COLOR_OPTION_FULLSCR (ccc4(187, 19, 19, 255))
#define COLOR_OPTION (ccc4(255, 255, 255, 255))
#define COLOR_CONTENT_FULLSCR (ccc4(79, 79, 79, 255))
#define COLOR_CONTENT_NOTFULLSCR (ccc4(255, 233, 154, 255))

#define TAG_TIMER_DLG_TIMECOUNT (800)

NDUIDialog::NDUIDialog()
{
	INIT_AUTOLINK(NDUIDialog);

	m_contentScroll = NULL;
	m_lbTitle = NULL;
	m_bFullScreen = false;
	m_btnClose = NULL;
	m_lbTime = NULL;
	m_iCurTime = 0;

	memset(m_btnOptions, 0, sizeof(m_btnOptions));

	InitUIData();
}

NDUIDialog::~NDUIDialog()
{
}

void NDUIDialog::Initialization()
{
	NDUILayer::Initialization();
}

void NDUIDialog::InitUIData()
{
	m_uiContentHeightFullScr = 252;
	m_uiContentHeightNotFullScr = 145;
	m_uiContentLeftWidthFullScr = 9;
	m_uiContentLeftWidthNotFullScr = 13;
	m_uiContentTopheight = 10;
	m_uiIntervalBtnAndContent = 6;
	m_uiTitleHeightFullScr = 44;
	m_uiTitleHeightNotFullScr = 45;
	m_sizeNotFullScr = CGSizeMake(367, 245);
	m_sizeBtnFullScr = CGSizeMake(132, 42);
	m_sizeBtnNotFullScr = CGSizeMake(298, 28);
}

void NDUIDialog::InitFullScrBtns(const std::vector<std::string>& ortherButtons)
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();

	NDPicturePool& pool = *(NDPicturePool::DefaultPool());

	for (int i = 0; i < max_btns; i++)
	{
		float x =
				i < max_btns_half ? winsize.width - m_sizeBtnFullScr.width : 0,
				y = m_uiTitleHeightFullScr + 13
						+ (i % max_btns_half) * (m_sizeBtnFullScr.height + 4);

		int leftWidth = i < max_btns_half ? 9 : 21;
		int rightWidth = i < max_btns_half ? 21 : 9;

		NDUIButton*& btn = m_btnOptions[i];
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetFontSize(14);
		btn->SetFrameRect(
				CGRectMake(x, y, m_sizeBtnFullScr.width,
						m_sizeBtnFullScr.height));
		btn->SetDelegate(this);
		btn->SetFontColor(COLOR_OPTION_FULLSCR);
		btn->CloseFrame();
		btn->SetTouchDownImage(
				pool.AddPicture(NDPath::GetImgPathUINew("dlgfull_btn_click.png")),
				false, CGRectZero, true);
		this->AddChild(btn);

		if ((unsigned int) i < ortherButtons.size())
		{
			btn->SetTitle(ortherButtons[i].c_str(), false, false, leftWidth,
					rightWidth);
		}
		else
		{
			btn->EnableEvent(false);
		}
	}
}

std::string NDUIDialog::GetTitle()
{
	if (m_lbTitle)
		return m_lbTitle->GetText();

	return "";
}

void NDUIDialog::Show(const char* title, const char* text,
		const char* cancleButton, const std::vector<std::string>& ortherButtons)
{
	if (this->GetParent())
	{
		return;
	}

	NDPicturePool& pool = *(NDPicturePool::DefaultPool());

	m_bFullScreen = ortherButtons.size() > 1 ? true : false;

	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	CGSize sizeDialog;
	sizeDialog.width = m_bFullScreen ? winsize.width : m_sizeNotFullScr.width;
	sizeDialog.height =
			m_bFullScreen ? winsize.height : m_sizeNotFullScr.height;

	this->SetFrameRect(
			CGRectMake((winsize.width - sizeDialog.width) / 2,
					(winsize.height - sizeDialog.height) / 2, sizeDialog.width,
					sizeDialog.height));

	this->SetBackgroundImage(
			pool.AddPicture(
					NDPath::GetImgPathUINew(
							m_bFullScreen ? "dlgfull_bg.png" : "dlg_bg.png")),
			true);

	m_lbTime = new NDUILabel;
	m_lbTime->Initialization();
	m_lbTime->SetFontSize(16);
	m_lbTime->SetFontColor(ccc4(255, 0, 0, 255));
	m_lbTime->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbTime->SetFrameRect(
			CGRectMake(10, m_bFullScreen ? 14.5f : 18.0f, sizeDialog.width,
					sizeDialog.height));
	this->AddChild(m_lbTime);

	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(16);
	m_lbTitle->SetFontColor(COLOR_TITLE);
	m_lbTitle->SetFontBoderColer(COLOR_TITLE_BODER);
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(
			CGRectMake(0, 0, sizeDialog.width, m_bFullScreen ? 29 : 36));
	this->AddChild(m_lbTitle);

	SetTitle(title);

	m_btnClose = new NDUIButton;
	m_btnClose->Initialization();
	m_btnClose->SetFrameRect(CGRectMake(sizeDialog.width - 45, 0, 45, 45));
	m_btnClose->SetDelegate(this);
	m_btnClose->CloseFrame();
	m_btnClose->SetImage(
			pool.AddPicture(
					NDPath::GetImgPathUINew(
							m_bFullScreen ?
									"dlgfull_close_normal.png" :
									"dlg_close_normal.png").c_str()), false, CGRectZero,
			true);
	m_btnClose->SetTouchDownImage(
			pool.AddPicture(
					NDPath::GetImgPathUINew(
							m_bFullScreen ?
									"dlgfull_close_click.png" :
									"dlg_close_click.png").c_str()), false, CGRectZero,
			true);
	this->AddChild(m_btnClose);

	if (!m_bFullScreen)
	{
		bool hasBtn = ortherButtons.size() == 1;

		m_contentScroll = new NDUIContainerScrollLayer;
		m_contentScroll->Initialization();
		m_contentScroll->SetFrameRect(
				CGRectMake(18, m_uiTitleHeightNotFullScr,
						sizeDialog.width - 18 * 2,
						m_uiContentHeightNotFullScr
								+ (hasBtn ? 0 : m_sizeBtnNotFullScr.height + 6)));
		m_contentScroll->SetDelegate(this);
		m_contentScroll->VisibleScroll(true);
		//m_contentScroll->SetBackgroundImage(pool.AddPicture(NDPath::GetImgPathUINew("attr_role_bg.png"), 317, 242), true);
		this->AddChild(m_contentScroll);
		SetContent(text, COLOR_CONTENT_NOTFULLSCR, 14);
		m_contentScroll->SetBackgroundImage(
				pool.AddPicture(NDPath::GetImgPathUINew("dlg_content.png"),
						m_contentScroll->GetFrameRect().size.width,
						m_contentScroll->GetFrameRect().size.height), true);

		if (hasBtn)
		{
			m_btnConfirm = new NDUIButton;
			m_btnConfirm->Initialization();
			m_btnConfirm->SetTitle(ortherButtons[0].c_str());
			m_btnConfirm->SetFontSize(14);
			m_btnConfirm->SetFontColor(COLOR_OPTION);
			m_btnConfirm->CloseFrame();
			m_btnConfirm->SetImage(
					pool.AddPicture(NDPath::GetImgPathUINew("dlg_btn_normal.png"),
							m_sizeBtnNotFullScr.width,
							m_sizeBtnNotFullScr.height), false, CGRectZero,
					true);
			m_btnConfirm->SetTouchDownImage(
					pool.AddPicture(NDPath::GetImgPathUINew("dlg_btn_click.png"),
							m_sizeBtnNotFullScr.width,
							m_sizeBtnNotFullScr.height), false, CGRectZero,
					true);
			m_btnConfirm->SetFrameRect(
					CGRectMake(
							m_uiIntervalBtnAndContent
									+ (sizeDialog.width
											- m_uiIntervalBtnAndContent * 2
											- m_sizeBtnNotFullScr.width) / 2,
							m_uiTitleHeightNotFullScr
									+ m_contentScroll->GetFrameRect().size.height
									+ 6, m_sizeBtnNotFullScr.width,
							m_sizeBtnNotFullScr.height));
			m_btnConfirm->SetDelegate(this);
			this->AddChild(m_btnConfirm);
		}
	}
	else
	{
		m_contentScroll = new NDUIContainerScrollLayer;
		m_contentScroll->Initialization();
		m_contentScroll->SetFrameRect(
				CGRectMake(m_uiIntervalBtnAndContent + m_sizeBtnFullScr.width,
						m_uiTitleHeightFullScr,
						sizeDialog.width
								- (m_uiIntervalBtnAndContent
										+ m_sizeBtnFullScr.width) * 2,
						m_uiContentHeightFullScr));
		m_contentScroll->SetDelegate(this);
		m_contentScroll->VisibleScroll(true);
		this->AddChild(m_contentScroll);

		SetContent(text, COLOR_CONTENT_FULLSCR, 14);

		InitFullScrBtns(ortherButtons);
	}

	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene)
	{
		scene->AddChild(this, UIDIALOG_Z);

		NDUIDialogDelegate* delegate =
				dynamic_cast<NDUIDialogDelegate*>(this->GetDelegate());
		if (delegate)
		{
			delegate->OnDialogShow(this);
		}
	}
}

void NDUIDialog::Show(const char* title, const char* text,
		const char* cancleButton, const char* ortherButtons, ...)
{
	va_list argumentList;
	char *eachObject;
	std::vector < std::string > btns;

	if (ortherButtons)
	{
		btns.push_back(std::string(ortherButtons));
		va_start(argumentList, ortherButtons);
		while ((eachObject = va_arg(argumentList, char*)))
		{
			btns.push_back(std::string(eachObject));
		}
		va_end(argumentList);
	}

	this->Show(title, text, cancleButton, btns);

}

void NDUIDialog::Show(const char* title, const char* text,
		const char* cancleButton, const std::vector<std::string>& ortherButtons,
		const std::vector<bool> vec_arrow)
{
	Show(title, text, cancleButton, ortherButtons);

	if (ortherButtons.size() == 1 && vec_arrow.size() == 1 && m_btnConfirm)
	{
		m_btnConfirm->SetArrow(vec_arrow[0]);
	}
	else if (ortherButtons.size() > 1 && vec_arrow.size() > 1)
	{
		for (size_t i = 0; i < vec_arrow.size(); i++)
		{
			if (m_btnOptions[i] && m_btnOptions[i]->EventEnabled())
			{
				m_btnOptions[i]->SetArrow(vec_arrow[i]);
			}
		}
	}
}

void NDUIDialog::Show0(const char* title, const char* text)
{
	this->Show(title, text, "", "", NULL);
}

void NDUIDialog::Show1(const char* title, const char* text, const char* op1)
{
	this->Show(title, text, "", op1 ? op1 : "", NULL);
}

void NDUIDialog::Show2(const char* title, const char* text, const char* op1,
		const char* op2)
{
	this->Show(title, text, "", op1 ? op1 : "", op2 ? op2 : "", NULL);
}

void NDUIDialog::Show3(const char* title, const char* text, const char* op1,
		const char* op2, const char* op3)
{
	this->Show(title, text, "", op1 ? op1 : "", op2 ? op2 : "", op3 ? op3 : "",
			NULL);
}

void NDUIDialog::Show4(const char* title, const char* text, const char* op1,
		const char* op2, const char* op3, const char* op4)
{
	this->Show(title, text, "", op1 ? op1 : "", op2 ? op2 : "", op3 ? op3 : "",
			op4 ? op4 : "", NULL);
}

void NDUIDialog::Show5(const char* title, const char* text, const char* op1,
		const char* op2, const char* op3, const char* op4, const char* op5)
{
	this->Show(title, text, "", op1 ? op1 : "", op2 ? op2 : "", op3 ? op3 : "",
			op4 ? op4 : "", op5 ? op5 : "", NULL);
}

void NDUIDialog::Show6(const char* title, const char* text, const char* op1,
		const char* op2, const char* op3, const char* op4, const char* op5,
		const char* op6)
{
	this->Show(title, text, "", op1 ? op1 : "", op2 ? op2 : "", op3 ? op3 : "",
			op4 ? op4 : "", op5 ? op5 : "", op6 ? op6 : "", NULL);
}

void NDUIDialog::Show7(const char* title, const char* text, const char* op1,
		const char* op2, const char* op3, const char* op4, const char* op5,
		const char* op6, const char* op7)
{
	this->Show(title, text, "", op1 ? op1 : "", op2 ? op2 : "", op3 ? op3 : "",
			op4 ? op4 : "", op5 ? op5 : "", op6 ? op6 : "", op7 ? op7 : "",
			NULL);
}

void NDUIDialog::Show8(const char* title, const char* text, const char* op1,
		const char* op2, const char* op3, const char* op4, const char* op5,
		const char* op6, const char* op7, const char* op8)
{
	this->Show(title, text, "", op1 ? op1 : "", op2 ? op2 : "", op3 ? op3 : "",
			op4 ? op4 : "", op5 ? op5 : "", op6 ? op6 : "", op7 ? op7 : "",
			op8 ? op8 : "", NULL);
}

void NDUIDialog::Show9(const char* title, const char* text, const char* op1,
		const char* op2, const char* op3, const char* op4, const char* op5,
		const char* op6, const char* op7, const char* op8, const char* op9)
{
	this->Show(title, text, "", op1 ? op1 : "", op2 ? op2 : "", op3 ? op3 : "",
			op4 ? op4 : "", op5 ? op5 : "", op6 ? op6 : "", op7 ? op7 : "",
			op8 ? op8 : "", op9 ? op9 : "", NULL);
}

void NDUIDialog::Show10(const char* title, const char* text, const char* op1,
		const char* op2, const char* op3, const char* op4, const char* op5,
		const char* op6, const char* op7, const char* op8, const char* op9,
		const char* op10)
{
	this->Show(title, text, "", op1 ? op1 : "", op2 ? op2 : "", op3 ? op3 : "",
			op4 ? op4 : "", op5 ? op5 : "", op6 ? op6 : "", op7 ? op7 : "",
			op8 ? op8 : "", op9 ? op9 : "", op10 ? op10 : "", NULL);
}

bool NDUIDialog::TouchBegin(NDTouch* touch)
{
	if (!(this->IsVisibled() && this->EventEnabled()))
	{
		return false;
	}

	m_kBeginTouch = touch->GetLocation();

	if (m_bFullScreen
			|| CGRectContainsPoint(this->GetScreenRect(), m_kBeginTouch))
	{
		NDUILayer::TouchBegin(touch);

		return true;
	}

	this->Close();

	return true;
}

void NDUIDialog::OnButtonClick(NDUIButton* button)
{
	unsigned int cellIndex = 0;
	if (button == m_btnClose)
	{
		this->Close();

		return;
	}
	else if (button == m_btnConfirm)
	{
		cellIndex = 0;
	}
	else
	{
		for (int i = 0; i < max_btns; i++)
		{
			if (button == m_btnOptions[i])
			{
				cellIndex = i;
				break;
			}
		}
	}

	NDUIDialogDelegate* delegate =
			dynamic_cast<NDUIDialogDelegate*>(this->GetDelegate());
	if (delegate)
	{
		delegate->OnDialogButtonClick(this, cellIndex);
	}
}

bool NDUIDialog::OnLayerMove(NDUILayer* uiLayer, UILayerMove move,
		float distance)
{
	if (uiLayer == m_contentScroll)
		m_contentScroll->OnLayerMove(uiLayer, move, distance);

	return false;
}

void NDUIDialog::SetContent(const char *text,
		cocos2d::ccColor4B color/*=ccc4(79, 79, 79, 255)*/,
		unsigned int fontsize/*=13*/)
{
	if (!m_contentScroll)
		return;

	m_contentScroll->RemoveAllChildren(true);

	if (!text)
		return;

	CGSize textSize;

	textSize.width =
			m_contentScroll->GetFrameRect().size.width
					- (m_bFullScreen ?
							m_uiContentLeftWidthFullScr :
							m_uiContentLeftWidthNotFullScr) * 2;

	textSize.height =
			NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(text,
					textSize.width, fontsize);

	NDUIText* uiText = NDUITextBuilder::DefaultBuilder()->Build(text, fontsize,
			textSize, color, false);

	uiText->SetFrameRect(
			CGRectMake(
					(m_bFullScreen ?
							m_uiContentLeftWidthFullScr :
							m_uiContentLeftWidthNotFullScr),
					m_uiContentTopheight, textSize.width, textSize.height));
	m_contentScroll->AddChild(uiText);

	m_contentScroll->refreshContainer();

	return;
}

void NDUIDialog::SetTitle(const char *text)
{
	if (!text || !m_lbTitle)
		return;

	m_lbTitle->SetText(text);
}

void NDUIDialog::Close()
{
	NDUIDialogDelegate* delegate =
			dynamic_cast<NDUIDialogDelegate*>(this->GetDelegate());
	if (delegate)
	{
		delegate->OnDialogClose(this);
	}

	if (this->GetParent())
	{
		this->RemoveFromParent(true);
	}
}

void NDUIDialog::SetTime(unsigned int sec)
{
	m_timer.KillTimer(this, TAG_TIMER_DLG_TIMECOUNT);

	if (sec > 0)
		m_timer.SetTimer(this, TAG_TIMER_DLG_TIMECOUNT, 1.0f);

	m_iCurTime = sec;

	if (m_iCurTime > 0 && m_lbTime)
	{
		std::stringstream ss;
		ss << m_iCurTime;
		m_lbTime->SetText(ss.str().c_str());
	}
}

void NDUIDialog::OnTimer(OBJID tag)
{
	NDUILayer::OnTimer(tag);

	if (tag == TAG_TIMER_DLG_TIMECOUNT)
	{
		if (m_iCurTime > 0)
			m_iCurTime -= 1;

		if (m_iCurTime > 0 && m_lbTime)
		{
			std::stringstream ss;
			ss << m_iCurTime;
			m_lbTime->SetText(ss.str().c_str());
		}
		else if (m_lbTime)
		{
			m_lbTime->SetText("");
		}

		if (m_iCurTime <= 0)
		{
			m_timer.KillTimer(this, TAG_TIMER_DLG_TIMECOUNT);

			NDUIDialogDelegate* delegate =
					dynamic_cast<NDUIDialogDelegate*>(this->GetDelegate());
			if (!delegate || !delegate->OnDialogTimeOut(this))
			{
				this->TimeOutDefaultDeal();
			}
		}

	}
}

void NDUIDialog::TimeOutDefaultDeal()
{
	this->Close();
}

void NDUIDialogDelegate::OnDialogShow(NDUIDialog* dialog)
{
}

void NDUIDialogDelegate::OnDialogClose(NDUIDialog* dialog)
{
}

void NDUIDialogDelegate::OnDialogButtonClick(NDUIDialog* dialog,
		unsigned int buttonIndex)
{
}

bool NDUIDialogDelegate::OnDialogTimeOut(NDUIDialog* dialog)
{
	return false;
}

/*
 IMPLEMENT_CLASS(NDUIDialog, NDUILayer)

 #define bottom_image [NSString stringWithFormat:@"%@/res/image/bottom.png", [[NSBundle mainBundle] resourcePath]]
 #define TEXT_START_WIDTH (20)

 NDUIDialog::NDUIDialog()
 {
 m_leaveButtonExists = false;
 m_autoRemove = false;

 m_width = 300;
 m_titleHeight = 20;
 m_contextHeight = 80;
 m_buttonHeight = 28;

 m_memo = NULL;

 std::string bottomImage = NDPath::GetImagePath().append("bottom.png");
 m_picLeftTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
 m_picLeftTop->SetReverse(true);
 m_picLeftTop->Rotation(PictureRotation180);

 m_picRightTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
 m_picRightTop->Rotation(PictureRotation180);

 m_picLeftBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());

 m_picRightBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
 m_picRightBottom->SetReverse(true);

 m_bTouchBegin = false;
 }

 NDUIDialog::~NDUIDialog()
 {
 delete m_picLeftTop;
 delete m_picRightTop;
 delete m_picLeftBottom;
 delete m_picRightBottom;
 }

 void NDUIDialog::Initialization()
 {
 NDUILayer::Initialization();

 m_label = new NDUILabel();
 m_label->Initialization();
 m_label->SetTextAlignment(LabelTextAlignmentCenter);
 m_label->SetFontColor(ccc4(255, 255, 0, 255));
 this->AddChild(m_label);

 //		m_memo = new NDUIMemo();
 //		m_memo->Initialization();
 //		m_memo->SetBackgroundColor(ccc3(196, 201, 181));
 //		m_memo->SetFontColor(ccc4(0, 0, 0, 255));
 //		this->AddChild(m_memo);

 m_table = new NDUITableLayer();
 m_table->Initialization();
 m_table->VisibleSectionTitles(false);
 m_table->SetDelegate(this);
 this->AddChild(m_table);

 this->SetFrameRect(CGRectMake(0, 0, NDDirector::DefaultDirector()->GetWinSize().width, NDDirector::DefaultDirector()->GetWinSize().height));
 }

 void NDUIDialog::draw()
 {
 NDUILayer::draw();

 if (this->IsVisibled())
 {
 CGRect scrRect = this->GetScreenRect();

 // top frame
 //			this->DrawLine(ccp(scrRect.origin.x + 40, scrRect.origin.y + 3),
 //						   ccp(scrRect.origin.x + scrRect.size.width - 40, scrRect.origin.y + 3),
 //						   ccc4(49, 93, 90, 255), 1);
 //			this->DrawLine(ccp(scrRect.origin.x + 40, scrRect.origin.y + 4),
 //						   ccp(scrRect.origin.x + scrRect.size.width - 40, scrRect.origin.y + 4),
 //						   ccc4(107, 146, 140, 255), 1);
 //			this->DrawLine(ccp(scrRect.origin.x + 40, scrRect.origin.y + 5),
 //						   ccp(scrRect.origin.x + scrRect.size.width - 40, scrRect.origin.y + 5),
 //						   ccc4(74, 109, 107, 255), 1);

 DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 2),
 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 2),
 ccc4(41, 65, 33, 255), 1);
 DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 3),
 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 3),
 ccc4(57, 105, 90, 255), 1);
 DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 4),
 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 4),
 ccc4(82, 125, 115, 255), 1);
 DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 5),
 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 5),
 ccc4(82, 117, 82, 255), 1);

 //bottom frame
 DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 2),
 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 2),
 ccc4(41, 65, 33, 255), 1);
 DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 3),
 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 3),
 ccc4(57, 105, 90, 255), 1);
 DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 4),
 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 4),
 ccc4(82, 125, 115, 255), 1);
 DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 5),
 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 5),
 ccc4(82, 117, 82, 255), 1);

 //left frame
 DrawLine(ccp(scrRect.origin.x + 13, scrRect.origin.y + 16),
 ccp(scrRect.origin.x + 13, scrRect.origin.y + scrRect.size.height - 16),
 ccc4(73, 119, 119, 255), 10);
 //			this->DrawLine(ccp(scrRect.origin.x + 17, scrRect.origin.y + 16),
 //						   ccp(scrRect.origin.x + 17, scrRect.origin.y + scrRect.size.height - 16),
 //						   ccc4(107, 89, 74, 255), 1);

 //right frame
 DrawLine(ccp(scrRect.origin.x + scrRect.size.width - 13, scrRect.origin.y + 16),
 ccp(scrRect.origin.x + scrRect.size.width - 13, scrRect.origin.y + scrRect.size.height - 16),
 ccc4(73, 119, 119, 255), 8);
 //			this->DrawLine(ccp(scrRect.origin.x + scrRect.size.width - 17, scrRect.origin.y + 16),
 //						   ccp(scrRect.origin.x + scrRect.size.width - 17, scrRect.origin.y + scrRect.size.height - 16),
 //						   ccc4(107, 89, 74, 255), 1);

 //background
 DrawRecttangle(CGRectMake(scrRect.origin.x + 17, scrRect.origin.y + 5, scrRect.size.width - 34, scrRect.size.height - 10), ccc4(0, 0, 0, 188));//ccc4(196, 201, 181, 255));


 //title rect
 //			if (!m_label->GetText().empty())
 //			{
 //				DrawRecttangle(CGRectMake(scrRect.origin.x + 17, scrRect.origin.y + 5, scrRect.size.width - 34, m_titleHeight), ccc4(160, 177, 155, 255));
 //			}

 m_picLeftTop->DrawInRect(CGRectMake(scrRect.origin.x+7,
 scrRect.origin.y,
 m_picLeftTop->GetSize().width,
 m_picLeftTop->GetSize().height));
 m_picRightTop->DrawInRect(CGRectMake(scrRect.origin.x + scrRect.size.width - m_picRightTop->GetSize().width - 7,
 scrRect.origin.y,
 m_picRightTop->GetSize().width,
 m_picRightTop->GetSize().height));
 m_picLeftBottom->DrawInRect(CGRectMake(scrRect.origin.x+7,
 scrRect.origin.y + scrRect.size.height - m_picLeftBottom->GetSize().height,
 m_picLeftBottom->GetSize().width,
 m_picLeftBottom->GetSize().height));
 m_picRightBottom->DrawInRect(CGRectMake(scrRect.origin.x + scrRect.size.width - m_picRightBottom->GetSize().width - 7,
 scrRect.origin.y + scrRect.size.height - m_picRightBottom->GetSize().height,
 m_picRightBottom->GetSize().width,
 m_picRightBottom->GetSize().height));
 }
 }

 void NDUIDialog::Show(const char* title, const char* text, const char* cancleButton, const std::vector<std::string>& ortherButtons)
 {
 if (this->GetParent())
 {
 return;
 }

 m_leaveButtonExists = false;
 m_autoRemove = false;

 if (title && strlen(title) > 0)
 {
 m_label->SetText(title);
 m_label->SetFrameRect(CGRectMake(TEXT_START_WIDTH, 5, m_width - TEXT_START_WIDTH*2, m_titleHeight));
 }
 else
 {
 m_label->SetText("");
 m_label->SetFrameRect(CGRectMake(TEXT_START_WIDTH, 5, 0, 0));
 }

 CGRect tb = m_table->GetFrameRect();

 std::string mmText;
 if (text && strlen(text) > 0)
 {
 mmText = text;
 }
 else
 {
 mmText = "";
 }

 if (mmText.size() > 0) {
 CGSize textSize;
 textSize.width = m_width - TEXT_START_WIDTH*2;
 textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(text, textSize.width, 13);

 float txtHeight = m_contextHeight < textSize.height ? m_contextHeight : textSize.height;
 m_memo = NDUITextBuilder::DefaultBuilder()->Build(mmText.c_str(),
 13,
 CGSizeMake(m_width - TEXT_START_WIDTH*2, txtHeight),
 ccc4(255, 255, 255, 255),
 true);
 m_memo->SetFrameRect(CGRectMake(TEXT_START_WIDTH-2, 10 + m_label->GetFrameRect().size.height, m_width - TEXT_START_WIDTH*2-4, txtHeight + 10));
 this->AddChild(m_memo);
 }

 NDDataSource* dataSource = new NDDataSource();
 NDSection* section = new NDSection();
 section->SetRowHeight(m_buttonHeight);
 dataSource->AddSection(section);
 m_table->SetDataSource(dataSource);
 int nMemoHeight = m_memo == NULL ? 0 : m_memo->GetFrameRect().size.height;
 m_table->SetFrameRect(CGRectMake(17, 15 + m_label->GetFrameRect().size.height + nMemoHeight,
 m_width - 34, 0));
 if (ortherButtons.size() > 0)
 {
 m_table->SetFrameRect(CGRectMake(17, 15 + m_label->GetFrameRect().size.height + nMemoHeight,
 m_width - 34, (m_buttonHeight + 1) * ortherButtons.size() + 1));
 }

 if (ortherButtons.size() > 0)
 {
 for (unsigned int i = 0; i < ortherButtons.size(); i++)
 {
 std::string btnTitle = ortherButtons.at(i);

 NDUIButton* btn = new NDUIButton();
 btn->Initialization();
 btn->SetFocusColor(ccc4(253, 253, 253, 255));
 btn->SetTitle(btnTitle.c_str());

 section->AddCell(btn);
 }
 }

 if (cancleButton && strlen(cancleButton) != 0)
 {
 m_leaveButtonExists = true;

 NDUIButton* btn = new NDUIButton();
 btn->Initialization();
 btn->SetFocusColor(ccc4(253, 253, 253, 255));
 btn->SetTitle(cancleButton);

 section->AddCell(btn);
 CGRect rect = m_table->GetFrameRect();
 m_table->SetFrameRect(CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, m_buttonHeight + 2 + rect.size.height));
 }

 if (section->Count() > 0)
 {
 section->SetFocusOnCell(0);
 }

 if ((!cancleButton || strlen(cancleButton) == 0) && ortherButtons.size() == 0)
 {
 m_autoRemove = true;
 }

 CGSize frameSize = CGSizeMake(m_width, m_label->GetFrameRect().size.height + nMemoHeight + m_table->GetFrameRect().size.height + 30);
 if (m_autoRemove)
 {
 frameSize = CGSizeMake(m_width, m_label->GetFrameRect().size.height + nMemoHeight + 15);
 }

 CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
 this->SetFrameRect(CGRectMake((winSize.width - frameSize.width) / 2,
 (winSize.height - frameSize.height) / 2,
 frameSize.width, frameSize.height));

 NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
 if (scene)
 {
 scene->AddChild(this, UIDIALOG_Z);

 NDUIDialogDelegate* delegate = dynamic_cast<NDUIDialogDelegate*> (this->GetDelegate());
 if (delegate)
 {
 delegate->OnDialogShow(this);
 }
 }
 }

 void NDUIDialog::Show(const char* title, const char* text, const char* cancleButton, const char* ortherButtons,...)
 {
 va_list argumentList;
 char *eachObject;
 std::vector<std::string> btns;

 if (ortherButtons)
 {
 btns.push_back(std::string(ortherButtons));
 va_start(argumentList, ortherButtons);
 while ((eachObject = va_arg(argumentList, char*)))
 {
 btns.push_back(std::string(eachObject));
 }
 va_end(argumentList);
 }

 this->Show(title, text, cancleButton, btns);

 }

 void NDUIDialog::Show(const char* title, const char* text, const char* cancleButton, const std::vector<std::string>& ortherButtons, const std::vector<bool> vec_arrow)
 {
 if (this->GetParent() || ortherButtons.size() != vec_arrow.size())
 {
 return;
 }

 m_leaveButtonExists = false;
 m_autoRemove = false;

 if (title && strlen(title) > 0)
 {
 m_label->SetText(title);
 m_label->SetFrameRect(CGRectMake(TEXT_START_WIDTH, 5, m_width - TEXT_START_WIDTH*2, m_titleHeight));
 }
 else
 {
 m_label->SetText("");
 m_label->SetFrameRect(CGRectMake(TEXT_START_WIDTH, 5, 0, 0));
 }

 CGRect tb = m_table->GetFrameRect();

 std::string mmText;
 if (text && strlen(text) > 0)
 {
 mmText = text;
 }
 else
 {
 mmText = "";
 }

 if (mmText.size() > 0) {
 CGSize textSize;
 textSize.width = m_width - TEXT_START_WIDTH*2;
 textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(text, textSize.width, 13);

 float txtHeight = m_contextHeight < textSize.height ? m_contextHeight : textSize.height;
 m_memo = NDUITextBuilder::DefaultBuilder()->Build(mmText.c_str(),
 13,
 CGSizeMake(m_width - TEXT_START_WIDTH*2, txtHeight),
 ccc4(255, 255, 255, 255),
 true);
 m_memo->SetFrameRect(CGRectMake(TEXT_START_WIDTH-2, 10 + m_label->GetFrameRect().size.height, m_width - TEXT_START_WIDTH*2+4, txtHeight + 10));
 this->AddChild(m_memo);
 }

 NDDataSource* dataSource = new NDDataSource();
 NDSection* section = new NDSection();
 section->SetRowHeight(m_buttonHeight);
 dataSource->AddSection(section);
 m_table->SetDataSource(dataSource);
 int nMemoHeight = m_memo == NULL ? 0 : m_memo->GetFrameRect().size.height;
 m_table->SetFrameRect(CGRectMake(17, 15 + m_label->GetFrameRect().size.height + nMemoHeight,
 m_width - 34, 0));
 if (ortherButtons.size() > 0)
 {
 m_table->SetFrameRect(CGRectMake(17, 15 + m_label->GetFrameRect().size.height + nMemoHeight,
 m_width - 34, (m_buttonHeight + 1) * ortherButtons.size() + 1));
 }

 if (ortherButtons.size() > 0)
 {
 for (unsigned int i = 0; i < ortherButtons.size(); i++)
 {
 std::string btnTitle = ortherButtons.at(i);

 NDUIButton* btn = new NDUIButton();
 btn->Initialization();
 btn->SetFocusColor(ccc4(253, 253, 253, 255));
 btn->SetTitle(btnTitle.c_str());
 btn->SetArrow(vec_arrow[i]);
 section->AddCell(btn);
 }
 }

 if (cancleButton && strlen(cancleButton) != 0)
 {
 m_leaveButtonExists = true;

 NDUIButton* btn = new NDUIButton();
 btn->Initialization();
 btn->SetFocusColor(ccc4(253, 253, 253, 255));
 btn->SetTitle(cancleButton);

 section->AddCell(btn);
 CGRect rect = m_table->GetFrameRect();
 m_table->SetFrameRect(CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, m_buttonHeight + 2 + rect.size.height));
 }

 if (section->Count() > 0)
 {
 section->SetFocusOnCell(0);
 }

 if ((!cancleButton || strlen(cancleButton) == 0) && ortherButtons.size() == 0)
 {
 m_autoRemove = true;
 }

 CGSize frameSize = CGSizeMake(m_width, m_label->GetFrameRect().size.height + nMemoHeight + m_table->GetFrameRect().size.height + 30);
 if (m_autoRemove)
 {
 frameSize = CGSizeMake(m_width, m_label->GetFrameRect().size.height + nMemoHeight + 15);
 }

 CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
 this->SetFrameRect(CGRectMake((winSize.width - frameSize.width) / 2,
 (winSize.height - frameSize.height) / 2,
 frameSize.width, frameSize.height));

 NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
 if (scene)
 {
 scene->AddChild(this, UIDIALOG_Z);

 NDUIDialogDelegate* delegate = dynamic_cast<NDUIDialogDelegate*> (this->GetDelegate());
 if (delegate)
 {
 delegate->OnDialogShow(this);
 }
 }
 }

 bool NDUIDialog::DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch)
 {
 bool result = NDUILayer::DispatchTouchEndEvent(beginTouch, endTouch);
 //if (!result)
 //		{
 //			if ((m_memo->GetCurrentPageNum() == 1 && m_memo->GetLastPageNum() == m_memo->GetTotalPageCount())
 //				|| (m_memo->GetCurrentPageNum() == m_memo->GetTotalPageCount() && m_memo->GetLastPageNum() == 1)
 //				|| (m_memo->GetCurrentPageNum() == m_memo->GetLastPageNum()))
 //			{
 //				CGRect mmScrRect = m_memo->GetScreenRect();
 //				if (CGRectContainsPoint(mmScrRect, endTouch) && CGRectContainsPoint(mmScrRect, beginTouch) && m_autoRemove)
 //				{
 //					this->Close();
 //					result = true;
 //				}
 //			}
 //		}
 return result;

 }

 bool NDUIDialog::TouchBegin(NDTouch* touch)
 {
 if ( !(this->IsVisibled() && this->EventEnabled()) )
 {
 return false;
 }

 m_beginTouch = touch->GetLocation();

 int iCellCount = 0;
 if (m_table && m_table->GetDataSource() && m_table->GetDataSource()->Section(0))
 {
 iCellCount = m_table->GetDataSource()->Section(0)->Count();
 }

 if (iCellCount < 1)
 {
 if ( !m_memo
 || m_memo->GetCurrentPageIndex() == m_memo->GetPageCount()
 || m_memo->GetPageCount() == 1 )
 {
 this->Close();
 return true;
 }
 }

 m_bTouchBegin = CGRectContainsPoint(this->GetScreenRect(), m_beginTouch);

 return true;
 }

 bool NDUIDialog::TouchEnd(NDTouch* touch)
 {
 m_endTouch = touch->GetLocation();

 if (CGRectContainsPoint(this->GetScreenRect(), m_endTouch) && this->IsVisibled() && this->EventEnabled() && m_bTouchBegin)
 {
 this->DispatchTouchEndEvent(m_beginTouch, m_endTouch);
 }

 m_bTouchBegin = false;

 return true;
 }

 void NDUIDialog::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
 {
 if (cellIndex == section->Count()-1)
 {
 if (m_leaveButtonExists)
 {
 this->Close();
 return;
 }
 }

 NDUIDialogDelegate* delegate = dynamic_cast<NDUIDialogDelegate*> (this->GetDelegate());
 if (delegate)
 {
 delegate->OnDialogButtonClick(this, cellIndex);
 }

 }

 void NDUIDialog::SetWidth(unsigned int width)
 {
 m_width = width;
 }

 void NDUIDialog::SetTitleHeight(unsigned int height)
 {
 m_titleHeight = height;
 }

 void NDUIDialog::SetContextHeight(unsigned int height)
 {
 m_contextHeight = height;
 }

 void NDUIDialog::SetButtonHeight(unsigned int height)
 {
 m_buttonHeight = height;
 }

 void NDUIDialog::Close()
 {
 NDUIDialogDelegate* delegate = dynamic_cast<NDUIDialogDelegate*> (this->GetDelegate());
 if (delegate)
 {
 delegate->OnDialogClose(this);
 }

 if (this->GetParent())
 {
 this->RemoveFromParent(true);
 }
 }

 std::string NDUIDialog::GetTitle()
 {
 std::string result;
 if (m_label)
 {
 result = m_label->GetText();
 }
 return result;
 }

 void NDUIDialogDelegate::OnDialogShow(NDUIDialog* dialog)
 {
 }

 void NDUIDialogDelegate::OnDialogClose(NDUIDialog* dialog)
 {
 }

 void NDUIDialogDelegate::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
 {
 }
 */
}
