---------------------------------------------------
--描述: 好友UI
--时间: 2012.4.18
--作者: fyl
---------------------------------------------------



FriendUI = {}
local p = FriendUI;

--Friend.h
local ID_FRIEND_CTRL_VERTICAL_LIST_FRIENDS		    = 17;
local ID_FRIEND_CTRL_BUTTON_16                      = 16;   
local ID_FRIEND_CTRL_BUTTON_15                      = 15;   


--Friend_list.h
local ID_FRIEND_LIST_CTRL_BUTTON_21			        = 21;
local ID_FRIEND_LIST_CTRL_BUTTON_27			        = 27;
local ID_FRIEND_LIST_CTRL_BUTTON_28			        = 28;
local ID_FRIEND_LIST_CTRL_BUTTON_29			        = 29;
local ID_FRIEND_LIST_CTRL_BUTTON_30			        = 30;
local ID_FRIEND_LIST_CTRL_TEXT_NAME                 = 23;
local ID_FRIEND_LIST_CTRL_TEXT_LEVEL                = 26;


local friendNameList = {};   --存储好友id及名字

--当前操作的对象（好友）
local friendId;
local friendName;


-----------------------
-----------------------

function p.IsExistFriend(nFriendId)
	if not CheckN(nFriendId) then
		LogInfo("p.IsExistFriend invalid arg");
		return false;
	end
	local name = friendNameList[nFriendId];
	if name == nil or name == "" then
		return false;
	end
	return true;
end

--判断好友列表是否已满
function p.CanAddFriend()	
	if #friendNameList < 50 then	 
		return true;
	else
	    return false;	
	end	
end 


