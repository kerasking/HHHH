

---------------------------------------------------
--描述: 装备养成
--时间: 2012.5.25
--作者: chh
---------------------------------------------------
EquipUpgradeUI = {}
local p = EquipUpgradeUI;

p.nTagQuick = nil;  --加速确认框Tag

p.TagClose      = 3;    --关闭
p.TagStreng     = 6;    --强化按钮
p.TagBaptize    = 7;    --洗炼按钮
p.TagMosaic     = 8;    --镶嵌按钮


p.TAG = {
    STRENGTHEN    = 1001,     --强化层
    BAPTIZE       = 1002,     --洗炼层
    MOSAIC        = 1003,     --镶嵌层
};

p.TAG_CHANGE_BTNS = {[p.TAG.STRENGTHEN] = p.TagStreng, [p.TAG.BAPTIZE] = p.TagBaptize,[p.TAG.MOSAIC] = p.TagMosaic,};

p.TagPetNameList    = 601;      --武将列表
local TAG_PET_NAME  = 1;        --武将名字

p.TagPetNameListL   = 24;       --武将列表左箭头
p.TagPetNameListR   = 25;       --武将列表右箭头
p.TagUserList      = 600;       --用户列表
p.TagEquipList      = 5;        --装备列表
p.TagEquipListItemHeight = 55*ScaleFactor; --装备列表项

p.idGemListItem     = {};       --背包宝石列表
p.idEquipListItem   = {};       --背包装备列表

local TAG_EQUIP_PIC     = 2;    --装备图片
local TAG_EQUIP_NAME    = 6;    --装备名字
local TAG_EQUIP_LEVEL   = 7;    --强化等级
local TAG_EQUIP_BUTTON  = 5;    --强化按钮

--强化UI Tag
local TAG_E_PIC         = 2;    --装备图片
--local TAG_E_NAME        = 3;    --装备名字
local TAG_E_LEVEL       = 17;   --装备强化等级
local TAG_E_ATTACK_TXT  = 15;   --装备说明
local TAG_E_ATTACK      = 18;   --强化攻击
local TAG_E_MONEY       = 19;   --强化费用

local TAG_E_WAIT_TIME_TIP = 6;  --冷却时间说明
local TAG_E_WAIT_TIME   = 8;    --冷却时间
local TAG_E_QUICK       = 13;   --加速按钮
local TAG_E_STRENG      = 11;   --强化按钮

local TAG_E_C_CD        = 124;  --取消CD
local TAG_E_O_CRIT      = 119;  --开启爆击
local TAG_E_O_DISCOUNT  = 120;  --开启打折功能
local TAG_E_O_CD2       = 121;  --提示需求取消CD

--洗炼UI Tag
local TAG_B_OLD_ATTRS   = {21,22,23,};      --原属性
local TAG_B_NEW_ATTRS   = {24,25,26,};      --新属性
local TAG_B_PIC         = 2;                --图片
local TAG_B_NAME        = 3;                --名称
local TAG_B_BTN_B       = 11;               --洗炼按钮
local TAG_B_BTN_KEEP    = 12;               --保持按钮
local TAG_B_BTN_RRPLACE = 13;               --替换按钮

local TAG_RadioJin5     = 31;
local TAG_RadioJin10     = 32;

local TAG_VIP_PLATINUM  = 47;
local TAG_VIP_EXTREME   = 48;



p.TAG_B_PIC = TAG_B_PIC;
p.TAG_B_BTN_KEEP = TAG_B_BTN_KEEP;
p.TAG_B_BTN_B = TAG_B_BTN_B;


p.TagRadioGroud = {
    TONG    = 27,--铜币洗炼
    JIN5    = 28,--10金洗炼
    JIN10   = 29,--100金洗炼
};

p.BaptizeMoney = {
    TONG    = 20000,    --铜币洗炼
    JIN5    = 10,        --10金洗炼
    JIN10   = 100,      --100金洗炼
};


--洗炼颜色
local BaptizeColor = {
    ccc4(255,0,0,255),
    ccc4(251,165,46,255),
    ccc4(0,255,0,255),
};


--培养文本
p.TrainTags = {
    30,31,32,
};


local ReqJinVip3 = 3;
local ReqJinVip6 = 6;

--宝石UI Tag
local TAG_M_PAGE_L      = 13;       --宝石分页左边图
local TAG_M_PAGE_R      = 12;       --宝石分页右边图
local TAG_M_PAGE_LIST   = 11;       --宝石分页列表
local TAG_M_GEM_LIST    = 10;       --宝石列表
local TAG_M_GEM_GRID    = {4,5,6,7,8,9,};    --宝石镶嵌表格
local TAG_M_GEM_BAG     = {4,5,6,7,8,9,10,11,12,13};    --宝石物品背包

local TAG_M_GEM_EQUIP   = 13;
local TAG_M_GEM_EQUIP_NAME = 15;


local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local Wait_Time    = 1200;

local MAX_LEVEL     = 100;

local COLOR_RED     = ccc4(255,0,0,255);
local COLOR_GREEN     = ccc4(14,182,22,255);
local RectRightUILayer = CGRectMake(160.0*ScaleFactor, 42.5*ScaleFactor, 320.0*ScaleFactor, 275.0*ScaleFactor);



-- 宝石分页
local MAX_GEM_NUM				= 0;
local MAX_GRID_NUM_PER_PAGE		= 10;

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

local TAG_BEGIN_ARROW   = 1411;
local TAG_END_ARROW     = 1412;


p.TimerHander = nil;

p.nItemIdTemp   = 0;        --选中的装备ID

p.nCurrPage = 0;            --当前界面 值（p.TAG）

function p.LoadUI(page)
--------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    
    
