---------------------------------------------------
--描述: 主界面底部快捷栏
--时间: 2012.2.13
--作者: jhzheng
---------------------------------------------------

MainUIBottomSpeedBar = {}
local p = MainUIBottomSpeedBar;

--UI坐标配置
local winsize	= GetWinSize();
local btnnum	= 8;
local MAX_MILORDERS = 48;
local IsTest    = false;        --是否测试使用

p.Width			= winsize.w;
p.Height		= 40*ScaleFactor;
p.Btninner		= 10*ScaleFactor;
p.BtnWidth		= p.Height;
p.BtnHeight		= p.Height;

p.ScrollWidth   = 780.0;
p.ScrollHeight  = p.Height;

local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;
local TAG_CONTAINER = 121;
local TAG_CON_ITEM_BUTTON = 105;

p.LayerRect = CGRectMake(0.0,winsize.h-p.Height,winsize.w, p.Height); 

p.ScrollRect  = CGRectMake((winsize.w-p.ScrollWidth)/2, winsize.h - p.Height, p.ScrollWidth, p.ScrollHeight); 

--** chh 2012-07-19 **--
function p.BtnCutRectMake(ind)
    LogInfo("p.BtnCutRectMake ind:[%d]",ind);
    local col = Num1(ind)-1;
    local row = Num2(ind)-1;
    if(col < 0 or row < 0) then
        LogInfo("p.BtnCutRectMake row col num fail!");
        return nil;
    end
    
    --原始图片资源的位置是固定的！
	--local nor = CGRectMake(col*40.0*ScaleFactor,row*40.0*ScaleFactor,40.0*ScaleFactor, 40.0*ScaleFactor );
    --local sel = CGRectMake(col*40.0*ScaleFactor,row*40*ScaleFactor+120*ScaleFactor,40.0*ScaleFactor, 40.0*ScaleFactor );
	local nor = CGRectMake(col*80, row*80,		80, 80);
    local sel = CGRectMake(col*80, row*80+240,	80, 80);
	return nor,sel;
end

--滚动层配置
p.ScrollTag = 1;
p.BtnFilePath = "button_function.png"
--按钮配置
p.BtnTag = 
{
    111,    --武将
    112,    --行囊
    113,    --强化
    114,    --阵法
    115,    --将星
    117,    --坐骑
    129,    --占星
    116,    --军团
    119,    --助手
    123,    --好友
    121,    --任务
    125,    --邮件
    122,    --设置
    
    
    
   --发布时去除 131,    --删号
    
    --[[
    118,    --奖励
    124,    --活动
    126,    --决斗
    127,    --征收
    128,    --祭祀
    129,    --占星
    131,    --删号
    132,    --退出
    133,    --神秘商人
    ]]
};
p.BtnFunc =
{
    111,    --人物
    112,    --背包
    113,    --强化
    114,    --阵法
    115,    --将星
    116,    --军团
    117,    --坐骑
    118,    --奖励
    119,    --助手
    121,    --任务
    122,    --设置
    123,    --好友
    124,    --活动
    125,    --邮件
    126,    --决斗
    127,    --征收
    128,    --祭祀
    129,    --占星
    131,    --删号
    132,    --退出
    133,    --神秘商人

};



p.BtnLTag   = 201;
p.BtnRTag   = 202;

p.BtnLeft   = "/General/arrows/icon_arrows2.png";
p.BtnRight  = "/General/arrows/icon_arrows1.png";
p.BtnLeftS   = "/General/arrows/icon_arrows7.png";
p.BtnRightS  = "/General/arrows/icon_arrows8.png";


--btn

p.BtnSayTag = 1301;
p.BtnGMTag = 1302;
p.BtnOLGiftTag = 1303;

p.BtnSayPic = "button_talk.png";
p.BtnStaminaPic = "button_look.png";
p.BtnGm				= "button_gm.png";
p.BtnOLGift			= "onlinegift.png";
p.BtnRechargeGift	= "rechargegift.png";


p.BtnSayFindRect = {
    cutNor = CGRectMake(0.0,0.0,74, 80 ),
    cutSel = CGRectMake(0.0,80.0,74, 80 ),
};

p.BtnGMFindRect = {
    cutNor = CGRectMake(0.0,0.0,92, 80 ),
    cutSel = CGRectMake(0.0,80.0,92, 80 ),
};

