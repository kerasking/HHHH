/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008      Apple Inc. All Rights Reserved.

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



/*
* Support for RGBA_4_4_4_4 and RGBA_5_5_5_1 was copied from:
* https://devforums.apple.com/message/37855#37855 by a1studmuffin
*/

#include "CCTexture2D.h"
#include "ccConfig.h"
#include "ccMacros.h"
#include "CCConfiguration.h"
#include "platform/platform.h"
#include "platform/CCImage.h"
#include "CCGL.h"
#include "support/ccUtils.h"
#include "platform/CCPlatformMacros.h"
#include "textures/CCTexturePVR.h"
#include "CCDirector.h"
#include "shaders/CCGLProgram.h"
#include "shaders/ccGLStateCache.h"
#include "shaders/CCShaderCache.h"

#if ND_MOD
#include "ObjectTracker.h"
#include "TextureList.h"
#endif

#if CC_ENABLE_CACHE_TEXTURE_DATA
    #include "CCTextureCache.h"
#endif

#if ND_MOD
	#include "png.h"
	#include "pnginfo.h"
	#include "pngstruct.h"

	#define int_p_NULL (int*)NULL
	#define PNG_BYTES_TO_CHECK 8
	#define png_infopp_NULL (png_infopp)NULL	

	#define alpha_composite(composite, fg, alpha, bg) {                     \
		unsigned short temp = ((unsigned short)(fg)*(unsigned short)(alpha) +                       \
		(unsigned short)(bg)*(unsigned short)(255 - (unsigned short)(alpha)) + (unsigned short)128);       \
		(composite) = (u_char)((temp + (temp >> 8)) >> 8);                   \
	}
#endif

#if ND_MOD
using namespace cocos2d;

void ConvertPalette(png_color *pSrc, CCTexture2D::RGBQUAD *pDst, int nCount, png_bytep transalpha) 
{
	for(int i = 0 ; i< nCount; i++)
	{

		if(transalpha) {
			pDst->rgbReserved = transalpha[i];
			//            pDst->rgbBlue = pSrc->blue & pDst->rgbReserved;
			//            pDst->rgbGreen = pSrc->green & pDst->rgbReserved;
			//            pDst->rgbRed =pSrc->red & pDst->rgbReserved;
		}
		else {
			//            pDst->rgbBlue = pSrc->blue;
			//            pDst->rgbGreen = pSrc->green;
			//            pDst->rgbRed = pSrc->red;
			pDst->rgbReserved = 255;
		}
		alpha_composite(pDst->rgbBlue, pSrc->blue, pDst->rgbReserved, 0);
		alpha_composite(pDst->rgbGreen, pSrc->green, pDst->rgbReserved, 0);
		alpha_composite(pDst->rgbRed, pSrc->red, pDst->rgbReserved, 0);
		pSrc++;
		pDst++;
	} 
}
#endif

NS_CC_BEGIN

//CLASS IMPLEMENTATIONS:

// If the image has alpha, you can create RGBA8 (32-bit) or RGBA4 (16-bit) or RGB5A1 (16-bit)
// Default is: RGBA8888 (32-bit textures)
static CCTexture2DPixelFormat g_defaultAlphaPixelFormat = kCCTexture2DPixelFormat_Default;

// By default PVR images are treated as if they don't have the alpha channel premultiplied
static bool PVRHaveAlphaPremultiplied_ = false;

CCTexture2D::CCTexture2D()
: m_uPixelsWide(0)
, m_uPixelsHigh(0)
, m_uName(0)
, m_fMaxS(0.0)
, m_fMaxT(0.0)
, m_bHasPremultipliedAlpha(false)
, m_bHasMipmaps(false)
, m_bPVRHaveAlphaPremultiplied(true)
, m_pShaderProgram(NULL)
#if ND_MOD
, m_pData(0)
, m_bKeepData(false)
, m_nContainerType(0)
, m_uiWidth(0), m_uiHeight(0)
#endif
{
#if ND_MOD
	INC_CCOBJ("CCTexture2D");
	TextureList::instance().add_tex(this);
#endif
}

CCTexture2D::~CCTexture2D()
{
#if ND_MOD
	DEC_CCOBJ("CCTexture2D");
	TextureList::instance().del_tex(this);
#endif

#if CC_ENABLE_CACHE_TEXTURE_DATA
    VolatileTexture::removeTexture(this);
#endif

    CCLOGINFO("cocos2d: deallocing CCTexture2D %u.", m_uName);
    CC_SAFE_RELEASE(m_pShaderProgram);

    if(m_uName)
    {
        ccGLDeleteTexture(m_uName);
    }
}

CCTexture2DPixelFormat CCTexture2D::getPixelFormat()
{
    return m_ePixelFormat;
}

unsigned int CCTexture2D::getPixelsWide()
{
    return m_uPixelsWide;
}

unsigned int CCTexture2D::getPixelsHigh()
{
    return m_uPixelsHigh;
}

GLuint CCTexture2D::getName()
{
    return m_uName;
}

