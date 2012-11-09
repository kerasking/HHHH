---------------------------------------------------
--描述: 聊天物品界面
--时间: 2012.4.20
--作者: cl

---------------------------------------------------
local _G = _G;

ChatItemUI={}
local p=ChatItemUI;
local winsize	= GetWinSize();

local bagID1	=1001;

local ID_ITEM_FIRST=1;

p.currentInputTarget=ChatInputTarget.main_input;

local containter;
function p.LoadUI(target)
	p.currentInputTarget=target;
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load chatui failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ChatItemUI);
	layer:SetFrameRect(CGRectMake(0, winsize.h*0.52, winsize.w, winsize.h*0.48));
	layer:SetBackgroundColor(ccc4(0,0,0,180));
	scene:AddChild(layer);
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.ChatItemUI);

	container = createUIScrollViewContainer();
	--local containter = GetScrollViewContainer(layer,ID_ROLEINVITE_CTRL_LIST_M);
	if (nil == container) then
		layer:Free();
		LogInfo("scene = nil,3");
		return false;
	end
	container:Init();
	container:SetStyle(UIScrollStyle.Horzontal);
	container:SetFrameRect(CGRectMake(0,0, winsize.w, winsize.h*0.48));
	container:SetViewSize(CGSizeMake(winsize.w, container:GetFrameRect().size.h));
	--container:SetLeftReserveDistance(winsize.w);
	--container:SetRightReserveDistance(winsize.w);
	layer:AddChild(container);
	
	p.LoadItem();
end

function p.OnItemUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag>=1 and
			tag<=24 then
			
			local button=ConverToItemButton(uiNode);
			if CheckP(button) then
				if button:GetItemId()==0 then
					return true;
				end
			end
			
			local view=PRecursiveSV(uiNode, 1);
			if not CheckP(view) then
				return true;
			end
			local id=view:GetViewId();
			local index=tag+(id-bagID1)*24;
			
			local str="<b";
			if index<10 then
				str=str.."0"..SafeN2S(index);
			else
				str=str..SafeN2S(index);
			end
			
			if p.currentInputTarget==ChatInputTarget.main_input then
				ChatMainUI.AppendText(str);
			elseif p.currentInputTarget==ChatInputTarget.private_input then
				ChatPrivateUI.AppendText(str);
			end

		end
	end
	return true;
end

function p.LoadItem()
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local idlist	= ItemUser.GetBagItemList(nPlayerId);
	if not CheckT(idlist) then
		LogInfo("no item");
		return false;
	end
	
	local count=table.getn(idlist);

	local bag1 = createUIScrollView();
	if bag1 == nil then
		--LogInfo("view == nil");
		return;
	end
	bag1:Init(false);
	container:AddView(bag1);
	bag1:SetViewId(bagID1);
	local uiLoad = createNDUILoad();
	if uiLoad ~= nil then
		uiLoad:Load("SM_LT_Chat_item.ini",bag1,p.OnItemUIEvent,0,0);
		uiLoad:Free();
	end
	
	local bag2 = createUIScrollView();
	if bag2 == nil then
		--LogInfo("bag2 == nil");
		return;
	end
	bag2:Init(false);
	container:AddView(bag2);
	bag2:SetViewId(bagID1+1);
	local uiLoad = createNDUILoad();
	if uiLoad ~= nil then
		uiLoad:Load("SM_LT_Chat_item.ini",bag2,p.OnItemUIEvent,0,0);
		uiLoad:Free();
	end
	
	for i, v in ipairs(idlist) do
		LogInfo("item:%d,%d",i,v);
		if i<=24 then
			local button= GetItemButton(bag1,ID_ITEM_FIRST+i-1);
			if CheckP(button) then
				button:ChangeItem(v);
			else
				LogInfo("no itembutton");
			end
		else
			local button= GetItemButton(bag2,ID_ITEM_FIRST+i-1);
			if CheckP(button) then
				button:ChangeItem(v);
			else
				LogInfo("no itembutton");
			end
		end
	end

end