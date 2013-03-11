---------------------------------------------------
--描述: 占星祭祀
--时间: 2012.11.22
--作者: chh
---------------------------------------------------
DestinyFeteUI = {}
local p = DestinyFeteUI;

--是否消费提示
p.bFlagConfirm = false;
--[[
local DesInfos = {
    "◇ 每天可以免费占星一次，0点更新，之后可以花费银币进行占星，无次数限制\n◇ 每选择一次占星，只会获得一个星运\n◇ 占星由低级到高级分为：龟甲卜算、周易八卦、洛书河图、奇门遁甲、七星祭天。初始只能选择“龟甲卜算”。\n◇ 每选择一种占星后，都有几率开启下一级的占星，或返回“龟甲卜算”\n◇ 开启高级占星后，依然可以点击“龟甲卜算”，可同时开启多个不同等级的占星。\n◇ 可获得星运类型如下：\n \n<ce47012武曲星/e： 初始力量500点,之后每级增加力量470点\n<ce47012文曲星/e： 初始智力500点,之后每级增加智力470点\n<ce47012禄存星/e： 初始敏捷500点,之后每级增加敏捷470点\n<ce47012廉贞星/e： 初始生命2000点,之后每级增加生命2500点",
	"<ce47012紫微星/e： 100级可获得，初始控制概率增幅基础值的4%,之后每级控制概率增幅基础值的6%\n<ce47012巨门星/e： 100级可获得，初始控制抗性增幅基础值的4%,之后每级控制抗性增幅基础值的6%\n<ce47012破军星/e： 100级可获得，初始减扣士气效果增加基础值的4%,之后每级减扣士气效果增加基础值的6%\n<ce47012贪狼星/e： 100级可获得，初始减扣士气抗性增幅基础值的4%,之后每级减扣士气抗性增幅基础值的6%\n<cff00fc天枢星/e： 初始力量320点,之后每级增加力量240点\n<cff00fc天璇星/e： 初始敏捷320点,之后每级增加敏捷240点\n<cff00fc天权星/e： 初始智力320点,之后每级增加智力240点\n<cff00fc玉衡星/e： 初始生命1280点,之后每级增加生命1000点\n<cff00fc开阳星/e： 80级可获得，初始韧性9%,之后每级增加韧性3.5%\n<cff00fc摇光星/e： 80级可获得，初始增加9%暴击,之后每级增加暴击3.5%",
    "<c179bfc天府星/e： 初始力量180点,之后每级增加力量135点\n<c179bfc天梁星/e： 初始敏捷180点,之后每级增加敏捷135点\n<c179bfc天机星/e： 初始智力180点,之后每级增加智力135点\n<c179bfc天同星/e： 初始生命900点,之后每级增加生命700点\n<c179bfc天衡星/e： 初始命中9%,之后每级增加命中3.5%\n<c179bfc天罡星/e： 初始增加9%闪避,之后每级增加闪避3.5%\n<c179bfc天相星/e： 初始增加9%格挡,之后每级增加格挡3.5%\n<c179bfc天杀星/e： 初始增加9%破击,之后每级增加破击3.5%\n<c1ced5d太阳星/e： 初始力量90点,之后每级增加力量70点\n<c1ced5d太阴星/e： 初始敏捷90点,之后每级增加敏捷70点\n<c1ced5d少阳星/e： 初始智力90点,之后每级增加智力70点\n<c1ced5d少阴星/e： 初始生命500点,之后每级增加生命400点\n<cff0f0f福星/e： 增加星运经验1200点"
};
]]



