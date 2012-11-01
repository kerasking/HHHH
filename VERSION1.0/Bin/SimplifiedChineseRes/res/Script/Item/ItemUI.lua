---------------------------------------------------
--描述: 物品UI
--时间: 2012.3.12
--作者: jhzheng
---------------------------------------------------

ItemUI = {}

local p = ItemUI;

function p.AttachItemInfoByItemType(pUiLayer,nItemType,nWidthLimit)
	local nResHeight		= 0;
	local nStartX			= 5 * ScaleFactor;
	local nQulity			= ItemFunc.GetQuality(nItemType);
	local strName			= "";
	
	--物品名字
	strName=p.GetColoredItemNameByItemType(nItemType);
	
	nResHeight	= nResHeight + 2 * ScaleFactor;
	p.AddColorLabel(pUiLayer, strName, 16, nStartX, nResHeight, nWidthLimit);
	nResHeight	= nResHeight + 20 * ScaleFactor;
	
	
	--物品描述
	local strContent = ItemFunc.GetDesc(nItemType);
	if p.AddColorLabel(pUiLayer, strContent, 12, nStartX, nResHeight, nWidthLimit - 50 * ScaleFactor) then
		local size = GetHyperLinkTextSize(strContent, 12, nWidthLimit-50 * ScaleFactor);
		nResHeight	= nResHeight + size.h + 5 * ScaleFactor;
	end
	
	nResHeight = nResHeight + 5 * ScaleFactor;
	
	return nResHeight;
	
end

function p.AttachItemInfo(pUiLayer, nItemId, nWidthLimit)
	LogInfo("p.AttachItemInfo");
	local nResHeight	= 0;
	if not CheckP(pUiLayer) or
		not CheckN(nItemId) or
		not CheckN(nWidthLimit) then
		LogInfo("p.AttachItemInfo invalid arg");
		return nResHeight;
	end
	
	if not Item.IsExistItem(nItemId) then
		LogInfo("p.AttachItemInfo not Item.IsExistItem[%d]", nItemId);
		return nResHeight;
	end
	
	local nItemType	= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	local nType		= ItemFunc.GetType(nItemType);
	if nType == Item.TypeInvalid then
		LogInfo("p.AttachItemInfo nType == Item.TypeInvalid");
		return nResHeight;
	end
	
	if nType == Item.TypeEquip then
		return p.AttachEquipInfo(pUiLayer, nItemId, nWidthLimit);
	elseif nType == Item.TypeDaoFa then
		return p.AttackDaoFaInfo(pUiLayer, nItemId, nWidthLimit);
	elseif nType == Item.TypeComposeRoll then
		return p.AttachComposeInfo(pUiLayer, nItemId, nWidthLimit);
	else--if nType == Item.TypeConsume then
		return p.AttachConsumeInfo(pUiLayer, nItemId, nWidthLimit);
	end
	
	return 0;
end


function p.GetColoredItemNameByItemType(nItemType)
	
	local nType	= ItemFunc.GetType(nItemType);
	local strName	= "";
	
	LogInfo("type=%d,itemType=%d",nType,nItemType);
	if nType == Item.TypeEquip then
		local nQulity = ItemFunc.GetQuality(nItemType);
		if nQulity == Item.QUALITY_WHITE then
			strName = "<cffffff" .. ItemFunc.GetName(nItemType) .. "/e";
		elseif nQulity == Item.QUALITY_GREEN then
			strName = "<c00ff00" .. ItemFunc.GetName(nItemType) .. "/e";
		elseif nQulity == Item.QUALITY_BLUE then
			strName = "<c0000ff" .. ItemFunc.GetName(nItemType) .. "/e";
		elseif nQulity == Item.QUALITY_PURPLE then
			strName = "<c4bff00" .. ItemFunc.GetName(nItemType) .. "/e";
		elseif nQulity == Item.QUALITY_GOLDEN then
			strName = "<cffD700" .. ItemFunc.GetName(nItemType) .. "/e";
		else
			strName = ItemFunc.GetName(nItemType);
		end
	elseif nType == Item.TypeDaoFa then
		strName = ItemFunc.GetName(nItemType);
		local c , cstr = RealizeFunc.getColorByQut(ItemFunc.GetQuality(nItemType))
		if cstr then
			strName = "<c".. cstr .. strName .. "/e";
		end
	elseif nType == Item.TypeComposeRoll then	
        strName = "<c00ff00" .. ItemFunc.GetName(nItemType) .. "/e";
	else
		strName = ItemFunc.GetName(nItemType);
	end
	LogInfo("itemName="..strName);
	return strName;
