/*
 *  NDUIAnimation.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_UI_ANIMATION_H_
#define _ND_UI_ANIMATION_H_

#include "NDUINode.h"
#include "NDTimer.h"
#include "GlobalDialog.h"
#include <map>
#include <deque>

using namespace NDEngine;

typedef enum
{
	UIAnimationMoveBegin,
	UIAnimationMoveNone = UIAnimationMoveBegin,
	UIAnimationMoveLeftToRight,
	UIAnimationMoveLeftToRightReverse,
	UIAnimationMoveRightToLeft,
	UIAnimationMoveRightToLeftReverse,
 	UIAnimationMoveTopToBottom,
	UIAnimationMoveTopToBottomReverse,
	UIAnimationMoveEnd,
}UIAnimationMove;

class NDUIAnimation : 
public NDObject,
public ITimerCallback
{
	DECLARE_CLASS(NDUIAnimation)
public:
	NDUIAnimation();
	
	~NDUIAnimation();
	
	void OnTimer(OBJID tag); override;
	
	unsigned int GetAnimationKey(NDUINode* node, CGSize range=CGSizeZero);
	
	bool DelAnimation(unsigned int key);
	
	bool DelAllAnimation();
	
	bool AddAnimation(unsigned int key, CGPoint fromPosition, CGPoint toPosition, float needTime);
	
	bool AddAnimation(unsigned int key, UIAnimationMove move, float needTime);
	
	bool playerAnimation(unsigned int key);
	
	bool playerAllAnimation();
	
	/*
	bool StopAnimation(unsigned int key);
	
	bool StopAllAnimation();
	*/
	
private:
	void Update(float dt);
	
private:
	typedef  struct MoveInfo
	{
		MoveInfo()
		{
			memset(this, 0, sizeof(this));
		}
		
		explicit MoveInfo(UIAnimationMove move, float time)
		{
			this->move			= move;
			this->time			= time;
			this->fromPosition	= CGPointZero;
			this->toPosition	= CGPointZero;
		}
		explicit MoveInfo(CGPoint fromPosition, CGPoint toPosition, float time)
		{
			this->move			= UIAnimationMoveNone;
			this->time			= time;
			this->fromPosition	= fromPosition;
			this->toPosition	= toPosition;
		}
		
		UIAnimationMove move;
		CGPoint fromPosition, toPosition;
		float time;
	};
	
	typedef struct _tagUIAnimationSequence
	{
		bool AddAnimation(UIAnimationMove move, float time)
		{
			if (move <= UIAnimationMoveNone || move >= UIAnimationMoveEnd) return false;
			
			if (time < 0.0f) return false;
			
			infos.push_back(MoveInfo(move, time));
			
			return true;
		}
		bool AddAnimation(CGPoint fromPosition, CGPoint toPosition, float time)
		{
			if (time < 0.0f) return false;
			
			infos.push_back(MoveInfo(fromPosition, toPosition, time));
			
			return true;
		}
		bool GetAnimation(MoveInfo& info)
		{
			if (curIndex == (unsigned int)-1 || curIndex >= infos.size()) return false;
			
			info = infos[curIndex++];
			
			return true;
		}
		
		void Clear()
		{
			curIndex = -1;
			
			
		}
		
		void Start() { curIndex = 0; }
		
		void Stop() { curIndex = -1; infos.clear(); }
	private:
		std::deque<MoveInfo> infos;
		unsigned int curIndex;
	}UIAnimationSequence;
	
	typedef struct _tagUIAnimationInfo
	{
		unsigned int uiID;
		NDUINode* node;
		CGRect orginScrRect;
		MoveInfo curMove;
		CGSize range;
		float pass;
		UIAnimationSequence sequence;
		
		bool StartUIAnimation()
		{
			sequence.Start();
			
			pass = 0.0f;
			
			return sequence.GetAnimation(curMove);
		}
		
		bool StopUIAnimation()
		{
			sequence.Stop();
			
			return true;
		}
		
		bool Run(float dt)
		{
			int x = 0.0f, y = 0.0f;
			
			double percent = (pass+dt)/curMove.time;
			
			bool overange = percent > 1.0f;
			
			switch (curMove.move) {
				case UIAnimationMoveNone:
				{
					x = overange ? curMove.toPosition.x : curMove.fromPosition.x + (curMove.toPosition.x-curMove.fromPosition.x)*percent;
					
					y = overange ? curMove.toPosition.y : curMove.fromPosition.y + (curMove.toPosition.y-curMove.fromPosition.y)*percent;
				}
					break;
				case UIAnimationMoveRightToLeftReverse:
				{
					x = overange ? orginScrRect.origin.x : orginScrRect.origin.x-range.width*(1.0f-percent);
					
					y = orginScrRect.origin.y;
				}
					break;
				case UIAnimationMoveRightToLeft:
				{
					x = overange ? orginScrRect.origin.x-range.width  : orginScrRect.origin.x-range.width*percent;
					
					y = orginScrRect.origin.y;
				}
					break;
				case UIAnimationMoveLeftToRightReverse:
				{
					x = overange ? orginScrRect.origin.x : orginScrRect.origin.x+range.width*(1.0f-percent);
					
					y = orginScrRect.origin.y;
				}
					break;
				case UIAnimationMoveLeftToRight:
				{
					x = overange ? orginScrRect.origin.x+range.width  : orginScrRect.origin.x+range.width*percent;
					
					y = orginScrRect.origin.y;
				}
					break;
				case UIAnimationMoveTopToBottom:
				{
					x = orginScrRect.origin.x;
					
					y = overange ? orginScrRect.origin.y+range.height: orginScrRect.origin.y+range.height*percent;
				}
					break;
				case UIAnimationMoveTopToBottomReverse:
				{
					x = orginScrRect.origin.x;
					
					y = overange ? orginScrRect.origin.y : orginScrRect.origin.y+range.height*(1.0f-percent);
				}
					break;
				default:
					break;
			}
			
			if (node) node->SetFrameRect(CGRectMake(x, y, orginScrRect.size.width, orginScrRect.size.height));
			
			if (overange) 
			{
				pass = 0.0f;
				return sequence.GetAnimation(curMove);
			}
			else
			{
				pass += dt;
			}
			
			return true;
		}
	}UIAnimationInfo;
	
	typedef std::map<unsigned int, UIAnimationInfo*> datamap;
	
	typedef datamap::iterator datamap_it;
	
	typedef std::pair<unsigned int, UIAnimationInfo*> datamap_pair;
	
	NDTimer timer;
	
	CIDFactory m_idFactory;
	
	datamap m_data;
	datamap m_dataRun;
	
	double m_doubleTimeStamp;
};

#endif // _ND_UI_ANIMATION_H_