p.BtnOnlineGiftRect = {
    cutNor = CGRectMake(0.0,0.0, 80, 80.0),
    cutSel = CGRectMake(0.0,0.0, 80, 80.0),
};

p.BtnRechargeGiftRect = {
    cutNor = CGRectMake(0.0,0.0, 80, 80 ),
    cutSel = CGRectMake(0.0,0.0, 80, 80 ),
};


p.BtnSayRect = CGRectMake(25.0 ,winsize.h-p.BtnHeight-40*ScaleFactor ,40.0*ScaleFactor, 40.0*ScaleFactor);

p.BtnGMRect = CGRectMake(0.0 , winsize.h*0.21 ,92.0, 80.0);

p.BtnOLGiftRect = CGRectMake(winsize.w*0.63 , winsize.h*0.21 ,80.0, 80.0);

p.BtnRechargeRect = CGRectMake(winsize.w*0.72 , winsize.h*0.21 ,80.0, 80.0);



--label
p.LabelTag = 1430;      --对话框标签
p.LabelRect = CGRectMake(75.0 ,508.0 ,600, 24);

p.nTotalFunc = 0;

--control btn
p.CBY = 50*ScaleFactor;
p.ControlBtnRect    = CGRectMake(winsize.w/2-20*ScaleFactor ,winsize.h-p.CBY ,40*ScaleFactor, 20*ScaleFactor);

p.BtnControlBtnUp   = "/icon_ui3.png";
p.BtnControlBtnDown = "/icon_ui2.png";
p.ShowHideState     = 0;    --0代表已经显示 1代表未显示
p.ShowHideHeight    = p.Height;

local tt;
function p.LoadUI()

	local scene = GetSMGameScene();
    
	if scene == nil then
		LogInfo("scene == nil,load BottomSpeedBar failed!");
		return;
	end
	
    
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.BottomSpeedBar );
	layer:SetFrameRect(p.LayerRect);
	scene:AddChild(layer);
    

-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("MainUI_Bottom.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);

    
    
    p.refreshScroll();
    
    
    local pool = DefaultPicPool();
    local norPic	= pool:AddPicture(GetSMImgPath(p.BtnSayPic), false);
    norPic:Cut(p.BtnSayFindRect.cutNor);
    
    --对话列表
    local sayListBtn = p.CreateSceneButton(norPic,nil,p.BtnSayRect,NMAINSCENECHILDTAG.BottomMsgBtn,UILayerZOrder.ChatBtn);
    sayListBtn:SetTag(p.BtnSayTag);
    sayListBtn:SetVisible(true);
   
     --[[提交gm问题按钮
    local gmPic	= pool:AddPicture(GetSMImg00Path(p.BtnGm), true);
    gmPic:Cut(p.BtnGMFindRect.cutNor);
    
    local gmSelPic	= pool:AddPicture(GetSMImg00Path(p.BtnGm), true);
    gmSelPic:Cut(p.BtnGMFindRect.cutSel);
    
    local gmBtn = p.CreateSceneButton(gmPic,gmSelPic,p.BtnGMRect,NMAINSCENECHILDTAG.GMProblemBtn);
    gmBtn:SetTag(p.BtnGMTag);
    gmBtn:SetVisible(false);  
   --]]
   

    --显示隐藏底
    local upPic	= pool:AddPicture(GetSMImgPath(p.BtnControlBtnDown), true);
    local ControlBtn = p.CreateSceneButton(upPic,nil,p.ControlBtnRect,NMAINSCENECHILDTAG.BottomControlBtn,0);
   
     
    tt = ControlBtn;
	
    if(p.ShowHideState == 1) then
        p.setOffset(1, p.ShowHideHeight)
    end
    CheckOtherPlayerBtn.LoadUI(0);
	GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"p.GameDataUserInfoRefresh",p.GameDataUserInfoRefresh);

	return;
end

