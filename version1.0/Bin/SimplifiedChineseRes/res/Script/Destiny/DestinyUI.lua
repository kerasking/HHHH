---------------------------------------------------
--描述: 占星
--时间: 2012.11.09
--作者: chh
---------------------------------------------------
DestinyUI = {}
local p = DestinyUI;

p.bFlagConfirm = false;

local MAX_GRID_NUM_PER_PAGE			= 16;

local NUMBER_FILE = "/number/num_1.png";
local N_W = 42;
local N_H = 34;
local Numbers_Rect = {
    CGRectMake(N_W*0,0.0,N_W,N_H),
    CGRectMake(N_W*1,0.0,N_W,N_H),
    CGRectMake(N_W*2,0.0,N_W,N_H),
    CGRectMake(N_W*3,0.0,N_W,N_H),
    CGRectMake(N_W*4,0.0,N_W,N_H),
    CGRectMake(N_W*5,0.0,N_W,N_H),
    CGRectMake(N_W*6,0.0,N_W,N_H),
    CGRectMake(N_W*7,0.0,N_W,N_H),
    CGRectMake(N_W*8,0.0,N_W,N_H),
    CGRectMake(N_W*9,0.0,N_W,N_H),
};
local TAG_NUMBER_IMG = 156;
local TAG_MOUSE	= 9999;	

local TAG_CLOSE = 225;

local TAG_E_TMONEY      = 243;  --
local TAG_E_TEMONEY     = 242;  --

local TAG_BEGIN_ARROW01   = 10;
local TAG_END_ARROW02     = 9;

local TAG_BEGIN_ARROW03   = 1411;
local TAG_END_ARROW04     = 1412;

local TAG_PET_NAME_CONTAINER        = 50;
local TAG_PET_CONTAINER             = 51;
local TAG_BACK_PAGE_CONTAINER       = 65;
local TAG_BACK_CONTAINER            = 680;


--左边面板TAG
local TAG_PET_LEVEL         = 16;       --等级
local TAG_PET_LUCK          = 235;      --星运
local TAG_BAG_BUTTON        = 23;       --背包连接

local TAG_PET_ACT_DESC              = 19;   --攻击说明
local TAG_PET_ACT					= 20;   --攻击
local TAG_PET_SPEED					= 27;   --速度
local TAG_PET_DEX					= 28;   --物防
local TAG_PET_LIFE					= 22;   --生命
local TAG_PET_MAGIC					= 29;   --策防
local TAG_PET_SKILL                 = 24;   --技能
local TAG_PET_ANIMATE               = 9;    --角色动画

local TAG_BAG_CAPACITY              = 35;   --背包容量
local TAG_AUTO_SYNTHESIS            = 102;  --一键合成
local TAG_DESTINY_FETE              = 101;  --占星祭祀

local TAG_BAG_LIST = {--背包tag列表
    62,66,67,68,63,69,70,71,64,72,73,74,65,75,76,77
};		

local TAG_BAG_NAME_LIST = {--背包tag列表
    171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186
};		


local TAG_EQUIP_LIST = {--装备列表
    [Item.POSITION_DAO_FA_1] = 201,
    [Item.POSITION_DAO_FA_2] = 203,
    [Item.POSITION_DAO_FA_3] = 205,
    [Item.POSITION_DAO_FA_4] = 207,
    [Item.POSITION_DAO_FA_5] = 202,
    [Item.POSITION_DAO_FA_6] = 204,
    [Item.POSITION_DAO_FA_7] = 206,
    [Item.POSITION_DAO_FA_8] = 208,
};

local TAG_EQUIP_NAME_LIST = {--装备列表名
    [Item.POSITION_DAO_FA_1] = 146,
    [Item.POSITION_DAO_FA_2] = 148,
    [Item.POSITION_DAO_FA_3] = 150,
    [Item.POSITION_DAO_FA_4] = 152,
    [Item.POSITION_DAO_FA_5] = 147,
    [Item.POSITION_DAO_FA_6] = 149,
    [Item.POSITION_DAO_FA_7] = 151,
    [Item.POSITION_DAO_FA_8] = 153,
};					


--往背包增加一个物品
function p.AddItem(idItem)
    if( MsgRealize.nIsStopRefreshBag ) then
        return;
    end

    LogInfo("DestinyUI.AddItem");
	if not CheckN(idItem) then
		return;
	end
	
	if not IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then
		return;
	end
	local container		= p.GetBackContainer();
	if not CheckP(container) then
		LogInfo("p.AddItem not CheckP(container)");
		return;
	end
	local nCount = ConvertN(container:GetViewCount());
	if nCount <= 0 then
		LogInfo("p.AddItem nCount <= 0");
		return;
	end
    LogInfo("nCount:[%d]",nCount);
	for	i=1, nCount do
		local sv = container:GetViewById(i);
		if not CheckP(sv) then
			LogInfo("not CheckP(sv) id[%d]", i);
			break;
		end
		for i, v in ipairs(TAG_BAG_LIST) do
            LogInfo("i:[%d],v:[%d]",i,v);
			local itemButton = RecursiveItemBtn(sv, {v});
            local itemlbl = RecursiveLabel(sv, {TAG_BAG_NAME_LIST[i]});
			if CheckP(itemButton) and 0 == itemButton:GetItemId() then
                itemButton:ChangeItem(idItem);
                itemButton:SetFocus(true);
                
                
                local nItemType			= Item.GetItemInfoN(idItem, Item.ITEM_TYPE);
                local strName			= ItemFunc.GetName(nItemType);
                local levelLV           = Item.GetItemInfoN(idItem, Item.ITEM_ADDITION);
                itemlbl:SetText(string.format("%sLv%d",strName,levelLV));
                --设置物品颜色
                ItemFunc.SetDaoFaLabelColor(itemlbl,nItemType);
                
                
				return;
			end
		end 
	end
    p.SetBagCapacity();
    p.RefreshGoods();
end

