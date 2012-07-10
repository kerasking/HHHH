---------------------------------------------------
--描述: 主界面右上部快捷栏
--时间: 2012.3.22
--作者: cl
---------------------------------------------------

TopActivitySpeedBar = {}
local p = TopActivitySpeedBar;

--UI坐标配置
local winsize	= GetWinSize();
local btnnum	= 2;
p.Width			= winsize.w;
p.Height		= winsize.h * 0.125;
p.Rect			= CGRectMake(0, p.Height, p.Width, p.Height);
p.Btninner		= 0;--winsize.w * (0.01);
p.BtnWidth		= p.Height;--(p.Width - (btnnum + 1) * p.Btninner) / btnnum;
p.BtnY			= p.Height * (0.1);
p.BtnHeight		= p.Height - p.BtnY * 2;

local ARENA_INDEX=1;
local ACTIVITY_INDEX=2;
local DAILY_INDEX=3;

local GiftTag_beginId=1000;

local ARENA_GIFT=0;
local LEVEL_GIFT=1;
local WORLD_BOSS_GIFT=2;
local GROUP_BOSS_GIFT=3;

p.gift_info={};

--滚动层配置
p.ScrollTag = 1;
local scroll;
--按钮配置
p.BtnTag = 
{
	101,
	102,
	--103,
	--104,
	--105,
	--106,
	--107,
	--108,
	--109,
	--110,
};

p.BtnText = 
{
	"竞技场",
	"活动",
	--"日常",

};

local giftFile = "btn_gift.png";

p.BtnFile = 
{
	"icon_arena.png",		-- 竞技场

};

function p.ShowGiftDialog(gift,index)
	if index==1 then
		local tip="你在竞技场排名"..SafeN2S(gift[4])..",获得铜钱＋"..SafeN2S(gift[2]);
		CommonDlg.ShowWithConfirm(tip, nill);
	elseif index==2 then
		local tip="你的等级为"..SafeN2S(gift[4])..",获得声望＋"..SafeN2S(gift[2]);
		CommonDlg.ShowWithConfirm(tip, nill);
	elseif index==3 then
		local tip="在世界BOSS击杀中，你排名"..SafeN2S(gift[4])..",获得"..ItemFunc.GetName(gift[2]);
		CommonDlg.ShowWithConfirm(tip, nill);
	elseif index==4 then
		local tip="在帮派BOSS击杀中，你排名"..SafeN2S(gift[4])..",获得"..ItemFunc.GetName(gift[2]);
		CommonDlg.ShowWithConfirm(tip, nill);		
	end
	
end

function p.GetGift(id)

	for i=1,4 do
		local gift = p.gift_info[i];
		if nill == gift then
			continue;
		end
		
		if gift[1] == id then
			p.ShowGiftDialog(gift,i);
			p.gift_info[i] =nil;
			break;
		end
	end
	
	p.CleanScroll();
	p.refreshBtns();
end

function p.AddGift(id,type,param0,param1,aux_param0,aux_param1)
	if type==ARENA_GIFT then
		p.gift_info[1]={id,param0,param1,aux_param0,aux_param1,};
	elseif type==LEVEL_GIFT then
		p.gift_info[2]={id,param0,param1,aux_param0,aux_param1,};
	elseif type==WORLD_BOSS_GIFT then
		p.gift_info[3]={id,param0,param1,aux_param0,aux_param1,};
	elseif type==GROUP_BOSS_GIFT then
		p.gift_info[4]={id,param0,param1,aux_param0,aux_param1,};
	end
	
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = RecursiveScrollContainer(scene, {NMAINSCENECHILDTAG.TopSpeedBar});
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.CleanScroll()
	scroll:RemoveAllChildren(true);
end

