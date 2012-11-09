/*
 *  Utility.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-11.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __ND_UTILITY_H__
#define __ND_UTILITY_H__

#include "globaldef.h"
#include "NDDirector.h"

#define MAP_UNITSIZE (16 * ((int)(NDDirector::DefaultDirector()->GetScaleFactor())))
#define SCREEN_SCALE (NDDirector::DefaultDirector()->GetScaleFactor())

bool IsPointInside(CGPoint pt, CGRect rect);
int GetNumBits(int num);
bool VerifyUnsignedNum(const std::string strnum);
std::string getStringTime(long nSeconds);

std::string changeToChineseSign(std::string old);

void showDialog(const char* title, const char* content);
void showDialog(const char* content);

// opengl绘图函数；必须在draw方法里调用，否则将不会长久生效
// 画矩形
// void DrawRecttangle(CGRect rect, ccColor4B color);
// 画多边形
// void DrawPolygon(CGRect rect, ccColor4B color, GLuint lineWidth);
// 画线
// void DrawLine(CGPoint fromPoint, CGPoint toPoint, ccColor4B color, GLuint lineWidth);
// 画圆
// void DrawCircle(CGPoint center, float r, float a, int segs, ccColor4B color);
// 画边框
// void DrawFrame(int borderColor, int x, int y, int width, int height);
// 画三角形
// void DrawTriangle(CGPoint first, CGPoint second, CGPoint third, ccColor4B color);
// CGSize getStringSize(const char* pszStr, uint fontSize);
// 
// CGSize getStringSizeMutiLine(const char* pszStr, uint fontSize, CGSize contentSize = CGSizeMake(480, 320));

void quitGame(bool bTipNet = false);

// string getStringTime(long nSeconds);
// 
// std::string getNextMonthDay(long nSeconds);

// iType: 1->游戏介绍, 2->游戏操作
/*std::string cutBytesToString(NSInputStream* stream, int iType);*/

const char* GetCopyCacheData();
void CopyDataToCopyCache(const char* data);

enum
{
	STRPARAM = 1, UPDATEURL = 2,
};
std::string loadPackInfo(int param);

//获取软件版本号
std::string GetSoftVersion();
//获取系统固件版本
std::string GetIosVersion();
//获取渠道信息
std::string GetChannelInfo();
//获取更新地址
std::string GetUpdateUrl();

//bool IsSupportPrecisionPic();

std::string platformString();

void drawRectBar2(int x, int y, int color, int num1, int num2, int width);

CGRect getNewNumCut(unsigned int num, bool hightlight);

void ShowAlert(const char* pszAlert);

// 时间转换函数
typedef enum
{
	TIME_SECOND,
	TIME_MINUTE,
	TIME_HOUR,
	TIME_DAY,
	TIME_DAYTIME,
	TIME_STAMP,
} TIME_TYPE;

// long_time 以秒为单位
uint TimeConvert(TIME_TYPE type /*=TIME_MILLISECOND*/, time_t long_time);

// long_time 以秒为单位
std::string TimeConvertToStr(TIME_TYPE type, time_t long_time);

enum NDLANGUAGE
{
	NDLANGUAGE_None,
	NDLANGUAGE_SimplifiedChinese,				// 简体中文
	NDLANGUAGE_TraditionalChinese,			// 繁体中文
};

bool IsInSimplifiedChinese();

bool IsTraditionalChinese();

NDLANGUAGE GetLocalLanguage();

#endif

