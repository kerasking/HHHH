---------------------------------------------------
--描述: 聊天数据管理
--时间: 2012.4.25
--作者: cl
---------------------------------------------------

ChatDataFunc = {};
local p = ChatDataFunc;

p.chatList={0};

ChatType={
	CHAT_CHANNEL_ALL=0,
	CHAT_CHANNEL_SYS=1,
	CHAT_CHANNEL_WORLD=2,
	CHAT_CHANNEL_FACTION=3,
	CHAT_CHANNEL_PRIVATE=4,
	CHAT_CHANNEL_SMALL=5,
	CHAT_CHANNEL_SYSTIP = 20, --用于动画提示
}

ChatInputTarget={
	main_input=1,
	private_input=2,
}

local list_head=1;
local list_end=1;
local maxCount=100;

function p.AddAllChatRecordGameScene()
	for i=list_head,list_end do
		if IsUIShow(NMAINSCENECHILDTAG.ChatGameScene) then
			if nil~=p.chatList[i] then
					ChatGameScene.AddChatText(p.chatList[i][1],p.chatList[i][2],p.chatList[i][4],p.chatList[i][5],i);
				
			end
		end
	end
end



function p.AddAllChatRecord(type)
	LogInfo("head:%d,end:%d",list_head,list_end);
	for i=list_head,list_end do
		if IsUIShow(NMAINSCENECHILDTAG.ChatMainUI) then
			if nil~=p.chatList[i] then
				if type==ChatType.CHAT_CHANNEL_ALL then
					ChatMainUI.AddChatText(p.chatList[i][1],p.chatList[i][2],p.chatList[i][4],p.chatList[i][5]);
				elseif type==ChatType.CHAT_CHANNEL_WORLD and p.chatList[i][2]==ChatType.CHAT_CHANNEL_WORLD then
					ChatMainUI.AddChatText(p.chatList[i][1],p.chatList[i][2],p.chatList[i][4],p.chatList[i][5]);
				elseif type==ChatType.CHAT_CHANNEL_FACTION and p.chatList[i][2]==type then
					ChatMainUI.AddChatText(p.chatList[i][1],p.chatList[i][2],p.chatList[i][4],p.chatList[i][5]);
				elseif type==ChatType.CHAT_CHANNEL_PRIVATE and p.chatList[i][2]==type then
					ChatMainUI.AddChatText(p.chatList[i][1],p.chatList[i][2],p.chatList[i][4],p.chatList[i][5]);
				end
			end
		end
	end
end

function p.AddAllChatRecordSmall()
	LogInfo("head:%d,end:%d",list_head,list_end);
	for i=list_head,list_end do
		if IsUIShow(NMAINSCENECHILDTAG.ChatSmallUI) then
			if nil~=p.chatList[i] then
				ChatSmallUI.AddChatText(p.chatList[i][1],p.chatList[i][2],p.chatList[i][4],p.chatList[i][5]);
			end
		end
	end
end

function p.AddAllChatRecordPrivate(playerId)
	LogInfo("head:%d,end:%d",list_head,list_end);
	if playerId == 0 then
		return;
	end
	for i=list_head,list_end do
		if IsUIShow(NMAINSCENECHILDTAG.ChatPrivateUI) then
			if nil~=p.chatList[i] and p.chatList[i][2]==ChatType.CHAT_CHANNEL_PRIVATE then
				if p.chatList[i][1]==playerId or p.chatList[i][3] == playerId  then
					ChatPrivateUI.AddChatText(p.chatList[i][1],p.chatList[i][2],p.chatList[i][3],p.chatList[i][4],p.chatList[i][5]);
				end
			end
		end
	end
end

function p.AddChatRecord(sID,cID,tID,spk,txt)
	LogInfo("addChatRecord:%s:%s",spk,txt);
	if (list_end-list_head)>49 then
		p.chatList[list_head]=nil;
        				
        if IsUIShow(NMAINSCENECHILDTAG.ChatGameScene) then
            ChatGameScene.RemoveChatText(list_head)
        end
		
		list_head=list_head+1;
	end
	
	cID=p.GetChatTypeFromChannel(cID);
	p.chatList[list_end]={sID,cID,tID,spk,txt};
	list_end=list_end+1;
	
	if IsUIShow(NMAINSCENECHILDTAG.ChatMainUI) and cID ~= ChatType.CHAT_CHANNEL_PRIVATE then
		ChatMainUI.AddChatText(sID,cID,spk,txt);
	end
	
	
	if IsUIShow(NMAINSCENECHILDTAG.ChatMainUI) and cID==ChatType.CHAT_CHANNEL_PRIVATE then
		ChatMainUI.AddChatText(sID,cID,spk,txt);
	end
	
    
 	if  cID==ChatType.CHAT_CHANNEL_SYSTIP then
		--ChatMainUI.AddChatText(sID,cID,spk,txt);
		CommonDlgNew.ShowTipDlg(txt);
        return;
	end
    
    ChatGameScene.AddChatText(sID,cID,spk,txt,list_end);
    
    ChatGameScene.DelayShowUI();
    
		
end

