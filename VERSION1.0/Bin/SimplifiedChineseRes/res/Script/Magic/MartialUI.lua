

---------------------------------------------------
--描述: 布阵
--时间: 2012.4.27
--作者: chh
---------------------------------------------------
MartialUI = {}
local p = MartialUI;

p.AllUsers              = nil;      --所有武将
p.MartialUsers          = nil;      --已出战武将

p.AllAlertSkill         = nil;      --主将已有技能
p.CurrentSkill          = 0;        --主将当前技能

p.mTotalMatrixCount     = 0;        -- 最大出战人数
p.mAlertMatrixCount     = 0;        -- 已出战人数

p.nMainPetId            = 0;        --主角武将的ID

p.TagMartialDescLayer        = 9172;     --布阵说明层
p.TagDescTagCloseBtn       = 6;        --布阵说明层关闭
p.PanelType = {
    Users = 1,--武将列表
    Staff = 2,--出战武将
};

p.PanelTarget = {
    Source  = 1,    --源
    Dest    = 2,    --目标
};

p.PutData = {
    Source  = {Type = p.PanelType.Users, Index = 0,},
    Dest    = {Type = p.PanelType.Staff, Index = 0,},
};


--Tag

local TagPetInfoLayer   = 8987;
local TagSkillInfoLayer = 8787;


local TagStaffList      = 48;       --所有武将列表控件
local TagStaffBtn       = {1,2};    --人员头像
local TagStaffPics      = {3,4};    --已出战图片
local TagStaffDis       = {5,6};    --禁止点击图片
--local TagStaffDisBtn    = {7,8};    --禁止按钮

local TagClose          = 533;      --关闭
local TagDes            = 649;      --已出战人数描述
local TagSkillList      = 1000;     --技能控件列表
local TagMartialDesc    = 28;       --布阵说明
local TAG_SWAP_EQUIP    = 36;       --快速换装

local SkillDescFormat   = "";
local TagSkillDesc = 26;    --技能描述
local TagSkillName = 27;
local TagListItem = {
	btn     = 400,
    focus   = 200,
    edge    = 20,
}

--分为前军中军后军
local TagSatation = {
    {0,45,0},
    {38,39,40,},
    {35,36,37,},
};

local TagOrderPic = {0,50,0,43,49,52,46,47,51}; --出手顺序

--武将信息Tag
local TagPetInfoPic = 39;
local TagPetInfoName = 43;
local TagPetInfoProfess = 46;
local TagPetInfoLevel = 44;
local TagPetInfoPhysical = 55;
local TagPetInfoQuick = 48;
local TagPetInfoQuarter = 57;
local TagPetInfoLife = 54;
local TagPetInfSpeed = 60;
local TagPetInfSkill = 56;
local TagPetInfoPhysicalRate = 24;
local TagPetInfoQuickRate = 25;
local TagPetInfoQuarterRate = 26;
local TagPetInfoLifeRate = 27;
local TagPetInfDesc = 75;
local TagPetInfBtn = 30;


--排序
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



local Mouse_Size = {w = 40*ScaleFactor, h = 40*ScaleFactor,};

local TAG_MOUSE     = 9999;

local USER_FLAG     = 5748;
local USER_FLAG_DIS = 5749;

--Const
--local StaffListItemSize = CGSizeMake(130.0*ScaleFactor, 65.0*ScaleFactor);
local TAG_STAFFLIST_SIZE_PIC    = 100;

local SKILL_RECT = CGSizeMake((40+TagListItem.edge)*CoordScaleX, 40*CoordScaleY);               -- 技能框大小

function p.LoadUI()
   
--------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    

--------------------添加布阵层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerMartial );
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
    
-----------------初始化ui添加到 layer 层上----------------------------------

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("LayOut.ini", layer, p.OnUIEvent, 0, 0);
    
    
    
--------------------添加武将信息层（窗口）---------------------------------------
    local petInfoLayer = createNDUILayer();
	if petInfoLayer == nil then
		return false;
	end
	petInfoLayer:SetPopupDlgFlag(true);
	petInfoLayer:Init();
	petInfoLayer:SetTag(TagPetInfoLayer);
	petInfoLayer:SetFrameRect(RectFullScreenUILayer);
	layer:AddChildZ(petInfoLayer,1);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		petInfoLayer:Free();
		return false;
	end
	uiLoad:Load("LayOut_PetInfo.ini", petInfoLayer, p.OnUIEventPet, 0, 0);
    petInfoLayer:SetVisible(false);
    
    
--------------------添加技能信息层（窗口）---------------------------------------
    local skillInfoLayer = createNDUILayer();
	if skillInfoLayer == nil then
		return false;
	end
	skillInfoLayer:SetPopupDlgFlag(true);
	skillInfoLayer:Init();
	skillInfoLayer:SetTag(TagSkillInfoLayer);
	skillInfoLayer:SetFrameRect(RectFullScreenUILayer);
	layer:AddChildZ(skillInfoLayer,1);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		petInfoLayer:Free();
		return false;
	end
	uiLoad:Load("LayOut_SkillInfo.ini", skillInfoLayer, p.OnUIEventSkill, 0, 0);
    skillInfoLayer:SetVisible(false);
    
    
--------------------初始化布阵说明层（窗口）---------------------------------------
    local descInfoLayer = createNDUILayer();
	if descInfoLayer == nil then
		return false;
	end
	descInfoLayer:SetPopupDlgFlag(true);
	descInfoLayer:Init();
	descInfoLayer:SetTag(p.TagMartialDescLayer);
	descInfoLayer:SetFrameRect(RectFullScreenUILayer);
	layer:AddChildZ(descInfoLayer,1);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		petInfoLayer:Free();
		return false;
	end
	uiLoad:Load("LayOut_List.ini", descInfoLayer, p.OnUIEventDesc, 0, 0);
    descInfoLayer:SetVisible(false);
    
    
    
    
    
    
    p.initData();
    
    p.refreshUI();
    
   
    
    --鼠标图片初始化
	local imgMouse	= createNDUIImage();
	imgMouse:Init();
	imgMouse:SetTag(TAG_MOUSE);
	layer:AddChildZ(imgMouse, 2);
    
    p.clearData();
    
    MsgMagic.mUIListener = p.processNet;
    MsgItem.mUIListener = p.processNet;
    
    
    --设置关闭音效
   	local closeBtn=GetButton(layer,TagClose);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   	
    return true;
end


