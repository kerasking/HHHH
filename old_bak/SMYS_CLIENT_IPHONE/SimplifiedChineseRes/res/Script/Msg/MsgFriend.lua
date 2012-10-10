---------------------------------------------------
--描述: 处理装备强化相关消息
--时间: 2012.4.16
--作者: fyl
---------------------------------------------------

MsgFriend = {}
local p = MsgFriend;

local	_FRIEND_ADD               = 10;		--添加好友
local	_FRIEND_DEL               = 11;	    --删除好友
local	_FRIEND_LIST_INIT         = 12;		--获取好友列表

local   _FRIEND_SEL               = 16;     --查看资料

local	_FRIEND_FLLOWER_GIVE	  = 20;		--赠送鲜花
local	_FRIEND_FLLOWER_OPEN      = 21;		--打开赠送鲜花界面，查看玩家收到的赠送鲜花记录和拥有的鲜花总数
local	_FRIEND_FLLOWER_RANK      = 22;		--查看鲜花榜




local playerId; --打开赠送鲜花界面和查看好友资料,添加/删除好友 需要用到
local playerName = "";
local addFlag = 0;

--打开赠送鲜花界面
function p.SendOpenGiveFlower(nPlayerId,nPlayerName)	
    playerId = nPlayerId;
	playerName = nPlayerName;
	
    local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	if nil == netdata then
		LogInfo("发送打开赠送鲜花界面消息失败,内存不够");
		return false;
	end
	
	netdata:WriteByte(_FRIEND_FLLOWER_OPEN);
	netdata:WriteInt(0);
	
	SendMsg(netdata);	
	netdata:Free();		

    LogInfo("打开赠送鲜花界面,playerId[%d]", nPlayerId);
    ShowLoadBar();
   	
	return true;
end

--赠送鲜花
function p.SendGiveFlower(nPlayerId,nGiveNum)
	if	not CheckN(nGiveNum) or 
	    not CheckN(nPlayerId)  then
		LogInfo("发送赠送鲜花消息失败,参数不对");
		return false;
	end
	
    local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	if nil == netdata then
		LogInfo("发送赠送鲜花消息失败,内存不够");
		return false;
	end
	
	netdata:WriteByte(_FRIEND_FLLOWER_GIVE);
	netdata:WriteInt(0);
	
	netdata:WriteInt(nPlayerId);
	netdata:WriteInt(nGiveNum);
	SendMsg(netdata);	
	netdata:Free();		
	
	LogInfo("赠送鲜花,send giveNum[%d] playerId[%d]", nGiveNum,nPlayerId);
    ShowLoadBar();

	return true;
end

--查看鲜花榜
function p.SendFlowerRank()	
    local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	if nil == netdata then
		LogInfo("发送查看鲜花榜消息失败,内存不够");
		return false;
	end
	
	netdata:WriteByte(_FRIEND_FLLOWER_RANK);
	netdata:WriteInt(0);
	
	SendMsg(netdata);	
	netdata:Free();		
	
	LogInfo("查看鲜花榜,send ");
    ShowLoadBar();

	return true;
end

--打开好友界面
function p.SendOpenFriend()		
    local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	if nil == netdata then
		LogInfo("发送打开好友界面消息失败,内存不够");
		return false;
	end
	
	netdata:WriteByte(_FRIEND_LIST_INIT);
	netdata:WriteInt(0);
	
	SendMsg(netdata);	
	netdata:Free();		

    LogInfo("发送打开好友界面消息,actionId[%d]",_FRIEND_LIST_INIT);
    ShowLoadBar();
   	
	return true;
end

--增加好友
function p.SendFriendAdd(nPlayerId)	
    playerId = nPlayerId;
    local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	if nil == netdata then
		LogInfo("发送增加好友消息失败,内存不够");
		return false;
	end
	
	netdata:WriteByte(_FRIEND_ADD);
	netdata:WriteInt(0);	
	netdata:WriteInt(nPlayerId);
	
	SendMsg(netdata);	
	netdata:Free();		
	
	LogInfo("发送增加好友消息,playerId[%d]",nPlayerId);
    ShowLoadBar();
	
	addFlag = 1;

	return true;
end

--删除好友
function p.SendFriendDel(nPlayerId)	
    playerId = nPlayerId;
    local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	if nil == netdata then
		LogInfo("发送删除好友消息失败,内存不够");
		return false;
	end
	
	netdata:WriteByte(_FRIEND_DEL);
	netdata:WriteInt(0);	
	netdata:WriteInt(nPlayerId);
	
	SendMsg(netdata);	
	netdata:Free();		
	
	LogInfo("发送删除好友消息,send playerId[%d]",nPlayerId);
    ShowLoadBar();

	return true;