--------------------添加层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.EquipUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,1);
-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("foster_A.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();
    
    




--------------------初始化强化UI---------------------------------------
    local layerStreng = createNDUILayer();
	if layerStreng == nil then
		return false;
	end
	layerStreng:Init();
	layerStreng:SetTag(p.TAG.STRENGTHEN);
	layerStreng:SetFrameRect(RectRightUILayer);
    layerStreng:SetVisible(false);
	layer:AddChild(layerStreng);
-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("foster_A_R1.ini", layerStreng, p.OnUIEventStreng, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();
    local btn = GetButton(layerStreng, TAG_E_QUICK);
    btn:SetVisible(false);




    






--------------------初始化洗炼UI---------------------------------------
    local layerBaptize = createNDUILayer();
	if layerBaptize == nil then
		return false;
	end
	layerBaptize:Init();
	layerBaptize:SetTag(p.TAG.BAPTIZE);
	layerBaptize:SetFrameRect(RectRightUILayer);
    layerBaptize:SetVisible(false);
	layer:AddChild(layerBaptize);
-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("foster_A_R2.ini", layerBaptize, p.OnUIEventBaptize, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();
    
    local btn = GetButton(layerBaptize, TAG_B_BTN_KEEP);
    btn:SetVisible(false);
    local btn = GetButton(layerBaptize, TAG_B_BTN_RRPLACE);
    btn:SetVisible(false);
    
    
--------------------初始化镶嵌UI---------------------------------------
    local layerMosaic = createNDUILayer();
	if layerMosaic == nil then
		return false;
	end
	layerMosaic:Init();
	layerMosaic:SetTag(p.TAG.MOSAIC);
	layerMosaic:SetFrameRect(RectRightUILayer);
    --layerMosaic:SetVisible(false);
	layer:AddChild(layerMosaic);
-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("foster_A_R3.ini", layerMosaic, p.OnUIEventUnMosaic, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();
    
    p.initData();
    if(CheckN(page)) then
        p.ChangeTab(page);
    else
        p.ChangeTab(p.TAG.STRENGTHEN);
    end
    
-------------------------------初始化数据------------------------------------    
    
    p.setTrainRadio(p.TagRadioGroud.TONG);
    
    
    --设置箭头
    p.setArrow(p.GetLayerByTag(p.TAG.MOSAIC),p.GetGemViewContainer());
    
    p.SetFocusOnPage(0);
    
    
    
    --设置洗炼文本内容
    for i,v in ipairs(p.TrainTags) do
        local sDesc = GetDataBaseDataS("equip_edu_config",i,DB_EQUIP_EDU_CONFIG.DESCRIPT);
        SetLabel(layerBaptize,v,sDesc);
    end
    
    
    
    
    MsgEquipStr.mUIListener = p.processNet;
    MsgCompose.mUIListener = p.processNet;
    
   
    --设置关闭音效
   	local closeBtn=GetButton(layer, p.TagClose);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   	

   	
    return true;
end


function p.setArrow(layer,pageView)
    --设置箭头   
    local larrow    = GetButton(layer,TAG_BEGIN_ARROW);
    local rarrow    = GetButton(layer,TAG_END_ARROW);
            
    local pageIndex = pageView:GetBeginIndex();
    local pageCount = pageView:GetViewCount();
    
    larrow:EnalbeGray(false);
    rarrow:EnalbeGray(false);
    if(pageIndex == 0) then
        larrow:EnalbeGray(true);
    end
    if(pageIndex == pageCount-1) then
        rarrow:EnalbeGray(true);
    end
end



---------------------------初始化窗口--------------------------------------
function p.initData()
    p.idGemListItem = {};
    p.idEquipListItem = {};
    
    local nPlayerId		= ConvertN(GetPlayerId());
    local idlistItem	= ItemUser.GetBagItemList(nPlayerId);
	local nSize			= table.getn(idlistItem);
    
    for i, v in ipairs(idlistItem) do
        local nItemType		= Item.GetItemInfoN(v, Item.ITEM_TYPE);
        local nType			= ItemFunc.GetBigType(nItemType);
        if (nType == Item.bTypeGem) then
            table.insert(p.idGemListItem, v);
        elseif(nType == Item.bTypeEquip) then
            table.insert(p.idEquipListItem, v);
        end
    end
    
    --排序宝石
    local tempVar;
    for i=1, #p.idGemListItem do
        local nItemTypeI	= Item.GetItemInfoN(p.idGemListItem[i], Item.ITEM_TYPE);
        for j=i,#p.idGemListItem do
            
            local nItemTypeJ	= Item.GetItemInfoN(p.idGemListItem[j], Item.ITEM_TYPE);
            if(nItemTypeI<nItemTypeJ) then
                tempVar = p.idGemListItem[i];
                p.idGemListItem[i] = p.idGemListItem[j];
                p.idGemListItem[j] = tempVar;
            end
        end
    end
    
    
    
    MAX_GEM_NUM	= table.getn(p.idGemListItem);
    if(MAX_GEM_NUM == 0) then
        MAX_GEM_NUM = 1;
    end
end

---------------------------关闭窗口--------------------------------------
function p.freeData()
    MsgEquipStr.mUIListener = nil;
    MsgCompose.mUIListener = nil;
    p.idGemListItem = nil;
    p.idEquipListItem = nil;
end


function p.processNet(msgId, m)
    LogInfo("p.processNet msgId"..msgId);
    if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
        return;
	end
	if msgId == NMSG_Type._MSG_EQUIPSTR_INFO then       --强化返回
		LogInfo("testbbs:[%d]",m.StuffId);
        --修改用户信息
        local uContainer = p.GetUserContainer();
        for i=1, uContainer:GetViewCount() do
            LogInfo("uContainer:i=[%d]",i);
            local clientView = uContainer:GetView(i-1);
            
            
            local k=1;
            for j=1, clientView:GetViewCount() do
                k = k+1;
                local view = clientView:GetView(j-1);
                
                if(view:GetViewId() == m.EquipId) then
                    p.refreshEquipInfoListItem(view,m.EquipId);
                    break;
                end
            end
            if(k<clientView:GetViewCount()) then
                break;
            end
            
            
        end
        
        --修改强化窗口信息
        p.refreshStrengView(m.EquipId);
        
        --刷新VIP功能说明
        p.RefreshEachView();
        
        
        if m.StuffId == 1 then
            --暴击光效
            
        end
        
        --强化成功音效
        Music.PlayEffectSound(Music.SoundEffect.EQ_STR);
		--引导任务事件触发
		GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.STRENGTHEN_EQUIP);
   	
    elseif(msgId == NMSG_Type._MSG_STONE) then
        p.initData();
        p.LoadGemBagView();
        LogInfo("m.EquipId:[%d]",m.EquipId);
        p.refreshMosaicView(m.EquipId);
        
        --镶嵌成功音效
        Music.PlayEffectSound(Music.SoundEffect.MOUNTING);
        --引导任务事件触发
		GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.MOSAIC);
   	
    elseif(msgId == NMSG_Type._MSG_EQUIP_EDU_INFO) then
        --洗炼成功音效    
        Music.PlayEffectSound(Music.SoundEffect.WEAPON_BAPTIZE);
        
        --引导任务事件触发
		GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.WASH_EQUIP);
		
        p.RefreshNewAttrData(m);
    elseif(msgId == NMSG_Type._MSG_CONFIRM_EQUIP_EDU) then
        if(m.EquipId == p.nItemIdTemp) then
            p.refreshBaptizeView(p.nItemIdTemp);
        end

	end
	CloseLoadBar();
end

function p.RefreshUI()
    p.RefreshPetInfo();
    p.RefreshEquipInfo();
    p.RefreshGemInfo();
    
    p.RefreshEachView();
end



local TAG_E_WAIT_TIME_TIP = 6;  --冷却时间说明
local TAG_E_WAIT_TIME   = 8;    --冷却时间
local TAG_E_QUICK       = 13;   --加速按钮

local TAG_E_C_CD        = 124;  --取消CD
local TAG_E_O_CRIT      = 119;  --开启爆击
local TAG_E_O_DISCOUNT  = 120;  --开启打折功能
local TAG_E_O_CD2       = 121;  --提示需求取消CD

local TipColor = ccc4(251,165,46,255);

--显示每个页面的vip功能显示
function p.RefreshEachView()
    local layer = p.GetLayer();
    if(layer == nil) then
        return;
    end
    local bIsEnHanceOpen = GetVipIsOpen(DB_VIP_CONFIG.ENHANCE_CLEARTIME);
    local nCritFlag = GetVipIsOpen(DB_VIP_CONFIG.ENHANCE_CRIT_FLAG);
    local nReducePecent = GetVipVal(DB_VIP_CONFIG.ENHANCE_REDUCE_PECENT);
    
    local strangLayer = p.GetLayerByTag(p.TAG.STRENGTHEN);
    
    local l_wtt = GetLabel(strangLayer, TAG_E_WAIT_TIME_TIP);
    local l_wt = GetLabel(strangLayer, TAG_E_WAIT_TIME);
    local l_quick = GetButton(strangLayer, TAG_E_QUICK);

    local l_ecd = GetLabel(strangLayer, TAG_E_C_CD);
    local l_eocrit = GetLabel(strangLayer, TAG_E_O_CRIT);
    local l_eodiscount = GetLabel(strangLayer, TAG_E_O_DISCOUNT);
    local l_eocd2 = GetLabel(strangLayer, TAG_E_O_CD2);
    
    --是否取消CD
    if(bIsEnHanceOpen) then
        l_ecd:SetVisible(true);
        l_wtt:SetVisible(false);
        l_wt:SetVisible(false);
        l_quick:SetVisible(false);
        l_eocd2:SetVisible(false);
    else
        l_ecd:SetVisible(false);
        l_wtt:SetVisible(true);
        l_wt:SetVisible(true);
        l_quick:SetVisible(true);
    end
    
    --暴击
    if(nCritFlag) then
        local nCritCount = GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_EQUIP_CRIT_COUNT);
        local nCritSliver = GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_EQUIP_CRIT_SAVE_MONEY);
        
        l_eocrit:SetText(string.format(GetTxtPri("QiangHuaBaoJiTxt"),nCritCount,nCritSliver));
        l_eocrit:SetFontColor(TipColor);
    end
    
    --折扣
    if(nReducePecent>0) then
        local nMoney = GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_EQUIP_ENHANCE_SAVE_MONEY);
        l_eodiscount:SetText(string.format(GetTxtPri("QiangHuaJieYueTxt"),nMoney));
        l_eodiscount:SetFontColor(TipColor);
    end


    --洗炼VIP限制
    local baptizeLayer = p.GetLayerByTag(p.TAG.BAPTIZE);
    
    local r_Platinum = p.getRadioByTag(p.TagRadioGroud.JIN5);
    local r_Extreme = p.getRadioByTag(p.TagRadioGroud.JIN10);
    
    local l_Platinum = GetLabel(baptizeLayer,TAG_RadioJin5);
    local l_Extreme = GetLabel(baptizeLayer,TAG_RadioJin10);
    
    local l_VipTipPlatinum = GetLabel(baptizeLayer,TAG_VIP_PLATINUM);
    local l_VipExtreme = GetLabel(baptizeLayer,TAG_VIP_EXTREME);
    
    local bIsPlatinum = Is_EQUIP_EDU(BaptizeType.Coin);    
    if(bIsPlatinum) then
        r_Platinum:SetVisible(true);
        l_Platinum:SetVisible(true);
        l_VipTipPlatinum:SetVisible(false);
    else
        r_Platinum:SetVisible(false);
        l_Platinum:SetVisible(false);
        l_VipTipPlatinum:SetVisible(true);
    end
    
    
    local bIsExtreme = Is_EQUIP_EDU(BaptizeType.Extreme);
    if(bIsExtreme) then
        r_Extreme:SetVisible(true);
        l_Extreme:SetVisible(true);
        l_VipExtreme:SetVisible(false);
    else
        r_Extreme:SetVisible(false);
        l_Extreme:SetVisible(false);
        l_VipExtreme:SetVisible(true);
    end
    
