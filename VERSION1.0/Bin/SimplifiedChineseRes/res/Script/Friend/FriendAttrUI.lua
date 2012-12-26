---------------------------------------------------
--描述: 好友资料UI
--时间: 2012.4.16
--作者: fyl
---------------------------------------------------



FriendAttrUI = {}
local p = FriendAttrUI;

--bg tag
local ID_ROLEATTR_L_BG_CTRL_LIST_LEFT			    = 51;
local ID_ROLEATTR_L_BG_CTRL_LIST_LEFT_DESTINY       = 15;
local ID_ROLEATTR_L_BG_CTRL_LIST_NAME			    = 50;
local ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_67			= 67;
local ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_66			= 66;
local ID_SM_JH_ROLEATTR_L_BG_CTRL_LIST_LEFT			= 51;
local ID_SM_JH_ROLEATTR_L_BG_CTRL_LIST_NAME			= 50;

--占星背包
local TAG_DESTINY_BAG = 14;     --占星背包

--L
local ID_ROLEATTR_R_CTRL_TEXT_SPEED						= 27;
local ID_ROLEATTR_L_CTRL_TEXT_HELP						= 100;
local ID_ROLEATTR_L_CTRL_EXP_ROLE						= 33;
local ID_ROLEATTR_L_CTRL_BUTTON_SHOES					= 62;
local ID_ROLEATTR_L_CTRL_BUTTON_DRESS					= 61;
local ID_ROLEATTR_L_CTRL_BUTTON_HELMET				= 60;
local ID_ROLEATTR_L_CTRL_BUTTON_AMULET				= 59;
local ID_ROLEATTR_L_CTRL_BUTTON_WEAPON				= 58;
local ID_ROLEATTR_L_CTRL_BUTTON_SOUL					= 57;
local ID_ROLEATTR_L_CTRL_BUTTON_INHERIT				= 56;
local ID_ROLEATTR_L_CTRL_BUTTON_LEAVE					= 31;
local ID_ROLEATTR_L_CTRL_BUTTON_PILL					= 30;
local ID_ROLEATTR_L_CTRL_TEXT_DEX					= 28;
local ID_ROLEATTR_L_CTRL_TEXT_MAGIC					= 29;
local ID_ROLEATTR_L_CTRL_TEXT_SKILL					= 27;
local ID_ROLEATTR_L_CTRL_TEXT_26						= 26;
local ID_ROLEATTR_L_CTRL_TEXT_25						= 25;
local ID_ROLEATTR_L_CTRL_TEXT_ABILITY					= 24;
local ID_ROLEATTR_L_CTRL_TEXT_23						= 23;
local ID_ROLEATTR_L_CTRL_TEXT_LIFE					= 22;
local ID_ROLEATTR_L_CTRL_TEXT_21						= 21;
local ID_ROLEATTR_L_CTRL_TEXT_FORCE					= 20;
local ID_ROLEATTR_L_CTRL_TEXT_19						= 19;
--local ID_ROLEATTR_L_CTRL_TEXT_JOB						= 17;
local ID_ROLEATTR_L_CTRL_TEXT_JOB						= 16;
local ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG				= 9;
local ID_ROLEATTR_L_CTRL_BUTTON_BAG					= 97;
local ID_ROLEATTR_L_CTRL_BUTTON_FIRE					= 98;
local ID_ROLEATTR_L_CTRL_TEXT_LEVEL						= 235;

--[[
local ID_ROLEATTR_L_CTRL_EXP_ROLE					= 33;
local ID_ROLEATTR_L_CTRL_BUTTON_SHOES				= 62;
local ID_ROLEATTR_L_CTRL_BUTTON_DRESS				= 61;
local ID_ROLEATTR_L_CTRL_BUTTON_HELMET				= 60;
local ID_ROLEATTR_L_CTRL_BUTTON_AMULET				= 59;
local ID_ROLEATTR_L_CTRL_BUTTON_WEAPON				= 58;
local ID_ROLEATTR_L_CTRL_BUTTON_SOUL				= 57;
local ID_ROLEATTR_L_CTRL_TEXT_MAGIC					= 28;
local ID_ROLEATTR_L_CTRL_TEXT_SKILL					= 27;
local ID_ROLEATTR_L_CTRL_TEXT_ABILITY				= 24;
local ID_ROLEATTR_L_CTRL_TEXT_LIFE					= 22;
local ID_ROLEATTR_L_CTRL_TEXT_FORCE					= 20;
local ID_ROLEATTR_L_CTRL_TEXT_JOB					= 17;
local ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG			= 9;
--]]


