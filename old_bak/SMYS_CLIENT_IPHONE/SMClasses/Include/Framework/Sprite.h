/**
精灵类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#ifndef __SPRITE_H__
#define __SPRITE_H__

#include "IAniObj.h"
#include "CGeometry.h"
#include "cTypes.h"
#include "IActionDelegate.h"
#include "FrameworkTypes.h"

typedef enum
{
    ProgressLR,//从左到右
    ProgressRL,//从右到左
    ProgressTB,//从上到下
    ProgressBT,//从下到上
} ProgressType;//进度动作显示出精灵来的方法

struct sImageList
{
    CRect rect;//每帧图片所在整张图片的位置大小
    IImageObj* m_Obj;//图片的来源
};

//显示提示消息
void showTip(const char* lpszTip,unsigned long nColor=0x00ff00/*绿色*/,BOOL bMuliLine=FALSE/*忽略该参数*/,int iFontSize=18/*字体大小*/, const char* lpSpriteName="com_txttipsbg"/*背景图片*/, const char* pszFile="./ani/ui.ani"/*背景ani文件*/,float fSacleX=2/*图片X坐标缩放*/,float fSacleY=1.f/*图片Y坐标缩放*/,float fWaitTime=3.0f/*等待时间*/,int iUpSize=-50/*上升的距离*/,float fUpTime=.6f/*上升需要时间*/,int xPos=-1/*x坐标,默认-1则居中*/,int yPos=100/*y坐标*/,int iRemoveOhters=1/*是否清除其他提示消息*/,RENDER_TEXT_STYLE iRendeTextStyle=RENDER_TEXT_SILHOUETTE/*文字风格*/);

//删除所有提示消息
void removeAllTips();

class CAction;
class CSprite :public IActionDelegate
{
public:
    CSprite(void);
    virtual ~CSprite(void);
public:
    //多帧动画载入
    void InitSprite(const char* lpSpriteName/*ani的[KEY]*/, const char* pszFile="./ani/common.ani");
   
	//初始化精灵,只有一帧
	void InitSprite( const char* lpSpriteName/*ani的[KEY]*/,CRect rect/*第一帧的大小,第二帧要再调用AddFrameWithRect增加后续的帧动画*/,const char* pszFile="./ani/common.ani");
  
	void InitSprite( const char* lpSpriteName/*ani的[KEY]*/,CRect rectAll/*总图片大小*/,int iRow/*行*/,int iCol/*列*/,int iCount/*总图片数*/,const char* pszFile="./ani/common.ani");

    //显示精灵
    virtual bool Show(bool bShowRelative = false);

    //暂时没用(设置动画的每帧动画间隔时间的再次延长时间,默认为0)
    void SetDelay(float fDelay);

    // 增加一帧或多帧的ani [KEY](ani只支持一次最多加载64帧的图片,用此函数加载多次到精灵中)
    void AddFrameWithFileName(const char *pszFileName/*ani的[KEY]*/,char* pszFile=NULL);

	//在原大图片上,增加某区域的一帧动画;若原来已有好几个图片文件的帧动画,增加的按第一个图片大小
    void AddFrameWithRect(CRect rect/*区域*/);

	//设置帧范围大小(总帧数若多于已有的图片帧数,会自动设成最大允许图片帧数)
	void SetFrameRangeSize(int iStartFrameIndex/*开始帧号*/,int iFrameSize/*总帧数,最小一帧*/);
	
	//设置帧范围(总帧数若多于已有的图片帧数,会自动设成最大允许图片帧数)
	void SetFrameRange(int iStartFrameIndex/*开始帧号*/,int iEndFrameIndex/*结束帧号*/);

	//获得动画的图片数量
    int GetImagesSize();

	//获取动画初始化后的图片的总帧数
	int GetFrameSize();

	//获取动画的播放的总帧数
	int GetPlayFrameSize();

	//获得第一帧的位置
	int GetFrameMinIndex();
	
	//设置动画的帧号
	void SetImageNum(int iFrameIndex);

	//获取某一帧动画
    IImageObj* GetFrameImage(int iFrameIndex);

	//获取缩放比率(范围:0.f-无限大)
    float GetScale();

    //设置放大缩小比例(相对最初始的大小)
    void SetScale(float scale);

	//设置放大缩小比例(相对最初始的大小)
	void SetScale(float scaleX/*X轴的缩放比率*/,float scaleY/*Y轴的缩放比率*/);

    //设置精灵中心点的坐标,如setCenterPosition(CPoint(CMyBitmap::GetScreenWidth()/2,100));
    void SetCenterPosition(CPoint& pos);

    //X坐标翻转(图片左右翻转)
	void SetFlipX(bool bFlipX=true/*是否图片左右翻转*/);
	
    //Y坐标翻转(图片上下翻转)
	void SetFlipY(bool bFlipY=true/*是否图片上下翻转*/);

