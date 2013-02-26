---------------------------------------------------
--描述: 主界面聊天信息
--时间: 2012.7.9
--作者: qbw

---------------------------------------------------
local _G = _G;

ChatGameScene={}
local p=ChatGameScene;
local winsize	= GetWinSize();
local container	=nil;
local scroll	=nil;
local contentHight=0;

local gRectScaleY = 0.225;
--延迟显示ui时间
p.mTimerTaskTag = nil;

p.currentChatType=ChatType.CHAT_CHANNEL_ALL;

local text="";



function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load chatui failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	
	--LogInfo("get layer");
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ChatGameScene);
	layer:SetTouchEnabled(false);

	--layer:SetFrameRect(CGRectMake(winsize.w*0.1, winsize.h*0.5, winsize.w*0.3, winsize.h*0.3));
	layer:SetFrameRect(CGRectMake(winsize.w*0.1, winsize.h*0.6, winsize.w*0.7, winsize.h*gRectScaleY));
	layer:SetBackgroundColor(ccc4(0,0,0,30));
	
	scene:AddChildZ(layer,4999);


	local rectX = winsize.w*0.1;
	local rectW	= winsize.w*0.7;

	local rect  = CGRectMake(0, 0, rectW, winsize.h*gRectScaleY); 
	
	container = createUIScrollContainer();
	if container == nil then
		LogInfo("container == nil,load ChatGameScene failed!");
		return;
	end
	container:Init();
	container:SetFrameRect(rect);
	container:SetTopReserveDistance(winsize.h*0.6);
	container:SetBottomReserveDistance(winsize.h*0.6);
	container:EnableScrollBar(false);
	container:SetTouchEnabled(false);
	
	layer:AddChild(container);
	
		
	local scrollrect = CGRectMake(0.0, 0.0, rectW, winsize.h*gRectScaleY);
	scroll = createUIScroll();
	if (scroll == nil) then
		LogInfo("scroll == nil,load ChatGameScene failed!");
		container:RemoveFromParent(true);
		return;
	end
	scroll:Init(true);
	scroll:SetFrameRect(scrollrect);
	scroll:SetScrollStyle(UIScrollStyle.Verical);
	scroll:SetMovableViewer(container);
	scroll:SetContainer(container);
	scroll:SetTouchEnabled(false);
	container:AddChild(scroll);
	
	
	contentHight=0;
	
	
	ChatDataFunc.AddAllChatRecordGameScene();
	container:ScrollToBottom();
    
    --** chh 2012-08-08 **--
    --设置隐藏偏移
    if(MainUIBottomSpeedBar.ShowHideState == 1) then
        MainUIBottomSpeedBar.messSetOffset(1, MainUIBottomSpeedBar.ShowHideHeight);
    end
    
    if p.mTimerTaskTag == nil then
    	LogInfo("gamescene loadui p.mTimerTaskTag nil")
    	layer:SetVisible(false);
    end
    LogInfo("gamescene loadui p.mTimerTaskTag 2")
end


function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ChatGameScene);
	
	if nil == layer then
		--LogInfo("DelayShowUI GetParent return parent nil")
		return nil;
	end

	return layer;
end

function p.AddChatText(speakerId,channel,speaker,text,nindex)
	LogInfo("gamescene chat AddChatText speaker"..speaker)
	if p.currentChatType==channel
		or p.currentChatType==ChatType.CHAT_CHANNEL_ALL then
	
		LogInfo("gamescene chat AddChatText1")
		
		local layer=p.GetParent();
		if nil==layer then
			return false;
		end
		if nil == scroll then
			return false;
		end
		LogInfo("gamescene chat AddChatText2")
		local chatText=createUIChatText();
		chatText:Init();
		chatText:SetContentWidth(winsize.w*0.7);
		
		local color = ChatMainUI.ColorChannel[channel];
		chatText:SetContent(speakerId,channel,speaker,text,1,6,color);
		chatText:SetTag(nindex);
		--chatText:SetContent(speakerId,channel,speaker,text,1,6,ccc4(0,0,255,255));
		local rect  = CGRectMake(0, contentHight, winsize.w*0.7, winsize.h*0.05); 
		chatText:SetFrameRect(rect);
		contentHight=contentHight+winsize.h*gRectScaleY/5.0; --chatText:GetContentHeight();
		
		LogInfo("gamescene chat AddChatText3")
		
		local scrollrect = CGRectMake(0.0, 0.0, winsize.w*0.7, contentHight);
		scroll:SetFrameRect(scrollrect);
		scroll:AddChild(chatText);
		
		if OnlineCheckIn.InInCity() == false then
			LogInfo("gamescene chat not InInCity")
			layer:SetVisible(false);
		else
			LogInfo("gamescene chat InInCity ")
			layer:SetVisible(true);
		end
	end
	
	container:ScrollToBottom();
	return true;
end

function p.RemoveChatText(nindex)
	if scroll ~= nil then
		scroll:RemoveChildByTag(nindex, true);
	end
end



local gCount =0;
function p.DelayShowUI()
	

	--LogInfo("DelayShowUI OnlineCheckIn.InInCity() true")
	if CheckP(p.GetParent()) == false then
		--LogInfo("DelayShowUI parent nil loadui")
		p.LoadUI()		
	else
		local Chatlayer = p.GetParent();
		--if OnlineCheckIn.InInCity()  then
		--不在主城则不显示
			Chatlayer:SetVisible(true);	
		--end	
	end
	
	if (p.mTimerTaskTag) then
		UnRegisterTimer(p.mTimerTaskTag);
		p.mTimerTaskTag = nil;
	end
	gCount = 0;
	p.mTimerTaskTag = RegisterTimer(p.SetUIInvisible, 1);

end


--设置隐藏ui
function p.SetUIInvisible()
	if CheckP(p.GetParent()) == false then
		return;	
	end
	local Chatlayer = p.GetParent();
	
	--if OnlineCheckIn.InInCity() == false then
	--	Chatlayer:SetVisible(false);
	--	return;				
	--end
	
	
	gCount = gCount +1;
	
	if gCount < 8 then
		Chatlayer:SetVisible(true);
		return;
	end
	
	gCount = 0;
	Chatlayer:SetVisible(false);
	
	--不在主城则不显示	
	if (p.mTimerTaskTag) then
		UnRegisterTimer(p.mTimerTaskTag);
		p.mTimerTaskTag = nil;
	end	--]]
end


--RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "ChatGameScene.LoadUI", p.DelayShowUI);

