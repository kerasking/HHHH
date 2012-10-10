#pragma once
#include "IActionDelegate.h"
#include "IAniObj.h"
#include "CGeometry.h"
#include "cTypes.h"

class CDialog;

//代理动作类(使对话框可以使用动作)
class CActionDelegate:public IActionDelegate
{
public:
    CActionDelegate(CDialog *pObject);
    ~CActionDelegate(void);
    enum ACION_ACTOR_TYPE
    {
        // AAT_SPRITE=0,
		AAT_WNDOBJECT
		//AAT_WNDOBJECT
    };
public:

    //获取是否可见
    virtual bool GetIsVisible();

	//设置可见
    virtual void SetIsVisible(bool var);

    //获取位置
    virtual const CPoint& GetPosition();

    //设置位置
    virtual void SetPosition(const CPoint& newPosition);

	//是否自动释放
    virtual bool IsAutoRelease();

	//CCActionManager在动画播放完后，是否自动释放掉IActionDelegate对象。
    virtual void SetAutoRelease(bool bAutoRelease);

	//显示
    bool Show(bool bShowRelative);

	//设置X和Y坐标缩放值
    void SetScale(float scale);

	//设置X坐标缩放值
    void SetScaleX(float newScaleX);

	//获取Y坐标缩放值
    float GetScaleY();

	//设置Y坐标缩放值
    void SetScaleY(float newScaleY);

	//获取缩放值
    float GetScaleX();

	//获取透明度
    int  GetOpacity(void);

	//设置透明度
    void SetOpacity(int iOpacity);

	//获取颜色值
    const Color3B& GetColor(void);

	//设置颜色值
    void SetColor(const Color3B& color3);

	//获取旋转值
    float GetRotation();

	//设置旋转值
    void SetRotation(float newRotation);

    //Y坐标翻转
    void SetFlipY(bool bFlipY);

    //X坐标翻转
    void SetFlipX(bool bFlipX);

	//动画播放的总帧数
    int GetPlayFrameSize();

	//设置动画的帧号
    void SetImageNum(int i);

private:
    void *m_pObject;
    ACION_ACTOR_TYPE m_aaType;
    bool m_bAutoRelease;//是否自动释放

};