	//X坐标是否翻转
    bool IsFlipX(void);

	//Y坐标是否翻转
    bool IsFlipY(void);

    //获得精灵实际显示的宽度
    int GetShowWidth();

    //获得精灵实际显示的高度
    int GetShowHeight();

    //获得精灵载入图片的宽度
    int GetWidth();

    //获得精灵载入图片的高度
    int GetHeight();

    //设置要从左到右,还是从上到下显示精灵
    void SetProgressType(ProgressType type);

	//设置进度值
    void SetPercentage(float fPercentage);

    //获取进度值( 范围: 0 - 100)
    float GetPercentage(void);

	virtual float GetRotation();
	virtual void SetRotation(float rotation);

	virtual float GetScaleX();
	virtual void SetScaleX(float scaleX);

	virtual const CPoint& GetPosition(void);
	virtual void SetPosition(const CPoint& var);

#if 0
	//增加子精灵
	virtual void AddChild(CSprite* pSprChild);

	/** Adds a child to the container with a z-order
	If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
	*/
	virtual void AddChild(CSprite * pSprChild, int zOrder);

	/** Adds a child to the container with z order and tag
	If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
	*/
	virtual void AddChild(CSprite * pSprChild, int zOrder, int tag);

	//获取父精灵
	CSprite* GetParent();

	//设置父精灵
	void SetParent(CSprite* pSpriteChild);

	//void SetTouchEnable(BOOL bTouch=TRUE);

	//BOOL IsTouchEnable();

	//获取标签
	virtual int GetTag(void);

	//设置标签
	virtual void SetTag(int iTag);

	
#endif

	//增加一个动作(GetActionManager()->AddAction(action, this))
	CAction * RunAction(CAction* action);

	//停止该精灵的所有动作(GetActionManager()->RemoveAllActionsFromTarget(this);)
	void StopAllActions();

	float m_fDelay;

	//精灵的载入名字
	string m_strSpriteName;

protected:
	virtual bool IsAutoRelease();
	virtual void SetAutoRelease(bool bAutoRelease);

#if 0
	CSprite* m_pParent;
	BOOL m_bTouchEnable;
	typedef vector<CSprite*> VEC_SPRITE;
	VEC_SPRITE m_vecChild;
#endif

	int m_iFrameMin;//开始帧
	int m_iFrameSize;//图片总帧数
	int m_iPlayFrameSize;//播放的总帧数

	
    float m_fRotation; //旋转角度
   
	int m_iImageNum;//精灵动画的第几张图片	
    vector<sImageList> m_vImages;//图片列表
    char m_czAniFile[256];//默认的ani路径

    
    CPoint m_tPosition; //坐标位置(AnchorPoint锚点在精灵左上角)
    ProgressType m_eProgressType;//如何显示出精灵(从上到下/从左到右)

	int m_iWidth;//精灵图片的宽度
    int m_iHeight;//精灵图片的高度

    float	m_fPercentage;
    bool	m_bAutoRelease;

    bool m_bFlipX;//X坐标翻转
    bool m_bFlipY;//Y坐标翻转
   
#if 0
	int m_iTag;//精灵的标签(默认-1)
#endif

    float m_fScaleX; //X坐标缩放

	//Y坐标缩放
    PROPERTY(float, m_fScaleY, ScaleY)

    /** Whether of not the node is visible. Default is true */
    PROPERTY(bool, m_bIsVisible, IsVisible)

    /** Opacity: conforms to CCRGBAProtocol protocol */
	//透明度
    PROPERTY(int, m_nOpacity, Opacity)

    /** Color: conforms with CCRGBAProtocol protocol */
	//颜色
    PROPERTY_PASS_BY_REF(Color3B, m_sColor, Color)

#if 0
	PROPERTY_PASS_BY_REF(CPoint, m_tAnchorPoint, AnchorPoint)

	/** The z order of the node relative to it's "brothers": children of the same parent */
	//默认0
	PROPERTY_READONLY(int, m_iZOrder, ZOrder)
private:
	void SetZOrder(int z);
#endif

};