CCSize CCTexture2D::getContentSize()
{

    CCSize ret;
    ret.width = m_tContentSize.width / CC_CONTENT_SCALE_FACTOR();
    ret.height = m_tContentSize.height / CC_CONTENT_SCALE_FACTOR();
    
    return ret;
}

const CCSize& CCTexture2D::getContentSizeInPixels()
{
    return m_tContentSize;
}

GLfloat CCTexture2D::getMaxS()
{
    return m_fMaxS;
}

void CCTexture2D::setMaxS(GLfloat maxS)
{
    m_fMaxS = maxS;
}

GLfloat CCTexture2D::getMaxT()
{
    return m_fMaxT;
}

void CCTexture2D::setMaxT(GLfloat maxT)
{
    m_fMaxT = maxT;
}

CCGLProgram* CCTexture2D::getShaderProgram(void)
{
    return m_pShaderProgram;
}

void CCTexture2D::setShaderProgram(CCGLProgram* pShaderProgram)
{
    CC_SAFE_RETAIN(pShaderProgram);
    CC_SAFE_RELEASE(m_pShaderProgram);
    m_pShaderProgram = pShaderProgram;
}

void CCTexture2D::releaseData(void *data)
{
    free(data);
}

void* CCTexture2D::keepData(void *data, unsigned int length)
{
    CC_UNUSED_PARAM(length);
    //The texture data mustn't be saved because it isn't a mutable texture.
    return data;
}

bool CCTexture2D::hasPremultipliedAlpha()
{
    return m_bHasPremultipliedAlpha;
}

bool CCTexture2D::initWithData(const void *data, CCTexture2DPixelFormat pixelFormat, unsigned int pixelsWide, unsigned int pixelsHigh, const CCSize& contentSize)
{
    // XXX: 32 bits or POT textures uses UNPACK of 4 (is this correct ??? )
    if( pixelFormat == kCCTexture2DPixelFormat_RGBA8888 || ( ccNextPOT(pixelsWide)==pixelsWide && ccNextPOT(pixelsHigh)==pixelsHigh) )
    {
        glPixelStorei(GL_UNPACK_ALIGNMENT,4);
    }
    else
    {
        glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    }

    glGenTextures(1, &m_uName);
    ccGLBindTexture2D(m_uName);

    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

    // Specify OpenGL texture image

    switch(pixelFormat)
    {
    case kCCTexture2DPixelFormat_RGBA8888:
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)pixelsWide, (GLsizei)pixelsHigh, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
        break;
    case kCCTexture2DPixelFormat_RGB888:
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei)pixelsWide, (GLsizei)pixelsHigh, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
        break;
    case kCCTexture2DPixelFormat_RGBA4444:
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)pixelsWide, (GLsizei)pixelsHigh, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
        break;
    case kCCTexture2DPixelFormat_RGB5A1:
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)pixelsWide, (GLsizei)pixelsHigh, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
        break;
    case kCCTexture2DPixelFormat_RGB565:
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei)pixelsWide, (GLsizei)pixelsHigh, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
        break;
    case kCCTexture2DPixelFormat_AI88:
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, (GLsizei)pixelsWide, (GLsizei)pixelsHigh, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data);
        break;
    case kCCTexture2DPixelFormat_A8:
        glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, (GLsizei)pixelsWide, (GLsizei)pixelsHigh, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
        break;
    case kCCTexture2DPixelFormat_I8:
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, (GLsizei)pixelsWide, (GLsizei)pixelsHigh, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
        break;
    default:
        CCAssert(0, "NSInternalInconsistencyException");

    }

    m_tContentSize = contentSize;
    m_uPixelsWide = pixelsWide;
    m_uPixelsHigh = pixelsHigh;
    m_ePixelFormat = pixelFormat;
    m_fMaxS = contentSize.width / (float)(pixelsWide);
    m_fMaxT = contentSize.height / (float)(pixelsHigh);

    m_bHasPremultipliedAlpha = false;
    m_bHasMipmaps = false;

    setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTexture));

    return true;
}


const char* CCTexture2D::description(void)
{
    return CCString::createWithFormat("<CCTexture2D | Name = %u | Dimensions = %u x %u | Coordinates = (%.2f, %.2f)>", m_uName, m_uPixelsWide, m_uPixelsHigh, m_fMaxS, m_fMaxT)->getCString();
}

// implementation CCTexture2D (Image)

bool CCTexture2D::initWithImage(CCImage *uiImage)
{
	setDbgInfo( uiImage ); //ND_MOD

    if (uiImage == NULL)
    {
        CCLOG("cocos2d: CCTexture2D. Can't create Texture. UIImage is nil");
        this->release();
        return false;
    }
    
    unsigned int imageWidth = uiImage->getWidth();
    unsigned int imageHeight = uiImage->getHeight();
    
    CCConfiguration *conf = CCConfiguration::sharedConfiguration();
    
    unsigned maxTextureSize = conf->getMaxTextureSize();
    if (maxTextureSize > 0 && (imageWidth > maxTextureSize || imageHeight > maxTextureSize) )
    {
        CCLOG("cocos2d: WARNING: Image (%u x %u) is bigger than the supported %u x %u", imageWidth, imageHeight, maxTextureSize, maxTextureSize);
        this->release();
        return NULL;
    }
    
    // always load premultiplied images
    return initPremultipliedATextureWithImage(uiImage, imageWidth, imageHeight);
}