--R
--[[
local ID_ROLEATTR_R_CTRL_BUTTON_95					= 96;
local ID_ROLEATTR_R_CTRL_TEXT_CRIT					= 138;
local ID_ROLEATTR_R_CTRL_TEXT_DODGE					= 135;
local ID_ROLEATTR_R_CTRL_TEXT_KILL					= 131;
local ID_ROLEATTR_R_CTRL_TEXT_WRECK					= 130;
local ID_ROLEATTR_R_CTRL_TEXT_HIT					= 129;
local ID_ROLEATTR_R_CTRL_TEXT_TENACITY				= 125;
local ID_ROLEATTR_R_CTRL_TEXT_MAGIC_ATTACK			= 124;
local ID_ROLEATTR_R_CTRL_TEXT_MAGIC_DEFENSE			= 121;
local ID_ROLEATTR_R_CTRL_TEXT_STUNT_DEFENSE			= 120;
local ID_ROLEATTR_R_CTRL_TEXT_NORMAL_DEFENSE		= 119;
local ID_ROLEATTR_R_CTRL_TEXT_STUNT_ATTACK			= 117;
local ID_ROLEATTR_R_CTRL_TEXT_NORMAL_ATTACK			= 116;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_LIFE				= 109;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_LEVEL			= 108;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_SKILL			= 105;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_JOB				= 104;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_NAME				= 103;
local ID_ROLEATTR_R_CTRL_TEXT_FIGHTING				= 137;
local ID_ROLEATTR_R_CTRL_TEXT_BLOCK					= 136;
local ID_ROLEATTR_R_CTRL_PICTURE_ROLE_ICON			= 99;
--]]
local ID_ROLEATTR_R_CTRL_BUTTON_95					= 96;
local ID_ROLEATTR_R_CTRL_TEXT_CRIT					= 124;
local ID_ROLEATTR_R_CTRL_TEXT_DODGE					= 125;
local ID_ROLEATTR_R_CTRL_TEXT_134						= 134;
local ID_ROLEATTR_R_CTRL_TEXT_133						= 133;
local ID_ROLEATTR_R_CTRL_TEXT_132						= 132;
local ID_ROLEATTR_R_CTRL_TEXT_KILL					= 130;
local ID_ROLEATTR_R_CTRL_TEXT_WRECK					= 129;
local ID_ROLEATTR_R_CTRL_TEXT_HIT						= 138;
local ID_ROLEATTR_R_CTRL_TEXT_128						= 128;
local ID_ROLEATTR_R_CTRL_TEXT_127						= 127;
local ID_ROLEATTR_R_CTRL_TEXT_126						= 126;
local ID_ROLEATTR_R_CTRL_TEXT_TENACITY				= 121;
local ID_ROLEATTR_R_CTRL_TEXT_MAGIC_ATTACK			= 117;
local ID_ROLEATTR_R_CTRL_TEXT_123						= 123;
local ID_ROLEATTR_R_CTRL_TEXT_122						= 122;
local ID_ROLEATTR_R_CTRL_TEXT_MAGIC_DEFENSE			= 120;
--local ID_ROLEATTR_R_CTRL_TEXT_STUNT_DEFENSE			= 120;
local ID_ROLEATTR_R_CTRL_TEXT_NORMAL_DEFENSE			= 119;
local ID_ROLEATTR_R_CTRL_TEXT_SPEED						= 27;
local ID_ROLEATTR_R_CTRL_TEXT_NORMAL_ATTACK			= 116;
local ID_ROLEATTR_R_CTRL_TEXT_115						= 115;
local ID_ROLEATTR_R_CTRL_TEXT_114						= 114;
local ID_ROLEATTR_R_CTRL_TEXT_113						= 113;
local ID_ROLEATTR_R_CTRL_TEXT_112						= 112;
local ID_ROLEATTR_R_CTRL_TEXT_111						= 111;
local ID_ROLEATTR_R_CTRL_TEXT_110						= 110;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_LIFE				= 109;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_LEVEL				= 108;
local ID_ROLEATTR_R_CTRL_TEXT_107						= 107;
local ID_ROLEATTR_R_CTRL_TEXT_106						= 106;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_SKILL				= 105;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_JOB				= 104;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_NAME				= 103;
local ID_ROLEATTR_R_CTRL_TEXT_102						= 102;
local ID_ROLEATTR_R_CTRL_TEXT_101						= 101;
local ID_ROLEATTR_R_CTRL_PICTURE_151					= 151;
local ID_ROLEATTR_R_CTRL_PICTURE_152					= 152;
local ID_ROLEATTR_R_CTRL_PICTURE_153					= 153;
local ID_ROLEATTR_R_CTRL_PICTURE_154					= 154;
local ID_ROLEATTR_R_CTRL_PICTURE_155					= 155;
local ID_ROLEATTR_R_CTRL_PICTURE_156					= 156;
local ID_ROLEATTR_R_CTRL_PICTURE_157					= 157;
local ID_ROLEATTR_R_CTRL_PICTURE_158					= 158;
local ID_ROLEATTR_R_CTRL_PICTURE_159					= 159;
local ID_ROLEATTR_R_CTRL_PICTURE_160					= 160;
local ID_ROLEATTR_R_CTRL_PICTURE_161					= 161;
local ID_ROLEATTR_R_CTRL_TEXT_FIGHTING				= 137;
local ID_ROLEATTR_R_CTRL_TEXT_BLOCK					= 135;
local ID_ROLEATTR_R_CTRL_PICTURE_165					= 165;
local ID_ROLEATTR_R_CTRL_PICTURE_164					= 164;
local ID_ROLEATTR_R_CTRL_PICTURE_162					= 162;
local ID_ROLEATTR_R_CTRL_PICTURE_150					= 150;
local ID_ROLEATTR_R_CTRL_PICTURE_163					= 163;
local ID_ROLEATTR_R_CTRL_PICTURE_ROLE_ICON			= 99;
local ID_ROLEATTR_R_CTRL_PICTURE_95					= 95;
local ID_ROLEATTR_R_CTRL_PICTURE_94					= 94;


local ID_ROLEATTR_R_CTRL_PICTURE_240					= 240;
local ID_ROLEATTR_R_CTRL_PICTURE_241					= 241;

