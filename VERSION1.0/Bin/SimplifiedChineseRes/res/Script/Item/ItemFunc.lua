---------------------------------------------------
--描述: 物品通用的一些接口
--时间: 2012.3.5
--作者: jhzheng
---------------------------------------------------
ItemFunc = {};
local p = ItemFunc;

--ItemType表接口
function p.GetName(nItemType)
	local str	= "";
	if CheckN(nItemType) then
		str		= GetDataBaseDataS("itemtype", nItemType, DB_ITEMTYPE.NAME);
	end
	return ConvertS(str);
end

function p.GetQuality(nItemType)
	local nQuality	= 0;
	if CheckN(nItemType) then
		nQuality	= Num1(nItemType);
	end
	return nQuality;
end

function p.GetDesc(nItemType)
	local str	= "";
	if CheckN(nItemType) then
		str		= GetDataBaseDataS("itemtype", nItemType, DB_ITEMTYPE.DESCRIPT);
	end
	return ConvertS(str);
end

function p.GetJobReq(nItemType)
	local nJobReq	= 0;
	if CheckN(nItemType) then
		nJobReq	= Num4(nItemType);
	end
	return nJobReq;
end

--获得道具的类别
function p.GetPropType(nItemType)
    local nType	= 0;
	if CheckN(nItemType) then
		nType	= Num7(nItemType);
	end
	return nType;
end

function p.GetQualityCCC4(nItemType)
    return GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.QUALITY);
end

function p.GetLvlReq(nItemType)
	local nRes	= 0;
	if CheckN(nItemType) then
		nRes	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.REQ_LEVEL);
	end
	return ConvertN(nRes);
end

function p.CanChaiFen(nItemType)
	local nRes	= 0;
	if CheckN(nItemType) then
		nRes	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.AMOUNT_LIMIT);
	end
	if nRes > 1 then
		return true;
	end
	return false;
end

function p.GetPrice(nItemType)
	local nRes	= 0;
	if CheckN(nItemType) then
		nRes	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.PRICE);
	end
	return ConvertN(nRes);
end

function p.CanEquip(nItemId)
	if not CheckN(nItemId) then
		return false;
	end
	local nItemType = Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	return p.CanEquipByItemType(nItemType);
end

function p.CanEquipByItemType(nItemType)
	if not CheckN(nItemType) then
		return false;
	end
	
	if 0 == Num8(nItemType) and 1 == Num7(nItemType) then
		return true;
	end
	
	return false;
end


function p.GetBigType(nItemType)
    if not CheckN(nItemType) then
		return Item.bTypeInvalid;
	end
	local nNum8 = Num8(nItemType);
    return nNum8;
end

function p.GetType(nItemType)
	if not CheckN(nItemType) then
		return Item.TypeInvalid;
	end
	
	local nNum8 = Num8(nItemType);
	local nNum7 = Num7(nItemType);
	
	if 0 == nNum8 then
	--可装备类
		if 1 == nNum7 then
		--装备
			return Item.TypeEquip;
		elseif 2 == nNum7 then
		--器灵
			return Item.TypeQiLing;
		elseif 3 == nNum7 then
		--道法
			return Item.TypeDaoFa;
		end
	elseif 1 == nNum8 then
	--坐骑
		return Item.TypeRide;
	elseif 2 == nNum8 then
	--普通物品
		if 1 == nNum7 or 
			2 == nNum7 or
			3 == nNum7 then
		--消耗类物品(回复药,丹药,变身卷轴)
			return Item.TypeConsume;
		elseif 4 == nNum7 then
		--玉牌
			return Item.TypeNone;
		elseif 5 == nNum7 then
		--材料
			return Item.TypeNone;
		end
	elseif 3 == nNum8 then
	--合成卷
		return Item.TypeComposeRoll;
	elseif 4 == nNum8 then
	--任务物品
		return Item.TypeQuest;
	elseif 5 == nNum8 then
	--礼包
		return Item.TypeGift;
	end
    
    
	
	return Item.TypeInvalid;
