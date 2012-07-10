//
//  NDPicture.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//	－－介绍－－
//	NDPicture是专门针对本地图片的操作
//	如果需要共享图片资源可以通过NDPicturePool获取NDPicture对象

#ifndef __NDPicture_H
#define __NDPicture_H

#include "NDObject.h"
#include "NDDictionary.h"
#include "define.h"

#import "CCTexture2D.h"
#import "ccTypes.h"



namespace NDEngine
{
	typedef enum{
		PictureRotation0,
		PictureRotation90,
		PictureRotation180,
		PictureRotation270
	}PictureRotation;
	
	class NDPicture : public NDObject
	{
		DECLARE_CLASS(NDPicture)
		NDPicture(bool canGray=false);
		~NDPicture();
	public:
//		
//		函数：Initialization
//		作用：初始化图片资源
//		参数：imageFile本地图片资源
//		返回值：无
		void Initialization(const char* imageFile); hide
		
		// 将多张图片融合成1张, 大小以第一张为准
		void Initialization(vector<const char*>& vImgFiles); hide
		
		// 将多张图片融合成1张, 大小以第一张为准 null end
		void Initialization(vector<const char*>& vImgFiles, vector<CGRect>& vImgCustomRect, vector<CGPoint>&vOffsetPoint); hide

//		
//		函数：Initialization
//		作用：初始化图片资源
//		参数：imageFile本地图片资源,hrizontalPixel水平方向中间被拉伸的像素个数,verticalPixel垂直方向中间被拉伸的像素个数, bAdvance是否是高精度图
//		返回值：无
		void Initialization(const char* imageFile, int hrizontalPixel, int verticalPixel=0); hide

//		
//		函数：Cut
//		作用：剪切资源图片的特定矩形区域
//		参数：rect剪切区域
//		返回值：无
		void Cut(CGRect rect);
//		
//		函数：SetReverse
//		作用：水平翻转图片
//		参数：reverse如果true则翻转，否则不翻转
//		返回值：无
		void SetReverse(bool reverse);
//		
//		函数：Rotation
//		作用：旋转图片
//		参数：rotation顺时针旋转角度
//		返回值：无
		void Rotation(PictureRotation rotation);
//		
//		函数：SetColor
//		作用：设置图片灰度
//		参数：color灰度颜色
//		返回值：无
		void SetColor(ccColor4B color);
//		
//		函数：DrawInRect
//		作用：将图片绘制于屏幕指定区域；该方法必须每帧都被调用
//		参数：rect绘制区域
//		返回值：无
		void DrawInRect(CGRect rect);
//		
//		函数：GetSize
//		作用：获取设置完后的图片的大小
//		参数：无
//		返回值：大小
		CGSize GetSize();
//		
//		函数：Copy
//		作用：拷贝一份设置
//		参数：无
//		返回值：本对象
		NDPicture* Copy();
		
		bool SetGrayState(bool gray);
		
		bool IsGrayState();
		
	public:	
		CCTexture2D *GetTexture();
		// 灰图功能的NDPicture禁用该接口
		void SetTexture(CCTexture2D* tex);
	private:
		CCTexture2D *m_texture;
		CGRect m_cutRect;
		bool m_reverse, m_bAdvance;
		PictureRotation m_rotation;
		
		// 变灰
		bool m_canGray;
		bool m_stateGray;
		CCTexture2D *m_textureGray;
		
		GLfloat m_coordinates[8];
		GLubyte m_colors[16];
		GLfloat m_vertices[8];
		
		std::string m_strfile;
		int m_hrizontalPixel;
		int m_verticalPixel;
		
		void SetCoorinates();
		void SetVertices(CGRect drawRect);
	};
	
	class NDPictureDictionary : public NDDictionary
	{
		DECLARE_CLASS(NDPictureDictionary)
		public:
			void Recyle();
	};
	
	class NDPicturePool : public NDObject
	{
		DECLARE_CLASS(NDPicturePool)
		NDPicturePool();
		~NDPicturePool();
	public:
//		
//		函数：DefaultPool
//		作用：单例静态方法，成员方法的访问请都通过该接口先。
//		参数：无
//		返回值：本对象指针
		static NDPicturePool* DefaultPool();
		
		static void PurgeDefaultPool();
//		
//		函数：AddPicture
//		作用：从图片池获取一张图片资源，注意：调用该方法需要外部清理返回的对象内存
//		参数：imageFile本地图片资源
//		返回值：NDPicture对象指针
		NDPicture* AddPicture(const char* imageFile, bool gray=false);	
		
//		
//		函数：AddPicture
//		作用：从图片池获取一张图片资源，注意：调用该方法需要外部清理返回的对象内存
//		参数：imageFile本地图片资源,其它参数见NDPicture初始化参数
//		返回值：NDPicture对象指针
		NDPicture* AddPicture(const char* imageFile, int hrizontalPixel, int verticalPixel=0, bool gray=false);
//		
//		函数：RemovePicture
//		作用：释放本地图片资源
//		参数：imageFile本地图片资源
//		返回值：无
		void RemovePicture(const char* imageFile);
		
		void Recyle();
		
	private:
		NDPictureDictionary *m_textures;
		
		std::map<std::string, CGSize> m_mapStr2Size;
		
	private:
		CGSize GetImageSize(std::string filename);
	};
}

#endif