end

--选择装备高亮功能
function p.SelectEquipFouce(equipId)
    local uContainer = p.GetUserContainer();
    for i=1, uContainer:GetViewCount() do
        local clientView = uContainer:GetView(i-1);
        for j=1, clientView:GetViewCount() do
            local view = clientView:GetView(j-1);
            local equipBtn = GetItemButton(view, TAG_EQUIP_PIC);
            if(equipBtn == nil) then
                LogInfo("p.SelectEquipFouce equipBtn is nil!");
                return;
            end 
            if(view:GetViewId() ~= equipId) then
                equipBtn:SetFocus(false);
            else
                equipBtn:SetFocus(true);
            end
        end
    end
end

---------------------------刷新武将名称-----------------------------------
function p.RefreshPetInfo()
    local container = p.GetPetNameContainer();
    if nil == container then
		LogInfo("nil == container");
		--return;
	end
	container:RemoveAllView();
    local rectview = container:GetFrameRect();
    container:SetViewSize(rectview.size);
    
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		--return;
	end
    
    --获取玩家伙伴id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil == idTable then
		LogInfo("nil == idTable");
		--return;
	end
    
    --遍历伙伴
	for i, v in ipairs(idTable) do
        --顶部角色名称
		p.AddPetNameItem(v);
	end
    --背包
    p.AddPetNameItem(0);
end



---------------------------刷新武将装备-----------------------------------
function p.RefreshEquipInfo()
    local userContainer = p.GetUserContainer();
    local nIndex = userContainer:GetBeginIndex();
    userContainer:RemoveAllView();
    userContainer:ShowViewByIndex(0);
    
    local rectview = userContainer:GetFrameRect();
    userContainer:SetViewSize(rectview.size);
    
    local nPlayerId = GetPlayerId();
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
    
    
    for i=1, #idTable do
        local petId = idTable[i];
        p.AddPetEquipItem(petId);
    end
    
    p.AddPetEquipItem(0);
    
    --userContainer:ShowViewByIndex(nIndex);
end


function p.AddPetEquipItem(petId)
        local userContainer = p.GetUserContainer();
        local rectview = userContainer:GetFrameRect();
        
        local clientLayer = createContainerClientLayerM();
        clientLayer:Init(false);
        clientLayer:SetViewSize(CGSizeMake(rectview.size.w, p.TagEquipListItemHeight));
        userContainer:AddView(clientLayer);
        
        local nPlayerId = GetPlayerId();
        
        
        local equipIdList = {};
        if(petId==0) then
            equipIdList = p.idEquipListItem;
        else
            equipIdList = ItemPet.GetEquipItemList(nPlayerId, petId);
        end
        
 
        
        if(p.nCurrPage == p.TAG.BAPTIZE) then
        
            local fillEquip = {};
            for i,v in ipairs(equipIdList) do
                local equipId = equipIdList[i];
                local nItemType			= Item.GetItemInfoN(equipId, Item.ITEM_TYPE);
                local nEquipType = Num6(nItemType);
                if(nEquipType == 1) then
                    table.insert(fillEquip,equipId);
                end
            end
            equipIdList=fillEquip;
        end
        
        for j, v in ipairs(equipIdList) do
            local equipId = equipIdList[j];
            local view = createUIScrollViewM();
            view:Init(false);
            view:SetViewId(equipId);
            clientLayer:AddView(view);
    
            --初始化ui
            local uiLoad = createNDUILoad();
            if nil == uiLoad then
                view:Free();
                return false;
            end
            
            uiLoad:Load("foster_A_L_Item.ini", view, nil, 0, 0);
            p.refreshEquipInfoListItem(view,equipId);
        end
