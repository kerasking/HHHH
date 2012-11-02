---------------------------------------------------
--描述: 处理装备强化相关消息
--时间: 2012.4.16
--作者: fyl
---------------------------------------------------

MsgFriend = {}
local p = MsgFriend;

local	_FRIEND_ADD               = 10;		--添加好友
local	_FRIEND_DEL               = 11;	    --删除好友
local	_FRIEND_INFO_UPDATE       = 12;		--更新好友数据
local	_FRIEND_LIST_INIT         = 13;		--获取好友列表数据
local 	_FRIEND_ADDBYNAME		  = 17;		--通过名字添加好友

local   _FRIEND_ANOUNCEMENT       = 18;     --好友操作消息

local   _FRIEND_SEL               = 16;     --查看资料

local	_FRIEND_FLLOWER_GIVE	  = 20;		--赠送鲜花
local	_FRIEND_FLLOWER_OPEN      = 21;		--打开赠送鲜花界面，查看玩家收到的赠送鲜花记录和拥有的鲜花总数
local	_FRIEND_FLLOWER_RANK      = 22;		--查看鲜花榜


local playerId; --打开赠送鲜花界面和查看好友资料,添加/删除好友 需要用到
local playerName = "";

local IsSelect = false;    --在好友面板中查看好友资料
local IsGiveFlower = false;--在好友面板中选择进入鲜花赠送界面

local parentLayerTag;


function p.SendGetFriendInfo(friendId)
	local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	netdata:WriteByte(_FRIEND_INFO_UPDATE);

	netdata:WriteInt(0);	
	netdata:WriteInt(friendId);
    
        	
	SendMsg(netdata);	
	netdata:Free();	

    LogInfo("发送获取好友信息消息,actionId[%d] friend:[%d]",_FRIEND_INFO_UPDATE,friendId);
    ShowLoadBar();
   	
	return true;	
end


--获取好友列表更新
function p.SendFriendListUpdate()		
    local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	if nil == netdata then
		LogInfo("发送打开好友界面消息失败,内存不够");
		return false;
	end
	
	netdata:WriteByte(_FRIEND_INFO_UPDATE);
	netdata:WriteInt(0);
	
	SendMsg(netdata);	
	netdata:Free();	

    LogInfo("发送打开好友界面消息,actionId[%d]",_FRIEND_INFO_UPDATE);
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

	return true;
end

--通过名字增加好友
function p.SendFriendAddByName(sFriendName)	
	local netdata = createNDTransData(NMSG_Type._MSG_GOODFRIEND);
	if nil == netdata then
		LogInfo("发送增加好友消息失败,内存不够");
		return false;
	end
	
	netdata:WriteByte(_FRIEND_ADDBYNAME);
	netdata:WriteInt(0);		
	netdata:WriteStr(sFriendName);
	
	SendMsg(netdata);	
	netdata:Free();		
	
	LogInfo("发送增加好友消息,name:[%s]",sFriendName);
    ShowLoadBar();

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

	--LogInfo("发送删除好友消息,send playerId[%d]",nPlayerId);
    ShowLoadBar();

	return true;
end