bool CCTexture2D::initPremultipliedATextureWithImage(CCImage *image, unsigned int width, unsigned int height)
{
	setDbgInfo( image ); //ND_MOD

    unsigned char*            tempData = image->getData();
    unsigned int*             inPixel32 = NULL;
    unsigned char*            inPixel8 = NULL;
    unsigned short*           outPixel16 = NULL;
    bool                      hasAlpha = image->hasAlpha();
    CCSize                    imageSize = CCSizeMake((float)(image->getWidth()), (float)(image->getHeight()));
    CCTexture2DPixelFormat    pixelFormat;
    size_t                    bpp = image->getBitsPerComponent();

    // compute pixel format
    if(hasAlpha)
    {
        pixelFormat = g_defaultAlphaPixelFormat;
    }
    else
    {
        if (bpp >= 8)
        {
            pixelFormat = kCCTexture2DPixelFormat_RGB888;
        }
        else 
        {
            pixelFormat = kCCTexture2DPixelFormat_RGB565;
        }
        
    }
    
    // Repack the pixel data into the right format
    unsigned int length = width * height;
    
    if (pixelFormat == kCCTexture2DPixelFormat_RGB565)
    {
        if (hasAlpha)
        {
            // Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
            
            tempData = new unsigned char[width * height * 2];
            outPixel16 = (unsigned short*)tempData;
            inPixel32 = (unsigned int*)image->getData();
            
            for(unsigned int i = 0; i < length; ++i, ++inPixel32)
            {
                *outPixel16++ = 
                ((((*inPixel32 >>  0) & 0xFF) >> 3) << 11) |  // R
                ((((*inPixel32 >>  8) & 0xFF) >> 2) << 5)  |  // G
                ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);    // B
            }
        }
        else 
        {
            // Convert "RRRRRRRRRGGGGGGGGBBBBBBBB" to "RRRRRGGGGGGBBBBB"
            
            tempData = new unsigned char[width * height * 2];
            outPixel16 = (unsigned short*)tempData;
            inPixel8 = (unsigned char*)image->getData();
            
            for(unsigned int i = 0; i < length; ++i)
            {
                *outPixel16++ = 
                (((*inPixel8++ & 0xFF) >> 3) << 11) |  // R
                (((*inPixel8++ & 0xFF) >> 2) << 5)  |  // G
                (((*inPixel8++ & 0xFF) >> 3) << 0);    // B
            }
        }    
    }
    else if (pixelFormat == kCCTexture2DPixelFormat_RGBA4444)
    {
        // Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
        
        inPixel32 = (unsigned int*)image->getData();  
        tempData = new unsigned char[width * height * 2];
        outPixel16 = (unsigned short*)tempData;
        
        for(unsigned int i = 0; i < length; ++i, ++inPixel32)
        {
            *outPixel16++ = 
            ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | // R
            ((((*inPixel32 >> 8) & 0xFF) >> 4) <<  8) | // G
            ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | // B
            ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);  // A
        }
    }
    else if (pixelFormat == kCCTexture2DPixelFormat_RGB5A1)
    {
        // Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGBBBBBA"
        inPixel32 = (unsigned int*)image->getData();   
        tempData = new unsigned char[width * height * 2];
        outPixel16 = (unsigned short*)tempData;
        
        for(unsigned int i = 0; i < length; ++i, ++inPixel32)
        {
            *outPixel16++ = 
            ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | // R
            ((((*inPixel32 >> 8) & 0xFF) >> 3) <<  6) | // G
            ((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) | // B
            ((((*inPixel32 >> 24) & 0xFF) >> 7) << 0);  // A
        }
    }
    else if (pixelFormat == kCCTexture2DPixelFormat_A8)
    {
        // Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "AAAAAAAA"
        inPixel32 = (unsigned int*)image->getData();
        tempData = new unsigned char[width * height];
        unsigned char *outPixel8 = tempData;
        
        for(unsigned int i = 0; i < length; ++i, ++inPixel32)
        {
            *outPixel8++ = (*inPixel32 >> 24) & 0xFF;  // A
        }
    }
    
    if (hasAlpha && pixelFormat == kCCTexture2DPixelFormat_RGB888)
    {
        // Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRGGGGGGGGBBBBBBBB"
        inPixel32 = (unsigned int*)image->getData();
        tempData = new unsigned char[width * height * 3];
        unsigned char *outPixel8 = tempData;
        
        for(unsigned int i = 0; i < length; ++i, ++inPixel32)
        {
            *outPixel8++ = (*inPixel32 >> 0) & 0xFF; // R
            *outPixel8++ = (*inPixel32 >> 8) & 0xFF; // G
            *outPixel8++ = (*inPixel32 >> 16) & 0xFF; // B
        }
    }
    
    initWithData(tempData, pixelFormat, width, height, imageSize);
    
    if (tempData != image->getData())
    {
        delete [] tempData;
    }

    m_bHasPremultipliedAlpha = image->isPremultipliedAlpha();
    return true;
}

