---------------------------------------------------
--描述: 处理活动相关消息
--时间: 2012.3.23
--作者: cl
---------------------------------------------------

MsgActivityMix = {}
local p = MsgActivityMix;


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
		
		Activity_MixUI.AddActivity(id,type,param,status,isAgent);
	end
end


function p.ProcessGetGift(netdatas)
	local id=netdatas:ReadInt();
	LogInfo("Get_Gift");
	TopActivitySpeedBar.GetGift(id,type);
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
	local count = netdatas:ReadByte();
	
	for i=1,count do
		local id=netdatas:ReadInt();
		local type=netdatas:ReadInt();
		local param0=netdatas:ReadInt();
		local param1=netdatas:ReadInt();
		local aux_param0=netdatas:ReadInt();
		local aux_param1=netdatas:ReadInt();
		LogInfo("GIFT id=%d,type=%d",id,type);
		TopActivitySpeedBar.AddGift(id,type,param0,param1,aux_param0,aux_param1);
	end
	
	
	if IsUIShow(NMAINSCENECHILDTAG.TopSpeedBar) then
		TopActivitySpeedBar.CleanScroll();
		TopActivitySpeedBar.refreshBtns();
	end
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

RegisterNetMsgHandler(NMSG_Type._MSG_GET_GIFTPACK, "p.ProcessGetGift", p.ProcessGetGift);
RegisterNetMsgHandler(NMSG_Type._MSG_DAILY_ACTIVITY_LIST, "p.ProcessActivityMixInfo", p.ProcessActivityMixInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_GIFTPACK_LIST, "p.ProcessGiftPackList", p.ProcessGiftPackList);