end

















function p.AddUserItem(petId)
    local container = p.GetUserContainer();
    local view = createUIScrollView();
    view:Init(false);
    view:SetViewId(petId);
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
	
    uiLoad:Load("foster_A_L.ini", view, nil, 0, 0);
    p.refreshUserInfoListItem(view, petId);
end

function p.refreshUserInfoListItem(view, petId)
    local container = p.GetEquipContainer(petId);
    container:RemoveAllView();
    local rectview = container:GetFrameRect();
    container:SetViewSize(CGSizeMake(rectview.size.w, p.TagEquipListItemHeight));
    
    
    local nPlayerId = GetPlayerId();
    
    
    if( petId == 0 ) then
        --遍历背包装备
        for i, v in ipairs(p.idEquipListItem) do
            p.AddPetEquipItem(v,0);
        end
    else
        local equipIdList = ItemPet.GetEquipItemList(nPlayerId, petId);
        LogInfo("equipIdList:[%d],nPlayerId:[%d],petId:[%d]",#equipIdList,nPlayerId,petId);
        --遍历装备
        for i, v in ipairs(equipIdList) do
            p.AddPetEquipItem(v,petId);
        end
    end
    
end















function p.refreshEquipInfoListItem(view,equipId)
    --set pic
    local pic = GetItemButton(view, TAG_EQUIP_PIC);
    pic:ChangeItem(equipId);
    
    --set name
    local type =Item.GetItemInfoN(equipId, Item.ITEM_TYPE);
    local equipName = ItemFunc.GetName(type);
    local name = GetLabel(view, TAG_EQUIP_NAME);
    name:SetText(equipName);
    
    --set level
    local equipLv = Item.GetItemInfoN(equipId, Item.ITEM_ADDITION);
    local name = GetLabel(view, TAG_EQUIP_LEVEL);
    local lv = GetTxtPub("QianHua")..equipLv;
    lv=lv..GetTxtPub("Level");
    name:SetText(lv);
    
    local btn = GetButton(view, TAG_EQUIP_BUTTON);
    btn:SetParam1(equipId);
    btn:SetLuaDelegate(p.OnUIEventSelectEquipBtn);
end


function p.AddPetNameItem(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	local container = p.GetPetNameContainer();
 
    local view = createUIScrollView();
    if view == nil then
        LogInfo("p.AddPetNameItem createUIScrollView failed");
        return;
    end
    view:Init(false);
    view:SetViewId(nPetId);
    view:SetTag(nPetId);
    container:AddView(view);
        
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
	
    uiLoad:Load("PetNameListItem.ini", view, nil, 0, 0);
    p.refreshPetInfoListItem(view,nPetId);
    
    view:SetTouchEnabled(false);
end

function p.refreshPetInfoListItem(view,nPetId)
    local labelName = GetLabel(view, TAG_PET_NAME);
    if(nPetId == 0) then
        labelName:SetText("背包");
    else
        local strPetName = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
        labelName:SetText(strPetName);
    end
end


function p.OnUIEventSelectEquipBtn(uiNode, uiEventType, param)
    local btn = ConverToButton(uiNode);
    p.nItemIdTemp = btn:GetParam1();
    
    if(p.nCurrPage == p.TAG.STRENGTHEN)then
        --强化
        p.refreshStrengView(p.nItemIdTemp);
    end
    
    if(p.nCurrPage == p.TAG.BAPTIZE)then
        --洗炼
        p.refreshBaptizeView(p.nItemIdTemp);
    end
    
    if(p.nCurrPage == p.TAG.MOSAIC)then
        --镶嵌
        p.refreshMosaicView(p.nItemIdTemp);
    end
    
    --选中装备
    p.SelectEquipFouce(p.nItemIdTemp);
end


function p.GetStrangPic()
    local strangLayer = p.GetLayerByTag(p.TAG.STRENGTHEN);
    if(strangLayer == nil) then
        LogInfo("p.GetStrangPic strangLayer is nil!");
        return 0;
    end
    
    local pic = GetItemButton(strangLayer, TAG_EQUIP_PIC);
    return pic:GetItemId();
end

--强化view填充
function p.refreshStrengView(equipId)
    local strangLayer = p.GetLayerByTag(p.TAG.STRENGTHEN);
    
    
    local pic = GetItemButton(strangLayer, TAG_EQUIP_PIC);
    --local name = GetLabel(strangLayer, TAG_E_NAME);
    local level = GetLabel(strangLayer, TAG_E_LEVEL);
    local txtattack = GetLabel(strangLayer, TAG_E_ATTACK_TXT);
    local attack = GetLabel(strangLayer, TAG_E_ATTACK);
    local money = GetLabel(strangLayer, TAG_E_MONEY);
    
    if(equipId == 0) then
        pic:ChangeItem(0);
        --name:SetText("");
        level:SetText("");
        attack:SetText("");
        money:SetText("");
        return;
    end
    
    pic:ChangeItem(equipId);
    
    
    --set name
    local type =Item.GetItemInfoN(equipId, Item.ITEM_TYPE);
    local equipName = ItemFunc.GetName(type);
    --name:SetText(equipName);
    
    
    local equipLv = Item.GetItemInfoN(equipId, Item.ITEM_ADDITION) + 1;
    if(equipLv>MAX_LEVEL) then
        level:SetText(GetTxtPri("QiangHuaMaxLevelTxt"));
        attack:SetText(GetTxtPri("QiangHuaMaxLevelTxt"));
        money:SetText(GetTxtPri("QiangHuaMaxLevelTxt"));
        return;
    end
    
    --set level
    local lv = GetTxtPub("QianHua")..equipLv;
    lv=lv..GetTxtPub("Level");
    level:SetText(lv);
    
    --set attack
    local txt,num = ItemFunc.GetAttrDesc(type,equipLv);
    txtattack:SetText(txt);
    attack:SetText(num);
    
    --set money
    
    LogInfo("chh_typeid1:[%d]",type);
    local reqMoney = EquipStrFunc.GetReqMoney(type,equipLv);
    money:SetText(reqMoney..GetTxtPub("coin"));
    
end

--洗炼view填充
function p.refreshBaptizeView(equipId)
    local baptizeLayer = p.GetLayerByTag(p.TAG.BAPTIZE);
    local nAttrBegin = Item.ITEM_ATTR_BEGIN;
    --附加属性显示
    local btAttrAmount = Item.GetItemInfoN(equipId, Item.ITEM_ATTR_NUM);
    LogInfo("btAttrAmount:[%d]",btAttrAmount);
    for i=1,#TAG_B_OLD_ATTRS do
        local l_attr = GetLabel(baptizeLayer,TAG_B_OLD_ATTRS[i]);
        if(i<=btAttrAmount) then
       
            local desc = Item.GetItemInfoN(equipId, nAttrBegin);
            nAttrBegin = nAttrBegin + 1;
            local val = Item.GetItemInfoN(equipId, nAttrBegin);
            nAttrBegin = nAttrBegin + 1;
            
            
            local txt = ItemFunc.GetAttrTypeValueDesc(desc,val);
            local nFullVal = p.GetEduPropFull(equipId);
            if(val >= nFullVal) then
                txt = string.format("%s (%s)",txt,GetTxtPri("XiLianFull"));
            end
            
            l_attr:SetText(txt);
        else
            l_attr:SetText("");
        end
    end
    
    local pic = GetItemButton(baptizeLayer,TAG_B_PIC);
    pic:ChangeItem(equipId);
    
    --[[
    local type =Item.GetItemInfoN(equipId, Item.ITEM_TYPE);
    local equipName = ItemFunc.GetName(type);
    local name = GetLabel(baptizeLayer,TAG_B_NAME);   --已被删除
    name:SetText(equipName);
    ]]
end

function p.setTrainRadio(tag)
    for k, v in pairs(p.TagRadioGroud) do
        if(v ~= tag) then
            local radio = p.getRadioByTag(v);
            radio:SetSelect(false);
        end
	end
    local radio = p.getRadioByTag(tag);
    radio:SetSelect(true);
end

function p.getRadioByTag(tag)
    local layer = p.GetLayerByTag(p.TAG.BAPTIZE);
    local nod = GetUiNode(layer, tag);
    local check = ConverToCheckBox(nod);
    return check;
end

function p.getSelectRadio()
    local radio = p.getRadioByTag(p.TagRadioGroud.TONG);
    if radio:IsSelect() then
        return BaptizeType.SilVer;
    end
    
    radio = p.getRadioByTag(p.TagRadioGroud.JIN5);
    if radio:IsSelect() then
        return BaptizeType.Coin;
    end
    
    radio = p.getRadioByTag(p.TagRadioGroud.JIN10);
    if radio:IsSelect() then
        return BaptizeType.Extreme;
    end
    
    return 0;
end

function p.isTrainCheck(tag)
    for k, v in pairs(p.TagRadioGroud) do
        if(v == tag) then
            return true;
        end
    end
    return false;
end



--镶嵌view填充
function p.refreshMosaicView(equipId)
    local mosaicLayer = p.GetLayerByTag(p.TAG.MOSAIC);
    
    local bAttrCount = Item.GetItemInfoN(equipId, Item.ITEM_ATTR_NUM);
    local bGenCount = Item.GetItemInfoN(equipId, Item.ITEM_GEN_NUM);
    
    local gem_beg = Item.ITEM_ATTR_BEGIN + bAttrCount*2;
    
    if(bGenCount>#TAG_M_GEM_GRID) then 
        bGenCount = #TAG_M_GEM_GRID; 
    end
    LogInfo("equipId:[%d], bGenCount:[%d]",equipId, bGenCount);
    for i=1,#TAG_M_GEM_GRID do
        local btnItem = GetItemButton(mosaicLayer, TAG_M_GEM_GRID[i]);
        btnItem:SetParam1(equipId);
        if(i<=bGenCount) then
            local gemTypeId = Item.GetItemInfoN(equipId, gem_beg);
            LogInfo("gemTypeId:[%d]",gemTypeId);
            btnItem:ChangeItemType(gemTypeId);
            gem_beg = gem_beg + 1;
        else
            btnItem:ChangeItem(0);
        end
        
    end
    
    --显示装备信息
    local btnItem = GetItemButton(mosaicLayer, TAG_M_GEM_EQUIP);
    local btnName = GetLabel(mosaicLayer, TAG_M_GEM_EQUIP_NAME);
    btnItem:ChangeItem(equipId);
    local nItemTypeId =Item.GetItemInfoN(equipId, Item.ITEM_TYPE);
    local sEquipName = ItemFunc.GetName(nItemTypeId);
    btnName:SetText(sEquipName);
    
    p.resetEduBtnDisplay();
end

-----------------------------切换UI---------------------------------
function p.ChangeTab(tab)
    local layerMain = p.GetLayer();

    --面板
    local k = 0;
    for i,v in pairs(p.TAG) do
        k = k+1;
        local layer = p.GetLayerByTag(v);
        layer:SetVisible(false);
        
        
        local btn = GetButton(layerMain, p.TAG_CHANGE_BTNS[v]);
        --btn:EnalbeGray(false);
        btn:TabSel(false);
        if(tab ~= nil and v == tab) then
            --btn:EnalbeGray(true);
            btn:TabSel(true);
        end
        
    end
    
    local layer = p.GetLayerByTag(tab);
    layer:SetVisible(true);
    
    --[[
    if(tab == p.TAG.BAPTIZE or p.nCurrPage == p.TAG.BAPTIZE) then
        p.nCurrPage = tab;
        --p.baptizeGrayDeal();
        p.RefreshUI();
    else
        
    end
    ]]
    p.nCurrPage = tab;
    p.RefreshUI();
    
    
    --强化面板清空
    p.refreshStrengView(0);
    
    --洗炼面板清空
    p.refreshBaptizeView(0);
    
    --镶嵌面板清空
    p.refreshMosaicView(0);
end


--洗洗装备灰色处理
function p.baptizeGrayDeal()
    local userContainer = p.GetUserContainer();
    
    if(userContainer == nil) then
        LogInfo("userContainer userContainer is nil!");
        return;
    end
    
    local userCount = userContainer:GetViewCount();
    
    for i=1, userCount do
        
        local clientLayer = userContainer:GetView(i-1);
        
        if(clientLayer == nil) then
            LogInfo("p.baptizeGrayDeal clientLayer is nil!");
            return;
        end
        
        local clientCount = clientLayer:GetViewCount();
        LogInfo("i:[%d],clientCount:[%d]",i,clientCount);
        for j=1, clientCount do
            local scrollView = clientLayer:GetView(j-1);
            
            if(scrollView == nil) then
                LogInfo("p.baptizeGrayDeal scrollView is nil!");
                return;
            end
            
            
            
            local equipId = scrollView:GetViewId();
            local nItemType	= Item.GetItemInfoN(equipId, Item.ITEM_TYPE);
            local nEquipType = Num6(nItemType);
            
            --set pic
            local pic = GetItemButton(scrollView, TAG_EQUIP_PIC);
            local btn = GetButton(scrollView, TAG_EQUIP_BUTTON);
            if ( 1 ~= nEquipType and p.nCurrPage == p.TAG.BAPTIZE) then--不是武器就不用洗炼
                pic:EnalbeGray(true);
                btn:EnalbeGray(true);
                
                
            else
                pic:EnalbeGray(false);
                btn:EnalbeGray(false);
            end
            
        end
        
    end
end

-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d], event:%d", tag, uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then                           
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.EquipUI);
        elseif (p.TagStreng == tag) then
            p.ChangeTab(p.TAG.STRENGTHEN);
        elseif (p.TagBaptize == tag) then
            p.ChangeTab(p.TAG.BAPTIZE);
        elseif (p.TagMosaic == tag) then
            p.ChangeTab(p.TAG.MOSAIC);
        end
        
    elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		if tag == p.TagUserList then
            LogInfo("p.OnUIEvent NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN");
            local pageContainer = p.GetPetNameContainer();
        
            local userContainer = p.GetUserContainer();
            
            LogInfo("userContainer:GetBeginIndex():[%d]",userContainer:GetBeginIndex());
            
            pageContainer:ShowViewByIndex(userContainer:GetBeginIndex());
		end 

	end
	return true;
end

--强化等级不能超过主角等级
function p.tipLevel()
    CommonDlgNew.ShowYesDlg(GetTxtPri("QiangHuaMaxPlayerLimit"))
end

--你已经强化最大等级
function p.tipMaxLevel()
    CommonDlgNew.ShowYesDlg(GetTxtPri("QiangHuaMaxLimit"));
end

--银币不足
function p.tipMaxTong()
    CommonDlgNew.ShowYesDlg(GetTxtPub("TongQianBuZhu"));
end

--金币不足
function p.tipMaxJin()
    CommonDlgNew.ShowYesDlg(GetTxtPub("JinBiBuZhu"));
end

--请选择装备
function p.tipNotSelectEquip()
    CommonDlgNew.ShowYesDlg(GetTxtPri("Select_Equip"));
end

--请选择武器
function p.tipNotSelectWeapon()
    CommonDlgNew.ShowYesDlg(GetTxtPri("Select_Weapon"));
end

--宝石过多
function p.tipMaxGemEquip()
    CommonDlgNew.ShowYesDlg(GetTxtPri("QiangLuMax"));
end

--不能嵌入相同宝石
function p.tipNotSameEquip()
    CommonDlgNew.ShowYesDlg(GetTxtPri("QiangLuXiangTong"));
end

--vip限制
function p.tipVipLimitBaptize(nVipRank, sName)
    local tipInfo = string.format(GetTxtPri("XX_VipLimit"),nVipRank,sName);
    CommonDlgNew.ShowYesDlg(tipInfo);
end


--加速提示
function p.tipQuickTip()
    local needgmoney = p.GetCdMoney();
    if(needgmoney) then
        local tipInfo = string.format(GetTxtPri("QiangHuaQuick"),needgmoney);
        p.nTagQuick = CommonDlgNew.ShowYesOrNoDlg(tipInfo, p.quickCallback);
    end
end

--加速提示2
function p.tipQuickTip2()
    local needgmoney = p.GetCdMoney();
    local tipInfo = string.format(GetTxtPri("QiangHuaQuick2"),needgmoney);
    p.nTagQuick = CommonDlgNew.ShowYesOrNoDlg(tipInfo, p.quickCallback);
end


function p.GetCdMoney()
    --判断是否可加速，vip可加速
    local nPlayerId     = GetPlayerId();
    local gmoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
    local WaitTime = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
    local needgmoney    = math.ceil(WaitTime / 60);
            
    if(needgmoney>gmoney) then
        p.tipMaxJin();
        return nil;
    end
    
    return needgmoney;
end


function p.OnUIEventStreng(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d], event:%d", tag, uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if TAG_E_STRENG == tag then     --强化
			
            LogInfo("p.OnUIEventStreng:p.nItemIdTemp:[%d]",p.nItemIdTemp)
            if(p.nItemIdTemp <= 0) then
                p.tipNotSelectEquip();
                return;
            end
            
            local equipId = p.nItemIdTemp;
            
            local WaitTime = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
            if(WaitTime>Wait_Time) then
                p.tipQuickTip2();
                return true;
            end
            
            --判断最大等级不能超过100，判断装备不能超过主角，判断币足够
            local equipLv       = Item.GetItemInfoN(equipId, Item.ITEM_ADDITION);
            
            local nPlayerId     = GetPlayerId();
            local nPetId        = RolePetFunc.GetMainPetId(nPlayerId);
            local mainLv        = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL);
            local money         = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
            local type          = Item.GetItemInfoN(equipId, Item.ITEM_TYPE);
            local moneyLv       = EquipStrFunc.GetReqMoney(type,equipLv+1);
            
            if(equipLv>=mainLv) then
                p.tipLevel();
                return;
            end
            
            if(equipLv>MAX_LEVEL) then
                p.tipMaxLevel();
                return;
            end
            
            if(moneyLv>money) then
                p.tipMaxTong();
                return;
            end
            
            ShowLoadBar();
            MsgEquipStr.SendEquipStrAction(equipId,0);
        elseif (TAG_E_QUICK == tag) then    --加速
            p.tipQuickTip();
            
        end
	end
	return true;