// implementation CCTexture2D (Text)
bool CCTexture2D::initWithString(const char *text, const char *fontName, float fontSize)
{
	setDbgInfo( text ); //ND_MOD
    return initWithString(text, CCSizeMake(0,0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, fontName, fontSize);
}

bool CCTexture2D::initWithString(const char *text, const CCSize& dimensions, CCTextAlignment hAlignment, CCVerticalTextAlignment vAlignment, const char *fontName, float fontSize)
{
#if CC_ENABLE_CACHE_TEXTURE_DATA
    // cache the texture data
    VolatileTexture::addStringTexture(this, text, dimensions, hAlignment, vAlignment, fontName, fontSize);
#endif

	setDbgInfo( text ); //ND_MOD

    CCImage image;

    CCImage::ETextAlign eAlign;

    if (kCCVerticalTextAlignmentTop == vAlignment)
    {
        eAlign = (kCCTextAlignmentCenter == hAlignment) ? CCImage::kAlignTop
            : (kCCTextAlignmentLeft == hAlignment) ? CCImage::kAlignTopLeft : CCImage::kAlignTopRight;
    }
    else if (kCCVerticalTextAlignmentCenter == vAlignment)
    {
        eAlign = (kCCTextAlignmentCenter == hAlignment) ? CCImage::kAlignCenter
            : (kCCTextAlignmentLeft == hAlignment) ? CCImage::kAlignLeft : CCImage::kAlignRight;
    }
    else if (kCCVerticalTextAlignmentBottom == vAlignment)
    {
        eAlign = (kCCTextAlignmentCenter == hAlignment) ? CCImage::kAlignBottom
            : (kCCTextAlignmentLeft == hAlignment) ? CCImage::kAlignBottomLeft : CCImage::kAlignBottomRight;
    }
    else
    {
        CCAssert(false, "Not supported alignment format!");
    }
    
    if (!image.initWithString(text, (int)dimensions.width, (int)dimensions.height, eAlign, fontName, (int)fontSize))
    {
        return false;
    }

    return initWithImage(&image);
}


// implementation CCTexture2D (Drawing)

void CCTexture2D::drawAtPoint(const CCPoint& point)
{
    GLfloat    coordinates[] = {    
        0.0f,    m_fMaxT,
        m_fMaxS,m_fMaxT,
        0.0f,    0.0f,
        m_fMaxS,0.0f };

    GLfloat    width = (GLfloat)m_uPixelsWide * m_fMaxS,
        height = (GLfloat)m_uPixelsHigh * m_fMaxT;

    GLfloat        vertices[] = {    
        point.x,            point.y,
        width + point.x,    point.y,
        point.x,            height  + point.y,
        width + point.x,    height  + point.y };

    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
    m_pShaderProgram->use();
    m_pShaderProgram->setUniformForModelViewProjectionMatrix();

    ccGLBindTexture2D( m_uName );


    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, coordinates);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

void CCTexture2D::drawInRect(const CCRect& rect)
{
    GLfloat    coordinates[] = {    
        0.0f,    m_fMaxT,
        m_fMaxS,m_fMaxT,
        0.0f,    0.0f,
        m_fMaxS,0.0f };

    GLfloat    vertices[] = {    rect.origin.x,        rect.origin.y,                            /*0.0f,*/
        rect.origin.x + rect.size.width,        rect.origin.y,                            /*0.0f,*/
        rect.origin.x,                            rect.origin.y + rect.size.height,        /*0.0f,*/
        rect.origin.x + rect.size.width,        rect.origin.y + rect.size.height,        /*0.0f*/ };

    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
    m_pShaderProgram->use();
    m_pShaderProgram->setUniformForModelViewProjectionMatrix();

    ccGLBindTexture2D( m_uName );

    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, coordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#ifdef CC_SUPPORT_PVRTC
// implementation CCTexture2D (PVRTC);    
bool CCTexture2D::initWithPVRTCData(const void *data, int level, int bpp, bool hasAlpha, int length, CCTexture2DPixelFormat pixelFormat)
{
    if( !(CCConfiguration::sharedConfiguration()->supportsPVRTC()) )
    {
        CCLOG("cocos2d: WARNING: PVRTC images is not supported.");
        this->release();
        return false;
    }

    glGenTextures(1, &m_uName);
    glBindTexture(GL_TEXTURE_2D, m_uName);

    this->setAntiAliasTexParameters();

    GLenum format;
    GLsizei size = length * length * bpp / 8;
    if(hasAlpha) {
        format = (bpp == 4) ? GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
    } else {
        format = (bpp == 4) ? GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
    }
    if(size < 32) {
        size = 32;
    }
    glCompressedTexImage2D(GL_TEXTURE_2D, level, format, length, length, 0, size, data);

    m_tContentSize = CCSizeMake((float)(length), (float)(length));
    m_uPixelsWide = length;
    m_uPixelsHigh = length;
    m_fMaxS = 1.0f;
    m_fMaxT = 1.0f;
    m_bHasPremultipliedAlpha = PVRHaveAlphaPremultiplied_;
    m_ePixelFormat = pixelFormat;

    return true;
}
#endif // CC_SUPPORT_PVRTC

bool CCTexture2D::initWithPVRFile(const char* file)
{
	setDbgInfo( file ); //ND_MOD

    bool bRet = false;
    // nothing to do with CCObject::init
    
    CCTexturePVR *pvr = new CCTexturePVR;
    bRet = pvr->initWithContentsOfFile(file);
        
    if (bRet)
    {
        pvr->setRetainName(true); // don't dealloc texture on release
        
        m_uName = pvr->getName();
        m_fMaxS = 1.0f;
        m_fMaxT = 1.0f;
        m_uPixelsWide = pvr->getWidth();
        m_uPixelsHigh = pvr->getHeight();
        m_tContentSize = CCSizeMake((float)m_uPixelsWide, (float)m_uPixelsHigh);
        m_bHasPremultipliedAlpha = PVRHaveAlphaPremultiplied_;
        m_ePixelFormat = pvr->getFormat();
        m_bHasMipmaps = pvr->getNumberOfMipmaps() > 1;       

        pvr->release();
    }
    else
    {
        CCLOG("cocos2d: Couldn't load PVR image %s", file);
    }

    return bRet;
}

void CCTexture2D::PVRImagesHavePremultipliedAlpha(bool haveAlphaPremultiplied)
{
    PVRHaveAlphaPremultiplied_ = haveAlphaPremultiplied;
}

    
//
// Use to apply MIN/MAG filter
//
// implementation CCTexture2D (GLFilter)

void CCTexture2D::generateMipmap()
{
    CCAssert( m_uPixelsWide == ccNextPOT(m_uPixelsWide) && m_uPixelsHigh == ccNextPOT(m_uPixelsHigh), "Mipmap texture only works in POT textures");
    ccGLBindTexture2D( m_uName );
    glGenerateMipmap(GL_TEXTURE_2D);
    m_bHasMipmaps = true;
}

bool CCTexture2D::hasMipmaps()
{
    return m_bHasMipmaps;
}

void CCTexture2D::setTexParameters(ccTexParams *texParams)
{
    CCAssert( (m_uPixelsWide == ccNextPOT(m_uPixelsWide) || texParams->wrapS == GL_CLAMP_TO_EDGE) &&
        (m_uPixelsHigh == ccNextPOT(m_uPixelsHigh) || texParams->wrapT == GL_CLAMP_TO_EDGE),
        "GL_CLAMP_TO_EDGE should be used in NPOT dimensions");

    ccGLBindTexture2D( m_uName );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, texParams->minFilter );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, texParams->magFilter );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, texParams->wrapS );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, texParams->wrapT );

