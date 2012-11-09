---------------------------------------------------
--描述: 赠送鲜花UI
--时间: 2012.4.16
--作者: fyl
---------------------------------------------------



GiveFlowersUI = {}
local p = GiveFlowersUI;

local ID_FLOWERS_CTRL_TEXT_LIST5					= 41;
local ID_FLOWERS_CTRL_TEXT_LIST4				    = 40;
local ID_FLOWERS_CTRL_TEXT_LIST3					= 39;
local ID_FLOWERS_CTRL_TEXT_LIST2					= 38;
local ID_FLOWERS_CTRL_TEXT_LIST1					= 35;
local ID_FLOWERS_CTRL_PICTURE_34					= 34;
local ID_FLOWERS_CTRL_PICTURE_33					= 33;
local ID_FLOWERS_CTRL_PICTURE_32					= 32;
local ID_FLOWERS_CTRL_PICTURE_LIST_PLAY2			= 31;
local ID_FLOWERS_CTRL_PICTURE_30					= 30;
local ID_FLOWERS_CTRL_TEXT_FLOWER33				= 29;
local ID_FLOWERS_CTRL_TEXT_FLOWER32				= 28;
local ID_FLOWERS_CTRL_TEXT_FLOWER31				= 27;
local ID_FLOWERS_CTRL_TEXT_FLOWER23				= 26;
local ID_FLOWERS_CTRL_TEXT_FLOWER22				= 25;
local ID_FLOWERS_CTRL_TEXT_FLOWER21				= 24;
local ID_FLOWERS_CTRL_TEXT_FLOWER13				= 23;
local ID_FLOWERS_CTRL_TEXT_FLOWER12				= 22;
local ID_FLOWERS_CTRL_TEXT_FLOWER11				= 21;
local ID_FLOWERS_CTRL_BUTTON_SEND_FLOWER3			= 20;
local ID_FLOWERS_CTRL_BUTTON_SEND_FLOWER2			= 19;
local ID_FLOWERS_CTRL_BUTTON_SEND_FLOWER1			= 18;
local ID_FLOWERS_CTRL_PICTURE_FLOWER3				= 17;
local ID_FLOWERS_CTRL_PICTURE_FLOWER2				= 16;
local ID_FLOWERS_CTRL_PICTURE_FLOWER1				= 15;
local ID_FLOWERS_CTRL_PICTURE_FLOWER3_BG			= 14;
local ID_FLOWERS_CTRL_PICTURE_FLOWER2_BG			= 13;
local ID_FLOWERS_CTRL_PICTURE_FLOWER1_BG			= 12;
local ID_FLOWERS_CTRL_PICTURE_FLOWERS_LIST		= 10;
local ID_FLOWERS_CTRL_BUTTON_FLOWER_LIST			= 9;
local ID_FLOWERS_CTRL_TEXT_FLOWER_NUM				= 8;
local ID_FLOWERS_CTRL_TEXT_7						= 7;
local ID_FLOWERS_CTRL_PICTURE_PLAY_HEAD			= 6;
local ID_FLOWERS_CTRL_PICTURE_5						= 5;
local ID_FLOWERS_CTRL_TEXT_4						= 4;
local ID_FLOWERS_CTRL_BUTTON_3						= 3;
local ID_FLOWERS_CTRL_PICTURE_TITAL				= 2;
local ID_FLOWERS_CTRL_PICTURE_BG					= 1;



local giveFlowerNum = 0;
local playerId ;
local textIdList = {}

-----------------------
-----------------------

