
PetUI = {}
local p = PetUI;

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

p.MountInfo         = {};

local TAG_MOUSE = 9999;

p.TagIllusion   = 501;
p.TagRide       = 502;
p.TagTrain      = 503;
p.TagClose      = 533;
p.TAG_EXP       = 42;
p.TAG_ITEMSIZE       = 4;

p.TagIllsionLayer       = 1000;
p.TagIllsionClose       = 533;
p.TagIllusionData       = 501;
p.TagIllusionList       = 44;
p.TagIllsionItemBtn     = 457;
p.TagIllsionItemPic     = 11;
p.TagIllsionItemDis     = 12;

local TAG_BEGIN_ARROW   = 1411;
local TAG_END_ARROW     = 1412;

local TAG_E_TMONEY      = 243;  --
local TAG_E_TEMONEY     = 242;  --
local TAG_E_TSMB        = 106;  --神马鞭数量

local TAG_E_ZY1         = 107;  --幻化指引1
local TAG_E_ZY2         = 116;  --幻化指引2

local TAG_C_SPEED_LBL   = 24;
local TAG_N_SPEED_LBL   = 25;

local TAG_MOUNT_DESC    = 5;    --坐骑说明

local MountListCount     = 2;

p.TagMountLevel = {
	NAME = 601,
	TURN = 602,
	STAR = 603,
};

p.RideStateEnum = { rest = 0, ride = 1,}
p.RideState = {[p.RideStateEnum.rest] = GetTxtPri("RideMount"), [p.RideStateEnum.ride] = GetTxtPri("RestMount"),};

p.TagRadioGroud = {
    TONG    = 401,
    JIN10   = 402,
    JIN50   = 403,
};

local TAG_RADIO_TXTS = {36,37,38};

p.TagMountPic	= 100;

local IllsionSize = CGSizeMake((120+10)*ScaleFactor, 140*ScaleFactor);

p.MountModelIds = {}        --坐骑模型ID

p.TagCurrProp	= {
	FORCE 	= 201,
	QUICK	= 202,
	WIT		= 203,
	LIFE	= 204,
	SPEED	= 205,
	NFORCE 	= 301,
	NQUICK	= 302,
	NWIT	= 303,
	NLIFE	= 304,
	NSPEED	= 305,
};

p.MaxStarLevel = 0;

--金钱不足
function p.MoneyNotEnough(nMoney)
    local nPlayerId     = GetPlayerId();
    local money         = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
    
    if(money<nMoney) then
        CommonDlgNew.ShowYesDlg(GetTxtPub("TongQianBuZhu"));
        return false;
    end
    return true;
end

--金币不足
function p.EoneyNotEnough(em)
    local nPlayerId     = GetPlayerId();
    local emoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
    if(emoney<em) then
        CommonDlgNew.ShowYesDlg(GetTxtPub("JinBiBuZhu"));
        return false;
    end
    return true;
end

--爆击
function p.TipKnocking(data)
    --[[
    local nExp = p.MountInfo.exp - p.MountInfo.pre_exp;
    ]]
    
    
    if(data.nTrainType == 1 or data.nTrainType == 2) then
        local nStr = "";
        if(data.nSmallCrit > 0) then
            nStr = string.format(GetTxtPri("DanChiBaoJiX10Exp"),data.nTrainExp);
        else
            nStr = string.format("%s +%d",GetTxtPub("exp"),data.nTrainExp);
        end
        CommonDlgNew.ShowTipDlg(nStr);
        
    elseif(data.nTrainType == 3) then
    
        local sTotal = string.format(GetTxtPri("MaxBaoJiX1Level2"),data.nTrainExp);
        CommonDlgNew.ShowTipDlg(sTotal);
        
        
        local nStr = "";
        if(data.nSmallCrit > 0) then
            nStr = string.format(GetTxtPri("BaoJiX10Exp"),data.nSmallCrit);
        end
        
        if(data.nBigCrit > 0) then
            local sXun = "";
            if(data.nSmallCrit > 0) then
                sXun = ",";
            end
            local sBigCrit = string.format(GetTxtPri("MaxBaoJiX1Level"),data.nBigCrit);
            nStr = string.format("%s%s%s",nStr,sXun,sBigCrit);
        end
        
        CommonDlgNew.ShowTipDlg(nStr);
        
    end
    
    --[[
    if(data.nCritType == 1 )then
        nStr = string.format("%s %s",GetTxtPri("BaoJiX10Exp"),nStr);
    elseif data.nCritType == 2 then
        nStr = string.format("%s",GetTxtPri("MaxBaoJiX1Level"));
    end
    ]]
