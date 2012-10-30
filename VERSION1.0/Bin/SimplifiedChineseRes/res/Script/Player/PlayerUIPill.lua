---------------------------------------------------
--描述: 玩家丹药界面
--时间: 2012.4.11
--作者: xxj
---------------------------------------------------

PlayerUIPill = {}
local p = PlayerUIPill;

--背景 tag
local ID_PILL_CTRL_PICTURE_LIST_M					= 263;
local ID_PILL_CTRL_BUTTON_MAGIC				= 765;
local ID_PILL_CTRL_BUTTON_SKILL				= 764;
local ID_PILL_CTRL_BUTTON_FIGHT				= 763;
local ID_PILL_CTRL_BUTTON_CLOSE				= 756;
local ID_PILL_CTRL_TEXT_755					= 755;
local ID_PILL_CTRL_PICTURE_754				= 754;

-- 丹药进度tag
local ID_PILL_M_CTRL_PICTURE_55					= 55;
local ID_PILL_M_CTRL_PICTURE_54					= 54;
local ID_PILL_M_CTRL_PICTURE_53					= 53;
local ID_PILL_M_CTRL_PICTURE_52					= 52;
local ID_PILL_M_CTRL_PICTURE_51					= 51;
local ID_PILL_M_CTRL_PICTURE_50					= 50;
local ID_PILL_M_CTRL_TEXT_PROGRESS				= 796;
local ID_PILL_M_CTRL_TEXT_795					= 795;
local ID_PILL_M_CTRL_TEXT_FIGHT					= 794;
local ID_PILL_M_CTRL_TEXT_793					= 793;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_27			= 792;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_26			= 791;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_25			= 790;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_24			= 789;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_23			= 788;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_22			= 787;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_20			= 786;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_19			= 785;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_18			= 784;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_17			= 783;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_16			= 782;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_14			= 781;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_13			= 780;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_12			= 779;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_11			= 778;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_9			= 777;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_8			= 776;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_7			= 775;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_5			= 774;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_4			= 773;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_2			= 772;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_21			= 762;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_15			= 761;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_10			= 760;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_6			= 759;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_3			= 758;
local ID_PILL_M_CTRL_OBJECT_BUTTON_M_1		    = 757;

-- 界面控件tag定义
local ScrollTag = 1;                        --滚动层配置
local TAG_PILL_INFO = 997;                  --丹药信息tag
local TAG_PILL_BACK = 998;					--背景tag
local TAG_PILL_PROGRESS = 999;				--丹药进度tag            
-- 宠物id
p.nPetId = 0;
--丹药类型
local PILL_TYPE_CORCE  = 1;
local PILL_TYPE_STUN   = 2;
local PILL_TYPE_SPELLS = 3;
p.pillType = 0;
--自定义数据
local margin = 5 * ScaleFactor;
local labelWidth = RectUILayer.size.w / 3;
local x = labelWidth - 40 * ScaleFactor - margin;
local w = 40 * ScaleFactor;	
local pillInfoContainX = 250 * ScaleFactor;
local pillInfoContainY = 30 * ScaleFactor;
local addIconFileName = "icon_role.png";
local labelText = {"武力","绝技","法术"};
local useLevel= 0;

local phyElixir = 
{
  PET_ATTR.PET_ATTR_PHY_ELIXIR1,
  PET_ATTR.PET_ATTR_PHY_ELIXIR2,
  PET_ATTR.PET_ATTR_PHY_ELIXIR3,
  PET_ATTR.PET_ATTR_PHY_ELIXIR4,
  PET_ATTR.PET_ATTR_PHY_ELIXIR5,
  PET_ATTR.PET_ATTR_PHY_ELIXIR6
};
local skillElixir = 
{
  PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR1,
  PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR2,
  PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR3,
  PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR4,
  PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR5,
  PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR6
};
local magicElixir = 
{
  PET_ATTR.PET_ATTR_MAGIC_ELIXIR1,
  PET_ATTR.PET_ATTR_MAGIC_ELIXIR2,
  PET_ATTR.PET_ATTR_MAGIC_ELIXIR3,
  PET_ATTR.PET_ATTR_MAGIC_ELIXIR4,
  PET_ATTR.PET_ATTR_MAGIC_ELIXIR5,
  PET_ATTR.PET_ATTR_MAGIC_ELIXIR6
};
local elixir = {phyElixir,skillElixir,magicElixir};