local DesInfos2 = {
	GetTxtPri("DF_T1"),
	GetTxtPri("DF_T2"),
	GetTxtPri("DF_T3"),
	GetTxtPri("DF_T4"),
	GetTxtPri("DF_T5"),
	GetTxtPri("DF_T6"),
	GetTxtPri("DF_T7"),
	GetTxtPri("DF_T8"),
	GetTxtPri("DF_T9"),
	GetTxtPri("DF_T10"),
	GetTxtPri("DF_T11"),
	"",
	GetTxtPri("DF_T12"),
	GetTxtPri("DF_T13"),
	GetTxtPri("DF_T14"),
	GetTxtPri("DF_T15"),
	GetTxtPri("DF_T16"),
	GetTxtPri("DF_T17"),
	GetTxtPri("DF_T18"),
	GetTxtPri("DF_T19"),
	GetTxtPri("DF_T20"),
	GetTxtPri("DF_T21"),
	GetTxtPri("DF_T22"),
	GetTxtPri("DF_T23"),
	GetTxtPri("DF_T24"),
	GetTxtPri("DF_T25"),
	GetTxtPri("DF_T26"),
	GetTxtPri("DF_T27"),
	GetTxtPri("DF_T28"),
	GetTxtPri("DF_T29"),
	GetTxtPri("DF_T30"),
	GetTxtPri("DF_T31"),
	GetTxtPri("DF_T32"),
	GetTxtPri("DF_T33"),
	GetTxtPri("DF_T34"),
	GetTxtPri("DF_T35"),
	GetTxtPri("DF_T36"),
	GetTxtPri("DF_T37"),
	GetTxtPri("DF_T38"),
	GetTxtPri("DF_T39"),
	GetTxtPri("DF_T40"),
	GetTxtPri("DF_T41"),
	GetTxtPri("DF_T42"),
	GetTxtPri("DF_T43"),
	GetTxtPri("DF_T44"),
}

local TAG_DESC_LAYER = {
	"destiny/Destiny_L_11.ini",
	"destiny/Destiny_L_12.ini",
	"destiny/Destiny_L_13.ini",
	"destiny/Destiny_L_14.ini",
}

p.nCurrPetId = nil;

local MAX_GOODS_NUM     = 4;    --最大物品行数，一行为2个物品

local TAG_CLOSE = 12;
local TAG_CLOSE_INFO = 533;
local TAG_DESC  = 87;   --说明按钮
local TAG_DESTINY_BAG   = 61;
local TAG_FAST_DESTINY  = 52;
local TAG_FAST_GET      = 51;
local TAG_FAST_SELL     = 50;
local TAG_QMDJ          = 17;   --召唤奇门遁甲
local TAG_FREE_COUNT    = 37;   --免费占星次数
local TAG_GOODS_CONTAINER = 19; --物品列表
local TAG_E_TMONEY      = 243;  --
local TAG_E_TEMONEY     = 242;  --


local TAG_IMG_GOODS_PIC1    = 2;
local TAG_LBL_GOODS_NAME1   = 3;
local TAG_LBL_GOODS_DESC1   = 6;
local TAG_BTN_GOODS_SELL1   = 9;

local TAG_IMG_GOODS_PIC2    = 5;
local TAG_LBL_GOODS_NAME2   = 7;
local TAG_LBL_GOODS_DESC2   = 8;
local TAG_BTN_GOODS_SELL2   = 10;

local TAG_ITEM_SIZE         = 51;

local TAG_NPC_LIST = {101,102,103,104,105,};

local TAG_DEFINE_TEXT = {SELL = GetTxtPri("DU_T2"), GET = GetTxtPri("DU_T3")}

function p.LoadUI( nCurrPetId )
    if(p.GetCurrLayer() ~= nil) then
        p.RefreshFreeCount();
        LogInfo("destiny alerady opene");
        return;
    end
    
    p.nCurrPetId = nCurrPetId;

	local scene = GetSMGameScene();
	local layer = createNDUILayer();
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.DestinyFeteUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer+1);
	layer:SetDestroyNotify(p.OnDestroy);
	
    --加载UI
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	uiLoad:Load("destiny/Destiny_M.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
    
    p.RefreshNpcList();
    p.RefreshGoodsList();
    
    p.RefreshMoney();
    
    MsgRealize.mUIListener = p.processNet;
    
    --**影藏一键卖出按钮
    local btn = GetButton(layer, TAG_FAST_SELL);
    if(btn) then
        btn:SetVisible(false);
    end
    
    
    --判断一键占星是否显示为灰色
    local nVipRank = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_VIP_RANK);
    local nRequestVipRank = GetRequestVipLevel(DB_VIP_CONFIG.DESTINY_ASTROLOGY_AUTO);
    LogInfo("nVipRank:[%d],nRequestVipRank:[%d]",nVipRank,nRequestVipRank);
    if(nRequestVipRank>nVipRank) then
        local btn = GetButton(layer,TAG_FAST_DESTINY);
        btn:SetImage(nil);
        btn:SetTouchDownImage(nil);
    end
    
    
    local bIsOpen = GetVipIsOpen(DB_VIP_CONFIG.DESTINY_SELECT_AYTO);
    if(bIsOpen == false) then
        local btn = GetButton(layer, TAG_FAST_SELL);
        btn:SetImage(nil);
        btn:SetTouchDownImage(nil);
    end
    
	return true;
