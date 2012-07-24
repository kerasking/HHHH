
#ifndef __NDSubAniGroup_H
#define __NDSubAniGroup_H

#include "basedefine.h"

class NDFrameRunRecord;
class NDAnimationGroup;
class Fighter;
namespace NDEngine 
{	
	enum {
		SUB_ANI_TYPE_SELF = 0,
		SUB_ANI_TYPE_TARGET = 1,
		SUB_ANI_TYPE_NONE = 2,
		SUB_ANI_TYPE_ROLE_FEEDPET = 3,
		SUB_ANI_TYPE_ROLE_WEAPON = 4,
		SUB_ANI_TYPE_SCREEN_CENTER = 5,
	};

	class NDSprite;
	class NDNode;

	struct NDSubAniGroup {

		NDSubAniGroup() {
			memset(this, 0L, sizeof(NDSubAniGroup));
		}

		NDSprite* role;
		NDAnimationGroup* aniGroup;
		Fighter* fighter;
		NDFrameRunRecord* frameRec;

		OBJID idAni;
		short x;
		short y;
		bool reverse;
		short coordW;
		short coordH;
		Byte type;
		int time;	//播放次数
		int antId;	//动作ID
		bool bComplete; // 播放完成
		bool isFromOut;
		int startFrame;
		bool isCanStart;//用来控制战斗中的延迟问题
	};

	struct NDSubAniGroupEx 
	{
		short x;
		short y;

		short coordW;
		short coordH;

		Byte type;

		std::string anifile;
	};


	//
	// 作用：播放子动画
	// 参数：key: 用于获取子动画的 frameRecord; sag:子动画信息
	// 返回值：子动画是否播放完成
	//bool DrawSubAnimation(NDNode* layer, NDSubAniGroup& sag);

	void AddSubAniGroup(NDSubAniGroupEx& group);

	//		
	//		函数：RunBattleSubAnimation
	//		作用：播放战斗子动画
	//		参数：f战斗对象
	//		返回值：无
	void RunBattleSubAnimation(NDSprite* role, Fighter* f);
}

#endif