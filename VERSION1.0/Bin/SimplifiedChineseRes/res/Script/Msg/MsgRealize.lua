---------------------------------------------------
--描述: 网络消息处理(悟道)消息处理及其逻辑
--时间: 2012.3.10
--作者: wjl
---------------------------------------------------

MsgRealize = {}
local p = MsgRealize;
local _G = _G;

p.mUIListener = nil;
p.mIdList = nil;
p.mNpcList = nil;
p.nQmdjCount = 0;--召唤次数
p.nFreeCount = 0;--免费占星次数
--=====逻辑

p.bAutoDestiny  = false;
p.nKeepDestiny  = nil;  --3蓝 4紫 5金 nil不保留

function p.EnableAutoDestiny()
    p.bAutoDestiny = true;
end

function p.CloseAutoDestiny()
    p.bAutoDestiny = false;
    p.NoKeep();
    DestinyFeteUI.SetBtnStatus(false);
end

function p.KeepBlue()
    p.nKeepDestiny = 3;
end

function p.KeepPurple()
    p.nKeepDestiny = 4;
end

function p.KeepGold()
    p.nKeepDestiny = 5;
end

function p.NoKeep()
    p.nKeepDestiny = nil;
end

--获得召唤奇门遁甲次数
function p.GetQmdjCount()
    return p.nQmdjCount;
end

function p.GetFreeCount()
    return p.nFreeCount;
end


function p.getRealizeIdList()
	if (p.mIdList) then
		return p.mIdList;
	else 
		return {};
	end
end

function p.getNpcIdList()
	if (p.mNpcList) then
		return p.mNpcList;
	else 
		return {};
	end
end


--=====网络
--==悟道购买

--合成
function p.sendRealizeMerge(id, id2)
	if not CheckN(id) then
		return false;
	end
	
	if not CheckN(id2) then
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_MERGE);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	netdata:WriteInt(id2);
	
	SendMsg(netdata);
	
	netdata:Free();
    
    p.nIsStopRefreshBag = false;
	
	LogInfo("send id[%d],id2[%d] ", id,id2);
	return true;
end

function p.processRealizeMerge(netdata)
	
	local id	= netdata:ReadInt();
	LogInfo("process 4516 id:%d", id)
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_REALIZE_MERGE, id);
	end
    CloseLoadBar();
end

p.nCurrPetId = nil;

--打开占星
function p.sendRealizeOp( nCurrPetId )
    --stage限制判断
    if not MainUIBottomSpeedBar.GetFuncIsOpen(129) then
        CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("DU_T16")));
        return false;
    end
    
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_OP);
	if nil == netdata then
		return false;
	end
	ShowLoadBar();
	SendMsg(netdata);
	netdata:Free();
    
    p.nCurrPetId = nCurrPetId;
    
	return true;
end

function p.processRealizeOp(netdata)
    LogInfo("p.processRealizeOp");
    
    local nQmdjCount = netdata:ReadInt();
    local nFreeCount = netdata:ReadInt();
    p.nQmdjCount = nQmdjCount;
    p.nFreeCount = nFreeCount;
    LogInfo("nQmdjCount:[%d],nFreeCount:[%d]",nQmdjCount,nFreeCount);
    
    DestinyFeteUI.LoadUI(p.nCurrPetId);
    DestinyUI.Close();
    CloseLoadBar();
end

--获得占星NPC列表
function p.processRealizeOpen(netdata)
	local count = netdata:ReadByte();
	LogInfo("process 4517 count:%d", count);
	local lst = {};
	for i = 1, count do
		lst[i] = netdata:ReadByte();
		LogInfo("process 4517 id:%d", lst[i]);
	end
	p.mNpcList = lst;
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_REALIZE_OPEN, lst);
	end
end

function p.sendCallQmdj()
    local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_QMDJ);
	if nil == netdata then
		return false;
	end
	
	SendMsg(netdata);
	netdata:Free();
	return true;
end

--悟道
function p.sendRealizeBuy(id)
	if not CheckN(id) then
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_BUY);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send 4518 id[%d] ", id);
	return true;
end

function p.processRealizeBuy(netdata)
		local id	= netdata:ReadInt();
	LogInfo("process 4518 id:%d", id)
	
	if (not p.mIdList) then
		p.mIdList = {};
	end
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_REALIZE_BUY, id);
	end
end