local itemButtonTag1 = 
{
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_1,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_2
};
local itemButtonTag2 = 
{
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_3,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_4,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_5
};
local itemButtonTag3 = 
{
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_6,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_7,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_8,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_9
};
local itemButtonTag4 = 
{
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_10,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_11,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_12,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_13,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_14  
};
local itemButtonTag5 = 
{
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_15,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_16,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_17,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_18,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_19, 
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_20
};
local itemButtonTag6 = 
{
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_21,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_22,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_23,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_24,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_25, 
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_26,
  ID_PILL_M_CTRL_OBJECT_BUTTON_M_27  
};
local itemButtonTag = 
{
  itemButtonTag1,
  itemButtonTag2,
  itemButtonTag3,
  itemButtonTag4,
  itemButtonTag5,
  itemButtonTag6,
};

local itemButtonValue1 =
{
  0,0
}

local itemButtonValue2 =
{
  0,0,0
}

local itemButtonValue3 =
{
  0,0,0,0
}

local itemButtonValue4 =
{
  0,0,0,0,0
}

local itemButtonValue5 =
{
  0,0,0,0,0,0
}

local itemButtonValue6 =
{
  0,0,0,0,0,0,0
}
local itemButtonValue = 
{
  itemButtonValue1,
  itemButtonValue2,
  itemButtonValue3,
  itemButtonValue4,
  itemButtonValue5,
  itemButtonValue6,
};

local useEmoney = {30,150,300,630,1230,2400};

function p.LoadUI(nPetId)
    LogInfo("PlayerUIPill.LoadUI(%d)",nPetId);
	p.nPetId = nPetId;
	p.pillType = PILL_TYPE_CORCE;
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load PlayerUIaPill failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerUIPill);
	layer:SetFrameRect(RectUILayer);
	scene:AddChild(layer);	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
	  layer:Free();
	  return false;
	end
	
	local layerPillBack = createUIScrollContainer();
	if not CheckP(layerPillBack) then
	  layer:Free();
	  return false;
	end
	layerPillBack:Init();
	layerPillBack:SetTag(TAG_PILL_BACK);
	layerPillBack:SetFrameRect(CGRectMake(0,0, RectUILayer.size.w, RectUILayer.size.h));
	layer:AddChild(layerPillBack);
	uiLoad:Load("Pill.ini",layerPillBack, p.OnMainUIEvent, 0, 0);	
	
	p.RefreshPillUi();
	
	uiLoad:Free();	
	return true;
end

function ClosePillInfo()
  local scene = GetSMGameScene();
  if CheckP(scene) then
    local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.PlayerUIPill);
	if CheckP(layer) then
	   local pillInfoContain = GetUiLayer(layer,TAG_PILL_INFO);
	   if CheckP(pillInfoContain) then
		 layer:RemoveChildByTag(TAG_PILL_INFO, true);
	   end
	end
  end
end