/**
  初始化动画:
  方法一:有N张图片文件,保存在ani里,如"./ani/ui.ani"里是:
	  [MyTestSprite]
	  FrameAmount=1
	  Frame0=data/Test/grossini_dance_11.png

	  [MyTestSprite_s1]
	  FrameAmount=1
	  Frame0=data/Test/grossini_dance_12.png

	  [MyTestSprite_s2]
	  FrameAmount=1
	  Frame0=data/Test/grossini_dance_13.png

	  [MyTestSprite_s3]
	  FrameAmount=1
	  Frame0=data/Test/grossini_dance_14.png

	  可以这样初始化:
	  m_mySprite.InitSprite("MyTestSprite","./ani/ui.ani");
	  m_mySprite.AddFrameWithFileName("MyTestSprite_s1");
	  m_mySprite.AddFrameWithFileName("MyTestSprite_s2");
	  m_mySprite.AddFrameWithFileName("MyTestSprite_s3" );

  或ani文件是:
	  [Frames]
	  FrameAmount=4
	  Frame0=data/Test/Player.png
	  Frame1=data/Test/grossini_dance_12.png
	  Frame2=data/Test/grossini_dance_13.png
	  Frame3=data/Test/grossini_dance_14.png
	  初始化:
	  m_mySprite.InitSprite("Frames","./ani/ui.ani");



  方法二:
  一张大图,2行,4列,共6张小图,每个小图大小132*132
  CRect rc={0,0,132*4,132*2};
  m_mySprite3.InitSprite("MyTestSpriteDragon",rc,2,4,6);

  方法三:
  初始化InitSprite时定义第一帧的小图大小,再AddFrameWithRect每一小图的位置大小
  #define MakeRect(x,y,w,h) 	memset(&rc,0,sizeof(rc));rc.top=y;rc.left=x;rc.right=x+w;rc.bottom=y+h;
  CRect rc;
  MakeRect(132*0, 132*0, 132, 132);
  m_mySprite3.InitSprite("MyTestSpriteDragon",rc);

  MakeRect(132*1, 132*0, 132, 132);
  m_mySprite3.AddFrameWithRect(rc);

  MakeRect(132*2, 132*0, 132, 132);
  m_mySprite3.AddFrameWithRect(rc);

  MakeRect(132*3, 132*0, 132, 132);
  m_mySprite3.AddFrameWithRect(rc);

  MakeRect(132*0, 132*1, 132, 132);
  m_mySprite3.AddFrameWithRect(rc);

  MakeRect(132*1, 132*1, 132, 132);
  m_mySprite3.AddFrameWithRect(rc);
**/

//class SpriteTipSet
//{
//	SpriteTipSet(unsigned long nColor=0x00ff00/*绿色*/,BOOL bMuliLine=FALSE/*是否换行*/,int iFontSize=18/*字体大小*/, const char* lpSpriteName="com_tipsbg"/*背景图片*/, const char* pszFile="./ani/ui.ani"/*背景ani文件*/,float fSacleX=2/*图片X坐标缩放*/,float fSacleY=1.f/*图片Y坐标缩放*/,float fWaitTime=3.0f/*等待时间*/,int iUpSize=-50/*上升的距离*/,float fUpTime=.6f/*上升需要时间*/,int xPos=-1/*x坐标,默认-1则居中*/,int yPos=100/*y坐标*/,int iRemoveOhters=1/*是否清除其他提示消息*/)
//	{
//		
//	}
//    void SetTip(unsigned long nColor=0x00ff00/*绿色*/,BOOL bMuliLine=FALSE/*是否换行*/,int iFontSize=18/*字体大小*/, const char* lpSpriteName="com_tipsbg"/*背景图片*/, const char* pszFile="./ani/ui.ani"/*背景ani文件*/,float fSacleX=2/*图片X坐标缩放*/,float fSacleY=1.f/*图片Y坐标缩放*/,float fWaitTime=3.0f/*等待时间*/,int iUpSize=-50/*上升的距离*/,float fUpTime=.6f/*上升需要时间*/,int xPos=-1/*x坐标,默认-1则居中*/,int yPos=100/*y坐标*/,int iRemoveOhters=1/*是否清除其他提示消息*/);
//    {
//        m_nColor=						nColor;
//        m_bMuliLine=							 bMuliLine;
//        m_iFontSize=							 iFontSize;
//        m_lpSpriteName=						 lpSpriteName;
//        m_pszFile=							pszFile;
//        m_fSacleX=fSacleX;
//        m_fSacleY=							fSacleY;
//        m_fWaitTime=							fWaitTime;
//        m_iUpSize=							iUpSize;
//        m_fUpTime=							 fUpTime;
//        m_xPos=							xPos;
//        m_yPos=							yPos;
//        m_iRemoveOhters=							iRemoveOhters;
//    }
//
//    void Show(const char *lpText)
//    {
//        showTip(lpText,
//                m_nColor,
//                m_bMuliLine,
//                m_iFontSize,
//                m_lpSpriteName,
//                m_pszFile,
//                m_fSacleX,
//                m_fSacleY,
//                m_fWaitTime,
//                m_iUpSize,
//                m_fUpTime,
//                m_xPos,
//                m_yPos,
//                m_iRemoveOhters);
//    }
//
//protected:
//    unsigned long m_nColor;
//    BOOL m_bMuliLine;
//    int m_iFontSize;
//    const char* m_lpSpriteName;
//    const char* m_pszFile;
//    float m_fSacleX;
//    float m_fSacleY;
//    float m_fWaitTime;
//    int m_iUpSize;
//    float m_fUpTime;
//    int m_xPos;
//    int m_yPos;
//    int m_iRemoveOhters;
//};

#endif //__SPRITE_H__