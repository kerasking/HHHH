#ifndef _ND_COMMON_CONTROL_
#define _ND_COMMON_CONTROL_

#include "NDPicture.h"
#include "NDUILabel.h"
#include "NDUILayer.h"
#include "NDUIImage.h"
#include "ImageNumber.h"
#include "NDUIBaseGraphics.h"
#include "NDUIButton.h"
#include "NDUIOptionButton.h"
#include "NDLightEffect.h"
#include "ccTypes.h"

using namespace NDEngine;

class NDStateBar : public NDUINode
{
	DECLARE_CLASS(NDStateBar)
	
	NDStateBar();
	
	virtual ~NDStateBar();
	
public:
	
	void Initialization(bool useNumPic=true); override
	
	void SetStatePicture(NDPicture* picBg, NDPicture* picProcess);
	
	void SetNumber(int iCurNum, int iMaxNum);
	
	NDUILabel* GetNumLable();
	
	ImageNumber* GetNumImage();
	
private:
	
	void draw(); override
	
private:

	NDPicture *m_picBg, *m_picProcess;
	
	NDUILabel *m_lbLabel;
	
	ImageNumber *m_imageNum;
	
	float m_fPercent;
};

class NDHPStateBar : public NDStateBar
{
	DECLARE_CLASS(NDHPStateBar)
public:
	
	void Initialization(CGPoint pos); override
};


class NDMPStateBar : public NDHPStateBar
{
	DECLARE_CLASS(NDMPStateBar)
public:
	
	void Initialization(CGPoint pos); override
};

class NDExpStateBar : public NDHPStateBar
{
	DECLARE_CLASS(NDExpStateBar)
public:
	
	void Initialization(CGPoint pos); override
};

class NDPropAllocLayer : public NDUILayer
{
	DECLARE_CLASS(NDPropAllocLayer)
	NDPropAllocLayer();
public:
	void Initialization(CGRect rect); override
	void SetLayerFocus(bool focus);
	bool IsFocus() { return m_focus; }
private:
	void draw(); override
private:
	bool m_focus;
	NDPicture *m_picBGFocus;
	NDPicture *m_picFocus;
	NDPicture *m_pic;
};

class NDPropSlideBar;

class NDPropSlideBarDelegate
{
public:
	virtual void OnPropSlideBarChange(NDPropSlideBar* bar, int change) {}
};


class NDPropSlideBar :
public NDUILayer
{
	DECLARE_CLASS(NDPropSlideBar);
public:
	NDPropSlideBar();
	
	~NDPropSlideBar();
	
	void Initialization(CGRect rect, unsigned int slideWidth); hide
	
	void SetMax(unsigned int uiMax, bool update=false);
	
	void SetMin(unsigned int uiMin, bool update=true);
	
	void SetCur(unsigned int uiCur, bool update=true);
	
	unsigned int GetCur();
	
	unsigned int GetMin();
	
	unsigned int GetMax();
	
	bool TouchBegin(NDTouch* touch); override
	
	bool TouchEnd(NDTouch* touch); override
	 
	bool TouchMoved(NDTouch* touch); override
 
	void draw(); override
	
	// 不处理其它分发事件
	bool DispatchTouchBeginEvent(CGPoint beginTouch) { return false; } override
	bool DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch) { return false; } override
	bool DispatchLongTouchEvent(CGPoint beginTouch, CGPoint endTouch) { return false; } override
	bool DispatchDragOutEvent(CGPoint beginTouch, CGPoint moveTouch, bool longTouch=false) { return false; } override
	bool DispatchDragOutCompleteEvent(CGPoint beginTouch, CGPoint endTouch, bool longTouch=false) { return false; } override
	bool DispatchDragInEvent(NDUINode* dragOutNode, CGPoint beginTouch, CGPoint endTouch, bool longTouch, bool dealByDefault=false) { return false; } override
	bool DispatchLayerMoveEvent(CGPoint beginPoint, NDTouch *moveTouch) { return false; } override

protected:
	virtual void SetSlideBar(CGSize parent, unsigned int width);
	
protected:
	void UpdateMinValue();
	void UpdateCurValue();
	void UpdateProcess();
	bool CheckCanMove(CGPoint scrPos);
	bool CheckChange(float change);
	void MoveEvent(float change);
protected:
	NDUIImage* m_imageSlide, *m_imageSlideBg, *m_imageProcess;
	NDUILabel* m_lbText;
	
	CGRect m_scrTouchRect; bool m_caclTouchRect;
	unsigned int m_uiMax, m_uiMin, m_uiCur;
	float m_fProcessWidth, m_fCur, m_fMin;
	bool m_slideMove;
};

class NDSlideBar : public NDPropSlideBar , public NDUIButtonDelegate
{
	DECLARE_CLASS(NDSlideBar)
	
public:
	void Initialization(CGRect rect, unsigned int slideWidth, bool hasBtn=true, NDPicture* slidePicture=NULL); hide
	
	void OnButtonClick(NDUIButton* button); override
};

class NDPropCell : public NDUINode
{
	DECLARE_CLASS(NDPropCell)
	
	NDPropCell();
	
	~NDPropCell();

public:
	void Initialization(bool hasinfo, CGSize size=CGSizeMake(238, 23)); hide
	