local TAG_LAYER_ATTR = 12345;				--属性界面层tag
-- 界面控件坐标定义
local winsize = GetWinSize();
local RectUILayer = CGRectMake(0, 0, winsize.w , winsize.h);

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;

local BAG_TYPE_NAME = {
    "星运",
    "装备",
};

local friendId;
local friendName = "";
local parentLayerTag;
local TAG_EQUIP_LIST = {};--装备Tag列表
-----------------------
-----------------------

function p.LoadUI(nPlayerId,nPlayerName,nTag)

	friendId = nPlayerId;
	friendName = nPlayerName;
	parentLayerTag = nTag;
	p.InitEquipTag();
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
	layer:SetTag(NMAINSCENECHILDTAG.FriendAttr);
	--layer:SetFrameRect(RectUILayer);
	
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,5005);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
    --三级窗口初始化
    BackLevelThreeWin.LoadUI(layer);
    
	--bg
	uiLoad:Load("RoleAttr_L_BG.ini", layer, p.OnUIEventScroll, 0, 0);
	--local AddFriendBtn	= RecursiveButton(layer, ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_66);
	--AddFriendBtn:SetVisible(false);ID_ROLEATTR_L_CTRL_BUTTON_FIRE
	
    
	local btn = GetButton(layer,TAG_DESTINY_BAG);
    --查看它人星运功能暂时屏蔽
    --btn:SetVisible(false);
    btn:SetTitle(BAG_TYPE_NAME[1]);
    
	local layerAttr = createNDUILayer();
	if not CheckP(layerAttr) then
		uiLoad:Free();
		layer:Free();
		return false;
	end
	
	

	
	layerAttr:Init();
	layerAttr:SetTag(TAG_LAYER_ATTR);
	layerAttr:SetFrameRect(CGRectMake(ATTR_OFFSET_X, ATTR_OFFSET_Y, RectUILayer.size.w / 2, RectUILayer.size.h));
	layer:AddChild(layerAttr);
	
	uiLoad:Load("RoleAttr_R.ini", layerAttr, p.OnUIEvent, 0, 0);
	
	uiLoad:Free();	
	
	--隐藏快速培养按钮 训练中label
	local trainButton = RecursiveButton(layerAttr, {43});
	trainButton:SetVisible(false);
	local xllabel = RecursiveLabel(layerAttr, {39});
	local timelable = RecursiveLabel(layerAttr, {38});
	xllabel:SetVisible(false);
	timelable:SetVisible(false);
	
	local containter = RecursiveSVC(layer, {ID_ROLEATTR_L_BG_CTRL_LIST_LEFT});
	
	
	if not CheckP(containter) then
		layer:Free();
		return false;
	end

	containter:SetViewSize(containter:GetFrameRect().size);
	containter:SetLuaDelegate(p.OnUIEventViewChange);
    
    
    --星运背包
    local destinyBag = RecursiveSVC(layer, {ID_ROLEATTR_L_BG_CTRL_LIST_LEFT_DESTINY});
	if not CheckP(destinyBag) then
		layer:Free();
		return false;
	end
    destinyBag:SetVisible(false);
	destinyBag:SetViewSize(destinyBag:GetFrameRect().size);
	destinyBag:SetLuaDelegate(p.OnUIEventViewChange);
    
	
	local petNameContainer = p.GetPetNameSVC();
	if CheckP(petNameContainer) then

	
		petNameContainer:SetCenterAdjust(true);
		local size		= petNameContainer:GetFrameRect().size;
		local viewsize	= CGSizeMake(size.w, size.h)
		petNameContainer:SetLeftReserveDistance(size.w / 2 + viewsize.w / 2);
		petNameContainer:SetRightReserveDistance(size.w / 2 - viewsize.w / 2);
		petNameContainer:SetViewSize(viewsize);
		petNameContainer:SetLuaDelegate(p.OnUIEventViewChange);
	end
    
    
    

    

		
	p.RefreshContainer();
    p.RefreshDestinyContainer();


	local beginView	= containter:GetBeginView(0);

	if CheckP(beginView) then
		p.ChangePetAttr(beginView:GetViewId());
	end
	
	if CheckP(petNameContainer) then
		petNameContainer:ShowViewByIndex(0);
	end
	
	--好友增加/删除 按钮刷新
	p.RefreshBtnText();
		
    --装备信息窗口初始化
    BackLevelThreeWin.LoadUI(layer);
    
    
    
    --隐藏金币银币
    local ID_ROLEATTR_R_CTRL_PICTURE_240					= 240;
    local ID_ROLEATTR_R_CTRL_PICTURE_241					= 241;
    
    local pic1 = GetImage(layer,ID_ROLEATTR_R_CTRL_PICTURE_240);
    local pic2 = GetImage(layer,ID_ROLEATTR_R_CTRL_PICTURE_241);
    if(pic1) then
        pic1:SetVisible(false);
    end
    if(pic2) then
        pic2:SetVisible(false);
    end
    
	return true;
end

--切换视图
function p.ChangeView()
    local layer = p.GetCurrLayer();
    if(layer == nil) then
        return;
    end
    local btn = GetButton(layer,TAG_DESTINY_BAG);
    if(btn) then
        if(btn:GetTitle() == BAG_TYPE_NAME[1]) then
            btn:SetTitle(BAG_TYPE_NAME[2]);
            p.DestinyView();
        else
            btn:SetTitle(BAG_TYPE_NAME[1]);
            p.BagView();
        end
    end
end