--从背包删除一个物品
function p.DelItem(idItem)
    if( MsgRealize.nIsStopRefreshBag ) then
        return;
    end
    
	LogInfo("DestinyUI.DelItem");
	if not CheckN(idItem) then
		return;
	end
	
	if not IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then
		return;
	end
	local container		= p.GetBackContainer();
	if not CheckP(container) then
	end
	local nCount = ConvertN(container:GetViewCount());
	if nCount <= 0 then
		return;
	end
	
	LogInfo("bag page count[%d]", nCount);
	LogInfo("del item[%d]", idItem);
	
	for	i=1, nCount do
		local sv = container:GetViewById(i);
		if not CheckP(sv) then
			LogInfo("not CheckP(sv) id[%d]", i);
			break;
		end
		for i, v in ipairs(TAG_BAG_LIST) do
			local itemButton = RecursiveItemBtn(sv, {v});
            if(itemButton) then
                LogInfo("item tag[%d]id[%d]", v, itemButton:GetItemId());
            end
		end 
	end
	
	for	i=1, nCount do
		local sv = container:GetViewById(i);
		if not CheckP(sv) then
			LogInfo("not CheckP(sv) id[%d]", i);
			break;
		end
		for i, v in ipairs(TAG_BAG_LIST) do
			local itemButton = RecursiveItemBtn(sv, {v});
            local itemlbl = RecursiveLabel(sv, {TAG_BAG_NAME_LIST[i]});
			if CheckP(itemButton) and idItem == itemButton:GetItemId() then
				itemButton:ChangeItem(0);
                itemButton:SetFocus(false);
                itemlbl:SetText("");
			end
		end 
	end
    p.SetBagCapacity();
    p.RefreshGoods();
end

--在指定位置显示装备
function p.AddEquip(idPet, idItem, nPostion)	
	--LogInfo("p.AddEquip");
	if not IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then
		return;
	end
	
	if not CheckN(idPet) or
		not CheckN(idItem) or
		not CheckN(nPostion) then
		return;
	end
	
	local view = p.GetCurPetView(idPet);
	if not CheckP(view) then
		return;
	end
	
	local equipBtn,equiplbl = p.GetPetEquipBtnByPos(view, nPostion);
	if not CheckP(equipBtn) then
		return;
	end
    
    if not CheckP(equiplbl) then
		return;
	end
    
	equipBtn:ChangeItem(idItem);
    
    
    local nItemType			= Item.GetItemInfoN(idItem, Item.ITEM_TYPE);
    local strName			= ItemFunc.GetName(nItemType);
    local levelLV           = Item.GetItemInfoN(idItem, Item.ITEM_ADDITION);
    equiplbl:SetText(string.format("%sLv%d",strName,levelLV));
    --设置物品颜色
    ItemFunc.SetDaoFaLabelColor(equiplbl,nItemType);
end

--从指定位置删除装备
function p.DelEquip(idPet, idItem, nPostion)
	--LogInfo("p.DelEquip");
	if not IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then
		return;
	end
	
	if not CheckN(idPet) or
		not CheckN(nPostion) then
		return;
	end
	
	local view = p.GetCurPetView(idPet);
	if not CheckP(view) then
		return;
	end
	
	local equipBtn,equiplbl = p.GetPetEquipBtnByPos(view, nPostion);
	if not CheckP(equipBtn) then
		return;
	end
	
	if equipBtn:GetItemId() == idItem then
		equipBtn:ChangeItem(0);
	end
    
    equiplbl:SetText("");
end

--获得装备的位置根据nTag
function p.GetPosByBtnTag( nTag )
    LogInfo("p.GetPosByBtnTag nTag:[%d]",nTag);
    for i,v in pairs(TAG_EQUIP_LIST) do
        LogInfo("i:[%d],v:[%d],nTag:[%d]",i,v,nTag);
        if(v == nTag) then
            return i;
        end
    end
    return 0;
end

function p.GetPetEquipBtnByPos(viewPet, nPostion)
	if not CheckN(nPostion) or not CheckP(viewPet) then
		return nil;
	end
	
	local nTag1	= TAG_EQUIP_LIST[nPostion];
	if not CheckN(nTag1) then
		return nil;
	end
    
    local nTag2 = TAG_EQUIP_NAME_LIST[nPostion];
    if not CheckN(nTag2) then
		return nil;
	end
	
	return _G.GetEquipButton(viewPet, nTag1),_G.GetLabel(viewPet, nTag2);
end