function p.LoadUI(datalist)
    LogInfo("load FriendUI !");
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load UI failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.Friend);
	layer:SetFrameRect(RectUILayer);
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("SM_JH_FRIEND_1.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();	
	
	local container = RecursiveSVC(scene, { NMAINSCENECHILDTAG.Friend, ID_FRIEND_CTRL_VERTICAL_LIST_FRIENDS});
	if not CheckP(container) then
		layer:Free();
		return false;
	end
	container:SetStyle(UIScrollStyle.Verical);
	container:SetViewSize(CGSizeMake(container:GetFrameRect().size.w, container:GetFrameRect().size.h/7));
	
	p.RefreshFriendContainer(datalist);
				
end



function p.GetFriendContainer()
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load UI failed!");
		return;
	end
	
	local container = RecursiveSVC(scene, { NMAINSCENECHILDTAG.Friend, ID_FRIEND_CTRL_VERTICAL_LIST_FRIENDS});
	
	if nil == container then
	    LogInfo("container == nil,load UI failed!");
	end	
	
	
	return container;
end

function p.SortTable(datalist,index)
	local n = #datalist - 1;
	
	for i = 1,n do
		 local k = i;
		 for j = i,n do
	         if datalist[j+1][index] > datalist[k][index] then
			     k = j+1;
			 end
		 end
		 if k ~= i then
		     local temp = datalist[i];
			 datalist[i] = datalist[k];
		     datalist[k] = temp;
		end	 
	end		

end

function p.GetFriendList(datalist)		
	local onList = {}
	local unList = {}
	for i = 1,#datalist do
	     if datalist[i][4] ~= 0 then
		     table.insert(onList,datalist[i])
		 else
             table.insert(unList,datalist[i])
		 end
	
	end
	
    p.SortTable(onList,3)
	p.SortTable(unList,3)
	
	datalist = {};
	for i,v in ipairs(onList) do
		 table.insert(datalist,v)
	end
	for i,v in ipairs(unList) do
		 table.insert(datalist,v)
	end
	
	return datalist;
end	


--刷新好友列表,初始化
function p.RefreshFriendContainer(friendList)
    friendList = p.GetFriendList(friendList)
	local container = p.GetFriendContainer();	
	 
	for i,v in ipairs(friendList) do	 
		 local friendItem = v;		 
	   	 local view = createUIScrollView();
	     if view == nil then
		     LogInfo("view == nil");
		     return;
	     end
	
	     view:Init(false);
	     view:SetViewId(friendItem[1]);
	     container:AddView(view);
		 --存储好友名字
		 friendNameList[friendItem[1]] = friendItem[2];
		 
	     local uiLoad = createNDUILoad();
	     if uiLoad ~= nil then
		     uiLoad:Load("SM_JH_FRIEND_2.ini",view,p.OnUIEventFriendAction,0,0);
		     uiLoad:Free();
	     end	
	    
		SetLabel(view,ID_FRIEND_LIST_CTRL_TEXT_NAME,friendItem[2]);
		SetLabel(view,ID_FRIEND_LIST_CTRL_TEXT_LEVEL,string.format("LV%d",friendItem[3]));
		
		if friendItem[4] == 0 then
			--离线的好友字体为灰色
			local nameText = GetLabel(view,ID_FRIEND_LIST_CTRL_TEXT_NAME);
			local levelText = GetLabel(view,ID_FRIEND_LIST_CTRL_TEXT_LEVEL);
		    nameText:SetFontColor(ccc4(88,88,88,255));
			levelText:SetFontColor(ccc4(88,88,88,255));
		end				
	end
end

function p.ResFriendAdd(nFriendId)
	CommonDlg.ShowTipInfo("提示", "添加好友成功!", nil, 2);
	friendNameList[nFriendId] = "falseName";
	--table.insert(friendNameList,nFriendId,"falseName")
	if IsUIShow(NMAINSCENECHILDTAG.FriendAttr) then
		FriendAttrUI.RefreshBtnText();
	end	
end

function p.ResFriendDel(nFriendId)
	CommonDlg.ShowTipInfo("提示", "删除成功!", nil, 2);
	if IsUIShow(NMAINSCENECHILDTAG.Friend) then
	    local container = p.GetFriendContainer();
	    container:RemoveViewById(nFriendId);
	end
	friendNameList[nFriendId] = "";
	if IsUIShow(NMAINSCENECHILDTAG.FriendAttr) then
		FriendAttrUI.RefreshBtnText();
	end	
end


---------------
--UI事件处理回调函数
---------------

function p.OnUIEvent(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		if tag == ID_FRIEND_CTRL_BUTTON_15 then
			--关闭界面
			CloseUI(NMAINSCENECHILDTAG.Friend);
	    end
	end
	return true;
end

function p.OnUIEventFriendAction(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		LogInfo("p.OnUIEventFriendAction[%d]", tag);	
		--获取按钮所在的view
		local view	= PRecursiveSV(uiNode, 1);	
		--local view = ConverToSV(uiNode:GetParent());
		if view == nil then
	        LogInfo("view is nil")	
		    return false;
		end
	
        friendId = view:GetViewId();		
		friendName = friendNameList[friendId];
        
		if tag == ID_FRIEND_LIST_CTRL_BUTTON_21 then
		    --查看资料
			--获取玩家宠物id列表
	        local idTable = RolePetUser.GetPetListPlayer(friendId);
			if idTable == nil or #idTable <= 0 then
		        MsgFriend.SendFriendSel(friendId,friendName);
			else
			    if IsUIShow(NMAINSCENECHILDTAG.Friend) then
				    CloseUI(NMAINSCENECHILDTAG.Friend);	
			    end	
			    FriendAttrUI.LoadUI(friendId,friendName);	
			end	
			
	    elseif tag == ID_FRIEND_LIST_CTRL_BUTTON_27 then	
		    --赠送鲜花 
			MsgFriend.SendOpenGiveFlower(friendId,friendName);
		    --判断今天是否赠送过了
		    --CommonDlg.ShowTipInfo("提示", "您今天已经赠送过鲜花了!", nil, 2); 
			   
		elseif tag == ID_FRIEND_LIST_CTRL_BUTTON_28 then	
		    --切磋  
		elseif tag == ID_FRIEND_LIST_CTRL_BUTTON_29 then	
		    --删除好友 
			CommonDlg.ShowNoPrompt(string.format("确定删除好友 %s 吗？",friendName), p.OnCommonDlgDelFriend, true);  
		elseif tag == ID_FRIEND_LIST_CTRL_BUTTON_30 then	
		    --私聊    	   	
		end
		
    end
    return true;
end


function p.OnCommonDlgDelFriend(nId, nEvent, param)
	if nEvent == CommonDlg.EventOK then
         MsgFriend.SendFriendDel(friendId);
	end
end	