--显示武将信息
function p.ShowPetInfo(nPetId)
    LogInfo("nPetId:[%d]",nPetId);
    local layer = p.GetPetInfoLayer();
    
    local nPetType = ConvertN(RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE));
    
    
    local pic = p.getPicture(nPetId);
    local btn = GetButton(layer,TagPetInfoPic);
    btn:SetImage(pic);
    
    local sName = GetDataBaseDataS("pet_config", nPetType, DB_PET_CONFIG.NAME);
    local nProfess = GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.PROFESSION);
    local nStand = GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.STAND_TYPE);
    LogInfo("nStand:[%d]",nStand);
    local sProfess = string.format("%s(%s)",RolePetFunc.GetJobDesc(nProfess),RolePetFunc.GetStandDesc(nStand));
    local sLevel = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL)..GetTxtPub("Level");
	local sPhy = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHYSICAL);   --力量
	local sDex = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DEX);        --敏捷
	local sMagic = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC);    --智力
	local sLife = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE);      --生命
	local sSpeed = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SPEED);    --速度
	local sSkill = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL);    --技能
    
    
    local bIsMainPet = RolePetFunc.IsMainPet(nPetId);
	local sPhyRate = p.GetUpdageRate(nPetType,DB_PET_CONFIG.ADD_PHYSICAL,bIsMainPet);
    local sDexRate = p.GetUpdageRate(nPetType,DB_PET_CONFIG.ADD_SUPER_SKILL,bIsMainPet);
    local sMagicRate = p.GetUpdageRate(nPetType,DB_PET_CONFIG.ADD_MAGIC,bIsMainPet);
    local sLifeRate = p.GetUpdageRate(nPetType,DB_PET_CONFIG.ADD_LIFE,bIsMainPet);
    
    
    --local sDesc = GetDataBaseDataS("pet_config", nPetType, DB_PET_CONFIG.DESCRIBE);
    
    local sDesc = GetDataBaseDataS("skill_config", RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SKILL), DB_SKILL_CONFIG.DESCRRIPTION);
    
    
    local l_name = SetLabel(layer,TagPetInfoName,sName);
    ItemPet.SetLabelColor(l_name, nPetId);
    
    
    SetLabel(layer,TagPetInfoProfess,sProfess);
    SetLabel(layer,TagPetInfoLevel,sLevel);
    SetLabel(layer,TagPetInfoPhysical,sPhy);
    SetLabel(layer,TagPetInfoQuick,sDex);
    SetLabel(layer,TagPetInfoQuarter,sMagic);
    SetLabel(layer,TagPetInfoLife,sLife);
    SetLabel(layer,TagPetInfSpeed,sSpeed);
    SetLabel(layer,TagPetInfSkill,sSkill); 
    
    SetLabel(layer,TagPetInfoPhysicalRate,sPhyRate);
    SetLabel(layer,TagPetInfoQuickRate,sDexRate);
    SetLabel(layer,TagPetInfoQuarterRate,sMagicRate);
    SetLabel(layer,TagPetInfoLifeRate,sLifeRate);
    SetLabel(layer,TagPetInfDesc,sDesc);
    
    
    --btn设置
    local button = GetButton(layer,TagPetInfBtn);
    
    
    local bMatrix = p.isMartialByPetId(nPetId);
    
    if(bMatrix) then
        button:SetTitle(GetTxtPri("XiaZhen"));
    else
        button:SetTitle(GetTxtPri("SanZhen"));
    end
    button:SetParam1(nPetId);
    
    --判断是否主角
    local bIsMainPetId = RolePetFunc.IsMainPet(nPetId);
    button:EnalbeGray(bIsMainPetId);
    
    layer:SetVisible(true);
end

function p.GetUpdageRate( nPetType,nIndex,bIsMainPet )
    local sPhyRate = GetDataBaseDataN("pet_config", nPetType, nIndex);
    
    if(bIsMainPet) then
        if(nIndex == DB_PET_CONFIG.ADD_PHYSICAL) then
            sPhyRate = sPhyRate + HeroStarUI.GetAttrValByType(5);
        elseif(nIndex == DB_PET_CONFIG.ADD_SUPER_SKILL) then
            sPhyRate = sPhyRate + HeroStarUI.GetAttrValByType(6);
        elseif(nIndex == DB_PET_CONFIG.ADD_MAGIC) then
            sPhyRate = sPhyRate + HeroStarUI.GetAttrValByType(7);
        elseif(nIndex == DB_PET_CONFIG.ADD_LIFE) then
            sPhyRate = sPhyRate + HeroStarUI.GetAttrValByType(8);
        end
    end
    
    return (sPhyRate/1000).."";
end


local TagSkillInfoPic   =39;
local TagSkillInfoName   =56;
local TagSkillInfoDesc   =75;
local TagSkillInfoBtn   =30;

--显示技能信息
function p.ShowSkillInfo(nSkillId)
    local layer = p.GetSkillInfoLayer();

    local btnpic		= GetButton(layer, TagSkillInfoPic);
    btnpic:SetImage(GetSkillPotraitPic(nSkillId), true);
    
    local sSkillName = GetDataBaseDataS("skill_config", nSkillId, DB_SKILL_CONFIG.NAME);
    local sSkillDesc = GetDataBaseDataS("skill_config", nSkillId, DB_SKILL_CONFIG.DESCRRIPTION);
    
    SetLabel(layer,TagSkillInfoName,sSkillName);
    SetLabel(layer,TagSkillInfoDesc,sSkillDesc);
    
    local btn		= GetButton(layer, TagSkillInfoBtn);
    btn:SetParam1(nSkillId);
    
    if(nSkillId == p.CurrentSkill) then
        btn:SetVisible(false);
    else
        btn:SetVisible(true);
    end
    
    layer:SetVisible(true);
end


function p.OnUIEventPet(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEventPet[%d], event:%d!", tag, uiEventType);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if TagClose == tag then                           
			local layer = p.GetPetInfoLayer();
            layer:SetVisible(false);
            p.PutData = {};
        elseif(TAG_SWAP_EQUIP == tag) then
            local layer = p.GetPetInfoLayer();
            local btn =GetButton(layer, TagPetInfBtn);
            QuickSwapEquipUI.LoadUI(p.GetCurrLayer(), btn:GetParam1());
            
            --关闭层
            local layer = p.GetPetInfoLayer();
            layer:SetVisible(false);
            p.PutData = {};
        elseif(TagPetInfBtn == tag) then  
            local layer = p.GetPetInfoLayer();
            layer:SetVisible(false);
            
            local btn = ConverToButton(uiNode);
            local nPetId = btn:GetParam1();
            local bMatrix = p.isMartialByPetId(nPetId);
            
            p.PutData = {};
            if(bMatrix) then
                local nIndexStaff = p.GetStaffIndexByPetId(nPetId);
                p.PutData.Source = {Type = p.PanelType.Staff, Index = nIndexStaff,};
                local dObj = {Type = p.PanelType.Users, Index = 1,};
                p.AutoSetData(dObj,true);
            else
                
                --是否有位置
                local nStand = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_STAND_TYPE);
                local nIndexStaff = p.GetStandIdlePosByStand(nStand);
                
                if(nIndexStaff ~= 0) then
                    local nIndexUser = p.GetUserIndexByPetId(nPetId);
                    p.PutData.Source = {Type = p.PanelType.Users, Index = nIndexUser,};
                    local dObj = {Type = p.PanelType.Staff, Index = nIndexStaff,};
                    p.AutoSetData(dObj);
                else
                    p.TipStandFull();
                end
                
            end
            
            --关闭层
            local layer = p.GetPetInfoLayer();
            layer:SetVisible(false);
            p.PutData = {};
                        
        end
    end
    return true;
