---------------------------------------------------
--描述: 普通副本
--时间: 2012.3.15
--作者: wjl
---------------------------------------------------
NormalBossListUI = {}
local p = NormalBossListUI;

p.TagUiLayer = NMAINSCENECHILDTAG.AffixNormalBoss;
p.TagClose = 3;
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

local TagTip = 9999;
local TagAim_MATERIAL = 1; -- 材料
local TagAim_TASK = 0; -- 任务

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

local TagBossListPic = {
	628,
	629,
	630,
	631,
	632,
	633,
	634,
	635,
	636,
	637,
}

local TagBossListName = {
	23,
	36,
	38,
	39,
	40,
	41,
	42,
	43,
	44,
	45,
}

local TagBossListStar = {
	24,
	46,
	47,
	48,
	49,
	50,
	51,
	52,
	53,
	54,
}

local TagBossListNum = {
	26,
	27,
	28,
	29,
	30,
	31,
	32,
	33,
	34,
	35,
}

p.mParentMap = 1;  -- 传送点所在地图ID
p.mPassway = 0;  -- 传送点ID
p.mList = {}
p.mCount = 0;

function p.LoadUIByBossId(nBossId, nAim)
	local elite = AffixBossFunc.findElite(nBossId);
	LogInfo("elite%d, %d", elite, nBossId);
	local nParentMapId = AffixBossFunc.findMapId(elite, nBossId);
	LogInfo("nParentMapId%d", nParentMapId);
	if ( nPassWayIndex == 1) then
		NormalBossEliteListUI.LoadUI(nParentMapId, elite, nBossId, nAim);
	else
		p.LoadUI(nParentMapId, elite, nBossId, nAim);
	end
end

--通过地图id及切屏点索引打开副本界面
function p.LoadUIBySwitch(nMapId, nPassWayIndex)
	if ( nPassWayIndex == 1) then
		NormalBossEliteListUI.LoadUI(nMapId, nPassWayIndex);
	else 
		--p.LoadUI(nMapId, nPassWayIndex);
		p.LoadUIByBossId(904400000,0)
	end
end

