---------------------------------------------------
--描述: 奇术
--时间: 2012.2.8
--作者: wjl
---------------------------------------------------
MartialUI = {}
local p = MartialUI;

p.TagUser = {
	534,
	538,
	535,
	539,
	536,
	540,
	537,
	541,
}

p.TagSatation = {
	42,
	43,
	44,
	39,
	40,
	41,
	36,
	37,
	38,
}

p.TagOrderText = {
	47,
	50,
	53,
	46,
	49,
	52,
	45,
	48,
	51,
}

p.TagListItem = {
	bg		= 553,
	name	= 558,
	level	= 559,
	state	= 560,
}

p.TagCheckBox = 54;

p.DrageState = {
	Out			= 1,
	Complement	= 2,
	In			= 3,
}

p.DrageSrcType = {
	User	= 1,
	Station = 2,
}

p.TagStaionStr = {
	"s1",
	"s2",
	"s3",
	"s4",
	"s5",
	"s6",
	"s7",
	"s8",
	"s9",
}

p.mDragSrc = {
	srcTag = 0,
	srcType = 0, -- 1:usertag, 2: stationtag
}

p.mDragDst = {
	srcTag = 0,
	srcType = 0,
}

p.mUserList = {
}

p.mMainPetId = 0;

p.mShowOrder = 1;

p.mDBSIndex = {
	DB_MATRIX_CONFIG.REQ_LEVEL1,
	DB_MATRIX_CONFIG.REQ_LEVEL2,
	DB_MATRIX_CONFIG.REQ_LEVEL3,
	DB_MATRIX_CONFIG.REQ_LEVEL4,
	DB_MATRIX_CONFIG.REQ_LEVEL5,
	DB_MATRIX_CONFIG.REQ_LEVEL6,
	DB_MATRIX_CONFIG.REQ_LEVEL7,
	DB_MATRIX_CONFIG.REQ_LEVEL8,
	DB_MATRIX_CONFIG.REQ_LEVEL9,
}

p.mPicPathOrder = {
		"mark_num1.png",
		"mark_num2.png",
		"mark_num3.png",
		"mark_num4.png",
		"mark_num5.png",
		"mark_num6.png",
		"mark_num7.png",
		"mark_num8.png",
		"mark_num9.png",
	}



--p.mStationList = {
--	2,
--	1,
--	1,
--}


p.TagList		= 1000;
p.TagClose		= 533;
p.TagShowOrder	= 55;
p.TagOpen		= 557;
--p.TagName		= 532;
--p.TagLevel		= 648;
p.TagDes		= 649;

p.mShowOrderSt		= 0; -- 0:为不显示，1:为显示
p.mMatrixList		= {};
p.mMatrixListCount	= 0;
p.mPreOpenIndex		= 0;

p.mCurrentOpenMatrix = {};
p.mCurrentMatrix = {
	
};

p.mClickItemIndex = 1;