function p.refreshScroll()

    local container = p.GetContainer();
    if(container == nil) then
        LogInfo("container is nil!");
        return;
    end
    container:RemoveAllView();
    local rectview = container:GetFrameRect();
    --container:SetViewSize(CGSizeMake(rectview.size.h+p.Btninner, rectview.size.h));
    container:SetViewSize(CGSizeMake(50*CoordScaleX, rectview.size.h));
    
    local bIsSkip = false;
    p.nTotalFunc = 0;
    for i,v in ipairs(p.BtnTag) do
    
        if(not IsTest) then
            bIsSkip = false;
            if(not p.GetFuncIsOpen(v)) then
                bIsSkip = true;
            end
        end
    
        if(bIsSkip == false) then
            p.nTotalFunc = p.nTotalFunc + 1;
            local view = createUIScrollView();
            if view == nil then
                LogInfo("p.LoadUI createUIScrollView failed");
                return;
            end
            view:Init(false);
            view:SetViewId(v);
            container:AddView(view);
        
            --初始化ui
            local uiLoad = createNDUILoad();
            if nil == uiLoad then
                layer:Free();
                return false;
            end
	
            uiLoad:Load("MainUI_Bottom_Item.ini", view, p.OnUIEvent, 0, 0);

            p.refreshListItem(view,i);
        end
    end
    p.setLRDisplay();
    
end

function p.GetFuncIsOpen(nTag)
    local ids = GetDataBaseIdList("guide_config");
    for i,v in ipairs(ids) do
        local nFuncIndex = GetDataBaseDataN("guide_config",v,DB_GUIDE_CONFIG.FUNC_INDEX);
        
        LogInfo("nFuncIndex:[%d],nTag:[%d]",nFuncIndex,nTag);
        
        if(nFuncIndex == nTag) then
            local nStage = GetDataBaseDataN("guide_config",v,DB_GUIDE_CONFIG.STAGE);
            local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_STAGE));
            
            LogInfo("v:[%d],nFuncIndex:[%d],nPlayerStage:[%d]",v,nStage,nPlayerStage);
            
            
            if(nPlayerStage<nStage) then
                return false;
            end
            break;
        end
    end
    return true;
end


function p.CreateSceneButton(norPic, selPic, rect, tag,z)
	local zlev = 1;
	if z ~= nil then
		zlev = z;
	end
	
    local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("scene == nil,load MainUI Button failed!");
		return;
	end
	
	local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
	
	local sizeBtn	= norPic:GetSize();
	
	local layer	= createNDUILayer();
	if not CheckP(layer) then
		return;
	end
	
	if(NMAINSCENECHILDTAG.BottomMsgBtn == tag) then
		layer:SetPopupDlgFlag(true);
	end
	
	layer:Init();
	
	if(NMAINSCENECHILDTAG.BottomMsgBtn == tag) then
		layer:bringToTop();
	end
	
	layer:SetFrameRect(rect);

    layer:SetTag(tag);
    
	local btn	= createNDUIButton();
	if not CheckP(btn) then
		layer:Free();
		return;
	end
    
	btn:Init();
	btn:CloseFrame();
    btn:SetTag(tag);
	btn:SetImage(norPic);
    
    
	btn:SetFrameRect(CGRectMake(0, 0, sizeBtn.w*CoordScaleY_960, sizeBtn.h*CoordScaleY_960));
	btn:SetLuaDelegate(p.OnUIEvent);
	layer:AddChild(btn);
    scene:AddChildZ(layer,zlev);
    return btn;
end


