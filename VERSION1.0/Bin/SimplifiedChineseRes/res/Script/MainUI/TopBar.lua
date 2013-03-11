---------------------------------------------------
--描述: 主界面底部快捷栏
--时间: 2012.2.13
--作者: jhzheng
---------------------------------------------------

MainUI = {}
local p = MainUI;
--UI坐标配置
local winsize	= GetWinSize();
local RectTopUILayer = CGRectMake(0, 0, winsize.w, 120.0*ScaleFactor);

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;
local fScalex = CoordScaleX;
local fScaley = CoordScaleY;


local TOOL_BTN = {
    {Tag=14,Rect=CGRectMake(345*fScalex,30*fScaley,40*fScalex,40*fScaley)},--竞技场
    {Tag=20,Rect=CGRectMake(305*fScalex,30*fScaley,40*fScalex,40*fScaley)},--征收
    {Tag=35,Rect=CGRectMake(265*fScalex,30*fScaley,40*fScalex,40*fScaley)},--祭祀 
    {Tag=19,Rect=CGRectMake(225*fScalex,30*fScaley,40*fScalex,40*fScaley)},--礼包
    {Tag=29,Rect=CGRectMake(185*fScalex,30*fScaley,40*fScalex,40*fScaley)},--每日签到  
    {Tag=38,Rect=CGRectMake(345*fScalex,70*fScaley,40*fScalex,40*fScaley)},--充值礼包  
    {Tag=39,Rect=CGRectMake(305*fScalex,70*fScaley,40*fScalex,40*fScaley)},--在线礼包 
    {Tag=40,Rect=CGRectMake(265*fScalex,70*fScaley,40*fScalex,40*fScaley)},--运粮活动   
    {Tag=41,Rect=CGRectMake(225*fScalex,70*fScaley,40*fScalex,40*fScaley)},--名人堂
};

local MAIN_UI_BUTTON_TOPUP = 17; 

local ID_MAINUI_PICTURE_UI_8						= 33;
local ID_MAINUI_PICTURE_UI_7						= 32;
local ID_MAINUI_PICTURE_UI_9						= 30;
local ID_MAINUI_TEXT_UI_2							= 28;
local ID_MAINUI_TEXT_UI_3							= 27;
local ID_MAINUI_TEXT_UI_6							= 26;
local ID_MAINUI_TEXT_UI_7							= 25;
local ID_MAINUI_TEXT_UI_4							= 24;
local ID_MAINUI_TEXT_UI_5							= 23;
local ID_MAINUI_PICTURE_UI_6						= 22;
local ID_MAINUI_BUTTON_HEAD						= 21;
local ID_MAINUI_PICTURE_UI3						= 20;
local ID_MAINUI_PICTURE_UI2						= 19;
local ID_MAINUI_PICTURE_UI1						= 18;
local ID_MAINUI_BUTTON_TOPUP						= 17;
local ID_MAINUI_BUTTON_MONEY						= 16;
local ID_MAINUI_BUTTON_ACTION						= 15;
local ID_MAINUI_BUTTON_DUEL						= 14;
local ID_MAINUI_BUTTON_MISSION					= 9;
local ID_MAINUI_BUTTON_MISSION2					= 98;
local ID_MAINUI_BTN_NEW_EMAIL						= 36;	--新邮件提示按钮ID
local ID_MAINUI_BTN_ACTIVITY						= 43;	--活动按钮ID

--图片裁剪不要用缩放比例!
local NUMBER_FILE = "/number/num_2.png";
local N_W = 42*2;
local N_H = 32*2;
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
local TAG_NUMBER_IMG_S = 25;
local TAG_NUMBER_IMG_B = 34;

--刷新引导图片定时器id
p.nTimerID = nil;

function p.LoadUI()

    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();
	if scene == nil then
		LogInfo("scene == nil,load TopBar failed!");
		return;
	end
    
--    local node = createNDUINode();
--	if node == nil then
--		return false;
--	end