function ShowPillInfo(itemtype,itemValue)
  local scene = GetSMGameScene();
  if CheckP(scene) then
    local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.PlayerUIPill);
	if CheckP(layer) then
	  local pillInfoContain = createUIScrollContainer(); 
	  if CheckP(pillInfoContain) then
		pillInfoContain:Init();
	    pillInfoContain:SetTag(TAG_PILL_INFO);			
		local nResHeight = margin;				
		local itemName = "<c00ff00" .. ItemFunc.GetName(itemtype).."/e";

		local itemValueDec = "<cEB6100"..labelText[p.pillType].."+"..itemValue.."/e";
		local itemDesc = ItemFunc.GetDesc(itemtype);
		
		local itemBtn = createUIItemButton();		
	    if CheckP(itemBtn) then
		  itemBtn:Init();
		  itemBtn:SetFrameRect(CGRectMake(x, margin, w, w));
		  itemBtn:ChangeItemType(itemtype);
		  pillInfoContain:AddChild(itemBtn);
	    end
		
		local fontSize = 12;
		ItemUI.AddColorLabel(pillInfoContain, itemName, fontSize,margin,nResHeight, labelWidth);
		local size = GetHyperLinkTextSize(itemName,fontSize,labelWidth);
	    nResHeight = nResHeight + size.h;
		
		fontSize = 10;
		ItemUI.AddColorLabel(pillInfoContain, itemValueDec, fontSize,margin,nResHeight, labelWidth);
		local size = GetHyperLinkTextSize(itemValueDec,fontSize,labelWidth);
	    nResHeight = nResHeight + size.h;
		
		if nResHeight < (margin + w) then
		  nResHeight = (margin + w);
		end
		
		fontSize = 10;
		ItemUI.AddColorLabel(pillInfoContain, itemDesc, fontSize,margin,nResHeight, labelWidth);
		local size = GetHyperLinkTextSize(itemDesc,fontSize,labelWidth);
	    nResHeight = nResHeight + size.h;
		
		nResHeight = nResHeight + margin;
		
	    pillInfoContain:SetFrameRect(CGRectMake(pillInfoContainX,pillInfoContainY,labelWidth,nResHeight));  
		local pool = DefaultPicPool();
	    if CheckP(pool) then
	      local pic = pool:AddPictureEx(GetSMImgPath("bg/bg_ver_black.png"), labelWidth, nResHeight, false); 
		  if CheckP(pic) then
	        pillInfoContain:SetBackgroundImage(pic);
          end
	    end
	    layer:AddChild(pillInfoContain);
	  end
	end
  end
end

function p.ChangePillType(pillType)
  p.pillType = pillType; 
  p.RefreshPillUi(); 
end

function p.RefreshPillUi() 
  LogInfo("p.RefreshPillUi()");
  local scene = GetSMGameScene();	
  if CheckP(scene) then
    local pillContainer = RecursiveUINode(scene,{NMAINSCENECHILDTAG.PlayerUIPill,TAG_PILL_BACK,ID_PILL_CTRL_PICTURE_LIST_M});
	if CheckP(pillContainer) then
	  pillContainer:RemoveAllChildren(true);
	  local pillProgressLayer = createNDUILayer();
	  if CheckP(pillProgressLayer) then
		pillProgressLayer:Init();
	    pillProgressLayer:SetTag(TAG_PILL_PROGRESS);
	    pillProgressLayer:SetFrameRect(CGRectMake(0,0, RectUILayer.size.w, RectUILayer.size.h));
	    pillContainer:AddChild(pillProgressLayer);			
		local uiLoad = createNDUILoad();
	    if CheckP(uiLoad) then
	      uiLoad:Load("Pill_M.ini",pillProgressLayer, p.OnPillItemUIEvent, 0, 0);
		  refreshPillProgress(pillProgressLayer);
		  uiLoad:Free();
	    end
	  end
	end
  end
end

