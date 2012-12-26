---------------------------------------------------
--描述: 普通副本
--时间: 2012.3.15
--作者: wjl
---------------------------------------------------
ClearUpUI = {}
local p = ClearUpUI;

p.TagUiLayer = NMAINSCENECHILDTAG.AffixBossClearUp;
p.TagClose = 4;
p.TagContainer = 677;

-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;

local TagAearName1 = 6;
local TagAearName2 = 7;

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


p.mList = {}


function p.LoadUI()
	
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
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	
	uiLoad:Load("ClearList.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	uiLoad:Free();
	
	p.initData();
	p.initSubUI();

	
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then
			p.freeData();
			CloseUI(p.TagUiLayer);
			return true;
		elseif (TagAearName1 == tag ) then
			MsgAffixBoss.sendNmlOpen();
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
end