--	node:Init();
--	node:SetFrameRect(RectTopUILayer);
    
    --------------------添加军衔层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetFrameRect(RectTopUILayer);
	layer:SetTag(NMAINSCENECHILDTAG.MainUITop );
    

	scene:AddChild(layer);
    -----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("MainUI.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	local pBtnNewEmail = GetUiNode( layer, ID_MAINUI_BTN_NEW_EMAIL );
	if ( nil ~= pBtnNewEmail ) then
		local rectForm		= pBtnNewEmail:GetFrameRect();
		local pSpriteNode	= createUISpriteNode();
		pSpriteNode:Init();
		pSpriteNode:SetFrameRect( CGRectMake(0, 0, rectForm.size.w, rectForm.size.h) );
		local szAniPath		= NDPath_GetAnimationPath();
		local szSprFile		= "mail01.spr";
		pSpriteNode:ChangeSprite( szAniPath .. szSprFile );
		pBtnNewEmail:AddChild( pSpriteNode );
	end
	pBtnNewEmail:SetVisible( MsgUserEmail.IsHaveNewEmail() );
	--
	local pBtnActivity = GetUiNode( layer, ID_MAINUI_BTN_ACTIVITY );
	if ( nil ~= pBtnActivity ) then
		local rectForm		= pBtnActivity:GetFrameRect();
		local pSpriteNode	= createUISpriteNode();
		pSpriteNode:Init();
		pSpriteNode:SetFrameRect( CGRectMake(0, 0, rectForm.size.w, rectForm.size.h) );
		local szAniPath		= NDPath_GetAnimationPath();
		local szSprFile		= "activity01.spr";
		pSpriteNode:ChangeSprite( szAniPath .. szSprFile );
		pBtnActivity:AddChild( pSpriteNode );
	end

	
	--在线礼包增加时间显示
    local btnOL = 	GetButton(layer,TOOL_BTN[7].Tag);
    
	local OLGiftCDlabel = CreateLabel("",CGRectMake(-115,60,300,50),12,ccc4(255,255,255,255));
    OLGiftCDlabel:SetTag(99);
    OLGiftCDlabel:SetTextAlignment(1);
    OLGiftCDlabel:SetVisible(true); 
    btnOL:AddChildZ(OLGiftCDlabel,2);
	------------------
	
	p.RefreshUserInfo();
    p.RefreshTaskPic();
	GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"p.GameDataUserInfoRefresh",p.GameDataUserInfoRefresh);
    
    
    p.RefreshFuncIsOpen();
    
	if ( p.nTimerID	 ~= nil ) then
    	UnRegisterTimer( p.nTimerID );
		p.nTimerID			= nil;
    end
    
    local btnbuff = 	GetButton(layer,44);
    btnbuff:SetVisible(false);
    Buff.SendRequest();
    
	return;
end




function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo( "topbar: OnUIEvent tag:"..tag );
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == MAIN_UI_BUTTON_TOPUP then
			if not IsUIShow(NMAINSCENECHILDTAG.PlayerVIPUI) then
				CloseMainUI();
				--DoFile("Player/PlayerVIPUI.lua");
				PlayerVIPUI.LoadUI();
				return true;
            end
        elseif TOOL_BTN[1].Tag == tag then          --竞技
            ShowLoadBar();
            _G.CloseMainUI();
            _G.MsgArena.SendOpenArena();
            return ture;
        
        elseif TOOL_BTN[2].Tag == tag then          --征收
                _G.CloseMainUI();
            	Levy.LoadUI();
            	return true;
        
        elseif TOOL_BTN[3].Tag == tag then          --祭祀
                _G.CloseMainUI();
            	Fete.LoadUI();
            	return ture;
                
                
        elseif TOOL_BTN[4].Tag == tag then          --礼包
            _G.CloseMainUI();
            GiftPackUI.LoadUI();
            return true;
            
        elseif TOOL_BTN[5].Tag == tag then          --每日签到
            LogInfo("tag"..tag);
            DailyCheckInUI.LoadUI();      
            --RechargeReward.LoadUI();      
            return ture;
        elseif TOOL_BTN[6].Tag == tag then          --充值礼包
            RechargeReward.LoadUI();      
            return ture;   
        elseif TOOL_BTN[7].Tag == tag then          --在线领取
        	--领取礼包
        	LogInfo("领取礼包");
        	OnlineCheckIn.GetGift();  
            return ture;   
            
        elseif TOOL_BTN[8].Tag == tag then          --活动列表
            if not IsUIShow(NMAINSCENECHILDTAG.DailyActionUI) then
                DailyAction.LoadUI(); 
            end
            return ture;        

        elseif ID_MAINUI_BTN_NEW_EMAIL == tag then          -- 新邮件
            _G.CloseMainUI();
            EmailList.LoadUI();
            return true;

        elseif ID_MAINUI_BTN_ACTIVITY == tag then          -- 活动(公告)
            _G.CloseMainUI();
            ActivityNoticeUI.ShowUI();
            return true;
          
            
        elseif ID_MAINUI_BUTTON_HEAD == tag then    --军衔
            local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_STAGE));
            --军衔权限判断
            if(nPlayerStage<StageFunc.Rank) then
                return true;
            end
            
            if not IsUIShow(NMAINSCENECHILDTAG.RankUI) then
                _G.CloseMainUI();
				_G.RankUI.LoadUI();
				return true;
                
			end
		elseif ID_MAINUI_BUTTON_MISSION == tag or tag == ID_MAINUI_BUTTON_MISSION2 then
			--追踪主线任务
			p.TrackMainTask();
			
		elseif tag == 37 then
			local nPlayerId     = GetPlayerId();
			local mainpetid 	= RolePetUser.GetMainPetId(nPlayerId);
			local nLev			= _G.SafeS2N(RolePetFunc.GetPropDesc(mainpetid, PET_ATTR.PET_ATTR_LEVEL));
		
			if nLev <= 29 then
				return;
			end
		
			nLev = nLev + 1;
			CommonDlgNew.ShowTipDlg(string.format(GetTxtPri("TB_T1"),nLev));
		elseif tag ==  44 then
			Buff.LoadUI();
			return true;
        end
    end	