end

--加速
function p.quickCallback(nEventType, param)
    if(CommonDlgNew.BtnOk == nEventType) then
        MsgEquipStr.SendClearStrQueneTimeAction(1);
        ShowLoadBar();
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



function p.OnProcessTimer(nTag)
    local WaitTime = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
    if(p.GetLayer() ~= nil) then 
    
        local layer = p.GetLayerByTag(p.TAG.STRENGTHEN);
        local timeLabel = GetLabel(layer, TAG_E_WAIT_TIME);
        local timerTxt,timer = p.calculateTime(WaitTime);
        timeLabel:SetText(timerTxt);
        local btn = GetButton(layer, TAG_E_QUICK);
        local strengBtn = GetButton(layer, TAG_E_STRENG);
        
        --[[
        if(WaitTime>Wait_Time) then
            strengBtn:SetParam1(1);--cd中
        else
            strengBtn:SetParam1(0);
        end
        ]]
        if(WaitTime <= 1) then
            btn:SetVisible(false);
            timeLabel:SetFontColor(COLOR_GREEN);
        else
            btn:SetVisible(true);
            if(WaitTime > Wait_Time) then
                timeLabel:SetFontColor(COLOR_RED);
            else
                timeLabel:SetFontColor(COLOR_GREEN);
            end
            
        end
    end
    
    if(WaitTime > 0) then
        WaitTime = WaitTime - 1;
        PlayerFunc.SetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1,WaitTime);
    end
    
    
    local bIsEnHanceOpen = GetVipIsOpen(DB_VIP_CONFIG.ENHANCE_CLEARTIME);
    if(bIsEnHanceOpen) then
        UnRegisterTimer(p.TimerHander);
        p.TimerHander = nil;
        p.RefreshEachView();
    end
    