end

--内部接口
--装备类物品
function p.AttachEquipInfo(pUiLayer, nItemId, nWidthLimit)
	local nResHeight		= 0;
	local nStartX			= 5 * ScaleFactor;
	local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	local nQulity			= ItemFunc.GetQuality(nItemType);
	local strName			= "";
	
	--物品名字
	strName=p.GetColoredItemNameByItemType(nItemType);
	
	nResHeight	= nResHeight + 2 * ScaleFactor;
	p.AddColorLabel(pUiLayer, strName, 16, nStartX, nResHeight, nWidthLimit);
	nResHeight	= nResHeight + 20 * ScaleFactor;
	
	--强化等级
	local nEnhance			= Item.GetItemInfoN(nItemId, Item.ITEM_ADDITION);
	local strEnhanceDesc	= "";
	if nEnhance >= 1 and nEnhance <= 10 then
		strEnhanceDesc	= "法器";
	elseif nEnhance >= 11 and nEnhance <= 20 then
		strEnhanceDesc	= "灵器";
	elseif nEnhance >= 21 and nEnhance <= 30 then
		strEnhanceDesc	= "道器";
	elseif nEnhance >= 31 and nEnhance <= 40 then
		strEnhanceDesc	= "下品仙器";
	elseif nEnhance >= 41 and nEnhance <= 50 then
		strEnhanceDesc	= "中品仙器";
	elseif nEnhance >= 61 and nEnhance <= 70 then
		strEnhanceDesc	= "王品仙器";
	elseif nEnhance >= 71 and nEnhance <= 80 then
		strEnhanceDesc	= "圣品仙器";
	elseif nEnhance >= 81 and nEnhance <= 90 then
		strEnhanceDesc	= "神器";
	elseif nEnhance >= 91 and nEnhance <= 100 then
		strEnhanceDesc	= "造化神器";
	end
	if nEnhance > 0 then
		local str	= "<cEB6100强化等级 " .. strEnhanceDesc .. tostring(nEnhance) .. "级/e";
		if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
			nResHeight	= nResHeight + 14 * ScaleFactor;
		end
	end
	
	--普通属性
	local bHasNormalProp = false;
	for i=1, 3 do
		local nAttrType = ConvertN(ItemFunc.GetAttrType(nItemId, i - 1));
		LogInfo("普通属性 itemid[%d] index[%d] attrtype[%d]", nItemId, i - 1, nAttrType);
		if nAttrType > Item.ATTR_TYPE_NONE then
			local nVal  = ConvertN(ItemFunc.GetAttrTypeVal(nItemId, i - 1));
			local desc	= ItemFunc.GetAttrTypeDesc(nAttrType);
			if "" ~= desc then
				local str;
				if nAttrType == Item.ATTR_TYPE_DRITICAL or
					nAttrType == Item.ATTR_TYPE_HITRATE or
					nAttrType == Item.ATTR_TYPE_WRECK or
					nAttrType == Item.ATTR_TYPE_HURT_ADD or
					nAttrType == Item.ATTR_TYPE_TENACITY or
					nAttrType == Item.ATTR_TYPE_DODGE or
					nAttrType == Item.ATTR_TYPE_BLOCK then 
					str = "<cEB6100" .. desc .. " +" .. tostring(GetNumDot(nVal/10, 1)) .. "%/e";
				else
					str = "<cEB6100" .. desc .. " +" .. tostring(nVal) .. "/e";
				end
				if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
					bHasNormalProp	= true;
					nResHeight	= nResHeight + 14 * ScaleFactor;
				end
			end
		end
	end
	
	if bHasNormalProp then
		nResHeight = nResHeight + 15 * ScaleFactor;
	end
	
	local bHasQiling	= false;
	--器灵
	local idlist	= ItemInlay.GetQiLinItemList(nItemId);
	LogInfo("器灵 列表");
	LogInfoT(idlist);
	if 0 < table.getn(idlist) then
		local listAttr = {};
		for i, v in ipairs(idlist) do
			for i=1, 3 do
				local nAttrType = ConvertN(ItemFunc.GetAttrType(v, i - 1));
				if nAttrType > Item.ATTR_TYPE_NONE then
					local nVal  = ConvertN(ItemFunc.GetAttrTypeVal(v, i - 1));
					LogInfo("器灵 itemid[%d] index[%d] attrtype[%d]val[%d]", v, i - 1, nAttrType, nVal);
					if not listAttr[nAttrType] then
						listAttr[nAttrType]	= nVal;
					else
						listAttr[nAttrType]	= listAttr[nAttrType] + nVal;
					end
				end
			end
		end
		LogInfo("器灵加成");
		for i, v in pairs(listAttr) do
			LogInfo("attr[%d] val[%d]", i, v);
		end
		
		local listsort = {};
		for i, v in pairs(listAttr) do
			table.insert(listsort, i);
		end
		table.sort(listsort);
		LogInfo("器灵 sort");
		LogInfoT(listsort);
		for i, v in ipairs(listsort) do
			if listAttr[v] then
				local nAttrType	= ConvertN(v);
				local nVal  = ConvertN(listAttr[v]);
				local desc	= ItemFunc.GetAttrTypeDesc(v);
				if "" ~= desc then
					local str;
					if nAttrType == Item.ATTR_TYPE_DRITICAL or
						nAttrType == Item.ATTR_TYPE_HITRATE or
						nAttrType == Item.ATTR_TYPE_WRECK or
						nAttrType == Item.ATTR_TYPE_HURT_ADD or
						nAttrType == Item.ATTR_TYPE_TENACITY or
						nAttrType == Item.ATTR_TYPE_DODGE or
						nAttrType == Item.ATTR_TYPE_BLOCK then 
						str = "<cEB6100" .. desc .. " +" .. tostring(GetNumDot(nVal / 10, 1)) .. "%/e";
					else
						str = "<cEB6100" .. desc .. " +" .. tostring(nVal) .. "/e";
					end
					if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
						nResHeight	= nResHeight + 14 * ScaleFactor;
						bHasQiling	= true;
					end
				end
			end
		end
	end
	
	if bHasQiling then
		nResHeight = nResHeight + 15 * ScaleFactor;
	end
	
	--穿戴需求
	local bHasReqWear = false;
	local nJobReq	= ConvertN(ItemFunc.GetJobReq(nItemType));
	local nLvlReq	= ConvertN(ItemFunc.GetLvlReq(nItemType));
	
	if nJobReq > PROFESSION_TYPE.NONE or nLvlReq > 0 then
		if p.AddColorLabel(pUiLayer, "穿戴需求", 12, nStartX, nResHeight, nWidthLimit) then
			nResHeight	= nResHeight + 14 * ScaleFactor;
		end
		if nLvlReq > 0 then
			local str = "角色等级 " .. tostring(nLvlReq) .. "级";
			if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
				nResHeight	= nResHeight + 14 * ScaleFactor;
			end
		end
		if nJobReq > PROFESSION_TYPE.NONE then
			local str = "角色职业 " .. RolePetFunc.GetJobDesc(nJobReq);
			if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
				nResHeight	= nResHeight + 14 * ScaleFactor;
			end
		end
		
		bHasReqWear = true;
	end
	
	if bHasReqWear then
		nResHeight = nResHeight + 15 * ScaleFactor;
	end
	
	--价格
	local nPrice	= ConvertN(ItemFunc.GetPrice(nItemType));
	if nPrice > 0 then
		local str = "<cffff00" .. "价格 " .. tostring(nPrice) .. "/e";
		if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
			nResHeight	= nResHeight + 14 * ScaleFactor;
		end
	end
	
	nResHeight = nResHeight + 5 * ScaleFactor;
	
	return nResHeight;
