---------------------------------------------------
--描述: 神秘商人
--时间: 2012.5.15
--作者: chh
---------------------------------------------------
SecretShopUI = {}
local p = SecretShopUI;

p.TagUiLayer = NMAINSCENECHILDTAG.ShopScretUI;

p.TagPageContainer  = 3;
local TagPageView   = 1029;
local TAG_LAYER_GRID= 4;
local MAX_GRID_NUM_PER_PAGE = 16;
p.TAG_CLOSE = 2;
p.TAG_BUY   = 12;

local TAG_BAG_LIST = {};						--背包tag列表

local BuyMaxNum = 99;

p.TAG_GOODS_INFO = {
    PIC = 5,
    NAME = 6,
    LEVEL = 8,
    DESC = 9,
    PRICE = 11,
    BUY_COUNT = 30,
};

local MoneyTypes = 
{
    GetTxtPub("coin"),
    GetTxtPub("shoe"),
}

p.GoodsType = {GEM = 1,};                       --货品类型

--p.GoodsInfos = {};                              --商店物品
p.GoodsShowId = {
    {ID = 3 , TYPE = p.GoodsType.GEM,},
    {ID = 5 , TYPE = p.GoodsType.GEM,},
    {ID = 7 , TYPE = p.GoodsType.GEM,},
    {ID = 8 , TYPE = p.GoodsType.GEM,},
    {ID = 9 , TYPE = p.GoodsType.GEM,},
};
p.pageSize = 0;

-- 常量宏
local MAX_BACK_BAG_NUM				= 4;
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
local TAG_BEGIN_ARROW   = 1411;
local TAG_END_ARROW     = 1412;
local TAG_E_TEMONEY     = 242;
-- 格子界面tag
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_16				= 77;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_15				= 76;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_14				= 75;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_12				= 74;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_11				= 73;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_10				= 72;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_8				= 71;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_7				= 70;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_6				= 69;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_4				= 68;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_3				= 67;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_2				= 66;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_13				= 65;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_9				= 64;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_5				= 63;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_1				= 62;


function p.Close()
	p.freeData();
	CloseUI(p.TagUiLayer);
end

p.ShopType = 0;
function p.LoadUI(ShopType)
    p.ShopType = ShopType;
    if(p.ShopType == nil) then
        p.ShopType = MsgShop.GroupType.MYSTERIOUS;
    end

	local scene = GetSMGameScene();
	local layer = createNDUILayer();
	
	--layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:SetTag(p.TagUiLayer);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
	layer:SetDestroyNotify(p.OnDestroy);
	
    --加载UI
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	uiLoad:Load("SM_NPC_ShopSecret.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
    
	p.initData(ShopType);
    
    p.LoadPageView();
    
    p.LoadGoodsView();
    
    --==设置当前显示背包的页=======
	p.SetFocusOnPage(0);
    
	p.RefreshUI();
    
    SetArrow(p.getUiLayer(),p.GetGoodsViewContainer(),1,TAG_BEGIN_ARROW,TAG_END_ARROW);
    
    p.refreshMoney();
    
	return true;
end

--银币不足
function p.tipMoneyNotEnough()
    CommonDlgNew.ShowYesDlg(GetTxtPri("YinBiBuZhuWuFaGouMai"));
end

--金币不足
function p.tipEMoneyNotEnough(nPrice)
    EMoneyNotEnough(nPrice);
end

--数字验证
function p.tipNumVail()
    CommonDlgNew.ShowYesDlg(GetTxtPri("NumMax0"));
end

function p.OnUIEventBuyNum(nEventType, param, val)
    if(CommonDlgNew.BtnOk == nEventType) then
        local num = math.floor(SafeS2N(val));
        if(num>0) then
            
            local layer = p.getUiLayer();
            local itemBtn = GetItemButton(layer, p.TAG_GOODS_INFO.PIC);           
            local nItemType = itemBtn:GetItemType();
            
            
            local nAmountLimit = GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.AMOUNT_LIMIT);
            --判断背包是否已满
            if(nAmountLimit~=0) then
                LogInfo("nAmountLimit:[%d]",nAmountLimit);
                if(ItemFunc.IsBagFull(math.ceil(num/nAmountLimit)-1)) then
                    return false;
                end
            end
            
            local nPrice    = 0;
            local nMoney	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.PRICE);
            local nEMoney	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.EMONEY);
            if(nBuyType == 0) then
                nPrice = nMoney;
            else
                nPrice = nEMoney;
            end
            nPrice = nPrice*num;
            
            local money = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_MONEY);
            local emoney= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_EMONEY );
            
            if(itemBtn:GetParam1()==0) then
                if(nPrice>money) then
                    p.tipMoneyNotEnough();
                    return;
                end
            elseif(itemBtn:GetParam1()==1) then
                 if(nPrice>emoney) then
                    p.tipEMoneyNotEnough(nPrice);
                    return;
                end
            end
            
            MsgShop.sendBuy(nItemType,num);
            ShowLoadBar();
        else
            p.tipNumVail();
        end
    end
end