end

--获取装备每次升级增加的属性内容(attr_type_1,attr_value_1,attr_grow_1,...)
function p.GetAttrTypeAndValueAndGrow(itemTypeId)
	local attr_type_1,attr_value_1,attr_grow_1,
	      attr_type_2,attr_value_2,attr_grow_2,
		  attr_type_3,attr_value_3,attr_grow_3;
		  
	if CheckN(itemTypeId) then
		attr_type_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_TYPE_1);
		attr_value_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_VALUE_1);
		attr_grow_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_GROW_1);
		
		attr_type_2 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_TYPE_2);
		attr_value_2 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_VALUE_2);
		attr_grow_2 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_GROW_2);
		
		attr_type_3 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_TYPE_3);
		attr_value_3 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_VALUE_3);
		attr_grow_3 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_GROW_3);
	end
	return attr_type_1,attr_value_1,attr_grow_1,
		   attr_type_2,attr_value_2,attr_grow_2,
		   attr_type_3,attr_value_3,attr_grow_3;
end

function p.GetAttrDesc(itemTypeId, level)
    local attr_type_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_TYPE_1);
    local attr_value_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_VALUE_1);
    local attr_grow_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_GROW_1);
    
    local txt = "";
    local num = "";
    
    
    txt = p.GetAttrTypeDesc(attr_type_1);
    
    txt = txt.."：";
    num = attr_value_1.."";
    if(level>0) then
        num = num.."(+"..(level*attr_grow_1)..")"
    end
    
    return txt,num;
end

--获得宝石属性的描述
function p.GetGemPropDesc(itemTypeId)
    local attr_type_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_TYPE_1);
    local attr_value_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_VALUE_1);
    
    LogInfo("attr_type_1:[%d],attr_value_1:[%d]",attr_type_1,attr_value_1);
    
    local txt = p.GetAttrTypeValueDesc(attr_type_1,attr_value_1);
    
    LogInfo("txt:[%s]",txt);
    
    return txt;
end


function p.GetEnhancedId(itemTypeId)
	local nId;
	if CheckN(itemTypeId) then
		nId = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ENHANCED_ID);
	end
	return nId;
end


--物品接口
--获取第N个物品属性(N从0开始)
function p.GetAttrType(nItemId, nIndex)
	if not CheckN(nItemId) or
		not CheckN(nIndex) then
		return 0;
	end
	
	return Item.GetItemInfoN(nItemId, Item.ITEM_ATTR_BEGIN + nIndex * 2);
end

--获取第N个物品属性值(N从0开始)
function p.GetAttrTypeVal(nItemId, nIndex)
	if not CheckN(nItemId) or
		not CheckN(nIndex) then
		return 0;
	end
	
	return Item.GetItemInfoN(nItemId, Item.ITEM_ATTR_BEGIN + nIndex * 2 + 1);
end

function p.GetItemCount(nItemType)
	if not CheckN(nItemType) then
		return 0;
	end
	
	local idlist = _G.ItemUser.GetBagItemList(GetPlayerId());
	local nCount = 0;
	
	local bCanChiFen	= p.CanChaiFen(nItemType);
	
	for i, v in ipairs(idlist) do
		local n = Item.GetItemInfoN(v, Item.ITEM_TYPE);
		if n == nItemType then
			if bCanChiFen then
				nCount = nCount + Item.GetItemInfoN(v, Item.ITEM_AMOUNT);
			else
				nCount = nCount + 1;
			end
		end
		
	end
	
	return nCount;
end

function p.GetStorageItemCount(nItemType)
	if not CheckN(nItemType) then
		return 0;
	end
	
	local idlist = _G.ItemUser.GetStorageItemList(GetPlayerId());
	local nCount = 0;
	
	local bCanChiFen	= p.CanChaiFen(nItemType);
	
	for i, v in ipairs(idlist) do
		local n = Item.GetItemInfoN(v, Item.ITEM_TYPE);
		if n == nItemType then
			if bCanChiFen then
				nCount = nCount + Item.GetItemInfoN(v, Item.ITEM_AMOUNT);
			else
				nCount = nCount + 1;
			end
		end
		
	end
	
	return nCount;
