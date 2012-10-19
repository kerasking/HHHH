//
//  NDNode.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-7.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDNode.h"
#include "NDBaseNode.h"
#include <cocos2d.h>
#include "CCPointExtension.h"

using namespace cocos2d;

namespace NDEngine
{
IMPLEMENT_CLASS(NDNode, NDCommonProtocol)

NDNode::NDNode():
m_nPosx(-1),
m_nPosy(-1)
{
	m_pkParent = NULL;
	m_ccNode = NULL;
	m_bDrawEnabled = true;
	m_nParam1 = 0;
	m_nParam2 = 0;
}

NDNode::~NDNode()
{
	this->RemoveAllChildren(true);
	if (m_pkParent)
	{
		this->RemoveFromParent(false);
	}
	CC_SAFE_RELEASE (m_ccNode);
}

NDNode* NDNode::Node()
{
	NDNode* node = new NDNode();
	node->Initialization();
	return node;
}

void NDNode::Initialization()
{
	NDAsssert(m_ccNode == NULL);

	m_ccNode = new NDBaseNode();
	NDBaseNode *ndBaseNode = (NDBaseNode *) m_ccNode;
	ndBaseNode->setNDNode(this);
}

void NDNode::draw()
{
}

NDNode* NDNode::GetParent()
{
	return m_pkParent;
}

void NDNode::SetParent(NDNode* node)
{
	m_pkParent = node;
}

const std::vector<NDNode*>& NDNode::GetChildren()
{
	return m_kChildrenList;
}

void NDNode::RemoveAllChildren(bool bCleanUp)
{
	NDAsssert(m_ccNode != NULL);

	while (m_kChildrenList.begin() != m_kChildrenList.end())
	{
		NDNode* node = (NDNode*) m_kChildrenList.back();

		LuaObject funcObj;

		if (node && node->GetDestroyNotify(funcObj) || funcObj.IsFunction())
		{
			LuaFunction<void> luaDestroyEventCallBack = funcObj;
			luaDestroyEventCallBack(node, bCleanUp);
		}

		NDNodeDelegate* delegate =
				dynamic_cast<NDNodeDelegate*>(node->GetDelegate());

		if (delegate)
		{
			delegate->OnBeforeNodeRemoveFromParent(node, bCleanUp);
		}

		m_kChildrenList.pop_back();
		node->SetParent(NULL);

		if (delegate)
		{
			delegate->OnAfterNodeRemoveFromParent(node, bCleanUp);
		}

		CCNode *ccNode = node->m_ccNode;
		m_ccNode->removeChild(ccNode, bCleanUp);

		if (bCleanUp)
		{
			delete node;
		}
	}
}

CGSize NDNode::GetContentSize()
{
	NDAsssert(m_ccNode != NULL);

	return m_ccNode->getContentSize();
}

void NDNode::SetContentSize(CGSize size)
{
	NDAsssert(m_ccNode != NULL);

	m_ccNode->setContentSize(size);
}

int NDNode::GetzOrder()
{
	NDAsssert(m_ccNode != NULL);

	return m_ccNode->getZOrder();
}

int NDNode::GetTag()
{
	NDAsssert(m_ccNode != NULL);

	return m_ccNode->getTag();
}

void NDNode::SetTag(int tag)
{
	NDAsssert(m_ccNode != NULL);

	m_ccNode->setTag(tag);
}

void NDNode::AddChild(NDNode* node)
{
	const char* pszTemp = GetRuntimeClass()->className;

	CCNode *ccNode = node->m_ccNode;
	int z = ccNode->getZOrder();
	int tag = ccNode->getTag();

	this->AddChild(node, z, tag);
}

void NDNode::AddChild(NDNode* node, int z)
{
	CCNode *ccNode = node->m_ccNode;
	int tag = ccNode->getTag();

	this->AddChild(node, z, tag);
}

void NDNode::AddChild(NDNode* node, int z, int tag)
{
	NDAsssert(m_ccNode != NULL && node != NULL && node->m_ccNode != NULL);
	NDAsssert(node != this);

	CCNode* pkNode = node->m_ccNode;

	node->SetParent(this);

	m_ccNode->addChild(pkNode, z, tag);

	m_kChildrenList.push_back(node);
}

void NDNode::RemoveChild(NDNode* node, bool bCleanUp)
{
	NDAsssert(m_ccNode != NULL && node != NULL && node->m_ccNode != NULL);

	std::vector<NDNode*>::iterator iter = m_kChildrenList.begin();
	for (; iter != this->m_kChildrenList.end(); iter++)
	{
		NDNode* ndNode = (NDNode*) *iter;
		if (ndNode->m_ccNode == node->m_ccNode)
		{
			LuaObject funcObj;

			if (ndNode && ndNode->GetDestroyNotify(funcObj)
					|| funcObj.IsFunction())
			{
				LuaFunction<void> luaDestroyEventCallBack = funcObj;
				luaDestroyEventCallBack(ndNode, bCleanUp);
			}

			NDNodeDelegate* delegate =
					dynamic_cast<NDNodeDelegate*>(ndNode->GetDelegate());

			if (delegate)
			{
				delegate->OnBeforeNodeRemoveFromParent(ndNode, bCleanUp);
			}

			m_kChildrenList.erase(iter);
			ndNode->SetParent(NULL);

			if (delegate)
			{
				delegate->OnAfterNodeRemoveFromParent(ndNode, bCleanUp);
			}

			CCNode *ccNode = ndNode->m_ccNode;
			m_ccNode->removeChild(ccNode, bCleanUp);

			if (bCleanUp)
			{
				delete ndNode;
			}

			break;
		}
	}
}

void NDNode::RemoveChild(int tag, bool bCleanUp)
{
	NDAsssert(m_ccNode != NULL);

	std::vector<NDNode*>::iterator iter;
	for (iter = m_kChildrenList.begin(); iter != m_kChildrenList.end();
			iter++)
	{
		NDNode* node = (NDNode*) *iter;
		if (node->m_ccNode->getTag() == tag)
		{
			LuaObject funcObj;

			if (node->GetDestroyNotify(funcObj) || funcObj.IsFunction())
			{
				LuaFunction<void> luaDestroyEventCallBack = funcObj;
				luaDestroyEventCallBack(node, bCleanUp);
			}

			NDNodeDelegate* delegate =
					dynamic_cast<NDNodeDelegate*>(node->GetDelegate());

			if (delegate)
			{
				delegate->OnBeforeNodeRemoveFromParent(node, bCleanUp);
			}

			m_kChildrenList.erase(iter);
			node->SetParent(NULL);

			if (delegate)
			{
				delegate->OnAfterNodeRemoveFromParent(node, bCleanUp);
			}

			m_ccNode->removeChildByTag(tag, bCleanUp);

			if (bCleanUp)
			{
				delete node;
			}

			break;
		}
	}
}

void NDNode::RemoveFromParent(bool bCleanUp)
{
	NDAsssert(this->m_ccNode != NULL);

	if (this->m_pkParent)
	{
		m_pkParent->RemoveChild(this, bCleanUp);
	}
}

bool NDNode::ContainChild(NDNode* node)
{
	NDAsssert(m_ccNode != NULL && node != NULL && node->m_ccNode != NULL);

	std::vector<NDNode*>::iterator iter;
	for (iter = m_kChildrenList.begin(); iter != m_kChildrenList.end();
			iter++)
	{
		NDNode* ndNode = (NDNode*) *iter;
		if (ndNode == node)
		{
			return true;
		}
	}

	return false;
}

NDNode* NDNode::GetChild(int tag)
{
	std::vector<NDNode*>::iterator iter;
	for (iter = m_kChildrenList.begin(); iter != m_kChildrenList.end();
			iter++)
	{
		NDNode* pkNode = (NDNode*) *iter;
		if (pkNode->m_ccNode->getTag() == tag)
		{
			return pkNode;
		}
	}
	return NULL;
}

bool NDNode::IsChildOf(NDNode* node)
{
	NDNode* pNode = this->GetParent();
	while (pNode)
	{
		if (pNode == node)
		{
			return true;
		}
		pNode = pNode->GetParent();
	}
	return false;
}

void NDNode::EnableDraw(bool enabled)
{
	m_bDrawEnabled = enabled;

	std::vector<NDNode*>::iterator iter;
	for (iter = m_kChildrenList.begin();
		iter != m_kChildrenList.end();iter++)
	{
		NDNode* node = (NDNode*) *iter;
		node->EnableDraw(m_bDrawEnabled);
	}
}

bool NDNode::DrawEnabled()
{
	return m_bDrawEnabled;
}

void NDNode::SetParam1(int nParam1)
{
	m_nParam1 = nParam1;
}

void NDNode::SetParam2(int nParam2)
{
	m_nParam2 = nParam2;
}

int NDNode::GetParam1()
{
	return m_nParam1;
}

int NDNode::GetParam2()
{
	return m_nParam2;
}

void NDNode::SetDestroyNotify(LuaObject func)
{
	m_kDelegateDestroy = func;
}

bool NDNode::GetDestroyNotify(LuaObject& func)
{
	if (!m_kDelegateDestroy.IsFunction())
	{
		return false;
	}

	func = m_kDelegateDestroy;

	return true;
}

void NDNode::AddViewer(NDCommonProtocol* viewer)
{
	this->RemoveViewer(viewer);

	if (NULL == viewer || viewer == this)
	{
		return;
	}

	m_listCommonViewer.push_back(viewer->QueryProtocolLink());
}

void NDNode::RemoveViewer(NDCommonProtocol* viewer)
{
	LIST_COMMON_VIEWER_IT it = m_listCommonViewer.begin();

	while (it != m_listCommonViewer.end())
	{
		NDCommonProtocol* p = (*it).Pointer();

		if (!(!p || p == viewer))
		{
			it++;
			continue;
		}

		it = m_listCommonViewer.erase(it);
	}
}

bool NDNode::DispatchClickOfViewr(NDObject* object)
{
	bool bDeal = false;
	LIST_COMMON_VIEWER_IT it = m_listCommonViewer.begin();
	for (; it != m_listCommonViewer.end(); it++)
	{
		NDCommonProtocol* p = (*it).Pointer();

		if (!p || this == p)
		{
			continue;
		}

		p->OnClick(object);

		bDeal = true;
	}

	return bDeal;
}

}