end


function p.calculateTime(timeNum)
    local timeStr = "";
    if(timeNum<0) then
        timeStr = "00:00";
    else
        local time = math.floor(timeNum/60);
        timeStr = timeStr..string.format("%02d",time)..":";
  
        time=timeNum%60;
        timeStr =  timeStr..string.format("%02d",time);
    end
    
    return timeStr;
end


function p.RefreshGemInfo()
    --分页
    p.LoadGemPageView();
    
    --背包中宝石数据
    p.LoadGemBagView();
end


--宝石分页视图
function p.LoadGemPageView()
    local container = p.GetGemPageViewContainer();
    if(container == nil) then
        LogInfo("container is nil!");
    end
    
    local index = container:GetBeginIndex();

    local rectview = container:GetFrameRect();
    container:SetViewSize(rectview.size);

    for i=1, MAX_GEM_NUM do
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
    
    container:ShowViewByIndex(index);
end

function p.LoadGemBagView()
    local container = p.GetGemViewContainer();
    if(container == nil) then
        LogInfo("container is nil!");
    end
    
    local startPage = container:GetBeginIndex();
    container:RemoveAllView();
    
    local rectview = container:GetFrameRect();
    container:SetViewSize(rectview.size);
    
    local pageSize = math.ceil(MAX_GEM_NUM/MAX_GRID_NUM_PER_PAGE);
    for i=1, pageSize  do
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
	
        uiLoad:Load("foster_A_R3_U.ini", view, p.OnUIEventMosaic, 0, 0);
        p.refreshGemListItem(view,i);
    end
    
    if startPage<container:GetViewCount() then
        container:ShowViewByIndex(startPage);
    else
        container:ShowViewByIndex(container:GetViewCount()-1);
    end
