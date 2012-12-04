---------------------------------------------------
--描述: 好友UI
--时间: 2012.4.18
--作者: fyl
---------------------------------------------------



FriendUI = {}
local p = FriendUI;

--Friend.h
local ID_FRIEND_CTRL_VERTICAL_LIST_FRIENDS		    = 24;
local ID_FRIEND_CTRL_BUTTON_16                      = 16;   
local ID_FRIEND_CTRL_BUTTON_15                      = 22;   
local ID_FRIEND_CTRL_BUTTON_25                      = 25;   


--Friend_list.h
local ID_FRIEND_LIST_CTRL_BUTTON_21			        = 21;
local ID_FRIEND_LIST_CTRL_BUTTON_27			        = 27;
local ID_FRIEND_LIST_CTRL_BUTTON_28			        = 28;
local ID_FRIEND_LIST_CTRL_BUTTON_29			        = 29;
local ID_FRIEND_LIST_CTRL_BUTTON_30			        = 30;
local ID_FRIEND_LIST_CTRL_HYPER_TEXT_NAME                 = 17;
local ID_FRIEND_LIST_CTRL_HYPER_TEXT_LEVEL                = 18;
local ID_FRIEND_LIST_CTRL_BUTTON_13                = 13;

--Friend info
local ID_FRIEND_INFO_CTRL_TEXT_NAME 			        = 19;
local ID_FRIEND_INFO_CTRL_TEXT_LEVEL 			        = 20;

local ID_FRIEND_INFO_CTRL_TEXT_13 			       	    = 13;
local ID_FRIEND_INFO_CTRL_TEXT_14 			       	    = 14;
local ID_FRIEND_INFO_CTRL_TEXT_15 			       	    = 15;
local ID_FRIEND_INFO_CTRL_TEXT_16 			       	    = 16;
local ID_FRIEND_INFO_CTRL_TEXT_17 			       	    = 17;
local ID_FRIEND_INFO_CTRL_PICTURE_ROLE_ICON        	    = 18;

local ID_FRIEND_CTRL_BUTTON_4                      = 4;--info   
local ID_FRIEND_CTRL_BUTTON_5                      = 5;--talk   
local ID_FRIEND_CTRL_BUTTON_6                      = 6;  --email 
local ID_FRIEND_CTRL_BUTTON_7                      = 7;   --delete


--AddFriend
local ID_ADDFRIEND_CONFIRM 						    = 5;
local ID_ADDFRIEND_CANCEL 	 						= 6;
local ID_ADDFRIEND_INPUTBUTTON  					= 3;


local TAG_FRIENDINFO_LAYER = 1001;
local TAG_ADDFRIEND_LAYER = 1002;

local friendNameList = {};   --存储好友id及名字

--当前操作的对象（好友）
local friendId;
local friendName;
--搜索文本
local g_SearchName = ""

local winsize = GetWinSize();
local Screenwidth =  winsize.w;
local Screenheight = winsize.h;

-----------------------
-----------------------

function p.LoadUI()

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
	layer:SetFrameRect(RectFullScreenUILayer);

	layer:SetTag( NMAINSCENECHILDTAG.Friend);
	scene:AddChildZ(layer,1);

	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	--bg
	uiLoad:Load("friend/friend_A.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();	

	local container = RecursiveSVC(scene, { NMAINSCENECHILDTAG.Friend, ID_FRIEND_CTRL_VERTICAL_LIST_FRIENDS});
	if not CheckP(container) then
		layer:Free();
		return false;
	end

	container:SetStyle(UIScrollStyle.Verical);
	container:SetViewSize(CGSizeMake(container:GetFrameRect().size.w, container:GetFrameRect().size.h/5));
	container:EnableScrollBar(true);

	--玩家信息
	local layerInfo = createNDUILayer();
	if layerInfo == nil then
		return false;
	end
	layerInfo:Init();
	layerInfo:SetTag(TAG_FRIENDINFO_LAYER);
	layerInfo:SetFrameRect(CGRectMake(Screenwidth*0.45,Screenheight*0.115,Screenwidth*0.5,Screenheight));

	local uiLoad = createNDUILoad();
	uiLoad:Load("friend/friend_A_R.ini", layerInfo, p.OnUIEventInfo, 0, 0);
	uiLoad:Free();	
	
	layer:AddChildZ(layerInfo,1);

	--默认选定第一个玩家
	p.ClearInfoLayer();
	
	local friendList = {}
	--friendList = p.GetFriendList();
	friendList = FriendFunc.GetFriendIdList(GetPlayerId());
	local nLength = #friendList;
	
	if friendList[nLength] ~= nil then
		friendId = friendList[nLength]
		 --LogInfo("qbw3:"..friendId)
		MsgFriend.SendGetFriendInfo(friendId);
		friendName = FriendFunc.GetAttrDesc(GetPlayerId(),FRIEND_DATA.FRIEND_NAME,friendId);
        
		p.RefreshInfoLayer();
		
	end

	--刷新列表
	p.RefreshFriendContainer();
   
   	--刷新好友数据
	--MsgFriend.SendFriendListUpdate();
  			

	
  	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_FRIEND_CTRL_BUTTON_15);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   		
