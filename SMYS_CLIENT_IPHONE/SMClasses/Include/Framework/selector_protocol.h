/*
动作回调接口类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
*/
#ifndef __COCOA_SELECTOR_PROTOCOL_H__
#define __COCOA_SELECTOR_PROTOCOL_H__

#include "IActionDelegate.h"
#include "cTypes.h"

//动作回调接口类(注意:多继承自该类时,必须将此类写在前面,如class CTestSel :public SelectorProtocol,public CTest否则使用会不正常!)
class SelectorProtocol
{
public:

    virtual void Callfunc() {};
    virtual void Callfunc(IActionDelegate* pSender)    {}
    virtual void Callfunc(IActionDelegate* pSender, void* pData){}
};


typedef void (SelectorProtocol::*SEL_CallFunc)();//要调用到的执行函数的地址
typedef void (SelectorProtocol::*SEL_CallFuncN)(IActionDelegate*);//IActionDelegate* sender为执行该动作的精灵
typedef void (SelectorProtocol::*SEL_CallFuncND)(IActionDelegate*, void*);//IActionDelegate* sender为执行该动作的精灵

//对应CCallFunc
#define callfunc_selector(sel) (SEL_CallFunc)(&sel)

//对应CCallFuncN
#define callfuncN_selector(sel) (SEL_CallFuncN)(&sel)

//对应CCallFuncND
#define callfuncND_selector(sel) (SEL_CallFuncND)(&sel)

/*在动作中的使用方法:
CSequence::Actions(
					CCallFunc::ActionWithTarget(&m_testSelPro, callfunc_selector(CTestSelPro::testCCCallFunc)),
                        CCallFuncN::ActionWithTarget(this, callfuncN_selector(CTestScene::callback2)),
                        CCallFuncND::ActionWithTarget(this, callfuncND_selector(CTestScene::callback3), (void*)xx),
                        CCallFuncN::ActionWithTarget(this, callfuncN_selector(CTestScene::initBomb)),
                        NULL)
                    );
					
	void CTestScene::testCCCallFunc();
	void CTestScene::callback2(IActionDelegate* sender);//IActionDelegate* sender为执行该动作的精灵
	void CTestScene::callback3(IActionDelegate* sender, void* data)//IActionDelegate* sender为执行该动作的精灵
	{
		printf("callback3 ok,pos=(%d,%d) data=%d!\n",sender->GetPosition().x,sender->GetPosition().y,data);
	}

参考CCCalFunc的使用方法:
	static CCallFunc * ActionWithTarget(SelectorProtocol* pSelectorTarget, SEL_CallFunc selector);
	创建一个执行函数的动作
	pSelectorTarget:要附加到动作的目标(该类必须继承自SelectorProtocol)
	selector:要调用的函数(可以有三种格式:
							1.无参数,
							2.有一个参数:调用该动作的精灵,
							3.有两个参数:调用该动作的精灵,传递任何类型值):
			typedef void (SelectorProtocol::*SEL_CallFunc)();
			typedef void (SelectorProtocol::*SEL_CallFuncN)(IActionDelegate*);
			typedef void (SelectorProtocol::*SEL_CallFuncND)(IActionDelegate*, void*);
	如:class CTestSelPro :	public SelectorProtocol
		void CTestSelPro::testCCCallFunc()
		{
			printf("CTestSelPro::testCCCallFunc ok!\n");
		}
		在CTestScene.cpp里:
		CCallFunc::ActionWithTarget(&m_testSelPro, callfunc_selector(CTestSelPro::testCCCallFunc))
*/
#endif // __COCOA_SELECTOR_PROTOCOL_H__