-- 界面控件坐标定义
local winsize = GetWinSize();
local TAG_MOUSE	= 9999;							--鼠标图片tag

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;


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
	layer:SetTag(NMAINSCENECHILDTAG.PlayerMartial );
	layer:SetFrameRect(RectUILayer);
	layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("LayOut.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	uiLoad:Free();
	
	--local bt = GetButton(layer, p.TagUser[1]);
	--local pic = p.getPicture();
	--if (pic and bt) then
	--	bt:SetImage(pic);
	--end
	--avatar1
	
	p.initData();
	
	local nod = GetUiNode(layer, p.TagCheckBox);
	if CheckP(nod) then
		local check = ConverToCheckBox(nod);
		if CheckP(check) then
			if p.mShowOrder == 1 then
				check:SetSelect(true);
			else
				check:SetSelect(false);
			end
		end
	end
	
	p.RefreshUI();
	
	--鼠标图片初始化
	local imgMouse	= createNDUIImage();
	imgMouse:Init();
	imgMouse:SetTag(TAG_MOUSE);
	layer:AddChildZ(imgMouse, 2);
	
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEven1t[%d], event:%d", tag, uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.PlayerMartial);
		elseif (p.TagOpen == tag ) then
			p.clickOpen();
		elseif (p.TagListItem.bg == tag) then
			LogInfo("6666");
			local parent = uiNode:GetParent();
			if (parent) then
				local index = parent:GetTag();
				p.mCurrentMatrix = p.mMatrixList[index];
				p.setData();
				p.RefreshUI();
			end
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
		if (p.TagCheckBox == tag) then
			p.clickCheckBox(uiNode);
		end
	
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT then
		--物品往外拖
		local isable = false;
		if p.isUserGridTag(tag) then
			LogInfo("物品往外拖 not p.isUserGridTag(tag)");
			isable = true;
			p.mDragSrc.srcTag = tag;
			p.mDragSrc.srcType = p.DrageSrcType.User;
		elseif p.isStationTag(tag) then
			isable = true;
			p.mDragSrc.srcTag = tag;
			p.mDragSrc.srcType = p.DrageSrcType.Station;
		end
		
		if (not isable) then
			return true;
		end
		
		if not CheckStruct(param) then
			LogInfo("物品往外拖 invalid param");
			return true;
		end
		
		local itemBtn = ConverToButton(uiNode);
		if not CheckP(itemBtn) then
			LogInfo("物品往外拖 not CheckP(itemBtn) ");
			return true;
		end
		
		p.SetMouse(itemBtn:GetImageCopy(), param);
		p.OnDragItemListener(p.mDragSrc,nil, p.DrageState.Out, param);
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT_COMPLETE then
		--物品往外拖完成
		if not p.isUserGridTag(tag) then 
			LogInfo("物品往外拖完成 not p.isUserGridTag(tag)");
			--return true;
		end
		local itemBtn = ConverToButton(uiNode);
		if not CheckP(itemBtn) then
			LogInfo("物品往外拖完成 not CheckP(itemBtn) ");
			--return true;
		end
		p.OnDragItemListener(p.mDragSrc,nil, p.DrageState.Complement, param);
		p.SetMouse(nil, SizeZero());
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_IN then
		local isable = false;
		if p.isUserGridTag(tag) then
			LogInfo("物品 not p.isUserGridTag(tag)");
			isable = true;
			p.mDragDst.srcTag = tag;
			p.mDragDst.srcType = p.DrageSrcType.User;
		elseif p.isStationTag(tag) then
			isable = true;
			p.mDragDst.srcTag = tag;
			p.mDragDst.srcType = p.DrageSrcType.Station;
		end
		
		if (not isable) then
			return true;
		end
		
		local itemBtn = ConverToButton(param);
		
		if CheckP(itemBtn)then
			p.OnDragItemListener(p.mDragSrc,p.mDragDst, p.DrageState.In, param);
		end
	end
	return true;
end

function p.OnUIEventScroll(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventScroll[%d]", tag);
	return true;
end

function p.GetListContainer()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
	if nil == layer then
		return nil;
	end
	
	local container = GetScrollViewContainer(layer, p.TagList);
	return container;
end

function p.GetAttackContainer()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
	if nil == layer then
		return nil;
	end
	
	local container = GetScrollViewContainer(layer, ID_ATTACK_LIST);
	return container;
end

function p.RefreshUI()
	
	p.RefreshUserGrid() 
	p.RefreshSation();
	p.RefreshStationInfos();
	p.RefreshList();
end

function p.RefreshList()
local scene = GetSMGameScene();	

	
	local container = p.GetListContainer();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	local rectview = container:GetFrameRect();
	--container:SetViewSize(CGSizeMake(rectview.size.w / 3, rectview.size.h));
	container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
	
	local count = p.mMatrixListCount;
	local lst = p.mMatrixList;
	
	if (count == nil or lst == nil) then
		count = 0
	end
	
	for i = 1,  count do
	
	local view = createUIScrollView();
	
	if view == nil then
		LogInfo("view == nil");
		return;
	end
	view:Init(false);
	view:SetScrollStyle(UIScrollStyle.Verical);
	view:SetViewId(i);
	view:SetTag(i);
	view:SetMovableViewer(container);
	view:SetScrollViewer(container);
	view:SetContainer(container);
	container:AddView(view);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	
	uiLoad:Load("LayOut_R.ini", view, p.OnUIEvent, 0, 0);
	
	if (i == 1) then -- 第一次初始vietSize
		local rectview = container:GetFrameRect();
		local bg = GetButton(view, p.TagListItem.bg);
		local rectItem = bg:GetFrameRect();
		
		container:SetViewSize(CGSizeMake(rectview.size.w, rectItem.size.h));
	end
	
	p.refreshMatrixItem(lst[i], view, p.TagListItem);
	
	uiLoad:Free();
 end -- end for
	
end

function p.RefreshUserGrid() 
	
	for i = 1, #p.TagUser do 
		local bt = p.getBt(p.TagUser[i]);
		local id = p.mUserList[i];
		local pic = p.getPicture(id);
		if (bt) then
			bt:SetImage(pic);
		end
	end
end

function p.RefreshSation()
	if not p.mCurrentMatrix then
		return
	end
	local order = 1;
	for i = 1, #p.TagSatation do 
		local bt = p.getBt(p.TagSatation[i]);
		if bt and p.mCurrentMatrix then
			local id = p.mCurrentMatrix[i];
			--bt:SetBackgroundPicture
			local enable = p.isLeveEnable(p.mCurrentMatrix.type, i, p.mCurrentMatrix.level)
			local pic = p.getPicture(id);
			local orderTxt = p.getImage(p.TagOrderText[i]);
			if ( p.mShowOrder == 1 and CheckN(id) and id > 0) then
				--if (orderTxt) then
					orderTxt:SetPicture(p.getOrderPic(order), true);
				--end
				order = order + 1;
			else
				orderTxt:SetPicture(nil, true);
			end
			if (bt) then
				if (enable) then
					bt:SetBackgroundPicture(p.getEnablePic(), p.getEnablePic());
				else
					bt:SetBackgroundPicture(p.getDisablePic(), p.getDisablePic());
				end
				bt:SetImage(pic);
			end
		elseif bt then 
		end
	end
end

function p.RefreshStationInfos()
	local scene = GetSMGameScene();	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
	if nil == layer then
		return nil;
	end
	--local nameV		= GetLabel(layer, p.TagName);
	local desV		= GetLabel(layer, p.TagDes);
	--local levelV	= GetLabel(layer, p.TagLevel); 
	
	local m = p.mCurrentMatrix; 
	if (m and m.id and m.type) then
		--local sName = MatrixConfigFunc.GetDataBaseS(m.type,DB_MATRIX_CONFIG.NAME);
		local sDes = MatrixConfigFunc.GetDataBaseS(m.type, DB_MATRIX_CONFIG.DESCRIPT);
		--nameV:SetText(ConvertS(sName));
		desV:SetText(ConvertS(sDes));
		--levelV:SetText(SafeN2S(m.level));
		p.RefreshSation();
		p.RefreshList();
		
		--[[
		local container = p.GetListContainer();
		local preScrollView = container:GetViewById(p.mPreOpenIndex);
		local preBt = GetLabel(scrollView, p.TagListItem.bg);
		if (preBt) then
			preBt:SetBackgroundPicture(nil);
			preBt:SetText("");
		end
		
		local scrollView = container:GetViewById(p.mPreOpenIndex);
		local bt = GetLabel(scrollView, p.TagListItem.bg);
		if (bt) then
			preBt:SetBackgroundPicture(p.getItemSelectPic());
			bt:SetText("启用");
		end
		]]--
		
	end
	
end

function p.refreshMatrixItem(matrix, view, viewIds)
	local nameV		= GetLabel(view, viewIds.name);
	local levelV	= GetLabel(view, viewIds.level);
	local labelV	= GetLabel(view, viewIds.state);
	local bgV		= GetButton(view, viewIds.bg);
	
	LogInfo("refreshMatrixItem");
	
	if (matrix) then
		LogInfo("refreshMatrixItem matrix");
	
		local id = matrix.id;
		local level = matrix.level;
		local type = matrix.type;
	
		local sName = MatrixConfigFunc.GetDataBaseS(type,DB_MATRIX_CONFIG.NAME);
		--local sDes = MatrixConfigFunc.GetDataBaseS(type, DB_MATRIX_CONFIG.DESCRIPT);
		local sLevel = string.format(" %d级", MatrixConfigFunc.GetUpLevelN(level, DB_MATRIX_UP_LEVEL.LEVEL));
		nameV:SetText(sName);
		levelV:SetText(sLevel);
		nameV:SetVisible(true);
		levelV:SetVisible(true);
		if (p.mCurrentOpenMatrix and id == p.mCurrentOpenMatrix.id) then
			labelV:SetText("启用");
			labelV:SetVisible(true);
		end
		
		if (p.mCurrentMatrix and id == p.mCurrentMatrix.id) then
			bgV:SetBackgroundPicture(p.getItemSelectPic(), p.getItemSelectPic());
		end
		
	else
		nameV:SetVisible(false);
		levelV:SetVisible(false);
		labelV:SetVisible(false);
	end
end


function p.clickOpen()
	local m = p.mCurrentMatrix;
	if (m and CheckN(m.id) ) then
		ShowLoadBar();
		MsgMagic.sendMatrixOpen(m.id);
	end
end

function p.clickCheckBox(uiNode)
	local check = ConverToCheckBox(uiNode);
	if not CheckP(check) then
		return;
	end
	
	local isSelect = check:IsSelect();
	if (isSelect) then
		p.mShowOrder = 1;
	else
		p.mShowOrder = 0;
	end
	
	p.RefreshSation();
end

function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	--LogInfo(string.format("processNet%d" , msgId));
	if msgId == NMSG_Type._MSG_MATRIX_STATION_OPEN then
		--local id = MsgMagic.getCurrentOpenMatrixId(); 
		p.mCurrentOpenMatrix = p.findMatrixById(m);
		p.RefreshList();
	end
	CloseLoadBar();
end

function p.initData()
	p.initConst();
	
	local lst, count = MsgMagic.getRoleMatrixList();
	p.mMatrixList = lst;
	p.mMatrixListCount = count;
	p.mDragSrc = {};
	local nPlayerId = GetPlayerId();
	p.mMainPetId = RolePetFunc.GetMainPetId(nPlayerId);
	LogInfo("p.mMainPetId %d", p.mMainPetId);

	local nPlayerId = GetPlayerId();
	local id = GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_MATRIX);
	p.mCurrentOpenMatrix = p.findMatrixById(id);
	p.mCurrentMatrix = p.mCurrentOpenMatrix
	if (p.mCurrentMatrix == nil) then
		p.mCurrentMatrix = {0,0,0,0,0,0,0,0};
	end
	
	p.setData();
	
	MsgMagic.mUIListener = p.processNet;
end

function p.setData()
	local nPlayerId = GetPlayerId();
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	
	local unUseIndex = 1;
	local mainHas = false;
	p.mUserList = {};
	if not p.mCurrentMatrix then
		return;
	end
	
	for i = 1, #p.mCurrentMatrix do
		if p.mCurrentMatrix[i] == 0 and p.isLeveEnable(p.mCurrentMatrix.type, i, p.mCurrentMatrix.level) then
			unUseIndex = i;
		end
		
		if p.mCurrentMatrix[i] == p.mMainPetId then
			mainHas = true;
		end
	end
	
	if not mainHas then
		p.mCurrentMatrix[unUseIndex] = p.mMainPetId;
	end
	
	if (idTable) then
		for i = 1 ,#idTable do
			LogInfo("i:%d,id:%d" , i, idTable[i]);
			local isIn = false;
			if (p.mCurrentMatrix) then
				for j = 1, #p.mCurrentMatrix do
					if (idTable[i] == p.mCurrentMatrix[j]) then
					 isIn = true;
					end
				end
			end
			if (not isIn) then
				table.insert(p.mUserList,idTable[i]);
			end
		end
	end
end

function p.findMatrixById(nId)
	if not CheckN(nId) then
		return;
	end
	
	for i = 1, p.mMatrixListCount do
		if (p.mMatrixList and p.mMatrixList[i].id == nId) then
			return p.mMatrixList[i];
		end
	end
	return p.mMatrixList[1];
end

function p.freeData()
	MsgMagic.mUIListener = nil;
	p.mCurrentOpenMatrix  = {};
	p.mCurrentMatrix = {};
	p.mMatrixList = {};
	p.mDragSrc = {};
end

function p.isUserGridTag(nTag)
	--if not CheckT(TAG_BAG_LIST) or 0 == table.getn(TAG_BAG_LIST) then
	--	return false;
	--end
	
	for i, v in pairs(p.TagUser) do
		if v == nTag then
			return true
		end
	end
	
	return false;
end

function p.isStationTag(nTag)
	for i, v in pairs(p.TagSatation) do
		if v == nTag and p.mCurrentMatrix then
			if (p.isLeveEnable(p.mCurrentMatrix.type,i, p.mCurrentMatrix.level)) then			
				return true
			end
		end
	end
	
	return false;
end

function p.SetMouse(pic, moveTouch)
	LogInfo("SetMouse");
	if not CheckStruct(moveTouch) then
		LogInfo("SetMouse invalid arg");
		return;
	end
	
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		return;
	end
	
	local idlist = {};
	local imgMouse = RecursiveImage(scene, {NMAINSCENECHILDTAG.PlayerMartial, TAG_MOUSE});
	if not CheckP(imgMouse) then
		LogInfo("not CheckP(imgMouse)");
		return;
	end
	
	imgMouse:SetPicture(pic, true);
	
	if CheckP(pic) then
		local size		= pic:GetSize();
		local nMoveX	= moveTouch.x - size.w / 2 - RectUILayer.origin.x;
		local nMoveY	= moveTouch.y - size.h / 2 - RectUILayer.origin.y;
		imgMouse:SetFrameRect(CGRectMake(nMoveX, nMoveY, size.w, size.h));
	else
		LogInfo("imgMouse:SetFrameRect(RectZero)");
		imgMouse:SetFrameRect(RectZero());
	end
end

-- state: 1 start, 2 drager out, 3 drager in
function p.OnDragItemListener(dragerSrc , dragerDst, state, param)
	if (dragerSrc == nil or state == nil or state == 0) then
		return;
	end
	
	if (state == p.DrageState.Out and dragerSrc.srcType == p.DrageSrcType.User) then
		
	elseif (state == p.DrageState.Complement) then
		-- p.DrageSrcType
		--local bt = p.getBt(dragerSrc.srcTag);
		--if (bt) then
		--	bt:SetVisible(false);
		--end
		p.SetMouse(nil, SizeZero());
	elseif (state == p.DrageState.In)  then
		if (dragerSrc and dragerDst and p.mCurrentMatrix) then
			if (not (dragerSrc.srcType == p.DrageSrcType.User and dragerDst.srcType ==  p.DrageSrcType.User) ) then
				local srcId, srcIndex = p.getIdByViewTag(dragerSrc.srcTag, dragerSrc.srcType);
				local dstId, dstIndex = p.getIdByViewTag(dragerDst.srcTag, dragerDst.srcType);
				LogInfo("srcIndex:%d, dstIndex:%d", srcIndex, dstIndex);
				if (dragerSrc.srcType == p.DrageSrcType.User) then
					table.remove(p.mUserList,srcIndex);
				end
				if (dragerDst.srcType == p.DrageSrcType.User) then
					if ( srcId ~= p.mMainPetId ) then
						p.mUserList[#p.mUserList+1] = srcId;  --主角不下阵
					end
				end
				if (dragerSrc.srcType == p.DrageSrcType.Station) then
					if (dragerDst.srcType == p.DrageSrcType.User) then 
						--p.mStationList[srcIndex] = 0;
						LogInfo("srcId id %d, mainId %d", srcId, p.mMainPetId)
						if ( srcId ~= p.mMainPetId ) then --主角不下阵
							p.mCurrentMatrix[srcIndex] = 0;
						end
					else
						--p.mStationList[srcIndex] = dstId;
						p.mCurrentMatrix[srcIndex] = dstId;
					end
				end
				if (dragerDst.srcType == p.DrageSrcType.Station) then
					--p.mStationList[dstIndex] = srcId;
					p.mCurrentMatrix[dstIndex] = srcId;
				end
				
				if (not (dragerDst.srcType == p.DrageSrcType.Station and dragerSrc.srcType == p.DrageSrcType.Station and srcIndex == dstIndex)
					) then
					LogInfo(".......");
					MsgMagic.sendSetStation(p.mCurrentMatrix);
				end
				
				p.RefreshUserGrid();
				p.RefreshSation();
			 end
		end
	end
		
end

function p.getBt(nTag)
	if (not nTag) then
		return nil;
	end
	
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
	if nil == layer then
		return nil;
	end
	
	local rtn = GetButton(layer, nTag);
	
	return rtn;
end

function p.getImage(nTag)
	if (not nTag) then
		return nil;
	end
	
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
	if nil == layer then
		return nil;
	end
	
	local rtn = GetImage(layer, nTag);
	
	return rtn;
end

-- return NDPicture
function p.getPicture(nId)
	
	local rtn = nil;
	if not CheckN(nId) then
		return nil;
	end
	
	local pool = DefaultPicPool();
	
	if (nId == 1) then
		rtn = pool:AddPicture(GetImgPathNew("avatar1.png"), false)
	elseif (nId > 0) then
		rtn = pool:AddPicture(GetImgPathNew("avatar2.png"), false)
	end
	
	return rtn;
end

function p.getDisablePic()
	local pool = DefaultPicPool();
	
	return pool:AddPicture(GetSMImgPath("bg_square_lock.png"), false)
end

function p.getEnablePic()
	local pool = DefaultPicPool();
	
	return pool:AddPicture(GetSMImgPath("bg_square_normal.png"), false)
end

function p.getOrderPic(order)
	local pool = DefaultPicPool();
	return pool:AddPicture(GetSMImgPath(p.mPicPathOrder[order]), false)
end

function p.getItemSelectPic()
	local pool = DefaultPicPool();
	return pool:AddPicture(GetSMImgPath("bg_layout_focus.png"), false)
end

function p.getIdByViewTag(nTag, tagType)
	local rtn = nil;
	if (tagType == p.DrageSrcType.User ) then
	for i = 1, #p.TagUser do 
		if (p.TagUser[i] == nTag ) then
			rtn = p.mUserList[i];
			return rtn, i;
		end
	end
	elseif (tagType == p.DrageSrcType.Station) then
	 for i = 1, #p.TagSatation do 
		if (p.TagSatation[i] == nTag and p.mCurrentMatrix) then
			rtn = p.mCurrentMatrix[i]; --p.mStationList[i];
			return rtn, i;
		end
	 end
	end
	
	return rtn;
end

function p.isLeveEnable(id, gridIndex, level)
	if (not CheckN(id)) or (not CheckN(gridIndex)) then
		LogInfo("isLeveEnable id not num");
		return false;
	end
	local dbIndex =  p.mDBSIndex[gridIndex];
	if not CheckN(dbIndex) then
		LogInfo("dbIndex not num");
		return false;
	end
	local dbLevel = MatrixConfigFunc.GetDataBaseN(id , dbIndex);
	return level >= dbLevel
end

function p.initConst()
	p.mDBSIndex = {
	DB_MATRIX_CONFIG.REQ_LEVEL1,
	DB_MATRIX_CONFIG.REQ_LEVEL2,
	DB_MATRIX_CONFIG.REQ_LEVEL3,
	DB_MATRIX_CONFIG.REQ_LEVEL4,
	DB_MATRIX_CONFIG.REQ_LEVEL5,
	DB_MATRIX_CONFIG.REQ_LEVEL6,
	DB_MATRIX_CONFIG.REQ_LEVEL7,
	DB_MATRIX_CONFIG.REQ_LEVEL8,
	DB_MATRIX_CONFIG.REQ_LEVEL9,
	}
		
	p.mPicPathOrder = {
		"mark_num1.png",
		"mark_num2.png",
		"mark_num3.png",
		"mark_num4.png",
		"mark_num5.png",
		"mark_num6.png",
		"mark_num7.png",
		"mark_num8.png",
		"mark_num9.png",
	}
	
end