function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("chh_mainui p.OnUIEvent[%d],uiEventType:[%d]", tag,uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
        if p.BtnSayTag	~= tag then  
            CloseMainUI();
        end
        
        if( p.BtnFunc[1] == tag ) then       --人物
            PlayerUIAttr.LoadUI();
            --CommonScrollDlg.ShowTipDlg({"由于服务器维护，3点关服，请大家通知大家！",ccc4(255,255,255,255)});
        elseif( p.BtnFunc[2] == tag ) then   --背包
            --p.TestButtonClick(); --删除角色测试 郭浩
            PlayerUIBackBag.LoadUI();
        elseif( p.BtnFunc[3] == tag ) then   --强化
            EquipUpgradeUI.LoadUI();
        elseif( p.BtnFunc[4] == tag ) then   --阵法
            MartialUI.LoadUI();
        elseif( p.BtnFunc[5] == tag ) then   --将星
            HeroStarUI.LoadUI();
        elseif( p.BtnFunc[6] == tag ) then   --军团
            ArmyGroup.Entry();
        elseif( p.BtnFunc[7] == tag ) then   --坐骑
            PetUI.LoadUI();
        elseif( p.BtnFunc[8] == tag ) then   --奖励
            GiftPackUI.LoadUI();
        elseif( p.BtnFunc[9] == tag ) then   --助手
            --AssistantUI.LoadUI();
            DragonTacticUI.LoadUI();      
        elseif( p.BtnFunc[10] == tag ) then  --任务
            TaskUI.LoadUI();
        elseif( p.BtnFunc[11] == tag ) then  --设置
            GameSetting.ShowUI();
        elseif( p.BtnFunc[12] == tag ) then  --好友
            FriendUI.LoadUI();
        elseif( p.BtnFunc[13] == tag ) then  --活动
            
        elseif( p.BtnFunc[14] == tag ) then  --邮件
            EmailList.LoadUI();
        elseif( p.BtnFunc[15] == tag ) then  --决斗
            MsgArena.SendOpenArena();
        elseif( p.BtnFunc[16] == tag ) then  --征收
            Levy.LoadUI();
        elseif( p.BtnFunc[17] == tag ) then  --祭祀
            Fete.LoadUI();
        elseif( p.BtnFunc[18] == tag ) then  --占星--GM问题
            --GMProblemUI.LoadUI();
            MsgRealize.sendRealizeOp();
        elseif( p.BtnFunc[19] == tag ) then  --删号
            --p.TestButtonClick();
        elseif( p.BtnFunc[20] == tag ) then  --退出
            QuitGame();
        elseif( p.BtnFunc[21] == tag ) then  --神秘商人
            SecretShopUI.LoadUI();
        
        
        
        --RealizeUI.LoadUI();
        
        elseif p.BtnSayTag	== tag then     --聊天界面
            ChatMainUI.LoadUI();
                  
        elseif tag == NMAINSCENECHILDTAG.BottomControlBtn then
            p.moveBottom(p.ShowHideHeight);
        elseif tag == p.BtnGMTag then
        	GMProblemUI.LoadUI();

        end
        
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
    
    elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
        p.setLRDisplay();
	end
	return true;
end
--移动工具栏
function p.moveBottom(nDistance)
    LogInfo("p.moveBottom");
    
    local offset = 0;
    if(p.ShowHideState == 0) then
        p.ShowHideState = 1;
        offset = 1;
    else
        p.ShowHideState = 0;
        offset = -1;
    end
    
    p.setOffset(offset, nDistance);
end
function p.setOffset(nOffset, nDistance)
    local scrollLayer = p.GetLayer();
    local msgLayer = p.GetBottomMsgBtnLayer();
    local findLayer = p.findBtn();
    local clayer = p.GetControlLayer();
    
    p.SetFrameYOffsetByObj(scrollLayer,nOffset*nDistance);
    p.SetFrameYOffsetByObj(msgLayer,nOffset*nDistance);
    p.SetFrameYOffsetByObj(findLayer,nOffset*nDistance);
    p.SetFrameYOffsetByObj(clayer,nOffset*(p.CBY-p.ControlBtnRect.size.h));
    p.SetControlBtnPic();
    p.messSetOffset(nOffset, nDistance);
end
function p.messSetOffset(nOffset, nDistance) 
    local chatLayer = p.GetChatGameSceneLayer();
    if(chatLayer) then
        p.SetFrameYOffsetByObj(chatLayer,nOffset*nDistance);
    end
end

function p.findSetOffset(nOffset, nDistance) 
    local findLayer = p.findBtn();
    if(findLayer) then
        p.SetFrameYOffsetByObj(findLayer,nOffset*nDistance);
    end
end

function p.SetFrameYOffsetByObj(node, offset)
    if(node == nil) then
        return false;
    end
    LogInfo("p.SetFrameYOffsetByObj offset:[%d]",offset);
    local rect = node:GetFrameRect();
    rect = CGRectMake(rect.origin.x,rect.origin.y+offset,rect.size.w,rect.size.h)
    node:SetFrameRect(rect);
end
function p.SetControlBtnPic()
    local pool = DefaultPicPool();
    local cbtn = p.GetControlBtn();
    if(p.ShowHideState == 0) then
        cbtn:SetImage(pool:AddPicture(GetSMImgPath(p.BtnControlBtnDown), true));
    else
        cbtn:SetImage(pool:AddPicture(GetSMImgPath(p.BtnControlBtnUp), true));
    end
end

function p.setLRDisplay()
    local layer = p.GetLayer();
    local container = p.GetContainer();
    local btnL = GetImage(layer,p.BtnLTag);
    local btnR = GetImage(layer,p.BtnRTag);
    local index = container:GetBeginIndex()+1;
    LogInfo("p5:index:[%d]",index);
    local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
    
    --left
    local norpic;
    LogInfo("p7");
    if (index==1) then
        norpic = pool:AddPicture(GetSMImgPath(p.BtnLeftS), false);
    else
        norpic = pool:AddPicture(GetSMImgPath(p.BtnLeft), false);
    end
    if(btnL) then
        btnL:SetPicture(norpic);
    end
    
    --right
    local norpic;
    if (index + btnnum > p.nTotalFunc) then
        norpic = pool:AddPicture(GetSMImgPath(p.BtnRightS), false);
    else
        norpic = pool:AddPicture(GetSMImgPath(p.BtnRight), false);
    end
    if(btnR) then
        btnR:SetPicture(norpic);
    end
end


function p.refreshListItem(view,i)
	local ind = p.BtnTag[i];

    local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
	
	local nor,sel,dis =  p.BtnCutRectMake(ind)
	 LogInfo("BtnCutRectMake:"..ind);
	 
    local norpic		= pool:AddPicture(GetSMImg00Path(p.BtnFilePath), false);
    norpic:Cut(nor);
    local toupic        = pool:AddPicture(GetSMImg00Path(p.BtnFilePath), false);
    toupic:Cut(sel);   
    
    local bgV = GetButton(view, TAG_CON_ITEM_BUTTON);
    bgV:SetImage(norpic);
    bgV:SetTouchDownImage(toupic);
    bgV:SetTag(p.BtnTag[i]);
end

function p.GetContainer()
	local container = GetScrollViewContainer(p.GetLayer(), TAG_CONTAINER);
	container:SetBottomSpeedBar(true);
    if nil == container then
        LogInfo("container is nil!");
		return nil;
	end
	return container;
end
function p.findBtn()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.MilOrdersBtn);
    return layer;
