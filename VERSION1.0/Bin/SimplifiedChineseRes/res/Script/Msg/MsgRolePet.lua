---------------------------------------------------
--描述: 玩家伙伴网络消息处理及其逻辑
--时间: 2012.3.8
--作者: cl
---------------------------------------------------

MsgRolePet = {}
local p = MsgRolePet;

local MSG_PET_SHOP_ACT_BUY			=1; --初次招募
local MSG_PET_SHOP_ACT_BUY_BACK		=2;	--归队
local MSG_PET_SHOP_ACT_DROP			=3;	--离队
local MSG_PET_SHOP_ACT_BUY_GOLD		=4; --直接用金币购买

function p.SendPetLeaveAction(nPetId)
	p.SendShopPetAction(nPetId, MSG_PET_SHOP_ACT_DROP);
end

function p.SendShopPetAction(nPetId, nAction)
	if not CheckN(nPetId) or not CheckN(nAction) then
		return false;
	end
	if nPetId <= 0 then
		return false;
	end
	local netdata = createNDTransData(NMSG_Type._MSG_PET_SHOP_ACTION);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(nAction);
	netdata:WriteInt(nPetId);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("send pet[%d] action[%d]", nPetId, nAction);
    ShowLoadBar();
	return true;
end


-- 银币购买
function p.SendBuyPet(nPetId)
	return p.SendShopPetAction(nPetId, MSG_PET_SHOP_ACT_BUY);
end

-- 金币购买
function p.SendBuyPetWithGold(nPetId)
	return p.SendShopPetAction(nPetId, MSG_PET_SHOP_ACT_BUY_GOLD);
end

function p.SendImpartPet(idPet,idTarget,vip)
	if not CheckN(idPet) or not CheckN(idTarget) or not CheckN(vip) then
		return false;
	end
	if idPet <= 0 then
		return false;
	end
	local netdata = createNDTransData(NMSG_Type._MSG_PET_IMPART);
	if nil == netdata then
		return false;
	end
	LogInfo("send pet[%d] target[%d]", idPet, idTarget);
	netdata:WriteByte(vip);
	netdata:WriteInt(idPet);
	netdata:WriteInt(idTarget);
	SendMsg(netdata);
	netdata:Free();
    ShowLoadBar();
	return true;
end

function p.SendBuyBackPet(nPetId)
	return p.SendShopPetAction(nPetId, MSG_PET_SHOP_ACT_BUY_BACK);
end

function p.SendDropPet(nPetId)
	return p.SendShopPetAction(nPetId, MSG_PET_SHOP_ACT_DROP);
end


