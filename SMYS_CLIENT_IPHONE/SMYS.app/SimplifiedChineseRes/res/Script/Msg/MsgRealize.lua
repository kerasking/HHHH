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

--=====逻辑

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
	
	LogInfo("send id[%d],id2[%d] ", id,id2);
	return true;
end

function p.processRealizeMerge(netdata)
	
	local id	= netdata:ReadInt();
	LogInfo("process 4516 id:%d", id)
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_REALIZE_MERGE, id);
	end
end

--悟道面板
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
	
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_BUY_ALL);
	if nil == netdata then
		return false;
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send 4534 ");
	return true;
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

-- 一键拾起
function p.sendPickUpAll()
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_PICKUP_ALL);
	if nil == netdata then
		return false;
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send 4531 ");
	return true;
end

--一键合成
function p.sendMergeAll(idList)
	if not idList then
		return false;
	end
	
	local lst = {}
	local count = 0;
	for k, v in pairs(idList) do
		count = count + 1;
		lst[count] = v;
	end
	
	if (count == nil or count == 0) then
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_REALIZE_MERGE_ALL);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(count);
	LogInfo("4533 count:%d", count);
	for i= 1, count do
		netdata:WriteInt(lst[i]);
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
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
end

--======消息注册
--==悟道购买
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_MERGE, "p.processRealizeMerge", p.processRealizeMerge);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_OPEN, "p.processRealizeOpen", p.processRealizeOpen);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_BUY, "p.processRealizeBuy", p.processRealizeBuy);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_LIST, "p.processRealizeList", p.processRealizeList);
--RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_SALE, "p.processRealizeSale", p.processRealizeSale);
--RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_PICKUP_ALL, "p.processRealizePickUpAll", p.processRealizePickUpAll);
--RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_SALE_ALL, "p.processRealizeSaleAll", p.processRealizeSaleAll);
RegisterNetMsgHandler(NMSG_Type._MSG_REALIZE_MERGE_ALL, "p.processRealizeMergeAll", p.processRealizeMergeAll);



	
	