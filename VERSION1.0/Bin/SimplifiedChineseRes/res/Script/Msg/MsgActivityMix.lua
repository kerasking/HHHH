---------------------------------------------------
--描述: 处理活动相关消息
--时间: 2012.3.23
--作者: cl
---------------------------------------------------

MsgActivityMix = {}
local p = MsgActivityMix;

p.giftBackList = {};

--获得礼包列表
function p.GetGiftBackLists()
    return p.giftBackList;
end

function p.ProcessActivityMixInfo(netdatas)
	local count=netdatas:ReadByte();
	
	if not IsUIShow(NMAINSCENECHILDTAG.ActivityMix) then
		Activity_MixUI.LoadUI();
	end
	
	for i=1,count do
		local id=netdatas:ReadInt();
		local type=netdatas:ReadByte();
		local param=netdatas:ReadInt();
		local status=netdatas:ReadByte();
		local isAgent=netdatas:ReadByte();
		
		LogInfo("in MSG: isAgent= " .. isAgent)
		Activity_MixUI.AddActivity(id,type,param,status,isAgent);
	end
end

function p.DelGiftById(id)
    if(not CheckN(id)) then
        LogInfo("p.delGiftById param error!");
        return;
    end
    for i=1,#p.giftBackList do
        local gift = p.giftBackList[i];
        if(gift.id == id) then
            LogInfo("delete gift id:[%d]",id);
            table.remove(p.giftBackList,i);
            return true;
        end
    end
    return false;
end

function p.ProcessGetGift(netdatas)
	local id=netdatas:ReadInt();
	LogInfo("Get_Gift success!");
    
    if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_GET_GIFTPACK, id);
	end
    
    MainUI.RefreshFuncIsOpen();
    
    CloseLoadBar();
end

function p.SendGetGift(id)
	local netdata = createNDTransData(NMSG_Type._MSG_GET_GIFTPACK);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	SendMsg(netdata);
	netdata:Free();
end

function p.ProcessGiftPackList(netdatas)
    local m = {};
	local count = netdatas:ReadByte();
	LogInfo("gift count:%d",count);
	for i=1,count do
        m[i] = {};
		m[i].id=netdatas:ReadInt();
		m[i].type=netdatas:ReadInt();
		m[i].param0=netdatas:ReadInt();
		m[i].param1=netdatas:ReadInt();
		m[i].aux_param0=netdatas:ReadInt();
		m[i].aux_param1=netdatas:ReadInt();
		m[i].gift_desc=netdatas:ReadUnicodeString();
		LogInfo("GIFT id=%d,type=%d,des=%s",m[i].id,m[i].type,m[i].gift_desc);
	end
	p.giftBackList = m;
    if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_GIFTPACK_LIST, m);
	end
    
    MainUI.RefreshFuncIsOpen();
    
    CloseLoadBar();
end

function p.SendOpenDailyActivity()
	local netdata = createNDTransData(NMSG_Type._MSG_DAILY_ACTIVITY_LIST);
	if nil == netdata then
		return false;
	end
	SendMsg(netdata);
	netdata:Free();
end


function p.SendStartBossFight(id)
	local netdata = createNDTransData(NMSG_Type._MSG_START_BOSS_BATTLE); 
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	SendMsg(netdata);
	netdata:Free();
end

--客户端发送使用替身娃娃消息
function p.SendStartUseScapegoat(activityId)
LogInfo("in p.SendStartUseScapegoat")
	local netdata = createNDTransData(NMSG_Type._MSG_USE_SCAPEGOAT_INFO);
	if nil == netdata then
		return;
	end
	LogInfo("in UseScapegoat fun, activityId= " .. activityId);
	netdata:WriteInt(activityId);
	SendMsg(netdata);
	netdata:Free();
	ShowLoadBar();
end

--客户端发送取消替身娃娃消息
function p.SendCancelUseScapegoat(activity_id)
	local netdata = createNDTransData(NMSG_Type._MSG_CANCLE_SCAPEGOAT_INFO);
	if nil == netdata then
		LogInfo("nil == netdata")
		return;
	end
	LogInfo("in CancelUseScapegoat fun, activity_id= " .. activity_id);
	netdata:WriteInt(activity_id);
	SendMsg(netdata);
	netdata:Free();
	ShowLoadBar();
end

--服务端下发使用替身娃娃消息
function p.ProcessStartUseScapegoatInfo(netdatas)
	CloseLoadBar();
	LogInfo("in p.ProcessStartUseScapegoatInfo fun");
	if nil == netdatas then
		LogInfo("netdatas == nil")
		return;
	end
	local activityId = netdatas:ReadInt();
	LogInfo("in ScapegoatInfo fun, activityId= " .. activityId);
	Activity_MixUI.SetScapegoatBabyControlName(activityId);
end

--服务端下发取消替身娃娃消息
function p.ProcessCancelUseScapegoatInfo(netdatas)
	CloseLoadBar();
	LogInfo("in p.ProcessCancelUseScapegoatInfo fun");
	if nil == netdatas then
		LogInfo("netdatas == nil")
		return;
	end
	local activityId = netdatas:ReadInt();
	Activity_MixUI.SetScapegoatBabyControlName(activityId);
end

RegisterNetMsgHandler(NMSG_Type._MSG_GET_GIFTPACK, "p.ProcessGetGift", p.ProcessGetGift);
RegisterNetMsgHandler(NMSG_Type._MSG_DAILY_ACTIVITY_LIST, "p.ProcessActivityMixInfo", p.ProcessActivityMixInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_GIFTPACK_LIST, "p.ProcessGiftPackList", p.ProcessGiftPackList);
RegisterNetMsgHandler(NMSG_Type._MSG_USE_SCAPEGOAT_INFO, "p.ProcessStartUseScapegoatInfo", p.ProcessStartUseScapegoatInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_CANCLE_SCAPEGOAT_INFO, "p.ProcessCancelUseScapegoatInfo", p.ProcessCancelUseScapegoatInfo);