end




--[[
--信息层事件
function p.OnUIEventInfo(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		if tag == ID_FRIEND_CTRL_BUTTON_4 then
			--info
			MsgFriend.SendFriendSel(friendId,"qbw:testid:"..friendId);	
		elseif tag ==  ID_FRIEND_CTRL_BUTTON_7 then	
			CommonDlg.ShowNoPrompt(string.format("确定删除好友 %s 吗？",friendName), p.OnCommonDlgDelFriend, true);  
		elseif ( ID_FRIEND_CTRL_BUTTON_6 == tag ) then	--++Guosen 2012.6.12 16:30
			LogInfo("发送邮件:"..friendName);
			if ( friendName ~= "" ) then
				CloseUI(NMAINSCENECHILDTAG.Friend);
				EmailList.SendEmailToFriend( friendName );  
			end
	    end
	end
	return true;
end--]]



function p.ResFriendAdd(nFriendId)
	CommonDlgNew.ShowYesDlg("添加好友成功!");
	if IsUIShow(NMAINSCENECHILDTAG.FriendAttr) then
		FriendAttrUI.RefreshBtnText();
	end	
	
	--if IsUIShow(NMAINSCENECHILDTAG.Friend) then

	--end	
	
	friendId =  p.GetFirstFriendId();
	LogInfo("qbw4   friendId:"..friendId)
	
	if friendId ~= 0 then
		friendName = FriendFunc.GetAttrDesc(GetPlayerId(),FRIEND_DATA.FRIEND_NAME,friendId);
	else
		friendName = "";			
	end
	
	p.GameDataFriendInfoRefresh()
	--p.RefreshInfoLayer();
	
end

function p.ResFriendDel(nFriendId)
	CommonDlgNew.ShowYesDlg("删除成功!");
	if IsUIShow(NMAINSCENECHILDTAG.Friend) then
	    local container = p.GetFriendContainer();
	    container:RemoveViewById(nFriendId);
	    
	end
	
	FriendFunc.DelFriend(GetPlayerId(), nFriendId);
	
	friendId =  p.GetFirstFriendId();
	friendName = FriendFunc.GetAttrDesc(GetPlayerId(),FRIEND_DATA.FRIEND_NAME,friendId);
	p.RefreshInfoLayer()

end


---------------
--UI事件处理回调函数
---------------

--信息层事件
function p.OnUIEventInfo(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		if tag == ID_FRIEND_CTRL_BUTTON_4 then
			--info
			MsgFriend.SendFriendSel(friendId,friendName);	
		elseif tag ==  ID_FRIEND_CTRL_BUTTON_7 then	
			CommonDlgNew.ShowYesOrNoDlg(string.format("确定删除好友 %s 吗？",friendName), p.OnCommonDlgDelFriend, true);
	   	
	   	elseif ( ID_FRIEND_CTRL_BUTTON_6 == tag ) then	--++Guosen 2012.6.12 16:30
			LogInfo("发送邮件:"..friendName);
			if ( friendName ~= "" ) then
				--CloseUI(NMAINSCENECHILDTAG.Friend);
				EmailList.SendEmailToFriend( friendName );  
			end
		elseif 	ID_FRIEND_CTRL_BUTTON_5 == tag then
			
			CloseUI(NMAINSCENECHILDTAG.Friend);
			
			ChatMainUI.LoadUIbyFriendName(friendName);
			
	    end

	end
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		if tag == ID_FRIEND_CTRL_BUTTON_15 then
			--关闭界面
			CloseUI(NMAINSCENECHILDTAG.Friend);
		elseif tag == ID_FRIEND_CTRL_BUTTON_15 then
			--
			
		elseif tag == ID_FRIEND_CTRL_BUTTON_25 then 
			--增加好友
		
			p.OnAddFriendBtnClick()	
				
	    end
	end
	return true;
end


function p.OnUIEventFriendAction(uiNode, uiEventType, param)
	LogInfo("QBW: p.OnUIEventFriendAction:"..uiEventType.." CLICK"..NUIEventType.TE_TOUCH_BTN_CLICK);	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		LogInfo("p.OnUIEventFriendAction[%d]", tag);	
		--获取按钮所在的view
		local view	= PRecursiveSV(uiNode, 1);	

		if view == nil then
	        LogInfo("view is nil")	
		    return false;
		end
	
        friendId = view:GetViewId();
        friendName = FriendFunc.GetAttrDesc(GetPlayerId(),FRIEND_DATA.FRIEND_NAME,friendId);
	
		--p.RefreshInfoLayer()
		MsgFriend.SendGetFriendInfo(friendId);
		
    end
    return true;
end


function p.OnCommonDlgDelFriend(nEventType , nEvent, param)
    if(CommonDlgNew.BtnOk == nEventType) then
         MsgFriend.SendFriendDel(friendId);
    end
end	




function p.OnAddFriendBtnClick()	

	local Bglayer = p.GetBgLayer()
	

	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end

	layer:Init();
	layer:SetTag(TAG_ADDFRIEND_LAYER);
	--layer:SetFrameRect(RectFullScreenUILayer);
	layer:SetFrameRect(CGRectMake(-150,0,960,640)); --@todo: use GetWinSize()!


	if Bglayer == nil then
		LogInfo("QBW1 bglayer nil")
		return;
	end
	
	if layer == nil then
		LogInfo("QBW1 layer nil")
		return;
	end
	
	Bglayer:AddChildZ(layer,2);

	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	g_SearchName = ""
	uiLoad:Load("friend/friend_A_S.ini", layer, p.OnUIEventAddFriendLayer, 0, 0);
	uiLoad:Free();	
end




function p.OnUIEventAddFriendLayer(uiNode, uiEventType, param)
	--LogInfo("QBW1: text input change:"..uiEventType.." "..NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local tag = uiNode:GetTag();
		if tag == ID_ADDFRIEND_CONFIRM then
		--发送申请添加好友

			--local Bglayer = p.GetBgLayer();
			--local node = RecursiveUINode(Bglayer,{TAG_ADDFRIEND_LAYER,ID_ADDFRIEND_INPUTBUTTON});
			--local pNameEdit = ConverToEdit(node);
			--g_SearchName = pNameEdit:GetText();

			if g_SearchName == "" then
				 CommonDlgNew.ShowYesDlg("不能为空!");  	
				 return;
			end
			LogInfo("QBW1 add friend name:"..g_SearchName);
            
           if true ==  FriendFunc.IsExistFriendByName(g_SearchName) then
                 CommonDlgNew.ShowYesDlg("该玩家已经是您的好友!");  
                return;
           end
            
			MsgFriend.SendFriendAddByName(g_SearchName);
			
			local Bglayer = p.GetBgLayer();
			Bglayer:RemoveChildByTag(TAG_ADDFRIEND_LAYER,true);
	
			
		elseif tag == ID_ADDFRIEND_CANCEL then

			local Bglayer = p.GetBgLayer();
			Bglayer:RemoveChildByTag(TAG_ADDFRIEND_LAYER,true);


		end
	end
	
	if uiEventType ==  NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
		--搜索文本变更	
			local Bglayer = p.GetBgLayer();
			local node = RecursiveUINode(Bglayer,{TAG_ADDFRIEND_LAYER,ID_ADDFRIEND_INPUTBUTTON});
			local pNameEdit = ConverToEdit(node);
			g_SearchName = pNameEdit:GetText();
			
	end--]]	
	return true;
end

---------------
--刷新信息
---------------
--刷新好友列表,初始化
function p.RefreshFriendContainer()	
    local friendList = p.GetFriendList();
	local nPlayerid = GetPlayerId();
	
	local container = p.GetFriendContainer();	
	container:RemoveAllView();
	

	 
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
		 
	     local uiLoad = createNDUILoad();
	     if uiLoad ~= nil then
		     uiLoad:Load("friend/friend_A_L.ini",view,p.OnUIEventFriendAction,0,0);
		     uiLoad:Free();
	     end	

		
		local l_name = SetLabel(view,ID_FRIEND_LIST_CTRL_HYPER_TEXT_NAME,friendItem[2]);
        ItemPet.SetLabelByQuality(l_name,FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_QUALITY,friendItem[1]));
        
        
		--SetLabel(view,ID_FRIEND_LIST_CTRL_HYPER_TEXT_LEVEL,string.format("等级:%d",friendItem[3]));
		SetLabel(view,ID_FRIEND_LIST_CTRL_HYPER_TEXT_LEVEL,"");

		--好友头像
		local nPetType = FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_PROFESSION,friendItem[1]) ;
        local Pic = p.getPicByPetType(nPetType);
		local HeadBtn = GetButton(view, ID_FRIEND_LIST_CTRL_BUTTON_13);
		HeadBtn:SetImage(Pic,true);
		--HeadBtn:EnalbeGray(false);		
		
		if friendItem[4] == 0 then
			--离线的好友字体为灰色
			local nameText = GetLabel(view,ID_FRIEND_LIST_CTRL_HYPER_TEXT_NAME);
			local levelText = GetLabel(view,ID_FRIEND_LIST_CTRL_HYPER_TEXT_LEVEL);
            
            
		   	nameText:SetFontColor(ccc4(88,88,88,255));
		   	levelText:SetFontColor(ccc4(88,88,88,255));
		   	--HeadBtn:EnalbeGray(true);
		end				
	end
