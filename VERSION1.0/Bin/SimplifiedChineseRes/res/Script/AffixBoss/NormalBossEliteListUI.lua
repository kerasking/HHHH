---------------------------------------------------
--描述: 普通精英副本
--时间: 2012.3.15
--作者: wjl
---------------------------------------------------
NormalBossEliteListUI = {}
local p = NormalBossEliteListUI;

local ID_HEROCOPY_M_CTRL_PICTURE_STAR_K5				= 1049;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_K4				= 1048;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_K3				= 1047;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_K2				= 1046;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_K1				= 1024;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_J5				= 949;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_J4				= 948;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_J3				= 947;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_J2				= 946;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_J1				= 924;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_I5				= 849;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_I4				= 848;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_I3				= 847;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_I2				= 846;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_I1				= 824;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_H5				= 749;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_H4				= 748;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_H3				= 747;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_H2				= 746;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_H1				= 724;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_G5				= 649;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_G4				= 648;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_G3				= 647;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_G2				= 646;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_G1				= 624;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_F5				= 549;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_F4				= 548;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_F3				= 547;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_F2				= 546;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_F1				= 524;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_E5				= 449;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_E4				= 448;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_E3				= 447;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_E2				= 446;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_E1				= 424;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_D5				= 349;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_D4				= 348;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_D3				= 347;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_D2				= 346;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_D1				= 324;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_C5				= 249;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_C4				= 248;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_C3				= 247;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_C2				= 246;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_C1				= 224;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_B5				= 149;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_B4				= 148;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_B3				= 147;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_B2				= 146;
local ID_HEROCOPY_M_CTRL_PICTURE_STAR_B1				= 124;

p.TagUiLayer = NMAINSCENECHILDTAG.AffixEliteBoss;
p.TagClose = 3;
p.TagContainer = 677;
p.TagPreArea = 6;
p.TagNextArea = 7;
p.TagCear = 8;
p.TagTitle = 2;
p.TagPower = 5;
p.TagReset = 109;
p.PerPageSize = 10;


local TagTip = 9999;
local TagAim_MATERIAL = 1; -- 材料
local TagAim_TASK = 0; -- 任务

-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;
p.mTimerTaskTag = nil;


local TagStarList = {
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_B3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_B2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_B4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_B1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_B5,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_C3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_C2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_C4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_C1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_C5,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_D3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_D2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_D4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_D1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_D5,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_E3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_E2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_E4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_E1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_E5,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_F3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_F2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_F4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_F1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_F5,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_G3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_G2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_G4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_G1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_G5,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_H3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_H2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_H4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_H1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_H5,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_I3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_I2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_I4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_I1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_I5,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_J3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_J2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_J4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_J1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_J5,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_K3,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_K2,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_K4,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_K1,
	ID_HEROCOPY_M_CTRL_PICTURE_STAR_K5,
}


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
p.mCurrentPage = 1
p.mHasCleanOUt = false;