end


-- 道法物品
function p.AttackDaoFaInfo(pUiLayer, nItemId, nWidthLimit)
	local nResHeight		= 0;
	local nStartX			= 5 * ScaleFactor;
	local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	
	--物品名字
	local strName = p.GetColoredItemNameByItemType(nItemType);

	nResHeight	= nResHeight + 2 * ScaleFactor;
	p.AddColorLabel(pUiLayer, strName, 16, nStartX, nResHeight, nWidthLimit);
	
	nResHeight	= nResHeight + 20 * ScaleFactor;
	
	--物品描述
	local strContent = ItemFunc.GetDesc(nItemType);
	if p.AddColorLabel(pUiLayer, strContent, 12, nStartX, nResHeight, nWidthLimit - 50 * ScaleFactor) then
		local size = GetHyperLinkTextSize(strContent, 12, nWidthLimit-50 * ScaleFactor);
		nResHeight	= nResHeight + size.h + 5 * ScaleFactor;
	end

	--价格
	local nPrice	= ConvertN(ItemFunc.GetPrice(nItemType));
	if nPrice > 0 then
		local str = "<cffff00" .. "价格 " .. tostring(nPrice) .. "/e";
		if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
			nResHeight	= nResHeight + 14 * ScaleFactor;
		end
	end
	
	nResHeight = nResHeight + 5 * ScaleFactor;
	
	return nResHeight;