--星运视图
function p.DestinyView()
    local petSVC = p.GetPetParent();
    local desSVC = p.GetDestinyContainer();
    local nameSVC	= p.GetPetNameSVC();
    
    if(petSVC) then
        petSVC:SetVisible(false);
    end
    
    if(desSVC) then
        desSVC:ShowViewByIndex(nameSVC:GetBeginIndex());
        desSVC:SetVisible(true);
    end
end

--背包视图
function p.BagView()
    local petSVC = p.GetPetParent();
    local desSVC = p.GetDestinyContainer();
    local nameSVC	= p.GetPetNameSVC();
    
    if(petSVC) then
        petSVC:ShowViewByIndex(nameSVC:GetBeginIndex());
        petSVC:SetVisible(true);
    end
    
    if(desSVC) then
        desSVC:SetVisible(false);
    end
end

------------------获取数据---------------------------------

--获取展示中的宠物id
function p.GetPetIdOnShow()
		local containter =  p.GetPetParent()

		local nPetId		= 0;
		
		if CheckP(containter) and CheckN(param) then
			local beginView	= containter:GetBeginView();
			if CheckP(beginView) then
				nPetId	= beginView:GetViewId();
				
			end
		end
		return 0;
end

function p.GetEquipTag(nPos)
	if not CheckT(TAG_EQUIP_LIST) or not CheckN(nPos) then
	    LogInfo("  p.GetEquipTag  error")
		return 0;
	end
	return ConvertN(TAG_EQUIP_LIST[nPos]);
end

	
function p.InitEquipTag()
	if not CheckT(TAG_EQUIP_LIST) or TAG_EQUIP_LIST[Item.POSITION_EQUIP_1] then
		return;
	end 
	
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_1] = ID_ROLEATTR_L_CTRL_BUTTON_SOUL;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_2] = ID_ROLEATTR_L_CTRL_BUTTON_WEAPON;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_3] = ID_ROLEATTR_L_CTRL_BUTTON_AMULET;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_4] = ID_ROLEATTR_L_CTRL_BUTTON_HELMET;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_5] = ID_ROLEATTR_L_CTRL_BUTTON_DRESS;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_6] = ID_ROLEATTR_L_CTRL_BUTTON_SHOES;
end

function p.GetDetailParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = RecursiveUILayer(scene, {NMAINSCENECHILDTAG.FriendAttr, TAG_LAYER_ATTR});
	return layer;
end

function p.GetCurrLayer()
    local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.FriendAttr);
	if nil == layer then
		return nil;
	end
    
    return layer;
end

function p.GetPetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.FriendAttr);
	if nil == layer then
		return nil;
	end
	
	local containter = RecursiveSVC(layer, {ID_ROLEATTR_L_BG_CTRL_LIST_LEFT});
	return containter;
end

function p.GetDestinyContainer()
	local layer = p.GetCurrLayer();
	if nil == layer then
		return nil;
	end
	
	local containter = RecursiveSVC(layer, {ID_ROLEATTR_L_BG_CTRL_LIST_LEFT_DESTINY});
	return containter;
end

function p.GetPetNameSVC()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	local svc = RecursiveSVC(scene, {NMAINSCENECHILDTAG.FriendAttr, ID_ROLEATTR_L_BG_CTRL_LIST_NAME});
	return svc;
end


function p.RefreshContainer()

	
	local container = p.GetPetParent();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	
	local petNameContainer = p.GetPetNameSVC();
	if CheckP(petNameContainer) then
		petNameContainer:RemoveAllView();
	end
	
	if nil == friendId then
		LogInfo("nil == friendId");
		return;
	end
    LogInfo("qbw:查看好友资料，friendId[%d]",friendId)
	
	--获取玩家宠物id列表
	local idTable = RolePetUser.GetPetListPlayer(friendId);
	if nil == idTable then
		LogInfo("nil == idTable");
		return;
	end
    
    idTable = RolePet.OrderPets(idTable,friendId);
    
	LogInfo("qbw:p.RefreshContainer:table count:"..table.getn(idTable));
	LogInfoT(idTable);
	LogInfo("qbw:p.RefreshContainer");
	
	local rectview = container:GetFrameRect();
	if nil == rectview then
		LogInfo("qbw:nil == rectview");
		return;
	end
	rectview.origin.x = 0;
	rectview.origin.y = 0;
	
	
	for i, v in ipairs(idTable) do
		local view = createUIScrollView();
		if view ~= nil then
			LogInfo("qbw:view == nil");
			view:Init(false);
            view:SetViewId(v);
            container:AddView(view);
            local uiLoad = createNDUILoad();
            if uiLoad ~= nil then
                uiLoad:Load("RoleAttr_L.ini", view, p.OnUIEventLeftView, 0, 0);
                uiLoad:Free();
            end
            --宠物名字
            p.ContainerAddPetName(v);
            
            local pRoleForm = GetUiNode(view, ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG);
            local rectForm	= pRoleForm:GetFrameRect();
            if nil ~= pRoleForm then
                local roleNode = createUIRoleNode();
                if nil ~= roleNode then
                    roleNode:Init();
                    roleNode:SetFrameRect(CGRectMake(0, 0, rectForm.size.w, rectForm.size.h));
                    roleNode:ChangeLookFace(RolePetFunc.GetLookFace(v));
                    pRoleForm:AddChild(roleNode);
                end
            end
            --宠物Attr
            p.UpdatePetAttrById(v);
            --宠物星云
            p.UpdateDestinyById(v);
            
            --宠物装备
            local idlist	= ItemPet.GetEquipItemList(friendId, v);
            LogInfo("pet装备id列表");
            LogInfoT(idlist);
            for i, v in ipairs(idlist) do
                local nPos	= Item.GetItemInfoN(v, Item.ITEM_POSITION);
                local nTag	= p.GetEquipTag(nPos);
                LogInfo("tag:[%d] position:[%d]",nTag,nPos)
                if nTag > 0 then
                    local equipBtn	= GetEquipButton(view, nTag);
                    if CheckP(equipBtn) then
                        LogInfo("aaa")
                        equipBtn:ChangeItem(v);
                    end
                end
            end
            
            local expUI = RecursivUIExp(view, {ID_ROLEATTR_L_CTRL_EXP_ROLE});
            expUI:SetVisible(false);
            LogInfo("qbw:2233:"..i);
		end
		
	end
