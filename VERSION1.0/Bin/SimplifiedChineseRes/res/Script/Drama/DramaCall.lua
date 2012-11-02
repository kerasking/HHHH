---------------------------------------------------
--描述: 剧情调用点
--时间: 2012.4.20
--作者: jhzheng
---------------------------------------------------

local p = Drama; 

local mDramaPlaying = false;
--副本id
local nBossId = 0;

function p.SetBossId(nId)
	nBossId = nId;
end




--[[
p.SpriteTypePlayer				= 1;
p.SpriteTypeNpc					= 2;
p.SpriteTypeMonster				= 3;

p.DramType = 
{
	BATTLE_START = 1,
	BATTLE_END 	 = 2,
	TASK_START	 = 3,
	TASK_END 	 = 4,
}

--剧情播放表
p.DramPlayFuncTable = {}; 
p.DramPlayFuncTable[1]= {1,50002,900100000,0,p.MainDrama_6};
p.DramPlayFuncTable[2]= {2,50002,900100000,0,p.MainDrama_7};
 --]]


--desc:		副本里所有怪都打完,掉宝箱之前调用
--ret:		true 条件满足播放剧情, false 条件不满足不播放剧情

--desc:		进入副本时调用
--param:	副本id
--ret:		true 条件满足播放剧情, false 条件不满足不播放剧情
--[[
function p.OnEnterBattleInstace(nInstanceId)
	if not CheckT(p.DramPlayFuncTable) or not CheckN(nInstanceId) then
		LogInfo("p.OnEnterBattleInstace DramPlayFuncTable not table or instance not N")
		return false;
	end
	

    if p.DramPlayFuncTable == nil then
         LogInfo("p.OnEnterBattleInstace1 table nil")
    
    end
    
	for i, v in ipairs(p.DramPlayFuncTable) do
		local t	= v;
		if not CheckT(t) then

			continue;
		end
		
		if 4 > #t then

             _G.LogInfoT(t)
			continue;
		end

		--剧情函数判断
		local dramafunc = t[5];
		if not CheckFunc(dramafunc) then


			continue;
		end
		
		--副本id 判断
		if not CheckN(t[3]) or t[3] ~= nInstanceId then
			continue;
		end

		LogInfo(".....副本ok....");
		
		--进入副本判断
		if not CheckN(t[1]) or t[1] ~= 1 then
			continue;
		end
		

		LogInfo(".....进入副本判断ok....");
		
		--任务判断
		if not CheckN(t[2]) then
			continue;
		end
		
		--任务不存在

		
		if 0 ~= t[2] and not TASK.IfTaskExist(t[2]) then
			continue;
		end

		
		LogInfo(".....任务判断ok....");
		
		dramafunc();
		
		return true;
	end
	
	return false;
end
--]]

function p.OnEnterBattleInstace(nInstanceId)
	return p.DramaBegin(p.DramType.BATTLE_START,nInstanceId)
end


function p.OnEnterBattleEndInstace(nInstanceId)
	return p.DramaBegin(p.DramType.BATTLE_END,nInstanceId)
end

function p.OnFinishTask(nTaskId)
	return	p.DramaBegin(p.DramType.TASK_END,nTaskId)
end

function p.OnBeginTask(nTaskId)
	return p.DramaBegin(p.DramType.TASK_START,nTaskId)
end

