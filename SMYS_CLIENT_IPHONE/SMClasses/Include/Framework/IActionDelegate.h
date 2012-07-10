#ifndef _IACTIONDELEGATE_HH__
#define _IACTIONDELEGATE_HH__
#include "CGeometry.h"
#include "cTypes.h"
#include "Object.h"


//精灵类的抽象基类(所有精灵的基类都必须实现此类的所有接口,方可应用在动作类上)
class IActionDelegate:public CObject
{
public:

	 //显示
	 virtual bool Show(bool bShowRelative )=0;

     //Y坐标翻转
	 virtual void SetFlipY(bool bFlipY)=0;
    
	 //X坐标翻转
	 virtual void SetFlipX(bool bFlipX)=0;

	 //动画播放的总帧数
     virtual int GetPlayFrameSize()=0;

	//设置动画的帧号
	 virtual void SetImageNum(int i)=0;
	
	//设置X和Y坐标缩放值
	 virtual void SetScale(float scale)=0;

	//设置Y坐标缩放值
	 virtual void SetScaleX(float newScaleX)=0;

	 //获取Y坐标缩放值
	 virtual float GetScaleY()=0;

	 //设置Y坐标缩放值
	 virtual void SetScaleY(float newScaleY)=0;
	
	 //获取X坐标缩放值
	 virtual float GetScaleX()=0;

	//设置是否可见
	 virtual bool GetIsVisible()=0;

	 //设置是否可见
	 virtual void SetIsVisible(bool var)=0;

	//获取透明度
	 virtual int GetOpacity(void)=0;

	//设置透明度
	 virtual void SetOpacity(int opacity)=0;

	 //获取颜色值
	 virtual const Color3B& GetColor(void)=0;

	 //设置颜色值
	 virtual void SetColor(const Color3B& color3)=0;

	//获取旋转值
	 virtual float GetRotation()=0;

	 //设置旋转值
	 virtual void SetRotation(float newRotation)=0;

	//获取位置
	 virtual const CPoint& GetPosition()=0;

	//设置位置
	 virtual void SetPosition(const CPoint& newPosition)=0;

	 //CCActionManager在动画播放完后，如果是AutoRelease,则自动释放掉IActionDelegate对象。
	 virtual bool IsAutoRelease() = 0;

	 //CCActionManager在动画播放完后，是否自动释放掉IActionDelegate对象。
	 virtual void SetAutoRelease(bool bAutoRelease) = 0;

};
#endif //_IACTIONDELEGATE_HH__