	NDUILabel* GetKeyText();
	
	NDUILabel* GetValueText();
	
	void SetFocusTextColor(cocos2d::ccColor4B clr) {
		m_clrFocusText = clr;
	}
	
	void draw(); override
	
	void SetPicAfterKey(NDPicture* pic) {
		m_picAfterKey = pic;
	}
	
	void SetKeyLeftDistance(unsigned int dis) { m_uiKeyDis = dis; }
	void SetValueRightDistance(unsigned int dis) { m_uiValueDis = dis; }
	
	void SetFocusPicture(const char* pszPicPath);
	
protected:
	NDUILabel	*m_lbKey, *m_lbValue;
	NDPicture	*m_picBg, *m_picFocus, *m_picInfo, *m_picAfterKey;
	bool		m_hasInfo;
	cocos2d::ccColor4B	m_clrFocusText, m_clrNormalText;
	
	unsigned int m_uiKeyDis;
	unsigned int m_uiValueDis;
};

class HyperLinkButton : public NDUIButton
{
	DECLARE_CLASS(HyperLinkButton)
public:
	HyperLinkButton();
	~HyperLinkButton();
	
	void Initialization();
	
	void SetHyperText(const char* text);
	
	void draw(); override
	
private:
	NDUILabel* m_lbHyperText;
	NDUILine* m_lineBottom;
};

class CommonTextInput;

class CommonTextInputDelegate
{
	public:
		// 返回值 true:清空并且隐藏text false:忽略点击Ok操作
		virtual bool SetTextContent(CommonTextInput* input, const char* text);
};

class ContentTextFieldDelegate:
	public cocos2d::CCObject
{
public:

	ContentTextFieldDelegate(){}
	virtual ~ContentTextFieldDelegate(){}

protected:
private:
};
 

// @interface ContentTextFieldDelegate : NSObject <UITextFieldDelegate>
// {
// 	UITextField* tfChat;
// }
// 
// @property(nonatomic, retain) UITextField* tfChat;
// 
// @end

class CommonTextInput : 
public NDUINode,
public NDUIButtonDelegate
{
	DECLARE_CLASS(CommonTextInput)
	
	CommonTextInput();
	
	~CommonTextInput();
	
public:
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void ShowContentTextField(bool bShow, const char* text=NULL);
	
	void CloseContentInput();
	
	void SetVisible(bool visible);
private:
	ContentTextFieldDelegate *m_contentDelegate;
	bool m_bShowContentTextField;
	NDUIButton	*m_btnContentOk;
	NDUIImage	*m_imgContent;
	NDUILayer	*m_layerBtn;
};

class CommonOptionButton :
public NDUIOptionButton
{
	DECLARE_CLASS(CommonOptionButton)
	
	CommonOptionButton();
	
	~CommonOptionButton();
public:
	void Initialization(); override
	
	void SetBackgroudImage(NDPicture* picNormal, NDPicture* picSel);
	
	void SetArrowImage(NDPicture* picLeft, NDPicture* picRight);
	
	void SetArrowInterval(unsigned int leftInterval, unsigned int rightInterval);
	
	void draw(); override
	
	void SetTitleColor(cocos2d::ccColor4B color, cocos2d::ccColor4B colorfocus);
private:
	
	NDPicture* m_picBGNormal, *m_picBGSel, *m_picArrowLeft, *m_picArrowRight;
	
	unsigned int m_uiLeftInterval, m_uiRightInterval;
	
	cocos2d::ccColor4B m_colorTitle, m_colorTitleFocus;
};

class PaiHangCell : public NDPropCell
{
	DECLARE_CLASS(PaiHangCell)
	
	PaiHangCell();
	
	~PaiHangCell();

public:
	void Initialization(CGSize size=CGSizeMake(432, 23)); hide
		
	void SetOrder(unsigned int order);
private:
	NDUIButton *m_btnPaiHang;
};

/***
* @brief 非全屏对话框背景
*/
class NDCommonDlgBack :
public NDUILayer, 
public NDUIButtonDelegate
{
	DECLARE_CLASS(NDCommonDlgBack)
public:
	NDCommonDlgBack();
	~NDCommonDlgBack();
	
	void Initialization(bool yellow=true); override
	virtual void Close();
	void OnButtonClick(NDUIButton* button); override
	bool TouchBegin(NDTouch* touch); override
	void SetTitle(const char * text);
protected:
	NDPicture* GetBtnNormalPic(CGSize size);
	NDPicture* GetBtnClickPic(CGSize size);
protected:
	NDUIButton *m_btnClose;
	NDUILabel  *m_lbTitle;
	bool		m_bYellow;
};

/**
* @brief 通用精灵UI节点
*/
class NDUISpriteNode : public NDUINode
{
	DECLARE_CLASS(NDUISpriteNode)
	
public:
	NDUISpriteNode();
	
	~NDUISpriteNode();
	
	void Initialization(const char* sprfile); override
	
	void SetSpritePosition(CGPoint pos);
	
	void Show(bool show);
	
	void draw();
	
private:
	NDLightEffect	*m_sprite;
	CGSize			m_sizeRun;
	bool			m_bShow;
};

#endif // _ND_COMMON_CONTROL_