end

--bIsSMB:是否是从背包中的使用神马鞭连接过来的，如果是那么默认选中金币培养选项
function p.LoadUI(bIsSMB)
    local scene = GetSMGameScene();
	if scene == nil then
		return;
	end
    
    --初始化幻化信息层
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PetUI);
	layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChildZ(layer,UILayerZOrder.NormalLayer);


    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("Mount.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();
    
    --初始化幻化UI层
    local layerIllsion = createNDUILayer();
	if layerIllsion == nil then
		return false;
	end
	layerIllsion:SetPopupDlgFlag( true );
	layerIllsion:Init();
	layerIllsion:SetTag(p.TagIllsionLayer);
	layerIllsion:SetFrameRect(RectFullScreenUILayer);
    layerIllsion:SetVisible(false);
	layer:AddChildZ(layerIllsion,1);
    
    local uiLoad2 = createNDUILoad();
	if nil == uiLoad2 then
		layerIllsion:Free();
		return false;
	end
    uiLoad2:Load("Mount_Illusion.ini", layerIllsion, p.OnUIIllsionEvent, CONTAINTER_X, CONTAINTER_Y);
    uiLoad2:Free();
    
    if(bIsSMB) then
        p.setTrainRadio(p.TagRadioGroud.JIN10);
    else
        p.setTrainRadio(p.TagRadioGroud.TONG);
    end
    
    p.initData();
    
    p.refreshUI();
    
    SetArrow(p.GetIllusionLayer(),p.GetListContainer(),MountListCount,TAG_BEGIN_ARROW,TAG_END_ARROW);
    
    --坐骑文字说明
    p.CreateMountDesc();
    
    --设置培养文字
    for i,v in ipairs(TAG_RADIO_TXTS) do
        local l_txt = GetLabel(layer, v);
        local sTxt = GetDataBaseDataS("mount_train_config",i,DB_MOUNT_TRAIN_CONFIG.DESCRIPT);
        l_txt:SetText(sTxt);
    end

    local TAG_C_SPEED_TXT   = 24;
    local TAG_N_SPEED_TXT   = 25;
    
    local c_s_lbl = GetLabel( layer, TAG_C_SPEED_LBL );
    local n_s_lbl = GetLabel( layer, TAG_N_SPEED_LBL );
    
    local c_s_txt = GetLabel( layer, p.TagCurrProp.SPEED );
    local n_s_txt = GetLabel( layer, p.TagCurrProp.NSPEED );
    
    c_s_lbl:SetVisible( false );
    n_s_lbl:SetVisible( false );
    c_s_txt:SetVisible( false );
    n_s_txt:SetVisible( false );
    
    return true;
end

--坐骑说明
function p.CreateMountDesc()
    local layer = p.getMainLayer();
    
    --坐骑说明
    local l_desc = GetLabel(layer, TAG_MOUNT_DESC);
    l_desc:SetVisible(false);
    
    
    local pLabelTips = _G.CreateColorLabel( GetTxtPri("PETUI_T3"), l_desc:GetFontSize()/2, l_desc:GetFrameRect().size.w );
   
     if CheckP(pLabelTips) then
		pLabelTips:SetFrameRect(l_desc:GetFrameRect());
		layer:AddChild(pLabelTips);
	end
end

--幻化信息层事件
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d], event:%d", tag, uiEventType);

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.PetUI);
        elseif (p.TagIllusion == tag) then
            p.clickIllusion();
        elseif (p.TagRide == tag) then
            p.clickRide();
        elseif (p.TagTrain == tag) then
            p.clickTrain();
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DOUBLE then
        if (p.TagTrain == tag) then
            p.clickTrain();
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
        
        LogInfo("xp:tag:[%d]",tag);
        --培养
        local isTrain = p.isTrainCheck(tag);
        
        if(isTrain) then
            p.setTrainRadio(tag);
        end
        
	end
	return true;