end

function p.GameDataFriendInfoRefresh()

	if IsUIShow(NMAINSCENECHILDTAG.Friend) then
		 --好友面板已经开启,刷新列表
		p.RefreshFriendContainer();	
		p.RefreshInfoLayer();	
		
	--else
		--p.LoadUI();		
	end
end

function p.ClearInfoLayer()
	LogInfo("QBW1 clear info layer")
	local scene = GetSMGameScene();
	local layer = RecursiveUILayer(scene, {NMAINSCENECHILDTAG.Friend, TAG_FRIENDINFO_LAYER});
		
		if layer == nil then
			LogInfo("QBW1 info layer nil")
		end		

        SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_NAME, "");
        SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_LEVEL,"");
        SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_13,"");	
	 	SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_14,"");	
		SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_15,"");
	 	SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_16,"");
		SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_17,"");	

		--好友头像
		--local nPetType = FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_PROFESSION,friendItem[1]) ;
       	local pool = DefaultPicPool();
        local Pic = pool:AddPicture(GetSMImgPath("General/boxes/icon_portrait2.png"),false);
        --local Pic = p.getPicByPetType(nPetType);
		local HeadBtn = GetImage(layer, ID_FRIEND_INFO_CTRL_PICTURE_ROLE_ICON);
		HeadBtn:SetPicture(Pic,true);

				