function p.LoadUI( nPetId )
    
    --stage限制判断
    if not MainUIBottomSpeedBar.GetFuncIsOpen(129) then
        CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("DU_T16")));
        return false;
    end

	local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
	local layer = createNDUILayer();
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.DestinyUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
	layer:SetDestroyNotify(p.OnDestroy);
	
    --加载UI
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	uiLoad:Load("destiny/DestinyBag_BG.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
    
    --鼠标图片初始化
	local imgMouse	= createNDUIImage();
	imgMouse:Init();
	imgMouse:SetTag(TAG_MOUSE);
	layer:AddChildZ(imgMouse, 2);
    
    p.RefreshMoney();
    
    --三级窗口初始化
    BackLevelThreeWin.LoadUI(layer);
    
    p.RefreshPetNameContainer();
    p.RefreshPetContainer();
    
    p.RefreshBackContainer();
    
    if(nPetId) then
        p.ShowPetInfo(nPetId);
    end
    
	return true;
end

function p.ShowPetInfo(nPetId)
    LogInfo("p.ShowPetInfo");
    local container = p.GetPetContainer();
    if(container == nil) then
        LogInfo("p.RefreshPetEquip container is nil");
        return;
    end
    if(nPetId == nil) then
        LogInfo("p.RefreshPetEquip nPetId is nil");
        return;
    end
    LogInfo("p.ShowPetInfo nPetId:[%d]",nPetId);
    container:ShowViewById(nPetId);
end

function p.OnUIEventBag(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventBag[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_PET_ANIMATE) then
            PlayerUIAttr.LoadUI(p.GetCurPetId());
            p.Close();
        else
            local equipBtn = ConverToItemButton(uiNode);
            local nItemId = equipBtn:GetItemId();
            if( p.IsEquipPanel(tag) )then
                BackLevelThreeWin.ShowUIDestiny(nItemId, p.GetCurPetId(), true);
            elseif ( p.IsBagPanel(tag) ) then
                BackLevelThreeWin.ShowUIDestiny(nItemId, p.GetCurPetId(), false);
            end
        end
    
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT then
        
        --向外拖拽时
        if not CheckStruct(param) then
			LogInfo("物品往外拖 invalid param");
			return true;
		end
        
        local itemBtn = ConverToItemButton(uiNode);
        if not CheckP(itemBtn) then
			LogInfo("物品往外拖 not CheckP(itemBtn) ");
			return true;
		end
        
        local nItemId = itemBtn:GetItemId();
        if ( nItemId <= 0 ) then
            LogInfo("拖动没有物品");
            return true;
        end
        
        p.DragMoveIng( itemBtn:GetImageCopy(),  param);
        
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT_COMPLETE then
        
         p.DragMoveEnd();
         
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_IN then
        --放到其它物品放开时
        
        LogInfo("NUIEventType.TE_TOUCH_BTN_DRAG_IN");
        
        local itemBtnA = ConverToItemButton(param);
        local itemBtnB = ConverToItemButton(uiNode);
        
        p.DragEnd(itemBtnA, itemBtnB);
    end
    return true;
end


function p.DragMoveIng( pic, moveTouch )
    p.SetMouse(pic, moveTouch);
end

function p.DragMoveEnd()
    p.SetMouse(nil, SizeZero());
end

function p.DragEnd(itemBtnA, itemBtnB)
    if(itemBtnA == nil or itemBtnB == nil) then
        LogInfo("itemBtnA == nil or itemBtnB == nil");
        return;
    end
    local nItemId1 = itemBtnA:GetItemId();
    local nItemId2 = itemBtnB:GetItemId();
    
    if((nItemId1 > 0 and nItemId2 > 0) or p.IsEquipPanel(itemBtnA:GetTag()) and p.IsEquipPanel(itemBtnB:GetTag()) and (nItemId1 > 0 and nItemId2 > 0)) then
        --两个装备按钮都在背包里，两个按钮都有ID,合成操作
        
        if ( nItemId1 == nItemId2 ) then
            LogInfo("p.MergeTwos 合成参数错误");
            return true;
        end
        
        --===================================================================================================
        --提示信息
        local nId1,nId2 = p.GetMerageResult(nItemId1, nItemId2);
        local nItemType1 = Item.GetItemInfoN(nId1, Item.ITEM_TYPE);
        local nItemType2 = Item.GetItemInfoN(nId2, Item.ITEM_TYPE);
        
        --福星不能吞噬福星
        if(Num1(nItemType1) == DAOFA_QUALITY_DATA.RED and Num1(nItemType2) == DAOFA_QUALITY_DATA.RED) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T19"));
            return;
        end
        --===================================================================================================
        
        
        
        
        
        
        --===================================================================================================
        --最高等级判断
        local nMaxLevel    = p.GetQualityMaxLevel(Num1(nItemType1));
        local levelLV      = Item.GetItemInfoN(nId1, Item.ITEM_ADDITION);
        if( levelLV>=nMaxLevel ) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T20"));
            return;
        end
        
        --===================================================================================================
        
        
        
        
        
        --只有背包到装备栏要此判断
        if(p.IsBagPanel(itemBtnA:GetTag()) and p.IsEquipPanel(itemBtnB:GetTag())) then
            --===================================================================================================
            --判断是否有相同占星存在
            local nType1    = GetDataBaseDataN("itemtype", nItemType1, DB_ITEMTYPE.ATTR_TYPE_1)/10;
            local nStatusType1 = GetDataBaseDataN("itemtype", nItemType1, DB_ITEMTYPE.STATUS_ATTR_TYPE1);
            local idlist	= ItemPet.GetDaoFaItemList(GetPlayerId(), p.GetCurPetId());
            for i,v in ipairs(idlist) do
                
                local nItemType2			= Item.GetItemInfoN(v, Item.ITEM_TYPE);
                local nType2 = GetDataBaseDataN("itemtype", nItemType2, DB_ITEMTYPE.ATTR_TYPE_1)/10;
                local nStatusType2 = GetDataBaseDataN("itemtype", nItemType2, DB_ITEMTYPE.STATUS_ATTR_TYPE1);
                
                if(nType1 == 0) then
                    if(nStatusType1 == nItemType2 and v ~= nId1 and v ~= nId2) then
                        CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T27"));
                        return false;
                    end
                else
                    if(nType1 == nType2 and v ~= nId1 and v ~= nId2) then
                        CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T27"));
                        return false;
                    end
                end
                
            end
            --===================================================================================================
        end
        
        
        
        
        --===================================================================================================
        local bIsUpgrade,nExp,nLevel,nOutExp = p.IsMerageUpgrade(nId1, nId2);
        local sTip = nil;
        if(bIsUpgrade) then
            if(nOutExp>0) then
                sTip = string.format(GetTxtPri("DU_T21"),ItemFunc.GetName(nItemType1),ItemFunc.GetName(nItemType2),nExp,nLevel,nOutExp)
            else
                sTip = string.format(GetTxtPri("DU_T10"),ItemFunc.GetName(nItemType1),ItemFunc.GetName(nItemType2),nExp,nLevel)
            end
        else
            sTip = string.format(GetTxtPri("DU_T9"),ItemFunc.GetName(nItemType1),ItemFunc.GetName(nItemType2),nExp)
        end
        --===================================================================================================
        
        
        
        
        
        
        --===================================================================================================
        --合成
        if(p.bFlagConfirm == false) then
            CommonDlgNew.ShowNotHintDlg(sTip, p.FlagConfirmCallBack, {nItemId1, nItemId2});
        else
            p.MergeTwos(nItemId1, nItemId2);
        end
        --===================================================================================================
        
        
        
    elseif(p.IsBagPanel(itemBtnA:GetTag()) and p.IsEquipPanel(itemBtnB:GetTag())) then
        --穿装备
        BackLevelThreeWin.DestinyEquipOperate(itemBtnA:GetItemId(), p.GetCurPetId(), p.GetPosByBtnTag(itemBtnB:GetTag()), false);
    elseif(p.IsEquipPanel(itemBtnA:GetTag()) and p.IsBagPanel(itemBtnB:GetTag())) then
        --脱装备
        BackLevelThreeWin.DestinyEquipOperate(itemBtnA:GetItemId(), p.GetCurPetId(), nil, true);
    end
end

function p.FlagConfirmCallBack(nEventType, param, val)
    LogInfo("p.FlagConfirmCallBack");
    if(nEventType == CommonDlgNew.BtnOk) then
        p.MergeTwos(param[1], param[2]);
        p.bFlagConfirm = val;
    elseif(nEventType == CommonDlgNew.BtnNo) then
        p.bFlagConfirm = val;
    end
end


function p.GetMerageResult(nItemId1, nItemId2)
    --判断哪个物品合成哪个物品
    local nItemIdResult1 = 0;
    local nItemIdResult2 = 0;
    
    local nItemType1	= Item.GetItemInfoN(nItemId1, Item.ITEM_TYPE);
    local nItemType2	= Item.GetItemInfoN(nItemId2, Item.ITEM_TYPE);
    
    local nQuality1 = Num1(nItemType1);
    local nQuality2 = Num1(nItemType2);
    
    LogInfo("nItemId1:[%d],nItemId2:[%d],nQuality1:[%d],nQuality2:[%d]",nItemId1,nItemId2,nQuality1,nQuality2);
    
    if(nQuality1>nQuality2) then
        LogInfo("nQuality1>nQuality2");
        nItemIdResult1 = nItemId1;
        nItemIdResult2 = nItemId2;
    elseif(nQuality1<nQuality2) then
        LogInfo("nQuality1<nQuality2");
        nItemIdResult1 = nItemId2;
        nItemIdResult2 = nItemId1;
    else
        local nExp1 = Item.GetItemInfoN(nItemId1, Item.ITEM_EXP);
        local nExp2 = Item.GetItemInfoN(nItemId2, Item.ITEM_EXP);
        if(nExp1<nExp2) then
            LogInfo("nExp1<nExp2");
            nItemIdResult1 = nItemId2;
            nItemIdResult2 = nItemId1;
        else
            LogInfo("else nExp1<nExp2");
            nItemIdResult1 = nItemId1;
            nItemIdResult2 = nItemId2;
        end
    end
    return nItemIdResult1,nItemIdResult2;
end

--1吞食2是否会升级
--参数：1.是否会升级 2.合成的经验 3.升级的等级 4.超出的经验
function p.IsMerageUpgrade(nItemId1, nItemId2)
    
    local nItemType1    = Item.GetItemInfoN(nItemId1, Item.ITEM_TYPE);
    local nItemType2    = Item.GetItemInfoN(nItemId2, Item.ITEM_TYPE);
    local nExp = GetDataBaseDataN("daofa_static_config",Num1(nItemType2)+1,DB_DAOFA_STATIC_CONFIG.VALUE);
    local nExp1 = Item.GetItemInfoN(nItemId1, Item.ITEM_EXP);
    local nExp2 = Item.GetItemInfoN(nItemId2, Item.ITEM_EXP) + nExp;
    local nExpTotal = nExp1+nExp2;
    local nLevelExp = BackLevelThreeWin.GetTotalByItemId(nItemId1);
    
    --计算星运合成后可升到哪一级
    local nLevel    = p.GetQualityMaxLevel(Num1(nItemType1));
    local nMaxLevel = nLevel;
    local nQuality = Num1(nItemType1);
    local ids = GetDataBaseIdList("dao_levelup_exp");
    for i,v in ipairs(ids) do
        local nQualityV = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.QUALITY);
        if(nQuality == nQualityV) then
            local nExpV = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.EXP);
            if(nExpTotal < nExpV) then
                nLevel = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.LEVEL) - 1;
                break;
            end
        end
    end
    
    --计算超出的经验 和 重新计算合成所得的经验
    local nOutExp      = 0;
    if(nMaxLevel == nLevel) then
        nOutExp      = nExp1+nExp2 - nLevelExp;
        nExp2        = nExp2 - nOutExp;
        
        LogInfo("nOutExp:[%d],nExp1:[%d],nExp2:[%d],nLevelExp:[%d]",nOutExp,nExp1,nExp2,nLevelExp);
    end
    
    
    --计算是否可升级
    if(nExp1+nExp2>=nLevelExp) then
        return true,nExp2,nLevel,nOutExp;
    end
    return false,nExp2,nLevel,nOutExp;