end

--获得出战的Grid Index 根据PetId
function p.GetStaffIndexByPetId(nPetId)
    for i,v in ipairs(p.MartialUsers) do
        if(v == nPetId) then
            return i;
        end
    end
    return 0;
end

--获得全部武将的Grid Index 根据PetId
function p.GetUserIndexByPetId(nPetId)
    for i,v in ipairs(p.AllUsers) do
        if(v == nPetId) then
            return i;
        end
    end
    return 0;
end


function p.OnUIEventDesc(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEventDesc[%d], event:%d!", tag, uiEventType);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if p.TagDescTagCloseBtn == tag then     
			local layer = p.GetMartialDescLayer();
            layer:SetVisible(false);
        end
    end
    return true;
end

function p.OnUIEventSkill(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEventSkill[%d], event:%d!", tag, uiEventType);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if TagClose == tag then                           
			local layer = p.GetSkillInfoLayer();
            layer:SetVisible(false);
        elseif TagSkillInfoBtn == tag then
            
            local btn = ConverToButton(uiNode);
            local nSkillId = btn:GetParam1();
            p.ChangeSkillBySkillId(nSkillId);
            
            local layer = p.GetSkillInfoLayer();
            layer:SetVisible(false);
        end
    end
    return true;
end

function p.ChangeSkillBySkillId(nSkillId)
    ShowLoadBar();
    LogInfo("skillId:[%d]",nSkillId);
    local id = p.GetIdBySkillId(nSkillId);
    MsgMagic.sendSkillUpdate(id);
end


--获得查看武将信息层
function p.GetPetInfoLayer()
    local layer = p.GetCurrLayer();
    
    if(layer == nil) then
        return nil;
    end
    
    local petInfoLayer = GetUiLayer(layer, TagPetInfoLayer);
    if(nil == petInfoLayer) then
        LogInfo("p.GetPetInfoLayer petInfoLayer is nil!");
        return nil;
    end
    return petInfoLayer;
end

--获得查看技能信息层
function p.GetSkillInfoLayer()
    local layer = p.GetCurrLayer();
    if(layer == nil) then
        return nil;
    end
    local skillInfoLayer = GetUiLayer(layer, TagSkillInfoLayer);
    if(nil == skillInfoLayer) then
        LogInfo("p.GetSkillInfoLayer skillInfoLayer is nil!");
    end
    return skillInfoLayer;
end

--获得空闲的出战位置
function p.GetStandIdlePosByStand(nStand)
    local Stand = TagSatation[nStand];
    for i,v in ipairs(Stand) do
        local nIndex = (nStand-1)*#TagSatation + i;
        local nPetId = p.MartialUsers[nIndex];
        if(v ~= 0) then
            if(nPetId == 0) then
                return nIndex;
            end
        end
    end
    return 0;
end


p.drawCount = 0;

-----------------------------UI层的事件处理---------------------------------
--主
function p.OnUIEvent(uiNode, uiEventType, param)
    LogInfo("chh_beg");
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent[%d], event:%d!", tag, uiEventType);
    
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if TagClose == tag then                           
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.PlayerMartial);
        elseif TagMartialDesc == tag then
            local layer = p.GetMartialDescLayer();
            if( layer ) then
                layer:SetVisible(true);
            end
        else
            --set data
            local nIndexUser = p.isUserListBtn(uiNode);
            local nIndexStaff = p.getStaffIndexByTag(tag);
            LogInfo("nIndexUser:[%d],nIndexStaff:[%d]",nIndexUser,nIndexStaff);
            if(nIndexStaff ~= 0) then
                local obj = {Type = p.PanelType.Staff, Index = nIndexStaff,};
                p.AutoSetData(obj);
            elseif(nIndexUser ~= 0) then
            
                local bIsClick = p.clickAllUsersList(nIndexUser);
                if(not bIsClick) then
                    --return true;
                end
                
                --set data
                local obj = {Type = p.PanelType.Users, Index = nIndexUser,};
                p.AutoSetData(obj);
            end
            
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT then
        LogInfo("Out");
        
        local nIndexUser = p.isUserListBtn(uiNode);
        if(nIndexUser ~= 0) then
            local bIfMove = p.clickAllUsersList(nIndexUser);
            if(not bIfMove) then
                return true;
            end
        end
        
        if(p.drawCount ~= 0) then
            p.SetMouse(param);
            return true;
        end
    
        local nIndexStaff = p.getStaffIndexByTag(tag);
        if(nIndexStaff > 0) then
            local obj = {Type = p.PanelType.Staff, Index = nIndexStaff,};
            p.AutoSetData(obj,true);
        elseif(nIndexUser > 0) then
            local obj = {Type = p.PanelType.Users, Index = nIndexUser,};
            p.AutoSetData(obj,true);
        end
        
        --set mouse
        local nPetId = 0;
        if(p.PutData.Source.Type == p.PanelType.Users) then
            nPetId = p.AllUsers[p.PutData.Source.Index];
        elseif(p.PutData.Source.Type == p.PanelType.Staff) then
            nPetId = p.MartialUsers[p.PutData.Source.Index];
        end
        LogInfo("nPetId:[%d]",nPetId);
        p.SetMouseImgAndPos(p.getBodyPicture(nPetId),param);
        
        p.drawCount = 1;
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT_COMPLETE then
        LogInfo("Complete");
        p.SetMouseImgAndPos(nil, SizeZero());
        p.drawCount = 0;
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_IN then
        LogInfo("In")
        if(p.PutData.Source == nil) then
            return true;
        end
        
        local btn = ConverToButton(uiNode);
        
        local nIndexUser = p.isUserListBtn(uiNode);
        local nIndexStaff = p.getStaffIndexByTag(tag);
        if(nIndexStaff > 0) then
            local obj = {Type = p.PanelType.Staff, Index = nIndexStaff,};
            p.AutoSetData(obj,true);
        elseif(nIndexUser > 0--[[ or btn:GetParam2() == USER_FLAG_DIS]]) then
            local obj = {Type = p.PanelType.Users, Index = nIndexUser,};
            p.AutoSetData(obj,true);
        end
        p.clearData();
    end
    LogInfo("chh_end");
    return true;
end

function p.isUserListBtn(uiNode)
    local btn = ConverToButton(uiNode);
    if(btn == nil) then
        return 0;
    end
    
    if(btn:GetParam2() == USER_FLAG) then
        return btn:GetParam1();
    end
    return 0;
end

--技能事件
function p.OnUIRightEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIRightEvent[%d], event:%d", tag, uiEventType);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
        uiNode = ConverToButton(uiNode);
        local nSkillId = uiNode:GetParam1();
        p.ShowSkillInfo(nSkillId);
        
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DOUBLE_CLICK then
        local nSkillId = uiNode:GetParam1();
        p.ChangeSkillBySkillId(nSkillId);
    end
    return true;
end

--自动设置数据
function p.AutoSetData(obj,isdraw)
    local target;
    if(p.PutData.Source == nil) then
        target = p.PanelTarget.Source;
    elseif(p.PutData.Dest == nil) then
        local sObj = p.PutData.Source;
        local dObj = obj;
        if(sObj.Type == dObj.Type and sObj.Type == p.PanelType.Users) then
            target = p.PanelTarget.Source;
        else
            target = p.PanelTarget.Dest;
        end
    end
    p.SetData(obj,target,isdraw);
end

--设置数据
function p.SetData(obj,target,isdraw)
    if(target == p.PanelTarget.Source) then
        LogInfo("Set p.PanelTarget.Source! Type:[%d],Index:[%d]",obj.Type,obj.Index);
        p.PutData.Source = obj;
    elseif(target == p.PanelTarget.Dest) then
        LogInfo("Set p.PanelTarget.Dest! Type:[%d],Index:[%d]",obj.Type,obj.Index);
        p.PutData.Dest = obj;
    end
    
    p.OnItemListener(isdraw);
end

--清楚数据
function p.clearData()
    p.PutData = {};
    p.CloseStaffLimit();
    p.CloseUsersLimit();
    p.clickAllUsersList(0);
    p.SetMouseImgAndPos(nil, SizeZero());
end

--布阵监听
function p.OnItemListener(isdraw)
    --判断主角不能下阵
    local isMainPet = false;
    if(p.PutData.Source and p.PutData.Dest and p.PutData.Source.Type ~= p.PutData.Dest.Type) then
    
        local nPetIdS,nPetIdD;
        nPetIdS = 0;
        nPetIdD = 0;
        if(p.PutData.Source.Type == p.PanelType.Users) then
            nPetIdS = p.AllUsers[p.PutData.Source.Index];
        elseif(p.PutData.Source.Type == p.PanelType.Staff) then
            nPetIdS = p.MartialUsers[p.PutData.Source.Index];
        end
        
        if(p.PutData.Dest.Type == p.PanelType.Users) then
            nPetIdD = p.AllUsers[p.PutData.Dest.Index];
        elseif(p.PutData.Dest.Type == p.PanelType.Staff) then
            nPetIdD = p.MartialUsers[p.PutData.Dest.Index];
        end
    
        if(nPetIdS == p.nMainPetId or nPetIdD == p.nMainPetId) then
            isMainPet = true;
        end
    end
    if(isMainPet) then
        p.TipNotRetreat();
        p.clearData();
        return;
    end
    
    
    --单击第一次
    if(p.PutData.Source and p.PutData.Dest == nil) then
        LogInfo("单击第一次");
        local sObj = p.PutData.Source;
        if(sObj.Type == p.PanelType.Users) then
            
            if(isdraw) then
                p.OpenStaffLimitByUserIndex(sObj.Index);
            else
                local nPetId = p.AllUsers[sObj.Index];
                p.ShowPetInfo(nPetId);
            end
            
        elseif(sObj.Type == p.PanelType.Staff) then
        
            local nPetId = p.MartialUsers[sObj.Index];
            if(isdraw) then
                if(nPetId ~= 0) then
                    p.OpenStaffLimitByStaffIndex(sObj.Index);
                end
            end
            
            
            if(isdraw) then
                if(nPetId ~= 0) then
                    LogInfo("isdraw=true,nPetId~=0");
                    --p.OpenUsersLimitByStaffIndex(sObj.Index);
                end
            else
                if(nPetId == 0) then
                    LogInfo("isdraw=false,nPetId==0");
                    p.OpenUsersLimitByStaffIndex(sObj.Index);
                else
                    LogInfo("isdraw=false,nPetId~=0");
                    local nPetId = p.MartialUsers[sObj.Index];
                    p.ShowPetInfo(nPetId);
                end
            end
            
            
        end
    end
    
    --单击第二次
    if(p.PutData.Source and p.PutData.Dest) then
        LogInfo("单击第二次");
        local sObj = p.PutData.Source;
        local dObj = p.PutData.Dest;
        
        LogInfo("p.mTotalMatrixCount:[%d],p.mAlertMatrixCount:[%d]",p.mTotalMatrixCount,p.mAlertMatrixCount);
        
        
        if(isdraw) then
            if(sObj.Type == p.PanelType.Staff and dObj.Type == p.PanelType.Users) then--下阵
                --下阵
                p.callHeroOutByIndex(sObj.Index);
                
                
                
                return;
            elseif(sObj.Type == p.PanelType.Staff and dObj.Type == p.PanelType.Staff) then--换位
                
                if(sObj.Index == dObj.Index) then
                    LogInfo("位置没变化！");
                    p.clearData();
                    return;
                end
                
                --判断是否可换位
                local nPetId = p.MartialUsers[sObj.Index];
                LogInfo("nPetId:[%d],dObj.Index:[%d]",nPetId,dObj.Index);
                local isPub = p.isPutByStaffIndex(nPetId, dObj.Index);
                if(isPub == false) then
                    p.clearData();
                    return;
                end
                
                --换位
                p.callHeroOutSwap(sObj.Index,dObj.Index);
                return;
            end
        else
            if(sObj.Type == p.PanelType.Staff and dObj.Type == p.PanelType.Staff) then --查看当前位置可出阵的武将
                LogInfo("查看当前位置可出阵的武将点击多次出阵框");
                p.PutData.Source = p.PutData.Dest;
                p.PutData.Dest = nil;
                p.OnItemListener();
                return;
            end
        end
        
        
        
        
        
        --最大上线判断
        if(p.mTotalMatrixCount == p.mAlertMatrixCount) then
            local isMax = false;
            if(sObj.Type == p.PanelType.Staff) then
                LogInfo("sObj.Index:[%d],p.MartialUsers[sObj.Index]:[%d]",sObj.Index,p.MartialUsers[sObj.Index]);
                if(p.MartialUsers[sObj.Index]==0) then
                    isMax = true;
                end
            end
            if(dObj.Type == p.PanelType.Staff) then
                LogInfo("dObj.Index:[%d],p.MartialUsers[dObj.Index]:[%d]",dObj.Index,p.MartialUsers[dObj.Index]);
                if(p.MartialUsers[dObj.Index]==0) then
                    isMax = true;
                end
            end
            
            
            if(isMax) then
                LogInfo("isMax true!");
                p.TipNotPutMax();
                p.clearData();
                return;
            end
            
        end
        
        if(sObj.Type == p.PanelType.Users and dObj.Type == p.PanelType.Staff) then      --用户列表到出战列表
            LogInfo("用户列表到出战列表");
            
            --判断不可放置武将
            local nPetId = p.AllUsers[sObj.Index];
            LogInfo("nPetId:[%d],dObj.Index:[%d]",nPetId,dObj.Index);
            local isPub = p.isPutByStaffIndex(nPetId, dObj.Index);
            if(isPub == false) then
                p.clearData();
                return;
            end
            
            p.callHeroIn();
        elseif(sObj.Type == p.PanelType.Staff and dObj.Type == p.PanelType.Users) then  --出战列表到用户列表
            LogInfo("出战列表到用户列表");
            
             --判断不可放置武将
            local nPetId = p.AllUsers[dObj.Index];
            LogInfo("nPetId:[%d],sObj.Index:[%d]",nPetId,sObj.Index);
            local isPub = p.isPutByStaffIndex(nPetId, sObj.Index);
            if(isPub == false) then
                p.clearData();
                return;
            end
            
            p.PutData.Source,p.PutData.Dest = p.PutData.Dest,p.PutData.Source;
            p.callHeroIn();
        end
        
        
    end
    

end

--武将下阵
function p.callHeroOutByIndex(nIndex)
    p.MartialUsers[nIndex] = 0;
    ShowLoadBar();
    MsgMagic.sendSetStation(p.MartialUsers);
    --p.clearData();
end

--武将换位
function p.callHeroOutSwap(nIndex1,nIndex2)
    p.MartialUsers[nIndex1],p.MartialUsers[nIndex2] = p.MartialUsers[nIndex2],p.MartialUsers[nIndex1];
    ShowLoadBar();
    MsgMagic.sendSetStation(p.MartialUsers);
    --p.clearData();
end

--武将上阵
function p.callHeroIn()
    local sObj = p.PutData.Source;
    local dObj = p.PutData.Dest;
    
    local nPetId = p.AllUsers[sObj.Index];
    p.MartialUsers[dObj.Index] = nPetId;
    MsgMagic.sendSetStation(p.MartialUsers);
    ShowLoadBar();
    --p.clearData();
end

--武将下阵
function p.callHeroOut(nEventType)
    if(CommonDlgNew.BtnOk == nEventType) then
        local sObj = p.PutData.Source;
        local nPetId = p.AllUsers[sObj.Index];
        p.MartialUsers[sObj.Index] = 0;
        ShowLoadBar();
        MsgMagic.sendSetStation(p.MartialUsers);
    end
    --p.clearData();
end

function p.TipNotPutMax()
    CommonDlgNew.ShowYesDlg(GetTxtPri("MaxUpperBound"));
end

function p.TipNotRetreat()
    CommonDlgNew.ShowYesDlg(GetTxtPri("PlayerNotDownLine"));
end

function p.TipRetreat()
    CommonDlgNew.ShowYesOrNoDlg(GetTxtPri("PlayerIsDownLine"),p.callHeroOut);
end

function p.TipChangeSkill()
    CommonDlgNew.ShowTipDlg(GetTxtPri("PlayerChangeSkill"),1,ccc4(255,255,0,255));
end

function p.TipStandFull()
    CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("StandFull"),RolePetFunc.GetStandDesc(nStand)));
