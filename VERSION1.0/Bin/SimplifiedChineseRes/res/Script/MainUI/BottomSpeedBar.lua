---------------------------------------------------
--描述: 主界面底部快捷栏
--时间: 2012.2.13
--作者: jhzheng
---------------------------------------------------

MainUIBottomSpeedBar = {}
local p = MainUIBottomSpeedBar;

--UI坐标配置
local winsize	= GetWinSize();
local btnnum	= 6;
p.Width			= winsize.w;
p.Height		= winsize.h * 0.125;
p.Rect			= CGRectMake(0, winsize.h - p.Height, p.Width, p.Height);
p.Btninner		= 0;--winsize.w * (0.01);
p.BtnWidth		= p.Height;--(p.Width - (btnnum + 1) * p.Btninner) / btnnum;
p.BtnY			= p.Height * (0.1);
p.BtnHeight		= p.Height - p.BtnY * 2;

--滚动层配置
p.ScrollTag = 1;
--按钮配置
p.BtnTag = 
{
	101,
	102,
	103,
	104,
	105,
	106,
	107,
	108,
	--109,
	--110,
	111,
	112,
	113,
	114,
	115,
};

p.BtnText = 
{
	"人物",
	"背包",
	"任务",
	"客栈",
	"奇术",
	"布阵",
	"封灵",
	"聊天",
	--"悟道",
	--"副本",
	"离开",
	"强化",
	"新聊",
	"好友",
	"练功",
};

p.BtnFile = 
{
	"icon_role.png",		-- 人物
	"icon_bag.png",			-- 背包
	"icon_task.png",		-- 任务
	"icon_hotel.png",		-- 客栈
	"icon_magic.png",		-- 奇术
	"icon_lineup.png",		-- 布阵
	"icon_seal.png",		-- 封灵
};