--查看好友资料
function p.SendFriendSel(nPlayerId,nPlayerName,nTag)
    playerId = nPlayerId;
	playerName = nPlayerName;
	parentLayerTag = nTag;
	
	if CheckN(parentLayerTag) and NMAINSCENECHILDTAG.Friend == parentLayerTag then
	    IsSelect = true;
	end
	
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
	
	LogInfo("qbw:Recv nRecordCount[%d]  actionId[%d]", nRecordCount, nAction);		
	
		
	if nAction == _FRIEND_LIST_INIT then
	        --读取玩家好友列表
			nRoleId = GetPlayerId();
			LogInfo("qbw1: Friend list init")
			for i = 1,nRecordCount do
			      local idFriend= netdata:ReadInt(); 
			      local name   = netdata:ReadUnicodeString();
				  local online = netdata:ReadByte();  --0:离线 
				  local pro = netdata:ReadInt(); 
                  local nQuality = netdata:ReadInt();
                  
				 -- local lv     = netdata:ReadInt();  
				 -- local pro       = netdata:ReadInt(); 
				 -- local repute    = netdata:ReadInt(); 
				 -- local syndycate = netdata:ReadInt(); 
				 -- local sports 	  = netdata:ReadInt(); 
				 -- local capacity  = netdata:ReadInt(); 
				  
				  
				  --LogInfo("_FRIEND_LIST_INIT:[%d],name:[%s],lv:[%d],online:[%d],lookface[%d]",idFriend,name,lv,online,lookface)
				  LogInfo("_FRIEND_LIST_INIT:[%d],name:[%s],online:[%d],pro[%d]",idFriend,name,online,pro)
				  
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_ID, idFriend, idFriend) 
				  SetRoleFriendDataS(nRoleId, FRIEND_DATA.FRIEND_NAME, name,   idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_ONLINE,online,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_PROFESSION,pro,idFriend) 
                    SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_QUALITY,nQuality,idFriend) 
				  --
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_LEVEL,0,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_REPUTE	,0,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_SYNDYCATE,0,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_SPORTS	,0,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_CAPACITY,0,idFriend) 
				  --]]
				  
				  
			end	
			
    elseif nAction == _FRIEND_INFO_UPDATE then
		    --更新玩家好友数据
	        nRoleId = GetPlayerId();
			CloseLoadBar();
			for i = 1,nRecordCount do
			      local idFriend= netdata:ReadInt(); 
				  local name   = netdata:ReadUnicodeString();
				  local online = netdata:ReadByte();  --0:离线 
				  local pro       = netdata:ReadInt(); 
                    --** chh 2012-09-05 **--
				  local nQuality  = netdata:ReadInt();  --品质
				 
				  local lv     = netdata:ReadInt(); 
				   local repute    = netdata:ReadInt(); 
				  local syndycate = netdata:ReadInt(); 
				  local sports 	  = netdata:ReadInt(); 
				  local capacity  = netdata:ReadInt(); 
                  
                  
                  
                  
				  LogInfo("_FRIEND_INFO_UPDATE:[%d],name:[%s],lv:[%d],online:[%d],pro[%d]",idFriend,name,lv,online,pro)
				  
				  --新添加的好友
				  if not FriendFunc.IsExistFriend(idFriend) then
				      SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_ID, idFriend, idFriend) 
				  end	
				    
				  SetRoleFriendDataS(nRoleId, FRIEND_DATA.FRIEND_NAME, name,   idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_LEVEL,lv,     idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_ONLINE,online,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_PROFESSION,pro,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_REPUTE	,repute,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_SYNDYCATE,syndycate,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_SPORTS	,sports,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_CAPACITY,capacity,idFriend) 
                  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_QUALITY,nQuality,idFriend) 
                  
                  LogInfo("chh_nQuality2:[%d]",nQuality);
			end	
			
			--[[
			if IsUIShow(NMAINSCENECHILDTAG.Friend) then
			    --好友面板已经开启,刷新列表
				FriendUI.RefreshFriendContainer();
				
			else
				FriendUI.LoadUI();
			end	--]]
			
			GameDataEvent.OnEvent(GAMEDATAEVENT.FRIENDATTR);
		
									
    elseif nAction == _FRIEND_ADD then
	        --添加好友
			CloseLoadBar();
			local idFriend= netdata:ReadInt(); 
			local name   = netdata:ReadUnicodeString();
			local online = netdata:ReadByte();  --0:离线 
			local pro       = netdata:ReadInt(); 
              --** chh 2012-09-05 **--
				  local nQuality  = netdata:ReadInt();  --品质
				  
                  local lv     = netdata:ReadInt(); 
				  local repute    = netdata:ReadInt(); 
				  local syndycate = netdata:ReadInt(); 
				  local sports 	  = netdata:ReadInt(); 
				  local capacity  = netdata:ReadInt(); 
				  			
			
			
			LogInfo("idFriend:[%d],name:[%s],lv:[%d],online:[%d],pro[%d]",idFriend,name,lv,online,pro)
			nRoleId = GetPlayerId();
			--新添加的好友
			if FriendFunc.IsExistFriend(idFriend) or playerId ~= idFriend then
                LogInfo("添加好友中，收到的好友id有误")				
			end	
			
			SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_ID, idFriend, idFriend) 
			SetRoleFriendDataS(nRoleId, FRIEND_DATA.FRIEND_NAME, name,   idFriend) 
			SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_LEVEL,lv,     idFriend) 
			SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_ONLINE,online,idFriend) 
			SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_QUALITY,nQuality,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_PROFESSION,pro,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_REPUTE	,repute,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_SYNDYCATE,syndycate,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_SPORTS	,sports,idFriend) 
				  SetRoleFriendDataN(nRoleId, FRIEND_DATA.FRIEND_CAPACITY,capacity,idFriend) 
				  

			FriendUI.ResFriendAdd(playerId);				
			--好友面板已经开启,刷新列表	
			--if IsUIShow(NMAINSCENECHILDTAG.Friend) then	
			 --   p.SendFriendListUpdate();	
			--end
 
			if IsUIShow(NMAINSCENECHILDTAG.FriendAttr) then
			    --刷新好友按钮文字
				FriendAttrUI.RefreshBtnText();
			end	
				
			--引导任务事件触发
			GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.ADDFRIEND);
	 
	elseif nAction == _FRIEND_DEL then
	        --删除好友					
			CloseLoadBar();
	        FriendUI.ResFriendDel(playerId);

			if IsUIShow(NMAINSCENECHILDTAG.FriendAttr) then
			    --刷新好友按钮文字
				FriendAttrUI.RefreshBtnText();
			end

						
	elseif nAction == _FRIEND_SEL then
	        --查看好友资料	
			CloseLoadBar();
			--从好友面板中查看资料
			--if IsSelect then
			--	FriendFunc.SetLayerVisible(NMAINSCENECHILDTAG.Friend,false);
			--end	
			
			if IsUIShow(NMAINSCENECHILDTAG.FriendAttr) then
				CloseUI(NMAINSCENECHILDTAG.FriendAttr);
			end
			
			--CloseMainUI(NMAINSCENECHILDTAG.FriendAttr);
			
			FriendAttrUI.LoadUI(playerId,playerName,parentLayerTag);
			
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
			
			--从好友面板中打开赠送鲜花界面
			if IsGiveFlower then
				FriendFunc.SetLayerVisible(NMAINSCENECHILDTAG.Friend,false);			
			end	
			
			if IsUIShow(NMAINSCENECHILDTAG.GiveFlowers) then
				CloseUI(NMAINSCENECHILDTAG.GiveFlowers);
			end									
			GiveFlowersUI.LoadUI(playerId,playerName,nFlowerCount,datalist,parentLayerTag);
			
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
    elseif nAction == _FRIEND_ANOUNCEMENT then
            CloseLoadBar();
            local sAnouce       = netdata:ReadUnicodeString();
           
  			--if IsUIShow(NMAINSCENECHILDTAG.Friend) then
                CommonDlgNew.ShowYesDlg(sAnouce);
			--end	          
	end	