end

function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_REALIZE_QMDJ then
        CloseLoadBar();
    elseif msgId == NMSG_Type._MSG_REALIZE_OPEN then
        p.RefreshNpcList();
    elseif msgId == NMSG_Type._MSG_REALIZE_LIST then
		p.RefreshGoodsList();
    elseif msgId == NMSG_Type._MSG_REALIZE_BUY then
        -- 占星成功反馈
        
        local color = ItemFunc.GetDaoFaItemColor(m);
        local str = string.format(GetTxtPri("DU_T4"),ItemFunc.GetName(m));
        CommonDlgNew.ShowTipsDlg({{str,color}});
        CloseLoadBar();
    elseif msgId == NMSG_Type._MSG_REALIZE_BUY_ALL then
        -- 一占星成功反馈
        if(#m == 0) then
            return;
        end
        local pStr = {};
        for i,v in ipairs(m) do
            local color = ItemFunc.GetDaoFaItemColor(v);
            table.insert(pStr,{string.format("%s X1",ItemFunc.GetName(v)),color});
        end
        CommonDlgNew.ShowTipsDlg(pStr);
        CloseLoadBar();
	end
end


--刷新NPC
function p.RefreshNpcList()
    LogInfo("p.RefreshNpcList");
    local layer = p.GetCurrLayer();
    if(layer == nil) then
        LogInfo("p.RefreshNpcList layer is nil!");
        return;
    end
    for i,v in ipairs(TAG_NPC_LIST) do
        local btn = GetButton(layer, v);
        if( btn ) then
            btn:EnalbeGray( not p.NpcIdIsExists(i) );
        end
    end
    
    local nCount    = GetVipVal(DB_VIP_CONFIG.DESTINY_CALL_QIMEN)-MsgRealize.GetQmdjCount();
    --召唤次数判断
    if(nCount<=0) then
        local btn = GetButton(layer,TAG_QMDJ);
        btn:SetImage(nil);
        btn:SetTouchDownImage(nil);
    end
    
    p.RefreshFreeCount();
end

function p.RefreshFreeCount()
    local layer = p.GetCurrLayer();
    if(layer == nil) then
        LogInfo("p.RefreshFreeCount layer is nil!");
        return;
    end
    
    --免费占星次数
    local nFreeCount = MsgRealize.GetFreeCount();
    SetLabel(layer, TAG_FREE_COUNT, string.format(GetTxtPri("DU_T25"),nFreeCount));
end

function p.NpcIdIsExists( nNpcId )
    local npc_list = MsgRealize.getNpcIdList();
    for i,v in ipairs(npc_list) do
        if v == nNpcId then
            return true;
        end
    end
    return false;
end

--刷新物品
function p.RefreshGoodsList()
    LogInfo("p.RefreshGoodsList");
    local container = p.GetGoodsContainer();
    if(container == nil) then
        LogInfo("p.RefreshGoodsList container == nil!");
        return;
    end
    
    
    
    for i=1,MAX_GOODS_NUM do
        
        local view = container:GetViewById(i);
        local uiLoad = nil;
        --判断是否有面板如果没有就添加，有就修改
        local id_list = MsgRealize.getRealizeIdList();
        if(view == nil and (i*2-1)<=#id_list) then
            LogInfo("add i=[%d]",i);
            --添加
            view = createUIScrollView();
            view:Init( false );
            view:SetScrollStyle( UIScrollStyle.Verical );
            view:SetViewId( i );
            view:SetTag( i );
            view:SetMovableViewer( container );
            view:SetScrollViewer( container );
            view:SetContainer( container );
            
            --初始化ui
            uiLoad = createNDUILoad();
            if nil == uiLoad then
                return false;
            end

            uiLoad:Load("destiny/Destiny_L.ini", view, p.OnUIEvent, 0, 0);--修改路径和事件方法
        end
        
        
        if( i*2-1>#id_list ) then
            LogInfo("del i=[%d]",i);
            container:RemoveViewById(i);
        else
            LogInfo("upt i=[%d]",i);
            p.RefreshGoodItem( view, i );
            
            if( uiLoad ) then
                container:AddView( view );
                uiLoad:Free();
            end
        end
        
    end
end

--填充物品，一次填充两个物品
function p.RefreshGoodItem( view, i )
    
    p.FullItemByItemTypeId(i*2-1,   view,TAG_IMG_GOODS_PIC1,TAG_LBL_GOODS_NAME1,TAG_LBL_GOODS_DESC1,TAG_BTN_GOODS_SELL1);
    p.FullItemByItemTypeId(i*2,     view,TAG_IMG_GOODS_PIC2,TAG_LBL_GOODS_NAME2,TAG_LBL_GOODS_DESC2,TAG_BTN_GOODS_SELL2);
    
    --设置每项控件大小
    local pic   = GetImage( view, TAG_ITEM_SIZE );
    if( pic ) then
        LogInfo("pic size:w:[%d],h:[%d]",pic:GetFrameRect().size.w,pic:GetFrameRect().size.h);
        local container = p.GetGoodsContainer();
        container:SetViewSize(pic:GetFrameRect().size);
    end
end

function p.FullItemByItemTypeId( nIndex, view, nTagPic, nTagName, nTagDesc, nTagSell )
    LogInfo("nIndex:[%d], nTagPic:[%d], nTagName:[%d], nTagDesc:[%d], nTagSell:[%d]",nIndex, nTagPic, nTagName, nTagDesc, nTagSell);

    local container = p.GetGoodsContainer();
    if(container == nil) then
        LogInfo("p.FullItemByItemTypeId container == nil");
        return;
    end
    
    if(view == nil) then
        LogInfo("p.FullItemByItemTypeId view == nil");
        return;
    end
    
    local pic       = GetItemButton(view, nTagPic);
    local l_name    = GetLabel(view, nTagName);
    local l_desc    = GetLabel(view, nTagDesc);
    local btn       = GetButton(view, nTagSell);
    
    --如果nItemType为0时那么隐藏控件
    local id_list = MsgRealize.getRealizeIdList();
    
    if( nIndex > #id_list) then
        LogInfo("chh_hide");
        pic:SetVisible(false);
        l_name:SetVisible(false);
        l_desc:SetVisible(false);
        btn:SetVisible(false);
        return false;
    else
        LogInfo("chh_show");
        pic:SetVisible(true);
        l_name:SetVisible(true);
        l_desc:SetVisible(true);
        btn:SetVisible(true);
    end
    
    local nItemType = id_list[nIndex];
    
    --设置物品颜色
    ItemFunc.SetDaoFaLabelColor(l_name,nItemType);
    
    local sName			= ItemFunc.GetName(nItemType);
    local desc          = ItemFunc.GetDesc(nItemType);
    
    --填充数据
    pic:ChangeItemType(nItemType);
    l_name:SetText(sName);
    l_desc:SetText(desc);
    btn:SetParam1(nItemType);
    btn:SetParam2(nIndex);
    local nStatus = Num1(nItemType);   --0.灰色用于出售 非0可拾取
    if(nStatus == DAOFA_QUALITY_DATA.GRAY) then
        btn:SetTitle(TAG_DEFINE_TEXT.SELL);
    else
        btn:SetTitle(TAG_DEFINE_TEXT.GET);
    end
    
    return true;
end

local DESTINY_INFO_TAG      = 1890;
local TAG_CONTAINER_DESC    = 101;

--创建layer层
function p.CreateDescLayer()
    local layer = p.GetCurrLayer();

	local layer_info = createNDUILayer();
	layer_info:Init();
	layer_info:SetTag(DESTINY_INFO_TAG);
	layer_info:SetFrameRect(RectFullScreenUILayer);
	layer:AddChild(layer_info);
    
    --加载UI
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	uiLoad:Load("destiny/Destiny_L_1.ini", layer_info, p.OnUIEventInfo, 0, 0);
	uiLoad:Free();
    
    local containter = RecursiveSVC(layer_info, {TAG_CONTAINER_DESC});
    containter:RemoveAllView();
    containter:EnableScrollBar(true);
    local size = containter:GetFrameRect().size;
    containter:SetViewSize(CGSizeMake(size.w,14*CoordScaleY));
	for i,v in ipairs(DesInfos2) do
        local view = createUIScrollView();
        view:Init(false);
        view:SetScrollStyle(UIScrollStyle.Verical);
        view:SetViewId(i);
        view:SetTag(i);
        view:SetMovableViewer(containter);
        view:SetScrollViewer(containter);
        view:SetContainer(containter);
        containter:AddView(view);
        
        local pLabelTips = _G.CreateColorLabel( v, 12, size.w );
        --pLabelTips:SetFrameRect(CGSizeMake(size.w,14*CoordScaleY));
        view:AddChild(pLabelTips);
    end
end

function p.OnUIEventInfo(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_CLOSE_INFO) then
            local layer = p.GetCurrLayer();
            layer:RemoveChildByTag(DESTINY_INFO_TAG, true);
        end
    end
    return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
    local nNpcId = p.GetNpcIndexByTag(tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_CLOSE) then
			p.Close();
        elseif(tag == TAG_DESC) then
            p.CreateDescLayer();
        elseif(nNpcId) then                     -- 占星
            if(MsgRealize.IsAutoDestiny()) then
                return true;
            end
            
            --判断银币是否足够
            local nNeedMoney = GetDataBaseDataN("daofa_config",nNpcId,DB_DAOFA_CONFIG.REQ_MONEY)
            if(p.IsNotMoney(nNeedMoney) == false) then
                return true;
            end
            
            
            --判断最大暂时星运背包
            local id_list = MsgRealize.getRealizeIdList();
            if(#id_list>=MAX_GOODS_NUM*2) then
                CommonDlgNew.ShowTipsDlg(p.SetTxtColor(GetTxtPri("DU_T5")));
                return true;
            end
            
            ShowLoadBar();
            MsgRealize.sendRealizeBuy(nNpcId);
            
        
        elseif(tag == TAG_DESTINY_BAG) then     --星云背包
            DestinyUI.LoadUI( p.nCurrPetId );
            p.Close();
        elseif(tag == TAG_FAST_DESTINY) then    -- 一键占星
            if(MsgRealize.IsAutoDestiny()) then
                return true;
            end
            
            --vip等级判断
            local nVipRank = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_VIP_RANK);
            local nRequestVipRank = GetRequestVipLevel(DB_VIP_CONFIG.DESTINY_ASTROLOGY_AUTO);
            LogInfo("nVipRank:[%d],nRequestVipRank:[%d]",nVipRank,nRequestVipRank);
            if(nRequestVipRank>nVipRank) then
                CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("DU_T12"),nRequestVipRank));
                return true;
            end
            
            local npc_list = MsgRealize.getNpcIdList();
            
            
            local npc_id = 1;
            for i,v in ipairs(npc_list) do
                if(v>npc_id) then
                    npc_id = v;
                end
            end
            
            
            local nNeedMoney = GetDataBaseDataN("daofa_config",npc_id,DB_DAOFA_CONFIG.REQ_MONEY);
            
            if(p.IsNotMoney(nNeedMoney) == false) then
                return true;
            end
            
            local id_list = MsgRealize.getRealizeIdList();
            if(#id_list>=MAX_GOODS_NUM*2) then
                CommonDlgNew.ShowTipsDlg(p.SetTxtColor(GetTxtPri("DU_T5")));
                return true;
            end
            
            ShowLoadBar();
            MsgRealize.sendRealizeBuyALL();
        elseif(tag == TAG_FAST_GET) then        -- 一键获得
            if(MsgRealize.IsAutoDestiny()) then
                return true;
            end
            
            local zx,fx = p.GetZXandFXCount();
            LogInfo("chh_00");
            if(zx == 0) then
                if( fx == 0 ) then
                    CommonDlgNew.ShowTipsDlg(p.SetTxtColor(GetTxtPri("DU_T7")));
                    return true;
                end
            
                
                
            end
            
            --判断背包是否已满
            if(ItemFunc.IsDestinyBagFull()) then
                LogInfo("chh_01");
                return true;
            end
            
            
            LogInfo("chh_02");
            ShowLoadBar();
            MsgRealize.sendPickUpAll();
        elseif(tag == TAG_FAST_SELL) then       -- 一键出售
            
            local nVipRank = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_VIP_RANK);
            local nRequestVipRank = GetRequestVipLevel(DB_VIP_CONFIG.DESTINY_SELECT_AYTO);
            LogInfo("nVipRank:[%d],nRequestVipRank:[%d]",nVipRank,nRequestVipRank);
            if(nRequestVipRank>nVipRank) then
                CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("DU_T30"),nRequestVipRank));
                return true;
            end
            
            
            local btn = ConverToButton(uiNode);
            if(btn) then
                if (MsgRealize.IsAutoDestiny()) then
                    --停止占星
                    MsgRealize.CloseAutoDestiny();
                    --[[
                    btn:SetTitle(GetTxtPri("DU_T28"));
                    p.SetBtnStatus(false);
                    ]]
                    
                else
                    --开始自动占星
                    p.CreateAutoDestinySelect();
                end
            end
            
            
            
            --[[
            local zx,fx = p.GetZXandFXCount();
            if(zx==0) then
                CommonDlgNew.ShowTipsDlg(p.SetTxtColor(GetTxtPri("DU_T6")));
                return true;
            end
            
            ShowLoadBar();
            MsgRealize.sendSaleAll();
            ]]
            
        elseif (tag == TAG_QMDJ) then           -- 召唤占星
            if(MsgRealize.IsAutoDestiny()) then
                return true;
            end
            --vip等级判断
            local nVipRank = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_VIP_RANK);
            local nRequestVipRank = GetRequestVipLevel(DB_VIP_CONFIG.DESTINY_CALL_QIMEN);
            if(nRequestVipRank>nVipRank) then
                CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("DU_T13"),nRequestVipRank));
                return true;
            end
            
            --已是奇门盾甲判断
            if p.NpcIdIsExists(4) then
                CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T15"));
                return true;
            end
            
            local nCount    = GetVipVal(DB_VIP_CONFIG.DESTINY_CALL_QIMEN)-MsgRealize.GetQmdjCount();
            --召唤次数判断
            if(nCount<=0) then
                CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T18"));
                return true;
            end
            
            
            local nEMoney = GetDaoFaQMDJEMoney();
            if(p.bFlagConfirm == false) then
                CommonDlgNew.ShowNotHintDlg(string.format(GetTxtPri("DU_T14"),nEMoney,nCount), p.FlagConfirmCallBack);
            else
                if(p.IsNotEMoney(nEMoney) == false) then
                    return true;
                end
            
                ShowLoadBar();
                MsgRealize.sendCallQmdj();
            end
            
        elseif(tag == TAG_BTN_GOODS_SELL1 or tag == TAG_BTN_GOODS_SELL2) then       --拾取和出售功能
            if(MsgRealize.IsAutoDestiny()) then
                return true;
            end
            
            local itemBtn = ConverToButton(uiNode);
            LogInfo("tag == TAG_BTN_GOODS_SELL1 or tag == TAG_BTN_GOODS_SELL2");
            if itemBtn then
                
                local nItemType = itemBtn:GetParam1();
                local nIndex = itemBtn:GetParam2()-1;
                local nStatus = Num1(nItemType);
                LogInfo("nItemType:[%d],nIndex:[%d],nStatus:[%d]",nItemType,nIndex,nStatus);
                if(nStatus == DAOFA_QUALITY_DATA.GRAY) then
                    --卖出
                    MsgRealize.sendSale(nIndex);
                else
                    --拾取
                    --判断背包是否已满
                    if(ItemFunc.IsDestinyBagFull()) then
                        return true;
                    end
                    
                    MsgRealize.sendPickUp(nIndex);
                end
                ShowLoadBar();
            end
        end
    end
    return true;