end

--刷新玩家左上角信息
function p.RefreshUserInfo()
	local topbar = p.GetTopBar();
	local nPlayerId = GetPlayerId();
	
	local HeadButton    =  RecursiveButton(topbar,{ID_MAINUI_BUTTON_HEAD});
	local MOLabel 		=  RecursiveLabel(topbar,{ID_MAINUI_TEXT_UI_3});
	local GoldLabel 	=  RecursiveLabel(topbar,{ID_MAINUI_TEXT_UI_5});
	local SilverLabel 	=  RecursiveLabel(topbar,{ID_MAINUI_TEXT_UI_4});
	--local VipRankLabel  =  RecursiveLabel(topbar,{ID_MAINUI_TEXT_UI_7});
    
    local VipRankS  =  RecursiveImage(topbar,{TAG_NUMBER_IMG_S});
    local VipRankB  =  RecursiveImage(topbar,{TAG_NUMBER_IMG_B});
	local NameLabel 	=  RecursiveLabel(topbar,{ID_MAINUI_TEXT_UI_6});
	local LevLabel 		=  RecursiveLabel(topbar,{ID_MAINUI_TEXT_UI_2});
	
	if (CheckP(topbar)) == false then
		LogInfo("topbar dont exist ")
		return;
	end	
	
	if (CheckP(MOLabel)) == false then
		LogInfo("molabel dont exist "..ID_MAINUI_TEXT_UI_3)
		return;
	end	
	
    local nPlayerId     = GetPlayerId();
    local nPetId        = RolePetFunc.GetMainPetId(nPlayerId);
    local nPetType      = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);
   -- local headPic       = _G.GetPetPotraitTranPic(nPetType);
    local headPic       = _G.GetPlayerMainUIPotraitPic(nPetType);
    
	local nMilOrders    = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_STAMINA);
	local nGold 		=  GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
	local nSilverCoin 	= GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
	local nVipRank 		= GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);
	local sName 		= GetRoleBasicDataS(nPlayerId,USER_ATTR.USER_ATTR_NAME);
	local mainpetid 	= RolePetUser.GetMainPetId(nPlayerId);
	local nLev			= RolePetFunc.GetPropDesc(mainpetid, PET_ATTR.PET_ATTR_LEVEL);
    
    LogInfo("sName:[%s]",sName);
    HeadButton:SetImage(headPic);
	
    --[[
    GoldLabel:SetFontSize(10);
	SilverLabel:SetFontSize(10);
	VipRankLabel:SetFontSize(8);
	NameLabel:SetFontSize(8);
	LevLabel:SetFontSize(8);
]]

	MOLabel:SetText(""..nMilOrders);

	local sGold = nGold.."";		
	GoldLabel:SetText(""..sGold);	
	
	local sSilverCoin = p.Coinformat(nSilverCoin);		
	SilverLabel:SetText(""..sSilverCoin);
	

    local pool = DefaultPicPool();
    local ps = pool:AddPicture(GetSMImgPath(NUMBER_FILE), false);
    if(nVipRank<10) then
        LogInfo("nVipRank{%d}",nVipRank);
        ps:Cut(Numbers_Rect[nVipRank+1]);
        VipRankS:SetPicture(ps);
    else
        local s = Num2(nVipRank)+1;
        local b = Num1(nVipRank)+1;
        ps:Cut(Numbers_Rect[s]);
        VipRankS:SetPicture(ps);
        
        local pb = pool:AddPicture(GetSMImgPath(NUMBER_FILE), false);
        pb:Cut(Numbers_Rect[b]);
        VipRankB:SetPicture(pb);
        
        LogInfo("s:[%d],b:[%d]",s,b);
    end
    
    
	--VipRankLabel:SetText("VIP"..nn);

	NameLabel:SetText(""..sName);
	LevLabel:SetText(""..nLev);
	