end

--获得一个品质的最高等级
function p.GetQualityMaxLevel( nQuality )
    local nLevel = 0;
    local ids = GetDataBaseIdList("dao_levelup_exp");
    for i,v in ipairs(ids) do
        local nQualityV = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.QUALITY);
        if(nQuality == nQualityV) then
            nLevelV = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.LEVEL);
            if(nLevelV > nLevel) then
                nLevel = nLevelV;
            end
        end
    end
    return nLevel;
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
	local imgMouse = RecursiveImage(scene, {NMAINSCENECHILDTAG.DestinyUI, TAG_MOUSE});
	if not CheckP(imgMouse) then
		LogInfo("not CheckP(imgMouse)");
		return;
	end
	
	imgMouse:SetPicture(pic, true);
	
	if CheckP(pic) then
		local size		= pic:GetSize();
		local nMoveX	= moveTouch.x - size.w / 2 - RectFullScreenUILayer.origin.x;
		local nMoveY	= moveTouch.y - size.h / 2 - RectFullScreenUILayer.origin.y;
		imgMouse:SetFrameRect(CGRectMake(nMoveX, nMoveY, size.w, size.h));
	else
		LogInfo("imgMouse:SetFrameRect(RectZero)");
		imgMouse:SetFrameRect(RectZero());
	end
end

function p.GetAutoMergeList()
    local idItems = ItemUser.GetDaoFaItemList(GetPlayerId());
    local lst = {};
    for i,v in ipairs(idItems) do
        local nItemType = Item.GetItemInfoN(v, Item.ITEM_TYPE);
        local nMaxLevel    = p.GetQualityMaxLevel(Num1(nItemType));
        local levelLV      = Item.GetItemInfoN(v, Item.ITEM_ADDITION);
        
        if(levelLV < nMaxLevel or Num1(nItemType) == DAOFA_QUALITY_DATA.RED) then
            table.insert(lst,v);
        end
    end
    return lst;