end

function p.SetBtnStatus(status)
    local player = p.GetCurrLayer();
    if(player) then
        local btn1 = GetButton(player, TAG_FAST_DESTINY);
        local btn2 = GetButton(player, TAG_FAST_GET);
        local btn3 = GetButton(player, TAG_QMDJ);
        if(btn1) then
            btn1:EnalbeGray(status);
        end
        if(btn2) then
            btn2:EnalbeGray(status);
        end
        if(btn3) then
            btn3:EnalbeGray(status);
        end
        
        local btn = GetButton(player, TAG_FAST_SELL);
        if(btn) then
            if(status) then
                btn:SetTitle(GetTxtPri("DU_T29"));
            else
                btn:SetTitle(GetTxtPri("DU_T28"));
            end
            
        end
    end
end

local DestinyFeteUIAUTO = 10101;
local AUTO_J = 101;
local AUTO_Z = 102;
local AUTO_R = 103;

function p.CreateAutoDestinySelect()
    local player = p.GetCurrLayer();
    local layer = createNDUILayer();
	layer:Init();
	layer:SetTag(DestinyFeteUIAUTO);
	layer:SetFrameRect(RectFullScreenUILayer);
	player:AddChildZ(layer,UILayerZOrder.NormalLayer+1);
	
    --加载UI
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	uiLoad:Load("destiny/Destiny_Dlg.ini", layer, p.OnUIEventAutoDestiny, 0, 0);
	uiLoad:Free();