end

function p.RefreshInfoLayer()
		LogInfo("QBW1 info layer 1")
		local scene = GetSMGameScene();
		local layer = RecursiveUILayer(scene, {NMAINSCENECHILDTAG.Friend, TAG_FRIENDINFO_LAYER});
		
		if layer == nil then
			LogInfo("QBW1 info layer nil")
			return;
		end
		
		LogInfo("QBW1 RefreshInfoLayer friendId:"..friendId)
		if  friendId  == 0 then
			p.ClearInfoLayer();
			return;
		end
		
		
		--LogInfo("QBW1 info layer 2")
		local nPlayerid = GetPlayerId();
        local l_name = SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_NAME, friendName);
         
         
        --设置好友玩家颜色
        --local nQuality = GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_QUALITY,friendId);
        ItemPet.SetLabelByQuality(l_name,FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_QUALITY,friendId));
        
         
        SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_LEVEL,SafeN2S(FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_LEVEL,friendId)).."级");
	
        local nPetType = FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_PROFESSION,friendId) ;
        
        local sProfession = GetDataBaseDataS("pet_config",nPetType,DB_PET_CONFIG.PRO_NAME);
        SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_13,sProfession);
	 	
	 	local nRanklevel =FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_REPUTE,friendId);
	 	LogInfo("QBW1 RefreshInfoLayer nRanklevel:"..nRanklevel)
	 	local stempstr = GetDataBaseDataS("rank_config",nRanklevel,DB_RANK.RANK_NAME);
	 	SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_14,stempstr);	
		--SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_14,SafeN2S(FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_REPUTE	,friendId)));	
		
		
		--帮派不显示
		--SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_15,SafeN2S(FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_SYNDYCATE,friendId)));
	 	SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_15,"");
	 	
	 	SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_16,SafeN2S(FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_SPORTS	,friendId)));
		SetLabel(layer, ID_FRIEND_INFO_CTRL_TEXT_17,SafeN2S(FriendFunc.GetAttrDesc(nPlayerid,FRIEND_DATA.FRIEND_CAPACITY	,friendId)));	
	
		
		--好友头像
		local Pic = p.getPicByPetType(nPetType);
		local HeadBtn = GetImage(layer, ID_FRIEND_INFO_CTRL_PICTURE_ROLE_ICON);
		HeadBtn:SetPicture(Pic,true);
		
		
		