function p.initData()
    p.initConst();
    p.pageSize = math.ceil(#p.GoodsShowId/MAX_GRID_NUM_PER_PAGE);
    
    if(p.ShopType == MsgShop.GroupType.MYSTERIOUS) then
        p.GoodsShowId = MsgShop.GetMySteriousGoodsList();
    else
        p.GoodsShowId = MsgShop.GetSmithGoodsList();
    end
    
    MAX_BACK_BAG_NUM	= table.getn(p.GoodsShowId);
    if(MAX_BACK_BAG_NUM == 0) then
        MAX_BACK_BAG_NUM = 1;
    end
    if(MAX_BACK_BAG_NUM>9) then
        MAX_BACK_BAG_NUM = 9;
    end
    
    MsgShop.mUIListener = p.processNet;
end

function p.initConst()
    p.InitGridTag();
    
end

function p.LoadPageView()
	local container = p.GetPageViewContainer();
    if(container == nil) then
        LogInfo("container is nil!");
    end

	
    local rectview = container:GetFrameRect();
    container:SetViewSize(rectview.size);

    for i=1, MAX_BACK_BAG_NUM do
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

function p.SetFocusOnPage(nPage)
	if not CheckN(nPage) or 
		nPage < 0 then
		return;
	end
	
    local container	= p.GetPageViewContainer();
	if not CheckP(container) then
        LogInfo("container is nil!");
		return;
	end
    container:ShowViewByIndex(nPage);
end

function p.LoadGoodsView()
    local container = p.GetGoodsViewContainer();
    container:RemoveAllView();
	local rectview = container:GetFrameRect();
	container:SetViewSize(rectview.size);
    
    for i=1, p.pageSize do
        local view = createUIScrollView();
		view:Init(false);
		view:SetViewId(i);
		container:AddView(view);
		
		local uiLoad = createNDUILoad();
		if uiLoad ~= nil then
			uiLoad:Load("SM_NPC_ShopSecret_List.ini", view, p.OnUIEventGoods, 0, 0);
			uiLoad:Free();
		end
    end
end

function p.OnUIEventGoods(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		if tag == TAG_LAYER_GRID then
            
			local pageView = p.GetGoodsViewContainer();
            local viewId = pageView:GetBeginIndex();
            p.SetFocusOnPage(viewId);
            
            SetArrow(p.getUiLayer(),p.GetGoodsViewContainer(),1,TAG_BEGIN_ARROW,TAG_END_ARROW);
		end
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        local btn = ConverToItemButton(uiNode);
        if(btn == nil) then
            LogInfo("btn is nil!");
        end
        local nItemType = btn:GetItemType();
        local nBuyType =  btn:GetParam1();
        p.SetGoodsInfo(nItemType, nBuyType);
	end
end

function p.OnUIEventClickPage(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventItemInfo[%d] event[%d]", tag, uiEventType);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag >=1 and tag <= p.pageSize then
			local container		= p.GetGoodsViewContainer();
			if CheckP(container) then
				container:ScrollViewById(tag);
			end 
		end
    
	end
    
	return true;
end

function p.SetGoodsInfo(nItemType, nBuyType)
    if(not CheckN(nItemType) or nItemType<=0) then
        return;
    end
    local layer = p.getUiLayer();
    
    LogInfo("nItemType:[%d];",nItemType);
    
    local itemBtn = GetItemButton(layer, p.TAG_GOODS_INFO.PIC);
    itemBtn:ChangeItemType(nItemType);
    itemBtn:SetParam1(nBuyType);
    
    --物品名称
    local l_name = GetLabel(layer, p.TAG_GOODS_INFO.NAME);
    l_name:SetText(ItemFunc.GetName(nItemType));
    ItemFunc.SetLabelColor(l_name,nItemType);
    
    --local l_level = GetLabel(layer, p.TAG_GOODS_INFO.LEVEL);
    --l_level:SetText(ItemFunc.GetLvlReq(nItemType)..GetTxtPub("Level"));
    
    
    --物品描述
    local l_desc = GetLabel(layer, p.TAG_GOODS_INFO.DESC);
    l_desc:SetText(ItemFunc.GetDesc(nItemType));
    
    LogInfo("nBuyType:[%d]",nBuyType);
    
    local l_price = GetLabel(layer, p.TAG_GOODS_INFO.PRICE);
    
    
    local nPrice    = 0;
    local nMoney	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.PRICE);
    local nEMoney	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.EMONEY);
    
    if(nBuyType == 0) then
        nPrice = nMoney;
    else
        nPrice = nEMoney;
    end
    l_price:SetText(nPrice..MoneyTypes[nBuyType+1]);
end




function p.RefreshUI()
    p.RefreshGoods();
end

function p.InitGridTag()
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_1);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_2);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_3);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_4);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_5);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_6);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_7);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_8);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_9);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_10);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_11);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_12);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_13);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_14);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_15);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_16);
end