end

function p.OnUIEventAutoDestiny(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == AUTO_J) then
            MsgRealize.KeepGold();
        elseif(tag == AUTO_Z) then
            MsgRealize.KeepPurple();
        elseif(tag == AUTO_R) then
            MsgRealize.KeepBlue();
        end
        
        
        
        
        MsgRealize.EnableAutoDestiny();
        MsgRealize.sendMergeAll();
        
        local player = p.GetCurrLayer();
        if(player) then
            player:RemoveChildByTag(DestinyFeteUIAUTO, true);
        end
        
        p.SetBtnStatus(true);
        
        
        --[[
        local btn = GetButton(player, TAG_FAST_SELL);
        if(btn) then
            btn:SetTitle(GetTxtPri("DU_T29"));
        end
        ]]
    end
    return true;
end


--是否银币不足
function p.IsNotMoney( nNeedMoney )
    local nPlayerId     = GetPlayerId();
    local nMoney         = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
    if(nNeedMoney > nMoney) then
        CommonDlgNew.ShowYesDlg(GetTxtPub("TongQianBuZhu"));
        return false
    end
    return true;
end

--是否金币不足
function p.IsNotEMoney( nNeedEMoney )
    local nPlayerId     = GetPlayerId();
    local nEMoney         = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
    if(nNeedEMoney > nEMoney) then
        CommonDlgNew.ShowYesDlg(GetTxtPub("JinBiBuZhu"));
        return false
    end
    return true;
