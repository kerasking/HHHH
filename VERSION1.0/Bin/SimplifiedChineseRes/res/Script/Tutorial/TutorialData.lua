---------------------------------------------------
--描述: 教程数据配置
--时间: 2012.07.12
--作者: chh
---------------------------------------------------

TutorialData = {}
local p = TutorialData;

local HandleTime = 1/24;
local Wait_Time    = 1200;
p.HandleTimerBegin = nil;
p.HandleTimerEnd = nil;
p.HandleTimerIsComplete = nil;

p.GuideConfigIds = GetDataBaseIdList("guide_config");
p.JtWidth   = 128*ScaleFactor;
p.JtHeight  = 128*ScaleFactor;

--[[
p.JtTagNum     = 2489;--前头Tag
p.GxTagNum     = 2490;--光效Tag
]]

--技能新手的stage在失败时提示
p.SkillStages = {
    90,130,200,
}; 

p.JtTag     = 4784321;--前头Tag
p.GxTag     = 4784322;--光效Tag
p.BoxTag    = 4784323;--文本框
p.TxtTag    = 2;    
p.TipSize   = CGSizeMake(80*ScaleFactor,40*ScaleFactor);

TutorialType = {
    UP = "jiants03.spr",
    DOWN = "jiantx03.spr",
    LEFT = "jiantz03.spr",
    RIGHT = "jianty03.spr",
}

--任务的开始判断
function p.TaskBegin()
    LogInfo("p.TaskBegin");
    
    if(p.IsPlaySkillTutorial()) then
        LogInfo("技能新手引导，等待失败播放！");
        return;
    end
    
    
    local nPlayerid = GetPlayerId();
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_STAGE));
    local nPlayerGuideStage	= _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_GUIDE_STAGE));
    
    LogInfo("nPlayerStage:[%d],nPlayerGuideStage:[%d]",nPlayerStage,nPlayerGuideStage); 
    
    --判断是否开启新手引导功能
    if(nPlayerStage==nPlayerGuideStage) then
        if(MainUIBottomSpeedBar) then
            LogInfo("add scroll!");
            MainUIBottomSpeedBar.refreshScroll();
            MainUI.RefreshFuncIsOpen();
        end
    
        p.ClearTask();
        
        local nCurrId = p.StageFindId(nPlayerStage);
        LogInfo("nCurrId:[%d],#p.GuideConfigIds:[%d]",nCurrId,#p.GuideConfigIds);
        if(nCurrId > 0) then
            
            --保存新手引导的数据
            p.SaveStage(nPlayerStage);
            
            --开启新手引导
            p.StartTutorial(nPlayerStage);
            
        end
    end
end

--战斗失败新手引导
function p.BattleFailEvent()
    LogInfo("p.BattleFailEvent");
    if(p.IsPlaySkillTutorial()) then
        LogInfo("p.BattleFailEvent true");
        p.ClearTask();
        local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_STAGE));
        p.StartTutorial(nPlayerStage);
    end
end

--是否播放切换技能新手引导
function p.IsPlaySkillTutorial()
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_STAGE));
    for i,v in ipairs(p.SkillStages) do
        if(v == nPlayerStage) then
            return true;
        end
    end
    return false;
end

--保存新手引导的数据
function p.SaveStage(nPlayerStage)
    local nCurrId = p.StageFindId(nPlayerStage);
    local nNextSerStage;
    local nNextSerStageId = nCurrId + 1;
    if(nNextSerStageId>#p.GuideConfigIds) then
        nNextSerStage = nPlayerStage + 1;
    else
        nNextSerStage = GetDataBaseDataN("guide_config",nNextSerStageId,DB_GUIDE_CONFIG.STAGE);
    end
    LogInfo("nNextSerStage:[%d]",nNextSerStage);
    
    local nPlayerid = GetPlayerId();
    _G.SetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_GUIDE_STAGE, nNextSerStage)
    MsgTutorial.sendProgress(nNextSerStage);
end


--开始新手引导教程
function p.StartTutorial(nPlayerStage)
    LogInfo("p.StartTutorial nPlayerStage:[%d]",nPlayerStage);
    p.CurrTask.KeyItem = nPlayerStage;
    
    if(p.DataInfo[p.CurrTask.KeyItem] == nil) then
        LogInfo("p.DataInfo[p.CurrTask.KeyItem] == nil");
    end
    
    p.DataInfo[p.CurrTask.KeyItem].BeginFunc();
    
    --p.DataInfo[p.CurrTask.KeyItem].EndFunc();
end


--根据Stage查找他在ini中的ID
function p.StageFindId(nStage)
    LogInfo("nStage:[%d]",nStage);
    for i,v in ipairs(p.GuideConfigIds) do
        LogInfo("p.StageFindId stage:[%d]",v);
        local nDbStage = GetDataBaseDataN("guide_config",v,DB_GUIDE_CONFIG.STAGE);
        if(nStage == nDbStage) then
            return v;
        end
    end
    return 0;
end


--清理任务
function p.ClearTask()
    LogInfo("p.ClearTask");
    p.CurrTaskEnd();

    p.CurrTask.KeyItem  = 0;
    p.CurrTask.SubItem  = 0;
    if(p.HandleTimerBegin) then
        LogInfo("p.HandleTimerBegin clear!");
        --UnRegisterTimer(p.HandleTimerBegin);
        --p.HandleTimerBegin      = nil;
    end
    
    if(p.HandleTimerEnd) then
        LogInfo("p.HandleTimerEnd clear!");
        --UnRegisterTimer(p.HandleTimerEnd);
        --p.HandleTimerEnd        = nil;
    end
    
    if(p.HandleTimerIsComplete) then
        LogInfo("p.HandleTimerIsComplete clear!");
        --UnRegisterTimer(p.HandleTimerIsComplete);
        --p.HandleTimerIsComplete = nil;
    end
end


function p.DealProgress()
    LogInfo("p.DealProgress p.CurrTask.SubItem:[%d]",p.CurrTask.SubItem);
    if(p.CurrTask.SubItem / 2 >=  p.GetCurrTaskCount()) then
        LogInfo("p.DealProgress stop! p.GetCurrTaskCount():[%d]",p.GetCurrTaskCount());
        p.DataInfo[p.CurrTask.KeyItem].EndFunc(true);
        
        if(p.HandleTimerIsComplete) then
            UnRegisterTimer(p.HandleTimerIsComplete);
            p.HandleTimerIsComplete = nil;
        end
        return;
    end
    
    local deal = p.CurrTask.SubItem % 2;
    
    if(deal == 0) then  --任务开始
        LogInfo("当前教程任务开始");
        
        p.CurrTaskBegin();
        p.CurrTask.SubItem = p.CurrTask.SubItem + 1;
        p.DealProgress();
    else                                                --判断任务结束
        if(p.CurrTaskIsComplete()) then                 --当前任务结束进入下一教程
            LogInfo("当前教程任务判断结束");
            p.CurrTaskEnd();
            if(p.HandleTimerIsComplete) then
                UnRegisterTimer(p.HandleTimerIsComplete);
                p.HandleTimerIsComplete = nil;
            end
            
            p.CurrTask.SubItem = p.CurrTask.SubItem + 1;
            p.DealProgress();
        else                                            --任务未结束
            --判断任务是否退出
            if(p.CurrTaskExitCond()) then
                LogInfo("当前教程任务是否退出（是）");
                p.CurrTaskEnd();
                if(p.HandleTimerIsComplete) then
                    UnRegisterTimer(p.HandleTimerIsComplete);
                    p.HandleTimerIsComplete = nil;
                end
                return;
            end
            
            LogInfo("p.CurrTaskIsComplete false");
            if(p.HandleTimerIsComplete == nil) then
                LogInfo("p.HandleTimerIsComplete is nil");
                p.HandleTimerIsComplete = RegisterTimer(p.DealProgress, HandleTime);
            end
        end
    end
end

--执行当前教程的开始
function p.CurrTaskBegin()
    local idx = math.floor(p.CurrTask.SubItem/2)+1;
    LogInfo("p.CurrTaskBegin idx:[%d]",idx);
    
    local KI = p.DataInfo[p.CurrTask.KeyItem];
    if(KI) then
        local KIT = KI.Task[idx];
        if(KIT) then
            return KIT.Begin();
        end
    end
    --p.DataInfo[p.CurrTask.KeyItem].Begin();
end

--执行当前教程的结束
function p.CurrTaskEnd()
    local idx = math.floor(p.CurrTask.SubItem/2)+1;
    LogInfo("p.CurrTaskEnd idx:[%d]",idx);
    
    local KI = p.DataInfo[p.CurrTask.KeyItem];
    if(KI) then
        local KIT = KI.Task[idx];
        if(KIT) then
            return KIT.End();
        end
    end
    --p.DataInfo[p.CurrTask.KeyItem].Task[idx].End();
end

--判断当前教程是否结束
function p.CurrTaskIsComplete()
    local idx = math.floor(p.CurrTask.SubItem/2)+1;
    
    local KI = p.DataInfo[p.CurrTask.KeyItem];
    if(KI) then
        local KIT = KI.Task[idx];
        if(KIT) then
            return KIT.IsComplete();
        end
    end
    
    --return p.DataInfo[p.CurrTask.KeyItem].Task[idx].IsComplete();
end

--判断当前教程是否退出
function p.CurrTaskExitCond()
    local idx = math.floor(p.CurrTask.SubItem/2)+1;
    
    local KI = p.DataInfo[p.CurrTask.KeyItem];
    if(KI) then
        local KIT = KI.Task[idx];
        if(KIT) then
            return KIT.ExitCond();
        end
    end
    
    --return p.DataInfo[p.CurrTask.KeyItem].Task[idx].ExitCond();
end

--获得当前教程的数量
function p.GetCurrTaskCount()
    return #p.DataInfo[p.CurrTask.KeyItem].Task;
end

--获得当前任务信息
function p.GetCurrTaskItem()
    local idx = math.floor(p.CurrTask.SubItem/2)+1;
    LogInfo("idx:[%d],p.CurrTask.SubItem:[%d],p.CurrTask.KeyItem:[%d]",idx,p.CurrTask.SubItem,p.CurrTask.KeyItem);
    
    
    return p.DataInfo[p.CurrTask.KeyItem].Task[idx];
end



-------------------------------------引导 000 开始-----------------------------------------------

function p.Stage000Begin()
    LogInfo("p.Stage000Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
            p.DealProgress();
        end
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage000Begin, HandleTime);
        end
    end
end

---------00------------
function p.Stage00000Begin()
    LogInfo("p.Stage00000Begin");
    local mapLayer=GetMapLayer();
    p.BeginTemplete(mapLayer);
end

function p.Stage00000End()
    LogInfo("p.Stage00000End");
    local mapLayer=GetMapLayer();
    
    if(mapLayer) then
        p.EndTemplete(mapLayer);
    else
        p.ClearTemplete();
    end
end

function p.Stage00000IsComplete()
    LogInfo("p.Stage00000IsComplete");
    
    local nPlayerid = GetPlayerId();
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_STAGE));
    
    LogInfo("nPlayerStage:[%d]",nPlayerStage);
    if(nPlayerStage and nPlayerStage == 10) then
        return true;
    end
    
    return false;
end


function p.Stage00000ExitCond()
    LogInfo("p.Stage00000ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end


-----------01------------
function p.Stage00001Begin()
    LogInfo("p.Stage00001Begin");
    p.BeginTemplete();
end

function p.Stage00001End()
    LogInfo("p.Stage00001End");
    p.EndTemplete();
end

function p.Stage00001IsComplete()
    LogInfo("p.Stage00001IsComplete");
    
    local nPlayerid = GetPlayerId();
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_STAGE));
    
    if(nPlayerStage and nPlayerStage == 11) then
        return true;
    end
    
    return false;
end

function p.Stage00001ExitCond()
    LogInfo("p.Stage00001ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end

-----------02-------------
function p.Stage00002Begin()
    LogInfo("p.Stage00002Begin");
    local mapLayer=GetMapLayer();
    p.BeginTemplete(mapLayer);
end

function p.Stage00002End()
    LogInfo("p.Stage00002End");
    local mapLayer=GetMapLayer();
    
    if(mapLayer) then
        p.EndTemplete(mapLayer);
    else
        p.ClearTemplete();
    end
    
end

function p.Stage00002IsComplete()
    LogInfo("p.Stage00002IsComplete");
    
    local nPlayerid = GetPlayerId();
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_STAGE));
    
    if(nPlayerStage and nPlayerStage == 20) then
        return true;
    end
    
    return false;
end