end





--是否全部都是福星
function p.IsAllFuxin(idItems)
    for i,v in ipairs(idItems) do
        local nItemType = Item.GetItemInfoN(v, Item.ITEM_TYPE);
        local nMaxLevel    = p.GetQualityMaxLevel(Num1(nItemType));
        local levelLV      = Item.GetItemInfoN(v, Item.ITEM_ADDITION);
        
        if(levelLV < nMaxLevel and Num1(nItemType) ~= DAOFA_QUALITY_DATA.RED) then
            return false;
        end
    end
    return true;
end


--是否有多个最高品质
function p.IsMaxQualitys(idItems)
    local nCount = 0;
    for i,v in ipairs(idItems) do
        local nItemType     = Item.GetItemInfoN(v, Item.ITEM_TYPE);
        local nQuality      = Num1(nItemType);
        if(nQuality == DAOFA_QUALITY_DATA.ORANGE) then
            nCount = nCount + 1;
        end
    end
    return nCount;
end


--获得超出的经验
function p.GetOutExp(idItems)
    LogInfo("p.GetOutExp");
    local nOutExp = 0;
    if(#idItems<2) then
        return nOutExp;
    end
    local nExp = Item.GetItemInfoN(idItems[1], Item.ITEM_EXP);
    local nItemType = Item.GetItemInfoN(idItems[1], Item.ITEM_TYPE);
    local nQuality = Num1(nItemType);
    local nMaxLevel = p.GetQualityMaxLevel(nQuality);
    local nMaxExp = p.GetExpByQualityAndLevel(nQuality,nMaxLevel);
    
    LogInfo("nExp:[%d] ; nMaxExp:[%d]",nExp,nMaxExp);
    
    local nTempExp = 0;
    for i=2,#idItems do
        local nItemTypeV = Item.GetItemInfoN(idItems[i], Item.ITEM_TYPE);
        nTempExp = nTempExp + GetDataBaseDataN("daofa_static_config",Num1(nItemTypeV)+1,DB_DAOFA_STATIC_CONFIG.VALUE) + Item.GetItemInfoN(idItems[i], Item.ITEM_EXP);
        
        LogInfo("nExp:[%d] + nTempExp:[%d] > nMaxExp:[%d]",nExp,nTempExp,nMaxExp);
        if(nExp + nTempExp > nMaxExp) then
            nOutExp = nExp + nTempExp - nMaxExp;
            break;
        end
    end

    return nOutExp;
end


--根据品质和等级获得升级的经验
function p.GetExpByQualityAndLevel(nQuality, nLevel)
    LogInfo("p.GetExpByQualityAndLevel nQuality:[%d],nLevel:[%d]",nQuality,nLevel);
    local nExp = 0;
    local ids = GetDataBaseIdList("dao_levelup_exp");
    for i,v in ipairs(ids) do
        local nQualityV = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.QUALITY);
        local nLevelV = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.LEVEL);
        if(nQuality == nQualityV and nLevel == nLevelV) then
            nExp = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.EXP);
            break;
        end
    end
    return nExp;
end


