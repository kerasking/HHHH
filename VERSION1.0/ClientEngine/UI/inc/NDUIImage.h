//
//  NDUIImage.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-18.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef __NDUIImage_H
#define __NDUIImage_H

#include "NDUINode.h"
#include "NDCombinePicture.h"

namespace NDEngine
{
	class NDUIImage : public NDUINode
	{
		DECLARE_CLASS(NDUIImage)
		NDUIImage();
		~NDUIImage();

	public:

		void SetPicture(NDPicture* pic, bool clearPicOnFree = false);
		NDPicture* GetPicture() { return m_pic;}
		void SetPictureLua(NDPicture* pic);
		CCSize GetPicSize();
		void SetCombinePicture(NDCombinePicture* pic, bool clearPicOnFree = false);
		virtual void draw();
	private:
		NDPicture* m_pic;
		NDCombinePicture *m_combinePic;
		bool m_clearPicOnFree;
	};
}
#endif