end

--消耗类物品
function p.AttachConsumeInfo(pUiLayer, nItemId, nWidthLimit)
	local nResHeight		= 0;
	local nStartX			= 5 * ScaleFactor;
	local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	
	--物品名字
	local strName =p.GetColoredItemNameByItemType(nItemType);
	
	nResHeight	= nResHeight + 2 * ScaleFactor;
	p.AddColorLabel(pUiLayer, strName, 16, nStartX, nResHeight, nWidthLimit);
	
	nResHeight	= nResHeight + 20 * ScaleFactor;
	
	--物品描述
	local strContent = ItemFunc.GetDesc(nItemType);
	if p.AddColorLabel(pUiLayer, strContent, 12, nStartX, nResHeight, nWidthLimit - 50 * ScaleFactor) then
		local size = GetHyperLinkTextSize(strContent, 12, nWidthLimit-50 * ScaleFactor);
		nResHeight	= nResHeight + size.h + 5 * ScaleFactor;
	end

	--价格
	local nPrice	= ConvertN(ItemFunc.GetPrice(nItemType));
	if nPrice > 0 then
		local str = "<cffff00" .. "价格 " .. tostring(nPrice) .. "/e";
		if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
			nResHeight	= nResHeight + 14 * ScaleFactor;
		end
	end
	
	nResHeight = nResHeight + 5 * ScaleFactor;
	
	return nResHeight;
end