function refreshPillProgress(pillProgressLayer)
  local pillTypeLabel = GetLabel(pillProgressLayer,ID_PILL_M_CTRL_TEXT_793);
  if CheckP(pillTypeLabel) then
    pillTypeLabel:SetText(labelText[p.pillType]);
  end
  
  local elixirValue = 0;
  local curElixir = elixir[p.pillType];
  for i, v in ipairs(curElixir) do
    local nElixir = RolePet.GetPetInfoN(p.nPetId,v);
	local curElixirValue = 5 * (i + 1);
	for j = 1,(i+1) do 
	  local itemtype = 22000000+ p.pillType * 100000 + i;
	  local itemBtn = GetItemButton(pillProgressLayer,itemButtonTag[i][j]);
	  itemBtn:SetShowAdapt(true);
	  if nElixir >= j then
	    itemBtn:ChangeItemType(itemtype);
		elixirValue = elixirValue + curElixirValue;
		itemButtonValue[i][j] = curElixirValue;
		curElixirValue = curElixirValue - 5;	 
	  else
		local pic = EmailList.GetPicByFileName(addIconFileName);
		if CheckP(pic) then
		   itemBtn:SetImage(pic);
		   local itemCount = ItemFunc.GetItemCount(itemtype) + ItemFunc.GetStorageItemCount(itemtype);
		   itemButtonValue[i][j] = itemCount;
		   if itemCount > 0 then
			 local itemBtnRect = itemBtn:GetFrameRect();
			 local amountLabelRect = CGRectMake(0,itemBtnRect.size.h-14*ScaleFactor,itemBtnRect.size.w,14*ScaleFactor);
			 local amountLabel = CreateLabel(tostring(itemCount),amountLabelRect, 12, ccc4(255,255,255, 255));
			 amountLabel:SetTextAlignment(UITextAlignment.Right);
			 itemBtn:AddChild(amountLabel);
		   end
		end
	    break;
	  end
	end
  end
  
  local elixirValueLabel = GetLabel(pillProgressLayer,ID_PILL_M_CTRL_TEXT_FIGHT);
  if CheckP(elixirValueLabel) then
    elixirValueLabel:SetText("+"..elixirValue);
  end
  
  local elixirProgressLabel = GetLabel(pillProgressLayer,ID_PILL_M_CTRL_TEXT_PROGRESS);
  if CheckP(elixirProgressLabel) then
    elixirProgressLabel:SetText(getIntPart(elixirValue * 100 / 415).."%");
  end
  
end

function p.OnMainUIEvent(uiNode, uiEventType, param)
   local tag = uiNode:GetTag();
   LogInfo("p.OnMainUIEvent[%d]", tag);
   if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
     if tag == ID_PILL_CTRL_BUTTON_CLOSE then
	   CloseUI(NMAINSCENECHILDTAG.PlayerUIPill);
	   return true;	   
	 elseif tag == ID_PILL_CTRL_BUTTON_FIGHT then  
	   ClosePillInfo();
	   p.ChangePillType(PILL_TYPE_CORCE);
	   return true;	   
	 elseif tag == ID_PILL_CTRL_BUTTON_SKILL then 
	   ClosePillInfo();
	   p.ChangePillType(PILL_TYPE_STUN);
	   return true;
	 elseif tag == ID_PILL_CTRL_BUTTON_MAGIC then 
	   ClosePillInfo();
	   p.ChangePillType(PILL_TYPE_SPELLS);
	   return true;
	 end
   end  
   return true; 
end

function p.OnPillItemUIEvent(uiNode, uiEventType, param)
   local tag = uiNode:GetTag();
   LogInfo("p.OnPillItemUIEvent[%d]", tag);
   if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
     local itemBtn = ConverToItemButton(uiNode);
	 if CheckP(itemBtn) then
	   local itemtype = itemBtn:GetItemType();
	   local i,j = GetTagPosition(tag);
	   local itemValue = itemButtonValue[i][j];
	   ClosePillInfo();
	   if itemtype ~= 0 then
		 ShowPillInfo(itemtype,itemValue); 
	   elseif CheckP(itemBtn:GetImage()) then	
	     itemtype = 22000000+ p.pillType * 100000 + i;
		 if itemValue > 0 then
		   MsgUsePill.SendUsePill(p.nPetId,p.pillType-1,i-1,ItemUI.GetItemID(itemtype));
		 else
		   local itemName = ItemFunc.GetName(itemtype);
		   local addValue = 5 * (i + 1)-(j-1) * 5;
		   useLevel = i;
		   CommonDlg.ShowNoPrompt("花费"..useEmoney[i].."金币让角色第"..j.."次服用"..itemName..","..labelText[p.pillType].."+"..addValue, p.OnCommonDlg,true);
		 end
	   end
	 end
   end  
   return true; 
end

function p.OnCommonDlg(nId, nEvent, param)
  if nEvent == CommonDlg.EventOK then
    MsgUsePill.SendUsePill(p.nPetId,p.pillType-1,useLevel-1,0);
  end
end

function GetTagPosition(tag)
  for i, v in ipairs(itemButtonTag) do
    for j, v1 in ipairs(v) do
	  if v1 == tag then
		 return i,j;
	  end
	end
  end
  return 0,0;
end