end

--钱钱数值转换格式
function p.Coinformat(nMoney)
	local str = "";
	local nYi = 0;
	local nWan = 0;
	local nMoneyTmp = nMoney;
	--[[
	if nMoneyTmp >= 100000000 then
		nYi = math.floor(nMoneyTmp/100000000);
	end
	if nYi > 0 then
		str = nYi.."亿";
	end
	--]]
		
	--nMoneyTmp = nMoneyTmp - nYi*100000000;
	if nMoneyTmp >= 10000 then
		nWan = math.floor(nMoneyTmp/10000);
	end	

	if nWan > 0 then
		str = str..nWan..GetTxtPub("ten");
	end	
	
	if str == "" then
		--nMoneyTmp = nMoneyTmp - nWan*10000;
		return nMoney;
	else
		return str;	
	end
end

--开启功能判断
function p.RefreshFuncIsOpen()
	 LogInfo("RefreshFuncIsOpen")
    local topBarLayer = p.GetTopBar();
    if(topBarLayer == nil) then
        return;
    end
    
    
    local btnArena = GetButton(topBarLayer,TOOL_BTN[1].Tag);
    local btnLevy = GetButton(topBarLayer,TOOL_BTN[2].Tag);
    local btnFete = GetButton(topBarLayer,TOOL_BTN[3].Tag);  
    local btnGift = GetButton(topBarLayer,TOOL_BTN[4].Tag);
    local btnSign = GetButton(topBarLayer,TOOL_BTN[5].Tag);
    local btnRecharge = GetButton(topBarLayer,TOOL_BTN[6].Tag);
    local btnOL = 	GetButton(topBarLayer,TOOL_BTN[7].Tag);
    local btnDailyAct = 	GetButton(topBarLayer,TOOL_BTN[8].Tag); 
            
    btnLevy:SetVisible(IsFunctionOpen(StageFunc.Levy));
    
    
    local nGiftCount = #MsgActivityMix.GetGiftBackLists();
    if(nGiftCount <= 0) then
        btnGift:SetVisible(false);
    else
        btnGift:SetVisible(true);
    end
    
    btnArena:SetVisible(IsFunctionOpen(StageFunc.Arena));
    btnFete:SetVisible(IsFunctionOpen(StageFunc.Fete));
    
    local type = MsgPlayerAction.PLAYER_ACTION_TYPE.CHECK_IN;
    btnSign:SetVisible(MsgPlayerAction.IsActionOpen(type));
    btnRecharge:SetVisible(MsgPlayerAction.IsActionOpen(MsgPlayerAction.RechargeRewardActionType));
    
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_STAGE));
 
    type = MsgPlayerAction.PLAYER_ACTION_TYPE.ON_LINE;
    local bShow = OnlineCheckIn.IsFunctionOpen()  and  MsgPlayerAction.IsActionOpen(type);
	btnOL:SetVisible(bShow);
    
    btnDailyAct:SetVisible(true);
    p.AdjustToolPos();
    
end

