---------------------------------------------------
--描述: 将星图数据处理
--时间: 2012.6.5
--作者: qbw
---------------------------------------------------
   
HeroStar = {}
local p = HeroStar;

p.FrontPosition = 1;
p.MidPosition 	= 2;
p.BackPosition 	= 3; 


--设置星图数据
function p.SetRoleHeroStarData(nRoleId,nGrade,nLev)
	SetGameDataN(NScriptData.eRole,nRoleId,NRoleData.eHeroStar,nGrade,HEROSTAR_DATA.LEVEL,nLev);
end

--获取对应星图等级
function p.GetLevByGrade(nRoleId,nGrade)
	local level = GetGameDataN(NScriptData.eRole,nRoleId,NRoleData.eHeroStar,nGrade,HEROSTAR_DATA.LEVEL)
	return level;
end


--获取对应星星属性,返回属性表 （配置gsconfig.ini）
function p.GetStarAttr(nGrade,nLev)
	local tIdlist = _G.GetDataBaseIdList("gsconfig"); 
	local nStarid = p.GetIdByPosition(nGrade,nLev);
	
	--LogInfo("nStarid:"..nStarid);
	
	if(nStarid == nil ) then
		return nil;
	end
	
	local tAttr = {};
	
	tAttr[DB_GSCONFIG.LEVEL_LIMIT] 		= _G.GetDataBaseDataN("gsconfig", nStarid, DB_GSCONFIG.LEVEL_LIMIT);
	
	
	tAttr[DB_GSCONFIG.ATTR1]			= _G.GetDataBaseDataN("gsconfig", nStarid, DB_GSCONFIG.ATTR1);
	tAttr[DB_GSCONFIG.VALUE1]			= _G.GetDataBaseDataN("gsconfig", nStarid, DB_GSCONFIG.VALUE1);
	tAttr[DB_GSCONFIG.ATTR2]			= _G.GetDataBaseDataN("gsconfig", nStarid, DB_GSCONFIG.ATTR2);
	tAttr[DB_GSCONFIG.VALUE2]			= _G.GetDataBaseDataN("gsconfig", nStarid, DB_GSCONFIG.VALUE2);
	tAttr[DB_GSCONFIG.STATION_EFFECT]	= _G.GetDataBaseDataN("gsconfig", nStarid, DB_GSCONFIG.STATION_EFFECT);
	tAttr[DB_GSCONFIG.EFFECT_VALUE]		= _G.GetDataBaseDataN("gsconfig", nStarid, DB_GSCONFIG.EFFECT_VALUE);
	tAttr[DB_GSCONFIG.SKILL]			= _G.GetDataBaseDataN("gsconfig", nStarid, DB_GSCONFIG.SKILL);
	
	return tAttr;
end



local tAttrTypeDesc = {}
	tAttrTypeDesc[0] = "";
	tAttrTypeDesc[1] = "力量";
	tAttrTypeDesc[2] = "敏捷";
	tAttrTypeDesc[3] = "智力";
	tAttrTypeDesc[4] = "生命";
	tAttrTypeDesc[5] = "力量成长率";
	tAttrTypeDesc[6] = "敏捷成长率";
	tAttrTypeDesc[7] = "智力成长率";
	tAttrTypeDesc[8] = "生命成长率";
	tAttrTypeDesc[9] = "物理攻击";
	tAttrTypeDesc[10] = "物理防御";
	tAttrTypeDesc[11] = "法术攻击";
	tAttrTypeDesc[12] = "法术防御";
	tAttrTypeDesc[13] = "速度";
	tAttrTypeDesc[14] = "命中率";
	tAttrTypeDesc[15] = "闪避率";
	tAttrTypeDesc[16] = "暴击率";
	tAttrTypeDesc[17] = "抗暴率";
	tAttrTypeDesc[18] = "格挡率";
	tAttrTypeDesc[19] = "破击率";
	tAttrTypeDesc[20] = "合击率";
	tAttrTypeDesc[21] = "求援率";
	tAttrTypeDesc[22] = "士气";