end


--幻化UI层事件
function p.OnUIIllsionEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagIllsionClose == tag then
            local layerIllsion = p.GetIllusionLayer()
            layerIllsion:SetVisible(false);
            p.CloseTutorial();
        end
	elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
        if p.TagIllusionList == tag then 
            SetArrow(p.GetIllusionLayer(),p.GetListContainer(),MountListCount,TAG_BEGIN_ARROW,TAG_END_ARROW);
        end
	end
    
	return true;
end


function p.OnUIIllsionItemEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIIllsionItemEvent tag:[%d]",tag);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == p.TagIllsionItemBtn) then
            local btn = ConverToButton(uiNode);
            p.illusionData(btn:GetParam1());
            p.CloseTutorial();
        end
	end
    return true;
end

--关闭窗口的清理事件
function p.freeData()
	p.MountInfo = nil;
    MsgMount.mUIListener = nil;
end


--幻化事件
function p.clickIllusion()
	local layer = p.getMainLayer();
	if nil == layer then
		return nil;
	end
    
    local layerIllsion = GetUiLayer(layer, p.TagIllsionLayer);
	if nil == layerIllsion then
		return nil;
	end
    
    layerIllsion:SetVisible(true);
end


function p.RideStateTurn()
    local status = p.MountInfo.ride;
    if(status == 0) then
        status = 1;
    elseif(status == 1) then
        status = 0;
    end
    return status;
end


--骑乘事件
function p.clickRide()
    LogInfo("p.clickRide()");
    
	local layer = p.getMainLayer();
    local btRide = GetButton(layer, p.TagRide);
    
    --tx
    MsgMount.sendRideUpgrade(p.RideStateTurn());
end

--培养事件
function p.clickTrain()
    LogInfo("p.clickTrain select id:[%d]",p.getSelectRadio());
    
    --金钱的判断
    local selectid = p.getSelectRadio();
        
    local nType = GetDataBaseDataN("mount_train_config",selectid,DB_MOUNT_TRAIN_CONFIG.TYPE);
    local nMoney = GetDataBaseDataN("mount_train_config",selectid,DB_MOUNT_TRAIN_CONFIG.PIRICE);
    
    if(nType == DB_MOUNT_TRAIN_TYPE_DESC.MONEY) then
        if(p.MoneyNotEnough(nMoney) == false) then
            return;
        end
    elseif(nType == DB_MOUNT_TRAIN_TYPE_DESC.EMONEY) then
        if(p.EoneyNotEnough(nMoney-p.GetSMBCount()*10) == false) then
           return;
        end
    end
    
    --[[
    if(selectid==1)then
        if(p.MoneyNotEnough() == false) then
            return;
        end
    elseif(selectid==2)then
        
        if(p.EoneyNotEnough(10-p.GetSMBCount()*10) == false) then
           return;
        end
    elseif(selectid==3)then
        if(p.EoneyNotEnough(500-p.GetSMBCount()*10) == false) then
           return;
        end
    end
    ]]

    --tx
    MsgMount.sendTrain(p.getSelectRadio());
end

--获得神马鞭数量
function p.GetSMBCount()
    local nCount = 0;
    local nPlayerId		= ConvertN(GetPlayerId());
	local idlistItem	= ItemUser.GetBagItemList(nPlayerId);
    for i,v in ipairs(idlistItem) do
        local nItemType = Item.GetItemInfoN(v, Item.ITEM_TYPE);
        if(nItemType == 36000000) then
            nCount = nCount + Item.GetItemInfoN(v, Item.ITEM_AMOUNT);
        end
    end
    return nCount;