end

function p.IsBackBagFull()
	local idlist = ItemUser.GetBagItemList(GetPlayerId());
	return table.getn(idlist) >= _G.GetRoleBasicDataN(_G.GetPlayerId(), _G.USER_ATTR.USER_ATTR_PACKAGE_LIMIT);
end

function p.getBackBagItemCount()
	local idlist = ItemUser.GetBagItemList(GetPlayerId());
	local count = 0;
	if idlist then
		count = #idlist;
	end
	return count;
end

function p.getBackBagCapability()
	return _G.GetRoleBasicDataN(_G.GetPlayerId(), _G.USER_ATTR.USER_ATTR_PACKAGE_LIMIT);
end


--其它接口
function p.GetAttrTypeDesc(nAttr)
	local str = "";
	if not CheckN(nAttr) then
		return str;
	end
    nAttr = math.floor(nAttr/10);
	if nAttr == Item.ATTR_TYPE_POWER then
		str = GetTxtPri("HS_T1");
	elseif nAttr == Item.ATTR_TYPE_AGILITY then
		str = GetTxtPri("HS_T2");
	elseif nAttr == Item.ATTR_TYPE_INTEL then
		str = GetTxtPri("HS_T3");
	elseif nAttr == Item.ATTR_TYPE_LIFE then
		str = GetTxtPri("HS_T4");
	elseif nAttr == Item.ATTR_TYPE_POWER_RATE then
		str = GetTxtPri("HS_T5");
	elseif nAttr == Item.ATTR_TYPE_AGILITY_RATE then
		str = GetTxtPri("HS_T6");
	elseif nAttr == Item.ATTR_TYPE_INTEL_RATE then
		str = GetTxtPri("HS_T7");
	elseif nAttr == Item.ATTR_TYPE_LIFE_RATE then
		str = GetTxtPri("HS_T8");
	elseif nAttr == Item.ATTR_TYPE_PHY_ATK then
		str = GetTxtPri("HS_T9");
	elseif nAttr == Item.ATTR_TYPE_PHY_DEF then
		str = GetTxtPri("HS_T10");
	elseif nAttr == Item.ATTR_TYPE_MAGIC_ATK then
		str = GetTxtPri("HS_T11");
	elseif nAttr == Item.ATTR_TYPE_MAGIC_DEF then
		str = GetTxtPri("HS_T12");
	elseif nAttr == Item.ATTR_TYPE_SPEED then
		str = GetTxtPri("HS_T13");
	elseif nAttr == Item.ATTR_TYPE_HIT then
		str = GetTxtPri("HS_T14");
	elseif nAttr == Item.ATTR_TYPE_DODGE then
		str = GetTxtPri("HS_T15");
	elseif nAttr == Item.ATTR_TYPE_DRITICAL then
		str = GetTxtPri("HS_T16");
	elseif nAttr == Item.ATTR_TYPE_TENACITY then
		str = GetTxtPri("HS_T17");
	elseif nAttr == Item.ATTR_TYPE_BLOCK then
		str = GetTxtPri("HS_T18");
	elseif nAttr == Item.ATTR_TYPE_WRECK then
		str = GetTxtPri("HS_T19");
	elseif nAttr == Item.ATTR_TYPE_UNION_ATK then
		str = GetTxtPri("HS_T20");
    elseif nAttr == Item.ATTR_TYPE_HELP then
		str = GetTxtPri("HS_T21");
    elseif nAttr == Item.ATTR_TYPE_MANA then
		str = GetTxtPri("HS_T22");
	end
    
	return str;
end