#if CC_ENABLE_CACHE_TEXTURE_DATA
    VolatileTexture::setTexParameters(this, texParams);
#endif
}

void CCTexture2D::setAliasTexParameters()
{
    ccGLBindTexture2D( m_uName );

    if( ! m_bHasMipmaps )
    {
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    }
    else
    {
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST );
    }

    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
#if CC_ENABLE_CACHE_TEXTURE_DATA
    ccTexParams texParams = {m_bHasMipmaps?GL_NEAREST_MIPMAP_NEAREST:GL_NEAREST,GL_NEAREST,GL_NONE,GL_NONE};
    VolatileTexture::setTexParameters(this, &texParams);
#endif
}

void CCTexture2D::setAntiAliasTexParameters()
{
    ccGLBindTexture2D( m_uName );

    if( ! m_bHasMipmaps )
    {
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    }
    else
    {
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST );
    }

    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
#if CC_ENABLE_CACHE_TEXTURE_DATA
    ccTexParams texParams = {m_bHasMipmaps?GL_LINEAR_MIPMAP_NEAREST:GL_LINEAR,GL_LINEAR,GL_NONE,GL_NONE};
    VolatileTexture::setTexParameters(this, &texParams);
#endif
}

const char* CCTexture2D::stringForFormat()
{
	switch (m_ePixelFormat) 
	{
		case kCCTexture2DPixelFormat_RGBA8888:
			return  "RGBA8888";

		case kCCTexture2DPixelFormat_RGB888:
			return  "RGB888";

		case kCCTexture2DPixelFormat_RGB565:
			return  "RGB565";

		case kCCTexture2DPixelFormat_RGBA4444:
			return  "RGBA4444";

		case kCCTexture2DPixelFormat_RGB5A1:
			return  "RGB5A1";

		case kCCTexture2DPixelFormat_AI88:
			return  "AI88";

		case kCCTexture2DPixelFormat_A8:
			return  "A8";

		case kCCTexture2DPixelFormat_I8:
			return  "I8";

		case kCCTexture2DPixelFormat_PVRTC4:
			return  "PVRTC4";

		case kCCTexture2DPixelFormat_PVRTC2:
			return  "PVRTC2";

		default:
			CCAssert(false , "unrecognized pixel format");
			CCLOG("stringForFormat: %ld, cannot give useful result", (long)m_ePixelFormat);
			break;
	}

	return  NULL;
}


//
// Texture options for images that contains alpha
//
// implementation CCTexture2D (PixelFormat)