function p.GetGridTag(i)
	if not CheckT(TAG_BAG_LIST) or 0 == table.getn(TAG_BAG_LIST) then
        LogInfo("TAG_BAG_LIST is num 0!");
		return 0;
	end
	
	if i <= table.getn(TAG_BAG_LIST) then
		return TAG_BAG_LIST[i];
	end
	LogInfo("i tai da!");
	return 0;
end

function p.RefreshGoods()
    local tSize = #p.GoodsShowId;
    LogInfo("tSize:[%d]",tSize);
    local  container = p.GetGoodsViewContainer();
    for i=1, p.pageSize do
		local view = container:GetViewById(i);
		if nil ~= view then
			for j=1, MAX_GRID_NUM_PER_PAGE do
                LogInfo("loop");
				local nTag		= p.GetGridTag(j);
                LogInfo("nTag:[%d]",nTag);
				local itemBtn	= GetItemButton(view, nTag);
                
                
                if(itemBtn == nil) then
                    LogInfo("itemBtn is nil!");
                end
                
				if nil ~= itemBtn then
					local nItemType	= 0;
					local nIndex	= (i - 1) * MAX_GRID_NUM_PER_PAGE + j;
                    LogInfo("nIndex:[%d]",nIndex);
					if nIndex <= tSize then
						nItemType		= p.GoodsShowId[nIndex].ID;
                        LogInfo("nItemType:[%d]",nItemType);
					end
					nItemType			= nItemType or 0;
                    
                    if(nItemType == 0) then
                        itemBtn:SetFocus(false);
                    else
                        itemBtn:SetFocus(true);
                        itemBtn:SetParam1(p.GoodsShowId[nIndex].BUY_TYPE);
                    end
                    itemBtn:ChangeItemType(nItemType);
				else
					LogError("p.RefreshGoods item button tag[%d][%d] error", j, nTag);
				end
			end
		end
	end
    
    --p.refreshBuyCount();
end

function p.refreshBuyCount()
    --可购买次数
    local usBuyedGem = GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_BUYED_GEM);
    local l_BuyCount = GetLabel(p.getUiLayer(), p.TAG_GOODS_INFO.BUY_COUNT);
    l_BuyCount:SetText(usBuyedGem.."");
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == p.TAG_CLOSE) then
            p.freeData();
			p.Close();
        elseif(tag == p.TAG_BUY) then
            local layer = p.getUiLayer();
            local itemBtn = GetItemButton(layer, p.TAG_GOODS_INFO.PIC);           
            if(itemBtn:GetItemType()==0) then
                return;
            end
            CommonDlgNew.ShowInputDlg(GetTxtPri("SSUI_T1"), p.OnUIEventBuyNum,nil,1,3);
        end
    end
    return true;
end

function p.freeData()
    MsgShop.mUIListener = nil;
    p.TAG_BAG_LIST = {};
end

function p.GetPageView()
	local svc	= p.GetPageViewContainer();
	if not CheckP(svc) then
		return nil;
	end
	
	local view = svc:GetView(0);
	return view;
end

function p.GetPageViewContainer()
	local scene = GetSMGameScene();	
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load p.LoadPageView failed!");
		return;
	end
	
	local svc	= RecursiveSVC(scene, {p.TagUiLayer, p.TagPageContainer});
	return svc;
end

function p.GetGoodsViewContainer()
	local scene = GetSMGameScene();
	local idlist = {};
	table.insert(idlist, p.TagUiLayer);
	table.insert(idlist, TAG_LAYER_GRID);
	local containter = RecursiveSVC(scene, idlist);
	return containter;
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

function p.processNet(msgId, data)
	if (msgId == nil ) then
		LogInfo("MsgShop processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_CONFIG_MYSTERIOUS_GOODS then
        p.GoodsShowId = data;
        p.RefreshUI();
    elseif msgId == NMSG_Type._MSG_SHOP then
        --p.refreshBuyCount();
        
        local sGood = string.format("%s x%d",ItemFunc.GetName(data.nItemType),data.nCount);
        local sTxt = string.format(GetTxtPri("BuyResultMsg"),sGood);
        CommonDlgNew.ShowTipDlg(sTxt);
	end
    CloseLoadBar();
end
--刷新金钱
function p.refreshMoney()
    local nPlayerId     = GetPlayerId();
    local layer = p.getUiLayer();
    if(layer == nil) then
        return;
    end
    
    local ngmoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY).."";
    _G.SetLabel(layer, TAG_E_TEMONEY, ngmoney);
end

local TAG_E_TMONEY      = 243;  --
local TAG_E_TEMONEY     = 242;  --
--刷新金钱
function p.refreshMoney()
    LogInfo("p.refreshMoney BEGIN");
    local nPlayerId     = GetPlayerId();
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ShopScretUI);
    if(layer == nil) then
        return;
    end
    
    local nmoney        = MoneyFormat(GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY));
    local ngmoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY).."";
    
    _G.SetLabel(layer, TAG_E_TMONEY, nmoney);
    _G.SetLabel(layer, TAG_E_TEMONEY, ngmoney);
end
GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"PetUI.refreshMoney",p.refreshMoney);

GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"PetUI.refreshMoney",p.refreshMoney);