end




---------------
--获取信息
---------------
--根据宠物id获取头像
function p.getPicByPetType(nPetType) -- PET ID
	if not CheckN(nPetType) then
		return nil;
	end
	

    if(nPetType == 0) then
        return nil;
    end
    local rtn = GetPetPotraitPic(nPetType);
    --local rtn = GetPlayerPotraitPic(nPetType);
    
	return rtn;
end


function p.GetBgLayer()
	local scene = GetSMGameScene();	
	local Bglayer = RecursiveUILayer(scene,{NMAINSCENECHILDTAG.Friend});
	return Bglayer
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


function p.GetFriendList()	
	local friendIdList = FriendFunc.GetFriendIdList(GetPlayerId());
	LogInfo("好友idList")
	LogInfoT(friendIdList)
	LogInfo("好友idList")
		
	local onList = {}
	local unList = {}
	
	for i,v in ipairs(friendIdList) do
		 local online = FriendFunc.GetAttrDesc(GetPlayerId(),FRIEND_DATA.FRIEND_ONLINE,v);	
		 local data ={}
		 --玩家id,玩家名称,等级,是否在线 
		 table.insert(data, v)
		 table.insert(data, FriendFunc.GetAttrDesc(GetPlayerId(),FRIEND_DATA.FRIEND_NAME,v))
		 table.insert(data, FriendFunc.GetAttrDesc(GetPlayerId(),FRIEND_DATA.FRIEND_LEVEL,v))
         table.insert(data, online)		 
		 if online ~= 0 then
		     table.insert(onList,data)
		 else
             table.insert(unList,data)
		 end
		 
	end	 

    --在线和离线好友分别 按等级进行排序
    p.SortTable(onList,3)
	p.SortTable(unList,3)
	
	local datalist = {};
	for i,v in ipairs(onList) do
		 table.insert(datalist,v)
	end
	for i,v in ipairs(unList) do
		 table.insert(datalist,v)
	end
	
	return datalist;
end	


--获取第一个玩家id
function p.GetFirstFriendId()

	local friendList = {}

	friendList = FriendFunc.GetFriendIdList(GetPlayerId());
	local nLength = #friendList;
	LogInfo("nLength:"..nLength)
	
	if friendList[nLength] ~= nil then
		friendId = friendList[nLength]
		 LogInfo("qbw3:"..friendId)
		 return friendId
	end	
	return 0
end

			
GameDataEvent.Register(GAMEDATAEVENT.FRIENDATTR, "p.GameDataFriendInfoRefresh", p.GameDataFriendInfoRefresh);
