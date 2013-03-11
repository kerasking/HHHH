/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

//#define COCOS2D_DEBUG 1

#define __CC_PLATFORM_IMAGE_CPP__
#include "platform/CCImageCommon_cpp.h"
#include "platform/CCPlatformMacros.h"
#include "platform/CCImage.h"
#include "jni/JniHelper.h"

#include <android/log.h>
#include <string.h>
#include <jni.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)

#if ND_MOD
#include "ccMacros.h"
#include "CCDirector.h"
#endif

NS_CC_BEGIN

//--------------------------------------------------------------------------------------------------<<
#if ND_MOD

static bool gs_bIsSystemFont = false;
static int  gs_isVerOlder = -1;

struct FONT_UTIL
{
	static bool isVerOlder()
	{
        if(gs_isVerOlder == -1)
        {
            JniMethodInfo t;
            if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
                                               "isVerOlder",
                                               "(I)I"))
            {
                jint isOldVer = (jint) t.env->CallStaticObjectMethod(t.classID, t.methodID);
                t.env->DeleteLocalRef(t.classID);
                gs_isVerOlder = isOldVer;
            }
        }
        return (gs_isVerOlder == 1);
	}

	static bool isPureAscii( const string& text )
	{
		if (text.length() == 0) return true;
		const char* p = text.c_str();
		while (*p != 0)
		{
			const char c = *p++;
			if ((c >= '0' && c <= '9') || 
				(c >= 'a' && c <= 'z') || 
				(c >= 'A' && c <= 'Z') ||
				(c == '%' || c == '/' || c == ':' 
					|| c == '+' || c == '-' 
					|| c == '[' || c == ']' 
					|| c == '(' || c == ')'
				))
				continue;
			else
				return false;
		}
		return true;
	}

	//对应低版本的android系统（主版本号为2），若字符串为纯数字或纯字母，则强制使用Arial字体.
	static const char* changeFontName( const char* fontName, const jstring& jstrText )
	{	
		static const char arialFontName[] = "Arial-BoldMT";

		if (isVerOlder() || gs_bIsSystemFont)
		{
			//LOGD("gs_bIsSystemFont is %s",gs_bIsSystemFont ? "true" : "false");
			string text = JniHelper::jstring2string( jstrText );

			if (isPureAscii(text))
			{
				return arialFontName;
			}
		}

		return fontName;
	}
};
#endif //ND_MOD
//-------------------------------------------------------------------------------------------------->>

class BitmapDC
{
public:
    BitmapDC()
    : m_pData(NULL)
    , m_nWidth(0)
    , m_nHeight(0)
    {
    }

    ~BitmapDC(void)
    {
        if (m_pData)
        {
            delete [] m_pData;
			m_pData = NULL; //ND_MOD
        }
    }

    bool getBitmapFromJava(const char *text, int nWidth, int nHeight, CCImage::ETextAlign eAlignMask, const char * pFontName, float fontSize)
    {
        JniMethodInfo methodInfo;
        if (! JniHelper::getStaticMethodInfo(methodInfo, "org/cocos2dx/lib/Cocos2dxBitmap", "createTextBitmap", 
            "(Ljava/lang/String;Ljava/lang/String;IIII)V"))
        {
            CCLOG("%s %d: error to get methodInfo", __FILE__, __LINE__);
            return false;
        }
        //fontSize*= 2;//CC_CONTENT_SCALE_FACTOR();//临时解决,Android支持高清

        /**create bitmap
         * this method call Cococs2dx.createBitmap()(java code) to create the bitmap, the java code
         * will call Java_org_cocos2dx_lib_Cocos2dxBitmap_nativeInitBitmapDC() to init the width, height
         * and data.
         * use this approach to decrease the jni call number
        */
        jstring jstrText = methodInfo.env->NewStringUTF(text);

#if ND_MOD
		if (gs_bIsSystemFont)
		{
			pFontName = "xxxxxxxxxx";
		}
		else
		{
			//@ndbitmap
			//说明：若使用NDBitmap机制则不需要改变字体：使用同一种字体，原先低端机的字符间距问题通过修正解决，详见NDSpecialCharWidth.java
			//		若未使用NDBitmap机制，则沿用原来改字体的方式解决字符宽度问题.
			const int WITH_NDBITMAP = 0;
			if (!WITH_NDBITMAP)
			{
				pFontName = FONT_UTIL::changeFontName( pFontName, jstrText );
			}
		}
#endif

        jstring jstrFont = methodInfo.env->NewStringUTF(pFontName);

        methodInfo.env->CallStaticVoidMethod(methodInfo.classID, methodInfo.methodID, jstrText,
            jstrFont, (int)fontSize, eAlignMask, nWidth, nHeight);

        methodInfo.env->DeleteLocalRef(jstrText);
        methodInfo.env->DeleteLocalRef(jstrFont);
        methodInfo.env->DeleteLocalRef(methodInfo.classID);

        return true;
    }