end

--刷新星运
function p.RefreshDestinyContainer()
    local nPlayerId = friendId;
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    
    --玩家面板列表
    local petContainer = p.GetDestinyContainer();
	if nil == petContainer then
		LogInfo("nil == petContainer");
		return;
	end
	petContainer:RemoveAllView();
	local petRectview = petContainer:GetFrameRect();
	petContainer:SetViewSize(petRectview.size);
    
    --获取玩家宠物id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
    idTable = RolePet.OrderPets(idTable, friendId);
    
	for i, v in ipairs(idTable) do
		local view = createUIScrollView();
		if view == nil then
			LogInfo("view == nil");
			return;
		end
		view:Init(false);
		view:SetViewId(v);
		petContainer:AddView(view);
		
		local uiLoad = createNDUILoad();
		if uiLoad ~= nil then
			uiLoad:Load("destiny/DestinyBag_L.ini", view, p.OnUIEventBag, 0, 0);
			uiLoad:Free();
		else
			return;
		end
		
		p.RefreshPet(v);
        p.RefreshPetEquip(v);
	end
    p.RefreshDestinyValue();
end

function p.OnUIEventBag(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventBag[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        local equipBtn = ConverToItemButton(uiNode);
        if(equipBtn) then
            local nItemId = equipBtn:GetItemId();
            BackLevelThreeWin.ShowUIDestiny(nItemId, p.GetPetIdOnShow(), nil);
        end
    end
    return true;
end

local TAG_PET_LEVEL         = 16;       --等级
local TAG_PET_LUCK          = 235;      --星运

local TAG_PET_ACT_DESC              = 19;   --攻击说明
local TAG_PET_ACT					= 20;   --攻击
local TAG_PET_SPEED					= 27;   --速度
local TAG_PET_DEX					= 28;   --物防
local TAG_PET_LIFE					= 22;   --生命
local TAG_PET_MAGIC					= 29;   --策防
local TAG_PET_SKILL                 = 24;   --技能
local TAG_PET_ANIMATE               = 9;    --角色动画

local TAG_EQUIP_LIST_1 = {--装备列表
    [Item.POSITION_DAO_FA_1] = 201,
    [Item.POSITION_DAO_FA_2] = 203,
    [Item.POSITION_DAO_FA_3] = 205,
    [Item.POSITION_DAO_FA_4] = 207,
    [Item.POSITION_DAO_FA_5] = 202,
    [Item.POSITION_DAO_FA_6] = 204,
    [Item.POSITION_DAO_FA_7] = 206,
    [Item.POSITION_DAO_FA_8] = 208,
};

local TAG_EQUIP_NAME_LIST_1 = {--装备列表名
    [Item.POSITION_DAO_FA_1] = 146,
    [Item.POSITION_DAO_FA_2] = 148,
    [Item.POSITION_DAO_FA_3] = 150,
    [Item.POSITION_DAO_FA_4] = 152,
    [Item.POSITION_DAO_FA_5] = 147,
    [Item.POSITION_DAO_FA_6] = 149,
    [Item.POSITION_DAO_FA_7] = 151,
    [Item.POSITION_DAO_FA_8] = 153,
};	

function p.RefreshPet( nPetId )
    LogInfo("p.RefreshPet");
    local petContainer = p.GetDestinyContainer();
    local view = petContainer:GetViewById(nPetId);
	if not CheckP(view) then
        LogInfo("p.RefreshPetName nil == view");
		return;
	end
    
    --攻击说明
    local nPetType = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);
    local nActType = GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.ATK_TYPE);
    if ( nActType == STAND_TYPE.THIRD) then
        --策攻
        SetLabel( view, TAG_PET_ACT_DESC, GetTxtPri("FAUI_T4") ); 
        SetLabel( view, TAG_PET_ACT, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_ATK) );
    else
        --物攻
        SetLabel( view, TAG_PET_ACT_DESC, GetTxtPri("FAUI_T3") );
        SetLabel( view, TAG_PET_ACT, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_ATK) );
    end
    
    --速度
    SetLabel( view, TAG_PET_SPEED,  RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SPEED) );
   
    --物防
    SetLabel( view, TAG_PET_DEX,  RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_DEF) );
    
    --生命
    SetLabel( view, TAG_PET_LIFE,  RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE) );
    
    --策防
    SetLabel( view, TAG_PET_MAGIC,  RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_DEF) );
    
    --技能
    SetLabel( view, TAG_PET_SKILL,  RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL) );
    
    --等级
    SetLabel( view, TAG_PET_LEVEL,  RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL)..GetTxtPub("Level") );
    
    --角色动画
    local pRoleForm = GetUiNode(view, TAG_PET_ANIMATE);
    if nil ~= pRoleForm then
        
        --判断人物动画是否加载过
        if( GetUiNode(pRoleForm, TAG_PET_ANIMATE) ) then
            return;
        end
        
        local rectForm	= pRoleForm:GetFrameRect();
        local roleNode = createUIRoleNode();
        if nil ~= roleNode then
            roleNode:Init();
            roleNode:SetFrameRect( CGRectMake(0, 0, rectForm.size.w, rectForm.size.h) );
            roleNode:ChangeLookFace(RolePetFunc.GetLookFace( nPetId ));
            pRoleForm:AddChildZTag( roleNode , 0, TAG_PET_ANIMATE);
        end
        
    end
