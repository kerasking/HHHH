---------------------------------------------------
--描述: 处理装备强化相关消息
--时间: 2012.4.9
--作者: fyl
---------------------------------------------------

MsgEquipStr = {}
local p = MsgEquipStr;

local MSG_EQUIP_IM_QUALITY         = 0;
local MSG_EQUIP_IM_QUALITY_FALSE   = 1;
local MSG_EQUIP_IM_ENHANCE         = 2;
local MSG_EQUIP_IM_ENHANCE_FALSE   = 3;
local MSG_EQUIP_IM_ADD_HOLE        = 4;
local MSG_EQUIP_IM_QUALITY_DISTROY = 5;
local MSG_EQUIP_IM_UPLEV           = 6;
local MSG_EQUIP_IM_CLEAR           = 7;

local EQUIP_MSG_CLEAR_UPGRADE_TIME   = 1;   --消除强化冷却时间
local EQUIP_MSG_ELIMINATE_UPGRADE_CD = 2;   --消除强化CD
local EQUIP_MSG_ADD_UPGRADE_QUEUE    = 3;   --增加强化队列


p.mUIListener = nil;

function p.ProcessEquipStrInfo(netdatas)
	local nAction = netdatas:ReadByte();
	local nEquipId = netdatas:ReadInt();
	local nStuffId = netdatas:ReadInt();    --0无暴击 1有暴击
	
	if CheckN(nAction) and CheckN(nEquipId) then
	    LogInfo("Recv equipId[%d] actionId[%d]", nEquipId, nAction);  
	end	
    
    nStuffId = Item.GetItemInfoN(nEquipId, Item.ITEM_ADDITION);
    --Item.SetItemInfoN(nEquipId, Item.ITEM_ADDITION, nStuffId);
    
    
    local m = {};
    m.EquipId = nEquipId;
    m.StuffId = nStuffId;
    
    CloseLoadBar();
	if nAction == MSG_EQUIP_IM_ENHANCE then
        if p.mUIListener then
            p.mUIListener( NMSG_Type._MSG_EQUIPSTR_INFO, m);
        end
	end	
end

function p.ProcessEquipStrUpdate(netdatas)
	local nAction = netdatas:ReadByte();
	local nParam = netdatas:ReadByte();
	
	if not CheckN(nAction) or
	   not CheckN(nParam)      then
	    LogInfo("收到的参数有误")
		return;
	end		
	
	LogInfo("Recv nParam[%d] actionId[%d]", nParam, nAction);		
	
	if nAction == EQUIP_MSG_ADD_UPGRADE_QUEUE then
       --LogInfo("响应增加队列");
	   CloseLoadBar();
    elseif nAction == EQUIP_MSG_ELIMINATE_UPGRADE_CD then
        --响应消除强化CD
        CloseLoadBar();
	elseif nAction == EQUIP_MSG_CLEAR_UPGRADE_TIME then
        --响应消除强化冷却时间
        CloseLoadBar();
	end	
    
    if p.mUIListener then
        LogInfo("p.mUIListenertest");
        p.mUIListener( NMSG_Type._MSG_EQUIPSTR_UPDATE, nAction);
    end
end


--增加强化队列
function p.SendAddEquipStrQueneAction()
    p.SendUpdateAction(EQUIP_MSG_ADD_UPGRADE_QUEUE,0);
end

--消除强化CD
function p.SendEliminateUpdateCDAction()
    p.SendUpdateAction(EQUIP_MSG_ELIMINATE_UPGRADE_CD,0);
end

--消除强化冷却时间
function p.SendClearStrQueneTimeAction(queneNum)
	if	not CheckN(queneNum) then
		LogInfo("发送装备强化队列冷却消息失败,参数不对");
		return false;
	end

    p.SendUpdateAction(EQUIP_MSG_CLEAR_UPGRADE_TIME,queneNum);
end