--一键悟道
function p.sendRealizeBuyALL()

    if(p.IsAutoDestiny()) then
        --判断银币
        local nmoney = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_MONEY);
        if(nmoney<60000) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T31"));
            p.CloseAutoDestiny();
            return;
        end
    end
    
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_BUY_ALL);
	if nil == netdata then
		return false;
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send 4534 ");
	return true;
end

function p.processRealizeBuyALL(netdata)
    local count = netdata:ReadByte();
    local lst = {};
	for i = 1, count do
		lst[i] = netdata:ReadInt();
	end
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_REALIZE_BUY_ALL, lst);
	end
    
    if(p.IsAutoDestiny()) then
        p.sendPickUpAll();
    end
end

-- 悟道List
function p.processRealizeList(netdata)
	local count = netdata:ReadByte();
	LogInfo("process 4529 count:%d", count);
	local lst = {};
	for i = 1, count do
		lst[i] = netdata:ReadInt();
		LogInfo("process 4529 id:%d", lst[i]);
	end
	p.mIdList = lst;
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_REALIZE_LIST, lst);
	end
end

-- 卖出
function p.sendSale(id)
	if not CheckN(id) then
		return false;
	end
	
	
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_SALE);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send 4530 id[%d] ", id);
	return true;
end

-- 一键卖出
function p.sendSaleAll()
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_SALE_ALL);
	if nil == netdata then
		return false;
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send 4532 ");
	return true;
end

--拾起
function p.sendPickUp(nIndex)
    if not CheckN(nIndex) then
		return false;
	end
	
	
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_PICKUP);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(nIndex);
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send 4536 nIndex[%d] ", nIndex);
	return true;
end


-- 一键拾起
function p.sendPickUpAll()
    if(p.IsAutoDestiny()) then
        --背包容量判断
        if(ItemFunc.IsDestinyBagFull()) then
            p.CloseAutoDestiny();
            return;
        end
    end

	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_PICKUP_ALL);
	if nil == netdata then
		return false;
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send 4531 ");
	return true;
end

--是否停止背包刷新
p.nIsStopRefreshBag = false;

--一键合成
function p.sendMergeAll()
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_MERGE_ALL);
	if nil == netdata then
		return false;
	end
    
    if(p.IsAutoDestiny()) then
        netdata:WriteByte(2);
        netdata:WriteByte(p.nKeepDestiny);
    else
        netdata:WriteByte(1);
    end
    
	SendMsg(netdata);
	
	netdata:Free();
    
    p.nIsStopRefreshBag = true;
	
	LogInfo("send 4533 ");
	return true;
end

function p.processRealizeMergeAll(netdata)
	local id	= netdata:ReadInt();
	LogInfo("process 4533 id:%d", id)
	
	if (not p.mIdList) then
		p.mIdList = {};
	end
	p.mIdList[#p.mIdList + 1] = id;
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_REALIZE_MERGE_ALL, id);
	end
    LogInfo("p.processRealizeMergeAll");
    p.nIsStopRefreshBag = false;
    DestinyUI.RefreshGoods();
    CloseLoadBar();
    
    if(p.IsAutoDestiny()) then
        p.sendRealizeBuyALL();
    end
end


function p.processRealizePickUpAll()
    LogInfo("p.processRealizePickUpAll");
    if(p.IsAutoDestiny()) then
        p.sendMergeAll();
    end
end

function p.IsAutoDestiny()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DestinyFeteUI);
    if(p.bAutoDestiny and layer) then
        return true;
    end
    p.CloseAutoDestiny();
    return false;
end


--======消息注册
--==悟道购买
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_MERGE, "p.processRealizeMerge", p.processRealizeMerge);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_OPEN, "p.processRealizeOpen", p.processRealizeOpen);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_BUY, "p.processRealizeBuy", p.processRealizeBuy);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_LIST, "p.processRealizeList", p.processRealizeList);
--RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_SALE, "p.processRealizeSale", p.processRealizeSale);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_PICKUP_ALL, "p.processRealizePickUpAll", p.processRealizePickUpAll);
--RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_SALE_ALL, "p.processRealizeSaleAll", p.processRealizeSaleAll);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_MERGE_ALL, "p.processRealizeMergeAll", p.processRealizeMergeAll);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_BUY_ALL, "p.processRealizeBuyALL", p.processRealizeBuyALL);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_OP, "p.processRealizeOp", p.processRealizeOp);



	
	