function p.LoadUI(id,flowerNum,giveRecordList)
    p.Init();
	playerId = id;

	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load GiveFlowersUI failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.GiveFlowers);
	layer:SetFrameRect(RectUILayer);
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("Flowers.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
	
	--鲜花总数
	SetLabel(layer, ID_FLOWERS_CTRL_TEXT_FLOWER_NUM, SafeN2S(flowerNum));
	
	LogInfo(SafeN2S(#giveRecordList))
	
	if #giveRecordList > 0 and #giveRecordList < 6 then
	    for i = 1,#giveRecordList do 
		     --record={1玩家名称，2赠送时间,3鲜花朵数}		
		     local record  = giveRecordList[i];
	         local str = string.format("[玩家]:%s赠送了您%d朵花 %s",record[1],record[3],p.GetTimeStr(record[2])); 
	         SetLabel(layer, textIdList[i], str);
	    end
	
	    if #giveRecordList < 5 then
	        p.SetGiveRecordTextHide(#giveRecordList + 1);
		end
	else 	
	    p.SetGiveRecordTextHide(1);
	end
	
	--设置鲜花榜按钮监听
	local flowerListBtn  = GetButton(layer, ID_FLOWERS_CTRL_BUTTON_FLOWER_LIST);
	flowerListBtn:SetLuaDelegate(p.OnUIEventOpenFlowerList); 
	
	--设置赠送鲜花按钮监听
	local btn  = GetButton(layer, ID_FLOWERS_CTRL_BUTTON_SEND_FLOWER1);
	local btn2 = GetButton(layer, ID_FLOWERS_CTRL_BUTTON_SEND_FLOWER2);
	local btn3 = GetButton(layer, ID_FLOWERS_CTRL_BUTTON_SEND_FLOWER3);
	btn:SetLuaDelegate(p.OnUIEventGiveFlower); 
    btn2:SetLuaDelegate(p.OnUIEventGiveFlower); 
	btn3:SetLuaDelegate(p.OnUIEventGiveFlower); 	
end

function p.GetTimeStr(minuteNum)
    local timeStr = "";
    if minuteNum < 60 then
	    timeStr = string.format("%2d分钟前",minuteNum);
	elseif (minuteNum/60) <	24 then
	        timeStr = string.format("%2d小时前",minuteNum/60);
	else	
	    timeStr = string.format("%2d天前",minuteNum/1440);
	end
	return timeStr ;
end

function p.ResGiveFlower()
    CommonDlg.ShowTipInfo("提示", "赠送成功!", nil, 2);
end

function p.SetGiveRecordTextHide(index)
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.GiveFlowers);
	if nil == layer then
		return nil;
	end

    for i = index,5 do
		 --LogInfo(SafeN2S(i));
         local giveRecordText = GetLabel(layer,textIdList[i]);
		 giveRecordText:SetVisible(false);
    end
end

function p.Init()
   textIdList[1] = ID_FLOWERS_CTRL_TEXT_LIST1;
   textIdList[2] = ID_FLOWERS_CTRL_TEXT_LIST2;
   textIdList[3] = ID_FLOWERS_CTRL_TEXT_LIST3;
   textIdList[4] = ID_FLOWERS_CTRL_TEXT_LIST4;
   textIdList[5] = ID_FLOWERS_CTRL_TEXT_LIST5;
end



---------------
--UI事件处理回调函数
---------------
function p.OnUIEventGiveFlower(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventGiveFlower[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then		
		local reqMoney;
		local reqEMoney;	
		local eMoney = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY); 	
		
		if tag ==  ID_FLOWERS_CTRL_BUTTON_SEND_FLOWER1 then
			giveFlowerNum = 1;
			CommonDlg.ShowNoPrompt("是否花费1000银币，赠送1朵鲜花，获得10点声望？", p.OnCommonDlgSendGiveFlower , true);				

		elseif tag == ID_FLOWERS_CTRL_BUTTON_SEND_FLOWER2 then
				giveFlowerNum = 9;
				CommonDlg.ShowNoPrompt("是否花费9金币，赠送9朵鲜花，获得20点声望？", p.OnCommonDlgSendGiveFlower , true);	
		elseif tag == ID_FLOWERS_CTRL_BUTTON_SEND_FLOWER3 then
				giveFlowerNum = 99;
				CommonDlg.ShowNoPrompt("是否花费99金币，赠送99朵鲜花，获得520点声望？", p.OnCommonDlgSendGiveFlower , true);	
		end
	end	
	
	return true;
		
end


function p.OnUIEvent(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		if tag == ID_FLOWERS_CTRL_BUTTON_3 then
			--关闭界面
			CloseUI(NMAINSCENECHILDTAG.GiveFlowers);
	    end
	end
	
	return true;
end

function p.OnUIEventOpenFlowerList(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		MsgFriend.SendFlowerRank();
   end
   
   return true;
end

---------------
--对话框回调函数
---------------
function p.OnCommonDlgSendGiveFlower(nId, nEvent, param)
	if nEvent == CommonDlg.EventOK then
	
		local reqMoney;
		local reqEMoney;	
		local eMoney = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY); 	
		LogInfo("玩家身上金币%d",eMoney)
		
		if giveFlowerNum ==  1 then
		    reqMoney = 1000;
		    local money = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_MONEY);
			LogInfo("玩家身上银币%d",money) 
		    if reqMoney  > money then
		        CommonDlg.ShowTipInfo("提示", "银币不足!", nil, 2);
			else
				MsgFriend.SendGiveFlower(playerId,1);				
		    end
		elseif giveFlowerNum == 9 then
		        reqEMoney = 9;
		        if reqEMoney  > eMoney then
		            CommonDlg.ShowTipInfo("提示", "金币不足!", nil, 2);
			    else
					MsgFriend.SendGiveFlower(playerId,9);
		        end
		elseif giveFlowerNum == 99 then
		        reqEMoney = 99;
		        if reqEMoney  > eMoney then
		            CommonDlg.ShowTipInfo("提示", "金币不足!", nil, 2);
			    else
					MsgFriend.SendGiveFlower(playerId,99);
		        end
		end
	end
end	