end

--装备洗炼
function p.OnUIEventBaptize(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEven1t[%d], event:%d", tag, uiEventType);

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		
        if TAG_B_BTN_B == tag then
			p.OnEventEdu();
        elseif (TAG_B_BTN_KEEP == tag) then
            p.resetEduBtnDisplay();
        elseif (TAG_B_BTN_RRPLACE == tag) then
            p.resetEduBtnDisplay();
            local btn = ConverToButton(uiNode);
            p.replaceEdu(btn:GetParam1());
        end
      
    elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
        local isTrain = p.isTrainCheck(tag);
        if(isTrain) then
            p.setTrainRadio(tag);
        end
	end
	return true;
end

--洗炼
function p.OnEventEdu()
    if(p.nItemIdTemp>0) then
        local nItemType	= Item.GetItemInfoN(p.nItemIdTemp, Item.ITEM_TYPE);
        LogInfo("Itemtypeid:[%d]",nItemType);
        local nEquipType = Num6(nItemType);
        if ( 1 ~= nEquipType) then--不是武器就不用洗炼
            --请选择武器
            p.tipNotSelectWeapon();
            return;
        end
        local nPlayerId     = GetPlayerId();
        local money         = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
        local emoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
        
        local nPlayerVip    = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);
        
        
        local selectRadio   = p.getSelectRadio();
        local nType = GetDataBaseDataN("equip_edu_config",selectRadio,DB_EQUIP_EDU_CONFIG.TYPE);
        local nPrice = GetDataBaseDataN("equip_edu_config",selectRadio,DB_EQUIP_EDU_CONFIG.PRICE);
        
        
        --Vip判断
        local bIsEdu = Is_EQUIP_EDU(selectRadio);    
        if(not bIsEdu) then
            local nNeedVip = GetVipLevel_EQUIP_EDU(selectRadio);
            local sNeedName = GetDataBaseDataS("equip_edu_config",selectRadio,DB_EQUIP_EDU_CONFIG.NAME);
            p.tipVipLimitBaptize(nNeedVip,sNeedName);
            return;
        end
        
        
        --金钱不足判断
        if(nType == PriceType.Sliver) then
            if(money < nPrice) then
                p.tipMaxTong();
                return;
            end
        elseif(nType == PriceType.Coin) then
            if(emoney < nPrice) then
                p.tipMaxJin();
                return;
            end
        end
        
                
        
        MsgEquipStr.SendEdu(p.nItemIdTemp,p.getSelectRadio());
    else
        --请选择武器
        p.tipNotSelectWeapon();
    end
end

--获得洗炼
function p.GetEduPropFull(nItemId)
    local itemTypeId = Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    local attr_value_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_VALUE_1);
    local attr_grow_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_GROW_1);
    
    local equipLv = Item.GetItemInfoN(nItemId, Item.ITEM_ADDITION);
    
    return math.floor((attr_value_1 + equipLv*attr_grow_1)/3);
end

--刷新
function p.RefreshNewAttrData(m)
    local baptizeLayer = p.GetLayerByTag(p.TAG.BAPTIZE);
    local nAttrBegin = Item.ITEM_ATTR_BEGIN;
    
    --附加属性显示
    local btAttrAmount = Item.GetItemInfoN(m.Equip, Item.ITEM_ATTR_NUM);
    for i=1,#TAG_B_NEW_ATTRS do
        local l_attr = GetLabel(baptizeLayer,TAG_B_NEW_ATTRS[i]);
        if(i<=btAttrAmount) then
            local desc = Item.GetItemInfoN(p.nItemIdTemp, nAttrBegin);
            nAttrBegin = nAttrBegin + 1;
            
            local val = Item.GetItemInfoN(p.nItemIdTemp, nAttrBegin);
            nAttrBegin = nAttrBegin + 1;
            
            local txt = ItemFunc.GetAttrTypeValueDesc(desc,m.Attr[i]);
            
            --发变属性已满的状态
            local nFullVal = p.GetEduPropFull(p.nItemIdTemp);
            if(m.Attr[i] >= nFullVal) then
                txt = string.format("%s (%s)",txt,GetTxtPri("XiLianFull"));
            end
            
            --发变颜色
            if(val>m.Attr[i]) then
                l_attr:SetFontColor(BaptizeColor[1]);
            elseif(val<m.Attr[i]) then
                l_attr:SetFontColor(BaptizeColor[3]);
            else
                l_attr:SetFontColor(BaptizeColor[2]);
            end
            
            
            l_attr:SetText(txt);
        else
            l_attr:SetText("");
        end
    end
    p.setEduBtnDisplay(m.Equip);
end

function p.setEduBtnDisplay(nEquip)
    local baptizeLayer = p.GetLayerByTag(p.TAG.BAPTIZE);

    --按钮的显示和隐藏
    local btnEdu = GetButton(baptizeLayer,TAG_B_BTN_B);
    btnEdu:SetVisible(false);
    
    local btnKeep = GetButton(baptizeLayer,TAG_B_BTN_KEEP);
    btnKeep:SetVisible(true);
    
    local btnReplace = GetButton(baptizeLayer,TAG_B_BTN_RRPLACE);
    btnReplace:SetParam1(nEquip);
    btnReplace:SetVisible(true);
end

function p.resetEduBtnDisplay()
    local baptizeLayer = p.GetLayerByTag(p.TAG.BAPTIZE);
    
    --按钮的显示和隐藏
    local btnEdu = GetButton(baptizeLayer,TAG_B_BTN_B);
    btnEdu:SetVisible(true);
    
    local btnKeep = GetButton(baptizeLayer,TAG_B_BTN_KEEP);
    btnKeep:SetVisible(false);
    
    local btnReplace = GetButton(baptizeLayer,TAG_B_BTN_RRPLACE);
    btnReplace:SetVisible(false);
    
    p.clearNewAttr();
end

--清空新属性
function p.clearNewAttr()
    local baptizeLayer = p.GetLayerByTag(p.TAG.BAPTIZE);
    for i=1,#TAG_B_NEW_ATTRS do
        local l_attr = GetLabel(baptizeLayer,TAG_B_NEW_ATTRS[i]);
        l_attr:SetText("");
    end