function p.Stage00002ExitCond()
    LogInfo("p.Stage00002ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end

--------------03------------
function p.Stage00003Begin()
    LogInfo("p.Stage00003Begin");
    p.BeginTemplete();
end

function p.Stage00003End()
    LogInfo("p.Stage00003End");
    p.EndTemplete();
end

function p.Stage00003IsComplete()
    LogInfo("p.Stage00003IsComplete");
    local isInCity = p.InRuoYanCity();
    return not isInCity;
end

function p.Stage00003ExitCond()
    LogInfo("p.Stage00003ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



--------------04------------
function p.Stage00004Begin()
    LogInfo("p.Stage00004Begin");
end

function p.Stage00004End()
    LogInfo("p.Stage00004End");
end

function p.Stage00004IsComplete()
    LogInfo("p.Stage00004IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.MonsterReward);
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end

function p.Stage00004ExitCond()
    LogInfo("p.Stage00004ExitCond");
    return false;
end


-----------05------------
function p.Stage00005Begin()
    LogInfo("p.Stage00005Begin");
    p.BeginTemplete();
end

function p.Stage00005End()
    LogInfo("p.Stage00005End");
    --p.ClearTemplete();
    p.EndTemplete();
end

function p.Stage00005IsComplete()
    LogInfo("p.Stage00005IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.MonsterReward);
        if(layer) then
            return not layer:IsVisibled();
        else
            return true;
        end
    end
    return false;
end

function p.Stage00005ExitCond()
    LogInfo("p.Stage00005ExitCond");
    return false;
end


--------------06------------
function p.Stage00006Begin()
    LogInfo("p.Stage00006Begin");
end

function p.Stage00006End()
    LogInfo("p.Stage00006End");
end

function p.Stage00006IsComplete()
    LogInfo("p.Stage00006IsComplete");
    return p.InRuoYanCity();
end

function p.Stage00006ExitCond()
    return false;
end




--------------07------------
function p.Stage00007Begin()
    LogInfo("p.Stage00007Begin");
    p.BeginTemplete();
end

function p.Stage00007End()
    LogInfo("p.Stage00007End");
    p.EndTemplete();
end

function p.Stage00007IsComplete()
    LogInfo("p.Stage00007IsComplete");
    
    local nPlayerid = GetPlayerId();
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_STAGE));
    
    if(nPlayerStage and nPlayerStage == 21) then
        return true;
    end
    return false;
end

function p.Stage00007ExitCond()
    LogInfo("p.Stage00007ExitCond");
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



function p.Stage000End(isComplete)
    LogInfo("p.Stage000End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end
-------------------------------------引导 000 结束-----------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------------------------------------引导 021 开始-----------------------------------------------
function p.Stage021Begin()
    LogInfo("p.Stage021Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage021Begin, HandleTime);
        end
    end
end





---------01------------
function p.Stage02101Begin()
    LogInfo("p.Stage02101Begin");
    p.BeginTemplete();
end

function p.Stage02101End()
    LogInfo("p.Stage02101End");
    p.EndTemplete();
end

function p.Stage02101IsComplete()
    LogInfo("p.Stage02101IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        
        if(layer) then
			LogInfo("p.Stage04105IsComplete true");
            return layer:IsVisibled();
        end
    end
	LogInfo("p.Stage02101IsComplete false");
    return false;
end


function p.Stage02101ExitCond()
    LogInfo("p.Stage02101ExitCond");
    
    if(p.InRuoYanCity() == false) then
        LogInfo("p.Stage02101ExitCond true");
        return true;
    end
    LogInfo("p.Stage02101ExitCond false");
    return false;
end



---------02------------
function p.Stage02102Begin()
    LogInfo("p.Stage02102Begin");
    p.BeginTemplete();
    
end

function p.Stage02102End()
    LogInfo("p.Stage02102End");
    p.EndTemplete();
end

function p.Stage02102IsComplete()
    LogInfo("p.Stage02102IsComplete");
    
    if PlayerUIBackBag.BagPos.TYPE == Item.bTypeProp then
        return true;
    end
    return false;
end


function p.Stage02102ExitCond()
    LogInfo("p.Stage02102ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end


---------03------------
function p.Stage02103Begin()
    LogInfo("p.Stage02103Begin");
    p.BeginTemplete();
end

function p.Stage02103End()
    LogInfo("p.Stage02103End");
    p.EndTemplete();
end

function p.Stage02103IsComplete()
    LogInfo("p.Stage02103IsComplete");
    
    local layer = BackLevelThreeWin.GetPropLayer();
    if(layer and layer:IsVisibled()) then
        LogInfo("p.Stage02103IsComplete true");
        return true;
    end
    LogInfo("p.Stage02103IsComplete false");
    return false;
end


function p.Stage02103ExitCond()
    LogInfo("p.Stage02103ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
            
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end


---------04------------
function p.Stage02104Begin()
    LogInfo("p.Stage02104Begin");
    p.BeginTemplete();
end

function p.Stage02104End()
    LogInfo("p.Stage02104End");
    p.EndTemplete();
end

function p.Stage02104IsComplete()
    LogInfo("p.Stage02104IsComplete");
    
    local layer = BackLevelThreeWin.GetPropLayer();
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end

function p.Stage02104ExitCond()
    LogInfo("p.Stage02104ExitCond");
    
    local layer = BackLevelThreeWin.GetPropLayer();
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end




---------05------------
function p.Stage02105Begin()
    LogInfo("p.Stage02105Begin");
    p.BeginTemplete();
end

function p.Stage02105End()
    LogInfo("p.Stage02105End");
    p.EndTemplete();
end

function p.Stage02105IsComplete()
    LogInfo("p.Stage02105IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene,BackLevelThreeWin.nTagId);
        if(layer == nil) then
            return true;
        end
    end
    return false;
end


function p.Stage02105ExitCond()
    LogInfo("p.Stage02105ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end



---------06------------
function p.Stage02106Begin()
    LogInfo("p.Stage02106Begin");
    p.BeginTemplete();
end

function p.Stage02106End()
    LogInfo("p.Stage02106End");
    p.EndTemplete();
end

function p.Stage02106IsComplete()
    LogInfo("p.Stage02106IsComplete");
    
    if PlayerUIBackBag.BagPos.TYPE == Item.bTypeEquip then
        return true;
    end
    return false;
end


function p.Stage02106ExitCond()
    LogInfo("p.Stage02106ExitCond");
    
    local scene = GetSMGameScene();
    if (scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    
    
    return false;
end




---------07------------
function p.Stage02107Begin()
    LogInfo("p.Stage02107Begin");
    p.BeginTemplete();
end

function p.Stage02107End()
    LogInfo("p.Stage02107End");
    p.EndTemplete();
end

function p.Stage02107IsComplete()
    LogInfo("p.Stage02107IsComplete");
    
    local layer = BackLevelThreeWin.GetEquipLayer();
    if(layer and layer:IsVisibled()) then
        LogInfo("p.Stage02107IsComplete true");
        return true;
    end
    
    
    --装备前移
    local nPlayerId = GetPlayerId();
    local nPetId = RolePetUser.GetMainPetId(nPlayerId);
    local nPetType = ConvertN(RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE));
    
    local nEquipTypeId = 0;
    local nJob = GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.PROFESSION);
    if nJob == PROFESSION_TYPE.SWORD then
		nEquipTypeId = 1101011;
	elseif nJob == PROFESSION_TYPE.CHIVALROUS then
		nEquipTypeId = 1102011;
	elseif nJob == PROFESSION_TYPE.FIST then
		nEquipTypeId = 1103011;
	elseif nJob == PROFESSION_TYPE.AXE then
		nEquipTypeId = 1101011;
	end
    LogInfo("nEquipTypeId:[%d]",nEquipTypeId);
    p.OrderItem(nEquipTypeId, nEquipTypeId);
    
    
    LogInfo("p.Stage02107IsComplete false");
    return false;
end


function p.Stage02107ExitCond()
    LogInfo("p.Stage02107ExitCond");
    
    local scene = GetSMGameScene();
    
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    
    return false;
end


---------08------------
function p.Stage02108Begin()
    LogInfo("p.Stage02108Begin");
    p.BeginTemplete();
end

function p.Stage02108End()
    LogInfo("p.Stage02108End");
    p.EndTemplete();
end

function p.Stage02108IsComplete()
    LogInfo("p.Stage02108IsComplete");
    
    local layer = BackLevelThreeWin.GetEquipLayer();
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    
    return false;
end


function p.Stage02108ExitCond()
    LogInfo("p.Stage02108ExitCond");
    
    local layer = BackLevelThreeWin.GetEquipLayer();
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage021End(isComplete)
    LogInfo("p.Stage021End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 021 结束-----------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------------------------------------引导 031 开始-----------------------------------------------

function p.Stage031Begin()
    LogInfo("p.Stage031Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage031Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage03101Begin()
    LogInfo("p.Stage03101Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage03101End()
    LogInfo("p.Stage03101End");
    p.EndTemplete();
end

function p.Stage03101IsComplete()
    LogInfo("p.Stage03101IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end


function p.Stage03101ExitCond()
    LogInfo("p.Stage03101ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------02------------
function p.Stage03102Begin()
    LogInfo("p.Stage03102Begin");
    p.BeginTemplete();
end

function p.Stage03102End()
    LogInfo("p.Stage03102End");
    p.EndTemplete();
end

function p.Stage03102IsComplete()
    LogInfo("p.Stage03102IsComplete");
    
    --监测是否可升级将星
    return not HeroStar.CheckHeroStarCanUpLev();
    
    --[[
    local nStar = HeroStar.GetLevByGrade(GetPlayerId(),1);
    LogInfo("nStar:[%d]",nStar);
    if(nStar>0) then
        return true;
    end
    ]]
    --return false;
end


function p.Stage03102ExitCond()
    LogInfo("p.Stage03102ExitCond");
    
    local scene = GetSMGameScene();
    if(scene == nil) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
        if(layer == nil) then
            LogInfo("p.Stage03102ExitCond true");
            return true;
        end
    end
    
    LogInfo("p.Stage03102ExitCond false");
    return false;
end





---------03------------
function p.Stage03103Begin()
    LogInfo("p.Stage03103Begin");
    p.BeginTemplete();
end

function p.Stage03103End()
    LogInfo("p.Stage03103End");
    p.EndTemplete();
end

function p.Stage03103IsComplete()
    LogInfo("p.Stage03103IsComplete");
    
    if(not p.IsShowLayer({NMAINSCENECHILDTAG.HeroStarUI})) then
        return true;
    end
    return false;
end


function p.Stage03103ExitCond()
    LogInfo("p.Stage03103ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end




function p.Stage031End(isComplete)
    LogInfo("p.Stage031End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 031 结束-----------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------------------------------------引导 041 开始-----------------------------------------------
function p.Stage041Begin()
    LogInfo("p.Stage041Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage041Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage04101Begin()
    LogInfo("p.Stage04101Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage04101End()
    LogInfo("p.Stage04101End");
    p.EndTemplete();
end

function p.Stage04101IsComplete()
    LogInfo("p.Stage04101IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
        if(layer) then
            return layer:IsVisibled();
        end
    end
    
    return false;
end


function p.Stage04101ExitCond()
    LogInfo("p.Stage04101ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------02------------
function p.Stage04102Begin()
    LogInfo("p.Stage04102Begin");
    p.BeginTemplete();
end

function p.Stage04102End()
    LogInfo("p.Stage04102End");
    p.EndTemplete();
end

function p.Stage04102IsComplete()
    LogInfo("p.Stage04102IsComplete");
    
    local petInfo = MartialUI.GetPetInfoLayer();
    if(petInfo) then
        if(petInfo:IsVisibled()) then
            return true;
        end
    end
    return false;
end


function p.Stage04102ExitCond()
    LogInfo("p.Stage04102ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
        if(layer == nil) then
            LogInfo("p.Stage04102ExitCond true");
            return true;
        end
    end
    
    LogInfo("p.Stage04102ExitCond false");
    return false;
end



---------03------------
function p.Stage04103Begin()
    LogInfo("p.Stage04103Begin");
    p.BeginTemplete();
end

function p.Stage04103End()
    LogInfo("p.Stage04103End");
    p.EndTemplete();
end

function p.Stage04103IsComplete()
    LogInfo("p.Stage04103IsComplete");
    
    local petInfo = MartialUI.GetPetInfoLayer();
    if(petInfo == nil or not petInfo:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage04103ExitCond()
    LogInfo("p.Stage04103ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
        if(layer == nil) then
            LogInfo("p.Stage04103ExitCond true");
            return true;
        end
    end
    
    LogInfo("p.Stage04102ExitCond false");
    return false;
end



---------04------------
function p.Stage04104Begin()
    LogInfo("p.Stage04104Begin");
    p.BeginTemplete();
end

function p.Stage04104End()
    LogInfo("p.Stage04104End");
    p.EndTemplete();
end

function p.Stage04104IsComplete()
    LogInfo("p.Stage04104IsComplete");
    
   if(not p.IsShowLayer({NMAINSCENECHILDTAG.PlayerMartial})) then
        return true;
    end
    return false;
end


function p.Stage04104ExitCond()
    LogInfo("p.Stage04104ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end






---------05------------
function p.Stage04105Begin()
    LogInfo("p.Stage04105Begin");
    p.BeginTemplete();
end

function p.Stage04105End()
    LogInfo("p.Stage04105End");
    p.EndTemplete();
end

function p.Stage04105IsComplete()
    LogInfo("p.Stage04105IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer) then
			LogInfo("p.Stage04105IsComplete true");
            return layer:IsVisibled();
        end
    end
	LogInfo("p.Stage04105IsComplete false");
    return false;
end


function p.Stage04105ExitCond()
    LogInfo("p.Stage04105ExitCond");
    
    if(p.InRuoYanCity() == false) then
        LogInfo("p.Stage04105ExitCond true");
        return true;
    end
    LogInfo("p.Stage04105ExitCond false");
    return false;
end



---------06------------
function p.Stage04106Begin()
    LogInfo("p.Stage04106Begin");
    p.BeginTemplete();
end

function p.Stage04106End()
    LogInfo("p.Stage04106End");
    p.EndTemplete();
end

function p.Stage04106IsComplete()
    LogInfo("p.Stage04106IsComplete");
    
    return p.GetBackIsCurr(10000010);
end

function p.Stage10106IsComplete()
    LogInfo("p.Stage04106IsComplete");
    return p.GetBackIsCurr(10000008);
end

function p.GetBackIsCurr(nPetTypeId)
    local nPetId = PlayerUIBackBag.GetCurPetId();
    local ncPetTypeId = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);
    if(ncPetTypeId == nPetTypeId) then
        return true;
    end
    return false;
end

function p.Stage04106ExitCond()
    LogInfo("p.Stage04106ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end



---------07------------
function p.Stage04107Begin()
    LogInfo("p.Stage04107Begin");
    p.BeginTemplete();
    p.OrderItem(34000000, 34000004);
end

function p.Stage04107End()
    LogInfo("p.Stage04106End");
    p.EndTemplete();
end

function p.Stage04107IsComplete()
    LogInfo("p.Stage04107IsComplete");
    
    if PlayerUIBackBag.BagPos.TYPE == Item.bTypeProp then
        return true;
    end
    return false;
end


function p.Stage04107ExitCond()
    LogInfo("p.Stage04107ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end



---------08------------
function p.Stage04108Begin()
    LogInfo("p.Stage04108Begin");
    p.BeginTemplete();
end

function p.Stage28End()
    LogInfo("p.Stage28End");
    p.EndTemplete();
end

function p.Stage04108IsComplete()
    LogInfo("p.Stage04108IsComplete");
    
    --[[
    local nPlayerId		= ConvertN(GetPlayerId());
    local idlistItem	= ItemUser.GetBagItemList(nPlayerId);
    for i,v in ipairs(idlistItem) do
        local nItemType		= Item.GetItemInfoN(v, Item.ITEM_TYPE);
        if(nItemType == 34000000) then
            return false;
        end
    end
    return true;
    ]]
    
    --[[
    local nPlayerId = _G.ConvertN(_G.GetPlayerId());
    local nPlayerPetId  = RolePetFunc.GetMainPetId(nPlayerId);
    local allUsers = RolePetUser.GetPetListPlayer(nPlayerId);
	for i,v in ipairs(allUsers) do
        if(v ~= nPlayerPetId) then
            local nPetLevel = RolePet.GetPetInfoN(v, PET_ATTR.PET_ATTR_LEVEL);
            LogInfo("nPetLevel:[%d],v:[%d],nPlayerPetId:[%d],i:[%d]",nPetLevel,v,nPlayerPetId,i);
            if(nPetLevel>1) then
                return true;
            end
            break;
        end
    end
    ]]
    
    local layer = BackLevelThreeWin.GetPropLayer();
    if(layer and layer:IsVisibled()) then
        return true;
    end
    
    return false;
end


function p.Stage04108ExitCond()
    LogInfo("p.Stage04108ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end







---------09------------
function p.Stage04109Begin()
    LogInfo("p.Stage04109Begin");
    p.BeginTemplete();
end

function p.Stage04109End()
    LogInfo("p.Stage04109End");
    p.EndTemplete();
end

function p.Stage04109IsComplete()
    LogInfo("p.Stage04109IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer == nil or not layer:IsVisibled()) then
            LogInfo("p.Stage04109IsComplete true;");
            return true;
        end
    end
    LogInfo("p.Stage04109IsComplete false;");
    return false;
end


function p.Stage04109ExitCond()
    LogInfo("p.Stage04109ExitCond");
    if(p.InRuoYanCity() == false) then
        LogInfo("p.Stage04105ExitCond true");
        return true;
    end
    LogInfo("p.Stage04109ExitCond false");
    return false;
end




function p.Stage041End(isComplete)
    LogInfo("p.Stage041End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 041 结束-----------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------------------------------------引导 071 开始-----------------------------------------------
function p.Stage071Begin()
    LogInfo("p.Stage071Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage071Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage07101Begin()
    LogInfo("p.Stage07101Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage07101End()
    LogInfo("p.Stage07101End");
    p.EndTemplete();
end

function p.Stage07101IsComplete()
    LogInfo("p.Stage07101IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
        if(layer) then
            return layer:IsVisibled();
        end
    end
        
    return false;
end


function p.Stage31ExitCond()
    LogInfo("p.Stage31ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------02------------
function p.Stage07102Begin()
    LogInfo("p.Stage07102Begin");
    p.BeginTemplete();
end

function p.Stage07102End()
    LogInfo("p.Stage07102End");
    p.EndTemplete();
end

function p.Stage07102IsComplete()
    LogInfo("p.Stage07102IsComplete");
    
    local nEquipId = EquipUpgradeUI.GetStrangPic();
    if(nEquipId>0) then
        return true;
    end
    return false;
    
end


function p.Stage07102ExitCond()
    LogInfo("p.Stage07102ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
        if(layer == nil) then
            LogInfo("p.Stage07102ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage07102ExitCond false");
    return false;
end



---------03------------
function p.Stage07103Begin()
    LogInfo("p.Stage07103Begin");
    p.BeginTemplete();
end

function p.Stage07103End()
    LogInfo("p.Stage07103End");
    p.EndTemplete();
end

function p.Stage07103IsComplete()
    LogInfo("p.Stage07103IsComplete");
    
    local equipId = EquipUpgradeUI.GetStrangPic();
    local nPetId        = RolePetFunc.GetMainPetId(GetPlayerId());
    local equipLv       = Item.GetItemInfoN(equipId, Item.ITEM_ADDITION);
    local mainLv        = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL);
    
    local WaitTime = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
    if(WaitTime>Wait_Time or equipLv>=mainLv) then
        return true;
    end
    
    return false;
end


function p.Stage07103ExitCond()
    LogInfo("p.Stage07103ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
        if(layer == nil) then
            LogInfo("p.Stage07105ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage07103ExitCond false");
    return false;
end






---------05------------
function p.Stage07105Begin()
    LogInfo("p.Stage07105Begin");
    p.BeginTemplete();
end

function p.Stage07105End()
    LogInfo("p.Stage07105End");
    p.EndTemplete();
end

function p.Stage07105IsComplete()
    LogInfo("p.Stage07105IsComplete");
    
    if(EquipUpgradeUI.nTagQuick) then
        local scene = GetSMGameScene();
        local layer = GetUiLayer(scene,EquipUpgradeUI.nTagQuick);
        if(layer) then
            LogInfo("p.Stage07105IsComplete true");
            return true;
        end
    end
    LogInfo("p.Stage07105IsComplete false");
    return false;
end


function p.Stage07105ExitCond()
    LogInfo("p.Stage07105ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
        if(layer == nil) then
            LogInfo("p.Stage07105ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage07105ExitCond false");
    return false;
end



---------06------------
function p.Stage07106Begin()
    LogInfo("p.Stage07106Begin");
    p.BeginTemplete();
end

function p.Stage07106End()
    LogInfo("p.Stage07106End");
    EquipUpgradeUI.refreshStrengView(0);
    p.EndTemplete();
end

function p.Stage07106IsComplete()
    LogInfo("p.Stage07106IsComplete");
    
    local WaitTime = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
    if(WaitTime==0) then
        return true;
    end

    return false;
end


function p.Stage07106ExitCond()
    LogInfo("p.Stage07106ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    if(layer == nil) then
        LogInfo("p.Stage07106ExitCond true");
        return true;
    end
    LogInfo("p.Stage07106ExitCond false");
    return false;
end



---------04------------
function p.Stage07104Begin()
    LogInfo("p.Stage07104Begin");
    p.BeginTemplete();
end

function p.Stage07104End()
    LogInfo("p.Stage07104End");
    p.EndTemplete();
end

function p.Stage07104IsComplete()
    LogInfo("p.Stage07104IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    else
        return true;
    end
    return false;
end


function p.Stage07104ExitCond()
    LogInfo("p.Stage07104ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



function p.Stage071End(isComplete)
    LogInfo("p.Stage071End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 071 结束-----------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------------------------------------引导 081 开始-----------------------------------------------

function p.Stage081Begin()
    LogInfo("p.Stage081Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage081Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage08101Begin()
    LogInfo("p.Stage08101Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage08101End()
    LogInfo("p.Stage08101End");
    p.EndTemplete();
end

function p.Stage08101IsComplete()
    LogInfo("p.Stage08101IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
        if(layer) then
            return layer:IsVisibled();
        end
    end
    
    return false;
end


function p.Stage08101ExitCond()
    LogInfo("p.Stage08101ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end




---------02------------
function p.Stage08102Begin()
    LogInfo("p.Stage08102Begin");
    p.BeginTemplete();
end

function p.Stage08102End()
    LogInfo("p.Stage08102End");
    p.EndTemplete();
end

function p.Stage08102IsComplete()
    LogInfo("p.Stage08102IsComplete");
    local skillInfo = MartialUI.GetSkillInfoLayer();
    if(skillInfo) then
        if(skillInfo:IsVisibled()) then
            return true;
        end
    end
    return false;
end


function p.Stage08102ExitCond()
    LogInfo("p.Stage08102ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
        if(layer == nil) then
            LogInfo("p.Stage08102ExitCond true");
            return true;
        end
    end
    
    LogInfo("p.Stage08102ExitCond false");
    return false;
end



---------03------------
function p.Stage08103Begin()

    LogInfo("p.Stage08103Begin");
    local skillInfo = MartialUI.GetSkillInfoLayer();
    if(skillInfo == nil) then
        LogInfo("error:p.Stage08103Begin MartialUI.GetSkillInfoLayer() is nil!");
        return;
    end
    p.BeginTemplete(skillInfo);
    
end

function p.Stage08103End()
    LogInfo("p.Stage08103End");
    p.EndTemplete();
end

function p.Stage08103IsComplete()
    LogInfo("p.Stage08103IsComplete");
    
    local skillInfo = MartialUI.GetSkillInfoLayer();
    if(skillInfo == nil or not skillInfo:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage08103ExitCond()
    LogInfo("p.Stage08103ExitCond");
    
    local skillInfo = MartialUI.GetSkillInfoLayer();
    if(skillInfo == nil or not skillInfo:IsVisibled()) then
        return true;
    end
    return false;
end



---------04------------
function p.Stage08104Begin()
    LogInfo("p.Stage08104Begin");
    p.BeginTemplete();
end

function p.Stage08104End()
    LogInfo("p.Stage08104End");
    p.EndTemplete();
end

function p.Stage08104IsComplete()
    LogInfo("p.Stage08104IsComplete");
    
    if(not p.IsShowLayer({NMAINSCENECHILDTAG.PlayerMartial})) then
        return true;
    end
    return false;
end


function p.Stage08104ExitCond()
    LogInfo("p.Stage04104ExitCond");
    
    if(not p.IsShowLayer({NMAINSCENECHILDTAG.PlayerMartial})) then
        return true;
    end
    return false;
end






function p.Stage081End(isComplete)
    LogInfo("p.Stage081End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 081 结束-----------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------------------------------------引导 121 开始-----------------------------------------------








---------01------------
function p.Stage12101Begin()
    LogInfo("p.Stage12101Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage12101End()
    LogInfo("p.Stage12101End");
    p.EndTemplete();
end

function p.Stage12101IsComplete()
    LogInfo("p.Stage12101IsComplete");
    
    --监测是否可升级
    if(not HeroStar.CheckHeroStarCanUpLev()) then
        return true;
    end
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end


function p.Stage12101ExitCond()
    LogInfo("p.Stage12101ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------02------------
function p.Stage12102Begin()
    LogInfo("p.Stage12102Begin");
    p.BeginTemplete();
end

function p.Stage12102End()
    LogInfo("p.Stage12102End");
    p.EndTemplete();
end

function p.Stage12102IsComplete()
    LogInfo("p.Stage12102IsComplete");
    
    --监测是否可升级将星
    return not HeroStar.CheckHeroStarCanUpLev();
    
    --[[
    local nStar = HeroStar.GetLevByGrade(GetPlayerId(),1);
    LogInfo("nStar:[%d]",nStar);
    if(nStar>0) then
        return true;
    end
    ]]
    --return false;
end


function p.Stage12102ExitCond()
    LogInfo("p.Stage12102ExitCond");
    
    local scene = GetSMGameScene();
    if(scene == nil) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
        if(layer == nil) then
            LogInfo("p.Stage12102ExitCond true");
            return true;
        end
    end
    
    LogInfo("p.Stage12102ExitCond false");
    return false;
end





---------03------------
function p.Stage12103Begin()
    LogInfo("p.Stage12103Begin");
    p.BeginTemplete();
end

function p.Stage12103End()
    LogInfo("p.Stage12103End");
    p.EndTemplete();
end

function p.Stage12103IsComplete()
    LogInfo("p.Stage12103IsComplete");
    
    if(not p.IsShowLayer({NMAINSCENECHILDTAG.HeroStarUI})) then
        return true;
    end
    return false;
end


function p.Stage12103ExitCond()
    LogInfo("p.Stage12103ExitCond");
    
    if(not p.IsShowLayer({NMAINSCENECHILDTAG.HeroStarUI})) then
        return true;
    end
    return false;
end







-------------------------------------引导 121 结束-----------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------------------------------------引导 161 开始-----------------------------------------------
function p.Stage161Begin()
    LogInfo("p.Stage161Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage161Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage16101Begin()
    LogInfo("p.Stage16101Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage16101End()
    LogInfo("p.Stage16101End");
    p.EndTemplete();
end

function p.Stage16101IsComplete()
    LogInfo("p.Stage16101IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Levy);
        
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end


function p.Stage16101ExitCond()
    LogInfo("p.Stage16101ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------02------------
function p.Stage16102Begin()
    LogInfo("p.Stage16102Begin");
    p.BeginTemplete();
end

function p.Stage16102End()
    LogInfo("p.Stage16102End");
    p.EndTemplete();
end

function p.Stage16102IsComplete()
    LogInfo("p.Stage16102IsComplete");
    
    local nPlayerId = GetPlayerId();
    local nVipRank = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);

    local nBuyedLevy = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_BUYED_LEVY);   
    local nAvailBuyTime = (nVipRank+1)*10; --每天可征收次数
    local nLeftTime = nAvailBuyTime - nBuyedLevy;   --每天还可次征收数
    if(nLeftTime + 1 == nAvailBuyTime) then
        return true;
    end
    
    return false;
end


function p.Stage16102ExitCond()
    LogInfo("p.Stage16102ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Levy);
        if(layer == nil) then
            LogInfo("p.Stage16102ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage16102ExitCond false");
    return false;
end


function p.Stage161End(isComplete)
    LogInfo("p.Stage161End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 161 结束-----------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------------------------------------引导 171 开始-----------------------------------------------
function p.Stage171Begin()
    LogInfo("p.Stage171Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage171Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage17101Begin()
    LogInfo("p.Stage17101Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage17101End()
    LogInfo("p.Stage17101End");
    p.EndTemplete();
end

function p.Stage17101IsComplete()
    LogInfo("p.Stage17101IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
        if(layer and layer:IsVisibled()) then
            return true;
        end
    end
    
    return false;
end


function p.Stage17101ExitCond()
    LogInfo("p.Stage54ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    
    return false;
end


---------02------------
function p.Stage17102Begin()
    LogInfo("p.Stage17102Begin");
    p.BeginTemplete();
end

function p.Stage17102End()
    LogInfo("p.Stage17102End");
    p.EndTemplete();
end

function p.Stage17102IsComplete()
    LogInfo("p.Stage17102IsComplete");
    --[[
    local level = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_RANK);
    if(level>1) then
        return true;
    end
    return false;
    ]]
    return not RankUI.IsUpgrade();
end


function p.Stage17102ExitCond()
    LogInfo("p.Stage17102ExitCond");
    
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end



---------03------------
function p.Stage17103Begin()
    LogInfo("p.Stage17103Begin");
    p.BeginTemplete();
end

function p.Stage17103End()
    LogInfo("p.Stage17103End");
    p.EndTemplete();
end

function p.Stage17103IsComplete()
    LogInfo("p.Stage17103IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end


function p.Stage17103ExitCond()
    LogInfo("p.Stage17103ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
        if(layer == nil) then
            LogInfo("p.Stage17103ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage17103ExitCond false");
    return false;
end


function p.Stage171End(isComplete)
    LogInfo("p.Stage171End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end



-------------------------------------引导 171 结束-----------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------------------------------------引导 181 开始-----------------------------------------------
function p.Stage181Begin()
    LogInfo("p.Stage181Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage181Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage18101Begin()
    LogInfo("p.Stage18101Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage18101End()
    LogInfo("p.Stage18101End");
    p.EndTemplete();
end

function p.Stage18101IsComplete()
    LogInfo("p.Stage18101IsComplete");
    
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    if(layer) then
        return layer:IsVisibled();
    end
    
    return false;
end


function p.Stage18101ExitCond()
    LogInfo("p.Stage18101ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end







---------02------------
function p.Stage18102Begin()
    LogInfo("p.Stage18102Begin");
    p.BeginTemplete();
end

function p.Stage18102End()
    LogInfo("p.Stage18102End");
    p.EndTemplete();
end

function p.Stage18102IsComplete()
    LogInfo("p.Stage18102IsComplete");
    
    local nFirstRepute = GetDataBaseDataN("rank_config",2,DB_RANK.REPUTE);
    local nRepute = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_REPUTE);
    if(nRepute>nFirstRepute) then
        return true;
    end
    return false;
end


function p.Stage18102ExitCond()
    LogInfo("p.Stage18102ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
        if(layer == nil) then
            LogInfo("p.Stage18102ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage18102ExitCond false");
    return false;
end


---------03------------
function p.Stage18103Begin()
    LogInfo("p.Stage18103Begin");
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    if(layer == nil) then
        LogInfo("error:p.Stage18103Begin NMAINSCENECHILDTAG.Arena is nil!");
        return;
    end
    
    p.BeginTemplete(layer);
end

function p.Stage18103End()
    LogInfo("p.Stage18103End");
    
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    if(layer == nil) then
        LogInfo("error:p.Stage18103Begin NMAINSCENECHILDTAG.Arena is nil!");
        p.ClearTemplete();
        return;
    end
    
    p.EndTemplete(layer);
end

function p.Stage18103IsComplete()
    LogInfo("p.Stage18103IsComplete");
    
    if (ArenaUI.cdTime==0) then
        return true;
    end

    return false;
end


function p.Stage18103ExitCond()
    LogInfo("p.Stage18103ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
        if(layer == nil) then
            LogInfo("p.Stage18103ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage18103ExitCond false");
    return false;
end




---------04------------
function p.Stage18104Begin()
    LogInfo("p.Stage18104Begin");
    p.BeginTemplete();
end

function p.Stage18104End()
    LogInfo("p.Stage18104End");
    p.EndTemplete();
end

function p.Stage18104IsComplete()
    LogInfo("p.Stage18104IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
        if(layer==nil) then
            LogInfo("p.Stage18104IsComplete true");
            return true;
        end
    end
    return false;
end


function p.Stage18104ExitCond()
    LogInfo("p.Stage18104ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
        if(layer==nil) then
            LogInfo("p.Stage18104IsComplete true");
            return true;
        end
    else
        return true;
    end
    
    return false;
end



function p.Stage181End(isComplete)
    LogInfo("p.Stage181End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 181 结束-----------------------------------------------






-------------------------------------引导 08 开始-----------------------------------------------
--stage == 421
function p.Stage7Begin()
    LogInfo("p.Stage7Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage7Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage71Begin()
    LogInfo("p.Stage71Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage71End()
    LogInfo("p.Stage71End");
    p.EndTemplete();
end

function p.Stage71IsComplete()
    LogInfo("p.Stage71IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end


function p.Stage71ExitCond()
    LogInfo("p.Stage71ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end







---------02------------
function p.Stage72Begin()
    LogInfo("p.Stage72Begin");
    p.BeginTemplete();
end

function p.Stage72End()
    LogInfo("p.Stage72End");
    p.EndTemplete();
end

function p.Stage72IsComplete()
    LogInfo("p.Stage72IsComplete");
    
    --[[
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
        if(layer == nil) then
            LogInfo("p.Stage72IsComplete true");
            return true;
        end
    end
    ]]
    
    local MountInfo = MsgMount.getMountInfo();
    if(MountInfo.star>1) then
        LogInfo("p.Stage72IsComplete true");
        return true;
    end
    LogInfo("p.Stage72IsComplete false");
    return false;
end


function p.Stage72ExitCond()
    LogInfo("p.Stage72ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
        if(layer == nil) then
            LogInfo("p.Stage72ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage72ExitCond false");
    return false;
end



--------------------03----------------------
function p.Stage73IsComplete()
    if(PetUI.MountInfo.ride == 1) then
        return true;
    end
    return false;
end

---------04------------
function p.Stage74Begin()
    LogInfo("p.Stage74Begin");
    p.BeginTemplete();
end

function p.Stage74End()
    LogInfo("p.Stage74End");
    p.EndTemplete();
end

function p.Stage74IsComplete()
    LogInfo("p.Stage74IsComplete");
    
    local scene = GetSMGameScene();
    if(scene == nil) then
        return false;
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage74ExitCond()
    LogInfo("p.Stage74ExitCond");
    return false;
end







function p.Stage7End(isComplete)
    LogInfo("p.Stage7End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 08 结束-----------------------------------------------



-------------------------------------引导 09 开始-----------------------------------------------
--stage == 581
function p.Stage8Begin()
    LogInfo("p.Stage8Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage8Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage81Begin()
    LogInfo("p.Stage81Begin");
    p.BeginTemplete();
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage81End()
    LogInfo("p.Stage81End");
    p.EndTemplete();
end

function p.Stage81IsComplete()
    LogInfo("p.Stage81IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end


function p.Stage81ExitCond()
    LogInfo("p.Stage81ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------02------------
function p.Stage82Begin()
    LogInfo("p.Stage82Begin");
    p.BeginTemplete();
end

function p.Stage82End()
    LogInfo("p.Stage82End");
    p.EndTemplete();
end

function p.Stage82IsComplete()
    LogInfo("p.Stage82IsComplete");
    if(Fete.mList and Fete.mList[4] and Fete.mList[4].num) then
        if(Fete.mList[4].num>0) then
            LogInfo("p.Stage82IsComplete true");
            return true;
        end
    end
    LogInfo("p.Stage82IsComplete false");
    return false;
end


function p.Stage82ExitCond()
    LogInfo("p.Stage82ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
        if(layer == nil) then
            LogInfo("p.Stage82ExitCond true");
            return true;
        end
    end
    
    LogInfo("p.Stage82ExitCond false");
    return false;
end



---------03------------
function p.Stage83Begin()
    LogInfo("p.Stage83Begin");
    p.BeginTemplete();
end

function p.Stage83End()
    LogInfo("p.Stage83End");
    p.EndTemplete();
end

function p.Stage83IsComplete()
    LogInfo("p.Stage83IsComplete");
    
    local scene = GetSMGameScene();
        if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
        if(layer==nil) then
            LogInfo("p.Stage83IsComplete true");
            return true;
        end
    end
    return false;
    
end


function p.Stage83ExitCond()
    LogInfo("p.Stage83ExitCond");
    local scene = GetSMGameScene();
    
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
        if(layer==nil) then
            LogInfo("p.Stage83ExitCond true");
            return true;
        end
    end
    return false;
end



--------------05------------

function p.Stage85IsComplete()
    local layer = BackLevelThreeWin.GetPropLayer();
    if layer and layer:IsVisibled() then
        return true;
    end
    
end

--------------06------------

function p.Stage86Begin()
    p.Stage04107Begin();
    LogInfo("p.Stage86Begin");
    
    p.OrderItem(31000001, 31000012);
end


--------------07------------
function p.Stage86IsComplete()
    LogInfo("p.Stage86IsComplete");
    local layer = BackLevelThreeWin.GetPropLayer();
    if layer and layer:IsVisibled() then
        LogInfo("p.Stage86IsComplete true");
        return true;
    end
    LogInfo("p.Stage86IsComplete false");
    return false;
end


--------------08------------

function p.Stage87Begin()
    LogInfo("p.Stage87Begin");
    p.BeginTemplete();
end



function p.Stage87IsComplete()
    LogInfo("p.Stage87IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene,BackLevelThreeWin.nTagId);
        if(layer) then
            LogInfo("p.Stage87IsComplete true");
            return true;
        end
    end
    LogInfo("p.Stage87IsComplete false");
    return false;
end


function p.Stage87ExitCond()
    LogInfo("p.Stage87ExitCond");
    
    local layer = BackLevelThreeWin.GetPropLayer();
    if(layer == nil or not layer:IsVisibled()) then
        
        return true;
    end
    return false;
end


---------09------------
function p.Stage88Begin()
    LogInfo("p.Stage88Begin");
    p.BeginTemplete();
end

function p.Stage88End()
    LogInfo("p.Stage88End");
    p.EndTemplete();
end

function p.Stage88IsComplete()
    LogInfo("p.Stage88IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene,BackLevelThreeWin.nTagId);
        if layer == nil or not layer:IsVisibled() then
            LogInfo("p.Stage88IsComplete true");
            return true;
        end
    end
    
    LogInfo("p.Stage88IsComplete false");
    return false;
end


function p.Stage88ExitCond()
    LogInfo("p.Stage88ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    
    return false;
end


function p.Stage810IsComplete()
    LogInfo("p.Stage012IsComplete");
    if(EquipUpgradeUI.nCurrPage == EquipUpgradeUI.TAG.MOSAIC) then
        return true;
    end
    return false;
end


function p.Stage811IsComplete()
    LogInfo("p.Stage811IsComplete");
    
    if(EquipUpgradeUI.nItemIdTemp and EquipUpgradeUI.nItemIdTemp>0 
        and EquipUpgradeUI.nCurrPage == EquipUpgradeUI.TAG.MOSAIC) then
        
        return true;
    end
    LogInfo("p.Stage811IsComplete false");
    return false;
    
end




---------10------------
function p.Stage812Begin()
    LogInfo("p.Stage812Begin");
    p.BeginTemplete();
end

function p.Stage812End()
    LogInfo("p.Stage812End");
    p.EndTemplete();
end

function p.Stage812IsComplete()
    LogInfo("p.Stage812IsComplete");
    
    local gemLayer = EquipUpgradeUI.GetGemInfoLayer();
    if(gemLayer and gemLayer:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage812ExitCond()
    LogInfo("p.Stage812ExitCond");
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end


---------11------------
function p.Stage813Begin()
    LogInfo("p.Stage813Begin");
    p.BeginTemplete();
end

function p.Stage813End()
    LogInfo("p.Stage813End");
    p.EndTemplete();
end

function p.Stage813IsComplete()
    LogInfo("p.Stage813IsComplete");
    
    --[[
    local bGenCount = Item.GetItemInfoN(EquipUpgradeUI.nItemIdTemp, Item.ITEM_GEN_NUM);
    if(bGenCount>0) then
        LogInfo("p.Stage813IsComplete true");
        return true;
    end
    LogInfo("p.Stage813IsComplete false");
    ]]
    
    LogInfo("p.Stage813IsComplete");
    local gemLayer = EquipUpgradeUI.GetGemInfoLayer();
    if(gemLayer == nil or gemLayer:IsVisibled() == false) then
        return true;
    end
    
    return false;
end


function p.Stage813ExitCond()
    LogInfo("p.Stage813ExitCond");
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end



function p.Stage8End(isComplete)
    LogInfo("p.Stage8End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end




-------------------------------------引导 09 结束-----------------------------------------------






-------------------------------------引导 12 开始-----------------------------------------------


---------02------------
function p.Stage012Begin()
    LogInfo("p.Stage012Begin");
    p.BeginTemplete();
end

function p.Stage012End()
    LogInfo("p.Stage012End");
    p.EndTemplete();
end

function p.Stage012IsComplete()
    LogInfo("p.Stage012IsComplete");
    if(EquipUpgradeUI.nCurrPage == EquipUpgradeUI.TAG.BAPTIZE) then
        return true;
    end
    return false;
end


function p.Stage012ExitCond()
    LogInfo("p.Stage012ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
        if(layer == nil or not layer:IsVisibled()) then
            return true;
        end
    end
    return false;
end




--装备
function p.Stage013IsComplete()
    LogInfo("p.Stage013IsComplete");
    local baptizeLayer = EquipUpgradeUI.GetLayerByTag(EquipUpgradeUI.TAG.BAPTIZE);
    if(baptizeLayer) then
        local pic = GetItemButton(baptizeLayer,EquipUpgradeUI.TAG_B_PIC);
        if(pic and pic:GetItemId()>0) then
            return true;
        end
    end
    return false;
end


--洗练
function p.Stage014IsComplete()
    LogInfo("p.Stage014IsComplete");
    local baptizeLayer = EquipUpgradeUI.GetLayerByTag(EquipUpgradeUI.TAG.BAPTIZE);
    if(baptizeLayer) then
        local btn = GetButton(baptizeLayer,EquipUpgradeUI.TAG_B_BTN_KEEP);
        if(btn and btn:IsVisibled()) then
            return true;
        end
    end
    return false;

end

--替换
function p.Stage015IsComplete()
    LogInfo("p.Stage015IsComplete");
    local baptizeLayer = EquipUpgradeUI.GetLayerByTag(EquipUpgradeUI.TAG.BAPTIZE);
    if(baptizeLayer) then
        local btn = GetButton(baptizeLayer,EquipUpgradeUI.TAG_B_BTN_B);
        if(btn and btn:IsVisibled()) then
            return true;
        end
    end
    return false;
end


-------------------------------------引导 12 结束-----------------------------------------------





-------------------------------------引导 13 开始-----------------------------------------------
--stage == 241
function p.Stage241Begin()
    LogInfo("p.Stage241Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage241Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage2411Begin()
    LogInfo("p.Stage2411Begin");
    p.BeginTemplete();
end

function p.Stage2411End()
    LogInfo("p.Stage2411End");
    p.EndTemplete();
end

function p.Stage2411IsComplete()
    LogInfo("p.Stage2411IsComplete");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.WorldMap);
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end


function p.Stage2411ExitCond()
    LogInfo("p.Stage2411ExitCond");
    return false;
end




---------02------------
function p.Stage2412Begin()
    LogInfo("p.Stage2412Begin");
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.WorldMap);
    p.BeginTemplete();
end

function p.Stage2412End()
    LogInfo("p.Stage2412End");
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.WorldMap);
    if(layer) then
        p.EndTemplete();
    else
        p.ClearTemplete();
    end
end

function p.Stage2412IsComplete()
    LogInfo("p.Stage2412IsComplete");
    local scene = GetSMGameScene();
    
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
        if(layer) then
            LogInfo("p.Stage2412IsComplete true");
            return true;
        end
    end
    LogInfo("p.Stage2412IsComplete false");
    return false;
end


function p.Stage2412ExitCond()
    LogInfo("p.Stage2412ExitCond");
    return false;
end



---------03------------
function p.Stage2413Begin()
    LogInfo("p.Stage2413Begin");
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    p.BeginTemplete(layer);
end

function p.Stage2413End()
    LogInfo("p.Stage2413End");
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    if(layer) then
        p.EndTemplete(layer);
    else
        p.ClearTemplete();
    end
end

function p.Stage2413IsComplete()
    LogInfo("p.Stage2413IsComplete");
    if(NormalBossListUI.pLayerElite and NormalBossListUI.pLayerElite:IsVisibled()) then
        LogInfo("p.Stage2413IsComplete true");
        return true;
    end
    LogInfo("p.Stage2413IsComplete false");
    return false;
end


function p.Stage2413ExitCond()
    LogInfo("p.Stage2413ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
        if(layer == nil) then
            LogInfo("p.Stage2413ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage2413ExitCond false");
    return false;
end


---------04------------
function p.Stage2414Begin()
    LogInfo("p.Stage2414Begin");
    if(NormalBossListUI.pLayerElite) then
        p.BeginTemplete(NormalBossListUI.pLayerElite);
    end
end

function p.Stage2414End()
    LogInfo("p.Stage2414End");
    
    if(NormalBossListUI.pLayerElite) then
        p.EndTemplete();
    else
        p.ClearTemplete();
    end
end

function p.Stage2414IsComplete()
    LogInfo("p.Stage2414IsComplete");
    if(NormalBossListUI.pLayerElite == nil) then
        LogInfo("p.Stage2414IsComplete true");
        return true;
    end
    LogInfo("p.Stage2414IsComplete false");
    return false;
end


function p.Stage2414ExitCond()
    LogInfo("p.Stage2414ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
        if(layer == nil) then
            LogInfo("p.Stage2414ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage2414ExitCond false");
    return false;
end




function p.Stage241End(isComplete)
    LogInfo("p.Stage7End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end


-------------------------------------引导 13 结束-----------------------------------------------



-------------------------------------引导 14 开始-----------------------------------------------

---------03------------
function p.Stage5413IsComplete()
    LogInfo("Stage5413IsComplete");
    if(NormalBossListUI.pLayerConfDlg and NormalBossListUI.pLayerConfDlg:IsVisibled()) then
        LogInfo("Stage5413IsComplete true");
        return true;
    end
    LogInfo("Stage5413IsComplete false");
    return false;
end



---------04------------
function p.Stage5414Begin()
    LogInfo("p.Stage5414Begin");
    if(NormalBossListUI.pLayerConfDlg) then
        p.BeginTemplete(NormalBossListUI.pLayerConfDlg);
    end
end

function p.Stage5414End()
    LogInfo("p.Stage5414End");
    
    if(NormalBossListUI.pLayerConfDlg) then
        p.EndTemplete();
    else
        p.ClearTemplete();
    end
end

function p.Stage5414IsComplete()
    LogInfo("p.Stage5414IsComplete");
    if(ClearUpSettingUI.pLayerPrepare ~= nil) then
        LogInfo("p.Stage5414IsComplete true");
        return true;
    end
    LogInfo("p.Stage2414IsComplete false");
    return false;
end


function p.Stage5414ExitCond()
    LogInfo("p.Stage2414ExitCond");
    
    local scene = GetSMGameScene();
    if(scene) then
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
        if(layer == nil) then
            LogInfo("p.Stage2414ExitCond true");
            return true;
        end
    end
    LogInfo("p.Stage2414ExitCond false");
    return false;
end



---------05------------
function p.Stage6414Begin()
    LogInfo("p.Stage6414Begin");
    if(ClearUpSettingUI.pLayerPrepare) then
        p.BeginTemplete(ClearUpSettingUI.pLayerPrepare);
    end
end

function p.Stage6414End()
    LogInfo("p.Stage6414End");
    
    if(ClearUpSettingUI.pLayerPrepare) then
        p.EndTemplete(ClearUpSettingUI.pLayerPrepare);
    else
        p.ClearTemplete();
    end
end

function p.Stage6414IsComplete()
    LogInfo("p.Stage6414IsComplete");
    if(ClearUpSettingUI.pLayerFighting ~= nil and ClearUpSettingUI.pLayerFighting:IsVisibled()) then
        LogInfo("p.Stage6414IsComplete true");
        return true;
    end
    LogInfo("p.Stage6414IsComplete false");
    return false;
end


function p.Stage6414ExitCond()
    LogInfo("p.Stage6414ExitCond");
    return false;
end




---------06------------
function p.Stage7414Begin()
    LogInfo("p.Stage7414Begin");
    if(ClearUpSettingUI.pLayerFighting) then
        p.BeginTemplete(ClearUpSettingUI.pLayerFighting);
    end
end

function p.Stage7414End()
    LogInfo("p.Stage7414End");
    
    if(ClearUpSettingUI.pLayerFighting) then
        p.EndTemplete(ClearUpSettingUI.pLayerFighting);
    else
        p.ClearTemplete();
    end
end

function p.Stage7414IsComplete()
    LogInfo("p.Stage7414IsComplete");
    
    
    if(ClearUpSettingUI.pLayerFighting == nil or not ClearUpSettingUI.pLayerFighting:IsVisibled()) then
        return true;
    else
        local btn = GetButton(ClearUpSettingUI.pLayerFighting,ClearUpSettingUI.ID_BTN_FINISH);
        if(btn==nil or not btn:IsVisibled()) then
            LogInfo("p.Stage7414IsComplete true");
            return true;
        end
    end
    LogInfo("p.Stage7414IsComplete false");
    return false;
end


function p.Stage7414ExitCond()
    LogInfo("p.Stage7414ExitCond");
    
    if(ClearUpSettingUI.pLayerFighting == nil or not ClearUpSettingUI.pLayerFighting:IsVisibled()) then
        LogInfo("p.Stage7414ExitCond true");
        return true;
    end
    LogInfo("p.Stage7414ExitCond false");
    return false;
end

-------------------------------------引导 14 结束-----------------------------------------------





function p.BeginTemplete(layer)
    if(layer == nil) then
        local scene = GetSMGameScene();
        if(scene == nil) then
            return;
        end
        layer = scene;
    end

    local taskItem = p.GetCurrTaskItem();
    
    p.ClearTemplete();
    
    --添加前头
    if(taskItem.Dir) then
        
        --添加提示文字
        if(taskItem.TxtPos) then
            local nX,nY = p.GetJtRelativePos(taskItem.Dir.x*ScaleFactor, taskItem.Dir.y*ScaleFactor, taskItem.Dir.index);
            p.CreateText(layer,taskItem.TxtPos.Txt,p.BoxTag,nX,nY,taskItem.Order);
        end
        
        p.CreateAnimate(layer,taskItem.Dir.index,p.JtTag,taskItem.Dir.x*ScaleFactor,taskItem.Dir.y*ScaleFactor,taskItem.Order);
    end
    
    --添加光效
    if(taskItem.EffectPos) then
        p.CreateAnimate(layer,taskItem.EffectPos.index,p.GxTag,taskItem.EffectPos.x*ScaleFactor,taskItem.EffectPos.y*ScaleFactor,taskItem.Order);
    end
    
end

function p.EndTemplete(layer)
    local scene = GetSMGameScene();
    if(layer) then
        scene = layer;
    end
	if scene then
        --[[
		if(p.JtTag) then
            layer:RemoveChildByTag(p.JtTag,true);
            p.JtTag:RemoveFromParent(true);
            
            if(p.BoxTag) then
                p.BoxTag:RemoveFromParent(true);
            end
        end
        if(p.GxTag) then
            p.GxTag:RemoveFromParent(true);
        end
        ]]
        
        scene:RemoveChildByTag(p.JtTag,true);
        scene:RemoveChildByTag(p.BoxTag,true);
        scene:RemoveChildByTag(p.GxTag,true);
	end
    
    p.ClearTemplete();
end

function p.ClearTemplete()
    --[[
    p.JtTag = nil;
    p.GxTag = nil;
    p.BoxTag = nil;
    ]]
end

--获得文本框相对位置根据箭头
function p.GetJtRelativePos(nX, nY, nType)
    local x,y;
    x=0;y=0;
    LogInfo("nType:[%s]",nType);
    if(nType == TutorialType.UP) then
        x = nX + 25*ScaleFactor;
        y = nY + 80*ScaleFactor;
    elseif(nType == TutorialType.DOWN) then
         LogInfo("nTypedown:[%s]",nType);
        x = nX + 25*ScaleFactor;
        y = nY - 0*ScaleFactor;
    elseif(nType == TutorialType.LEFT) then
        x = nX + 80*ScaleFactor;
        y = nY + 45*ScaleFactor;
    elseif(nType == TutorialType.RIGHT) then
        x = nX - 35*ScaleFactor;
        y = nY + 45*ScaleFactor;
    end
    return x,y;
end


--城市ID
p.RuoYanCityId = 1;

p.RuoYanCity = {
    NMAINSCENECHILDTAG.AffixNormalBoss,
    NMAINSCENECHILDTAG.AffixBossClearUp,
    NMAINSCENECHILDTAG.AffixBossClearUpElite,
    NMAINSCENECHILDTAG.bossUI,
    NMAINSCENECHILDTAG.WorldMap,
};

--在洛阳城
function p.InRuoYanCity()
    if(p.RuoYanCityId == GetMapId()) then
        if(p.IsShowLayer(p.RuoYanCity)) then
            return false;
        else
            
            local scene = GetSMGameScene();
            if(scene) then
                local bs = GetUiLayer(scene,NMAINSCENECHILDTAG.BottomSpeedBar);
                if(bs) then
                    if(bs:IsVisibled()) then
                        return true;
                    end
                end
            end
            
            return false;
        end
    end
    return false;
end

function p.IsShowLayer(arrays)
    for i,v in ipairs(arrays) do
        local isShow = IsUIShow(v);
        if(isShow) then
            LogInfo("p.IsShowLayer Tag:[%d]",v);
            return true;
        end
    end
    return false;
end

--创建动画
function p.CreateAnimate(parent, szSprFile, nTag, nX, nY, nOrder)
    if(not CheckS(szSprFile) or
        not CheckN(nX) or
        not CheckN(nY)) then
        LogInfo("p.CreateAnimate param fail!");
    end

    local pSpriteNode = createUISpriteNode();
    pSpriteNode:Init();
    pSpriteNode:SetFrameRect( CGRectMake(nX, nY, p.JtWidth, p.JtHeight) );
    local szAniPath = NDPath_GetAnimationPath();
    pSpriteNode:ChangeSprite( szAniPath .. szSprFile );
    
    if(nOrder == nil) then
        nOrder = 99999999;
    end
    parent:AddChildZTag(pSpriteNode,nOrder,nTag);
    
    return pSpriteNode;
end

--创建提示文本
function p.CreateText(parent, sText, nTag, nX, nY, nOrder)
    LogInfo("p.CreateText:nX:[%d], nY:[%d]", nX, nY);
    local layer = createNDUINode();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetFrameRect(CGRectMake(nX,nY,p.TipSize.w,p.TipSize.h));
    
    if(nOrder == nil) then
        nOrder = 99999999;
    end
    parent:AddChildZTag(layer,nOrder,nTag);
    
-----------------初始化ui添加到 node 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("tutorial.ini", layer, nil, 0, 0);
    
    
--设置文本框属性
    local label = GetLabel(layer, p.TxtTag);
    if(label) then
        --label:SetTextAlignment(nAlign);
        label:SetText(sText);
        label:SetHasFontBoderColor(false);
    end
    
    return layer;
end




--将物品放到第一位
function p.OrderItem(nMinItemId, nMaxItemId)
    local container		= PlayerUIBackBag.GetBackBagContainer();
    local nTags = {77,76,75,74,73,72,71,70,69,68,67,66,65,64,63,62};
    if(container) then
        local nViewCount    = container:GetViewCount();
        
        LogInfo("nViewCount:[%d]",nViewCount);
        
        for i=1,nViewCount do
            local view = container:GetView(i-1);
            for j,v in ipairs(nTags) do
                local btn = GetItemButton(view,v);
                
                if(btn and btn:GetItemId()>0) then
                    local nItemType = Item.GetItemInfoN(btn:GetItemId(), Item.ITEM_TYPE);
                    LogInfo("nItemType:[%d]",nItemType);
                    if(nItemType>=nMinItemId and nItemType<=nMaxItemId) then
                        
                        local view0 = container:GetView(0);
                        local btn0 = GetItemButton(view0,nTags[16]);
                        
                        local b = btn:GetItemId();
                        local b0 = btn0:GetItemId();
                        
                        LogInfo("b:[%d],b0:[%d]",b,b0);
                        
                        btn:ChangeItem(b0);
                        btn0:ChangeItem(b);
                        return;
                    end
                end
            end
        end
    end
end








--当前任务的进度 KeyItem引导ID， SubItem当前任务做到第几步了
p.CurrTask = { KeyItem = 0, SubItem = 0, };
p.DataInfo = {
    [0]={
        BeginFunc=TutorialData.Stage000Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage000End,        --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.RIGHT,x=80,y=160}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T1")}, Begin=TutorialData.Stage00000Begin, End=TutorialData.Stage00000End, IsComplete=TutorialData.Stage00000IsComplete, ExitCond = TutorialData.Stage00000ExitCond, Order=0,},
            
            {Dir={index=TutorialType.RIGHT,x=620,y=-25}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T1")},  Begin=TutorialData.Stage00001Begin, End=TutorialData.Stage00001End, IsComplete=TutorialData.Stage00001IsComplete, ExitCond = TutorialData.Stage00001ExitCond, Order=0,},
            
            {Dir={index=TutorialType.RIGHT,x=1335,y=160}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T1")},  Begin=TutorialData.Stage00002Begin, End=TutorialData.Stage00002End, IsComplete=TutorialData.Stage00002IsComplete, ExitCond = TutorialData.Stage00002ExitCond, Order=0,},
            
            {Dir={index=TutorialType.RIGHT,x=635,y=-40}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T2")},   Begin=TutorialData.Stage00003Begin, End=TutorialData.Stage00003End, IsComplete=TutorialData.Stage00003IsComplete, ExitCond = TutorialData.Stage00003ExitCond, Order=0,},
            
            {Dir=nil, EffectPos=nil, Begin=TutorialData.Stage00004Begin, End=TutorialData.Stage00004End, IsComplete=TutorialData.Stage00004IsComplete, ExitCond = TutorialData.Stage00004ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=680,y=385}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T3")},  Begin=TutorialData.Stage00005Begin, End=TutorialData.Stage00005End, IsComplete=TutorialData.Stage00005IsComplete, ExitCond = TutorialData.Stage00005ExitCond},
            
            {Dir=nil, EffectPos=nil, Begin=TutorialData.Stage00006Begin, End=TutorialData.Stage00006End, IsComplete=TutorialData.Stage00006IsComplete, ExitCond = TutorialData.Stage00006ExitCond},
            
            {Dir={index=TutorialType.RIGHT,x=620,y=-25}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T1")}, Begin=TutorialData.Stage00007Begin, End=TutorialData.Stage00007End, IsComplete=TutorialData.Stage00007IsComplete, ExitCond = TutorialData.Stage00007ExitCond, Order=0,},
        },
    },
    
    [21] = {
        BeginFunc=TutorialData.Stage021Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage021End,        --任务结束清理事件
        Task =  
        {
            --指引背包按钮
            {Dir={index=TutorialType.DOWN,x=105,y=390}, EffectPos={index="xingong01.spr",x=110,y=430}, TxtPos = {Txt=GetTxtPri("TD_T4")}, Begin=TutorialData.Stage02101Begin, End=TutorialData.Stage02101End, IsComplete=TutorialData.Stage02101IsComplete, ExitCond = TutorialData.Stage02101ExitCond, Order=0,},
            
            --礼包使用
            {Dir={index=TutorialType.DOWN,x=750,y=416}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T5")}, Begin=TutorialData.Stage02102Begin, End=TutorialData.Stage02102End, IsComplete=TutorialData.Stage02102IsComplete, ExitCond = TutorialData.Stage02102ExitCond},
            
            {Dir={index=TutorialType.UP,x=420,y=130}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T8")}, Begin=TutorialData.Stage02103Begin, End=TutorialData.Stage02103End, IsComplete=TutorialData.Stage02103IsComplete, ExitCond = TutorialData.Stage02103ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=515,y=320}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T7")}, Begin=TutorialData.Stage02104Begin, End=TutorialData.Stage02104End, IsComplete=TutorialData.Stage02104IsComplete, ExitCond = TutorialData.Stage02104ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=274,y=220}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T9")}, Begin=TutorialData.Stage02105Begin, End=TutorialData.Stage02105End, IsComplete=TutorialData.Stage02105IsComplete, ExitCond = TutorialData.Stage02105ExitCond},
            
            --穿装备
            {Dir={index=TutorialType.DOWN,x=430,y=416}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T10")}, Begin=TutorialData.Stage02106Begin, End=TutorialData.Stage02106End, IsComplete=TutorialData.Stage02106IsComplete, ExitCond = TutorialData.Stage02106ExitCond},
            
            {Dir={index=TutorialType.UP,x=420,y=130}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T11")},  Begin=TutorialData.Stage02107Begin, End=TutorialData.Stage02107End, IsComplete=TutorialData.Stage02107IsComplete, ExitCond = TutorialData.Stage02107ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=515,y=320}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T12")}, Begin=TutorialData.Stage02108Begin, End=TutorialData.Stage02108End, IsComplete=TutorialData.Stage02108IsComplete, ExitCond = TutorialData.Stage02108ExitCond},
        }
    },
    
    [31] = {
        BeginFunc=TutorialData.Stage031Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage031End,        --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.DOWN,x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt=GetTxtPri("TD_T13")},  Begin=TutorialData.Stage03101Begin, End=TutorialData.Stage03101End, IsComplete=TutorialData.Stage03101IsComplete, ExitCond = TutorialData.Stage03101ExitCond, Order=0,},
            {Dir=nil, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T41")}, Begin=TutorialData.Stage03102Begin, End=TutorialData.Stage03102End, IsComplete=TutorialData.Stage03102IsComplete, ExitCond = TutorialData.Stage03102ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage03103Begin, End=TutorialData.Stage03103End, IsComplete=TutorialData.Stage03103IsComplete, ExitCond = TutorialData.Stage03103ExitCond},
        },
    },
    [41] = {
        BeginFunc=TutorialData.Stage041Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage041End,        --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.DOWN,x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt=GetTxtPri("TD_T40")}, Begin=TutorialData.Stage04101Begin, End=TutorialData.Stage04101End, IsComplete=TutorialData.Stage04101IsComplete, ExitCond = TutorialData.Stage04101ExitCond, Order=0,},
            {Dir={index=TutorialType.UP,x=-36,y=160}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T53")}, Begin=TutorialData.Stage04102Begin, End=TutorialData.Stage04102End, IsComplete=TutorialData.Stage04102IsComplete, ExitCond = TutorialData.Stage04102ExitCond},
            {Dir={index=TutorialType.DOWN,x=350,y=360}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T51")}, Begin=TutorialData.Stage04103Begin, End=TutorialData.Stage04103End, IsComplete=TutorialData.Stage04103IsComplete, ExitCond = TutorialData.Stage04103ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")},  Begin=TutorialData.Stage04104Begin, End=TutorialData.Stage04104End, IsComplete=TutorialData.Stage04104IsComplete, ExitCond = TutorialData.Stage04104ExitCond},
            {Dir={index=TutorialType.DOWN,x=110,y=380}, EffectPos={index="xingong01.spr",x=110,y=430}, TxtPos = {Txt=GetTxtPri("TD_T4")}, Begin=TutorialData.Stage04105Begin, End=TutorialData.Stage04105End, IsComplete=TutorialData.Stage04105IsComplete, ExitCond = TutorialData.Stage04105ExitCond, Order=0,},
            {Dir={index=TutorialType.RIGHT,x=100,y=-10}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T50")}, Begin=TutorialData.Stage04106Begin, End=TutorialData.Stage04106End, IsComplete=TutorialData.Stage04106IsComplete, ExitCond = TutorialData.Stage04106ExitCond},
            {Dir={index=TutorialType.DOWN,x=750,y=400}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T49")}, Begin=TutorialData.Stage04107Begin, End=TutorialData.Stage04107End, IsComplete=TutorialData.Stage04107IsComplete, ExitCond = TutorialData.Stage04107ExitCond},
                        
            {Dir={index=TutorialType.UP,x=425,y=150}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T5")}, Begin=TutorialData.Stage04108Begin, End=TutorialData.Stage28End, IsComplete=TutorialData.Stage04108IsComplete, ExitCond = TutorialData.Stage04108ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=510,y=320}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T7")}, Begin=TutorialData.Stage87Begin, End=TutorialData.Stage02108End, IsComplete=TutorialData.Stage87IsComplete, ExitCond = TutorialData.Stage87ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=274,y=220}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T9")}, Begin=TutorialData.Stage02105Begin, End=TutorialData.Stage02105End, IsComplete=TutorialData.Stage02105IsComplete, ExitCond = TutorialData.Stage02105ExitCond},
            
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage04109Begin, End=TutorialData.Stage04109End, IsComplete=TutorialData.Stage04109IsComplete, ExitCond = TutorialData.Stage04109ExitCond},
        },
    },
    
    
    [71] = {
        BeginFunc=TutorialData.Stage071Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage071End,        --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.DOWN,x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt=GetTxtPri("TD_T25")},Begin=TutorialData.Stage07101Begin, End=TutorialData.Stage07101End, IsComplete=TutorialData.Stage07101IsComplete, ExitCond = TutorialData.Stage31ExitCond, Order=0,},
            {Dir={index=TutorialType.LEFT,x=40,y=80}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T11")},  Begin=TutorialData.Stage07102Begin, End=TutorialData.Stage07102End, IsComplete=TutorialData.Stage07102IsComplete, ExitCond = TutorialData.Stage07102ExitCond},
            {Dir={index=TutorialType.RIGHT,x=380,y=442}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T54")},   Begin=TutorialData.Stage07103Begin, End=TutorialData.Stage07103End, IsComplete=TutorialData.Stage07103IsComplete, ExitCond = TutorialData.Stage07103ExitCond},
            
            --[[
            --新添加(加速功能)
            {Dir={index=TutorialType.DOWN,x=650,y=160}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T55")}, Begin=TutorialData.Stage07105Begin, End=TutorialData.Stage07105End, IsComplete=TutorialData.Stage07105IsComplete, ExitCond = TutorialData.Stage07105ExitCond},
            {Dir={index=TutorialType.DOWN,x=274,y=220}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T9")}, Begin=TutorialData.Stage07106Begin, End=TutorialData.Stage07106End, IsComplete=TutorialData.Stage07106IsComplete, ExitCond = TutorialData.Stage07106ExitCond},
            
            {Dir={index=TutorialType.LEFT,x=40,y=190}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T11")},  Begin=TutorialData.Stage07102Begin, End=TutorialData.Stage07102End, IsComplete=TutorialData.Stage07102IsComplete, ExitCond = TutorialData.Stage07102ExitCond},
            
            {Dir={index=TutorialType.RIGHT,x=380,y=442}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T54")},   Begin=TutorialData.Stage07103Begin, End=TutorialData.Stage07103End, IsComplete=TutorialData.Stage07103IsComplete, ExitCond = TutorialData.Stage07103ExitCond},
            
            ]]
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage07104Begin, End=TutorialData.Stage07104End, IsComplete=TutorialData.Stage07104IsComplete, ExitCond = TutorialData.Stage07104ExitCond},
            
        },
    },
    
    [90] = {
        BeginFunc=TutorialData.Stage081Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage081End,            --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.DOWN,x=400,y=380}, EffectPos={index="xingong01.spr",x=400,y=430}, TxtPos = {Txt=GetTxtPri("TD_T13")},  Begin=TutorialData.Stage12101Begin, End=TutorialData.Stage12101End, IsComplete=TutorialData.Stage12101IsComplete, ExitCond = TutorialData.Stage12101ExitCond, Order=0,},
            {Dir={index=TutorialType.DOWN,x=20,y=380}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T41")}, Begin=TutorialData.Stage12102Begin, End=TutorialData.Stage12102End, IsComplete=TutorialData.Stage12102IsComplete, ExitCond = TutorialData.Stage12102ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage12103Begin, End=TutorialData.Stage12103End, IsComplete=TutorialData.Stage12103IsComplete, ExitCond = TutorialData.Stage12103ExitCond},
            
            
            {Dir={index=TutorialType.DOWN,x=300,y=380}, EffectPos={index="xingong01.spr",x=300,y=430}, TxtPos = {Txt=GetTxtPri("TD_T40")},  Begin=TutorialData.Stage08101Begin, End=TutorialData.Stage08101End, IsComplete=TutorialData.Stage08101IsComplete, ExitCond = TutorialData.Stage08101ExitCond, Order=0,},
            {Dir={index=TutorialType.DOWN,x=380,y=350}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T39")}, Begin=TutorialData.Stage08102Begin, End=TutorialData.Stage08102End, IsComplete=TutorialData.Stage08102IsComplete, ExitCond = TutorialData.Stage08102ExitCond},
            {Dir={index=TutorialType.DOWN,x=355,y=240}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T38")},  Begin=TutorialData.Stage08103Begin, End=TutorialData.Stage08103End, IsComplete=TutorialData.Stage08103IsComplete, ExitCond = TutorialData.Stage08103ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage08104Begin, End=TutorialData.Stage08104End, IsComplete=TutorialData.Stage08104IsComplete, ExitCond = TutorialData.Stage08104ExitCond},
        }
    },
    
    [111] = {
        BeginFunc=TutorialData.Stage041Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage041End,        --任务结束清理事件
        Task =  
        {
    
            {Dir={index=TutorialType.DOWN,x=300,y=380}, EffectPos={index="xingong01.spr",x=300,y=430}, TxtPos = {Txt=GetTxtPri("TD_T40")}, Begin=TutorialData.Stage04101Begin, End=TutorialData.Stage04101End, IsComplete=TutorialData.Stage04101IsComplete, ExitCond = TutorialData.Stage04101ExitCond, Order=0,},
            {Dir={index=TutorialType.UP,x=90,y=160}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T53")}, Begin=TutorialData.Stage04102Begin, End=TutorialData.Stage04102End, IsComplete=TutorialData.Stage04102IsComplete, ExitCond = TutorialData.Stage04102ExitCond},
            {Dir={index=TutorialType.DOWN,x=350,y=360}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T51")}, Begin=TutorialData.Stage04103Begin, End=TutorialData.Stage04103End, IsComplete=TutorialData.Stage04103IsComplete, ExitCond = TutorialData.Stage04103ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")},  Begin=TutorialData.Stage04104Begin, End=TutorialData.Stage04104End, IsComplete=TutorialData.Stage04104IsComplete, ExitCond = TutorialData.Stage04104ExitCond},
            {Dir={index=TutorialType.DOWN,x=110,y=380}, EffectPos={index="xingong01.spr",x=110,y=430}, TxtPos = {Txt=GetTxtPri("TD_T4")}, Begin=TutorialData.Stage04105Begin, End=TutorialData.Stage04105End, IsComplete=TutorialData.Stage04105IsComplete, ExitCond = TutorialData.Stage04105ExitCond, Order=0,},
            {Dir={index=TutorialType.RIGHT,x=100,y=-10}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T52")}, Begin=TutorialData.Stage04106Begin, End=TutorialData.Stage04106End, IsComplete=TutorialData.Stage10106IsComplete, ExitCond = TutorialData.Stage04106ExitCond},
            {Dir={index=TutorialType.DOWN,x=750,y=400}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T49")}, Begin=TutorialData.Stage04107Begin, End=TutorialData.Stage04107End, IsComplete=TutorialData.Stage04107IsComplete, ExitCond = TutorialData.Stage04107ExitCond},
            
            {Dir={index=TutorialType.UP,x=425,y=150}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T5")}, Begin=TutorialData.Stage04108Begin, End=TutorialData.Stage28End, IsComplete=TutorialData.Stage04108IsComplete, ExitCond = TutorialData.Stage04108ExitCond},
            {Dir={index=TutorialType.DOWN,x=510,y=320}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T7")}, Begin=TutorialData.Stage87Begin, End=TutorialData.Stage02108End, IsComplete=TutorialData.Stage87IsComplete, ExitCond = TutorialData.Stage87ExitCond},
            {Dir={index=TutorialType.DOWN,x=274,y=220}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T9")}, Begin=TutorialData.Stage02105Begin, End=TutorialData.Stage02105End, IsComplete=TutorialData.Stage02105IsComplete, ExitCond = TutorialData.Stage02105ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage04109Begin, End=TutorialData.Stage04109End, IsComplete=TutorialData.Stage04109IsComplete, ExitCond = TutorialData.Stage04109ExitCond},
            
        }
    },
    
    [130] = {
        BeginFunc=TutorialData.Stage081Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage081End,            --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.DOWN,x=400,y=380}, EffectPos={index="xingong01.spr",x=400,y=430}, TxtPos = {Txt=GetTxtPri("TD_T13")},  Begin=TutorialData.Stage12101Begin, End=TutorialData.Stage12101End, IsComplete=TutorialData.Stage12101IsComplete, ExitCond = TutorialData.Stage12101ExitCond, Order=0,},
            {Dir={index=TutorialType.DOWN,x=20,y=380}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T41")}, Begin=TutorialData.Stage12102Begin, End=TutorialData.Stage12102End, IsComplete=TutorialData.Stage12102IsComplete, ExitCond = TutorialData.Stage12102ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage12103Begin, End=TutorialData.Stage12103End, IsComplete=TutorialData.Stage12103IsComplete, ExitCond = TutorialData.Stage12103ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=300,y=380}, EffectPos={index="xingong01.spr",x=300,y=430}, TxtPos = {Txt=GetTxtPri("TD_T40")},  Begin=TutorialData.Stage08101Begin, End=TutorialData.Stage08101End, IsComplete=TutorialData.Stage08101IsComplete, ExitCond = TutorialData.Stage08101ExitCond, Order=0,},
            {Dir={index=TutorialType.DOWN,x=260,y=350}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T39")}, Begin=TutorialData.Stage08102Begin, End=TutorialData.Stage08102End, IsComplete=TutorialData.Stage08102IsComplete, ExitCond = TutorialData.Stage08102ExitCond},
            {Dir={index=TutorialType.DOWN,x=355,y=240}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T38")},  Begin=TutorialData.Stage08103Begin, End=TutorialData.Stage08103End, IsComplete=TutorialData.Stage08103IsComplete, ExitCond = TutorialData.Stage08103ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage08104Begin, End=TutorialData.Stage08104End, IsComplete=TutorialData.Stage08104IsComplete, ExitCond = TutorialData.Stage08104ExitCond},
        }
    },
    
    
    [161] = {
        BeginFunc=TutorialData.Stage161Begin,     --判断任务是否开始
        EndFunc=TutorialData.Stage161End,         --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.UP,x=600,y=70}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T48")}, Begin=TutorialData.Stage16101Begin, End=TutorialData.Stage16101End, IsComplete=TutorialData.Stage16101IsComplete, ExitCond = TutorialData.Stage16101ExitCond, Order=0,},
            {Dir={index=TutorialType.LEFT,x=500,y=396}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T47")},  Begin=TutorialData.Stage16102Begin, End=TutorialData.Stage16102End, IsComplete=TutorialData.Stage16102IsComplete, ExitCond = TutorialData.Stage16102ExitCond},
        },
    },
    
    
    [171] = {
        BeginFunc=TutorialData.Stage171Begin,     --判断任务是否开始
        EndFunc=TutorialData.Stage171End,         --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.LEFT,x=130,y=-50}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T46")},  Begin=TutorialData.Stage17101Begin, End=TutorialData.Stage17101End, IsComplete=TutorialData.Stage17101IsComplete, ExitCond = TutorialData.Stage17101ExitCond, Order=0,},
            
            
            {Dir=nil--[[{index=TutorialType.DOWN,x=360,y=360}]], EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T45")}, Begin=TutorialData.Stage17102Begin, End=TutorialData.Stage17102End, IsComplete=TutorialData.Stage17102IsComplete, ExitCond = TutorialData.Stage17102ExitCond},
            
            
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage17103Begin, End=TutorialData.Stage17103End, IsComplete=TutorialData.Stage17103IsComplete, ExitCond = TutorialData.Stage17103ExitCond},
        },
    },
    
    
    [181] = {
        BeginFunc=TutorialData.Stage181Begin,     --判断任务是否开始
        EndFunc=TutorialData.Stage181End,         --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.UP,x=600,y=60}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T44")},  Begin=TutorialData.Stage18101Begin, End=TutorialData.Stage18101End, IsComplete=TutorialData.Stage18101IsComplete, ExitCond = TutorialData.Stage18101ExitCond, Order=0,},
            
            {Dir={index=TutorialType.LEFT,x=290,y=60}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T43")},  Begin=TutorialData.Stage18102Begin, End=TutorialData.Stage18102End, IsComplete=TutorialData.Stage18102IsComplete, ExitCond = TutorialData.Stage18102ExitCond},
            
            --[[
            {Dir={index=TutorialType.UP,x=716,y=290}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T42")},   Begin=TutorialData.Stage18103Begin, End=TutorialData.Stage18103End, IsComplete=TutorialData.Stage18103IsComplete, ExitCond = TutorialData.Stage18103ExitCond},
            
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage18104Begin, End=TutorialData.Stage18104End, IsComplete=TutorialData.Stage18104IsComplete, ExitCond = TutorialData.Stage18104ExitCond},
            ]]
        },
    },
    
    
    
    [200] = {
        BeginFunc=TutorialData.Stage081Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage081End,            --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.DOWN,x=400,y=380}, EffectPos={index="xingong01.spr",x=400,y=430}, TxtPos = {Txt=GetTxtPri("TD_T13")},  Begin=TutorialData.Stage12101Begin, End=TutorialData.Stage12101End, IsComplete=TutorialData.Stage12101IsComplete, ExitCond = TutorialData.Stage12101ExitCond, Order=0,},
            {Dir={index=TutorialType.DOWN,x=20,y=380}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T41")}, Begin=TutorialData.Stage12102Begin, End=TutorialData.Stage12102End, IsComplete=TutorialData.Stage12102IsComplete, ExitCond = TutorialData.Stage12102ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage12103Begin, End=TutorialData.Stage12103End, IsComplete=TutorialData.Stage12103IsComplete, ExitCond = TutorialData.Stage12103ExitCond},
            
            
            {Dir={index=TutorialType.DOWN,x=300,y=380}, EffectPos={index="xingong01.spr",x=300,y=430}, TxtPos = {Txt=GetTxtPri("TD_T40")},  Begin=TutorialData.Stage08101Begin, End=TutorialData.Stage08101End, IsComplete=TutorialData.Stage08101IsComplete, ExitCond = TutorialData.Stage08101ExitCond, Order=0,},
            {Dir={index=TutorialType.DOWN,x=500,y=350}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T39")}, Begin=TutorialData.Stage08102Begin, End=TutorialData.Stage08102End, IsComplete=TutorialData.Stage08102IsComplete, ExitCond = TutorialData.Stage08102ExitCond},
            {Dir={index=TutorialType.DOWN,x=355,y=240}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T38")},  Begin=TutorialData.Stage08103Begin, End=TutorialData.Stage08103End, IsComplete=TutorialData.Stage08103IsComplete, ExitCond = TutorialData.Stage08103ExitCond},
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage08104Begin, End=TutorialData.Stage08104End, IsComplete=TutorialData.Stage08104IsComplete, ExitCond = TutorialData.Stage08104ExitCond},
        }
    },
    
    [221] = {
        BeginFunc=TutorialData.Stage071Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage071End,        --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.DOWN,x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt=GetTxtPri("TD_T25")}, Begin=TutorialData.Stage07101Begin, End=TutorialData.Stage07101End, IsComplete=TutorialData.Stage07101IsComplete, ExitCond = TutorialData.Stage31ExitCond, Order=0,},
            
            --切换选项卡
            {Dir={index=TutorialType.UP,x=380,y=-25}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T37")}, Begin=TutorialData.Stage012Begin, End=TutorialData.Stage012End, IsComplete=TutorialData.Stage012IsComplete, ExitCond = TutorialData.Stage012ExitCond},
            
            --点击装备
            {Dir={index=TutorialType.LEFT,x=40,y=80}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T23")}, Begin=TutorialData.Stage07102Begin, End=TutorialData.Stage07102End, IsComplete=TutorialData.Stage013IsComplete, ExitCond = TutorialData.Stage07102ExitCond},
            
            --点击洗练
            {Dir={index=TutorialType.RIGHT,x=384,y=448}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T36")}, Begin=TutorialData.Stage07103Begin, End=TutorialData.Stage07103End, IsComplete=TutorialData.Stage014IsComplete, ExitCond = TutorialData.Stage07103ExitCond},
            
            --替换
            {Dir={index=TutorialType.DOWN,x=634,y=380}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T35")},  Begin=TutorialData.Stage07103Begin, End=TutorialData.Stage07103End, IsComplete=TutorialData.Stage015IsComplete, ExitCond = TutorialData.Stage07103ExitCond},
            
            --退出
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")},   Begin=TutorialData.Stage07104Begin, End=TutorialData.Stage07104End, IsComplete=TutorialData.Stage07104IsComplete, ExitCond = TutorialData.Stage07104ExitCond},
            
        },
    },
    
    
    [241] = {
        BeginFunc=TutorialData.Stage241Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage241End,        --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.RIGHT,x=780,y=150}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T20")}, Begin=TutorialData.Stage2411Begin, End=TutorialData.Stage2411End, IsComplete=TutorialData.Stage2411IsComplete, ExitCond = TutorialData.Stage2411ExitCond, Order=0,},
            {Dir={index=TutorialType.RIGHT,x=530,y=-50}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T19")},  Begin=TutorialData.Stage2412Begin, End=TutorialData.Stage2412End, IsComplete=TutorialData.Stage2412IsComplete, ExitCond = TutorialData.Stage2412ExitCond},
            {Dir={index=TutorialType.UP,x=354,y=-20}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T34")},  Begin=TutorialData.Stage2413Begin, End=TutorialData.Stage2413End, IsComplete=TutorialData.Stage2413IsComplete, ExitCond = TutorialData.Stage2413ExitCond},
            {Dir={index=TutorialType.DOWN,x=0,y=0}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T33")},  Begin=TutorialData.Stage2414Begin, End=TutorialData.Stage2414End, IsComplete=TutorialData.Stage2414IsComplete, ExitCond = TutorialData.Stage2414ExitCond},
        }
    },
        
    
    [291] = {
        BeginFunc=TutorialData.Stage7Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage7End,        --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.DOWN,x=510,y=380}, EffectPos={index="xingong01.spr",x=510,y=430}, TxtPos = {Txt=GetTxtPri("TD_T32")},  Begin=TutorialData.Stage71Begin, End=TutorialData.Stage71End, IsComplete=TutorialData.Stage71IsComplete, ExitCond = TutorialData.Stage71ExitCond, Order=0,},
            
            {Dir={index=TutorialType.DOWN,x=450,y=400}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T31")}, Begin=TutorialData.Stage72Begin, End=TutorialData.Stage72End, IsComplete=TutorialData.Stage73IsComplete, ExitCond = TutorialData.Stage72ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=660,y=400}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T30")}, Begin=TutorialData.Stage72Begin, End=TutorialData.Stage72End, IsComplete=TutorialData.Stage72IsComplete, ExitCond = TutorialData.Stage72ExitCond},
            
            --退出
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")},   Begin=TutorialData.Stage74Begin, End=TutorialData.Stage74End, IsComplete=TutorialData.Stage74IsComplete, ExitCond = TutorialData.Stage74ExitCond},
        },
    },
    [321] = {
        BeginFunc=TutorialData.Stage8Begin,     --判断任务是否开始
        EndFunc=TutorialData.Stage8End,         --任务结束清理事件
        Task =  
        {
            --宝石祭祀
            {Dir={index=TutorialType.UP,x=440,y=70}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T29")}, Begin=TutorialData.Stage81Begin, End=TutorialData.Stage81End, IsComplete=TutorialData.Stage81IsComplete, ExitCond = TutorialData.Stage81ExitCond, Order=0,},
            {Dir={index=TutorialType.DOWN,x=680,y=40}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T28")},  Begin=TutorialData.Stage82Begin, End=TutorialData.Stage82End, IsComplete=TutorialData.Stage82IsComplete, ExitCond = TutorialData.Stage82ExitCond},
            
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")},    Begin=TutorialData.Stage83Begin, End=TutorialData.Stage83End, IsComplete=TutorialData.Stage83IsComplete, ExitCond = TutorialData.Stage83ExitCond},
            
            
            --宝石礼包使用
            {Dir={index=TutorialType.DOWN,x=110,y=380}, EffectPos={index="xingong01.spr",x=110,y=430}, TxtPos = {Txt=GetTxtPri("TD_T4")}, Begin=TutorialData.Stage04105Begin, End=TutorialData.Stage04105End, IsComplete=TutorialData.Stage04105IsComplete, ExitCond = TutorialData.Stage04105ExitCond, Order=0,},
            
            --背包选项卡切换
            {Dir={index=TutorialType.DOWN,x=750,y=400}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T27")}, Begin=TutorialData.Stage04107Begin, End=TutorialData.Stage04107End, IsComplete=TutorialData.Stage04107IsComplete, ExitCond = TutorialData.Stage04107ExitCond},
            
            --指向第一个道具
            {Dir={index=TutorialType.UP,x=420,y=130}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T26")}, Begin=TutorialData.Stage86Begin, End=TutorialData.Stage28End, IsComplete=TutorialData.Stage86IsComplete, ExitCond = TutorialData.Stage04108ExitCond},
            
            --使用礼包
            {Dir={index=TutorialType.DOWN,x=510,y=320}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T7")}, Begin=TutorialData.Stage87Begin, End=TutorialData.Stage02108End, IsComplete=TutorialData.Stage87IsComplete, ExitCond = TutorialData.Stage87ExitCond},
            
            --确认框
            {Dir={index=TutorialType.DOWN,x=274,y=220}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T9")}, Begin=TutorialData.Stage88Begin, End=TutorialData.Stage88End, IsComplete=TutorialData.Stage88IsComplete, ExitCond = TutorialData.Stage88ExitCond},
            
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")},  Begin=TutorialData.Stage04109Begin, End=TutorialData.Stage04109End, IsComplete=TutorialData.Stage04109IsComplete, ExitCond = TutorialData.Stage04109ExitCond},
            
            
            {Dir={index=TutorialType.DOWN,x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt=GetTxtPri("TD_T25")}, Begin=TutorialData.Stage07101Begin, End=TutorialData.Stage07101End, IsComplete=TutorialData.Stage07101IsComplete, ExitCond = TutorialData.Stage31ExitCond, Order=0,},
            
            {Dir={index=TutorialType.UP,x=550,y=-30}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T24")}, Begin=TutorialData.Stage012Begin, End=TutorialData.Stage012End, IsComplete=TutorialData.Stage810IsComplete, ExitCond = TutorialData.Stage012ExitCond},
            
            {Dir={index=TutorialType.LEFT,x=40,y=80}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T23")}, Begin=TutorialData.Stage07102Begin, End=TutorialData.Stage07102End, IsComplete=TutorialData.Stage811IsComplete, ExitCond = TutorialData.Stage07102ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=274,y=0}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T22")}, Begin=TutorialData.Stage812Begin, End=TutorialData.Stage812End, IsComplete=TutorialData.Stage812IsComplete, ExitCond = TutorialData.Stage812ExitCond},
            
            {Dir={index=TutorialType.DOWN,x=430,y=330}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T21")}, Begin=TutorialData.Stage813Begin, End=TutorialData.Stage813End, IsComplete=TutorialData.Stage813IsComplete, ExitCond = TutorialData.Stage813ExitCond},
            
            
            
            {Dir={index=TutorialType.RIGHT,x=710,y=-110}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T6")}, Begin=TutorialData.Stage07104Begin, End=TutorialData.Stage07104End, IsComplete=TutorialData.Stage07104IsComplete, ExitCond = TutorialData.Stage07104ExitCond},
            
        },
    },
    
    
    [541] = {
        BeginFunc=TutorialData.Stage241Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage241End,        --任务结束清理事件
        Task =  
        {
            {Dir={index=TutorialType.RIGHT,x=780,y=150}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T20")},Begin=TutorialData.Stage2411Begin, End=TutorialData.Stage2411End, IsComplete=TutorialData.Stage2411IsComplete, ExitCond = TutorialData.Stage2411ExitCond, Order=0,},
            {Dir={index=TutorialType.RIGHT,x=530,y=-50}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T19")}, Begin=TutorialData.Stage2412Begin, End=TutorialData.Stage2412End, IsComplete=TutorialData.Stage2412IsComplete, ExitCond = TutorialData.Stage2412ExitCond},
            {Dir={index=TutorialType.DOWN,x=0,y=0}, EffectPos=nil,TxtPos = {Txt=GetTxtPri("TD_T18")},Begin=TutorialData.Stage2413Begin, End=TutorialData.Stage2413End, IsComplete=TutorialData.Stage5413IsComplete, ExitCond = TutorialData.Stage2413ExitCond},
            {Dir={index=TutorialType.DOWN,x=350,y=200}, EffectPos=nil,TxtPos = {Txt=GetTxtPri("TD_T16")},Begin=TutorialData.Stage5414Begin, End=TutorialData.Stage5414End, IsComplete=TutorialData.Stage5414IsComplete, ExitCond = TutorialData.Stage5414ExitCond},
            {Dir={index=TutorialType.DOWN,x=630,y=380}, EffectPos=nil, TxtPos = {Txt=GetTxtPri("TD_T15")},Begin=TutorialData.Stage6414Begin, End=TutorialData.Stage6414End, IsComplete=TutorialData.Stage6414IsComplete, ExitCond = TutorialData.Stage6414ExitCond},
            --[[
            {Dir={index=TutorialType.DOWN,x=710,y=380}, EffectPos=nil,TxtPos = {Txt=GetTxtPri("TD_T14")},Begin=TutorialData.Stage7414Begin, End=TutorialData.Stage7414End, IsComplete=TutorialData.Stage7414IsComplete, ExitCond = TutorialData.Stage7414ExitCond},
            ]]
            
        },
    },
};

------------------------------------------------------------------------------------
--更新stage事件
GameDataEvent.Register(GAMEDATAEVENT.USERSTAGEATTR,"p.TaskBegin",p.TaskBegin);
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--战斗失败事件
GameDataEvent.Register(GAMEDATAEVENT.BATTLE_LOSE_INFO,"p.BattleFailEvent",p.BattleFailEvent);
------------------------------------------------------------------------------------