end

--刷新武将装备
function p.RefreshPetEquip(nPetId)
    local nPlayerId = friendId;
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    
    local container = p.GetDestinyContainer();
    if(container == nil) then
        LogInfo("p.RefreshPetEquip container is nil");
        return;
    end
    local view = container:GetViewById(nPetId);
    if(view == nil) then
        LogInfo("p.RefreshPetEquip view is nil");
        return;
    end
    
    --装备
    local idlist	= ItemPet.GetDaoFaItemList(nPlayerId, nPetId);
    for i, v in ipairs(idlist) do
        local nPos	= Item.GetItemInfoN(v, Item.ITEM_POSITION);
        local nTag1,nTag2	= p.GetEquipTag2(nPos);
        LogInfo("nPos:[%d],nTag1[%d],nTag2:[%d]",nPos,nTag1,nTag2);
        if nTag1 > 0 then
            local equipBtn	= GetEquipButton(view, nTag1);
            local equiplbl	= GetLabel(view, nTag2);
            if CheckP(equipBtn) then
                equipBtn:ChangeItem(v);
                
                local nItemType			= Item.GetItemInfoN(v, Item.ITEM_TYPE);
                local strName			= ItemFunc.GetName(nItemType);
                local levelLV           = Item.GetItemInfoN(v, Item.ITEM_ADDITION);
                equiplbl:SetText(string.format("%s.Lv%d",strName,levelLV));
                --设置物品颜色
                ItemFunc.SetDaoFaLabelColor(equiplbl,nItemType);
            end
        end
    end

end

function p.GetEquipTag2(nPos)
	if not CheckT(TAG_EQUIP_LIST_1) or not CheckN(nPos) then
		return 0;
	end
	return ConvertN(TAG_EQUIP_LIST_1[nPos]),ConvertN(TAG_EQUIP_NAME_LIST_1[nPos]);
end

function p.RefreshDestinyValue()
    local petContainer = p.GetDestinyContainer();
    
    if(petContainer == nil) then
        return;
    end
    
    local nPlayerId = friendId;
    local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
    
	for i, v in ipairs(idTable) do
		
        local view = petContainer:GetViewById(v);
        if not CheckP(view) then
            LogInfo("p.RefreshDestinyValue nil == view");
            return;
        end
        
        SetLabel( view, TAG_PET_LUCK, p.GetLuckValue(v).."" ); 
	end
end

--计算星运值
function p.GetLuckValue(nPetId)
    local val = 1;
    local idlist	= ItemPet.GetDaoFaItemList(friendId, nPetId);
    for i,v in ipairs(idlist) do
        local nItemType = Item.GetItemInfoN(v, Item.ITEM_TYPE);
        local nBaseExp = GetDataBaseDataN("daofa_static_config",Num1(nItemType)+1,DB_DAOFA_STATIC_CONFIG.VALUE);
        local nExp = Item.GetItemInfoN(v, Item.ITEM_EXP);
        val = val + nBaseExp + nExp;
        --val = val + nExp;
    end
    
    val = math.ceil(val / 10);
    return val;
end

function p.ContainerAddPetName(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local strPetName = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
	
	local container	= p.GetPetNameSVC();
	if not CheckP(container) then
		return;
	end
	
	local view = createUIScrollView();
	if not CheckP(view) then
		return;
	end
	view:Init(false);
	view:SetViewId(nPetId);
	container:AddView(view);
	
	local size	= view:GetFrameRect().size;
	local btn	= _G.CreateButton("", "", strPetName, CGRectMake(0, 0, size.w, size.h), 12);
    
    --local nQuality = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_QUALITY);
    
	if CheckP(btn) then
        --local cColor = ItemPet.GetPetQuality(nPetId);
        --btn:SetFontColor(cColor);
        
        local nQuality = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_QUALITY);
        btn:SetFontColor(ItemPet.GetQuality(nQuality));
        
        
		btn:SetLuaDelegate(p.OnUIEventClickPetName);
		view:AddChild(btn);
	end
end

function p.RefreshBtnText()

	local scene = GetSMGameScene();
	local BagButton	= RecursiveButton(scene, {NMAINSCENECHILDTAG.FriendAttr,TAG_LAYER_ATTR,ID_ROLEATTR_L_CTRL_BUTTON_BAG});

	--BagButton:SetVisible(false);
	if FriendFunc.IsExistFriend(friendId) then

		str = GetTxtPri("FAUI_T1")
	else 

		str = GetTxtPri("FAUI_T2")
	end	

	BagButton:SetTitle(str);
	
end

