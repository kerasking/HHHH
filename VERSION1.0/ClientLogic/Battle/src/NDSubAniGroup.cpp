#include "NDSubAniGroup.h"
#include "NDNode.h"
#include "NDSprite.h"
#include "NDFrame.h"
#include "CCPointExtension.h"
#include "Fighter.h"
#include "GameScene.h"
#include "Battle.h"
///< #include "NDMapMgr.h" 临时性注释 郭浩
#include "NDPath.h"

using namespace NDEngine;

bool DrawSubAnimation(NDNode* layer, NDSubAniGroup& sag)
{
	//NDNode* layer = this->GetParent();
	
	if (!layer)
	{
		return true;
	}
	
	NDFrameRunRecord* record = sag.frameRec;
	
	if (!record) 
	{
		return true;
	}
	
	NDAnimationGroup *aniGroup = sag.aniGroup;
	
	if(!aniGroup) {
		return true;
	}
	
	CGPoint pos = aniGroup->getPosition();
	aniGroup->setRunningMapSize(layer->GetContentSize());
	
	NDAnimation* ani = NULL;
	if (aniGroup->getAnimations()->count() > 0) {
		ani = (NDAnimation*)aniGroup->getAnimations()->objectAtIndex(0);
	}
	
	if (!ani) {
		return true;
	}
	
	CGPoint posTarget = ccp(0, 0);
	if (aniGroup->getType() == SUB_ANI_TYPE_NONE) {
		aniGroup->setReverse(sag.fighter->m_info.group == BATTLE_GROUP_DEFENCE ? false : true);
		int coordx = 0;
		
		if (aniGroup->getReverse()) {// 向右释放技能
			coordx += (240 - (aniGroup->getPosition().x + ani->getW())) * 2;
		}
		
		posTarget.x = pos.x + ani->getW() / 2 + coordx + 20;
		posTarget.y = pos.y + ani->getH() / 2 + 45;
		//aniGroup.draw(g, pos.x + aniGroup.getWidth() / 2 + coordx, pos.y + aniGroup.getHeight() + coordy, 0, 0);
	} else if (aniGroup->getType() == SUB_ANI_TYPE_TARGET || aniGroup->getType() == SUB_ANI_TYPE_SELF) {
		posTarget.x = sag.fighter->getX();
		posTarget.y = sag.fighter->getY();
		//aniGroup.draw(g, sag.fighter.getX(), sag.fighter.getY(), 0, 0);
	}
	
	// 子动画播放位置设置
	aniGroup->setPosition(posTarget);
	
	ani->runWithRunFrameRecord(record,true,1.0f);//layer->getScale());
	
	aniGroup->setPosition(pos);
	
	return record->getCurrentFrameIndex() != 0 && record->getNextFrameIndex() == 0;
}


void AddSubAniGroup(NDSubAniGroupEx& group)
{
	if (group.anifile.empty()) 
	{
		return;
	}
	
	GameScene* scene = (GameScene*)NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
	if (!scene) {
		return;
	}

	/***
	* 临时性注释 郭浩
	* begin
	*/
	
// 	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(scene);
// 	if (!layer)
// 	{
// 		return;
// 	}	

	/***
	* 临时性注释 郭浩
	* end
	*/

	NDLightEffect* lightEffect = new NDLightEffect();
	
	std::string sprFullPath = NDPath::GetAnimationPath();
	sprFullPath.append(group.anifile);
	lightEffect->Initialization(sprFullPath.c_str());
	
	lightEffect->SetLightId(0, false);
	
	if (group.type== SUB_ANI_TYPE_NONE) 
	{
		lightEffect->SetPosition(ccp(group.coordW, group.coordH));
	} else if (group.type == SUB_ANI_TYPE_SELF) {
		lightEffect->SetPosition(ccp(group.coordW+group.x, group.coordH+group.y));
	}
	else if (group.type== SUB_ANI_TYPE_SCREEN_CENTER) 
	{
		//lightEffect->SetPosition(ccpAdd(layer->GetScreenCenter(), ccp(group.coordW, group.coordH))); ///<临时性注释 郭浩
	}

	
//	layer->AddChild(lightEffect); ///< 临时性注释 郭浩
}


void RunBattleSubAnimation(NDSprite* role, Fighter* f)
{
	if (!role) {
		return;
	}
	Battle* battle = BattleMgrObj.GetBattle();
	if (!battle) {
		return;
	}
	
	// 1.获取当前帧
	NDFrame* curFrame = role->GetCurrentFrame();
	
	// 2.取当前帧的子动画数组并加入战斗对象的子动画数组
	if (curFrame && curFrame->getSubAnimationGroups()) {
		for (int i = 0; i < curFrame->getSubAnimationGroups()->count(); i++) {
			NDAnimationGroup *group = curFrame->getSubAnimationGroups()->getObjectAtIndex(i);
			group->setReverse(f->m_info.group == BATTLE_GROUP_DEFENCE ? false : true);
			
			if (group->getIdentifer() == 0) { // 非魔法特效
				if (group->getType() == SUB_ANI_TYPE_SELF || group->getType() == SUB_ANI_TYPE_NONE) {
					battle->addSubAniGroup(role, group, f);
				}
			} else { // 魔法特效
				if (group->getIdentifer() == f->getUseSkill()->getSubAniID()) {
					if (group->getType() == SUB_ANI_TYPE_SELF) {
						battle->addSubAniGroup(role, group, f);
					} else if (group->getType() == SUB_ANI_TYPE_TARGET) {
						
						VEC_FIGHTER& array = f->getArrayTarget();
						if (array.size() == 0) { // 如果没有目标数组，则制定目标为mainTarget
							battle->addSubAniGroup(role, group, f->m_mainTarget);
						} else {
							for (size_t j = 0; j < array.size(); j++) {
								battle->addSubAniGroup(role, group, array.at(j));
							}
						}
					} else if (group->getType() == SUB_ANI_TYPE_NONE) {							
						battle->addSubAniGroup(role, group, f);
					}
				}
			}
		}
	}
}