function p.LoadUI(nParentMapId, nPassway, nBossId, nAim)
	LogInfo("mapId:%d nPassway:d nBossId:d nAim:d", nParentMapId);
	if not CheckN(nParentMapId)  then
		p.mParentMap = 1;
	else
		p.mParentMap = nParentMapId;
	end
	
	
	
	if not CheckN(nPassway) then
		p.mPassway = 0
	else
		p.mPassway = nPassway;
	end
	
	
	
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
	
	uiLoad:Load("NormalCopy.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	uiLoad:Free();
	
	p.initData();
	p.initSubUI();
	
	if (nBossId) then
		nAim = nAim or 0;
		p.showItemInfoDlg(nBossId, nAim);
	end
	
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("tag:" .. tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then
			p.close();
		elseif (TagAearName1 == tag ) then
			MsgAffixBoss.sendNmlOpen();
		elseif (TagListBt[1] == tag) then
			p.close();
			ClearUpSettingUI.LoadUI(2);
		elseif (TagListBt[2] == tag) then
			MsgAffixBoss.sendNmlEnter(981900000);
		elseif (TagListBt[3] == tag) then
			MsgAffixBoss.sendNmlLeave();
		elseif (TagListBt[7] == tag) then
			MsgAffixBoss.sendClean(p.mList[1].typeId, 2);
		elseif (TagListBt[8] == tag) then
			MsgAffixBoss.sendCancel(p.mList[1].typeId);
		elseif (TagListBt[9] == tag) then
			MsgAffixBoss.sendFinish(p.mList[1].typeId);
		end
	end
	return true;
end


function p.initSubUI()
	p.refreshContainer();
end

--物品信息层初始化
function p.showItemInfoDlg(nBossId, nAim)
	local nX = 100;
	local nY = 100;
	LogInfo("intem info dlg.");
	local layer = p.getUiLayer();
	layer:RemoveChildByTag(TagTip, true);
	local str = "";
	if (nAim == TagAim_MATERIAL) then
		str = "材料掉落地"
	elseif (nAim == TagAim_TASK) then
		str = "当前任务副本"
	else
	  return;
	end
	
	local container = p.getContainerById(p.TagContainer);
	if not CheckP(container) then
		LogInfo("nil == container");
		return;
	end
	
	local lst, count = AffixBossFunc.findBossList(p.mParentMap, p.mPassway);
	local index = 1;
	for i = 1, count do
		if nBossId == lst[i] then
			index = i;
		end
	end
	
	local page = math.ceil((index)/ 10);
	local ind	= index - (page -1) * 10
	local scrollView = container:GetViewById(page);
	if not CheckP(scrollView) then
		LogInfo("..1");
	end
	LogInfo("ind%d..11", ind);
	local view = GetButton(scrollView, TagBossListPic[ind]);
	if CheckP(view) then
	LogInfo("..2");
		local rect = view:GetFrameRect()
		nX = rect.origin.x;
		nY = rect.origin.y;
	else 
		
 	end
	
	LogInfo("nx%dny%d..32", nX, nY);
	
	local lb = _G.CreateColorLabel(str, 14, 14*10);
	if CheckP(lb) then
		lb:SetTag(TagTip);
		lb:SetFrameRect(CGRectMake(nX, nY, 14*20, 20 * ScaleFactor));
		layer:AddChildZ(lb, 1);
		return true;
	end
end

function p.refreshContainer()
	local container = p.getContainerById(p.TagContainer);
	if not CheckP(container) then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	local rectview = container:GetFrameRect();
	
	container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
	
	local lst, count = AffixBossFunc.findBossList(p.mParentMap, p.mPassway);
	LogInfo("count:" .. count);
	p.mList = lst;
	p.mCount = count;
	p.mCurrentPage = 1;
	
	
	if (count == nil or count < 1) then
		count = 1
	end
	local page = math.ceil((count)/ 10);
	
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
	
		uiLoad:Load("NormalCopy_M.ini", view, p.onListItemEvent, 0, 0);
		uiLoad:Free();
	
		for j = 1, 10 do 
			p.refreshItemView(view, lst[(i - 1) * 10 + j], j);
		end
   end
end

function p.refreshItemView(view, t, index) 
	local picV		= GetButton(view, TagBossListPic[index]);
	local nameV		= GetLabel(view, TagBossListName[index]);
	--local numV		= GetLabel(view, TagBossListNum[index]);
	--local cleanV	= GetButton(view, TagBossListBt[index]);
	local starV		= GetImage(view, TagBossListStar[index]);
	
	if (t) then
		nameV:SetText(ConvertS(t.name));
		--numV:SetText(ConvertN(t.order));
	else
		picV:SetVisible(false);
		nameV:SetVisible(false);
	end
end

function p.onListItemEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("tag:" .. tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		for i = 1, #TagBossListPic do
			if (TagBossListPic[i] == tag) then
				p.enterBoss(i);
				return true;
			end
		end
		
		for i = 1, #TagListBt do
			if (TagListBt[i] == tag) then
				p.clear(i);
				return true;
			end
		end
		
	end
	return true;
end

function p.close() 
	p.freeData();
	CloseUI(p.TagUiLayer);
end

function p.enterBoss(i)

	local t = p.mList[(p.mCurrentPage - 1) * 10 + i];
	if t then
		MsgAffixBoss.sendNmlEnter(t.typeid);
	end
end

function p.clear(i)
	--MsgAffixBoss.sendClean(p.mList[1].typeId, 2);
	p.close();
	ClearUpUI.LoadUI(2);
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

-- return NDPicture
function p.getSatrPic(nId)
	
	local rtn = nil;
	if not nId then
		return nil;
	end
	
	local pool = DefaultPicPool();
	
	if (nId == 1) then
		rtn = pool:AddPicture(GetImgPathNew("avatar1.png"), false)
	elseif (nId == 2) then
		rtn = pool:AddPicture(GetImgPathNew("avatar2.png"), false)
	end
	
	return rtn;
end

-- return NDPicture
function p.getPic(nId)
	
	local rtn = nil;
	if not nId then
		return nil;
	end
	
	local pool = DefaultPicPool();
	
	if (nId == 1) then
		rtn = pool:AddPicture(GetSMImgPath("avatar1.png"), false)
	elseif (nId == 2) then
		rtn = pool:AddPicture(GetSMImgPath("avatar2.png"), false)
	end
	
	return rtn;
end