end

--打开出战武将限制根据nIndex
function p.OpenStaffLimitByUserIndex(nIndex)
    local nPetId = p.AllUsers[nIndex];
    local nStand = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_STAND_TYPE);
    p.OpenStaffLimitByStandCol(nStand);
end

--打开出战武将限制根据nIndex
function p.OpenStaffLimitByStaffIndex(nIndex)
    local nPetId = p.MartialUsers[nIndex];
    local nStand = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_STAND_TYPE);
    p.OpenStaffLimitByStandCol(nStand);
end

--打开出战武将限制根据站位
function p.OpenStaffLimitByStandCol(nStandCol)
    
    for i,vi in ipairs(TagSatation) do
        for j,vj in ipairs(vi) do
            
            if(vj ~= 0) then
                local bt = p.GetStaffBtnByTag(vj);
                if(i==nStandCol) then
                    bt:SetImage(nil);
                else
                    bt:SetImage(p.getDisablePic());
                end
            end
        end
    end
end

--关闭出战武将限制
function p.CloseStaffLimit()
    
    for i,vi in ipairs(TagSatation) do
        for j,vj in ipairs(vi) do
            
            if(vj ~= 0) then
                local bt = p.GetStaffBtnByTag(vj);
                bt:SetImage(nil);
            end
        end
    end
    
    --p.refreshMartialUser();