--获得合成卷的描述
function p.AttachComposeInfo(pUiLayer, nItemId, nWidthLimit)
	LogInfo("获得合成卷的描述nItemId="..nItemId);
	local nResHeight		= 0;
	local nStartX			= 5 * ScaleFactor;
	local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	local nQulity			= ItemFunc.GetQuality(nItemType);
	local strName			= "";
	
	local nStartX1			= nStartX + nWidthLimit/2;
	
	--物品名字
	strName = "<c0000ff" .. ItemFunc.GetName(nItemType) .. "/e";
	
	nResHeight	= nResHeight + 2 * ScaleFactor;
	p.AddColorLabel(pUiLayer, strName, 16, nStartX, nResHeight, nWidthLimit);
	nResHeight	= nResHeight + 20 * ScaleFactor;
	--物品描述
	local strContent = ItemFunc.GetDesc(nItemType);
	if p.AddColorLabel(pUiLayer, strContent, 12, nStartX, nResHeight, nWidthLimit - 50 * ScaleFactor) then
		local size = GetHyperLinkTextSize(strContent, 12, nWidthLimit-50 * ScaleFactor);
		nResHeight	= nResHeight + size.h + 5 * ScaleFactor;
	end
	--材料需求
	if nResHeight < 50 then
	  nResHeight = 50;
	end
	local formulaID=Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	
	local materialTable = {};
	p.addMaterialDes(materialTable,formulaID,DB_FORMULATYPE.MATERIAL1,DB_FORMULATYPE.NUM1);
	p.addMaterialDes(materialTable,formulaID,DB_FORMULATYPE.MATERIAL2,DB_FORMULATYPE.NUM2);
	p.addMaterialDes(materialTable,formulaID,DB_FORMULATYPE.MATERIAL3,DB_FORMULATYPE.NUM3);
	p.addMaterialDes(materialTable,formulaID,DB_FORMULATYPE.MATERIAL4,DB_FORMULATYPE.NUM4);
	p.addMaterialDes(materialTable,formulaID,DB_FORMULATYPE.MATERIAL5,DB_FORMULATYPE.NUM5);
	p.addMaterialDes(materialTable,formulaID,DB_FORMULATYPE.MATERIAL6,DB_FORMULATYPE.NUM6);
	
	for i, v in ipairs(materialTable) do
	  if i%2 == 0 then
		if p.AddColorLabel(pUiLayer, v, 12, nStartX1, nResHeight, nWidthLimit - 50 * ScaleFactor) then
		  local size = GetHyperLinkTextSize(v, 12, nWidthLimit-50 * ScaleFactor);
		  nResHeight	= nResHeight + size.h + 5 * ScaleFactor;
		end
	  else  
	    if p.AddColorLabel(pUiLayer, v, 12, nStartX, nResHeight, nWidthLimit - 50 * ScaleFactor) then
		  if i == #materialTable then
			local size = GetHyperLinkTextSize(v, 12, nWidthLimit-50 * ScaleFactor);
		    nResHeight	= nResHeight + size.h + 5 * ScaleFactor;
		  end 
		end
	  end 
	end
	--价格
	local nPrice	= ConvertN(ItemFunc.GetPrice(nItemType));
	if nPrice > 0 then
		local str = "<cffff00" .. "价格 " .. tostring(nPrice) .. "/e";
		if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
			nResHeight	= nResHeight + 14 * ScaleFactor;
		end
	end	
	nResHeight = nResHeight + 5 * ScaleFactor;
	
	

	return nResHeight;
end

function p.addMaterialDes(materialTable,formulaID,material,num)
  local materialItemType = GetDataBaseDataN("formulatype",formulaID,material);
  if materialItemType ~= 0 then
	local materialName = ItemFunc.GetName(materialItemType);
	local owerNum = ItemFunc.GetItemCount(materialItemType);
	local needNum = GetDataBaseDataN("formulatype",formulaID,num);
	local materialDes=materialName..owerNum.."/"..needNum;
	if owerNum >= needNum then
	  materialDes = "<c00ff00" .. materialDes .. "/e";
	else
	  materialDes = "<cffffff" .. materialDes .. "/e";
	end 
	table.insert(materialTable,materialDes);
  end
end

--内部接口
function p.AddColorLabel(pUiLayer, str, fontsize, nX, nY, nWidthLimit)
	if	not CheckP(pUiLayer) or
		not CheckS(str) or
		not CheckN(fontsize) or
		not CheckN(nX) or
		not CheckN(nY) or
		not CheckN(nWidthLimit) then
		return false;
	end
	
	if "" == str then
		return false;
	end
	LogInfo("_G.CreateColorLabel");
	local lb = _G.CreateColorLabel(str, fontsize, nWidthLimit);
	if CheckP(lb) then
		lb:SetFrameRect(CGRectMake(nX, nY, nWidthLimit, 20 * ScaleFactor));
		pUiLayer:AddChild(lb);
		return true;
	end
	return false;
end