function p.GetStatusAttrTypeDesc(nAttr)
    local str = "";
	if not CheckN(nAttr) then
		return str;
	end
    LogInfo("p.GetStatusAttrTypeDesc nAttr:[%d]",nAttr);
	if nAttr == Item.STATUS_ATTR_TYPE_CONTROL_ADD then
		str = "控制概率增幅";
    elseif nAttr == Item.STATUS_ATTR_TYPE_CONTROL_SUB then
        str = "控制抗性增幅";
    elseif nAttr == Item.STATUS_ATTR_TYPE_MORALE_ADD then
        str = "减扣士气效果增幅";    
	elseif nAttr == Item.STATUS_ATTR_TYPE_MORALE_SUB then
		str = "减扣士气抗性增幅";
    end
    return str;
end

function p.GetAttrTypeValueDesc(nAttr, value)
    LogInfo("ItemFunc.GetAttrTypeValueDesc:nAttr:[%d],value:[%d]",nAttr, value);
    local str = "";
    value = value.."";
    local des = p.GetAttrTypeDesc(nAttr);
    local val = ""
    nAttr = Num1(nAttr);
    if(nAttr == 1) then
        val = "+"..value;
    elseif(nAttr == 2) then
        val = "-"..value;
    elseif(nAttr == 3) then
        val = "+"..(value/10);
        val = val.."%";
    elseif(nAttr == 4) then
        val = "-"..(value/10);
        val = (val/10).."%";
    end
    str = des..val;
    return str;
end

function p.GetStatusAttrTypeValueDesc(nAttr, value)
    LogInfo("ItemFunc.GetStatusAttrTypeValueDesc:nAttr:[%d],value:[%d]",nAttr, value);
    local str = "";
    local des = p.GetStatusAttrTypeDesc(nAttr);
    str = des.."+"..(value/10).."%";
    return str;
end




--根据位置获得物品id(传入物品列表和位置索引)
function p.GetItemIdByPosition(idlist,nPosition)
   for i, v in ipairs(idlist) do
     local position = Item.GetItemInfoN(v,Item.ITEM_POSITION);
	 if position == nPosition then
	   return v;
	 end
   end
   return 0;
end

function p.IsAlertEquipItem(nEquipId)
    local usPosition = Item.GetItemInfoN(nEquipId, Item.ITEM_POSITION);
    if usPosition >= Item.POSITION_EQUIP_1 and usPosition <= Item.POSITION_EQUIP_6 then
            return true;
    end
    return false;
end

--获取对应升阶公式id   (nItemType：改造装备id   ,nType：改造类型升阶/神铸/升星)
function p.GetFormulaIdByItemType(nItemType,nType)
	local idList	= {};
	local idFormulaType = _G.GetDataBaseIdList("formulatype");  
	--_G.LogInfoT(idNpcTask)
	
	for i,v  in ipairs(idFormulaType) do
		

		local nEquipTypeId = _G.GetDataBaseDataN("formulatype",v,DB_FORMULATYPE.MATERIAL1);
		--LogInfo(nNpcId.."  "..nMatchNpcId)
		
		if nEquipTypeId == nItemType then
			
			local nDataBaseType = _G.GetDataBaseDataN("formulatype",v,DB_FORMULATYPE.TYPE);
			if nDataBaseType == nType then
				return v;
			end			
		end				

	end
	
	return 0;
end