end

--根据武将的出战位置打开“所有武将”限制
function p.OpenUsersLimitByStaffIndex(nIndex)
    LogInfo("p.OpenUsersLimitByStaffIndex nIndex:[%d]",nIndex)
    local nStand = math.ceil(nIndex/#TagSatation);
    p.OpenUsersLimitByStand(nStand);
end

function p.OpenUsersLimitByStand(nStand)
    local rows = math.ceil(#p.AllUsers/2);
    local container = p.GetStaffListContainer();
    for i = 1, rows do 
        local view = container:GetView(i-1);
        
        if(view == nil) then
            LogInfo("p.OpenUsersLimitByStand view is nil!");
        end
        
        local nIndex1 = i*2-1;
        local nIndex2 = i*2;
        
        local btn1 = GetButton(view, TagStaffBtn[1]);
        local btn2 = GetButton(view, TagStaffBtn[2]);
        
        local dispic1 = GetImage(view, TagStaffDis[1]);
        local dispic2 = GetImage(view, TagStaffDis[2]);
        
        --[[
        local disbtn1 = GetButton(view, TagStaffDisBtn[1]);
        local disbtn2 = GetButton(view, TagStaffDisBtn[2]);
        ]]
        
        local nStand1 = RolePet.GetPetInfoN(p.AllUsers[nIndex1], PET_ATTR.PET_ATTR_STAND_TYPE);
        local nStand2 = RolePet.GetPetInfoN(p.AllUsers[nIndex2], PET_ATTR.PET_ATTR_STAND_TYPE);
        
        local isMartial1 = p.isMartialByPetId(p.AllUsers[nIndex1]);
        local isMartial2 = p.isMartialByPetId(p.AllUsers[nIndex2]);
        
        
        local isvis1 = (nStand~=nStand1);
        dispic1:SetVisible(isvis1);
        --disbtn1:SetVisible(isvis1);
        
        if(isMartial1) then
            LogInfo("nIndex1:[%d]",nIndex1);
            dispic1:SetVisible(false);
            --disbtn1:SetVisible(true);
        end
        
        
        if(btn2:GetImage()) then
        
            local isvis2 = (nStand~=nStand2);
            dispic2:SetVisible(isvis2);
            --disbtn2:SetVisible(isvis2);
        
            if(isMartial2) then
                LogInfo("nIndex2:[%d]",nIndex2);
                dispic2:SetVisible(false);
                --disbtn2:SetVisible(true);
            end
        
        end
        
        
        --[[
        btn1:EnalbeGray(nStand~=nStand1);
        
        if(isMartial1) then
            LogInfo("nIndex1:[%d]",nIndex1);
            btn1:EnalbeGray(true);
        end
        
        btn2:EnalbeGray(nStand~=nStand2);
        
        if(isMartial2) then
            LogInfo("nIndex2:[%d]",nIndex2);
            btn2:EnalbeGray(true);
        end
        ]]
        
    end
end


--关闭所有武将限制
function p.CloseUsersLimit()
    local rows = math.ceil(#p.AllUsers/2);
    local container = p.GetStaffListContainer();
    for i = 1, rows do 
        local view = container:GetView(i-1);
        p.refreshUserItem(i*2-1, view);
        p.refreshUserItem(i*2, view);
    end
end

--获得x图片
function p.getDisablePic()
	local pool = DefaultPicPool();
	return pool:AddPicture(GetSMImgPath("bg/bg_front_dis.png"), false);
end


--根据tag获得他对应的出战tag的index
function p.getStaffIndexByTag(nTag)
    local k=0;
    for i,vi in ipairs(TagSatation) do
        for j,vj in ipairs(vi) do
            k = k+1;
            if(vj == nTag) then
                return k;
            end
        end
    end
    return 0;
end

---------------------------初始化布阵窗口--------------------------------------
function p.initData()
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    local nPlayerPetId = RolePetFunc.GetMainPetId(nPlayerId)
	
    p.AllUsers = {};
    
	--获得全部人员列表
	local allUsers = RolePetUser.GetPetListPlayer(nPlayerId);
	for i,v in ipairs(allUsers) do
        if(v ~= nPlayerPetId) then
            table.insert(p.AllUsers,v);
        end
    end
    
    p.AllUsers = RolePet.OrderPets(p.AllUsers);
    
    
    --获得出战人员列表
	local lst, count    = MsgMagic.getRoleMatrixList();
	p.MartialUsers      = lst[1];
    p.mAlertMatrixCount = p.GetAlertMatrixCount(p.MartialUsers);
    
    --主将已有的全部技能
    p.AllAlertSkill          = MsgMagic.getRoleMainSkillList();
    
    local nPlayerId     = GetPlayerId();
	p.nMainPetId        = RolePetFunc.GetMainPetId(nPlayerId);
    p.CurrentSkill      = RolePet.GetPetInfoN(p.nMainPetId,PET_ATTR.PET_ATTR_SKILL);
    LogInfo("p.CurrentSkill:[%d]",p.CurrentSkill);
    
    --最大出战人数
    local lvRank = PlayerFunc.GetUserAttr(nPlayerId,USER_ATTR.USER_ATTR_RANK);
    p.mTotalMatrixCount = GetDataBaseDataN("rank_config",lvRank,DB_RANK.MAX_FIGHT_PET);
end

function p.GetAlertMatrixCount(MartialUsers)
    local count = 0;
    for i,v in ipairs(MartialUsers) do
        if(v ~= 0) then
            count = count + 1;
        end
    end
    return count;
end

--刷新UI
function p.refreshUI()
    p.refreshAllUser();
    p.refreshMartialUser();
    p.refreshAllSkill();
    p.refreshCurrSkill();
end

--刷新全部用户
function p.refreshAllUser()
    local container = p.GetStaffListContainer();
    container:RemoveAllView();
    container:SetViewSize(StaffListItemSize);
    container:EnableScrollBar(true);
    
    local rows = math.ceil(#p.AllUsers/2);
    
    for i = 1, rows do 
        local view = createUIScrollView();
        if view == nil then
            LogInfo("p.refreshAllUser view is nil!");
            return;
        end
        
        view:Init(false);
        view:SetScrollStyle(UIScrollStyle.Verical);
        view:SetViewId(i);
        view:SetTag(i);
        view:SetMovableViewer(container);
        view:SetScrollViewer(container);
        view:SetContainer(container);
        
        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            layer:Free();
            return false;
        end
        uiLoad:Load("LayOut_L.ini", view, p.OnUIEvent, 0, 0);
        
        --设置大小
        
        p.refreshUserItem(i*2-1, view);
        p.refreshUserItem(i*2, view);
        uiLoad:Free();
        
        container:AddView(view);
    end
end

--------------------------刷新武将列表项-------------------------------
function p.refreshUserItem(index,view)
    LogInfo("p.refreshUserItem index:[%d]",index);
    local container = p.GetStaffListContainer();
    
    local itemPos = index % 2;
    if(itemPos == 0) then
        itemPos = 2;
    end
    
    local btn = GetButton(view, TagStaffBtn[itemPos]);
    local pic = GetImage(view, TagStaffPics[itemPos]);
    local dispic = GetImage(view, TagStaffDis[itemPos]);
    --local disbtn = GetButton(view, TagStaffDisBtn[itemPos]);
    
    local PicRect = GetImage(view, TAG_STAFFLIST_SIZE_PIC);
    container:SetViewSize(PicRect:GetFrameRect().size);
    
    if(btn == nil) then
        return;
    end
    
    --btn set
    btn:SetParam1(index);
    btn:SetParam2(USER_FLAG);
    
    --disbtn
    --disbtn:SetParam2(USER_FLAG_DIS);
    
    if(index > #p.AllUsers) then
        btn:SetVisible(false);
        pic:SetVisible(false);
    else
        local pic = p.getPicture(p.AllUsers[index]);
        btn:SetImage(pic);
        LogInfo("p.AllUsers[index]:[%d]",p.AllUsers[index]);
    end
    
    --pic set
    local isMartial = p.isMartialByPetId(p.AllUsers[index]);
    pic:SetVisible(isMartial);
    
    
    dispic:SetVisible(isMartial);
    if(isMartial) then
        dispic:SetVisible(false);
    end
    
    --disbtn:SetVisible(isMartial);
    --btn:EnalbeGray(isMartial);
end


--刷新已出战用户
function p.refreshMartialUser()

    local OrderPetIds = p.GetOrderByPetId();
    
    LogInfo("OrderPetIds Begin");

    for i,v in ipairs(p.MartialUsers) do
        local pic = p.getBodyPicture(v);
        local btn = p.GetStaffBtnByIndex(i);
        if(btn) then
            btn:SetBackgroundPicture(pic,nil);
            
            local nTagOrderPic = TagOrderPic[i];
            local pOrderPic = GetImage(p.GetCurrLayer(),nTagOrderPic);
            if(nTagOrderPic>0 and v>0) then
                
                local norpic = DefaultPicPool():AddPicture(GetSMImgPath(NUMBER_FILE), false);
                norpic:Cut(Numbers_Rect[OrderPetIds[v]+1]);
                
                pOrderPic:SetPicture(norpic);
            else
                pOrderPic:SetPicture(nil);
            end
            
        end
         
    end
    
    --刷新出战人数
    local layer = p.GetCurrLayer();
    local desV = GetLabel(layer, TagDes);
    local sDes = p.mAlertMatrixCount.."/";
    sDes = sDes..p.mTotalMatrixCount;
    desV:SetText(sDes);
end

--刷新所有技能
function p.refreshAllSkill()
    
    -- 技能列表
    local container = p.GetSkillListContainer();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
    
    container:RemoveAllView();
    local rectview = container:GetFrameRect();
    container:SetViewSize(SKILL_RECT);
    
    for i, v in ipairs(p.AllAlertSkill) do
        local view = createUIScrollView();
		if view == nil then
			LogInfo("p.LoadUI createUIScrollView failed");
			return;
		end
		view:Init(false);
		view:SetViewId(v.skill);
        view:SetTag(v.skill);
		container:AddView(view);
        
        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            uiLoad:Free();
            return false;
        end
	
        uiLoad:Load("LayOut_R.ini", view, p.OnUIRightEvent, 0, 0);
        p.refreshSkillItem(v.skill,view);
        uiLoad:Free();
	end
    
end

function p.refreshSkillItem(skillId, view)  
    local bgV		= GetButton(view, TagListItem.btn);
    bgV:SetParam1(skillId);
    bgV:SetImage(GetSkillPotraitPic(skillId), true);
end


--刷新当前技能为选中
function p.refreshCurrSkill()
    p.setSkillChecked(p.CurrentSkill);
end



-----------------------------选中技能根据技能ID--------------------------------
function p.setSkillChecked(skill)
    LogInfo("p.setSkillChecked p.AllAlertSkill:[%d]",#p.AllAlertSkill);
    if not CheckN(skill) then
		return false;
	end
    
    local cur = p.clickAllSkillList(skill);
    
    local container = p.GetSkillListContainer();
    
    local cols = 3;
    local maxCols = 5;
    local tot = #p.AllAlertSkill;
    if(tot>cols) then
        local diff = tot-cur;
        
        if(diff>=cols) then
            LogInfo("chh_tot:[%d],cur:[%d],diff:[%d],index1:[%d]",tot,cur,diff,cur-1);
            container:ShowViewByIndex(cur-1-2);
        else
            LogInfo("chh_tot:[%d],cur:[%d],diff:[%d],index2:[%d]",tot,cur,diff,tot-cols);
            container:ShowViewByIndex(tot-maxCols);
        end
    end
    
    local sSkillName    = GetDataBaseDataS("skill_config", skill, DB_SKILL_CONFIG.NAME);
    SetLabel(p.GetCurrLayer(),TagSkillName,sSkillName);
end



---------------------------释放阵法数据--------------------------------------
function p.freeData()
    p.AllUsers      = nil;
    p.MartialUsers  = nil;
    p.AllAlertSkill = nil;
    MsgMagic.mUIListener = nil;
    MsgItem.mUIListener  = nil;
end


function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_MATRIX_STATION then
		p.initData();
        p.refreshAllUser();
        p.refreshMartialUser();
    elseif msgId == NMSG_Type._MSG_USER_CURRENT_SKILL then
        CloseLoadBar();
        
        local nSkillId = p.GetSkillById(m);
        
        
        p.CurrentSkill      = nSkillId;
        
        
        LogInfo("nSkillId:[%d],m:[%d]",nSkillId,m);
        p.clickAllSkillList(nSkillId);
        p.setSkillChecked(nSkillId);
        p.TipChangeSkill();
    elseif(msgId == NMSG_Type._MSG_ITEM_ACTION) then
        if(m == 11) then
            CommonDlgNew.ShowTipDlg(GetTxtPri("MSG_ITEM_T01"));
            QuickSwapEquipUI.CloseUI();
        end
	end
    p.clearData();
	CloseLoadBar();
end



----------------------------select--------------------------------

function p.clickAllUsersList(nIndex)
    LogInfo("nIndex:[%d]",nIndex);
    local container = p.GetStaffListContainer();
    local rows = math.ceil(#p.AllUsers/2);
    for i = 1, rows do 
        LogInfo("i:[%d]",i);
        local view = container:GetView(i-1);
        local btn1 = GetButton(view, TagStaffBtn[1]);
        local btn2 = GetButton(view, TagStaffBtn[2]);
        btn1:SetFocus(false);
        btn2:SetFocus(false);
    end
    
    local view = container:GetView(math.ceil(nIndex/2)-1);
    if(view == nil) then
        LogInfo("p.clickAllUsersList view is nil!");
        return;
    end
    local nItemPos = nIndex%2;
    if(nItemPos == 0) then
        nItemPos = 2;
    end
    local btn = GetButton(view, TagStaffBtn[nItemPos]);
    if(btn == nil) then
        LogInfo("p.clickAllUsersList btn is nil!");
        return;
    end
    
    
    LogInfo("ViewIndex:[%d],TagStaffBtn:[%d]",math.ceil(nIndex/2)-1,TagStaffBtn[nItemPos]);
    
    local martralPic = GetImage(view, TagStaffPics[nItemPos]);
    local dispic = GetImage(view, TagStaffDis[nItemPos]);
    
    --[[
    if(martralPic:IsVisibled() and p.PutData.Source == nil) then
    
    end
    ]]
    
    if(martralPic:IsVisibled() or dispic:IsVisibled()) then
        LogInfo("p.clickAllUsersList false");
        return false;
    end
    LogInfo("p.clickAllUsersList true");
    btn:SetFocus(true);
    return true;
end

function p.clickAllSkillList(nSkill)
    LogInfo("nSkill:[%d]",nSkill);
    local cur = 0;
    local container = p.GetSkillListContainer();
    local rows = #p.AllAlertSkill;
    for i = 1, rows do
        LogInfo("i:[%d],p.AllAlertSkill[i].skill:[%d]",i,p.AllAlertSkill[i].skill);
        local view = container:GetView(i-1);
        local focus = GetButton(view, TagListItem.btn);
        
        if(nSkill == p.AllAlertSkill[i].skill) then
            focus:TabSel(true);
            focus:SetFocus(true);
            cur = i;
        else
            focus:TabSel(false);
            focus:SetFocus(false);
        end
    end
    return cur;
end


----------------------------tools--------------------------------
function p.getPicture(nId)
	if not CheckN(nId) then
		return nil;
	end
	
	local nPetType = RolePet.GetPetInfoN(nId,PET_ATTR.PET_ATTR_TYPE);
    --**chh 2012-06-08
    if(nPetType == 0) then
        LogInfo("p.getPicture nPetType is nil!");
        return nil;
    end
    local rtn = GetPetPotraitPic(nPetType);
	return rtn;
end


function p.getBodyPicture(nId)
    if not CheckN(nId) then
		return nil;
	end
	
	local nPetType = RolePet.GetPetInfoN(nId,PET_ATTR.PET_ATTR_TYPE);
    --**chh 2012-06-08
    if(nPetType == 0) then
        LogInfo("p.getPicture nPetType is nil!");
        return nil;
    end
    local rtn = GetPetBodyPic(nPetType);
	return rtn;
end

--获得petid判断武将是否出战
function p.isMartialByPetId(nPetId)
    for i,v in ipairs(p.MartialUsers) do
        if(v == nPetId) then
            return true;
        end
    end
    return false;
end


--根据ID取技能
function p.GetSkillById(id)
    for i, v in ipairs(p.AllAlertSkill) do
        if(v.id == id) then
            return v.skill;
        end
    end
    return 0;
end

--根据技能取ID
function p.GetIdBySkillId(skillId)
    for i, v in ipairs(p.AllAlertSkill) do
        if(v.skill==skillId) then
            return v.id;
        end
    end
    return 0;
end

--获得出战武将的pos根据Index
function p.GetPosByIndex(nIndex)
    local row,col;
    row = 0; col = 0;

    local rows = #TagSatation;
    if(rows~=0) then
        row = math.ceil(nIndex/rows);
        if(row==0) then
            row = rows;
        end
    end
    
    local cols = #TagSatation[1];
    if(cols ~= 0) then
        col = nIndex%cols;
        if(col==0) then
            col = cols;
        end
    end
    
    return row,col;
end


--获得出手顺序
function p.GetOrderByPetId()
    
    local MartialPetIds = {};
    for i,v in ipairs(p.MartialUsers) do
        if(v ~= 0) then
            table.insert(MartialPetIds,v);
        end
    end
        
    MartialPetIds = RolePet.OrderSpeedPets(MartialPetIds);
    
    local OrderPetIds = {};
    for i,v in ipairs(MartialPetIds) do
        OrderPetIds[v] = i;
        LogInfo("chh_i:[%d],speed:[%d],v:[%d]",i,v,RolePet.GetPetInfoN(v, PET_ATTR.PET_ATTR_SPEED));
    end
    
    return OrderPetIds;
end


--判断是否可放置武将
function p.isPutByStaffIndex(nPetId, nIndex)
    local nStand = math.ceil(nIndex / #TagSatation);
    if(nStand==0) then
        nStand = #TagSatation;
    end
    return p.isPutByStand(nPetId,nStand);
end

function p.isPutByStand(nPetId, nStand)
    local stand_type = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_STAND_TYPE);
    LogInfo("stand_type:[%d],nStand:[%d]",stand_type,nStand);
    if(stand_type == nStand) then
        return true;
    end
    return false;
end

function p.SetMouseImgAndPos(pic, moveTouch)
    local layer = p.GetCurrLayer();
    local imgMouse = RecursiveImage(layer, {TAG_MOUSE});
    imgMouse:SetPicture(pic, true);
    
    if(pic) then
        p.SetMouse(moveTouch);
    end
end

function p.SetMouse(moveTouch)
	LogInfo("SetMouse");
	if not CheckStruct(moveTouch) then
		LogInfo("SetMouse invalid arg");
		return;
	end
	
	local layer = p.GetCurrLayer();
	
	local imgMouse = RecursiveImage(layer, {TAG_MOUSE});
	if not CheckP(imgMouse) then
		LogInfo("not CheckP(imgMouse)");
		return;
	end
	

    local nMoveX	= moveTouch.x - Mouse_Size.w / 2;
    local nMoveY	= moveTouch.y - Mouse_Size.h / 2;
    imgMouse:SetFrameRect(CGRectMake(nMoveX, nMoveY, Mouse_Size.w, Mouse_Size.h));
end

----------------------------获得控件方法--------------------------------
--获得出战btn根据index
function p.GetStaffBtnByIndex(nIndex)
    local row,col = p.GetPosByIndex(nIndex);
	return p.GetStaffBtnByTag(TagSatation[row][col]);
end

--获得出战btn根据nTag
function p.GetStaffBtnByTag(nTag)
    LogInfo("nTag:[%d]",nTag);
    local layer = p.GetCurrLayer();
	local btn = GetButton(layer, nTag);
    
    if(btn == nil) then
        LogInfo("p.GetStaffBtn btn is nil!");
    end
	return btn;
end

--获得技能控件列表
function p.GetSkillListContainer()
	local layer = p.GetCurrLayer();
	local container = GetScrollViewContainer(layer, TagSkillList);
	return container;
end

--获得所有武将列表控件
function p.GetStaffListContainer()
    local layer = p.GetCurrLayer();
	local container = GetScrollViewContainer(layer, TagStaffList);
    
    if(container == nil) then
        LogInfo("p.GetStaffListContainer container is nil!");
    end
    
	return container;
end

--获得当前UI窗口层
function p.GetCurrLayer()
    local scene = GetSMGameScene();
	if nil == scene then
        LogInfo("p.GetCurrLayer scene is nil!");
		return nil;
	end
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
	if nil == layer then
        LogInfo("p.GetCurrLayer layer is nil!");
		return nil;
	end
    return layer;
end

--获得布阵说明层
function p.GetMartialDescLayer()
    
    local layer = p.GetCurrLayer();
    if( layer == nil ) then
        return nil;
    end
    
    local desc_layer = GetUiLayer(layer, p.TagMartialDescLayer);
    if( desc_layer == nil ) then
        return nil;
    end
    
    return desc_layer;
end