function p.LoadUI(nParentMapId, nPassway, nBossId, nAim)
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
	
	uiLoad:Load("HeroCopy.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	uiLoad:Free();
	
	
	-- 体力值
	local powerV = GetLabel(layer, p.TagPower)
	local power = PlayerFunc.GetStamina(GetPlayerId());
	LogInfo("power:%d", power);
	if (CheckP(powerV)) then
		powerV:SetText(SafeN2S(power));
	end
	
	-- 重置
	local resetV = GetButton(layer, p.TagReset)
	if (not PlayerVip.hasResetEliteBoss() and CheckP(resetV)) then
		resetV:SetVisible(false);
	end
	
	
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
			return true;
		elseif (p.TagPreArea == tag ) then
			p.clickPre();
		elseif (p.TagNextArea == tag) then
			p.clickNext();
		elseif (p.TagCear == tag) then
			p.close();
			ClearUpEliteSettingUI.LoadUI(p.mParentMap);
		elseif (p.TagReset == tag) then
			p.sendReset();
		end
		
	elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		local tag = uiNode:GetTag();
		LogInfo("p.OnUIEventViewChange[%d]", tag);
		local containter	= ConverToSVC(uiNode);
		if CheckP(containter) and CheckN(param) then
			local beginView	= containter:GetView(param);
			if CheckP(beginView) and p.TagContainer == tag then
				local page	= beginView:GetViewId()
				p.mCurrentPage = page
				p.refreshTitle();
				
			end
		end
	end
	return true;
end

function p.sendReset()
 ShowLoadBar();
 MsgAffixBoss.sendNmlReset(p.mParentMap);
end


function p.initSubUI()
	p.refresh();
	p.mTimerTaskTag = RegisterTimer(p.timerCallback, 5); -- 5s
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
	local index = getMaxIndex(nBossId, lst, count);
	
	local page = math.ceil((index)/ 10);
	LogInfo("index%d,page%d", index, page);
	container:ScrollViewById(page);
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
	
	local lb = createNDUIImage();
	lb:Init();
	
	--local lb = _G.CreateColorLabel(str, 14, 14*10);
	if CheckP(lb) then
		local pic = p.getTipPic(nAim);
		if (pic) then
			local size = pic:GetSize();
			lb:SetPicture(pic, true);
			lb:SetTag(TagTip);
			lb:SetFrameRect(CGRectMak(nX+ 20 * ScaleFactor, nY, size.w, size.h));
			layer:AddChildZ(lb, 1);
		end
		return true;
	end
end

function getMaxIndex(nBossId, lst, count) 
  if (lst == nil) then
	return 1;
  end
  for i = 1, count do
	if nBossId == lst[i].typeid or lst[i + 1] == nil or lst[i + 1].status == 0 then -- 当前或锁住状态
		return i;
	end
  end
  return 1;
end

function p.refresh()
	local layer = p.getUiLayer();
	
	local preV = GetButton(layer, p.TagPreArea);
	local nextV = GetButton(layer, p.TagNextArea);
	
	local preName = nil;
	local nextName = nil;
	local index = AffixBossEliteMapList.getIndex(p.mParentMap);
	if (index and index > 0 ) then
	   local preId = AffixBossEliteMapList.getIdByIndex(index - 1);
	   local nextId = AffixBossEliteMapList.getIdByIndex(index + 1);
	   if (preId) then
			preName = AffixBossFunc.findName(preId);
	   end
	   if (nextId) then
			nextName = AffixBossFunc.findName(nextId);
	   end
	end
	
	if CheckP(preV) then
		if (preName) then
			preV:SetVisible(true);
			preV:SetTitle("←"..preName);
		else
			preV:SetVisible(false);
		end
	end
	
	if CheckP(nextV) then
		if (nextName) then
			nextV:SetVisible(true);
			nextV:SetTitle(nextName.."→");
		else
			nextV:SetVisible(false);
		end
	end
	
	p.mHasCleanOUt = false;
	
	p.refreshContainer();
	
	p.refreshTitle();
	
	
	local clearV = GetButton(layer, p.TagCear);
	if (p.mHasCleanOUt == true) then
		clearV:SetVisible(true);
	else
		clearV:SetVisible(false);
	end
	
end

function p.refreshTitle()
	local layer = p.getUiLayer();
	local titleV = GetLabel(layer, p.TagTitle);
	local name = AffixBossFunc.findName(p.mParentMap);
	local title = "精英副本"
	
	local curpage = p.mCurrentPage or 1;
	if (p.mCount and p.mCount > p.PerPageSize) then 
		local page = math.ceil((p.mCount)/ p.PerPageSize);
		title = string.format("“%s”%s(%d/%d)", name, title, curpage,page);
	elseif name then
		title = string.format("“%s”%s", name, title);
	end
	if CheckP(titleV) then
		titleV:SetText(title);
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
	
	LogInfo("size.w %d", rectview.size.w);
	
	container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
	
	local lst, count = AffixBossFunc.findBossList(p.mParentMap, p.mPassway);
	LogInfo("count:" .. count);
	p.mList = lst;
	p.mCount = count;
	p.mCurrentPage = p.mCurrentPage or 1;
	
	
	if (count == nil or count < 1) then
		count = 1
	end
	local page = math.ceil((count)/ p.PerPageSize);
	
	for i = 1,  page do
	
		local view = createUIScrollView();
	
		if not CheckP(view) then
			LogInfo("view == nil");
			return;
		end
		view:Init(false);
		--view:SetScrollStyle(UIScrollStyle.Horzontal);
		view:SetViewId(i);
		--view:SetMovableViewer(container);
		--view:SetScrollViewer(container);
		--view:SetContainer(container);
		container:AddView(view);
	
		--初始化ui
		local uiLoad = createNDUILoad();
		if not CheckP(uiLoad) then
			return false;
		end
	
		uiLoad:Load("HeroCopy_M.ini", view, p.onListItemEvent, 0, 0);
		uiLoad:Free();
	
		for j = 1, p.PerPageSize do 
			p.refreshItemView(view, lst[(i - 1) * p.PerPageSize + j], j, (i - 1) * p.PerPageSize + j);
		end
   end
end

function p.refreshItemView(view, t, index, lstIndex) 
	local picV		= GetButton(view, TagBossListPic[index]);
	local nameV		= GetLabel(view, TagBossListName[index]);
	--local numV		= GetLabel(view, TagBossListNum[index]);
	--local cleanV	= GetButton(view, TagBossListBt[index]);
	--local starV		= GetImage(view, TagBossListStar[index]);
	
	
	local pIndex = (index -1)*5 + 1
	local userStage = PlayerFunc.GetPlayerStage();
	local systime = GetCurrentTime();
	
	if (t) then
		local needStage = AffixBossFunc.findStage(t.typeid);
		LogInfo("needStage%d", needStage);
		
		local preItem = p.mList[lstIndex - 1]; -- 第一个前一个为nil
		
		if (((not preItem) or preItem.rank > 0) and needStage <= userStage) then
			nameV:SetText(ConvertS(t.name));
			--numV:SetText(ConvertN(t.order));
			local pic = p.getBossPic(t.typeid);
			if CheckP(pic) then
				picV:SetImage(pic);
			end
			if (t.time > 0 and t.time > systime) then -- cd time
				picV:EnalbeGray(true);
			else 
				if (t.rank > 0 ) then
					p.mHasCleanOUt = true;
				end
				picV:EnalbeGray(false);
			end
		else 
			nameV:SetText("");
			picV:SetImage(p.getLockPic());
			picV:EnalbeGray(true);
		end
		
		for k = pIndex + t.rank, pIndex + 4 do 
			local img = GetImage(view, TagStarList[k]);
			if (CheckP(img)) then
				img:SetVisible(false);
			end
		end
		
		
	else
		for k = pIndex, pIndex + 4 do 
			local img = GetImage(view, TagStarList[k]);
			if (CheckP(img)) then
				img:SetVisible(false);
			end
		end
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
	local t = p.mList[(p.mCurrentPage - 1) * p.PerPageSize + i];
	if t then
		MsgAffixBoss.sendNmlEnter(t.typeid);
	end
end

function p.clear(i)
	--MsgAffixBoss.sendClean(p.mList[1].typeId, 2);
	p.close();
	ClearUpUI.LoadUI(p.mParentMap);
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

function p.clickPre()
	p.mCurrentPage = 1;
	local index = AffixBossEliteMapList.getIndex(p.mParentMap);
	if index and index > 0 then
		local id = AffixBossEliteMapList.getIdByIndex(index - 1);
		if (id) then
			p.mParentMap = id;
			p.refresh();
		end
	end
	
end

function p.clickNext()
	p.mCurrentPage = 1;
	local index = AffixBossEliteMapList.getIndex(p.mParentMap);
	if index and index > 0 then
		local id = AffixBossEliteMapList.getIdByIndex(index + 1);
		if (id) then
			p.mParentMap = id;
			p.refresh();
		end
	end
end

function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	--LogInfo(string.format("processNet%d" , msgId));
	if msgId == NMSG_Type._MSG_AFFIX_BOSS_NML_RESET then
		p.refreshCurPageItem();
		CloseLoadBar();
	end
	
	
end

function p.initData()
	MsgAffixBoss.mUIListener = p.processNet;
	p.mCurrentPage  = 1;
end

function p.freeData()
	MsgAffixBoss.mUIListener = nil;
	if ( p.mTimerTaskTag ) then
		UnRegisterTimer(p.mTimerTaskTag);
	end
	p.mTimerTaskTag = nil;
end

-- return NDPicture
function p.getBossPic(nId)
	
	local rtn = nil;
	if not nId then
		return nil;
	end
	
	local pool = DefaultPicPool();
	
	rtn = pool:AddPicture(GetSMImgPath("boss_snake.png"), false)
	
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

function p.getTipPic(nTyp)

local rtn = nil;
	if not nTyp then
		return nil;
	end
	
	local pool = DefaultPicPool();
	
	if (nTyp == TagAim_MATERIAL) then
		rtn = pool:AddPicture(GetSMImgPath("Material_Drop_Copy.png"), false)
	elseif (nTyp == TagAim_TASK) then
		rtn = pool:AddPicture(GetSMImgPath("Current_Task_Copy.png"), false)
	end
	
	return rtn;
end

function p.getLockPic()
	local pool = DefaultPicPool();
	return pool:AddPicture(GetSMImgPath("bg_copy_lock.png"), false)
end

function p.timerCallback(tag)
	if (tag and tag == p.mTimerTaskTag) then
		LogInfo("timerCallback");
		p.refreshCurPageItem();
	end
end

function p.refreshCurPageItem()
	if (not p.mList) or (not p.mCurrentPage) then
		return;
	end
	
	local container = p.getContainerById(p.TagContainer);
	if not CheckP(container) then
		LogInfo("nil == container");
		return;
	end
	
	local i = p.mCurrentPage;
	lst = p.mList;
	
	local view = container:GetViewById(i);
	
	for j = 1, p.PerPageSize do 
			p.refreshItemView(view, lst[(i - 1) * p.PerPageSize + j], j, (i - 1) * p.PerPageSize + j);
	end
	
	local layer = getUiLayer();
	local clearV = GetButton(layer, p.TagCear);
	if (p.mHasCleanOUt == true) then
		clearV:SetVisible(true);
	else
		clearV:SetVisible(false);
	end
	
end