--取得物品的描述和名字加到层pUiLayer中(仅适用合成物品后的描述-如果是装备则取的强化等级背包中强化等级最高的装备强化等级－5，背包中无装备则强化等级为0)
function p.AttachItemND(pUiLayer,formulaID , nWidthLimit)
    local nItemType=GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.PRODUCT);
	local nResHeight		= 0;
	local nStartX			= 5 * ScaleFactor;
	local nQulity			= ItemFunc.GetQuality(nItemType);
	local nType		        = ItemFunc.GetType(nItemType);
	
	if CheckP(pUiLayer) and
	   CheckN(nItemType) and
	   CheckN(nWidthLimit) then
	--物品名字
	local strName = p.GetColoredItemNameByItemType(nItemType);
	
	nResHeight	= nResHeight + 2 * ScaleFactor;
	p.AddColorLabel(pUiLayer, strName, 16, nStartX, nResHeight, nWidthLimit);
	nResHeight	= nResHeight + 20 * ScaleFactor;
	
	if nType == Item.TypeInvalid then
		LogInfo("p.AttachItemInfo nType == Item.TypeInvalid");
		return nResHeight;
	end
	if nType == Item.TypeEquip then
	    local bHasNormalProp = false;
		
		local nAttrType = Item.ATTR_TYPE_NONE;
		local nVal = 0;
		local nGrow=0;
		--强化等级
		local nEnhance=1;
		local maxEhanceItemID=p.GetMaxEnhanceItemID(GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.MATERIAL1));
		if maxEhanceItemID ~= 0 then
		   nEnhance= Item.GetItemInfoN(maxEhanceItemID, Item.ITEM_ADDITION)-5;
		   if nEnhance < 1 then
		     nEnhance = 1;
		   end
		end
		
		local strEnhanceDesc = "";
	    if nEnhance >= 1 and nEnhance <= 10 then
		  strEnhanceDesc	= "法器";
	    elseif nEnhance >= 11 and nEnhance <= 20 then
		  strEnhanceDesc	= "灵器";
	    elseif nEnhance >= 21 and nEnhance <= 30 then
		strEnhanceDesc	= "道器";
	    elseif nEnhance >= 31 and nEnhance <= 40 then
		  strEnhanceDesc	= "下品仙器";
	    elseif nEnhance >= 41 and nEnhance <= 50 then
		  strEnhanceDesc	= "中品仙器";
	    elseif nEnhance >= 61 and nEnhance <= 70 then
		  strEnhanceDesc	= "王品仙器";
	    elseif nEnhance >= 71 and nEnhance <= 80 then
		  strEnhanceDesc	= "圣品仙器";
	    elseif nEnhance >= 81 and nEnhance <= 90 then
		  strEnhanceDesc	= "神器";
	    elseif nEnhance >= 91 and nEnhance <= 100 then
		  strEnhanceDesc	= "造化神器";
	    end
		
		local str	= "<cEB6100强化等级 " .. strEnhanceDesc .. tostring(nEnhance) .. "级/e";
		if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
			nResHeight	= nResHeight + 14 * ScaleFactor;
		end
		
		--普通属性
        for i=1, 3 do
		  if i == 1 then
			nAttrType = GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ATTR_TYPE_1);
		    nVal = GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ATTR_VALUE_1);
			nGrow = GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ATTR_GROW_1);
		  elseif i == 2 then
		    nAttrType = GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ATTR_TYPE_2);
		    nVal = GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ATTR_VALUE_2);
			nGrow = GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ATTR_GROW_2);
		  elseif i == 3 then
		    nAttrType = GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ATTR_TYPE_3);
		    nVal = GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ATTR_VALUE_3);
			nGrow = GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ATTR_GROW_3);
		  end
		
		  if nAttrType > Item.ATTR_TYPE_NONE then
			local desc	= ItemFunc.GetAttrTypeDesc(nAttrType);
			if "" ~= desc then
				local str;
				if nAttrType == Item.ATTR_TYPE_DRITICAL or
					nAttrType == Item.ATTR_TYPE_HITRATE or
					nAttrType == Item.ATTR_TYPE_WRECK or
					nAttrType == Item.ATTR_TYPE_HURT_ADD or
					nAttrType == Item.ATTR_TYPE_TENACITY or
					nAttrType == Item.ATTR_TYPE_DODGE or
					nAttrType == Item.ATTR_TYPE_BLOCK then 
					str = "<cEB6100" .. desc .. " +" .. tostring(GetNumDot((nVal+nEnhance*nGrow)/10, 1)) .. "%/e";
				else
					str = "<cEB6100" .. desc .. " +" .. tostring(nVal+nEnhance*nGrow) .. "/e";
				end
				if p.AddColorLabel(pUiLayer, str, 12, nStartX, nResHeight, nWidthLimit) then
					bHasNormalProp	= true;
					nResHeight	= nResHeight + 14 * ScaleFactor;
				end
			 end
		  end
	    end

		if bHasNormalProp then
		nResHeight = nResHeight + 15 * ScaleFactor;
	    end
		
	elseif nType == Item.TypeConsume then
		--物品描述
	    local strContent = ItemFunc.GetDesc(nItemType);
	    if p.AddColorLabel(pUiLayer, strContent, 12, nStartX, nResHeight, nWidthLimit - 50 * ScaleFactor) then
	       local size = GetHyperLinkTextSize(strContent, 12, nWidthLimit-50 * ScaleFactor);
		   nResHeight	= nResHeight + size.h + 5 * ScaleFactor;
		end	
	    nResHeight = nResHeight + 5 * ScaleFactor;
	    return nResHeight;
	    else 
	       return nResHeight;  	
	    end
	end	
