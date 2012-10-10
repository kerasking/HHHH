/**
动作管理类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#ifndef __ACTION_CCACTION_MANAGER_H__
#define __ACTION_CCACTION_MANAGER_H__

#include "CAction.h"
#include <vector>
#include "IActionDelegate.h"

using namespace std;
struct _nodeElement;
class  CActionManager 
{
public:
	static CActionManager& sharedInstance();
	/** Adds an action with a target. 
	 If the target is already present, then the action will be added to the existing target.
	 If the target is not present, a new instance of this target will be created either paused or not, and the action will be added to the newly created target.
	 When the target is paused, the queued actions won't be 'ticked'.
	 增加一个动作
	 注意:一个精灵同时AddAction两个动作会同时执行这两个动作
		  一个精灵不要AddAction同一个动作两次,精灵的执行时间可能会变小
	 */
	bool AddAction(CAction *pAction/*所加的动作*/, IActionDelegate *pTarget/*精灵*/,bool bPause=false/*初始是否是暂停*/);

	/** 
	 增加一个动作
	 注意:窗口只支持移动相关的动作。
	 */
	bool AddAction(CAction *pAction/*所加的动作*/, DLG_HANDLE hDlg, bool bPause= false/*初始是否是暂停*/);

    /** Removes all actions from all the targets.
	删除所有的动作
    */
	void RemoveAllActions(void);

    /** Removes all actions from a certain target.
	 All the actions that belongs to the target will be removed.
	 根据精灵或对话框的名字删除它的所有动作,如pTarget为m_mySprite.GetActionDelegate()
	 */
	void RemoveAllActionsFromTarget(IActionDelegate *pTarget);

    /** Removes an action given an action reference.
	根据动作的名字删除一个动作
    */
	void RemoveAction(CAction *pAction);

    /** Removes an action given its tag and the target 
	 根据标签删除一个动作*/
	void RemoveActionByTag(unsigned int tag, IActionDelegate *pTarget);

	/** Gets an action given its tag an a target
	 @return the Action the with the given tag
	 根据标签获得对应的动作
	 */
	CAction* GetActionByTag(unsigned int tag, IActionDelegate *pTarget);

    /** Returns the numbers of actions that are running in a certain target. 
	 * Composable actions are counted as 1 action. Example:
	 * - If you are running 1 Sequence of 7 actions, it will return 1.
	 * - If you are running 7 Sequences of 2 actions, it will return 7.
	 获取精灵当前执行的动作的个数
	 */
	unsigned int NumberOfRunningActionsInTarget(IActionDelegate *pTarget);

    /** Pauses the target: all running actions and newly added actions will be paused
	暂停一个动作
	*/
	void PauseTarget(IActionDelegate *pTarget/*精灵或对话框代理*/);

    /** Resumes the target. All queued actions will be resumed.
	恢复执行一个动作
	*/
	void ResumeTarget(IActionDelegate *pTarget/*精灵或对话框代理*/);

	//动作是否存在动作管理类里
	bool IsActionExist(CAction *pAction/*动作*/);

	//bool addAnimation(CAction *pAction,bool bPause=false);
	//	void RemoveActionByTag(unsigned int tag);

	//检测Sprite删除是否安全
	bool IsSpriteDelSafe(IActionDelegate* pSprite);

	//更新(框架内部调用,外部不要调用)
	void Update(fTime dt);

	 //将被取消，统一用sharedInstance接口。
	friend	CActionManager* GetActionManager(void);
protected:
	CActionManager(void);
	~CActionManager(void);

protected:
	typedef struct CNodeElement
	{
		std::vector<CAction*> arrAction;//某一精灵的所有动作
		IActionDelegate		  *target;//某一精灵
		bool  bPause;
		bool  bDeleted; //default value is false;
	}_nodeElement;

	typedef std::vector<_nodeElement> CNodeElementList;
	CNodeElementList m_listNodeElemnt;//保存了所有的动作和动作的载体(精灵)

	bool				m_bInUpdate;
	CNodeElementList	m_listAdd;
	std::vector<CAction *> m_arrDeleteAction;//动作更新时保存的待删除动作的列表向量
};

//将被取消，统一用sharedInstance接口。
CActionManager* GetActionManager(void);


#endif // __ACTION_CCACTION_MANAGER_H__