-- 更新曾招募过的所有武将
function p.ProcessPetInfo(netdata)
    --CloseLoadBar();
	--LogInfo("MsgRolePet: p.ProcessPetInfo" );
	local btNum					= netdata:ReadByte();
	
	LogInfo("p.ProcessPetInfo btNum[%d]", btNum);
	
	if btNum <= 0 then
		return 1;
	end
	
	local nPlayerID		= GetPlayerId();--User表中的ID
	local tInvitedPets	= RolePetUser.GetPetList( nPlayerID );	-- 旧武将表,为空则是Login时
	local nPlayerPetID	= RolePetFunc.GetMainPetId( nPlayerID );
	local nPlayerLevel	= RolePet.GetPetInfoN( nPlayerPetID, PET_ATTR.PET_ATTR_LEVEL );
	local nNewLevel		= nPlayerLevel;
	
    
    
    
	for	i=1, btNum do
		local idPet					= netdata:ReadInt();					-- ID
		local idType				= netdata:ReadInt();					-- 类型
		
		local btMain				= netdata:ReadByte();					-- 是否主角
		local idOwner				= netdata:ReadInt();				-- 所有者
		local btPosition			= netdata:ReadByte();				-- 位置
		local usLevel				= netdata:ReadShort();				-- 等级
		local btGradenet			= netdata:ReadByte();				-- 境界
		local unExp					= netdata:ReadInt();					-- 经验
		local unLife				= netdata:ReadInt();					-- 生命
		local unLifeLimit			= netdata:ReadInt();			-- 生命上限
		local unMana				= netdata:ReadInt();			-- 气势
		local unManaLimit			= netdata:ReadInt();			-- 气势上限
		local idSkill				= netdata:ReadInt();				-- 技能
		local usForce				= netdata:ReadShort();				-- 武力
		local nDexterity			= netdata:ReadShort();			-- 敏捷
		LogInfo("nDexterity"..nDexterity);
		
		local usMagic				= netdata:ReadShort();				-- 智力
		local usForceFoster			= netdata:ReadShort();			-- 武力培养
		local usSuperSkillFoster	= netdata:ReadShort();		-- 绝技培养
		local usMagicFoster			= netdata:ReadShort();			-- 法术培养
		local btForceElixir1		= netdata:ReadByte();			-- 一品武力丹
		local btForceElixir2		= netdata:ReadByte();			-- 二品武力丹
		local btForceElixir3		= netdata:ReadByte();			-- 三品武力丹
		local btForceElixir4		= netdata:ReadByte();		-- 四品武力丹
		local btForceElixir5		= netdata:ReadByte();			-- 五品武力丹
		local btForceElixir6		= netdata:ReadByte();			-- 六品武力丹
		local btSuperSkillElixir1	= netdata:ReadByte();	-- 一品绝技丹
		local btSuperSkillElixir2	= netdata:ReadByte();	-- 二品绝技丹
		local btSuperSkillElixir3	= netdata:ReadByte();	-- 三品绝技丹
		local btSuperSkillElixir4	= netdata:ReadByte();	-- 四品绝技丹
		local btSuperSkillElixir5	= netdata:ReadByte();	-- 五品绝技丹
		local btSuperSkillElixir6	= netdata:ReadByte();	-- 六品绝技丹
		local btMagicElixir1		= netdata:ReadByte();			-- 一品法术丹
		local btMagicElixir2		= netdata:ReadByte();			-- 二品法术丹
		local btMagicElixir3		= netdata:ReadByte();			-- 三品法术丹
		local btMagicElixir4		= netdata:ReadByte();			-- 四品法术丹
		local btMagicElixir5		= netdata:ReadByte();			-- 五品法术丹
		local btMagicElixir6		= netdata:ReadByte();			-- 六品法术丹
		local btImpart				= netdata:ReadByte();			-- 传承
		local btObtain				= netdata:ReadByte();			-- 被传承
		local nQuality              = netdata:ReadByte();			-- 品质
		
        local nPhysicalAtk			= netdata:ReadInt();			--武力攻击 物理攻击
		local nSpeed				= netdata:ReadInt();			--绝技攻击 速度
		--nSpeed = 99;
		
		local nMagicAtk				= netdata:ReadInt();			--法术攻击 策略攻击
		local nPhysicalDef			= netdata:ReadInt();			--武力防御 物理防御
		local nSkill_Def			= netdata:ReadInt();			--绝技防御
		local nMagicDef				= netdata:ReadInt();			--法术防御 策略防御
		
		local btDritical			= netdata:ReadShort();				-- 暴击
		local btHitrate				= netdata:ReadShort();				-- 命中
		local btWreck				= netdata:ReadShort();				-- 破击
		local btHurtAdd				= netdata:ReadShort();				-- 必杀  合击
		local btTenacity			= netdata:ReadShort();				-- 韧性
		local btDodge				= netdata:ReadShort();				-- 闪避
		local btBlock				= netdata:ReadShort();				-- 格挡

		local btHelp 					= netdata:ReadShort(); ----求援
		local btAtkType              = netdata:ReadShort();              -- 武将的前中后军（0：前军， 1：中军， 2：后军）
        	local btCamp 	  =netdata:ReadShort();	--阵营
		
		
		local strName				= netdata:ReadUnicodeString();
		

		
		RolePet.SetPetInfoN(idPet,PET_ATTR.PET_ATTR_HELP, btHelp);
		
		RolePet.SetPetInfoN(idPet,PET_ATTR.PET_ATTR_ID, idPet);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_TYPE, idType);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAIN, btMain);
		RolePet.SetPetInfoN(idPet,PET_ATTR.PET_ATTR_OWNER_ID, idOwner);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_POSITION, btPosition);
		RolePet.SetPetInfoN(idPet,PET_ATTR.PET_ATTR_LEVEL, usLevel);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_GRADE, btGradenet);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_EXP, unExp);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_LIFE, unLife);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_LIFE_LIMIT, unLifeLimit);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MANA, unMana);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MANA_LIMIT, unManaLimit);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SKILL, idSkill);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHYSICAL, usForce);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SUPER_SKILL,0); --绝技设定取消
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC, usMagic);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHY_FOSTER, usForceFoster);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SUPER_SKILL_FOSTER, usSuperSkillFoster);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC_FOSTER, usMagicFoster);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHY_ELIXIR1, btForceElixir1);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHY_ELIXIR2, btForceElixir2);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHY_ELIXIR3, btForceElixir3);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHY_ELIXIR4, btForceElixir4);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHY_ELIXIR5, btForceElixir5);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHY_ELIXIR6, btForceElixir6);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR1, btSuperSkillElixir1);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR2, btSuperSkillElixir2);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR3, btSuperSkillElixir3);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR4, btSuperSkillElixir4);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR5, btSuperSkillElixir5);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR6, btSuperSkillElixir6);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC_ELIXIR1, btMagicElixir1);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC_ELIXIR2, btMagicElixir2);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC_ELIXIR3, btMagicElixir3);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC_ELIXIR4, btMagicElixir4);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC_ELIXIR5, btMagicElixir5);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC_ELIXIR6, btMagicElixir6);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_IMPART, btImpart);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_OBTAIN, btObtain);
        RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_QUALITY, nQuality);
        
        LogInfo("chh_nQuality1:[%d]",nQuality);
        
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHY_ATK, nPhysicalAtk);
		
		
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SPEED, nSpeed);
		--RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_SPEED, nSpeed);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC_ATK, nMagicAtk);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_PHY_DEF, nPhysicalDef);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_DEX, nDexterity);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_MAGIC_DEF, nMagicDef);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_DRITICAL, btDritical);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_HITRATE, btHitrate);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_WRECK, btWreck);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_HURT_ADD, btHurtAdd);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_TENACITY, btTenacity);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_DODGE, btDodge);
		RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_BLOCK, btBlock);
        RolePet.SetPetInfoN(idPet, PET_ATTR.PET_ATTR_STAND_TYPE, btAtkType);
		RolePet.SetPetInfoS(idPet, PET_ATTR.PET_ATTR_NAME, strName);
		
		if not RolePetUser.IsExistPet(idOwner, idPet) then
			RolePetUser.AddPet(idOwner, idPet);
		end
		LogInfo(" PET_ATTR.PET_ATTR_DEX".. PET_ATTR.PET_ATTR_DEX);
		RolePet.LogOutPet(idPet);
		
		--todo刷新跟宠物相关的界面
		GameDataEvent.OnEvent(GAMEDATAEVENT.PETINFO, idPet);
		
		
		-- tInvitedPets表空则是login时
		if ( ( table.getn(tInvitedPets) > 0 ) and ( idOwner == nPlayerID ) ) then
			if idPet == nPlayerPetID then
				--引导任务事件触发 --选定技能事件
				GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.EXCHANGE_SKILL,idSkill);				
			end
		end
		
		--
		if ( idPet == nPlayerPetID ) then
			nNewLevel	= usLevel;
		else
			--武将升级事件
			--引导任务事件触发
			GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.STRENGTHEN_PET,usLevel);
		end
	end
	
	if ( nPlayerLevel < nNewLevel ) then
		-- 主角升级
    	local pScene = GetSMGameScene();
    	if ( pScene ~= nil ) then
    		local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.MainUITop );
    		if ( pLayer ~= nil and pLayer:IsVisibled() ) then
				PlayEffectAnimation.ShowAnimation(2);
    			Music.PlayEffectSound(Music.SoundEffect.LEVUP);
                
                --Buff刷新
                Buff.SendRequest();
        
    		else
    			p.bShowLevelUpAnimation = true;--先置状态到特定界面里播放++Guosen 2012.8.6 有待判定战斗中
    		end
    	end
	end
	

	