end

function p.OLGiftBtn()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.OLGiftBtn);
    return layer;

end

function p.GetControlBtn()
    local controlLayer = p.GetControlLayer();
    return GetButton(controlLayer, NMAINSCENECHILDTAG.BottomControlBtn);
end

function p.GetControlLayer()
    local scene = GetSMGameScene();
    return GetUiLayer(scene, NMAINSCENECHILDTAG.BottomControlBtn);
end

function p.GetLayer()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BottomSpeedBar);
    return layer;
end

function p.GetBottomMsgBtnLayer()
    local scene = GetSMGameScene();
    return GetUiLayer(scene, NMAINSCENECHILDTAG.BottomMsgBtn);
end
function p.GetChatGameSceneLayer()
    local scene = GetSMGameScene();
    return GetUiLayer(scene, NMAINSCENECHILDTAG.ChatGameScene);
end

function p.TestButtonClick()
	CommonDlgNew.ShowYesOrNoDlg("警告（测试用）\n 确定要删除角色吗？", p.SendMsgDelPlayer1, true);	
end

function p.SendMsgDelPlayer1(nEventType , nEvent, param)
	if(CommonDlgNew.BtnOk == nEventType) then
		LogInfo("p.SendMsgDelPlayer1")	
		
   		CommonDlgNew.ShowYesOrNoDlg("你真的想删除人物吗？are u sure?", p.SendMsgDelPlayer2, true);	
   	end
end

function p.GetFuncBtn(nTag)
	local container = p.GetContainer();
    if(container == nil) then
        LogInfo("GetFuncBtn container is nil!");
        return nil;
    end
	local view = container:GetViewById(nTag);
	if(view == nil) then
		LogInfo("GetFuncBtn view is nil!");
		return nil;
	end
	return view;
end

function p.SendMsgDelPlayer2(nEventType , nEvent, param)
	if(CommonDlgNew.BtnOk == nEventType) then
		local netdata = createNDTransData(1053);
		if nil == netdata then
			return false;
		end
		--netdata:WriteByte(nAction);
		netdata:WriteInt(GetPlayerId());
		SendMsg(netdata);
		netdata:Free();
		QuitGame();			--能夠在刪除后自動回到服務器列表介面，Add by 郭浩
		LogInfo("p.SendMsgDelPlayer");
	end
end


RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "MainUIBottomSpeedBar.LoadUI", p.LoadUI);