end


--处理幻化事件
function p.illusionData(mountModelId)
    LogInfo("p.illusionData():mountModelId:[%d]",mountModelId);
    MsgMount.sendIllsion(mountModelId);
end

function p.initData()
	p.initConst();
    
    
    
    
    --[[
	p.MountInfo = {
		illusionId	= 2,
		star	= 19,
        exp     = 300,
        ride    = 0,
	};
    ]]
    
    --tx
    p.MountInfo = MsgMount.getMountInfo();
    
    p.MountModelIds = GetDataBaseIdList("mount_model_config");
    
    p.MaxStarLevel  = #GetDataBaseIdList("mount_config");
    
    
    MsgMount.mUIListener = p.processNet;
end

function p.initConst()
	
end

function p.refreshUI()
    p.refreshInfo();
    p.refreshIllsion();
    p.refreshRideButton(p.MountInfo.ride);
    
    p.refreshSMB();
    p.refreshMoney();
end

function p.refreshInfo()
	local layer = p.getMainLayer();
	if nil == layer then
		return nil;
	end
    
    local tempstr1,tempstr2,tempstr3,tempstr4,tempstr5,tempstr6,tempstr7,tempstr8,tempstr9,tempstr10;
    tempstr1 = "-";tempstr2 = "-";tempstr3 = "-";tempstr4 = "-";tempstr5 = "-";
    tempstr6 = "-";tempstr7 = "-";tempstr8 = "-";tempstr9 = "-";tempstr10 = "-";
    
    
    tempstr1 = GetDataBaseDataN("mount_config",p.MountInfo.star,DB_MOUNT.STR).."";
    tempstr2 = GetDataBaseDataN("mount_config",p.MountInfo.star,DB_MOUNT.AGI).."";
    tempstr3 = GetDataBaseDataN("mount_config",p.MountInfo.star,DB_MOUNT.INI).."";
    tempstr4 = GetDataBaseDataN("mount_config",p.MountInfo.star,DB_MOUNT.LIFE).."";
    tempstr5 = GetDataBaseDataN("mount_config",p.MountInfo.star,DB_MOUNT.SPEED).."%";
    
    if(p.MountInfo.star <= p.MaxStarLevel) then
        local nextStar = p.MountInfo.star+1;
        tempstr6 = GetDataBaseDataN("mount_config",nextStar,DB_MOUNT.STR).."";
        tempstr7 = GetDataBaseDataN("mount_config",nextStar,DB_MOUNT.AGI).."";
        tempstr8 = GetDataBaseDataN("mount_config",nextStar,DB_MOUNT.INI).."";
        tempstr9 = GetDataBaseDataN("mount_config",nextStar,DB_MOUNT.LIFE).."";
        tempstr10 = GetDataBaseDataN("mount_config",nextStar,DB_MOUNT.SPEED).."%";
    end
    
	local l_turn = GetLabel(layer, p.TagMountLevel.TURN);
    l_turn:SetText(p.GetTurn(p.MountInfo.star)..GetTxtPri("PETUI_T1"));

	local l_star = GetLabel(layer, p.TagMountLevel.STAR);
    l_star:SetText(p.GetStar(p.MountInfo.star)..GetTxtPri("PETUI_T2"));
    
    p.refreshMountAnimate(p.MountInfo.illusionId);
    
    local l_force = GetLabel(layer, p.TagCurrProp.FORCE);
    l_force:SetText(tempstr1);
    
    local l_quick = GetLabel(layer, p.TagCurrProp.QUICK);
    l_quick:SetText(tempstr2);
    
    local l_wit = GetLabel(layer, p.TagCurrProp.WIT);
    l_wit:SetText(tempstr3);
    
    local l_life = GetLabel(layer, p.TagCurrProp.LIFE);
    l_life:SetText(tempstr4);
    
    local l_speed = GetLabel(layer, p.TagCurrProp.SPEED);
    l_speed:SetText(tempstr5);
    
    local l_nforce = GetLabel(layer, p.TagCurrProp.NFORCE);
    l_nforce:SetText(tempstr6);
    
    local l_nquick = GetLabel(layer, p.TagCurrProp.NQUICK);
    l_nquick:SetText(tempstr7);
    
    local l_nwit = GetLabel(layer, p.TagCurrProp.NWIT);
    l_nwit:SetText(tempstr8);
    
    local l_nlife = GetLabel(layer, p.TagCurrProp.NLIFE);
    l_nlife:SetText(tempstr9);
    
    local l_nspeed = GetLabel(layer, p.TagCurrProp.NSPEED);
    l_nspeed:SetText(tempstr10);
    
    
    if p.MountInfo.star >= p.MaxStarLevel then
        local btn = GetButton(layer, p.TagTrain);
        btn:EnalbeGray(true);
    end
    
    p.refreshExpBar();