function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_CLOSE) then
			p.Close();
        elseif(tag == TAG_BAG_BUTTON) then
            PlayerUIBackBag.LoadUI(nil, p.GetCurPetId());
            p.Close();
        elseif(tag == TAG_AUTO_SYNTHESIS) then
            local idItems = p.GetAutoMergeList();
            
            if( #idItems < 2 ) then
                CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T1"));
                return;
            end
            
            idItems = Item.OrderDestinys(idItems);
            
            if (p.IsAllFuxin(idItems)) then
                CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T22"));
                return true;
            end
            
            local sTip = "";
            --是否有橙色品质
            if(p.IsMaxQualitys(idItems) > 1) then
                sTip = string.format(GetTxtPri("DU_T23"),GetTxtPri("DU_T8"));
            else
                
                local nOutExp = p.GetOutExp(idItems);
                if(nOutExp>0) then
                    sTip = string.format(GetTxtPri("DU_T24"),nOutExp,GetTxtPri("DU_T8"));
                else
                    sTip = GetTxtPri("DU_T8");
                end
            end
            
            CommonDlgNew.ShowYesOrNoDlg(sTip,p.MerageAllCallback);
        elseif(tag == TAG_DESTINY_FETE) then
            MsgRealize.sendRealizeOp( p.GetCurPetId() );
            
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		if tag == TAG_BACK_CONTAINER then
            local petContainer = ConverToSVC(uiNode);
            local petPageContainer = p.GetBackPageContainer();
            petPageContainer:ShowViewByIndex(petContainer:GetBeginIndex());
            SetArrow(p.GetCurrLayer(),p.GetBackPageContainer(),1,TAG_BEGIN_ARROW03,TAG_END_ARROW04);
            
		end
    end
    return true;
end

--一键合成确认
function p.MerageAllCallback(nEventType, param)
    if(nEventType == CommonDlgNew.BtnOk) then
        p.MergeAll();
    end
end

--合成
function p.MergeTwos(nItemId1, nItemId2)
    if ( (nItemId1 <= 0 or nItemId2 <= 0) or (nItemId1 == nItemId2)) then
        LogInfo("p.MergeTwos 合成参数错误");
        return true;
    end
    
    ShowLoadBar();
    MsgRealize.sendRealizeMerge(nItemId1, nItemId2);
end


--一键合成
function p.MergeAll()
    local idItems = ItemUser.GetDaoFaItemList(GetPlayerId());
    ShowLoadBar();
    MsgRealize.sendMergeAll();
end


function p.GetCurPetView()
	local parent	= p.GetPetContainer();
	if not CheckP(parent) then
        LogInfo("p.GetCurPetView parent is nil!");
		return nil;
	end
	
	return parent:GetBeginView(); 
end

function p.GetCurPetId()
	local view	= p.GetCurPetView();
	if not CheckP(view) then
        LogInfo("p.GetCurPetId view is nil!");
		return 0;
	end
	
	return view:GetViewId();
end

function p.OnDestroy()
    p.FreeData();
end

function p.Close()
	p.FreeData();
	CloseUI(NMAINSCENECHILDTAG.DestinyUI);
end

function p.FreeData()
    MsgShop.mUIListener = nil;
end


function p.RefreshPetNameContainer()
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    
    --玩家面板列表
    local petContainer = p.GetPetNameContainer();
	if nil == petContainer then
		LogInfo("nil == petContainer");
		return;
	end
    petContainer:SetTouchEnabled(false);
	petContainer:RemoveAllView();
	local petRectview = petContainer:GetFrameRect();
	petContainer:SetViewSize(petRectview.size);
    
    --获取玩家宠物id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
    idTable = RolePet.OrderPets(idTable);
    
	for i, v in ipairs(idTable) do
		local view = createUIScrollView();
		if view == nil then
			LogInfo("view == nil");
			return;
		end
		view:Init(false);
		view:SetViewId(v);
        view:SetTouchEnabled(false);
		petContainer:AddView(view);
		p.RefreshPetName(v);
	end
end

--填充名称
function p.RefreshPetName( nPetId )
    if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local strPetName = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
	local petNameContainer	= p.GetPetNameContainer();
	if not CheckP(petNameContainer) then
        LogInfo("p.RefreshPetName nil == petNameContainer");
		return;
	end
	
	local view = petNameContainer:GetViewById(nPetId);
	if not CheckP(view) then
        LogInfo("p.RefreshPetName nil == view");
		return;
	end
    
	local size	= view:GetFrameRect().size;
	local btn	= _G.CreateButton("", "", strPetName, CGRectMake(0, 0, size.w, size.h), 15);
    
    local cColor = ItemPet.GetPetQuality(nPetId);
    btn:SetFontColor(cColor);
    
    if CheckP(btn) then
		view:AddChild(btn);
	end
    
    SetArrow(p.GetCurrLayer(),p.GetPetNameContainer(),1,TAG_BEGIN_ARROW01,TAG_END_ARROW02);
end

function p.RefreshPetContainer()
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    
    --玩家面板列表
    local petContainer = p.GetPetContainer();
	if nil == petContainer then
		LogInfo("nil == petContainer");
		return;
	end
	petContainer:RemoveAllView();
	local petRectview = petContainer:GetFrameRect();
	petContainer:SetViewSize(petRectview.size);
    petContainer:SetLuaDelegate(p.OnUIEvenPet);
    
    --获取玩家宠物id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
    idTable = RolePet.OrderPets(idTable);
    
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

function p.RefreshPet( nPetId )
    LogInfo("p.RefreshPet");
    local petContainer = p.GetPetContainer();
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
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    
    local container = p.GetPetContainer();
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
        local nTag1,nTag2	= p.GetEquipTag(nPos);
        LogInfo("nPos:[%d],nTag1[%d],nTag2:[%d]",nPos,nTag1,nTag2);
        if nTag1 > 0 then
            local equipBtn	= GetEquipButton(view, nTag1);
            local equiplbl	= GetLabel(view, nTag2);
            if CheckP(equipBtn) then
                equipBtn:ChangeItem(v);
                
                local nItemType			= Item.GetItemInfoN(v, Item.ITEM_TYPE);
                local strName			= ItemFunc.GetName(nItemType);
                local levelLV           = Item.GetItemInfoN(v, Item.ITEM_ADDITION);
                equiplbl:SetText(string.format("%sL%d",strName,levelLV));
                --设置物品颜色
                ItemFunc.SetDaoFaLabelColor(equiplbl,nItemType);
            end
        end
    end

end

function p.GetEquipTag(nPos)
	if not CheckT(TAG_EQUIP_LIST) or not CheckN(nPos) then
		return 0;
	end
	return ConvertN(TAG_EQUIP_LIST[nPos]),ConvertN(TAG_EQUIP_NAME_LIST[nPos]);
end

function p.OnUIEvenPet(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvenPet tag:[%d]", tag);
	
    
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
    elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		if tag == TAG_PET_CONTAINER then
            local petContainer = ConverToSVC(uiNode);
            local petNameContainer = p.GetPetNameContainer();
            petNameContainer:ShowViewByIndex(petContainer:GetBeginIndex());
            SetArrow(p.GetCurrLayer(),p.GetPetNameContainer(),1,TAG_BEGIN_ARROW01,TAG_END_ARROW02);
            
        elseif tag == TAG_BACK_CONTAINER then
            local petContainer = ConverToSVC(uiNode);
            local petPageContainer = p.GetBackPageContainer();
            petPageContainer:ShowViewByIndex(petContainer:GetBeginIndex());
            SetArrow(p.GetCurrLayer(),p.GetBackPageContainer(),1,TAG_BEGIN_ARROW03,TAG_END_ARROW04);
            
		end 
	end
end

--刷新分页控件
function p.RefreshBackPageContainer()

    local container = p.GetBackPageContainer();
    if(container == nil) then
        LogInfo("container is nil!");
        return;
    end
    
    container:RemoveAllView();
	
    local rectview = container:GetFrameRect();
    container:SetViewSize(rectview.size);
    
    
    local idItems = ItemUser.GetDaoFaItemList(GetPlayerId());
    
    idItems = Item.OrderDestinys(idItems);
    local tSize			= table.getn(idItems);
    
    local nMaxBackNum = tSize / MAX_GRID_NUM_PER_PAGE;
    if(tSize == 0) then
        nMaxBackNum = 1;
    elseif(tSize % MAX_GRID_NUM_PER_PAGE ~= 0) then
        nMaxBackNum = nMaxBackNum + 1;
    end
    
    for i=1, nMaxBackNum do
        local view = createUIScrollView();
		if view == nil then
			LogInfo("p.LoadUI createUIScrollView failed");
			return;
		end
		view:Init(false);
		view:SetViewId(i);
		container:AddView(view);
        
        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            layer:Free();
            return false;
        end
        uiLoad:Load("Number_Item.ini", view, nil, 0, 0);
        p.refreshNumberListItem(view,i);
        view:SetTouchEnabled(false);
    end
    
end

function p.refreshNumberListItem(view,i)
    local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
    local norpic = pool:AddPicture(GetSMImgPath(NUMBER_FILE), false);
    norpic:Cut(Numbers_Rect[i+1]);
    local img = GetImage(view, TAG_NUMBER_IMG);
    img:SetPicture(norpic);
end

function p.SetBagCapacity()
    LogInfo("DestinyUI.SetBagCapacity");
    if not IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then
        return;
    end
    
    local idItems = ItemUser.GetDaoFaItemList(GetPlayerId());
    
    --容量
    local txt = string.format("%d/%d",#idItems,GetVipVal(DB_VIP_CONFIG.DESTINY_BAG_NUM));
    SetLabel(p.GetCurrLayer(),TAG_BAG_CAPACITY,txt);
end




-----刷新背包数据正在做
function p.RefreshBackContainer()
    LogInfo("p.RefreshBackContainer");
	
    --分页控件刷新
    p.RefreshBackPageContainer();
    
    --加载UI
	p.LoadBackBagUI();
    
    --填充UI
    p.FullBackBagUI();
    
    --背包数量的显示
    p.SetBagCapacity();
end

--加载背包UI
function p.LoadBackBagUI()
	local container = p.GetBackContainer();
	if not container then
		LogInfo("p.LoadBackBagUI p.GetBackContainer == nil");
		return;
	end
    local nBeginIndex = container:GetBeginIndex();
    container:RemoveAllView();
    
	local rectview = container:GetFrameRect();
	if nil == rectview then
		LogInfo("p.LoadBackBagUI nil == rectview");
		return;
	end
	    
    --禁止滚动框滚动
	container:SetLeftReserveDistance(10000);
    container:SetRightReserveDistance(10000);
    
	container:SetViewSize(rectview.size);
    container:ShowViewByIndex(0);
    
	local nPlayerId		= ConvertN(GetPlayerId());
    local idlistItem	= ItemUser.GetDaoFaItemList(nPlayerId);
	local tSize			= table.getn(idlistItem);
    local nMaxBackNum = tSize / MAX_GRID_NUM_PER_PAGE;
    if(tSize == 0) then
        nMaxBackNum = 1;
    elseif(tSize % MAX_GRID_NUM_PER_PAGE ~= 0) then
        nMaxBackNum = nMaxBackNum + 1;
    end
    local nGridNum		= GetVipVal(DB_VIP_CONFIG.DESTINY_BAG_NUM);
	for i=1, nMaxBackNum do
		local view = createUIScrollView();
		if view == nil then
			LogInfo("p.LoadBackBagUI createUIScrollView failed");
			return;
		end
		view:Init(false);
		view:SetViewId(i);
		container:AddView(view);
		
		local uiLoad = createNDUILoad();
		if uiLoad ~= nil then
			uiLoad:Load("destiny/DestinyBag_R_List.ini", view, p.OnUIEventBag, 0, 0);
			uiLoad:Free();
		end
        
         for j,v in ipairs(TAG_BAG_LIST) do
            LogInfo("i:[%d],j:[%d],max:[%d],tSize:[%d]",i,j,MAX_GRID_NUM_PER_PAGE,tSize)
            if (i-1)*MAX_GRID_NUM_PER_PAGE+j > nGridNum then
                local btn = GetItemButton( view, v );
                if( btn ) then
                    btn:RemoveFromParent(true);
                end
            end
        end
	end
    container:ShowViewByIndex(nBeginIndex);
    SetArrow(p.GetCurrLayer(),p.GetBackPageContainer(),1,TAG_BEGIN_ARROW03,TAG_END_ARROW04);
end

--填充背包UI
function p.FullBackBagUI()
    local container = p.GetBackContainer();
	if not container then
		LogInfo("p.RefreshBackBag p.GetBackContainer == nil");
		return;
	end
	
	local nPlayerId		= ConvertN(GetPlayerId());
	local nGridNum		= GetVipVal(DB_VIP_CONFIG.DESTINY_BAG_NUM);
	
	local idlistItem	= ItemUser.GetDaoFaItemList(nPlayerId);
	local tSize			= table.getn(idlistItem);
    
    LogInfo("idlistItem Begin");
    LogInfoT(idlistItem);
    LogInfo("idlistItem End");
    
    idlistItem = Item.OrderItems(idlistItem);
    
    local nMaxBackNum = tSize / MAX_GRID_NUM_PER_PAGE;
    if(tSize == 0) then
        nMaxBackNum = 1;
    elseif(tSize % MAX_GRID_NUM_PER_PAGE ~= 0) then
        nMaxBackNum = nMaxBackNum + 1;
    end
    
    for i=1, nMaxBackNum do
		local view = container:GetViewById(i);
		if nil ~= view then
			for j=1, MAX_GRID_NUM_PER_PAGE do
				local nTag1,nTag2		= p.GetGridTag(j);
				local itemBtn	= _G.GetItemButton(view, nTag1);
                local itemlbl	= _G.GetLabel(view, nTag2);
				if nil ~= itemBtn then
					local nItemId	= 0;
					local nIndex	= (i - 1) * MAX_GRID_NUM_PER_PAGE + j;
					if nIndex <= tSize then
						nItemId		= idlistItem[nIndex];
					end
					nItemId			= nItemId or 0;
                    LogInfo("nItemId:[%d]",nItemId);
                    if nIndex <= nGridNum then
                        itemBtn:ChangeItem(nItemId);
                        
                        if(nItemId == 0) then
                            itemBtn:SetFocus(false);
                            itemlbl:SetText("");
                        else
                            itemBtn:SetFocus(true);
                            
                            local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
                            local strName			= ItemFunc.GetName(nItemType);
                            local levelLV           = Item.GetItemInfoN(nItemId, Item.ITEM_ADDITION);
                            itemlbl:SetText(string.format("%sL%d",strName,levelLV));
                            --设置物品颜色
                            ItemFunc.SetDaoFaLabelColor(itemlbl,nItemType);
                        end
                        
                        
                        
                    else
                        itemBtn:ChangeItem(0);
                        itemBtn:SetFocus(false);
                        itemlbl:SetText("");
                    end
                    
                    
                    
                    
				else
					LogError("p.RefreshBackBag item button tag[%d][%d] error", j, nTag1);
				end
                
                
			end
		end
	end
end


function p.IsEquipPanel( nTag )
    for i=Item.POSITION_DAO_FA_1, Item.POSITION_DAO_FA_8 do
        if( TAG_EQUIP_LIST[i] == nTag ) then
            return true;
        end
    end
    return false;
end

function p.IsBagPanel( nTag )
    for i,v in ipairs(TAG_BAG_LIST) do
        if( v == nTag ) then
            return true;
        end
    end
    return false;
end


--判断哪个位置上可装备占星
--返回：
--0 装备栏已满
--非0 可装备的位置
function p.GetCanEquipPosition()
    LogInfo("DestinyUI.GetCanEquipPosition")
    local view = p.GetCurPetView( p.GetCurPetId() );
    if not CheckP(view) then
        LogInfo("DestinyUI.GetCanEquipPosition view is nil");
        return 0;
    end
    
    for i=Item.POSITION_DAO_FA_1, Item.POSITION_DAO_FA_8 do
        
        local equipBtn = p.GetPetEquipBtnByPos(view, i);
        if not CheckP(equipBtn) then
            LogInfo("DestinyUI.GetCanEquipPosition equipBtn is nil:i:[%d],TAG_EQUIP_LIST[i]:[%d]",i,TAG_EQUIP_LIST[i]);
            return 0;
        end
        
        if( equipBtn:GetItemId()==0 ) then
            LogInfo("DestinyUI.GetCanEquipPosition nPosition:[%d],TAG_EQUIP_LIST[i]:[%d]",i,TAG_EQUIP_LIST[i]);
            return i;
        end
        
    end
    return 0;
end


function p.GetGridTag(i)
	if not CheckT(TAG_BAG_LIST) or 0 == table.getn(TAG_BAG_LIST) then
		return 0;
	end
	
	if i <= table.getn(TAG_BAG_LIST) then
		return TAG_BAG_LIST[i],TAG_BAG_NAME_LIST[i];
	end
	
	return 0;
end

--刷新金钱
function p.RefreshMoney()
    LogInfo("DestinyUI.RefreshMoney");
    local nPlayerId     = GetPlayerId();
    
    local layer = p.GetCurrLayer();
    if(layer == nil) then
        return;
    end
    
    local nmoney        = MoneyFormat(GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY));
    local ngmoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY).."";
    
    _G.SetLabel(layer, TAG_E_TMONEY, nmoney);
    _G.SetLabel(layer, TAG_E_TEMONEY, ngmoney);
end




--=====================================================================================--
--获得武将名称面板
function p.GetPetNameContainer()
    local layer = p.GetCurrLayer();
    if(layer == nil) then
        return;
    end
    
    local containter = RecursiveSVC(layer, {TAG_PET_NAME_CONTAINER});
	return containter;
end

--获得武将装备面板
function p.GetPetContainer()
    local layer = p.GetCurrLayer();
    
    if(layer == nil) then
        return;
    end
    
    local containter = RecursiveSVC(layer, {TAG_PET_CONTAINER});
	return containter;
end

--获得背包分页面板
function p.GetBackPageContainer()
    local layer = p.GetCurrLayer();
    
    if(layer == nil) then
        return;
    end
    
    local containter = RecursiveSVC(layer, {TAG_BACK_PAGE_CONTAINER});
	return containter;
end

--获得背包面板
function p.GetBackContainer()
    local layer = p.GetCurrLayer();
    
    if(layer == nil) then
        return;
    end
    
    local containter = RecursiveSVC(layer, {TAG_BACK_CONTAINER});
	return containter;
end

function p.GetCurrLayer()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
        LogInfo("nil == scene")
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DestinyUI);
	if not CheckP(layer) then
		LogInfo("nil == layer")
		return nil;
	end
	
	return layer;