--[[
--获取对应升阶公式id   (nItemType：改造装备id   ,nType：改造类型升阶/神铸/升星)
function p.GetFormulaIdByItemType(nItemType,nType)
	local idList	= {};
	local idFormulaType = _G.GetDataBaseIdList("formulatype");  
	--_G.LogInfoT(idNpcTask)
	
	for i,v  in ipairs(idFormulaType) do
		
		--升阶
		if nType == 1 then
			if v ==  nItemType then
				return v;
			end
		end
		
		--神铸
		if nType == 2 then
			local nEquipTypeId = _G.GetDataBaseDataN("formulatype",v,DB_FORMULATYPE.MATERIAL1);
			--LogInfo(nNpcId.."  "..nMatchNpcId)
		
		
			if nEquipTypeId == nItemType then
			
				local nDataBaseType = _G.GetDataBaseDataN("formulatype",v,DB_FORMULATYPE.TYPE);
				if nDataBaseType == nType then
					return v;
				end			
			end		
		end			

	end
	
	return 0;
end

--]]
--判定装备是否可以升阶
function p.IfItemCanUpStep(itemID,nPetId)

	local nItemTypeId= Item.GetItemInfoN(itemID,Item.ITEM_TYPE);
	  
	local formulaID = ItemFunc.GetFormulaIdByItemType(nItemTypeId,1)
	LogInfo("IfItemCanUpStep nItemTypeId"..nItemTypeId);
	LogInfo("IfItemCanUpStep formulaID"..formulaID);
    
    
    --不存在公式 
	if formulaID == 0 then
		return false;
	end
	
	--不存在卷子
	if ItemFunc.GetItemCount(formulaID) <= 0 then
		LogInfo("IfItemCanUpStep f")
		return false;		
	end
    
    --判断武将等级是否达到可升级
    if(nPetId == nil) then
        local nPlayerId = GetPlayerId();
        if nil == nPlayerId then
            LogInfo("nil == nPlayerId");
            return;
        end
        nPetId = RolePetFunc.GetMainPetId(nPlayerId);
    end
    local nPetLevel = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL);
    local nFormulatypeLevel = _G.GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.LEVEL);
    LogInfo("nPetLevel:[%d],nFormulatypeLevel:[%d]",nPetLevel,nFormulatypeLevel);
    
    if(nPetLevel<nFormulatypeLevel) then
        return false;
    end
    
	LogInfo("IfItemCanUpStep true")
	return true;
end