function p.LoadUI()
	local scene = GetSMGameScene();
	if scene == nil then
		PrintString("scene == nil");
		return;
	end
	
	local container = createUIScrollContainer();
	if container == nil then
		PrintString("container == nil");
		return;
	end
	
	local rectX = 0;
	local rectW = (p.BtnWidth + p.Btninner) * 13;
	if rectW < winsize.w then
		rectX = winsize.w - rectW;
	else
		rectW	= winsize.w;
	end
	local rect  = CGRectMake(rectX, winsize.h - p.Height, rectW, p.Height); 
	container:Init();
	container:SetTag(NMAINSCENECHILDTAG.BottomSpeedBar);
	container:SetFrameRect(rect);
	container:SetLeftReserveDistance(rect.size.w);
	container:SetRightReserveDistance((p.BtnWidth + p.Btninner) * 2.5);
	scene:AddChild(container);

	local btnnum = 13;
	local scrollrect = CGRectMake(0.0, 0.0, (p.BtnWidth + p.Btninner) * btnnum, p.Height);
	local scroll = createUIScroll();
	if (scroll == nil) then
		LogInfo("scroll == nil,load BottomSpeedBar failed!");
		container:RemoveFromParent(true);
		return;
	end
	
	scroll:Init(true);
	scroll:SetFrameRect(scrollrect);
	scroll:SetScrollStyle(UIScrollStyle.Horzontal);
	scroll:SetTag(p.ScrollTag);
	--scroll:SetBackgroundColor(ccc4(125, 125, 125, 125));
	scroll:SetMovableViewer(container);
	scroll:SetContainer(container);
	container:AddChild(scroll);
	
	local nIconFiles = 7;
	local pool = DefaultPicPool();
	local v = 1;
	local i = 1;
	
	while i <= 13 do
	
	local btn = createNDUIButton();
		if btn == nil then
			LogInfo("btn[%d] == nil,load BottomSpeedBar failed!", i);
			container:RemoveFromParent(true);
			break;
		end
		btn:Init();
		local rect = CGRectMake(i * p.Btninner + (i - 1) * p.BtnWidth, p.BtnY, p.BtnWidth, p.BtnHeight);
		btn:SetFrameRect(rect);
		btn:SetTag(v);
		btn:CloseFrame();
		if i <= nIconFiles then

		else

			btn:SetTitle("Temp");
			
			local temp = GetImgPathNew("bag_btn_normal.png");
			
			btn:SetBackgroundPicture(pool:AddPicture(temp, false),
									pool:AddPicture(temp, false),
									false, RectZero(), true);

		end
		btn:SetLuaDelegate(p.OnUIEvent);
		scroll:AddChild(btn);
	
		v = v + 1;
		i = i + 1;
	end
	
	return;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if CloseMainUI() then
			return true;
		end
		if p.BtnTag[1] == tag then
			-- 玩家属性
			if not IsUIShow(NMAINSCENECHILDTAG.PlayerAttr) then
				CloseMainUI();
				PlayerUIAttr.LoadUI();
			end
		elseif p.BtnTag[2] == tag then
			--背包
			if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
				CloseMainUI();
				PlayerUIBackBag.LoadUI();
			end
		elseif p.BtnTag[3] == tag then
			--任务
			if not IsUIShow(NMAINSCENECHILDTAG.PlayerTask) then
				CloseMainUI();
				TaskUI.LoadUI();
			end
		elseif p.BtnTag[4] == tag then
			-- quitgame
			--QuitGame();
			--客栈
			if not IsUIShow(NMAINSCENECHILDTAG.RoleInvite) then
				CloseMainUI();
				RoleInvite.LoadUI();
				--DynMapGuide.LoadUI();
				--ArenaRewardUI.LoadUI();
			end
		elseif p.BtnTag[5] == tag then
			--奇术
			if not IsUIShow(NMAINSCENECHILDTAG.PlayerMagic) then
				CloseMainUI();
				MagicUI.LoadUI();
				return true;
			end
		elseif p.BtnTag[6] == tag then
			--布阵
			if not IsUIShow(NMAINSCENECHILDTAG.PlayerMartial) then
				CloseMainUI();
				MartialUI.LoadUI();
				return true;
			end
		elseif p.BtnTag[7] == tag then
			if not IsUIShow(NMAINSCENECHILDTAG.PlayerNimbusUI) then
				CloseMainUI();
				PlayerNimbusUI.LoadUI();
			end	
		elseif p.BtnTag[8] == tag then
			ShowChat();
		--[[
		elseif p.BtnTag[9] == tag then
			if not IsUIShow(NMAINSCENECHILDTAG.PlayerRealize) then
				CloseMainUI();
				RealizeUI.LoadUI();
			end
		elseif p.BtnTag[10] == tag then
			--CloseMainUI();
			--RoleTrainUI.LoadUI();
			if not IsUIShow(NMAINSCENECHILDTAG.AffixNormalBoss) then
				NormalBossListUI.LoadUI();
			end
		--]]
		elseif p.BtnTag[9] == tag then
			-- 回主界面
			--AffixBossFunc.findNpcByBossId(5);
			QuitGame();
		elseif p.BtnTag[10] == tag then
			-- 装备强化
		    if not IsUIShow(NMAINSCENECHILDTAG.EquipStr) then
				CloseMainUI();
				EquipStrUI.LoadUI();
			end	
		elseif p.BtnTag[11] == tag then
			if not IsUIShow(NMAINSCENECHILDTAG.ChatMainUI) then
				CloseMainUI();
				ChatMainUI.LoadUI();
			end		
		elseif p.BtnTag[12] == tag then	
			if not IsUIShow(NMAINSCENECHILDTAG.Friend) then
				CloseMainUI();
				MsgFriend.SendOpenFriend();
			end	
		elseif p.BtnTag[13] == tag then	
			--练功
			MainUIPractise.Practise();
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

RegisterGlobalEventHandler(100, "MainUIBottomSpeedBar.LoadUI", p.LoadUI);