void CCTexture2D::setDefaultAlphaPixelFormat(CCTexture2DPixelFormat format)
{
    g_defaultAlphaPixelFormat = format;
}


CCTexture2DPixelFormat CCTexture2D::defaultAlphaPixelFormat()
{
    return g_defaultAlphaPixelFormat;
}

unsigned int CCTexture2D::bitsPerPixelForFormat(CCTexture2DPixelFormat format)
{
	unsigned int ret=0;

	switch (format) {
		case kCCTexture2DPixelFormat_RGBA8888:
			ret = 32;
			break;
		case kCCTexture2DPixelFormat_RGB888:
			// It is 32 and not 24, since its internal representation uses 32 bits.
			ret = 32;
			break;
		case kCCTexture2DPixelFormat_RGB565:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_RGBA4444:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_RGB5A1:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_AI88:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_A8:
			ret = 8;
			break;
		case kCCTexture2DPixelFormat_I8:
			ret = 8;
			break;
		case kCCTexture2DPixelFormat_PVRTC4:
			ret = 4;
			break;
		case kCCTexture2DPixelFormat_PVRTC2:
			ret = 2;
			break;
		default:
			ret = -1;
			CCAssert(false , "unrecognized pixel format");
			CCLOG("bitsPerPixelForFormat: %ld, cannot give useful result", (long)format);
			break;
	}
	return ret;
}

unsigned int CCTexture2D::bitsPerPixelForFormat()
{
	return this->bitsPerPixelForFormat(m_ePixelFormat);
}


#if ND_MOD
#pragma message xx
CCTexture2D* CCTexture2D::initWithPaletteData(const void* pData,
		CCTexture2DPixelFormat ePixelFormat, int nWidth, int nHeight,
		CCSize kSize, unsigned int uiSizeOfData)
{
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glGenTextures(1, &m_uName);
	glBindTexture(GL_TEXTURE_2D, m_uName);

	setAntiAliasTexParameters();

	switch (ePixelFormat)
	{
	case kCCTexture2DPixelFormat_RGBA8888:
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) nWidth,
				(GLsizei) nHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, pData);
		break;
	case kCCTexture2DPixelFormat_RGBA4444:
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) nWidth,
				(GLsizei) nHeight, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, pData);
		break;
	case kCCTexture2DPixelFormat_RGB5A1:
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) nWidth,
				(GLsizei) nHeight, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, pData);
		break;
	case kCCTexture2DPixelFormat_RGB565:
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei) nWidth,
				(GLsizei) nHeight, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, pData);
		break;
	case kCCTexture2DPixelFormat_AI88:
		glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, (GLsizei) nWidth,
				(GLsizei) nHeight, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE,
				pData);
		break;
	case kCCTexture2DPixelFormat_A8:
		glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, (GLsizei) nWidth,
				(GLsizei) nHeight, 0, GL_ALPHA, GL_UNSIGNED_BYTE, pData);
		break;
        case kCCTexture2DPixelFormat_RGBA8:
#define GL_PALETTE8_RGBA8_OES             0x8B96
		glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_PALETTE8_RGBA8_OES, nWidth,
				nHeight, 0, uiSizeOfData, pData);
		break;
	default:
		//[NSException raise:NSInternalInconsistencyException format:@""];
		break;

	}

	m_tContentSize = kSize;
	m_uiWidth = (unsigned int) nWidth;
	m_uiHeight = (unsigned int) nHeight;
	m_uPixelsWide = nWidth;
	m_uPixelsHigh = nHeight;
	m_ePixelFormat = ePixelFormat;
	m_fMaxT = m_tContentSize.width / (float) m_uiWidth;
	m_fMaxS = m_tContentSize.height / (float) m_uiHeight;
	m_bHasPremultipliedAlpha = false;
	m_pData = 0;
	m_nContainerType = 0;

	return this;
}