--判断背包是否已满
function p.IsBagFull( nNum )
    if(nNum == nil) then
        nNum = 0;
    end
    local nPlayerId		= ConvertN(GetPlayerId());
	local idlistItems	= ItemUser.GetBagItemList(nPlayerId);
    
    if(#idlistItems+nNum >= ItemFunc.getBackBagCapability()) then
        CommonDlgNew.ShowYesDlg(GetTxtPub("BagFull"));
        return true;
    end
    return false;
end

--判断背包是否满，穿装备使用
function p.IsBagFullEquip(nPetId, nEquipId)

    local nPlayerId		= ConvertN(GetPlayerId());
	local idlistItems	= ItemUser.GetBagItemList(nPlayerId);
    
    if(#idlistItems >= ItemFunc.getBackBagCapability()) then
        
        LogInfo("nPetId:[%d],nEquipId:[%d]",nPetId,nEquipId);
        local nItemTypeId = Item.GetItemInfoN(nEquipId, Item.ITEM_TYPE);
    
        local nPosIndex = Num6(nItemTypeId);
        local TAG_EQUIP_LIST = {57,58,59,60,61,62};
        local unPosition = TAG_EQUIP_LIST[nPosIndex];
        local view = PlayerUIBackBag.GetPetView(nPetId);
        local equipBtn = _G.GetEquipButton(view, unPosition);
    
        if(equipBtn:GetItemId() ~= 0) then
            CommonDlgNew.ShowYesDlg(GetTxtPub("BagFull"));
            return true;
        end
    end
    return false;
end


--判断背包是否满，宝石卸下使用
function p.IsBagFullGem(GemItemList, nGemTypeId)
    local nPlayerId		= ConvertN(GetPlayerId());
	local idlistItems	= ItemUser.GetBagItemList(nPlayerId);
    
    if(#idlistItems >= ItemFunc.getBackBagCapability()) then
        for i,v in ipairs(GemItemList) do
            local total = Item.GetItemInfoN(v, Item.ITEM_AMOUNT);
            local nItemType = Item.GetItemInfoN(v, Item.ITEM_TYPE);
            if(nItemType == nGemTypeId and total<99) then
                return false;
            end
        end
        CommonDlgNew.ShowYesDlg(GetTxtPub("BagFull"));
        return true;
    end
    return false;
end

--判断占星背包是否已满
function p.IsDestinyBagFull( nNum )
    if(nNum == nil) then
        nNum = 0;
    end
    local nPlayerId		= ConvertN(GetPlayerId());
	local idlistItems	= ItemUser.GetDaoFaItemList(GetPlayerId());
    
    if(#idlistItems+nNum >= GetVipVal(DB_VIP_CONFIG.DESTINY_BAG_NUM)) then
        CommonDlgNew.ShowTipsDlg({{GetTxtPub("BagFull2"),ccc4(255,15,15,255)}});
        return true;
    end
    return false;
end


--** 获得物品颜色 **--
function p.GetItemColor(nItemType)
    local nQuality = p.GetQualityCCC4(nItemType);
    local cColor4 = ItemColor[nQuality];
    if(cColor4 == nil) then
        cColor4 = ItemColor[0];
    end
    return cColor4;
end

function p.SetLabelColor(label, nItemType) 
    if(label == nil) then
        LogInfo("p.SetLabelColor is nil!");
        return;
    end
    label:SetFontColor(p.GetItemColor(nItemType));
end


--设置道法物品颜色
function p.GetDaoFaItemColor(nItemType)
    local nQuality = Num1(nItemType);
    local cColor4 = DaoFaItemColor[nQuality];
    if(cColor4 == nil) then
        cColor4 = DaoFaItemColor[0];
    end
    return cColor4;
end

function p.SetDaoFaLabelColor(label, nItemType) 
    if(label == nil) then
        LogInfo("p.SetDaoFaLabelColor is nil!");
        return;
    end
    label:SetFontColor(p.GetDaoFaItemColor(nItemType));
end

--获得星运加层
function p.GetDestinyAdd(nItemId)
    
    local nItemTypeId =Item.GetItemInfoN(nItemId, Item.ITEM_TYPE); 
    local equipLv       = Item.GetItemInfoN(nItemId, Item.ITEM_ADDITION)-1;
    
    local txt = "";
    local attr_type_1 = GetDataBaseDataN("itemtype", nItemTypeId, DB_ITEMTYPE.ATTR_TYPE_1);
    local status_attr_type_1 = GetDataBaseDataN("itemtype", nItemTypeId, DB_ITEMTYPE.STATUS_ATTR_TYPE1);
    
    if(attr_type_1 ~= 0) then
        LogInfo("attr_type_1:[%d]",attr_type_1);
        
        local nt = math.floor(attr_type_1/10)*10;
        if( Num3(nItemTypeId)<5 ) then
            attr_type_1 = nt+1;
        else
            --百份比
            attr_type_1 = nt+3;
        end
        LogInfo("attr_type_1:[%d]",attr_type_1);
    
        local attr_value_1 = GetDataBaseDataN("itemtype", nItemTypeId, DB_ITEMTYPE.ATTR_VALUE_1);
        local attr_grow_1 = GetDataBaseDataN("itemtype", nItemTypeId, DB_ITEMTYPE.ATTR_GROW_1);
        txt = p.GetAttrTypeValueDesc(attr_type_1,attr_value_1+attr_grow_1*equipLv);
    else
        local status_attr_value_1 = GetDataBaseDataN("itemtype", nItemTypeId, DB_ITEMTYPE.STATUS_ATTR_VALUE1);
        local status_attr_grow_1 = GetDataBaseDataN("itemtype", nItemTypeId, DB_ITEMTYPE.STATUS_ATTR_GROW1);
        txt = p.GetStatusAttrTypeValueDesc(status_attr_type_1,status_attr_value_1+status_attr_grow_1*equipLv);
    end
    
    LogInfo("txt:[%s]",txt);
    
    return txt;
end