local tAttrAdjTypeDesc = {}
	tAttrAdjTypeDesc[0] = "";
	tAttrAdjTypeDesc[1] = "增加%s";
	tAttrAdjTypeDesc[2] = "减少%s";
	tAttrAdjTypeDesc[3] = "加成%s";
	tAttrAdjTypeDesc[4] = "减成%s";


--修正属性  增加和减少不做处理 
function p.AdjAttr(nOriginVal,nAdjVal,adjtype)

	if adjtype == 1 then
		nOriginVal  = nOriginVal + nAdjVal; --+ nAdjVal;
	elseif adjtype == 2 then
		nOriginVal  = nOriginVal - nAdjVal; --- nAdjVal;
	elseif adjtype == 3 then
		nOriginVal  = nOriginVal + nAdjVal;
	elseif adjtype == 4 then
		nOriginVal  = nOriginVal - nAdjVal;
	end
	return nOriginVal;
end



--获取属性描述
function p.GetAttrName(nAttrType)
	--错误属性id
	if tAttrTypeDesc[nAttrType] == nil then
		LogInfo(" p.GetAttrName(nAttr)	wrong Attr:"..nAttr)
		return nil
	end
	
	--无值
	if  tAttrTypeDesc[nAttrType] == "" then
		return nil
	end 
	
	local sRtn =  tAttrTypeDesc[nAttrType];
	return sRtn;
end

--获取属性修正描述
function p.GetAttrDesc(nAttr)

	local nAttrType = math.floor(nAttr/10);
	local nAdjType = nAttr%10;
		
	--错误属性id
	if tAttrAdjTypeDesc[nAdjType] ==nil or tAttrTypeDesc[nAttrType] == nil then
		LogInfo(" p.GetAttrDesc(nAttr)	wrong Attr:"..nAttr)
		return nil
	end
	
	--无值
	if  tAttrAdjTypeDesc[nAdjType] == "" or tAttrTypeDesc[nAttrType] == "" then
		return nil
	end 
	
	local sRtn =  tAttrTypeDesc[nAttrType]..tAttrAdjTypeDesc[nAdjType];
	return sRtn;
end

--获取对应星星消耗将魂数值 （配置gsconfig.ini）
function p.GetStarSoulNeed(nGrade,nLev)	
	
	local tIdlist = _G.GetDataBaseIdList("gsconfig"); 
	local nStarid = p.GetIdByPosition(nGrade,nLev);
	if(nStarid == nil ) then
		LogInfo(" p.GetStarSoulNeed1 nStarid nil")
		return nil;
	end


	
	local nSoul  =  _G.GetDataBaseDataN("gsconfig", nStarid, DB_GSCONFIG.COST_GHOST);
	
	if CheckN(nSoul) then
		LogInfo(" p.GetStarSoulNeed soul not N");
	end
	
	if nSoul == nil then
		LogInfo(" p.GetStarSoulNeed soul nil")
		return 0;
	end
	
	return nSoul;			
end


--获取对应星星的id
function p.GetIdByPosition(nGrade,nLev)
	local tIdlist = _G.GetDataBaseIdList("gsconfig"); 

	
	for i,id in pairs(tIdlist) do
		--LEV

		local  nRank  = _G.GetDataBaseDataN("gsconfig",id,DB_GSCONFIG.RANK);
		--GRADE

		local  nType  = _G.GetDataBaseDataN("gsconfig",id,DB_GSCONFIG.TYPE);

		if nRank == nLev and nType == nGrade then
			return id;
		end
		
	end	

	return nil;
end



local tStationDesc = {}
	tStationDesc[0] ={"",""}
	tStationDesc[1] ={"中军增伤",p.MidPosition}
	tStationDesc[2] ={"前军生命",p.FrontPosition }
	tStationDesc[3] ={"前军免伤",p.FrontPosition }
	tStationDesc[4] ={"后军增速",p.BackPosition}
	tStationDesc[5] ={"前军回血",p.FrontPosition}

--获取阵型加成描述  返回 1描述，2位置
function p.GetStationBuffDesc(nStationEffect)
	if tStationDesc[nStationEffect][1] == nil then 
		LogInfo(" p.GetStationBuffDesc(nStationEffect)	wrong nStationEffect:"..nStationEffect)
		return nil,nil;
	end
	 
	 return tStationDesc[nStationEffect][1],tStationDesc[nStationEffect][2];
	 