--调整位置
function p.AdjustToolPos()
    local topBarLayer = p.GetTopBar();
    local btnArena = GetButton(topBarLayer,TOOL_BTN[1].Tag);
    local btnLevy = GetButton(topBarLayer,TOOL_BTN[2].Tag);
    local btnFete = GetButton(topBarLayer,TOOL_BTN[3].Tag); 
    local btnGift = GetButton(topBarLayer,TOOL_BTN[4].Tag);
    local btnSign = GetButton(topBarLayer,TOOL_BTN[5].Tag);
    local btnRecharge = GetButton(topBarLayer,TOOL_BTN[6].Tag);
    local btnOL = GetButton(topBarLayer,TOOL_BTN[7].Tag);
    local btnDailyAct = GetButton(topBarLayer,TOOL_BTN[8].Tag);
    local btnRankList = GetButton(topBarLayer,TOOL_BTN[9].Tag);
    btnRankList:SetVisible(false);
    
    
    local btns = {};
    if(btnArena:IsVisibled()) then
        table.insert(btns,btnArena);
    end
    if(btnLevy:IsVisibled()) then
        table.insert(btns,btnLevy);
    end
    if(btnFete:IsVisibled()) then
        table.insert(btns,btnFete);
    end
    if(btnGift:IsVisibled()) then
        table.insert(btns,btnGift);
    end
    
    if(btnSign:IsVisibled()) then
        table.insert(btns, btnSign);
    end
    
    if(btnRecharge:IsVisibled()) then
        table.insert(btns, btnRecharge);
    end
 
    if(btnOL:IsVisibled()) then
        table.insert(btns, btnOL);
    end
    
     if(btnDailyAct:IsVisibled()) then
        table.insert(btns, btnDailyAct);
    end   
       
    for i,v in ipairs(btns) do
        local rect = TOOL_BTN[i].Rect;
        LogInfo("x:[%d],y:[%d],w:[%d],h:[%d]",rect.origin.x,rect.origin.y,rect.size.w,rect.size.h);
        v:SetFrameRect(rect);
    end
end

--获取背景层
function p.GetTopBar()
	local scene = GetSMGameScene();	
	local layer =  RecursiveUILayer(scene,{NMAINSCENECHILDTAG.MainUITop})
	return layer;

end

--数据刷新
function p.GameDataUserInfoRefresh()
	if not IsUIShow(NMAINSCENECHILDTAG.MainUITop) then
		return;
	end
	p.RefreshUserInfo();
	
end

--追踪主线任务
function p.TrackMainTask()
	--TaskUI.NavigateNpc(20006);
	
	--有主线则自动寻路
	local nTaskid = TASK.GetMainTaskId(); 
	if nTaskid ~= nil then
		TASK.TrackTask(nTaskid);
		LogInfo("TrackMainTask nTaskid:"..nTaskid)
		return;
	end
	
	--无主线则追踪下一个主线任务
	local nTaskid = TASK.GetNextMainTaskId(); 
	if nTaskid ~= nil then
		local nNpcId = TASK.GetTaskStartNpcId(nTaskid);
		TaskUI.NavigateNpc(nNpcId);		
		LogInfo("TrackNextMainTask nTaskid:"..nTaskid)
		return;
	end
	--]]
end