function p.SetPetAttr(petView, nPetDataIndex, str)
	if not CheckP(petView) or
		not CheckN(nPetDataIndex) or
		not CheckS(str) then
		LogInfo("PlayerUIAttr.SetPetAttr invalid arg");
		return;
	end
	
	--隐藏按钮
	
	local scene = GetSMGameScene();
	local FireButton	= RecursiveButton(scene, {NMAINSCENECHILDTAG.FriendAttr,TAG_LAYER_ATTR,ID_ROLEATTR_L_CTRL_BUTTON_FIRE});
	FireButton:SetVisible(false);





	
	
	local nTag = 0;
	if nPetDataIndex == PET_ATTR.PET_ATTR_TYPE then
	--职业
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_JOB;

	elseif nPetDataIndex == PET_ATTR.PET_ATTR_LIFE then
	--生命
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_LIFE;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SUPER_SKILL then
	--绝技
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_ABILITY;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SKILL then
	--技能
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_SKILL;

	elseif nPetDataIndex == PET_ATTR.PET_ATTR_NAME then
	--名字
		--todo
		--nTag	= ID_ROLEATTR_L_CTRL_TEXT_PLAYER_NAME;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SPEED	then
	--速度
		nTag	= ID_ROLEATTR_R_CTRL_TEXT_SPEED;
		

   --[[    
    elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHYSICAL then
	--力量
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;    
        
   	elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC then
	--智力
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_MAGIC;     
        
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_DEX	then
    --敏捷	
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_DEX;]]      

      elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHY_ATK then
	--物理攻击
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;    
        SetLabel(petView, ID_ROLEATTR_L_CTRL_TEXT_19, GetTxtPri("FAUI_T3"));
        
   elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC_ATK then
	--策略攻击
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;    
        SetLabel(petView, ID_ROLEATTR_L_CTRL_TEXT_19, GetTxtPri("FAUI_T4"));  
    
    
    elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHY_DEF	then
    --物理防御
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_DEX;      
        
   	elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC_DEF then
	--策略防御
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_MAGIC;            
                     
        
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_LEVEL	then
	--等级
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_LEVEL;	
	end
	
	if nTag > 0 then
		SetLabel(petView, nTag, str);
	end
end


function p.UpdatePetAttrById(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local container = p.GetPetParent();
	if not CheckP(container) then
		return;
	end
		
	if not RolePetUser.IsExistPet(friendId, nPetId) then
		return;
	end
	
	local view	= container:GetViewById(nPetId);
	if not CheckP(view) then
		return;
	end
	
	
	--名字
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_NAME, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));

	--职业
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_TYPE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TYPE));

	--生命
    local strlife = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE);-- .. "/" .. RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE_LIMIT);
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_LIFE, strlife);

    --获取职业类型 主要有  猛将: 1   射手: 2  军师: 3
    local nPetType = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);
    local nActType = GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.ATK_TYPE);
    if ( nActType == 3) then
           --策略攻击
        p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC_ATK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_ATK)); 
    else
        --物理攻击
        p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHY_ATK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_ATK));
    end

    --物理防御
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHY_DEF, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_DEF));  
    
    --策略防御
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC_DEF, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_DEF));
    
   --[[ 
    --力量
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHYSICAL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHYSICAL));
    
    --法术
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC));
    
	--敏捷
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_DEX, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DEX));
	]]  

	--绝技
	--p.SetPetAttr(view, PET_ATTR.PET_ATTR_SUPER_SKILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SUPER_SKILL));
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_SUPER_SKILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL));

	--速度
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_SPEED, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SPEED));
	--SetLabel(view, 27, SafeN2S(99));
	
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_LEVEL, GetTxtPub("levels")..":"..RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL));
	
	local expUI	= RecursivUIExp(view, {ID_ROLEATTR_L_CTRL_EXP_ROLE});
	if CheckP(expUI) then
		expUI:SetProcess(ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_EXP)));
		expUI:SetTotal(ConvertN(RolePetFunc.GetNextLvlExp(nPetId)));
	end
end

--宠物星云
function p.UpdateDestinyById(nPetId)
    --未完成

end

function p.ChangePetAttr(nPetId)
	LogInfo("qbw:change attr"..nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("not RolePet.IsExistPet[%d]", nPetId);
	end
	
	local layer = p.GetDetailParent();
	if not CheckP(layer) then
		return;
	end

	
	--姓名
	local l_name = SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_NAME, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
    
    
    local nQuality = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_QUALITY);
    ItemPet.SetLabelByQuality(l_name, nQuality)
    
    
    
	--职业
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_JOB, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TYPE));
	--技能
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_SKILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL));
	--等级
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_LEVEL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL));
	--SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_LEVEL, SafeN2S(99));
	--生命
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_LIFE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE));
	
    --力量
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHYSICAL));
    --敏捷
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DEX));
    --智力
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC));
    --速度
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SPEED));
    
    --[[
	--物理攻击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_ATK));
	--物理防御
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_DEF));
	--策略攻击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_ATK));
	--策略防御
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_DEF));]]    
    
	--绝防
	--SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_STUNT_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL_DEF));
	--暴击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_CRIT, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DRITICAL));
	--韧性
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_TENACITY, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TENACITY));
	--命中
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_HIT, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_HITRATE));
	--闪避
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_DODGE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DODGE));
	--破击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_WRECK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_WRECK));
	--格档
	--SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_BLOCK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_BLOCK));
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_BLOCK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_BLOCK));
	--必杀
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_KILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_HURT_ADD));
	--护驾
	SetLabel(layer, ID_ROLEATTR_L_CTRL_TEXT_HELP, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_HELP));
	--战力 todo
	--SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_FIGHTING, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL));

