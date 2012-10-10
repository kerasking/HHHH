---------------------------------------------------
--描述: 普通副本
--时间: 2012.3.15
--作者: wjl
---------------------------------------------------
ClearUpSettingUI = {}
local p = ClearUpSettingUI;

p.TagUiLayer = NMAINSCENECHILDTAG.AffixBossClearUpSet;
p.TagClose = 4;
p.TagContainer = 677;
p.TimeText = 7;

-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;

local TagBtStart_Cancel = 14;
local TagBtClose_Finish = 15;

local TagListBt ={
	138,
	139,
	57,
	58,
	59,
	55,
	56,
	60,
	61,
	62,
}

p.Flag = {
	Prepare = 1,
	Running = 2,
}

p.OpenText = {
	"开始",
	"取消",
}

p.FinishText = {
	"关闭",
	"立即完成",
}


p.mList = {}
p.mInstId = 0;
p.mRunFlag = 1;
p.mTimerTaskTag = nil;
p.mTimeSeconds = 0;


function p.LoadUI(instId)
	p.mInstId = instId;
	p.mRunFlag = p.Flag.Prepare;
	
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,load PlayerAttr failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(p.TagUiLayer);
	layer:SetFrameRect(RectUILayer);
	layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	
	uiLoad:Load("ClearList_B.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	uiLoad:Free();
	
	p.initData();
	p.initSubUI();

	
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent:%d" , tag);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then
			p.freeData();
			CloseUI(p.TagUiLayer);
			return true;
		elseif (TagBtStart_Cancel == tag ) then
			p.clickStarBt();
			--MsgAffixBoss.sendNmlOpen();
		elseif (TagBtClose_Finish == tag) then
			p.clickFinishBt();
		elseif (TagListBt[1] == tag) then
			MsgAffixBoss.sendEnter(p.mList[1].typeId);
		elseif (TagListBt[2] == tag) then
			MsgAffixBoss.sendClean(p.mList[1].typeId, 2);
		elseif (TagListBt[3] == tag) then
			MsgAffixBoss.sendCancel(p.mList[1].typeId);
		elseif (TagListBt[4] == tag) then
			MsgAffixBoss.sendFinish(p.mList[1].typeId);
		end
	end
	return true;
end


function p.initSubUI()
	--p.iniContainer();
	p.refreshRightLayout();
end

function p.refreshRightLayout()
	
	p.refreshButton();
end

function p.refreshButton()
	local layer = p.getUiLayer();
	local btSatr = GetButton(layer, TagBtStart_Cancel);
	local btClose = GetButton(layer, TagBtClose_Finish);
	if CheckP(btSatr) then
		btSatr:SetTitle(p.OpenText[p.mRunFlag]);
	end
	
	if CheckP(btClose) then
		btClose:SetTitle(p.FinishText[p.mRunFlag]);
	end
end

function p.iniContainer()
	local container = p.getContainerById(p.TagContainer);
	if not CheckP(container) then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	local rectview = container:GetFrameRect();
	
	container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
	
	local lst, count = MsgMagic.getRoleMatrixList();
	p.mMatrixList = lst;
	p.mCurrentPage = 1;
	
	
	if (count == nil or count < 1) then
		count = 1
	end
	local page = 1;--math.ceil((count-1)/3);
	
	for i = 1,  page do
	
	local view = createUIScrollView();
	
	if not CheckP(view) then
		LogInfo("view == nil");
		return;
	end
	view:Init(false);
	view:SetScrollStyle(UIScrollStyle.Horzontal);
	view:SetViewId(i);
	view:SetMovableViewer(container);
	view:SetScrollViewer(container);
	view:SetContainer(container);
	container:AddView(view);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	
	uiLoad:Load("NormalCopy_M.ini", view, p.OnUIEvent, 0, 0);
	
	uiLoad:Free();
   end
end


function p.getContainerById(nId)
	local layer = p.getUiLayer();
	local container = GetScrollViewContainer(layer, nId);
	return container;
	
end

function p.getUiLayer()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		return nil;
	end
	
	local layer = GetUiLayer(scene, p.TagUiLayer);
	if not CheckP(layer) then
		LogInfo("nil == layer")
		return nil;
	end
	
	return layer;
end


function p.clickButton(node) 
	
end

function p.clickStarBt()
	if (p.mRunFlag == p.Flag.Prepare) then
		p.mRunFlag = p.Flag.Running;
		local time = GetCurrentTime();
		p.mTimeSeconds =  time + 10;
		if (p.mTimerTaskTag) then
			UnRegisterTimer(p.mTimerTaskTag);
		end
		p.refreshRightLayout();
		p.mTimerTaskTag = RegisterTimer(p.timerCallback, 1);
	else 
		p.mRunFlag = p.Flag.Prepare;
		if (p.mTimerTaskTag) then
			UnRegisterTimer(p.mTimerTaskTag);
		end
		p.mTimeSeconds = 0;
		p.refreshRightLayout();
	end
	
end

function p.clickFinishBt()
	if p.mRunFlag == p.Flag.Running then
		p.mTimeSeconds = 0;
	else
		p.freeData();
		CloseUI(p.TagUiLayer);
	end
end


function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	--LogInfo(string.format("processNet%d" , msgId));
	--if msgId == NMSG_Type._MSG_MATRIX_ADD then
		
	--end
	
	CloseLoadBar();
end

function p.initData()
	--MsgMagic.mUIListener = p.processNet;
end

function p.freeData()
	--MsgMagic.mUIListener = nil;
	if (p.mTimerTaskTag) then
		UnRegisterTimer(p.mTimerTaskTag);
	end
end

function p.timerCallback(tag)
	if (tag and tag == p.mTimerTaskTag) then
		LogInfo("timerCallback");
		p.refreshTimeUI();
	end
end



function p.refreshTimeUI()
	
	local layer = p.getUiLayer();
	if not CheckP(layer) then
		return nil;
	end
	
	local txtV = GetLabel(layer, p.TimeText);
	local cool = p.mTimeSeconds;
	local curTime = GetCurrentTime();
	local time =  cool - curTime;
	LogInfo("cool:%d,cur:%d,time:%d", cool, curTime,time);
	local isVisible = true;
	if (time < 1) then
		isVisible = false;
		p.timeFinish();
	end
	if (txtV and isVisible) then
		local s = p.formatTime(time);
		LogInfo(s);
		txtV:SetText(s);
	end
	
	if (txtV) then
		txtV:SetVisible(isVisible);
	end
	
end

function p.timeFinish()
	if ( p.mTimerTaskTag ) then
		UnRegisterTimer(p.mTimerTaskTag);
	end
	p.mRunFlag = p.Flag.Prepare;
	p.refreshRightLayout();
end

--返回时间hh:mm:ss---
function p.formatTime(timeNum, format)
	if format == nil then
		format = "%02d:%02d:%02d"
	end
	return string.format(format, p.calculateTime(timeNum))
end

function p.calculateTime(timeNum)
	local nSec=timeNum
	local h=0
	local m=0
	local s=0
	h=math.floor(nSec/ 3600)
	m=math.floor((nSec%3600) /60)
	s=nSec%60

	return h,m,s
end