--刷新主线任务提示图片
function p.RefreshTaskPic()
	LogInfo("RefreshTaskPic 1")
	local layer = p.GetTopBar() ;
	local pool = DefaultPicPool();
	local TipBtn = GetButton(layer, ID_MAINUI_BUTTON_MISSION);
	local BattleBtn = GetButton(layer, ID_MAINUI_BUTTON_MISSION2);
	local tipLable =  RecursiveLabel(layer,{60});
	local tipimg = GetButton(layer, 37);
	--tipLable:SetText("");
	
	local nTaskid = TASK.GetMainTaskId(); 
    -----======有主线======------	
    if nTaskid ~= nil then
    		LogInfo("RefreshTaskPic 1 有主线"..nTaskid)
		--获取任务目标类型
		local nContenType,nVal  =	TASK.GetNextTaskTargetType(nTaskid);
		if nContenType == nil then
			return;
		end
		
		--根据类型刷新图片
		if nContenType == TASK.SM_TASK_CONTENT_TYPE.NPC then
			local nNpcId = nVal;
			--local Pic = NPC.GetNpcPotraitPic(nNpcId);
			local Pic = GetNpcTaskPic(nNpcId);
			
			
			TipBtn:SetImage(Pic,true);		
			local PicDown =  GetNpcTaskPic(nNpcId);
			TipBtn:SetTouchDownImage(PicDown,true);			
			TipBtn:SetVisible(true);
			tipimg:SetVisible(false);
			BattleBtn:SetVisible(false);
			tipLable:SetText("");
						
		elseif 	nContenType == TASK.SM_TASK_CONTENT_TYPE.ITEM or nContenType == TASK.SM_TASK_CONTENT_TYPE.MONSTER then
			local nMapid = nVal;
			local Pic = GetMapPic(nMapid);
			BattleBtn:SetImage(Pic,true);
			
			local PicDown = GetMapPic(nMapid);
			BattleBtn:SetTouchDownImage(PicDown,true);	
			BattleBtn:SetVisible(true);
			tipimg:SetVisible(false);
			TipBtn:SetVisible(false);
			tipLable:SetText("");
			--]]
		end
		return;
	end

	local nTaskid = TASK.GetNextMainTaskId(); 
	
	--=======有主线,但是还没接======------		
	if nTaskid ~= nil then
		LogInfo("RefreshTaskPic 1 有主线,但是还没接")
		--获取下一主线发布npc图片
		local nNpcId = TASK.GetTaskStartNpcId(nTaskid);
		local Pic = GetNpcTaskPic(nNpcId)--NPC.GetNpcPotraitPic(nNpcId);
		local PicDown =  GetNpcTaskPic(nNpcId)--NPC.GetNpcPotraitPic(nNpcId);
		--刷新图片
		TipBtn:SetImage(Pic,true);
		TipBtn:SetTouchDownImage(PicDown,true);	
		TipBtn:SetVisible(true);
		BattleBtn:SetVisible(false);
		tipLable:SetText("");
		tipimg:SetVisible(false);
		return;
	end
	
	
	--未达到等级要求 不显示图片 显示tip
	LogInfo("RefreshTaskPic 1 未达到等级要求")
	TipBtn:SetVisible(false);	
	if MsgPlayerTask.GetDataReady() == true then
		tipimg:SetVisible(true);

		--CommonDlgNew.ShowTipsDlg("升级到"..nLev.."级可接任务。征战副本可提升等级");
		--tipLable:SetText("升级到"..nLev.."级可接任务。\n征战副本可提升等级");
	else
		tipimg:SetVisible(false);
	end	
end

-- 获得新邮件提示按钮控件指针
function p.GetNewEmailButton()
    local scene = GetSMGameScene();
	if scene == nil then
		LogInfo("TopBar: GetNewEmailButton() scene == nil");
		return nil;
	end
    local layer = GetUiLayer( scene, NMAINSCENECHILDTAG.MainUITop );
	if layer == nil then
		LogInfo("TopBar: GetNewEmailButton() layer == nil");
		return nil;
	end
    local pBtnNewEmail = GetButton( layer, ID_MAINUI_BTN_NEW_EMAIL );
    return pBtnNewEmail;
end

-- 获得buff按钮
function p.GetBuffButton()
    local scene = GetSMGameScene();
	if scene == nil then
		LogInfo("TopBar: GetNewEmailButton() scene == nil");
		return nil;
	end
    local layer = GetUiLayer( scene, NMAINSCENECHILDTAG.MainUITop );
	if layer == nil then
		LogInfo("TopBar: GetNewEmailButton() layer == nil");
		return nil;
	end
    local pBtnBuff = GetButton( layer, 44 );
    return pBtnBuff;
end

--============定时刷新任务引导图片============----------


--设定定时器
function p.SetTimerShowTrackTip()	
	
	--if ( p.nTimerID == nil ) then
	--	p.nTimerID = RegisterTimer( p.OnTimerCoutDownCounter, 2 );
	--end
	
    return true;
end

--获取界面层
function p.OnTimerCoutDownCounter( nTimerID )
	if not IsUIShow(NMAINSCENECHILDTAG.MainUITop) then
		return;
	end
	
	p.RefreshTaskPic();
end


RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "MainUI.LoadUI", p.LoadUI);