end

--++Guosen 2012.8.6 
-- 播放升级光效和声音--当主角升级过却当时未能播升级光效此时播放--已升级，但是必须在特定的界面里播放提示光效和音效--比如战斗结算界面
function p.ShowLevelUpAnimation()
	if ( p.bShowLevelUpAnimation == true ) then
		PlayEffectAnimation.ShowAnimation(2);
    	Music.PlayEffectSound(Music.SoundEffect.LEVUP);
		p.bShowLevelUpAnimation = nil;
	end
end

--更新某个武将的信息
function p.ProcessPetInfoUpdate(netdata)
    --CloseLoadBar();
	LogInfo("MsgRolePet: p.ProcessPetInfoUpdate" );
	
	--获取主角等级
	local nPlayerId     = GetPlayerId();
	local mainpetid 	= RolePetUser.GetMainPetId(nPlayerId);
	local nLevOrigin	= RolePet.GetPetInfoN(mainpetid, PET_ATTR.PET_ATTR_LEVEL);--RolePetFunc.GetPropDesc(mainpetid, PET_ATTR.PET_ATTR_LEVEL);
	local nLevNow 		= 0;
	local nNewSkillId	= 0;

	
	local petId					= netdata:ReadInt();
	local btNum					= netdata:ReadByte();
	
	--LogInfo("p.ProcessPetInfoUpdate btNum[%d]", btNum);
	
	if btNum <= 0 then
		return 1;
	end
	
	local datalist				= {[1] = petId};
	for	i=1, btNum do	
		local usType = netdata:ReadShort();
		local unData = netdata:ReadInt();
		
		if usType == PET_ATTR.PET_ATTR_LEVEL then
			LogInfo("p.ProcessPetInfoUpdate uplev unData"..unData)
			nLevNow = unData;
		end
		
		
		if usType == PET_ATTR.PET_ATTR_SKILL then
			LogInfo("p.ProcessPetInfoUpdate switch skill unData"..unData);
			nNewSkillId = unData;
		end
		
		RolePet.SetPetInfoN(petId,usType,unData);
		table.insert(datalist, usType);
		table.insert(datalist, unData);
		LogInfo("p.ProcessPetInfoUpdate usType:%d unData:%d", usType,unData);
	end
	
	if 1 < #datalist then
		GameDataEvent.OnEvent(GAMEDATAEVENT.PETATTR, datalist);
	end
	
	if mainpetid == petId then
		--主角升级
		if nLevOrigin < nLevNow then
			--成功光效
			PlayEffectAnimation.ShowAnimation(2);
			--成功音效    
    		Music.PlayEffectSound(Music.SoundEffect.LEVUP);
    		
    		--Buff刷新
    		Buff.SendRequest();
		end
		
		--主角切换技能
		if nNewSkillId ~= 0 then
			--引导任务事件触发
			GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.EXCHANGE_SKILL,nNewSkillId);			
		end
		
	else
		--其他武将升级
		--引导任务事件触发
		GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.STRENGTHEN_PET,nLevNow);
	end