function p.ParseItemInfo(text)
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local idlist	= ItemUser.GetBagItemList(nPlayerId);
	if not CheckT(idlist) then
		LogInfo("no item");
		return false;
	end
	
	local i=0;
	while true do
		i,j=string.find(text,"<b",i);
		if nil==i then
			break;
		end
		
		local pre_str=string.sub(text,1,i-1);
		
		local after_str=string.sub(text,j+3,-1);
		
		local index=SafeS2N(string.sub(text,j+1,j+2));
		
		local item_str="";
		if index~=nill and
			index>0 and
			index<=48 then
			local itemid=idlist[index];
			local itemType=Item.GetItemInfoN(itemid, Item.ITEM_TYPE);
			local name=ItemFunc.GetName(itemType);
			local quality=ItemFunc.GetQuality(itemType);
			item_str="<b"..name.."/"..SafeN2S(quality).."/"..SafeN2S(itemid).."~";
            text=pre_str..item_str..after_str;
            i=i+string.len(item_str);
		end

	end
	return text;
end

function p.SendItemChat(nItemId)
	if not CheckN(nItemId) then
		return;
	end
	
	if not Item.IsExistItem(nItemId) then
		return;
	end
	local itemType=Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	local name=ItemFunc.GetName(itemType);
	local quality=ItemFunc.GetQuality(itemType);
	local item_str="<b"..name.."/"..SafeN2S(quality).."/"..SafeN2S(nItemId).."~";
	MsgChat.SendTalkMsg(14,item_str);
end

function p.AddSysInfo(text)
	if IsUIShow(NMAINSCENECHILDTAG.ChatMainUI) then
		ChatMainUI.AddChatText(0,ChatType.CHAT_CHANNEL_SYS,"SYSTEM",text);
	end
	
	if IsUIShow(NMAINSCENECHILDTAG.ChatSmallUI) then
		ChatSmallUI.AddChatText(0,ChatType.CHAT_CHANNEL_SYS,"SYSTEM",text);
	end
end
function p.GetChannelByChatType(type)
	if type==ChatType.CHAT_CHANNEL_WORLD then
		return 14;
	elseif type==ChatType.CHAT_CHANNEL_ALL then
		return 14;
	elseif type==ChatType.CHAT_CHANNEL_FACTION then
		return 4;
	elseif type==ChatType.CHAT_CHANNEL_PRIVATE then
		return 1;
	end
	return 14;
end

function p.OpenPrivateChat(playerId,name)
	if not IsUIShow(NMAINSCENECHILDTAG.ChatPrivateUI) then
		ChatPrivateUI.LoadUI();
	end

	ChatPrivateUI.SetChatPlayer(playerId,name);
end

function p.OnChatNodeClick(type,contentID,content)
	LogInfo("OnChatNodeClick contentID"..contentID.." type"..type);
	if type==1 then
		local nPlayerId = GetPlayerId();
		if nil == nPlayerId then
			LogInfo("nil == nPlayerId");
			return;
		end
		if contentID==nPlayerId then
			--return;
		end
		
        if contentID==0 then
            return;
        end       

		if CheckS(content) then
			ChatMainUI.OpenInfoList(contentID,content); 
		end
	elseif type==3 then
		--ChatMainUI.ShowChatItemInfo(contentID);
	elseif type==5 then
		--MsgFriend.SendFriendSel(contentID,content);
	end
	return true;
end

function p.ClearChatRecord()
	for i=list_head,list_end do
		if nil~=p.chatList[i] then
			p.chatList[i]=nil;
		end
	end
	list_head=1;
	list_end=1;
	p.chatList={0};
end

function p.GetChatTypeFromChannel(channel)
	local type=0;
	if channel==19 then
		type = ChatType.CHAT_CHANNEL_WORLD;
	elseif channel==21 then
		type = ChatType.CHAT_CHANNEL_WORLD;
	elseif channel==20 then
		type = ChatType.CHAT_CHANNEL_SYS;
	elseif channel==14 then
		type = ChatType.CHAT_CHANNEL_WORLD;
	elseif channel==9 then
		type = ChatType.CHAT_CHANNEL_WORLD;
	elseif channel==5 then
		type = ChatType.CHAT_CHANNEL_SYS;
    elseif channel==22 then
		type = ChatType.CHAT_CHANNEL_SYS;
	elseif channel==3 then
		type = ChatType.CHAT_CHANNEL_WORLD;
	elseif channel== 4 then
		type = ChatType.CHAT_CHANNEL_FACTION;
	elseif channel== 1 then
		type = ChatType.CHAT_CHANNEL_PRIVATE;
	elseif channel==23 then
		type = ChatType.CHAT_CHANNEL_SYSTIP;
	end
	return type;
end

function p.ResetChatContent(param1, param2, param3)
	LogInfo("receive_talk ResetChatContent");
	p.chatList={0};
	list_head=1;
	list_end=1;
end

_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_LOGIN_GAME, "ChatDataFunc.ResetChatContent", p.ResetChatContent);
--_G.GlobalEvent.Register(_G.GLOBALEVENT.GE_LOGIN_GAME, "ChatDataFunc.ResetChatContent", p.ResetChatContent);
--_G.GlobalEvent.Register(_G.GLOBALEVENT.GE_LOGIN_GAME, "ChatDataFunc.ResetChatContent", p.ResetChatContent);