bool CCTexture2D::initWithPalettePNG(const char* pszPNGFile)
{
	setDbgInfo( pszPNGFile ); //ND_MOD

	if (0 == pszPNGFile || !*pszPNGFile)
	{
		return false;
	}

	FILE* pkFile = 0;
	unsigned int nPOTWide = 0;
	unsigned int nPOTHigh = 0;
	CCSize kImageSize;
	char szBuffer[PNG_BYTES_TO_CHECK] =
	{ 0 };

	if (0 == (pkFile = fopen(pszPNGFile, "rb")))
	{
		return false;
	}

	if (PNG_BYTES_TO_CHECK != fread(szBuffer, 1, PNG_BYTES_TO_CHECK, pkFile))
	{
		fclose(pkFile);
		return false;
	}

	if (0 != png_sig_cmp((unsigned char*) szBuffer, (png_size_t) 0,
					PNG_BYTES_TO_CHECK))
	{
		fclose(pkFile);
		return false;
	}

	png_structp pkPNGPointer = 0;
	png_infop pkPNGInfo = 0;
	unsigned int uiSigRead = PNG_BYTES_TO_CHECK;

	int nColorType = 0;
	int nInterlaceType = 0;
	png_uint_32 dwWidth = 0;
	png_uint_32 dwHeight = 0;
	int nPixelCount = 0;
	int nCompressionType = 0;
	int nFilterType = 0;

	pkPNGPointer = png_create_read_struct(PNG_LIBPNG_VER_STRING, 0, 0, 0);

	if (0 == pkPNGPointer)
	{
		fclose(pkFile);
		return false;
	}

	pkPNGInfo = png_create_info_struct(pkPNGPointer);

	if (0 == pkPNGInfo)
	{
		fclose(pkFile);
		png_destroy_read_struct(&pkPNGPointer, &pkPNGInfo, 0);
		return false;
	}

	png_init_io(pkPNGPointer, pkFile);
	png_set_sig_bytes(pkPNGPointer, uiSigRead);

	png_read_info(pkPNGPointer, pkPNGInfo);
	png_get_IHDR(pkPNGPointer, pkPNGInfo, &dwWidth, &dwHeight, &nPixelCount,
			&nColorType, &nInterlaceType, &nCompressionType, &nFilterType);
	CCConfiguration* pkConfig = CCConfiguration::sharedConfiguration();

	nPOTWide = dwWidth;
	nPOTHigh = dwHeight;

	unsigned int uiMaxTextureSize = pkConfig->getMaxTextureSize();

	if (nPOTHigh > uiMaxTextureSize || nPOTWide > uiMaxTextureSize)
	{
		release();
		fclose(pkFile);
		return false;
	}

	png_set_packing(pkPNGPointer);

	if ((PNG_COLOR_TYPE_GRAY == nColorType && nPixelCount < 8)
			|| PNG_COLOR_TYPE_PALETTE == nColorType)
	{
		png_set_expand(pkPNGPointer);
	}

	if (png_get_valid(pkPNGPointer, pkPNGInfo, PNG_INFO_tRNS))
	{
		png_set_tRNS_to_alpha(pkPNGPointer);
	}

	png_set_invert_mono(pkPNGPointer);
	png_set_swap(pkPNGPointer);
	//png_set_filter(pkPNGPointer, 0xFF, PNG_FILLER_AFTER);
	png_read_update_info(pkPNGPointer, pkPNGInfo);

	png_color* pkPalette = 0;
	int nNumberPalette = 0;
	int nPaletteLength = 1 << nPixelCount;
	CCTexture2D::RGBQUAD pBmiColors[256] =
	{ 0 };

	png_get_PLTE(pkPNGPointer, pkPNGInfo, &pkPalette, &nNumberPalette);

	if (0 < nNumberPalette)
	{
		pkPNGPointer->bReadTransforms = 0;
		ConvertPalette(pkPalette,(CCTexture2D::RGBQUAD*)&pBmiColors,nPaletteLength,pkPNGInfo->trans_alpha);
	}

	static void* s_pData = 0;
	CCTexture2DPixelFormat ePixelFormat = kCCTexture2DPixelFormat_RGBA8888;

	int nRowBytes = png_get_rowbytes(pkPNGPointer, pkPNGInfo);
	static png_bytepp s_pProwPointers = 0;
	int nMaxHeight = static_cast<int>(1024.0f * CC_CONTENT_SCALE_FACTOR());

	if (dwHeight > (unsigned int) nMaxHeight)
	{
		nMaxHeight = dwHeight;

		if (0 != s_pProwPointers)
		{
			free(s_pProwPointers);
			s_pProwPointers = 0;
		}
	}

	if (0 == s_pProwPointers)
	{
		s_pProwPointers = (png_bytepp) malloc(sizeof(png_bytep) * nMaxHeight);
	}

	int nMaxRowBytes = static_cast<int>(2048.0f * CC_CONTENT_SCALE_FACTOR());

	if (nRowBytes > nMaxRowBytes)
	{
		nMaxRowBytes = nRowBytes;

		if (0 == s_pData)
		{
			free(s_pData);
			s_pData = 0;
		}
	}

	if (0 == s_pData)
	{
		s_pData = malloc(sizeof(CCTexture2D::RGBQUAD) * 256 + nMaxRowBytes * nMaxHeight);
	}

	for (unsigned int row = 0; row < dwHeight; row++)
	{
		s_pProwPointers[row] = (png_byte*) s_pData + sizeof(CCTexture2D::RGBQUAD) * nNumberPalette + row * nRowBytes;
	}

	if (0 < nNumberPalette)
	{
		memcpy(s_pData, (char*) pBmiColors, sizeof(CCTexture2D::RGBQUAD) * nNumberPalette);
		ePixelFormat = kCCTexture2DPixelFormat_RGBA8;
	}
	else if (32 == pkPNGPointer->pixel_depth)
	{
		ePixelFormat = kCCTexture2DPixelFormat_RGBA8888;
	}
	else if (24 == pkPNGPointer->pixel_depth)
	{
		ePixelFormat = kCCTexture2DPixelFormat_RGB888;
	}
	else
	{
		ePixelFormat = kCCTexture2DPixelFormat_RGB565;
	}

	png_read_image(pkPNGPointer, s_pProwPointers);
	png_read_end(pkPNGPointer, pkPNGInfo);

	if (32 == pkPNGPointer->pixel_depth)
	{
		for (int row = 0; row < (int) dwHeight; row++)
		{
			for (int col = 0;col < (int) dwWidth * 4;col += 4)
			{
				alpha_composite(s_pProwPointers[row][col],
					s_pProwPointers[row][col], s_pProwPointers[row][col + 3], 0);
				alpha_composite(s_pProwPointers[row][col+1],
					s_pProwPointers[row][col +1 ], s_pProwPointers[row][col + 3], 0);
				alpha_composite(s_pProwPointers[row][col+2],
					s_pProwPointers[row][col + 2], s_pProwPointers[row][col + 3], 0);
			}
		}
	}

	//SaveToBitmap(pszPNGFile, s_pProwPointers,nRowBytes,dwWidth,dwHeight,pkPNGPointer->pixel_depth,pBmiColors,nNumberPalette);

	kImageSize = CCSizeMake(static_cast<float>(dwWidth), static_cast<float>(dwHeight));

	initWithPaletteData(s_pData, ePixelFormat, nPOTWide,nPOTHigh,
		kImageSize,sizeof(CCTexture2D::RGBQUAD) * nNumberPalette + nRowBytes * dwHeight);

	m_bHasPremultipliedAlpha = true;

	if (m_bKeepData)
	{
		m_pData = s_pData;
	}

	png_destroy_read_struct(&pkPNGPointer, &pkPNGInfo, png_infopp_NULL);

	fclose(pkFile);

	return true;
}