end

function p.FlagConfirmCallBack(nEventType, param, val)
    LogInfo("p.FlagConfirmCallBack");
    if(nEventType == CommonDlgNew.BtnOk) then
        local nEMoney = GetDaoFaQMDJEMoney();
        if(p.IsNotEMoney(nEMoney) == false) then
            return true;
        end
        
        ShowLoadBar();
        MsgRealize.sendCallQmdj();
        p.bFlagConfirm = val;
    elseif(nEventType == CommonDlgNew.BtnNo) then
        p.bFlagConfirm = val;
    end
end

--获得灾星和非灾星数量，
function p.GetZXandFXCount()
    local nCountZX = 0;
    local nCountFX = 0;
    local id_list = MsgRealize.getRealizeIdList();
    for i,v in ipairs(id_list) do
        local nQuality = Num1(v);
        if(nQuality == DAOFA_QUALITY_DATA.GRAY) then
            nCountZX = nCountZX + 1;
        else
            nCountFX = nCountFX + 1;
        end
    end
    return nCountZX,nCountFX;
end

--获得可用占星的数量
function p.GetDestinyCount()
    local nCount = 0;
    local id_list = MsgRealize.getRealizeIdList();
    for i,v in ipairs(id_list) do
        local nType = GetDataBaseDataN("itemtype", v, DB_ITEMTYPE.ATTR_TYPE_1)/10;
        if(nType>0) then
            nCount = nCount + 1;
        end
    end
    return nCount;
end


function p.GetNpcIndexByTag( nTag )
    for i,v in ipairs(TAG_NPC_LIST) do
        if(v == nTag) then
            return i;
        end
    end
    return nil;
end

--设置错误文本
function p.SetTxtColor( nTxt )
    return {{nTxt,ccc4(255,15,15,255)}};
end

function p.OnDestroy()
    p.FreeData();
end

function p.Close()
	p.FreeData();
	CloseUI(NMAINSCENECHILDTAG.DestinyFeteUI);
end

function p.FreeData()
    
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

function p.GetGoodsContainer()
    local layer = p.GetCurrLayer();
    
    if(layer == nil) then
        return;
    end
    
    local containter = RecursiveSVC(layer, {TAG_GOODS_CONTAINER});
	return containter;
end



function p.GetCurrLayer()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
        LogInfo("nil == scene")
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DestinyFeteUI);
	if not CheckP(layer) then
		LogInfo("nil == layer")
		return nil;
	end
	
	return layer;
end
--=====================================================================================--

GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"DestinyFeteUI.RefreshMoney",p.RefreshMoney);