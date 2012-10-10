/*
 *  MsgPaiHang.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "MsgPaiHang.h"
#include "NDMsgDefine.h"

CMsgBillboard::CMsgBillboard()
{
	this->Init();
	m_pInfo = (MSG_Info*)m_bufMsg;
	
	m_pInfo->unMsgType = _MSG_BILLBOARD;
}

CMsgBillboard::~CMsgBillboard()
{
}

//////////////////////////////////////////////////////////////////////////
bool
CMsgBillboard::Append(int id, const string& strName)
{
	//IF_NOT( this->WriteObjToBuf(id) &&
//		   this->WriteStrToBuf(strName.c_str()))
//	{
//		return false;
//	}
//	
//	m_pInfo->unMsgSize = this->GetRealBufSize();
//	m_pInfo->uCount++;
	return true;
}

//////////////////////////////////////////////////////////////////////
bool CMsgBillboard::Create(char* pBuf, unsigned short usBufLen)
{
	if (!CMsgBase::Create(pBuf, usBufLen) || _MSG_BILLBOARD != this->GetType())
	{
		return false;
	}
	
	return true;
}

//////////////////////////////////////////////////////////////////////
void CMsgBillboard::Process	(int idActor)
{
   // DEBUG_TRY
//	
//    if (!idActor)
//        return;
//    
//	int nQueryPage = 0;
//	IF_NOT(this->ReadObjFromBuf(nQueryPage))
//	{
//		return;
//	}
//	
//    CQueryMgr& objMgr = CQueryMgr::GetInstance();
//    
//    objMgr.QueryBillboardList(idActor, m_pInfo->idBillboard, nQueryPage);
//	
//    DEBUG_CATCH2("CMsgBillboard::Process::Actor:%d", idActor);
}