function p.refreshBtns()
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local layer=p.GetParent();
	if nil == scroll then
		return;
	end
	
	local pool = DefaultPicPool();
	local n=0;
	for i=1,4 do
		local gift = p.gift_info[i];
		LogInfo("refresh_gift");
		if nill == gift then
			continue;
		end
		LogInfo("gift_exist");
		local btn = createNDUIButton();
		if btn == nil then
			LogInfo("btn[%d] == nil,load ActivitySpeedBar failed!", i);
			container:RemoveFromParent(true);
			break;
		end
		btn:Init();
		local rect = CGRectMake((n+1) * p.Btninner + n * p.BtnWidth, p.BtnY, p.BtnWidth, p.BtnHeight);
		btn:SetFrameRect(rect);
		btn:SetTag(GiftTag_beginId+gift[1]);
		btn:CloseFrame();
		local pic		= pool:AddPicture(GetSMImgPath(giftFile), false);
		local picSize	= pic:GetSize();
		local rect		= CGRectMake((p.BtnWidth - picSize.w) / 2,
									 (p.BtnHeight - picSize.h) / 2,
									  picSize.w, picSize.h );
		btn:SetBackgroundPicture(pic,
								pool:AddPicture(GetSMImgPath(giftFile), false),
								true, rect, true);
		btn:SetLuaDelegate(p.OnUIEvent);
		scroll:AddChild(btn);
		n=n+1;
	end

	local btnnum = table.getn(p.BtnText)+n;

	
	local container = p.GetParent();
	local rectX = 0;
	local rectW	= (p.BtnWidth + p.Btninner) * btnnum;
	if rectW < winsize.w then
		rectX = winsize.w - rectW;
	else
		rectW	= winsize.w;
	end
	local rect  = CGRectMake(rectX, p.Height, rectW, p.Height);
	 
	container:SetFrameRect(rect);
	container:SetLeftReserveDistance(rect.size.w);
	container:SetRightReserveDistance((p.BtnWidth + p.Btninner)* 2.5);
	
	local scrollrect = CGRectMake(0.0, 0.0, (p.BtnWidth + p.Btninner) * btnnum, p.Height);	
	scroll:SetFrameRect(scrollrect);
	
	local stage=GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_STAGE);
	local nIconFiles = table.getn(p.BtnFile);
	LogInfo("gift:%d",n);
	for	i, v in ipairs(p.BtnTag) do
		
		--if i == ARENA_INDEX and stage < 551 then
			--continue;
		--elseif i == DAILY_INDEX and stage< 451 then
			--continue;
		--end
		
		LogInfo("activity_btn%d",i);
		
		local btn = createNDUIButton();
		if btn == nil then
			LogInfo("btn[%d] == nil,load ActivitySpeedBar failed!", i);
			container:RemoveFromParent(true);
			break;
		end
		btn:Init();
		local rect = CGRectMake((i+n) * p.Btninner + (i + n - 1) * p.BtnWidth, p.BtnY, p.BtnWidth, p.BtnHeight);
		btn:SetFrameRect(rect);
		btn:SetTag(v);
		btn:CloseFrame();
		if i <= nIconFiles then
			local pic		= pool:AddPicture(GetSMImgPath(p.BtnFile[i]), false);
			local picSize	= pic:GetSize();
			local rect		= CGRectMake((p.BtnWidth - picSize.w) / 2,
										 (p.BtnHeight - picSize.h) / 2,
										  picSize.w, picSize.h );
			btn:SetBackgroundPicture(pic,
									pool:AddPicture(GetSMImgPath(p.BtnFile[i]), false),
									true, rect, true);
		else
			btn:SetTitle(p.BtnText[i]);
			btn:SetBackgroundPicture(pool:AddPicture(GetImgPathNew("bag_btn_normal.png"), false),
									pool:AddPicture(GetImgPathNew("bag_btn_click.png"), false),
									false, RectZero(), true);
		end
		btn:SetLuaDelegate(p.OnUIEvent);
		scroll:AddChild(btn);
	end
end

function p.LoadUI()
    if table.getn(p.BtnTag) ~= table.getn(p.BtnText) then
		LogInfo("table.getn,load BottomSpeedBar failed!");
		return;
	end
	
	local scene = GetSMGameScene();
	if scene == nil then
		LogInfo("scene == nil,load TopSpeedBarr failed!");
		return;
	end
	
	local container = createUIScrollContainer();
	if container == nil then
		LogInfo("container == nil,load TopSpeedBarr failed!");
		return;
	end
	
	local rectX = 0;
	local rectW	= (p.BtnWidth + p.Btninner) * (table.getn(p.BtnText));
	if rectW < winsize.w then
		rectX = winsize.w - rectW;
	else
		rectW	= winsize.w;
	end
	local rect  = CGRectMake(rectX, p.Height, rectW, p.Height); 
	container:Init();
	container:SetTag(NMAINSCENECHILDTAG.TopSpeedBar);
	container:SetFrameRect(rect);
	container:SetLeftReserveDistance(rect.size.w);
	container:SetRightReserveDistance((p.BtnWidth + p.Btninner)* 2.5);
	scene:AddChild(container);
	
	local btnnum = table.getn(p.BtnText);
	local scrollrect = CGRectMake(0.0, 0.0, (p.BtnWidth + p.Btninner) * btnnum, p.Height);
	scroll = createUIScroll();
	if (scroll == nil) then
		LogInfo("scroll == nil,load ActivitySpeedBar failed!");
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
	
	p.refreshBtns();

end


function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		
		if CloseMainUI() then
			return true;
		end
		
		if p.BtnTag[1] == tag then
			if not IsUIShow(NMAINSCENECHILDTAG.Arena) then
				CloseMainUI();
				_G.MsgArena.SendOpenArena();

			end
		elseif p.BtnTag[2] == tag then
			if not IsUIShow(NMAINSCENECHILDTAG.ActivityMix) then
				CloseMainUI();
				_G.MsgActivityMix.SendOpenDailyActivity();

			end
		end
		
		if tag >= GiftTag_beginId then
			local id=tag-GiftTag_beginId;
			LogInfo("SendGetGift:%d",id);
			_G.MsgActivityMix.SendGetGift(id);
		end
	end
	
	
	
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "TopActivitySpeedBa.LoadUI", p.LoadUI);