    // ARGB -> RGBA
    unsigned int swapAlpha(unsigned int value)
    {
        return ((value << 8 & 0xffffff00) | (value >> 24 & 0x000000ff));
    }

public:
    int m_nWidth;
    int m_nHeight;
    unsigned char *m_pData;
    JNIEnv *env;
};

static BitmapDC& sharedBitmapDC()
{
    static BitmapDC s_BmpDC;
    return s_BmpDC;
}

bool CCImage::initWithString(
                               const char *    pText, 
                               int             nWidth/* = 0*/, 
                               int             nHeight/* = 0*/,
                               ETextAlign      eAlignMask/* = kAlignCenter*/,
                               const char *    pFontName/* = nil*/,
                               int             nSize/* = 0*/)
{
    bool bRet = false;

    do 
    {
        CC_BREAK_IF(! pText);
        
        BitmapDC &dc = sharedBitmapDC();

        CC_BREAK_IF(! dc.getBitmapFromJava(pText, nWidth, nHeight, eAlignMask, pFontName, nSize));

        // assign the dc.m_pData to m_pData in order to save time
        m_pData = dc.m_pData;
        CC_BREAK_IF(! m_pData);

        m_nWidth    = (short)dc.m_nWidth;
        m_nHeight   = (short)dc.m_nHeight;
        m_bHasAlpha = true;
        m_bPreMulti = true;
        m_nBitsPerComponent = 8;

        bRet = true;
    } while (0);

    return bRet;  
}

#if ND_MOD
bool CCImage::getStringSize( const char *    in_utf8,
                            ETextAlign      eAlignMask,
                            const char *    pFontName,
                            int             nSize,
                            int&			outSizeWidth,
                            int&			outSizeHeight)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t
                                       
                                       , "org/cocos2dx/lib/Cocos2dxBitmap"
                                       
                                       , "getStringSize"
                                       
                                       , "(Ljava/lang/String;Ljava/lang/String;II)Ljava/lang/String;"))
        
    {
        jstring stringArg1 = t.env->NewStringUTF(in_utf8);

#if ND_MOD
		if (gs_bIsSystemFont)
		{
			pFontName = "xxxxxxxxxx";
		}
		else
		{
			pFontName = FONT_UTIL::changeFontName( pFontName, stringArg1 );
		}
#endif

        jstring stringArg2 = t.env->NewStringUTF(pFontName);
        
        jstring ret = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID, stringArg1,stringArg2,nSize,eAlignMask);
        sscanf(JniHelper::jstring2string(ret).c_str(), "%d %d", &outSizeWidth, &outSizeHeight);
        
        //outSizeHeight = (int)ret/10000;
        //outSizeWidth =  (int)ret-outSizeHeight*10000;
        t.env->DeleteLocalRef(stringArg1);
        t.env->DeleteLocalRef(stringArg2);
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(ret);
    }
}

void CCImage::changeSystemFont( bool bSystemFont )
{
	LOGD("Set bSystemFont");
	CCLog("ndbmp", "@@ CCImage::changeSystemFont(), bSystemFont=%d\r\n", (int)bSystemFont);
	gs_bIsSystemFont = bSystemFont;
}

#endif

NS_CC_END

// this method is called by Cocos2dxBitmap
extern "C"
{
    /**
    * this method is called by java code to init width, height and pixels data
    */
    void Java_org_cocos2dx_lib_Cocos2dxBitmap_nativeInitBitmapDC(JNIEnv*  env, jobject thiz, int width, int height, jbyteArray pixels)
    {
//#if ND_MOD
// 		unsigned char*& pData = cocos2d::sharedBitmapDC().m_pData;
// 		CC_SAFE_DELETE_ARRAY( pData );
//#endif

        int size = width * height * 4;
        cocos2d::sharedBitmapDC().m_nWidth = width;
        cocos2d::sharedBitmapDC().m_nHeight = height;
        cocos2d::sharedBitmapDC().m_pData = new unsigned char[size];
        env->GetByteArrayRegion(pixels, 0, size, (jbyte*)cocos2d::sharedBitmapDC().m_pData);

        // swap data
        unsigned int *tempPtr = (unsigned int*)cocos2d::sharedBitmapDC().m_pData;
        unsigned int tempdata = 0;
        for (int i = 0; i < height; ++i)
        {
            for (int j = 0; j < width; ++j)
            {
                tempdata = *tempPtr;
                *tempPtr++ = cocos2d::sharedBitmapDC().swapAlpha(tempdata);
            }
        }
    }
};