end


---------------
--UI事件处理回调函数
---------------
function p.OnUIEventLeftView(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventLeftView[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local equipBtn = ConverToEquipBtn(uiNode);
		if not CheckP(equipBtn) then
			LogInfo("click equipment not CheckP(itemBtn) ");
			return true;
		end
		LogInfo("equip p.ChangeItemInfo[%d]", equipBtn:GetItemId());
		
		local nItemId = equipBtn:GetItemId();
		--判断是否弹出框
    	if(nItemId == 0) then
        	return true;
   	    end
   	    local ChosedPetId = p.GetPetIdOnShow();
   	    
       -- BackLevelThreeWin.ShowUIEquip(nItemId, ChosedPetId, true);
        BackLevelThreeWin.ShowUIEquip(nItemId, 0, true);

	end
	
	return true;

end


function p.OnUIEvent(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		if tag == ID_ROLEATTR_R_CTRL_BUTTON_95 then
			--关闭界面
			CloseUI(NMAINSCENECHILDTAG.FriendAttr);
			if parentLayerTag ~= nil then
			    LogInfo("Set parent true")
			    FriendFunc.SetLayerVisible(parentLayerTag,true);
			end
		elseif tag == ID_ROLEATTR_L_CTRL_BUTTON_BAG then
			if FriendFunc.IsExistFriend(friendId) then
				 CommonDlgNew.ShowYesOrNoDlg(string.format(GetTxtPri("FAUI_T5"),friendName), p.OnCommonDlgDelFriend, true);
			else
				FriendFunc.AddFriend(friendId,friendName); --加为好友 
			end
			
	    end
	end	
	return true;
end

function p.OnUIEventScroll(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventScroll[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_67 then
			MsgFriend.SendOpenGiveFlower(friendId,friendName,NMAINSCENECHILDTAG.FriendAttr);
			
		elseif tag == ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_66 then
		        if FriendUI.IsExistFriend(friendId)  then
				    CommonDlg.ShowYesOrNoDlg(string.format(GetTxtPri("FAUI_T5"),friendName), p.OnCommonDlgDelFriend, true);
				else
				    FriendFunc.AddFriend(friendId,friendName); --加为好友 
				end	
                
        elseif tag == TAG_DESTINY_BAG then
            p.ChangeView();
		end
	end
	
	return true;
end


function p.OnUIEventClickPetName(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    --获取按钮所在的view
		local view	= PRecursiveSV(uiNode, 1);
		if CheckP(view) then
			local nPetId		= ConvertN(view:GetViewId())
			local containter	= p.GetPetNameSVC();
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
			
			containter = p.GetPetParent();
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
		end
	end
	
	return true;
end

function p.ChangePetHeadPic(nId)
	if not CheckN(nId) then
		return nil;
	end
	
	local nPetType = RolePet.GetPetInfoN(nId,PET_ATTR.PET_ATTR_TYPE);
	
    if(nPetType == 0) then
        return nil;
    end
    
    local layer = p.GetDetailParent();
    
    local pic = GetPetPotraitPic(nPetType);
    local HeadPic = GetImage(layer, ID_ROLEATTR_R_CTRL_PICTURE_ROLE_ICON);
	HeadPic:SetPicture(pic,true);
end


function p.OnUIEventViewChange(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventViewChange[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		local containter	= ConverToSVC(uiNode);
		local nPetId		= 0;
		if CheckP(containter) and CheckN(param) then
			local beginView	= containter:GetView(param);
			if CheckP(beginView) then
				nPetId	= beginView:GetViewId()
				p.ChangePetAttr(nPetId);
				p.ChangePetHeadPic(nPetId);
				
			end
		end
		
		if not nPetId or nPetId <= 0 then
			return true;
		end
	
		if ID_ROLEATTR_L_BG_CTRL_LIST_LEFT == tag or ID_ROLEATTR_L_BG_CTRL_LIST_LEFT_DESTINY == tag then
            LogInfo("p.OnUIEventViewChange:nPetId:[%d]",nPetId);
			containter	= p.GetPetNameSVC();
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
		elseif ID_ROLEATTR_L_BG_CTRL_LIST_NAME == tag then
			containter = ConverToSVC(uiNode);
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
		end

	end
	
	return true;
end


--[[
function p.OnCommonDlgDelFriend(nId, nEvent, param)
	if nEvent == CommonDlg.EventOK then
			MsgFriend.SendFriendDel(friendId,friendName);--删除好友         
	end
end	
]]

function p.OnCommonDlgDelFriend(nEventType , nEvent, param)
    if(CommonDlgNew.BtnOk == nEventType) then
         MsgFriend.SendFriendDel(friendId);
    end
end	

function p.ClickOtherPlayer(param1,param2,param3)
	LogInfo("qbw:click other")
	--CheckOtherPlayerBtn.LoadUI(param1);
	return;
	--[[
	if not _G.CheckN(param1) then
		LogInfo("qbw:friend no param");
		return
	end
	
	local nFriendId = param1;
	MsgFriend.SendFriendSel(nFriendId,"testid:"..nFriendId);
	
	--]]
	
end

_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_CLICK_OTHERPLAYER,"FriendAttrUI.ClickOtherPlayer",p.ClickOtherPlayer);