end
--=====================================================================================--


function p.RefreshGoods()
    if( MsgRealize.nIsStopRefreshBag ) then
        return;
    end
    
    p.RefreshBackContainer();
    p.SetBagCapacity();
    p.RefreshDestinyValue();
end


function p.RefreshPetInfo(nPetId)
    LogInfo("DestinyUI.PetInfoRefresh");
	if not CheckN(nPetId) then
        LogInfo("nPetId is nil");
		return;
	end
	if not IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then
        LogInfo("_G.NMAINSCENECHILDTAG.DestinyUI is nil");
		return;
	end
	p.RefreshPet(nPetId);
end

function p.RefreshPetAttr(datalist)
    LogInfo("p.RefreshPetInfo");
    
    if not CheckT(datalist) then
        LogInfo("not CheckT(datalist)");
		return;
	end
    
	if not IsUIShow(NMAINSCENECHILDTAG.DestinyUI) then
        LogInfo("not IsUIShow(NMAINSCENECHILDTAG.DestinyUI)");
		return;
	end
	local nPetId	= datalist[1];
	if not CheckN(nPetId) then
		LogError("not CheckN(nPetId)");
		return;
	end

    p.RefreshPetInfo(nPetId);
end

function p.RefreshDestinyValue()
    local petContainer = p.GetPetContainer();
    
    if(petContainer == nil) then
        return;
    end
    
    local nPlayerId = GetPlayerId();
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
    local idlist	= ItemPet.GetDaoFaItemList(GetPlayerId(), nPetId);
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



GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"DestinyUI.RefreshMoney",p.RefreshMoney);
GameDataEvent.Register(GAMEDATAEVENT.ITEMINFO,"DestinyUI.RefreshGoods", p.RefreshGoods);
GameDataEvent.Register(GAMEDATAEVENT.ITEMATTR,"DestinyUI.RefreshGoods", p.RefreshGoods);
GameDataEvent.Register(GAMEDATAEVENT.PETINFO, "DestinyUI.PetInfoRefresh", p.RefreshPetInfo);
GameDataEvent.Register(GAMEDATAEVENT.PETATTR, "DestinyUI.RefreshPetInfo", p.RefreshPetAttr);