end

--查看好友资料
function p.SendFriendSel(nPlayerId,nPlayerName)
    playerId = nPlayerId;
	playerName = nPlayerName;
	
    local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	if nil == netdata then
		LogInfo("发送查看好友资料消息失败,内存不够");
		return false;
	end
	
	netdata:WriteByte(_FRIEND_SEL);
	netdata:WriteInt(0);	
	netdata:WriteInt(nPlayerId);
	
	SendMsg(netdata);	
	netdata:Free();		
	
	LogInfo("发送查看好友资料消息,playerId[%d],playerName[%s]",nPlayerId,nPlayerName);
    ShowLoadBar();
	
	return true;
end


function p.ProcessGoodFriendInfo(netdata)

	local nAction      = netdata:ReadByte();
	local nRecordCount = netdata:ReadInt();
	
	if not CheckN(nAction) or
	   not CheckN(nRecordCount) then
	    LogInfo("收到的参数有误")
		return;
	end		
	
	LogInfo("Recv nRecordCount[%d]  actionId[%d]", nRecordCount, nAction);		
	
		
	if nAction == _FRIEND_LIST_INIT then
	        --读取玩家好友
			CloseLoadBar();	
			local datalist = {}
			for i = 1,nRecordCount do
			      local idFriend= netdata:ReadInt(); 
				  local name   = netdata:ReadUnicodeString();
				  local lv     = netdata:ReadInt(); 
				  local online = netdata:ReadByte();  --0:离线 
				  LogInfo("idFriend:[%d],name:[%s],lv:[%d],online:[%d]",idFriend,name,lv,online)
				  local data = {}
				  table.insert(data,idFriend)
				  table.insert(data,name)
				  table.insert(data,lv)
				  table.insert(data,online)
				  
				  table.insert(datalist,data)
			end	

			FriendUI.LoadUI(datalist);
									
    elseif nAction == _FRIEND_ADD then
	        --添加好友
			CloseLoadBar();
			FriendUI.ResFriendAdd(playerId);	
			
			--重新打开好友面板		
			if IsUIShow(NMAINSCENECHILDTAG.Friend) then
				CloseUI(NMAINSCENECHILDTAG.Friend);
				p.SendOpenFriend();	
			end	
			 
	elseif nAction == _FRIEND_DEL then
	        --删除好友					
			CloseLoadBar();
	        FriendUI.ResFriendDel(playerId);

	elseif nAction == _FRIEND_SEL then
	        --查看好友资料	
			CloseLoadBar();
			if IsUIShow(NMAINSCENECHILDTAG.Friend) then
				CloseUI(NMAINSCENECHILDTAG.Friend);	
			end	
			FriendAttrUI.LoadUI(playerId,playerName);
			
	elseif nAction == _FRIEND_FLLOWER_OPEN then
	        --打开赠送鲜花界面
			CloseLoadBar();			
			local datalist = {}
			local nFlowerCount = netdata:ReadInt();--鲜花总数
			for i = 1,nRecordCount do
				  local name  = netdata:ReadUnicodeString();
				  local time  = netdata:ReadInt();
				  local count = netdata:ReadInt(); 
				  local data = {}
				  table.insert(data,name);
				  table.insert(data,time);
				  table.insert(data,count);
				  table.insert(datalist,data);			     
            end		
			if IsUIShow(NMAINSCENECHILDTAG.Friend) then
				CloseUI(NMAINSCENECHILDTAG.Friend);
			end
			if IsUIShow(NMAINSCENECHILDTAG.FriendAttr) then
				CloseUI(NMAINSCENECHILDTAG.FriendAttr);
			end					
			GiveFlowersUI.LoadUI(playerId,playerName,nFlowerCount,datalist);
			
	elseif nAction == _FRIEND_FLLOWER_GIVE then
            --赠送鲜花
	        CloseLoadBar();
	        GiveFlowersUI.ResGiveFlower();		
			
	elseif nAction == _FRIEND_FLLOWER_RANK then	
			 --查看鲜花榜	
			 CloseLoadBar();		
			 local datalist = {};
			 for i = 1,nRecordCount do
				  local name       = netdata:ReadUnicodeString();
				  local flowerNum  = netdata:ReadInt();
				  local data = {}
				  table.insert(data,name);
				  table.insert(data,flowerNum);
				  
				  table.insert(datalist,data);			     
            end
			FlowerRankUI.LoadUI(datalist);	
																													
	end	
end



RegisterNetMsgHandler(NMSG_Type._MSG_GOODFRIEND, "p.ProcessGoodFriendInfo", p.ProcessGoodFriendInfo);