end

--** chh 2012-08-25 **--
--处理招募下野反馈()
function p.ProcessPetShop(netdata)
    local btAction			= netdata:ReadByte();   --1,2,3
    local nPetId			= netdata:ReadInt();
	
	LogInfo( "MsgRolePet: ProcessPetShop() btAction:%d, nPetId:%d", btAction,nPetId );
    if( btAction == MSG_PET_SHOP_ACT_BUY or btAction == MSG_PET_SHOP_ACT_BUY_BACK ) then
        --PlayEffectAnimation.ShowAnimation(6);
		if ( GetSMGameScene() ~= nil ) then
			RoleInvite.InviteSucess( btAction, nPetId  );
    	    --音效
    	    Music.PlayEffectSound(Music.SoundEffect.RECRUIT);
    	    --引导任务事件触发
			GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.RECRUIT_PET);
		end
    end
    
    CloseLoadBar();
end


RegisterNetMsgHandler(NMSG_Type._MSG_PET_SHOP_ACTION, "p.ProcessPetShop", p.ProcessPetShop);


RegisterNetMsgHandler(NMSG_Type._MSG_PETINFO_UPDATE, "p.ProcessPetInfoUpdate", p.ProcessPetInfoUpdate);
RegisterNetMsgHandler(NMSG_Type._MSG_PETINFO, "p.ProcessPetInfo", p.ProcessPetInfo);