void CCTexture2D::SaveToBitmap(const char* pszPngFile,
		unsigned char** pBMPColorBuf, int rowByteWidth, int width, int height,
		int colorDepth, CCTexture2D::RGBQUAD* pPalette, int nPaletteLen)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	int mPackedRowByteWidth = (rowByteWidth + 3) & 0xfffffffc;
	BYTE *pBmpBuf = (BYTE*) malloc(
			mPackedRowByteWidth * height + 54 + nPaletteLen * sizeof(CCTexture2D::RGBQUAD));
	BITMAPFILEHEADER *pBfh = (BITMAPFILEHEADER *) pBmpBuf;
	BYTE* pTemp = pBmpBuf;
	*pTemp = 'B';
	pTemp++;
	*pTemp = 'M';

	pBfh->bfOffBits = 54 + nPaletteLen * sizeof(CCTexture2D::RGBQUAD);
	pBfh->bfSize = mPackedRowByteWidth * height + 54
	+ nPaletteLen * sizeof(CCTexture2D::RGBQUAD);
	pBfh->bfReserved1 = pBfh->bfReserved2 = 0;

	BITMAPINFOHEADER *pBih = (BITMAPINFOHEADER *) (pBfh + 1);
	pBih->biBitCount = colorDepth;
	pBih->biClrImportant = 0;
	pBih->biClrUsed = 0;
	pBih->biCompression = 0;
	pBih->biHeight = height;
	pBih->biPlanes = 1;
	pBih->biSize = 40;
	pBih->biSizeImage = mPackedRowByteWidth * height;
	pBih->biWidth = width;
	pBih->biXPelsPerMeter = 0;
	pBih->biYPelsPerMeter = 0;

	// copy palette
	BYTE *pRowBuf = (BYTE *) (pBih + 1);
	if (nPaletteLen > 0)
	{
		memcpy(pRowBuf, pPalette, nPaletteLen * sizeof(CCTexture2D::RGBQUAD));
		// copy data
		pRowBuf += nPaletteLen * sizeof(CCTexture2D::RGBQUAD);
	}

	pRowBuf += mPackedRowByteWidth * (height - 1);
	for (int i = 0; i < height; i++)
	{
		memcpy(pRowBuf, *pBMPColorBuf, rowByteWidth);
		pRowBuf -= mPackedRowByteWidth;
		pBMPColorBuf++;
	}
	//memcpy((BYTE *)(pBih+1),pBMPColorBuf,rowByteWidth * height);
	char szFileName[256] =
	{	0};
	sprintf(szFileName, "%stestJPG_PngLib.bmp", pszPngFile);
	WriteToBMPFile(szFileName, pBmpBuf,
			mPackedRowByteWidth * height + 54 + nPaletteLen * sizeof(CCTexture2D::RGBQUAD));
	free(pBmpBuf);
#endif
}

void CCTexture2D::WriteToBMPFile(char* pFileName, BYTE* pBmpBuf, int nBmplen)
{
	FILE* pkFile = fopen(pFileName, "wb");

	if (0 == pkFile)
	{
		return;
	}

	fwrite(pBmpBuf, nBmplen, 1, pkFile);
	fclose(pkFile);
}

void CCTexture2D::setDbgInfo( const char* text ) 
{
	if (dbgInfo.length() == 0 && text && text[0] != 0) 
	{
		dbgInfo = text;
	}
}

void CCTexture2D::setDbgInfo(CCImage* uiImage) 
{
	if (dbgInfo.length() == 0 
		&& uiImage && uiImage->dbgInfo.length() > 0)
	{
		dbgInfo = uiImage->dbgInfo;
	}
}

#endif //ND_MOD

NS_CC_END