end

--刷新坐骑动画
function p.refreshMountAnimate(nIllusionId)
    LogInfo("nIllusionId:[%d]",nIllusionId);

    local layer = p.getMainLayer();
    --local p_pic   = GetImage(layer, p.TagMountPic);
	--p_pic:SetPicture(GetMountModelPotraitPic(nIllusionId));
    
    local p_pic   = RecursivUISprite(layer, {p.TagMountPic});
    local szAniPath = NDPath_GetAnimationPath();
    local lockface = GetDataBaseDataN("mount_model_config",nIllusionId,DB_MOUNT_MODEL.LOOKFACE);
    szAniPath = szAniPath .. "model_"..(lockface%1000) .. ".spr";
    
    local l_name = GetLabel(layer, p.TagMountLevel.NAME);
    l_name:SetText(GetDataBaseDataS("mount_model_config",p.MountInfo.illusionId,DB_MOUNT_MODEL.NAME));
    
    p_pic:ChangeSprite(szAniPath);
end

--获得转数
function p.GetTurn(star)
    local starS = math.ceil(star/10) - 1;
    return starS;
end

--获得星级
function p.GetStar(star)
    local starG = star%10;
    if(starG==0) then
        starG = 10; 
    end
    return starG;
end

function p.refreshRideButton(nRide,bIsTip)
    
	local layer = p.getMainLayer();
    local btRide = GetButton(layer, p.TagRide);
    
    LogInfo("p.refreshRideButton:ride:[%d]",p.MountInfo.ride);
    btRide:SetTitle(p.RideState[p.MountInfo.ride]);
    
    LogInfo("nRide:[%d]",nRide);
    
    if(bIsTip) then
        if(nRide == p.RideStateEnum.rest) then
            CommonDlgNew.ShowTipDlg(GetTxtPri("DownMount"));
        elseif(nRide == p.RideStateEnum.ride) then
            CommonDlgNew.ShowTipDlg(GetTxtPri("UpMount"));
        end
    end
end

function p.refreshExpBar()
    local layer = p.getMainLayer();
    
    local t = GetDataBaseDataN("mount_config",p.MountInfo.star,DB_MOUNT.EXP);
    local c = p.MountInfo.exp;
    local startExp = GetDataBaseDataN("mount_config",p.MountInfo.star-1,DB_MOUNT.EXP);
    
    if p.MountInfo.star >= p.MaxStarLevel then
        t = GetDataBaseDataN("mount_config",p.MountInfo.star-1,DB_MOUNT.EXP);
        c = t;
        startExp = GetDataBaseDataN("mount_config",p.MountInfo.star-2,DB_MOUNT.EXP);
    end
    
    
    local expUI	= RecursivUIExp(layer, {p.TAG_EXP});
    
    --[[
    expUI:SetStart(startExp);
    expUI:SetProcess(c);
    expUI:SetTotal(t);
    ]]
    
    expUI:SetProcess(c-startExp);
    expUI:SetTotal(t-startExp);
    
    LogInfo("t:[%d],c:[%d],temp:[%d]",t,c,startExp);