end



function p.SendSeeOtherPlayerList()
    LogInfo("MsgFriend.SendSeeOtherPlayerList");
    local netdata = createNDTransData(NMSG_Type._MSG_VIEW_PLAYER);
    
	SendMsg(netdata);	
	netdata:Free();	
    ShowLoadBar();
   	
	return true;
end

function p.ProcessOtherPlayerList( netdata )
    LogInfo("MsgFriend.ProcessOtherPlayerList");
    local m = {};
    local nCount = netdata:ReadInt();
    for i=1,nCount do
        local mr = {};
        mr.Id       = netdata:ReadInt();
        mr.Level    = netdata:ReadInt();
        mr.Quality  = netdata:ReadByte();
        mr.Name     = netdata:ReadUnicodeString();
        LogInfo( "nCount:[%d],i:[%d],mr.Id:[%d],mr.Level:[%d],mr.Quality:[%d],mr.Name:[%s]",nCount,i,mr.Id,mr.Quality,mr.Level,mr.Name );
        table.insert(m,mr);
    end
    MainPlayerListUI.LoadUI(m);
    CloseLoadBar();
end
RegisterNetMsgHandler(NMSG_Type._MSG_VIEW_PLAYER, "MsgFriend.ProcessOtherPlayerList", p.ProcessOtherPlayerList);
RegisterNetMsgHandler(NMSG_Type._MSG_GOODFRIEND, "p.ProcessGoodFriendInfo", p.ProcessGoodFriendInfo);