end

function p.replaceEdu(nEquip)
    LogInfo("p.replaceEdu nEquip:[%d]",nEquip);
    MsgEquipStr.SendConfirmEdu(nEquip);
    p.resetEduBtnDisplay();
end

--镶嵌事件
function p.OnUIEventMosaic(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("镶嵌事件p.OnUIEventMosaic[%d], event:%d", tag, uiEventType);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
    
        if(p.isBackGemList(tag) == false) then
            LogInfo("p.OnUIEventMosaic not mosaic!");
            return;
        end
    
        local btn = ConverToItemButton(uiNode);
        local nGemItemId = btn:GetItemId();
        
        if(nGemItemId == 0) then
            LogInfo("not select gem!");
            return;
        end
        
        --未选择装备提示
        if(not CheckN(p.nItemIdTemp) or p.nItemIdTemp<=0) then
            p.tipNotSelectEquip();
            return;
        end
        
        --宝石类型已存在判断
        if(p.GemIsExists(p.nItemIdTemp,nGemItemId)) then
            p.tipNotSameEquip();
            return;
        end
        
        
        --宝石过多判断        
        local nItemType = Item.GetItemInfoN(p.nItemIdTemp, Item.ITEM_TYPE);
        local socketLimit = GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.SOCKET_LIMIT);
        local gemCount = Item.GetItemInfoN(p.nItemIdTemp, Item.ITEM_GEN_NUM);
        LogInfo("gemCount:[%d],socketLimit:[%d]",gemCount,socketLimit);
        if(gemCount>=socketLimit) then
            p.tipMaxGemEquip()
            return;
        end
        
    
        if(nGemItemId>0) then
            LogInfo("p.nItemIdTemp:[%d],nGemItemId:[%d]",p.nItemIdTemp,nGemItemId);
            MsgCompose.embedGem(p.nItemIdTemp,nGemItemId);
        end

        
    end
end

function p.SetFocusOnPage(nPage)
    local container	= p.GetGemPageViewContainer();
	if not CheckP(container) then
        LogInfo("container is nil!");
		return;
	end
    container:ShowViewByIndex(nPage);
end

--判断装备的宝宝石是否存在
function p.GemIsExists(nItemIdTemp, nGemItemId)
    LogInfo("nItemIdTemp=[%d], nGemItemId=[%d]",nItemIdTemp,nGemItemId);
    local nGemItemType = Item.GetItemInfoN(nGemItemId, Item.ITEM_TYPE);
    local bAttrCount = Item.GetItemInfoN(nItemIdTemp, Item.ITEM_ATTR_NUM);
    local bGenCount = Item.GetItemInfoN(nItemIdTemp, Item.ITEM_GEN_NUM);
    local gem_beg = Item.ITEM_ATTR_BEGIN + bAttrCount*2;
    
    for i=1, bGenCount do
        local nGemTypeId = Item.GetItemInfoN(nItemIdTemp, gem_beg);
        LogInfo("nGemTypeId:[%d], nGemItemType=[%d]",nGemTypeId,nGemItemType);
        
        if Num6(nGemTypeId)*10+Num5(nGemTypeId) == Num6(nGemItemType)*10+Num5(nGemItemType) then
            return true;
        end
        gem_beg = gem_beg + 1;
    end
    return false;
end

--取出宝石事件
function p.OnUIEventUnMosaic(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventUnMosaic[%d], event:%d", tag, uiEventType);
    
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        local btn = ConverToItemButton(uiNode);
        local nGemTypeId = btn:GetItemType();
        
        --判断背包是否已满
        if(ItemFunc.IsBagFullGem(p.idGemListItem,nGemTypeId)) then
            return false;
        end
                
        
    
        if(nGemTypeId==0) then
            LogInfo("p.OnUIEventUnMosaic nGemTypeId == 0");
            return;
        end
    
        if(p.isEquipGemList(tag) == false) then
            LogInfo("p.OnUIEventUnMosaic not unmosaic!");
            return;
        end
    
        if(p.nItemIdTemp<=0) then
            --未选择装备提示
            p.tipNotSelectEquip();
            return;
        end
    
        MsgCompose.unEmbedGem(p.nItemIdTemp,nGemTypeId);
    elseif(uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN) then
        
        if(tag == TAG_M_GEM_LIST) then
            local pageView =  p.GetGemViewContainer();
            local viewIndex = pageView:GetBeginIndex();
            p.SetFocusOnPage(viewIndex);
                
            p.setArrow(p.GetLayerByTag(p.TAG.MOSAIC),p.GetGemViewContainer());
        end
    end
end

--是否背包中宝石
function p.isBackGemList(tag)
    for i,v in ipairs(TAG_M_GEM_BAG) do
        if(v == tag) then
            return true;
        end
    end
    return false;
end

--是否嵌入装备中的宝石
function p.isEquipGemList(tag)
    for i,v in ipairs(TAG_M_GEM_GRID) do
        if(v == tag) then
            return true;
        end
    end
    return false;
end


function p.refreshGemListItem(view, viewId)
   
    local start = (viewId-1)*MAX_GRID_NUM_PER_PAGE+1;
    local count = start+MAX_GRID_NUM_PER_PAGE-1;
    
    local nSize = table.getn(p.idGemListItem);
    if(count>nSize) then
        count = nSize;
    end
    
    for i=start,count do
        local tag = TAG_M_GEM_BAG[i-start+1];
        
        LogInfo("chh_tag:[%d],i:[%d],start:[%d]",tag,i,start);
        
        local btn = GetEquipButton(view,tag);
        btn:ChangeItem(p.idGemListItem[i]);
    end
end


function p.GetLayer()
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    return layer;
end

function p.GetLayerByTag(tag)
    local layer = p.GetLayer();
    local taglayer = GetUiLayer(layer, tag);
    if(taglayer == nil) then
        LogInfo("taglayer:[%d] is nil!",tag);
    end
    return taglayer;
end

function p.GetPetNameContainer()
    local layer = p.GetLayer();
    local container = GetScrollViewContainer(layer, p.TagPetNameList);
    return container;
end

function p.GetUserContainer()
    local layer = p.GetLayer();
    local container = GetScrollViewContainerM(layer, p.TagUserList);
    return container;
end

function p.GetEquipContainer(viewId)
    local userContainer = p.GetUserContainer();
    local view = userContainer:GetViewById(viewId);
    local container = GetScrollViewContainer(view, p.TagEquipList);
    return container;
end

function p.GetGemPageViewContainer()
    local layer = p.GetLayerByTag(p.TAG.MOSAIC);
    local container = GetScrollViewContainer(layer, TAG_M_PAGE_LIST);
    return container;
end

function p.GetGemViewContainer()
    local layer = p.GetLayerByTag(p.TAG.MOSAIC);
    local container = GetScrollViewContainer(layer, TAG_M_GEM_LIST);
    return container;
end

if(p.TimerHander == nil) then
    p.TimerHander = RegisterTimer(p.OnProcessTimer, 1);
end


