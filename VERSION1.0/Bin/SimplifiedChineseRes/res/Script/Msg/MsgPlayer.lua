---------------------------------------------------
--描述: 玩家信息网络消息处理及其逻辑
--时间: 2012.2.17
--作者: jhzheng
---------------------------------------------------

MsgPlayer = {}
local p = MsgPlayer;

local MSG_GRID_ACT_BEGIN				= 0;
local MSG_GRID_ACT_STORAGE				= 0; --仓库
local MSG_GRID_ACT_BAG					= 1; --背包
local MSG_GRID_ACT_END					= 2;

--发送开玩家背包消息
function p.SendOpenBagGrid(nNum)
	p.SendOpenGrid(MSG_GRID_ACT_BAG, nNum);
end

--发送开格子消息
function p.SendOpenGrid(nAction, nNum)
	if not CheckN(nAction) or
		not CheckN(nNum) then
		LogInfo("发送开格子消息失败,参数不对");
		return;
	end
	
	if nAction < MSG_GRID_ACT_BEGIN or 
		nAction >= MSG_GRID_ACT_END then
		LogInfo("发送开格子消息失败,action不对");
		return;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_LIMIT);
	if nil == netdata then
		LogInfo("发送开格子消息失败,内存不够");
		return false;
	end
	netdata:WriteByte(nAction);
	netdata:WriteShort(nNum);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("send Grid action[%d] num[%d]", nAction, nNum);
	return true;
end

-- 网络消息处理(用户信息, 宠物信息)
function p.ProcessUserInfo(netdata)
	local idUser				= netdata:ReadInt();
	local idLookface			= netdata:ReadInt();
	local idRecordMap			= netdata:ReadInt();        --玩家离线时所在的地图
	local usRecordX				= netdata:ReadShort();   --玩家离线时所在的地图x坐标	
	local usRecordY				= netdata:ReadShort();   --玩家离线时所在的地图y坐标	 
	local unMoney				= netdata:ReadInt();
	local unEMoney				= netdata:ReadInt();
	local usPackage				= netdata:ReadShort();
	local usStorage				= netdata:ReadShort();
	local unRepute				= netdata:ReadInt();                       --声望
	local btCamp				= netdata:ReadByte();
	local btVipLevel			= netdata:ReadByte();
	local unVipExp				= netdata:ReadInt();
	local unMatrix				= netdata:ReadInt();
	local unSoph				= netdata:ReadInt();                           --将魂
	local usPartsBag			= netdata:ReadShort();
	local usDaoFaBag			= netdata:ReadInt();                            --强化降费节省银币数
	local btPet_limit			= netdata:ReadByte();
	local unStage				= netdata:ReadInt();
	local cEquipCdCount			= netdata:ReadByte();
	local usEquipTime1			= netdata:ReadShort();
	local usEquipTime2			= netdata:ReadShort();
	local usEquipTime3			= netdata:ReadShort();
	local usStamina				= netdata:ReadShort();
	local unRank				= netdata:ReadInt();
	local usBoughtStamina		= netdata:ReadShort();
	local usBuyedGem 			= netdata:ReadShort();
	local usLevi 				= netdata:ReadShort();
	
	local usRecharge	= netdata:ReadInt();                            --充值金币数	 
    local usGuideStage	= netdata:ReadInt();

    local nResetCount			= netdata:ReadInt();                 --精英副本已重置的次数--与服务端同步更新--
    
    
    
    local usSaveMoney			= netdata:ReadInt();                    --装备强化暴击节省银币数	
    local usCritCount			= netdata:ReadInt();                    --装备强化暴击累加次数
    local usQuality             = netdata:ReadByte();
    
    
    
	local strName				= netdata:ReadUnicodeString();
    
	LogInfo("qbw unStage:%d",unStage);
    SetRoleBasicDataS(idUser, USER_ATTR.USER_ATTR_NAME, strName);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_RECHARGE_EMONEY, usRecharge);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_ID, idUser);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_LOOKFACE, idLookface);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_RECORD_MAP, idRecordMap);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_RECORD_X, usRecordX);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_RECORD_Y, usRecordY);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_MONEY, unMoney);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_EMONEY, unEMoney);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_PACKAGE_LIMIT, usPackage);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_STORAGELIMIT, usStorage);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_REPUTE, unRepute);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_CAMP, btCamp);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_VIP_RANK, btVipLevel);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_VIP_EXP, unVipExp);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_MATRIX, unMatrix);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_SOPH, unSoph);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_PARTS_BAG, usPartsBag);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_EQUIP_ENHANCE_SAVE_MONEY, usDaoFaBag);	
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_PET_LIMIT, btPet_limit);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_STAGE, unStage);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_STAMINA, usStamina);
    SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_BUYED_LEVY, usLevi);
    SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_GUIDE_STAGE, usGuideStage);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_HAVE_BUY_STAMINA, usBoughtStamina);
    SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_RANK, unRank);
    SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_INSTANCING_RESET_COUNT, nResetCount);	

	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_BUYED_GEM, usBuyedGem);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_EQUIP_QUEUE_COUNT, cEquipCdCount);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1, usEquipTime1);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME2, usEquipTime2);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME3, usEquipTime3);	
    SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_RANK, unRank);
    
    --** chh 2012-08-17 **--
    SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_EQUIP_CRIT_SAVE_MONEY, usSaveMoney);
    SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_EQUIP_CRIT_COUNT, usCritCount);
    SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_AUTO_EXERCISE, usQuality);
	
	--++Guosen 2012.7.15
	local nRideStatus	= usEquipTime2;
	local nMountType	= usEquipTime3;
	CreatePlayerWithMount( idLookface, usRecordX, usRecordY, idUser, "★"..strName, nRideStatus, nMountType );
	
    GameDataEvent.OnEvent(GAMEDATAEVENT.USERSTAGEATTR);
    
    local szDeviceToken = GetDeviceToken();
    if ( szDeviceToken ~= nil and szDeviceToken ~= "" ) then
    	MsgLoginSuc.setMobileKey( GetDeviceToken() );
    end
    
    --** 设置主角名称颜色 *＊--
    SetPlayerNameColorByQuality(usQuality);
	return 1;