end


--提示升级
p.UserInfoReady = false;
p.HeroInfoReady = false;
p.EffectSprite	= nil;
function p.HeroStarTip()
	if p.HeroInfoReady == false then
		return;
	end
	
	--是否满足升级条件
	local nRoleId =  GetPlayerId();
	
	local nGrade,nLev,bTopLev = HeroStarUI.GetNextStarPosition();
	
	--满级则不提示
	if bTopLev then
		return;
	end
	
	local nSoulNeed = HeroStar.GetStarSoulNeed(nGrade,nLev);
	local nSoul = GetRoleBasicDataN(nRoleId, USER_ATTR.USER_ATTR_SOPH);
	
	--未开启功能 返回
	if false == MainUIBottomSpeedBar.GetFuncIsOpen(115) then
		return;
	end

	
	if nSoul >= nSoulNeed then

		local btn = MainUIBottomSpeedBar.GetFuncBtn(115);
		
		if btn == nil then
			LogInfo("HeroStarTip 1")
			return;
		end
		
        local pSpriteNode = ConverToSprite( GetUiNode( btn, 99 ) );
    	if ( pSpriteNode ~= nil ) then
    		return;
    	end  

		local pSpriteNode	= createUISpriteNode();
		
		
		local btnrect = btn:GetFrameRect();
		local btnWidth =btnrect.size.w;
		local btnHeight = btnrect.size.h;

		pSpriteNode:Init();
		local szAniPath		= NDPath_GetAnimationPath();
		local szSprFile		= "gongn01.spr";
		
		pSpriteNode:ChangeSprite( szAniPath .. szSprFile );
		pSpriteNode:SetFrameRect( CGRectMake(-btnWidth*0.1,0,btnWidth,btnHeight) );
		pSpriteNode:SetScale(0.7);
		
		pSpriteNode:SetTag( 99 );
	
		--加到星星node上
    	btn:AddChild( pSpriteNode );
    	p.EffectSprite = pSpriteNode;
	else
		LogInfo("HeroStarTip nGrade nLev nSoulNeed nSoul"..nGrade.." "..nLev.." "..nSoulNeed.." "..nSoul);
		p.RemoveEffect();
		
	end
end

function p.UserInfoUpdate()
	p.UserInfoReady = true;
	p.HeroStarTip();
end

function p.HeroInfoUpdate()
	p.HeroInfoReady = true;
	p.HeroStarTip();
end

function p.Reset()
	p.UserInfoReady = false;
	p.HeroInfoReady = false;
	p.EffectSprite = nil;
end


function p.RemoveEffect()
	if p.EffectSprite == nil then
		return;
	end
    
    local effectspr = p.EffectSprite;
    LogInfo("HeroStarTip RemoveEffect 1");
    effectspr:RemoveFromParent( true );
    p.EffectSprite	= nil;
	
	
end

--检测将星是否可以升级
function p.CheckHeroStarCanUpLev()
	--是否满足升级条件
	local nRoleId =  GetPlayerId();
	local nGrade,nLev = HeroStarUI.GetNextStarPosition();
	local nSoulNeed = HeroStar.GetStarSoulNeed(nGrade,nLev);
	local nSoul = GetRoleBasicDataN(nRoleId, USER_ATTR.USER_ATTR_SOPH);
	LogInfo("p.CheckHeroStarCanUpLev nSoul"..nSoul.." nSoulNeed"..nSoulNeed.." nGrade nlev"..nGrade.." "..nLev);
	--未开启功能 返回
	if false == MainUIBottomSpeedBar.GetFuncIsOpen(115) then
		return false;
	end
	
	if nSoul < nSoulNeed then
		return false;
	end
	
		
	return true;
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "HeroStar.HeroStarTip", p.HeroStarTip);
GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"HeroStar.UserInfoUpdate",p.UserInfoUpdate);
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_LOGIN_GAME, "HeroStar.Reset", p.Reset);
