--剧情触发接口  1：剧情类型 2：参数  返回是否播放
function p.DramaBegin(nDramaType,nParam)
	--[[p.DramType = 
	{
	BATTLE_START = 1;
	BATTLE_END 	 = 2;
	TASK_START	 = 3;--]]

	if not CheckT(p.DramPlayFuncTable) or not CheckN(nParam) then
		LogInfo("p.OnEnterBattleInstace param:"..nParam)
		LogInfo("p.OnEnterBattleInstace DramPlayFuncTable not table or instance not N")
		return false;
	end
	

    if p.DramPlayFuncTable == nil then
         LogInfo("p.OnEnterBattleInstace1 table nil")
    
    end
     LogInfo("p.OnEnterBattleInstace")
	for i, v in ipairs(p.DramPlayFuncTable) do

		local t	= v;
		
	
		if  CheckT(t) then

			if 5 <= #t then

				if nDramaType == t[1] then

					--剧情函数判断
					local dramafunc = t[5];
					if  CheckFunc(dramafunc) then
						LogInfo("p.OnEnterBattleInstace4")
						if CheckN(t[2]) then
							LogInfo("p.OnEnterBattleInstace41 t[2]"..t[2])
							if 0 == t[2] or  TASK.IfTaskExist(t[2]) then
								--战斗开始
								LogInfo("p.OnEnterBattleInstace4 t3"..t[3].."  nparam:"..nParam)
								if  (nDramaType == p.DramType.BATTLE_START ) and CheckN(t[3]) and t[3] == nParam then									
									--已播放过1次 不播放（重启后再次挑战还是会播放）
									if t[4] ~= 0 then
										return false;
									end
									
									p.DramPlayFuncTable[i][4] = 1; 
									LogInfo("p.OnEnterBattleInstace5")
									dramafunc();
									return true;
								end
								
								--战斗结束
								if  ( nDramaType == p.DramType.BATTLE_END) and CheckN(t[3]) and t[3] == nParam then
									--已播放过1次 不播放（重启后再次挑战还是会播放）
									if t[4] ~= 0 then
										return false;
									end
									
									p.DramPlayFuncTable[i][4] = 1; 								
								
									LogInfo("p.OnEnterBattleInstace5")
									dramafunc();
									return true;
								end								
								
								
								
							end
							
							--接受任务
							if  nDramaType == p.DramType.TASK_START and t[2] == nParam then
								if TASK.IfTaskExist(t[2]) then
									LogInfo("p.OnEnterBattleInstace6")
									dramafunc();
									return true;
								end
							end							
							
							--完成任务
							if   nDramaType == p.DramType.TASK_END and t[2] == nParam then
								 	
									LogInfo("p.OnEnterBattleInstace7")
									dramafunc();
									return true;
								
							end								
						end
					
					end
				end	
			end
		end

		--[[
		--任务已经完成
		if 0 ~= t[2] and TASK.IsComplete(t[2]) then
			continue;
		end
		--]]
		
	end
	
	return false;

end


function p.IfDramaPlaying()	
	return mDramaPlaying;
end

function p.DramaEnd()
	mDramaPlaying = false;
end

function p.DramaStart()
	mDramaPlaying = true;
end

function p.GlobalEventBattleBegin()
    
	local nMapInstanceId = nBossId;--_G.GetMapInstanceId();
    LogInfo("drama.GlobalEventBattleBegin nMapInstanceId:"..nMapInstanceId);
	if not CheckN(nMapInstanceId) or nMapInstanceId <= 0 then
		return;
	end
	
	LogInfo("drama.GlobalEventBattleBegin 副本id[%d]", nMapInstanceId);
	if p.OnEnterBattleInstace(nMapInstanceId)== true then
		--暂停战斗场景
		LogInfo("drama DramaStart")
		p.DramaStart();
		
	end
end

local BATTLE_COMPLETE =
{
	BATTLE_COMPLETE_LOSE = 0,
	BATTLE_COMPLETE_WIN = 1,
	BATTLE_COMPLETE_NO = 2,
	BATTLE_COMPLETE_END = 3,
};


--播放则返回true 否则返回false
function p.GlobalEventBattleEnd(param1,param2,param3)
	local battleresult = param1;
	if battleresult ~= BATTLE_COMPLETE.BATTLE_COMPLETE_WIN then
		return false;
	end
	
	
 	local nMapInstanceId = nBossId;--_G.GetMapInstanceId();
    LogInfo("drama.GlobalEventBattleEnd nMapInstanceId:"..nMapInstanceId);
	if not CheckN(nMapInstanceId) or nMapInstanceId <= 0 then
		return false;
	end
	
	LogInfo("drama.GlobalEventBattleEnd 副本id[%d]", nMapInstanceId);
	if p.OnEnterBattleEndInstace(nMapInstanceId)== true then
		--暂停战斗场景
		LogInfo("drama DramaStart")
		p.DramaStart();
		return true;
	end
	
	return false;
	
end

_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_BATTLE_BEGIN, "Drama.GlobalEventBattleBegin", p.GlobalEventBattleBegin);
--_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_BATTLE_END, "Drama.GlobalEventBattleEnd", p.GlobalEventBattleEnd);
--_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_GENERATE_GAMESCENE, "Drama.GlobalEvent", p.GlobalEvent)