end

--取得背包中强化等级最高的装备ID（传入材料的itemtype-如果背包中不存在此装备则返回0）
function p.GetMaxEnhanceItemID(nItemType)
   local maxEhanceItemID = 0;
   local nEnhance = 0;
   local nPlayerId  = ConvertN(GetPlayerId());
   
   local idlistItem	= ItemUser.GetBagItemList(nPlayerId);
   for i, v in ipairs(idlistItem) do
     local itemType = Item.GetItemInfoN(v, Item.ITEM_TYPE);
     if itemType == nItemType then
	   local enhance = Item.GetItemInfoN(v, Item.ITEM_ADDITION);
	   if enhance>nEnhance then
	     nEnhance = enhance;
	     maxEhanceItemID = v;
	   elseif maxEhanceItemID == 0 then
		 maxEhanceItemID = v;
	   end
	 end
   end
   return maxEhanceItemID;
end

--取得背包中的装备id（传入itemtype－返回itemid）
function p.GetItemID(nItemType)
  local itemID = 0;
  local nPlayerId  = ConvertN(GetPlayerId());
  local idlistItem = ItemUser.GetBagItemList(nPlayerId);
  for i, v in ipairs(idlistItem) do
    local itemType = Item.GetItemInfoN(v, Item.ITEM_TYPE);
	if itemType == nItemType then
	  itemID = v;
	  break;
	end
  end
  return itemID;
end

--获得器灵的颜色
function p.GetQLColor(nItemType)
    local color = ccc4(255, 255,255, 255);
	local nQulity = ItemFunc.GetQuality(nItemType);
	if nQulity == Item.QL_QUALITY_BLUE then
	  color = ccc4(0,0,255, 255);
	elseif nQulity == Item.QL_QUALITY_PURPLE then
	  color = ccc4(167,87,168,255);
	elseif nQulity == Item.QL_QUALITY_GOLDEN then
	  color = ccc4(255,215,0,255);
	end
	return color;
end

--获得装备的颜色
function p.GetEquipColor(nItemType)
    local color = ccc4(255, 255,255, 255);
	local nQulity = ItemFunc.GetQuality(nItemType);
	if nQulity == Item.QUALITY_WHITE then
      color = ccc4(255, 255,255, 255);
	elseif nQulity == Item.QUALITY_GREEN then
	  color = ccc4(0,255,0,255);
	elseif nQulity == Item.QUALITY_BLUE then
	  color = ccc4(0,0,255,255);
	elseif nQulity == Item.QUALITY_PURPLE then
	  color = ccc4(167,87,168,255);
	elseif nQulity == Item.QUALITY_GOLDEN then
	  color = ccc4(255,215,0,255); 
	end
	return color;
end




