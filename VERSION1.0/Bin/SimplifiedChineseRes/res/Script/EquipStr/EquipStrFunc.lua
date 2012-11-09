---------------------------------------------------
--描述: 装备强化的一些接口
--时间: 2012.3
--作者: fyl
---------------------------------------------------
EquipStrFunc = {};
local p = EquipStrFunc;


--enhance表接口
function p.GetReqMoney(itemTypeId,equipLv)
	local reqMoney;
	if CheckN(itemTypeId) and
	    CheckN(equipLv) then
		enhanceId = ItemFunc.GetEnhancedId(itemTypeId);
		LogInfo("enhanceId:%d",enhanceId)
		LogInfo("equipLv:%d",equipLv)
	
		local reqMoney1 = GetDataBaseDataN("enhanced", enhanceId + equipLv - 1 , DB_ENHANCED.REQ_MONEY);
		local reqMoney2 = GetDataBaseDataN("enhanced", enhanceId + equipLv + 0 , DB_ENHANCED.REQ_MONEY);
		reqMoney = reqMoney2 - reqMoney1;
		
        
		LogInfo("money1:%d,money2:%d",reqMoney1,reqMoney2)
	end
	return reqMoney;
end




function p.CanEquipStr(nPetId,equipId)
	if CheckN(nPetId) and
	   CheckN(equipId) then
	     local equipLv = Item.GetItemInfoN(equipId, Item.ITEM_ADDITION);--注:0对应1级，以此类推
		 if nPetId == 0 then
		     --背包中的装备
			 nPetId = RolePetFunc.GetMainPetId(GetPlayerId);
		 end
	     local petLv = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL);
	     LogInfo("宠物等级:[%d]装备等级:[%d]",petLv,equipLv)
	
--	     if equipLv >= petLv then
--	         return -1;--装备等级不能超过宠物等级
--       end
	end
		
	return 1;
end



