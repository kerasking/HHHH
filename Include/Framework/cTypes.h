#ifndef __CCTYPES_H__
#define __CCTYPES_H__
//动作和精灵里的定义

#include "CGeometry.h"
#include <assert.h>

typedef unsigned int GLenum;
typedef unsigned char GLboolean;
typedef unsigned int GLbitfield;
typedef signed char GLbyte;
typedef short GLshort;
typedef int GLint;
typedef int GLsizei;
typedef unsigned char GLubyte;
typedef unsigned short GLushort;
typedef unsigned int GLuint;
typedef float GLfloat;
typedef float GLclampf;
typedef double GLdouble;
typedef double GLclampd;
typedef void GLvoid;

/** RGB color composed of bytes 3 bytes
颜色(类型是三个unsigned char)
 */
typedef struct _ccColor3B
{
	GLubyte	r;
	GLubyte	g;
	GLubyte b;
} Color3B;

//! helper macro that creates an Color3B type
static inline Color3B
ccc3(const GLubyte r, const GLubyte g, const GLubyte b)
{
	Color3B c = {r, g, b};
	return c;
}
//Color3B predefined colors
//! White color (255,255,255)
static const Color3B clrWHITE={255,255,255};
//! Yellow color (255,255,0)
static const Color3B clrYELLOW={255,255,0};
//! Blue color (0,0,255)
static const Color3B clrBLUE={0,0,255};
//! Green Color (0,255,0)
static const Color3B clrGREEN={0,255,0};
//! Red Color (255,0,0,)
static const Color3B clrRED={255,0,0};
//! Magenta Color (255,0,255)
static const Color3B clrMAGENTA={255,0,255};
//! Black Color (0,0,0)
static const Color3B clrBLACK={0,0,0};
//! Orange Color (255,127,0)
static const Color3B clrORANGE={255,127,0};
//! Gray Color (166,166,166)
static const Color3B clrGRAY={166,166,166};


#define ASSERT(cond)              assert(cond)
#define Assert(cond, msg)         ASSERT(cond)

#endif //__CCTYPES_H__