end

local test = 0;
function p.ProcessUserInfoUpdate(netdata)
    LogInfo("p.ProcessUserInfoUpdate");
	local idUser				= ConvertN(netdata:ReadInt());
	local nPlayerId				= ConvertN(GetPlayerId());
	if nPlayerId ~= idUser then
		LogError("qbw:ProcessUserInfoUpdate playerid[%d] idUser[%d]", nPlayerId, idUser);
		return;
	end
	
	
	test =0;
	local btAmount				= netdata:ReadByte();
	local datalist				= {};
	for i=1, btAmount do
		local nAttr				= ConvertN(netdata:ReadInt());
		local nAttrData			= ConvertN(netdata:ReadInt());
        LogInfo("nAttr:[%d],nAttrData:[%d]",nAttr,nAttrData);
		if nAttr ==  USER_ATTR.USER_ATTR_RANK then
			LogInfo("USER_ATTR_RANK:"..nAttrData);
			local rank = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_RANK);
			
			if rank < nAttrData then
				--军衔升级
				
				--成功光效
				PlayEffectAnimation.ShowAnimation(1);
				
				--成功音效
   				Music.PlayEffectSound(Music.SoundEffect.RANK_UP);
			end
			
		end
        
        if nAttr ==  USER_ATTR.USER_ATTR_AUTO_EXERCISE then
             --** 设置主角名称颜色 *＊--
            SetPlayerNameColorByQuality(nAttrData);
        end


		LogInfo("qbw: user info update nAttr"..nAttr.."  DATA:"..nAttrData);
		if nAttr ~= USER_ATTR.USER_ATTR_ID then
			SetRoleBasicDataN(idUser, nAttr, nAttrData);
			--状态如果有特殊处理todo
			table.insert(datalist, nAttr);
			table.insert(datalist, nAttrData);
		end
        if(nAttr == USER_ATTR.USER_ATTR_STAGE) then
            GameDataEvent.OnEvent(GAMEDATAEVENT.USERSTAGEATTR);
        end
	end
	if 0 < #datalist then
		GameDataEvent.OnEvent(GAMEDATAEVENT.USERATTR, datalist);
	end
    
   
end

RegisterNetMsgHandler(NMSG_Type._MSG_USERINFO, "p.ProcessUserInfo", p.ProcessUserInfo);

RegisterNetMsgHandler(NMSG_Type._MSG_USERINFO_UPDATE, "p.ProcessUserInfoUpdate", p.ProcessUserInfoUpdate);