end
        

function p.refreshIllsion()
    -- 幻化列表
    local container = p.GetListContainer();
	if nil == container then
		return;
	end
    container:RemoveAllView();
    --container:SetViewSize(IllsionSize);
    
    LogInfo("mcount:[%d]",#p.MountModelIds);
    
    for i, v in ipairs(p.MountModelIds) do
		local view = createUIScrollView();
        
        if view == nil then
            return;
        end
        view:SetPopupDlgFlag(true);
        view:Init(false);
        view:bringToTop();
        view:SetScrollStyle(UIScrollStyle.Horzontal);
        view:SetViewId(v);
        view:SetTag(v);
        view:SetMovableViewer(container);
        view:SetScrollViewer(container);
        view:SetContainer(container);
        
        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            return false;
        end
        uiLoad:Load("Mount_Illusion_Item.ini", view, p.OnUIIllsionItemEvent, 0, 0);
		
        p.refreshIllsionItem(v,view);
        container:AddView(view);
        uiLoad:Free();
	end
    
    local nTurn = p.GetTurn(p.MountInfo.star);
    
    local nCurr = nTurn*2-1;
    if(nCurr<0) then
        nCurr = 0;
    end
    if(nCurr>#p.MountModelIds-MountListCount) then
        nCurr = #p.MountModelIds - MountListCount;
    end
    container:ShowViewByIndex(nCurr);
    
end

function p.refreshIllsionItem(num, view)
    LogInfo("p.refreshIllsionItem num:[%d]",num);
    local btn = GetButton(view, p.TagIllsionItemBtn);
    local img = GetMountModelPotraitPic(num);
    btn:SetParam1(num);
    btn:SetImage(img);
    
    local lock_Pic = GetImage(view, p.TagIllsionItemPic);
    local lock_btn = GetButton(view, p.TagIllsionItemDis);
    local trun = p.GetTurn(p.MountInfo.star);
    local req_trun = GetDataBaseDataN("mount_model_config",num,DB_MOUNT_MODEL.REQ_LEVEL);
    if(trun<req_trun) then
        lock_Pic:SetVisible(true);
        lock_btn:SetVisible(true);
    else
        lock_Pic:SetVisible(false);
        lock_btn:SetVisible(false);
    end
    
    local pic = GetImage(view, p.TAG_ITEMSIZE);
    local container = p.GetListContainer();
    container:SetViewSize(pic:GetFrameRect().size);
end

function p.OpenTutorial()
    LogInfo("p.OpenTutorial");
    --光效1
    local layer = p.getMainLayer();
    if(layer == nil) then
        LogInfo("p.OpenTutorial layer is nil");
        return false;
    end
    local animate = RecursivUISprite(layer,{TAG_E_ZY1});
    local szAniPath = NDPath_GetAnimationPath();
    animate:ChangeSprite(szAniPath.."jiantx03.spr");
    animate:SetVisible(true);
    
    --光效2
    local illusionLayer = p.GetIllusionLayer();
    if(illusionLayer == nil) then
        LogInfo("p.OpenTutorial illusionLayer is nil");
        return false;
    end
    local animate = RecursivUISprite(illusionLayer,{TAG_E_ZY2});
    local szAniPath = NDPath_GetAnimationPath();
    animate:ChangeSprite(szAniPath.."jiantx03.spr");
    animate:SetVisible(true);
end

function p.CloseTutorial()
    LogInfo("p.CloseTutorial");
    local layer = p.getMainLayer();
    local animate = RecursivUISprite(layer,{TAG_E_ZY1});
    animate:SetVisible(false);
    
    local illusionLayer = p.GetIllusionLayer();
    local animate = RecursivUISprite(illusionLayer,{TAG_E_ZY2});
    animate:SetVisible(false);  
end

local TAG_E_ZY1         = 107;  --幻化指引1
local TAG_E_ZY2         = 116;  --幻化指引2

function p.getMainLayer()
    local scene = GetSMGameScene();
    if(scene == nil) then
        return nil;
    end
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
    return layer;
end

function p.GetIllusionLayer()
	local layer =p.getMainLayer();
    local layerIllsion = GetUiLayer(layer, p.TagIllsionLayer);
    return layerIllsion;
end

--获得幻化列表
function p.GetListContainer()
    local layerIllsion = p.GetIllusionLayer()
	local container = GetScrollViewContainer(layerIllsion, p.TagIllusionList);
	return container;
end

function p.processNet(msgId, data)
	if (msgId == nil ) then
		LogInfo("magmount processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_MOUNT_INFO_LIST then
        LogInfo("_MSG_MOUNT_INFO_LIST:p.MountInfo.illusionId:[%d]",p.MountInfo.illusionId);
        p.MountInfo = data;
        p.refreshUI();
    
    elseif(msgId == NMSG_Type._MSG_USER_CHANGE_MOUNT_TYPE) then                     --幻化
        
        p.refreshMountAnimate(data);
        
        LogInfo("p.processNet msgid:[%d]",NMSG_Type._MSG_USER_CHANGE_MOUNT_TYPE);
        local layerIllsion = p.GetIllusionLayer()
        layerIllsion:SetVisible(false);
        
    elseif(msgId == NMSG_Type._MSG_USER_CHANGE_MOUNT_STATUS) then       --骑乘
        p.refreshRideButton(data,true);
    elseif(msgId == NMSG_Type._MSG_USER_CHANGE_MOUNT_UPGRUDE) then      --培养
        --成功音效    
        Music.PlayEffectSound(Music.SoundEffect.MOUNT_UPGRADE);
        
        --引导任务事件触发
        GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.HORSE);
        
        --爆击提示
        p.TipKnocking(data);
        
        --刷新神马鞭
        p.refreshSMB();
	end
end

function p.getRadioByTag(tag)
    local layer = p.getMainLayer();
    local nod = GetUiNode(layer, tag);
    local check = ConverToCheckBox(nod);
    return check;
end

--取消选中培养单选框
function p.setTrainRadio(tag)
    for k, v in pairs(p.TagRadioGroud) do
        if(v ~= tag) then
            LogInfo("lei:tag:[%d]",v);
            local radio = p.getRadioByTag(v);
            radio:SetSelect(false);
        end
	end
    local radio = p.getRadioByTag(tag);
    radio:SetSelect(true);
end

function p.getSelectRadio()
    local radio = p.getRadioByTag(p.TagRadioGroud.TONG);
    if radio:IsSelect() then
        return 1;
    end
    
    radio = p.getRadioByTag(p.TagRadioGroud.JIN10);
    if radio:IsSelect() then
        return 2;
    end
    
    radio = p.getRadioByTag(p.TagRadioGroud.JIN50);
    if radio:IsSelect() then
        return 3;
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


--刷新神马鞭
function p.refreshSMB()
    LogInfo("p.refreshSMB");
    local nPlayerId     = GetPlayerId();
    local layer = p.getMainLayer();
    if(layer == nil) then
        return;
    end
    local nSMB = p.GetSMBCount();
    _G.SetLabel(layer, TAG_E_TSMB, nSMB.."");
end


--刷新金钱
function p.refreshMoney()
    local nPlayerId     = GetPlayerId();
    local layer = p.getMainLayer();
    if(layer == nil) then
        return;
    end
    
    local nmoney        = MoneyFormat(GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY));
    local ngmoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY).."";
    
    _G.SetLabel(layer, TAG_E_TMONEY, nmoney);
    _G.SetLabel(layer, TAG_E_TEMONEY, ngmoney);
end

GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"PetUI.refreshMoney",p.refreshMoney);