function p.SendUpdateAction(nAction,nParam)
    local netdata = createNDTransData(NMSG_Type._MSG_EQUIPSTR_UPDATE);
	if nil == netdata then
		LogInfo("发送物品消息失败,内存不够");
		return false;
	end
	netdata:WriteByte(nAction);
	netdata:WriteByte(nParam);
	SendMsg(netdata);	
	netdata:Free();		
	
	LogInfo("send nParam[%d] actionId[%d]", nParam, nAction);
    ShowLoadBar();

	return true;
end

--强化
function p.SendEquipStrAction(nEquipId,nQueue)
  p.SendAction(nEquipId, MSG_EQUIP_IM_ENHANCE,nQueue);
end

function p.SendAction(nEquipId, nAction,nQueue)
	if	not CheckN(nEquipId) or
		not CheckN(nAction) then
		LogInfo("发送装备强化消息失败,参数不对");
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_EQUIPSTR_INFO);
	if nil == netdata then
		LogInfo("发送物品消息失败,内存不够");
		return false;
	end
	netdata:WriteByte(nAction);
	netdata:WriteInt(nEquipId);
	netdata:WriteInt(nQueue);
	SendMsg(netdata);
	netdata:Free();	
	
	LogInfo("send equipId[%d] actionId[%d] nQueue[%d]", nEquipId, nAction,nQueue);
    ShowLoadBar();

	return true;
end

--洗炼
function p.SendEdu(nEquipId, nEduType)
	if	not CheckN(nEquipId) or
		not CheckN(nEduType) then
		LogInfo("发送装备洗练消息失败,参数不对");
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_TRY_EQUIP_EDU);
	if nil == netdata then
		LogInfo("发送物品消息失败,内存不够");
		return false;
	end
	
	netdata:WriteInt(nEquipId);
	netdata:WriteByte(nEduType);
    
	SendMsg(netdata);
	netdata:Free();	
	
	LogInfo("send nEquipId[%d] nEduType[%d]", nEquipId, nEduType);
    ShowLoadBar();
	return true;
end

--接收洗炼信息
function p.RevSendEduResult(netdatas)
    local m = {};
    m.Attr = {};
    
	m.Equip  = netdatas:ReadInt();
    table.insert(m.Attr, netdatas:ReadInt());
    table.insert(m.Attr, netdatas:ReadInt());
    table.insert(m.Attr, netdatas:ReadInt());
    
    LogInfo("p.RevSendEduResult m.Equip:[%d]",m.Equip);
    if p.mUIListener then
        p.mUIListener( NMSG_Type._MSG_EQUIP_EDU_INFO, m);
    end
    
    CloseLoadBar();
    return true;
end


--确认洗炼
function p.SendConfirmEdu(nEquipId)
	if	not CheckN(nEquipId)then
		LogInfo("发送装备确认洗练消息失败,参数不对");
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_CONFIRM_EQUIP_EDU);
	if nil == netdata then
		LogInfo("发送物品消息失败,内存不够");
		return false;
	end
	
	netdata:WriteInt(nEquipId);
    
	SendMsg(netdata);
	netdata:Free();	
	
	LogInfo("send nEquipId[%d]", nEquipId);
    ShowLoadBar();
	return true;
end

function p.RevSendConfirmEduResult(netdatas)
    LogInfo("p.RevSendConfirmEduResult replace success!");
    local m = {};
    m.EquipId = netdatas:ReadInt();
    if p.mUIListener then
        p.mUIListener( NMSG_Type._MSG_CONFIRM_EQUIP_EDU,m);
    end
end


RegisterNetMsgHandler(NMSG_Type._MSG_EQUIPSTR_INFO, "p.ProcessEquipStrInfo", p.ProcessEquipStrInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_EQUIPSTR_UPDATE, "p.ProcessEquipStrUpdate", p.ProcessEquipStrUpdate);
RegisterNetMsgHandler(NMSG_Type._MSG_EQUIP_EDU_INFO, "p.RevSendEduResult", p.RevSendEduResult);
RegisterNetMsgHandler(NMSG_Type._MSG_CONFIRM_EQUIP_EDU, "p.RevSendConfirmEduResult", p.RevSendConfirmEduResult);