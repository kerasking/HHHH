---------------------------------------------------
--描述: 教程数据配置
--时间: 2012.07.12
--作者: chh
---------------------------------------------------

TutorialData = {}
local p = TutorialData;

local HandleTime = 1/2;
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

p.JtTag     = nil;--前头Tag
p.GxTag     = nil;--光效Tag
p.BoxTag    = nil;--文本框
p.TxtTag    = 2;    
p.TipSize   = CGSizeMake(80*ScaleFactor,40*ScaleFactor);

TutorialType = {
    UP = 1,
    DOWN = 2,
    LEFT = 3,
    RIGHT = 4,
}

--任务的开始判断
function p.TaskBegin()
    LogInfo("p.TaskBegin");
        
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



-------------------------------------引导 01 开始-----------------------------------------------
--stage == 0
function p.Stage0Begin()
    LogInfo("p.Stage0Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
            p.DealProgress();
        end
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage0Begin, HandleTime);
        end
    end
end

---------01------------
function p.Stage01Begin()
    LogInfo("p.Stage01Begin");
    local mapLayer=GetMapLayer();
    p.BeginTemplete(mapLayer);
end

function p.Stage01End()
    LogInfo("p.Stage01End");
    p.EndTemplete();
end

function p.Stage01IsComplete()
    LogInfo("p.Stage01IsComplete");
    
    local nPlayerid = GetPlayerId();
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_STAGE));
    
    LogInfo("nPlayerStage:[%d]",nPlayerStage);
    
    if(nPlayerStage == 10) then
        return true;
    end
    
    return false;
end


function p.Stage01ExitCond()
    LogInfo("p.Stage01ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end


-----------02------------
function p.Stage02Begin()
    LogInfo("p.Stage02Begin");
    
    local scene = GetSMGameScene();
    
    p.BeginTemplete(scene);
end

function p.Stage02End()
    LogInfo("p.Stage02End");
    p.EndTemplete();
end

function p.Stage02IsComplete()
    LogInfo("p.Stage02IsComplete");
    
    local nPlayerid = GetPlayerId();
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_STAGE));
    
    if(nPlayerStage == 11) then
        return true;
    end
    
    return false;
end

function p.Stage02ExitCond()
    LogInfo("p.Stage02ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end

-----------03-------------
function p.Stage03Begin()
    LogInfo("p.Stage02Begin");
    
    local mapLayer=GetMapLayer();
    
    p.BeginTemplete(mapLayer);
end

function p.Stage03End()
    LogInfo("p.Stage03End");
    p.EndTemplete();
end

function p.Stage03IsComplete()
    LogInfo("p.Stage03IsComplete");
    
    local nPlayerid = GetPlayerId();
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_STAGE));
    
    if(nPlayerStage == 20) then
        return true;
    end
    
    return false;
end

function p.Stage03ExitCond()
    LogInfo("p.Stage03ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end

--------------04------------
function p.Stage04Begin()
    LogInfo("p.Stage04Begin");
    
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
end

function p.Stage04End()
    LogInfo("p.Stage04End");
    p.EndTemplete();
end

function p.Stage04IsComplete()
    LogInfo("p.Stage04IsComplete");
    local isInCity = p.InRuoYanCity();
    return not isInCity;
end

function p.Stage04ExitCond()
    LogInfo("p.Stage04ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



--------------05------------
function p.Stage05Begin()
    LogInfo("p.Stage05Begin");
end

function p.Stage05End()
    LogInfo("p.Stage05End");
end

function p.Stage05IsComplete()
    LogInfo("p.Stage05IsComplete");
    
    
    if(p.IsShowLayer({NMAINSCENECHILDTAG.MonsterReward})) then
        local scene = GetSMGameScene();
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.MonsterReward);
        
        if(layer) then
            return layer:IsVisibled();
        end
    end
    
    return false;
end

function p.Stage05ExitCond()
    return false;
end


-----------06------------
function p.Stage06Begin()
    LogInfo("p.Stage06Begin");
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
end

function p.Stage06End()
    LogInfo("p.Stage06End");
    p.JtTag = nil;
    p.GxTag = nil;
    --p.EndTemplete();
end

function p.Stage06IsComplete()
    LogInfo("p.Stage06IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.MonsterReward);
        
    if(layer) then
        return not layer:IsVisibled();
    else
        return true;
    end
end

function p.Stage06ExitCond()
    LogInfo("p.Stage06ExitCond");
    return false;
end


--------------07------------
function p.Stage07Begin()
    LogInfo("p.Stage07Begin");
end

function p.Stage07End()
    LogInfo("p.Stage07End");
end

function p.Stage07IsComplete()
    LogInfo("p.Stage07IsComplete");
    return p.InRuoYanCity();
end

function p.Stage07ExitCond()
    return false;
end


--------------08------------
function p.Stage08IsComplete()
    LogInfo("p.Stage08IsComplete");
    
    local nPlayerid = GetPlayerId();
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(nPlayerid, USER_ATTR.USER_ATTR_STAGE));
    
    if(nPlayerStage == 21) then
        return true;
    end
    
    return false;
end



function p.Stage0End(isComplete)
    LogInfo("p.Stage0End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end
-------------------------------------引导 01 结束-----------------------------------------------



-------------------------------------引导 02 开始-----------------------------------------------
--stage == 31
function p.Stage1Begin()
    LogInfo("p.Stage1Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage1Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage11Begin()
    LogInfo("p.Stage11Begin");
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage11End()
    LogInfo("p.Stage11End");
    p.EndTemplete();
end

function p.Stage11IsComplete()
    LogInfo("p.Stage11IsComplete");
    
    if(p.IsShowLayer({NMAINSCENECHILDTAG.HeroStarUI})) then
        local scene = GetSMGameScene();
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
        
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end


function p.Stage11ExitCond()
    LogInfo("p.Stage11ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------02------------
function p.Stage12Begin()
    LogInfo("p.Stage12Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
    if(layer == nil) then
        LogInfo("error:p.Stage12Begin NMAINSCENECHILDTAG.HeroStarUI is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage12End()
    LogInfo("p.Stage12End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage12IsComplete()
    LogInfo("p.Stage12IsComplete");
    
    local nStar = HeroStar.GetLevByGrade(GetPlayerId(),1);
    LogInfo("nStar:[%d]",nStar);
    if(nStar>0) then
        return true;
    end
    return false;
end


function p.Stage12ExitCond()
    LogInfo("p.Stage12ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
    if(layer == nil) then
        LogInfo("p.Stage12ExitCond true");
        return true;
    end
    LogInfo("p.Stage12ExitCond false");
    return false;
end





---------03------------
function p.Stage13Begin()
    LogInfo("p.Stage13Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
    
    if(layer == nil) then
        LogInfo("error:p.Stage13Begin NMAINSCENECHILDTAG.HeroStarUI is nil!");
        return;
    end
    
    p.BeginTemplete(layer);
end

function p.Stage13End()
    LogInfo("p.Stage13End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage13IsComplete()
    LogInfo("p.Stage13IsComplete");
    
   if(not p.IsShowLayer({NMAINSCENECHILDTAG.HeroStarUI})) then
        return true;
    end
    return false;
end


function p.Stage13ExitCond()
    LogInfo("p.Stage13ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end






function p.Stage1End(isComplete)
    LogInfo("p.Stage1End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 02 结束-----------------------------------------------





-------------------------------------引导 03 开始-----------------------------------------------
--stage == 41
function p.Stage2Begin()
    LogInfo("p.Stage2Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage2Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage21Begin()
    LogInfo("p.Stage21Begin");
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage21End()
    LogInfo("p.Stage21End");
    p.EndTemplete();
end

function p.Stage21IsComplete()
    LogInfo("p.Stage21IsComplete");
    
    if(p.IsShowLayer({NMAINSCENECHILDTAG.PlayerMartial})) then
        local scene = GetSMGameScene();
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
        
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end


function p.Stage21ExitCond()
    LogInfo("p.Stage21ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------02------------
function p.Stage22Begin()
    LogInfo("p.Stage22Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
    if(layer == nil) then
        LogInfo("error:p.Stage22Begin NMAINSCENECHILDTAG.PlayerMartial is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage22End()
    LogInfo("p.Stage22End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage22IsComplete()
    LogInfo("p.Stage22IsComplete");
    
    local petInfo = MartialUI.GetPetInfoLayer();
    if(petInfo) then
        if(petInfo:IsVisibled()) then
            return true;
        end
    end
    return false;
end


function p.Stage22ExitCond()
    LogInfo("p.Stage22ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
    if(layer == nil) then
        LogInfo("p.Stage22ExitCond true");
        return true;
    end
    LogInfo("p.Stage22ExitCond false");
    return false;
end



---------03------------
function p.Stage23Begin()
    LogInfo("p.Stage23Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
    if(layer == nil) then
        LogInfo("error:p.Stage23Begin NMAINSCENECHILDTAG.PlayerMartial is nil!");
        return;
    end
    
    local petLayer = MartialUI.GetPetInfoLayer();
    if(petLayer == nil) then
        LogInfo("error:p.Stage23Begin NMAINSCENECHILDTAG.PlayerMartial petLayer is nil!");
        return;
    end
    
    p.BeginTemplete(petLayer);
end

function p.Stage23End()
    LogInfo("p.Stage23End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
    local petInfo = MartialUI.GetPetInfoLayer();
    if(layer and petInfo) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage23IsComplete()
    LogInfo("p.Stage23IsComplete");
    
    local petInfo = MartialUI.GetPetInfoLayer();
    if(petInfo == nil or not petInfo:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage23ExitCond()
    LogInfo("p.Stage23ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------04------------
function p.Stage24Begin()
    LogInfo("p.Stage24Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
    
    if(layer == nil) then
        LogInfo("error:p.Stage24Begin NMAINSCENECHILDTAG.PlayerMartial is nil!");
        return;
    end
    
    p.BeginTemplete(layer);
end

function p.Stage24End()
    LogInfo("p.Stage24End");
    
    LogInfo("p.Stage03Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMartial);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage24IsComplete()
    LogInfo("p.Stage24IsComplete");
    
   if(not p.IsShowLayer({NMAINSCENECHILDTAG.PlayerMartial})) then
        return true;
    end
    return false;
end


function p.Stage24ExitCond()
    LogInfo("p.Stage24ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end






---------05------------
function p.Stage25Begin()
    LogInfo("p.Stage25Begin");
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
end

function p.Stage25End()
    LogInfo("p.Stage25End");
    p.EndTemplete();
end

function p.Stage25IsComplete()
    LogInfo("p.Stage25IsComplete");
    
    if(p.IsShowLayer({NMAINSCENECHILDTAG.PlayerBackBag})) then
        local scene = GetSMGameScene();
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        
        if(layer) then
			LogInfo("p.Stage25IsComplete true");
            return layer:IsVisibled();
        end
    end
	LogInfo("p.Stage25IsComplete false");
    return false;
end


function p.Stage25ExitCond()
    LogInfo("p.Stage25ExitCond");
    
    if(p.InRuoYanCity() == false) then
        LogInfo("p.Stage25ExitCond true");
        return true;
    end
    LogInfo("p.Stage25ExitCond false");
    return false;
end



---------06------------
function p.Stage26Begin()
    LogInfo("p.Stage26Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
    p.BeginTemplete(layer);
end

function p.Stage26End()
    LogInfo("p.Stage26End");
    p.EndTemplete();
end

function p.Stage26IsComplete()
    LogInfo("p.Stage26IsComplete");
    
    local nMainPetId = RolePetFunc.GetMainPetId(GetPlayerId());
    if(nMainPetId ~= PlayerUIBackBag.GetCurPetId()) then
        return true;
    end
    return false;
end


function p.Stage26ExitCond()
    LogInfo("p.Stage26ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end



---------07------------
function p.Stage27Begin()
    LogInfo("p.Stage27Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
    p.BeginTemplete(layer);
end

function p.Stage27End()
    LogInfo("p.Stage26End");
    p.EndTemplete();
end

function p.Stage27IsComplete()
    LogInfo("p.Stage27IsComplete");
    
    if PlayerUIBackBag.BagPos.TYPE == Item.bTypeProp then
        return true;
    end
    return false;
end


function p.Stage27ExitCond()
    LogInfo("p.Stage27ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end



---------08------------
function p.Stage28Begin()
    LogInfo("p.Stage28Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
    p.BeginTemplete(layer);
end

function p.Stage28End()
    LogInfo("p.Stage28End");
    p.EndTemplete();
end

function p.Stage28IsComplete()
    LogInfo("p.Stage28IsComplete");
    
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
    
    return false;
    
end


function p.Stage28ExitCond()
    LogInfo("p.Stage28ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
        
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end



---------09------------
function p.Stage29Begin()
    LogInfo("p.Stage29Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
    p.BeginTemplete(layer);
end

function p.Stage29End()
    LogInfo("p.Stage29End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage29IsComplete()
    LogInfo("p.Stage29IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
    
    if(layer == nil or not layer:IsVisibled()) then
        LogInfo("p.Stage29IsComplete true;");
        return true;
    end
    LogInfo("p.Stage29IsComplete false;");
    return false;
end


function p.Stage29ExitCond()
    LogInfo("p.Stage29ExitCond");
    return false;
end






function p.Stage2End(isComplete)
    LogInfo("p.Stage2End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 03 结束-----------------------------------------------





-------------------------------------引导 04 开始-----------------------------------------------
--stage == 71
function p.Stage3Begin()
    LogInfo("p.Stage3Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage3Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage31Begin()
    LogInfo("p.Stage31Begin");
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage31End()
    LogInfo("p.Stage31End");
    p.EndTemplete();
end

function p.Stage31IsComplete()
    LogInfo("p.Stage31IsComplete");
    
    if(p.IsShowLayer({NMAINSCENECHILDTAG.EquipUI})) then
        local scene = GetSMGameScene();
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
function p.Stage32Begin()
    LogInfo("p.Stage32Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    if(layer == nil) then
        LogInfo("error:p.Stage32Begin NMAINSCENECHILDTAG.EquipUI is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage32End()
    LogInfo("p.Stage32End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage32IsComplete()
    LogInfo("p.Stage32IsComplete");
    
    local nEquipId = EquipUpgradeUI.GetStrangPic();
    
    if(nEquipId>0) then
        return true;
    end
    return false;
    
end


function p.Stage32ExitCond()
    LogInfo("p.Stage32ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    if(layer == nil) then
        LogInfo("p.Stage32ExitCond true");
        return true;
    end
    LogInfo("p.Stage32ExitCond false");
    return false;
end



---------03------------
function p.Stage33Begin()
    LogInfo("p.Stage33Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    if(layer == nil) then
        LogInfo("error:p.Stage33Begin NMAINSCENECHILDTAG.EquipUI is nil!");
        return;
    end
    
    p.BeginTemplete(layer);
end

function p.Stage33End()
    LogInfo("p.Stage33End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage33IsComplete()
    LogInfo("p.Stage33IsComplete");
    
    local WaitTime = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
    if(WaitTime>Wait_Time) then
        return true;
    end
    
    return false;
end


function p.Stage33ExitCond()
    LogInfo("p.Stage33ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end






---------05------------
function p.Stage35Begin()
    LogInfo("p.Stage35Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    
    if(layer == nil) then
        LogInfo("error:p.Stage34Begin NMAINSCENECHILDTAG.EquipUI is nil!");
        return;
    end
    
    p.BeginTemplete(layer);
end

function p.Stage35End()
    LogInfo("p.Stage35End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage35IsComplete()
    LogInfo("p.Stage35IsComplete");
    
    if(EquipUpgradeUI.nTagQuick) then
        local scene = GetSMGameScene();
        local layer = GetUiLayer(scene,EquipUpgradeUI.nTagQuick);
        if(layer) then
            LogInfo("p.Stage35IsComplete true");
            return true;
        end
    end
    LogInfo("p.Stage35IsComplete false");
    return false;
end


function p.Stage35ExitCond()
    LogInfo("p.Stage35ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    if(layer == nil) then
        LogInfo("p.Stage35ExitCond true");
        return true;
    end
    LogInfo("p.Stage35ExitCond false");
    return false;
end



---------06------------
function p.Stage36Begin()
    LogInfo("p.Stage36Begin");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene,EquipUpgradeUI.nTagQuick);
    p.BeginTemplete(layer);
end

function p.Stage36End()
    LogInfo("p.Stage36End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, EquipUpgradeUI.nTagQuick);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage36IsComplete()
    LogInfo("p.Stage36IsComplete");
    
    local WaitTime = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
    if(WaitTime==0) then
        return true;
    end

    return false;
end


function p.Stage36ExitCond()
    LogInfo("p.Stage36ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    if(layer == nil) then
        LogInfo("p.Stage36ExitCond true");
        return true;
    end
    LogInfo("p.Stage36ExitCond false");
    return false;
end



---------04------------
function p.Stage34Begin()
    LogInfo("p.Stage34Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    
    if(layer == nil) then
        LogInfo("error:p.Stage34Begin NMAINSCENECHILDTAG.EquipUI is nil!");
        return;
    end
    
    p.BeginTemplete(layer);
end

function p.Stage34End()
    LogInfo("p.Stage34End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage34IsComplete()
    LogInfo("p.Stage34IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage34ExitCond()
    LogInfo("p.Stage34ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



function p.Stage3End(isComplete)
    LogInfo("p.Stage3End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 04 结束-----------------------------------------------









-------------------------------------引导 05 开始-----------------------------------------------
--stage == 251
function p.Stage4Begin()
    LogInfo("p.Stage4Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage4Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage41Begin()
    LogInfo("p.Stage41Begin");
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage41End()
    LogInfo("p.Stage41End");
    p.EndTemplete();
end

function p.Stage41IsComplete()
    LogInfo("p.Stage41IsComplete");
    
    if(p.IsShowLayer({NMAINSCENECHILDTAG.Levy})) then
        local scene = GetSMGameScene();
        local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Levy);
        
        if(layer) then
            return layer:IsVisibled();
        end
    end
    return false;
end


function p.Stage41ExitCond()
    LogInfo("p.Stage41ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end



---------02------------
function p.Stage42Begin()
    LogInfo("p.Stage42Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Levy);
    if(layer == nil) then
        LogInfo("error:p.Stage32Begin NMAINSCENECHILDTAG.Levy is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage42End()
    LogInfo("p.Stage42End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Levy);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage42IsComplete()
    LogInfo("p.Stage42IsComplete");
    
    local nPlayerId = GetPlayerId();
    local nVipRank = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);

    local nBuyedLevy = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_BUYED_LEVY);   
    local nAvailBuyTime = (nVipRank+1)*10; --每天可征收次数
    local nLeftTime = nAvailBuyTime - nBuyedLevy;   --每天还可次征收数
    if(nLeftTime == 0) then
        return true;
    end
    
    return false;
end


function p.Stage42ExitCond()
    LogInfo("p.Stage42ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Levy);
    if(layer == nil) then
        LogInfo("p.Stage42ExitCond true");
        return true;
    end
    LogInfo("p.Stage42ExitCond false");
    return false;
end


function p.Stage4End(isComplete)
    LogInfo("p.Stage4End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 05 结束-----------------------------------------------






-------------------------------------引导 06 开始-----------------------------------------------
--stage == 261
function p.Stage5Begin()
    LogInfo("p.Stage5Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage5Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage51Begin()
    LogInfo("p.Stage51Begin");
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage51End()
    LogInfo("p.Stage51End");
    local scene = GetSMGameScene();
    if(scene) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage51IsComplete()
    LogInfo("p.Stage51IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    if(layer and layer:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage51ExitCond()
    LogInfo("p.Stage54ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    
    return false;
end


---------02------------
function p.Stage52Begin()
    LogInfo("p.Stage52Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    if(layer == nil) then
        LogInfo("error:p.Stage55Begin NMAINSCENECHILDTAG.RankUI is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage52End()
    LogInfo("p.Stage52End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage52IsComplete()
    LogInfo("p.Stage52IsComplete");
    
    local level = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_RANK);
    if(level>1) then
        return true;
    end
    return false;
end


function p.Stage52ExitCond()
    LogInfo("p.Stage52ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
        
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end



---------03------------
function p.Stage53Begin()
    LogInfo("p.Stage53Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    if(layer == nil) then
        LogInfo("error:p.Stage53Begin NMAINSCENECHILDTAG.RankUI is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage53End()
    LogInfo("p.Stage53End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage53IsComplete()
    LogInfo("p.Stage53IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
        
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage53ExitCond()
    LogInfo("p.Stage53ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    if(layer == nil) then
        LogInfo("p.Stage53ExitCond true");
        return true;
    end
    LogInfo("p.Stage53ExitCond false");
    return false;
end


function p.Stage5End(isComplete)
    LogInfo("p.Stage5End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end



-------------------------------------引导 06 结束-----------------------------------------------











-------------------------------------引导 07 开始-----------------------------------------------
--stage == 271
function p.Stage6Begin()
    LogInfo("p.Stage6Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage6Begin, HandleTime);
        end
    end
end


---------01------------
function p.Stage61Begin()
    LogInfo("p.Stage61Begin");
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage61End()
    LogInfo("p.Stage61End");
    p.EndTemplete();
end

function p.Stage61IsComplete()
    LogInfo("p.Stage61IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
        
    if(layer) then
        return layer:IsVisibled();
    end
    
    return false;
end


function p.Stage61ExitCond()
    LogInfo("p.Stage61ExitCond");
    
    if(p.InRuoYanCity() == false) then
        return true;
    end
    return false;
end







---------02------------
function p.Stage62Begin()
    LogInfo("p.Stage62Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    if(layer == nil) then
        LogInfo("error:p.Stage62Begin NMAINSCENECHILDTAG.Arena is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage62End()
    LogInfo("p.Stage62End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage62IsComplete()
    LogInfo("p.Stage62IsComplete");
    
    local nFirstRepute = GetDataBaseDataN("rank_config",2,DB_RANK.REPUTE);
    local nRepute = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_REPUTE);
    if(nRepute>nFirstRepute) then
        return true;
    end
    return false;
end


function p.Stage62ExitCond()
    LogInfo("p.Stage62ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    if(layer == nil) then
        LogInfo("p.Stage62ExitCond true");
        return true;
    end
    LogInfo("p.Stage62ExitCond false");
    return false;
end


---------4------------
function p.Stage64Begin()
    LogInfo("p.Stage64Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    if(layer == nil) then
        LogInfo("error:p.Stage64Begin NMAINSCENECHILDTAG.Arena is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage64End()
    LogInfo("p.Stage64End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage64IsComplete()
    LogInfo("p.Stage64IsComplete");
    
    
    if (ArenaUI.cdTime==0) then
        return true;
    end

    return false;
end


function p.Stage64ExitCond()
    LogInfo("p.Stage64ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    if(layer == nil) then
        LogInfo("p.Stage64ExitCond true");
        return true;
    end
    LogInfo("p.Stage64ExitCond false");
    return false;
end




---------03------------
function p.Stage63Begin()
    LogInfo("p.Stage63Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    if(layer == nil) then
        LogInfo("error:p.Stage63Begin NMAINSCENECHILDTAG.Arena is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage63End()
    LogInfo("p.Stage63End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage63IsComplete()
    LogInfo("p.Stage63IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
        
    if(layer==nil) then
        LogInfo("p.Stage63IsComplete true");
        return true;
    end
    
    return false;
    
end


function p.Stage63ExitCond()
    LogInfo("p.Stage63ExitCond");
    
    --[[
    if(p.InRuoYanCity() == false) then
        return true;
    end
    ]]
    
    return false;
end



function p.Stage6End(isComplete)
    LogInfo("p.Stage6End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 07 结束-----------------------------------------------






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
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
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
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
        
    if(layer) then
        return layer:IsVisibled();
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
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
    if(layer == nil) then
        LogInfo("error:p.Stage62Begin NMAINSCENECHILDTAG.PetUI is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage72End()
    LogInfo("p.Stage72End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage72IsComplete()
    LogInfo("p.Stage72IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
    if(layer == nil) then
        LogInfo("p.Stage72ExitCond true");
        return true;
    end
    LogInfo("p.Stage72ExitCond false");
    return false;
end


function p.Stage72ExitCond()
    LogInfo("p.Stage72ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PetUI);
    if(layer == nil) then
        LogInfo("p.Stage72ExitCond true");
        return true;
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
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
    --新功能声音提示
    Music.PlayEffectSound(Music.SoundEffect.REMIND);
end

function p.Stage81End()
    LogInfo("p.Stage81End");
    p.EndTemplete();
end

function p.Stage81IsComplete()
    LogInfo("p.Stage81IsComplete");
    
    if(p.IsShowLayer({NMAINSCENECHILDTAG.Fete})) then
        local scene = GetSMGameScene();
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
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
    if(layer == nil) then
        LogInfo("error:p.Stage82Begin NMAINSCENECHILDTAG.Fete is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage82End()
    LogInfo("p.Stage82End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
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
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
    if(layer == nil) then
        LogInfo("p.Stage82ExitCond true");
        return true;
    end
    LogInfo("p.Stage82ExitCond false");
    return false;
end



---------03------------
function p.Stage83Begin()
    LogInfo("p.Stage83Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
    if(layer == nil) then
        LogInfo("p.Stage83Begin NMAINSCENECHILDTAG.Fete is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage83End()
    LogInfo("p.Stage83End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage83IsComplete()
    LogInfo("p.Stage83IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
        
    if(layer==nil) then
        LogInfo("p.Stage83IsComplete true");
        return true;
    end
    
    return false;
    
end


function p.Stage83ExitCond()
    LogInfo("p.Stage83ExitCond");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
        
    if(layer==nil) then
        LogInfo("p.Stage83ExitCond true");
        return true;
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
    p.Stage27Begin();
    
    LogInfo("p.Stage86Begin");
    
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
                    if(nItemType>=31000001 and nItemType<=31000012) then
                        
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
    local layer = BackLevelThreeWin.GetPropLayer();
    if(layer == nil) then
        LogInfo("error:p.Stage87Begin BackLevelThreeWin.GetPropLayer() is nil!");
        return;
    end
    p.BeginTemplete(layer);
end



function p.Stage87IsComplete()
    LogInfo("p.Stage87IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene,BackLevelThreeWin.nTagId);
    if(layer) then
        LogInfo("p.Stage87IsComplete true");
        return true;
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
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene,BackLevelThreeWin.nTagId);
    p.BeginTemplete(layer);
end

function p.Stage88End()
    LogInfo("p.Stage88End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene,BackLevelThreeWin.nTagId);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage88IsComplete()
    LogInfo("p.Stage88IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene,BackLevelThreeWin.nTagId);
    
    if layer == nil or not layer:IsVisibled() then
        LogInfo("p.Stage88IsComplete true");
        return true;
    end
    LogInfo("p.Stage88IsComplete false");
    return false;
end


function p.Stage88ExitCond()
    LogInfo("p.Stage88ExitCond");
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
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    p.BeginTemplete(layer);
end

function p.Stage812End()
    LogInfo("p.Stage812End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage812IsComplete()
    LogInfo("p.Stage812IsComplete");
    
    local bGenCount = Item.GetItemInfoN(EquipUpgradeUI.nItemIdTemp, Item.ITEM_GEN_NUM);
    if(bGenCount>0) then
        LogInfo("p.Stage812IsComplete true");
        return true;
    end
    LogInfo("p.Stage812IsComplete false");
    return false;
end


function p.Stage812ExitCond()
    LogInfo("p.Stage812ExitCond");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
        
    if(layer == nil or not layer:IsVisibled()) then
        return true;
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


-------------------------------------引导 10 开始-----------------------------------------------
function p.Stage9Begin()
    LogInfo("p.Stage9Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage9Begin, HandleTime);
        end
    end
end


function p.Stage92IsComplete()
    LogInfo("p.Stage92IsComplete");
    
    if PlayerUIBackBag.BagPos.TYPE == Item.bTypeEquip then
        return true;
    end
    return false;
end

function p.Stage93IsComplete()
    LogInfo("p.Stage93IsComplete");
    
    local layer = BackLevelThreeWin.GetEquipLayer();
    if(layer and layer:IsVisibled()) then
        LogInfo("p.Stage93IsComplete true");
        return true;
    end
    LogInfo("p.Stage93IsComplete false");
    return false;
end

---------04------------
function p.Stage94Begin()
    LogInfo("p.Stage94Begin");
    local layer = BackLevelThreeWin.GetEquipLayer();
    if(layer == nil) then
        LogInfo("error:p.Stage94Begin BackLevelThreeWin.GetEquipLayer() is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage94End()
    LogInfo("p.Stage94End");
    
    local layer = BackLevelThreeWin.GetEquipLayer();
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage94IsComplete()
    LogInfo("p.Stage94IsComplete");
    
    local layer = BackLevelThreeWin.GetEquipLayer();
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage94ExitCond()
    LogInfo("p.Stage94ExitCond");
    
    local layer = BackLevelThreeWin.GetEquipLayer();
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end



function p.Stage9End(isComplete)
    LogInfo("p.Stage9End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 10 结束-----------------------------------------------



-------------------------------------引导 11 开始-----------------------------------------------

function p.Stage10Begin()
    LogInfo("p.Stage10Begin");
    if(p.InRuoYanCity()) then
        if(p.HandleTimerBegin) then
            UnRegisterTimer(p.HandleTimerBegin);
            p.HandleTimerBegin = nil;
        end
        p.DealProgress();
    else
        if(p.HandleTimerBegin == nil) then
            p.HandleTimerBegin = RegisterTimer(p.Stage10Begin, HandleTime);
        end
    end
end

---------02------------
function p.Stage102IsComplete()
    LogInfo("p.Stage102IsComplete");
    local skillInfo = MartialUI.GetSkillInfoLayer();
    if(skillInfo) then
        if(skillInfo:IsVisibled()) then
            return true;
        end
    end
    return false;

end

---------03------------
function p.Stage103Begin()

    LogInfo("p.Stage103Begin");
    local skillInfo = MartialUI.GetSkillInfoLayer();
    if(skillInfo == nil) then
        LogInfo("error:p.Stage103Begin MartialUI.GetSkillInfoLayer() is nil!");
        return;
    end
    p.BeginTemplete(skillInfo);
    
end

function p.Stage103End()
    LogInfo("p.Stage103End");
    local skillInfo = MartialUI.GetSkillInfoLayer();
    
    if(skillInfo) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage103IsComplete()
    LogInfo("p.Stage103IsComplete");
    
    local skillInfo = MartialUI.GetSkillInfoLayer();
    if(skillInfo == nil or not skillInfo:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage103ExitCond()
    LogInfo("p.Stage103ExitCond");
    
    local skillInfo = MartialUI.GetSkillInfoLayer();
    if(skillInfo == nil or not skillInfo:IsVisibled()) then
        return true;
    end
    return false;
end


function p.Stage10End(isComplete)
    LogInfo("p.Stage10End");
    if(isComplete == false) then
        p.CurrTaskEnd();
    end
end

-------------------------------------引导 11 结束-----------------------------------------------















-------------------------------------引导 12 开始-----------------------------------------------


---------02------------
function p.Stage012Begin()
    LogInfo("p.Stage012Begin");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    if(layer == nil) then
        LogInfo("error:p.Stage32Begin NMAINSCENECHILDTAG.EquipUI is nil!");
        return;
    end
    p.BeginTemplete(layer);
end

function p.Stage012End()
    LogInfo("p.Stage012End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
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
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipUI);
    if(layer == nil or not layer:IsVisibled()) then
        return true;
    end
    return false;
end




--装备
function p.Stage013IsComplete()
    LogInfo("p.Stage013IsComplete");
    local baptizeLayer = EquipUpgradeUI.GetLayerByTag(EquipUpgradeUI.TAG.BAPTIZE);
    local pic = GetItemButton(baptizeLayer,EquipUpgradeUI.TAG_B_PIC);
    
    if(pic:GetItemId()>0) then
        return true;
    end
    return false;
end


--洗练
function p.Stage014IsComplete()
    LogInfo("p.Stage014IsComplete");
    local baptizeLayer = EquipUpgradeUI.GetLayerByTag(EquipUpgradeUI.TAG.BAPTIZE);
    local btn = GetButton(baptizeLayer,EquipUpgradeUI.TAG_B_BTN_KEEP);
    
    if(btn and btn:IsVisibled()) then
        return true;
    end
    return false;

end

--替换
function p.Stage015IsComplete()
    LogInfo("p.Stage015IsComplete");
    local baptizeLayer = EquipUpgradeUI.GetLayerByTag(EquipUpgradeUI.TAG.BAPTIZE);
    local btn = GetButton(baptizeLayer,EquipUpgradeUI.TAG_B_BTN_B);
    
    if(btn and btn:IsVisibled()) then
        return true;
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
    local scene = GetSMGameScene();
    p.BeginTemplete(scene);
end

function p.Stage2411End()
    LogInfo("p.Stage2411End");
    p.EndTemplete();
end

function p.Stage2411IsComplete()
    LogInfo("p.Stage2411IsComplete");
    
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.WorldMap);
        
    if(layer) then
        return layer:IsVisibled();
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
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.WorldMap);
    p.BeginTemplete(layer);
end

function p.Stage2412End()
    LogInfo("p.Stage2412End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.WorldMap);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
    end
end

function p.Stage2412IsComplete()
    LogInfo("p.Stage2412IsComplete");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    if(layer) then
        LogInfo("p.Stage2412IsComplete true");
        return true;
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
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    p.BeginTemplete(layer);
end

function p.Stage2413End()
    LogInfo("p.Stage2413End");
    local scene = GetSMGameScene();
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    
    if(layer) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
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
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    if(layer == nil) then
        LogInfo("p.Stage2413ExitCond true");
        return true;
    end
    LogInfo("p.Stage2413ExitCond false");
    return false;
end


---------04------------
function p.Stage2414Begin()
    LogInfo("p.Stage2414Begin");
    p.BeginTemplete(NormalBossListUI.pLayerElite);
end

function p.Stage2414End()
    LogInfo("p.Stage2414End");
    
    if(NormalBossListUI.pLayerElite) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
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
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    if(layer == nil) then
        LogInfo("p.Stage2414ExitCond true");
        return true;
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
    p.BeginTemplete(NormalBossListUI.pLayerConfDlg);
end

function p.Stage5414End()
    LogInfo("p.Stage5414End");
    
    if(NormalBossListUI.pLayerConfDlg) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
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
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    if(layer == nil) then
        LogInfo("p.Stage2414ExitCond true");
        return true;
    end
    LogInfo("p.Stage2414ExitCond false");
    return false;
end



---------05------------
function p.Stage6414Begin()
    LogInfo("p.Stage6414Begin");
    p.BeginTemplete(ClearUpSettingUI.pLayerPrepare);
end

function p.Stage6414End()
    LogInfo("p.Stage6414End");
    
    if(ClearUpSettingUI.pLayerPrepare) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
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
    p.BeginTemplete(ClearUpSettingUI.pLayerFighting);
end

function p.Stage7414End()
    LogInfo("p.Stage7414End");
    
    if(ClearUpSettingUI.pLayerFighting) then
        p.EndTemplete();
    else
        p.JtTag = nil;
        p.GxTag = nil;
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
        return;
    end

    local taskItem = p.GetCurrTaskItem();
    
    p.JtTag = nil;
    p.GxTag = nil;
    
    --添加前头
    if(taskItem.Dir) then
        p.JtTag = p.CreateAnimate(layer,taskItem.Dir.index,0,taskItem.Dir.x,taskItem.Dir.y);
        
        --添加提示文字
        if(taskItem.TxtPos) then
            local nX,nY = p.GetJtRelativePos(taskItem.Dir.x, taskItem.Dir.y, taskItem.TxtPos.Type);
            p.BoxTag = p.CreateText(layer,taskItem.TxtPos.Txt,taskItem.TxtPos.Align,0,nX,nY);
        end
        
    end
    
    --添加光效
    if(taskItem.EffectPos) then
        p.GxTag = p.CreateAnimate(layer,taskItem.EffectPos.index,0,taskItem.EffectPos.x,taskItem.EffectPos.y);
    end
    
end

function p.EndTemplete()
    if(p.JtTag) then
        p.JtTag:RemoveFromParent(true);
        
        if(p.BoxTag) then
            p.BoxTag:RemoveFromParent(true);
        end
    end
    if(p.GxTag) then
        p.GxTag:RemoveFromParent(true);
    end
    
    p.JtTag = nil;
    p.GxTag = nil;
    p.BoxTag = nil;
end

--获得文本框相对位置根据箭头
function p.GetJtRelativePos(nX, nY, nType)
    
    LogInfo("nType:[%d]",nType);
    local x,y;
    x=0;
    y=0;
    if(nType == TutorialType.UP) then
        x = nX + 25*ScaleFactor;
        y = nY + 0;
    elseif(nType == TutorialType.DOWN) then
        x = nX + 25*ScaleFactor;
        y = nY + 95*ScaleFactor;
    elseif(nType == TutorialType.LEFT) then
        x = nX + 25*ScaleFactor;
        y = nY - 20*ScaleFactor;
    elseif(nType == TutorialType.RIGHT) then
        x = nX + 25*ScaleFactor;
        y = nY + 100*ScaleFactor;
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
function p.CreateAnimate(parent, szSprFile, nTag, nX, nY)
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
    parent:AddChild(pSpriteNode,0,nTag);
    return pSpriteNode;
end

--创建提示文本
function p.CreateText(parent, sText, nAlign, nTag, nX, nY)
    LogInfo("p.CreateText:nX:[%d], nY:[%d]", nX, nY);
    local layer = createNDUINode();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetFrameRect(CGRectMake(nX,nY,p.TipSize.w,p.TipSize.h));
	parent:AddChild(layer,0,nTag);
    
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
        label:SetTextAlignment(nAlign);
        label:SetText(sText);
        label:SetHasFontBoderColor(false);
    end
    
    return layer;
end












--当前任务的进度 KeyItem引导ID， SubItem当前任务做到第几步了
p.CurrTask = { KeyItem = 0, SubItem = 0, };
p.DataInfo = {
    [0]={
        BeginFunc=TutorialData.Stage0Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage0End,        --任务结束清理事件
        Task =  
        {
            {Dir={index="jianty03.spr",x=70,y=160}, EffectPos=nil, TxtPos = {Txt="点击对话",Align = UITextAlignment.Center, Type = TutorialType.UP}, Begin=TutorialData.Stage01Begin, End=TutorialData.Stage01End, IsComplete=TutorialData.Stage01IsComplete, ExitCond = TutorialData.Stage01ExitCond},
            {Dir={index="jianty03.spr",x=600,y=-20}, EffectPos=nil, TxtPos = {Txt="点击对话",Align = UITextAlignment.Center, Type = TutorialType.DOWN},  Begin=TutorialData.Stage02Begin, End=TutorialData.Stage02End, IsComplete=TutorialData.Stage02IsComplete, ExitCond = TutorialData.Stage02ExitCond},
            {Dir={index="jianty03.spr",x=1320,y=160}, EffectPos=nil, TxtPos = {Txt="点击对话",Align = UITextAlignment.Center, Type = TutorialType.UP},  Begin=TutorialData.Stage03Begin, End=TutorialData.Stage03End, IsComplete=TutorialData.Stage03IsComplete, ExitCond = TutorialData.Stage03ExitCond},
            {Dir={index="jianty03.spr",x=620,y=-40}, EffectPos=nil, TxtPos = {Txt="点击自动寻路战斗",Align = UITextAlignment.Left, Type = TutorialType.DOWN},   Begin=TutorialData.Stage04Begin, End=TutorialData.Stage04End, IsComplete=TutorialData.Stage04IsComplete, ExitCond = TutorialData.Stage04ExitCond},
            {Dir=nil, EffectPos=nil, Begin=TutorialData.Stage05Begin, End=TutorialData.Stage05End, IsComplete=TutorialData.Stage05IsComplete, ExitCond = TutorialData.Stage05ExitCond},
            {Dir={index="jiantx03.spr",x=680,y=380}, EffectPos=nil, TxtPos = {Txt="点击返回主城",Align = UITextAlignment.Left, Type = TutorialType.LEFT},  Begin=TutorialData.Stage06Begin, End=TutorialData.Stage06End, IsComplete=TutorialData.Stage06IsComplete, ExitCond = TutorialData.Stage06ExitCond},
            {Dir=nil, EffectPos=nil, Begin=TutorialData.Stage07Begin, End=TutorialData.Stage07End, IsComplete=TutorialData.Stage07IsComplete, ExitCond = TutorialData.Stage07ExitCond},
            {Dir={index="jianty03.spr",x=620,y=-25}, EffectPos=nil, TxtPos = {Txt="点击对话",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage02Begin, End=TutorialData.Stage02End, IsComplete=TutorialData.Stage08IsComplete, ExitCond = TutorialData.Stage02ExitCond},
        },
    },
    
    [21] = {
        BeginFunc=TutorialData.Stage9Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage9End,        --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantx03.spr",x=110,y=380}, EffectPos={index="xingong01.spr",x=110,y=430}, TxtPos = {Txt="点击行囊按钮",Align = UITextAlignment.Center, Type = TutorialType.LEFT}, Begin=TutorialData.Stage25Begin, End=TutorialData.Stage25End, IsComplete=TutorialData.Stage25IsComplete, ExitCond = TutorialData.Stage25ExitCond},
            {Dir={index="jiantx03.spr",x=350,y=390}, EffectPos=nil, TxtPos = {Txt="点击切换背包",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage27Begin, End=TutorialData.Stage27End, IsComplete=TutorialData.Stage92IsComplete, ExitCond = TutorialData.Stage27ExitCond},
            {Dir={index="jiants03.spr",x=420,y=180}, EffectPos=nil, TxtPos = {Txt="点击选择装备",Align = UITextAlignment.Left, Type = TutorialType.RIGHT},  Begin=TutorialData.Stage28Begin, End=TutorialData.Stage28End, IsComplete=TutorialData.Stage93IsComplete, ExitCond = TutorialData.Stage28ExitCond},
            
            {Dir={index="jiantx03.spr",x=520,y=310}, EffectPos=nil, TxtPos = {Txt="点击穿装备",Align = UITextAlignment.Center, Type = TutorialType.LEFT}, Begin=TutorialData.Stage94Begin, End=TutorialData.Stage94End, IsComplete=TutorialData.Stage94IsComplete, ExitCond = TutorialData.Stage94ExitCond},
        }
    },
    
    [31] = {
        BeginFunc=TutorialData.Stage1Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage1End,        --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantx03.spr",x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt="点击将星按钮",Align = UITextAlignment.Left, Type = TutorialType.LEFT},  Begin=TutorialData.Stage11Begin, End=TutorialData.Stage11End, IsComplete=TutorialData.Stage11IsComplete, ExitCond = TutorialData.Stage11ExitCond},
            {Dir={index="jiantx03.spr",x=20,y=380}, EffectPos=nil, TxtPos = {Txt="点击修炼星图",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage12Begin, End=TutorialData.Stage12End, IsComplete=TutorialData.Stage12IsComplete, ExitCond = TutorialData.Stage12ExitCond},
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage13Begin, End=TutorialData.Stage13End, IsComplete=TutorialData.Stage13IsComplete, ExitCond = TutorialData.Stage13ExitCond},
        },
    },
    [41] = {
        BeginFunc=TutorialData.Stage2Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage2End,        --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantx03.spr",x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt="点击阵法按钮",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage21Begin, End=TutorialData.Stage21End, IsComplete=TutorialData.Stage21IsComplete, ExitCond = TutorialData.Stage21ExitCond},
            {Dir={index="jiants03.spr",x=-30,y=180}, EffectPos=nil, TxtPos = {Txt="点击选择武将",Align = UITextAlignment.Right, Type = TutorialType.RIGHT}, Begin=TutorialData.Stage22Begin, End=TutorialData.Stage22End, IsComplete=TutorialData.Stage22IsComplete, ExitCond = TutorialData.Stage22ExitCond},
            {Dir={index="jiantx03.spr",x=360,y=350}, EffectPos=nil, TxtPos = {Txt="点击上阵",Align = UITextAlignment.Center, Type = TutorialType.LEFT}, Begin=TutorialData.Stage23Begin, End=TutorialData.Stage23End, IsComplete=TutorialData.Stage23IsComplete, ExitCond = TutorialData.Stage23ExitCond},
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN},  Begin=TutorialData.Stage24Begin, End=TutorialData.Stage24End, IsComplete=TutorialData.Stage24IsComplete, ExitCond = TutorialData.Stage24ExitCond},
            
            {Dir={index="jiantx03.spr",x=110,y=380}, EffectPos={index="xingong01.spr",x=110,y=430}, TxtPos = {Txt="点击行囊按钮",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage25Begin, End=TutorialData.Stage25End, IsComplete=TutorialData.Stage25IsComplete, ExitCond = TutorialData.Stage25ExitCond},
            {Dir={index="jianty03.spr",x=100,y=-35}, EffectPos=nil, TxtPos = {Txt="滑动选择武将周仓",Align = UITextAlignment.Left, Type = TutorialType.DOWN}, Begin=TutorialData.Stage26Begin, End=TutorialData.Stage26End, IsComplete=TutorialData.Stage26IsComplete, ExitCond = TutorialData.Stage26ExitCond},
            {Dir={index="jiantx03.spr",x=750,y=390}, EffectPos=nil, TxtPos = {Txt="点击选择道具",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage27Begin, End=TutorialData.Stage27End, IsComplete=TutorialData.Stage27IsComplete, ExitCond = TutorialData.Stage27ExitCond},
            {Dir={index="jiants03.spr",x=410,y=180}, EffectPos=nil, TxtPos = {Txt="点击使用经验卡",Align = UITextAlignment.Right, Type = TutorialType.RIGHT}, Begin=TutorialData.Stage28Begin, End=TutorialData.Stage28End, IsComplete=TutorialData.Stage28IsComplete, ExitCond = TutorialData.Stage28ExitCond},
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage29Begin, End=TutorialData.Stage29End, IsComplete=TutorialData.Stage29IsComplete, ExitCond = TutorialData.Stage29ExitCond},
        },
    },
    
    
    [71] = {
        BeginFunc=TutorialData.Stage3Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage3End,        --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantx03.spr",x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt="点击强化按钮",Align = UITextAlignment.Center, Type = TutorialType.LEFT},Begin=TutorialData.Stage31Begin, End=TutorialData.Stage31End, IsComplete=TutorialData.Stage31IsComplete, ExitCond = TutorialData.Stage31ExitCond},
            {Dir={index="jiantz03.spr",x=40,y=80}, EffectPos=nil, TxtPos = {Txt="点击选择装备",Align = UITextAlignment.Left, Type = TutorialType.UP},  Begin=TutorialData.Stage32Begin, End=TutorialData.Stage32End, IsComplete=TutorialData.Stage32IsComplete, ExitCond = TutorialData.Stage32ExitCond},
            {Dir={index="jianty03.spr",x=360,y=445}, EffectPos=nil, TxtPos = {Txt="点击强化装备",Align = UITextAlignment.Left, Type = TutorialType.UP},   Begin=TutorialData.Stage33Begin, End=TutorialData.Stage33End, IsComplete=TutorialData.Stage33IsComplete, ExitCond = TutorialData.Stage33ExitCond},
            
            
            --新添加(加速功能)
            {Dir={index="jiantx03.spr",x=650,y=280}, EffectPos=nil, TxtPos = {Txt="点击加速秒CD",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage35Begin, End=TutorialData.Stage35End, IsComplete=TutorialData.Stage35IsComplete, ExitCond = TutorialData.Stage35ExitCond},
            {Dir={index="jiantx03.spr",x=280,y=200}, EffectPos=nil, TxtPos = {Txt="点击确定",Align = UITextAlignment.Center, Type = TutorialType.LEFT}, Begin=TutorialData.Stage36Begin, End=TutorialData.Stage36End, IsComplete=TutorialData.Stage36IsComplete, ExitCond = TutorialData.Stage36ExitCond},
            
            
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage34Begin, End=TutorialData.Stage34End, IsComplete=TutorialData.Stage34IsComplete, ExitCond = TutorialData.Stage34ExitCond},
        },
    },
    
    [81] = {
        BeginFunc=TutorialData.Stage10Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage10End,            --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantx03.spr",x=300,y=380}, EffectPos={index="xingong01.spr",x=300,y=430}, TxtPos = {Txt="点击阵法按钮",Align = UITextAlignment.Center, Type = TutorialType.LEFT},  Begin=TutorialData.Stage21Begin, End=TutorialData.Stage21End, IsComplete=TutorialData.Stage21IsComplete, ExitCond = TutorialData.Stage21ExitCond},
            {Dir={index="jiantx03.spr",x=380,y=350}, EffectPos=nil, TxtPos = {Txt="点击选择技能",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage22Begin, End=TutorialData.Stage22End, IsComplete=TutorialData.Stage102IsComplete, ExitCond = TutorialData.Stage22ExitCond},
            {Dir={index="jiantx03.spr",x=355,y=240}, EffectPos=nil, TxtPos = {Txt="点击更换技能",Align = UITextAlignment.Left, Type = TutorialType.LEFT},  Begin=TutorialData.Stage103Begin, End=TutorialData.Stage103End, IsComplete=TutorialData.Stage103IsComplete, ExitCond = TutorialData.Stage103ExitCond},
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage24Begin, End=TutorialData.Stage24End, IsComplete=TutorialData.Stage24IsComplete, ExitCond = TutorialData.Stage24ExitCond},
        }
    },
    
    
    [121] = {
        BeginFunc=TutorialData.Stage10Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage10End,            --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantx03.spr",x=300,y=380}, EffectPos={index="xingong01.spr",x=300,y=430}, TxtPos = {Txt="点击阵法按钮",Align = UITextAlignment.Center, Type = TutorialType.LEFT}, Begin=TutorialData.Stage21Begin, End=TutorialData.Stage21End, IsComplete=TutorialData.Stage21IsComplete, ExitCond = TutorialData.Stage21ExitCond},
            {Dir={index="jiantx03.spr",x=260,y=350}, EffectPos=nil, TxtPos = {Txt="点击选择技能",Align = UITextAlignment.Left, Type = TutorialType.LEFT},  Begin=TutorialData.Stage22Begin, End=TutorialData.Stage22End, IsComplete=TutorialData.Stage102IsComplete, ExitCond = TutorialData.Stage22ExitCond},
            {Dir={index="jiantx03.spr",x=355,y=240}, EffectPos=nil, TxtPos = {Txt="点击更换技能",Align = UITextAlignment.Left, Type = TutorialType.LEFT},  Begin=TutorialData.Stage103Begin, End=TutorialData.Stage103End, IsComplete=TutorialData.Stage103IsComplete, ExitCond = TutorialData.Stage103ExitCond},
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage24Begin, End=TutorialData.Stage24End, IsComplete=TutorialData.Stage24IsComplete, ExitCond = TutorialData.Stage24ExitCond},
        }
    },
    
    
    [161] = {
        BeginFunc=TutorialData.Stage4Begin,     --判断任务是否开始
        EndFunc=TutorialData.Stage4End,         --任务结束清理事件
        Task =  
        {
            {Dir={index="jiants03.spr",x=600,y=100}, EffectPos=nil, TxtPos = {Txt="点击征收按钮",Align = UITextAlignment.Left, Type = TutorialType.RIGHT}, Begin=TutorialData.Stage41Begin, End=TutorialData.Stage41End, IsComplete=TutorialData.Stage41IsComplete, ExitCond = TutorialData.Stage41ExitCond},
            {Dir={index="jiantz03.spr",x=550,y=400}, EffectPos=nil, TxtPos = {Txt="点击征收获得银币",Align = UITextAlignment.Left, Type = TutorialType.UP},  Begin=TutorialData.Stage42Begin, End=TutorialData.Stage42End, IsComplete=TutorialData.Stage42IsComplete, ExitCond = TutorialData.Stage42ExitCond},
        },
    },
    
    
    [171] = {
        BeginFunc=TutorialData.Stage5Begin,     --判断任务是否开始
        EndFunc=TutorialData.Stage5End,         --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantz03.spr",x=160,y=-50}, EffectPos=nil, TxtPos = {Txt="点击查看军衔信息",Align = UITextAlignment.Left, Type = TutorialType.DOWN},  Begin=TutorialData.Stage51Begin, End=TutorialData.Stage51End, IsComplete=TutorialData.Stage51IsComplete, ExitCond = TutorialData.Stage51ExitCond},
            {Dir={index="jiantx03.spr",x=360,y=360}, EffectPos=nil, TxtPos = {Txt="点击可升级军衔",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage52Begin, End=TutorialData.Stage52End, IsComplete=TutorialData.Stage52IsComplete, ExitCond = TutorialData.Stage52ExitCond},
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage53Begin, End=TutorialData.Stage53End, IsComplete=TutorialData.Stage53IsComplete, ExitCond = TutorialData.Stage53ExitCond},
        },
    },
    
    
    [181] = {
        BeginFunc=TutorialData.Stage6Begin,     --判断任务是否开始
        EndFunc=TutorialData.Stage6End,         --任务结束清理事件
        Task =  
        {
            {Dir={index="jiants03.spr",x=600,y=60}, EffectPos=nil, TxtPos = {Txt="点击竞技场按钮",Align = UITextAlignment.Left, Type = TutorialType.RIGHT},  Begin=TutorialData.Stage61Begin, End=TutorialData.Stage61End, IsComplete=TutorialData.Stage61IsComplete, ExitCond = TutorialData.Stage61ExitCond},
            {Dir={index="jiantz03.spr",x=105,y=50}, EffectPos=nil, TxtPos = {Txt="点击进行挑战",Align = UITextAlignment.Left, Type = TutorialType.DOWN},  Begin=TutorialData.Stage62Begin, End=TutorialData.Stage62End, IsComplete=TutorialData.Stage62IsComplete, ExitCond = TutorialData.Stage62ExitCond},
            
            
            {Dir={index="jiants03.spr",x=700,y=300}, EffectPos=nil, TxtPos = {Txt="点击加速去除CD",Align = UITextAlignment.Left, Type = TutorialType.RIGHT},   Begin=TutorialData.Stage64Begin, End=TutorialData.Stage64End, IsComplete=TutorialData.Stage64IsComplete, ExitCond = TutorialData.Stage64ExitCond},
            
            
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage63Begin, End=TutorialData.Stage63End, IsComplete=TutorialData.Stage63IsComplete, ExitCond = TutorialData.Stage63ExitCond},
            
        },
    },
    
    
    
    [191] = {
        BeginFunc=TutorialData.Stage10Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage10End,            --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantx03.spr",x=300,y=380}, EffectPos={index="xingong01.spr",x=300,y=430}, TxtPos = {Txt="点击阵法按钮",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage21Begin, End=TutorialData.Stage21End, IsComplete=TutorialData.Stage21IsComplete, ExitCond = TutorialData.Stage21ExitCond},
            {Dir={index="jiantx03.spr",x=500,y=350}, EffectPos=nil, TxtPos = {Txt="点击选择技能",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage22Begin, End=TutorialData.Stage22End, IsComplete=TutorialData.Stage102IsComplete, ExitCond = TutorialData.Stage22ExitCond},
            {Dir={index="jiantx03.spr",x=355,y=240}, EffectPos=nil, TxtPos = {Txt="点击更换技能",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage103Begin, End=TutorialData.Stage103End, IsComplete=TutorialData.Stage103IsComplete, ExitCond = TutorialData.Stage103ExitCond},
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN},  Begin=TutorialData.Stage24Begin, End=TutorialData.Stage24End, IsComplete=TutorialData.Stage24IsComplete, ExitCond = TutorialData.Stage24ExitCond},
        }
    },
    
    [221] = {
        BeginFunc=TutorialData.Stage3Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage3End,        --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantx03.spr",x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt="点击强化按钮",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage31Begin, End=TutorialData.Stage31End, IsComplete=TutorialData.Stage31IsComplete, ExitCond = TutorialData.Stage31ExitCond},
            
            --切换选项卡
            {Dir={index="jiants03.spr",x=400,y=-50}, EffectPos=nil, TxtPos = {Txt="点击武器洗炼",Align = UITextAlignment.Left, Type = TutorialType.RIGHT}, Begin=TutorialData.Stage012Begin, End=TutorialData.Stage012End, IsComplete=TutorialData.Stage012IsComplete, ExitCond = TutorialData.Stage012ExitCond},
            
            --点击装备
            {Dir={index="jiantz03.spr",x=40,y=80}, EffectPos=nil, TxtPos = {Txt="点击选择武器",Align = UITextAlignment.Left, Type = TutorialType.DOWN}, Begin=TutorialData.Stage32Begin, End=TutorialData.Stage32End, IsComplete=TutorialData.Stage013IsComplete, ExitCond = TutorialData.Stage32ExitCond},
            
            --点击洗练
            {Dir={index="jianty03.spr",x=360,y=445}, EffectPos=nil, TxtPos = {Txt="点击进行洗炼",Align = UITextAlignment.Left, Type = TutorialType.UP}, Begin=TutorialData.Stage33Begin, End=TutorialData.Stage33End, IsComplete=TutorialData.Stage014IsComplete, ExitCond = TutorialData.Stage33ExitCond},
            
            --替换
            {Dir={index="jiantx03.spr",x=640,y=360}, EffectPos=nil, TxtPos = {Txt="点击替换",Align = UITextAlignment.Center, Type = TutorialType.UP},  Begin=TutorialData.Stage33Begin, End=TutorialData.Stage33End, IsComplete=TutorialData.Stage015IsComplete, ExitCond = TutorialData.Stage33ExitCond},
            
            --退出
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN},   Begin=TutorialData.Stage34Begin, End=TutorialData.Stage34End, IsComplete=TutorialData.Stage34IsComplete, ExitCond = TutorialData.Stage34ExitCond},
            
        },
    
    
    },
    
    
    [241] = {
        BeginFunc=TutorialData.Stage241Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage241End,        --任务结束清理事件
        Task =  
        {
            {Dir={index="jianty03.spr",x=780,y=150}, EffectPos=nil, TxtPos = {Txt="点击出城",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage2411Begin, End=TutorialData.Stage2411End, IsComplete=TutorialData.Stage2411IsComplete, ExitCond = TutorialData.Stage2411ExitCond},
            {Dir={index="jianty03.spr",x=570,y=-30}, EffectPos=nil, TxtPos = {Txt="选择城池",Align = UITextAlignment.Center, Type = TutorialType.DOWN},  Begin=TutorialData.Stage2412Begin, End=TutorialData.Stage2412End, IsComplete=TutorialData.Stage2412IsComplete, ExitCond = TutorialData.Stage2412ExitCond},
            {Dir={index="jiants03.spr",x=350,y=0}, EffectPos=nil, TxtPos = {Txt="点击精英副本",Align = UITextAlignment.Center, Type = TutorialType.RIGHT},  Begin=TutorialData.Stage2413Begin, End=TutorialData.Stage2413End, IsComplete=TutorialData.Stage2413IsComplete, ExitCond = TutorialData.Stage2413ExitCond},
            {Dir={index="jiantx03.spr",x=0,y=0}, EffectPos=nil, TxtPos = {Txt="点击副本",Align = UITextAlignment.Center, Type = TutorialType.RIGHT},  Begin=TutorialData.Stage2414Begin, End=TutorialData.Stage2414End, IsComplete=TutorialData.Stage2414IsComplete, ExitCond = TutorialData.Stage2414ExitCond},
        }
    },
        
    
    [291] = {
        BeginFunc=TutorialData.Stage7Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage7End,        --任务结束清理事件
        Task =  
        {
            {Dir={index="jiantx03.spr",x=510,y=380}, EffectPos={index="xingong01.spr",x=510,y=430}, TxtPos = {Txt="点击骑乘",Align = UITextAlignment.Center, Type = TutorialType.LEFT},  Begin=TutorialData.Stage71Begin, End=TutorialData.Stage71End, IsComplete=TutorialData.Stage71IsComplete, ExitCond = TutorialData.Stage71ExitCond},
            
            {Dir={index="jiantx03.spr",x=450,y=360}, EffectPos=nil, TxtPos = {Txt="点击进行骑乘",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage72Begin, End=TutorialData.Stage72End, IsComplete=TutorialData.Stage73IsComplete, ExitCond = TutorialData.Stage72ExitCond},
            
            {Dir={index="jiantx03.spr",x=670,y=360}, EffectPos=nil, TxtPos = {Txt="点击可培养坐骑",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage72Begin, End=TutorialData.Stage72End, IsComplete=TutorialData.Stage72IsComplete, ExitCond = TutorialData.Stage72ExitCond},
        },
    },
    [321] = {
        BeginFunc=TutorialData.Stage8Begin,     --判断任务是否开始
        EndFunc=TutorialData.Stage8End,         --任务结束清理事件
        Task =  
        {
            --宝石祭祀
            {Dir={index="jiants03.spr",x=340,y=70}, EffectPos=nil, TxtPos = {Txt="点击祭祀按钮",Align = UITextAlignment.Left, Type = TutorialType.RIGHT}, Begin=TutorialData.Stage81Begin, End=TutorialData.Stage81End, IsComplete=TutorialData.Stage81IsComplete, ExitCond = TutorialData.Stage81ExitCond},
            {Dir={index="jiantx03.spr",x=700,y=60}, EffectPos=nil, TxtPos = {Txt="祭祀获得宝石",Align = UITextAlignment.Left, Type = TutorialType.LEFT},  Begin=TutorialData.Stage82Begin, End=TutorialData.Stage82End, IsComplete=TutorialData.Stage82IsComplete, ExitCond = TutorialData.Stage82ExitCond},
            
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN},    Begin=TutorialData.Stage83Begin, End=TutorialData.Stage83End, IsComplete=TutorialData.Stage83IsComplete, ExitCond = TutorialData.Stage83ExitCond},
            
            
            --宝石礼包使用
            {Dir={index="jiantx03.spr",x=110,y=380}, EffectPos={index="xingong01.spr",x=110,y=430}, TxtPos = {Txt="点击行囊按钮",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage25Begin, End=TutorialData.Stage25End, IsComplete=TutorialData.Stage25IsComplete, ExitCond = TutorialData.Stage25ExitCond},
            
            --背包选项卡切换
            {Dir={index="jiantx03.spr",x=750,y=390}, EffectPos=nil, TxtPos = {Txt="点击道具背包",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage27Begin, End=TutorialData.Stage27End, IsComplete=TutorialData.Stage27IsComplete, ExitCond = TutorialData.Stage27ExitCond},
            
            --指向第一个道具
            {Dir={index="jiantx03.spr",x=410,y=-40}, EffectPos=nil, TxtPos = {Txt="选择宝石礼包",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage86Begin, End=TutorialData.Stage28End, IsComplete=TutorialData.Stage86IsComplete, ExitCond = TutorialData.Stage28ExitCond},
            
            --使用礼包
            {Dir={index="jiantx03.spr",x=520,y=310}, EffectPos=nil, TxtPos = {Txt="点击使用",Align = UITextAlignment.Center, Type = TutorialType.LEFT}, Begin=TutorialData.Stage87Begin, End=TutorialData.Stage94End, IsComplete=TutorialData.Stage87IsComplete, ExitCond = TutorialData.Stage87ExitCond},
            
            --确认框
            {Dir={index="jiantx03.spr",x=270,y=200}, EffectPos=nil, TxtPos = {Txt="点击确定",Align = UITextAlignment.Center, Type = TutorialType.LEFT}, Begin=TutorialData.Stage88Begin, End=TutorialData.Stage88End, IsComplete=TutorialData.Stage88IsComplete, ExitCond = TutorialData.Stage88ExitCond},
            
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN},  Begin=TutorialData.Stage29Begin, End=TutorialData.Stage29End, IsComplete=TutorialData.Stage29IsComplete, ExitCond = TutorialData.Stage29ExitCond},
            
            
            
            
            
            {Dir={index="jiantx03.spr",x=200,y=380}, EffectPos={index="xingong01.spr",x=200,y=430}, TxtPos = {Txt="点击强化按钮",Align = UITextAlignment.Center, Type = TutorialType.LEFT}, Begin=TutorialData.Stage31Begin, End=TutorialData.Stage31End, IsComplete=TutorialData.Stage31IsComplete, ExitCond = TutorialData.Stage31ExitCond},
            
            {Dir={index="jiants03.spr",x=530,y=-30}, EffectPos=nil, TxtPos = {Txt="点击宝石镶嵌",Align = UITextAlignment.Left, Type = TutorialType.RIGHT}, Begin=TutorialData.Stage012Begin, End=TutorialData.Stage012End, IsComplete=TutorialData.Stage810IsComplete, ExitCond = TutorialData.Stage012ExitCond},
            
            {Dir={index="jiantz03.spr",x=40,y=80}, EffectPos=nil, TxtPos = {Txt="点击选择武器",Align = UITextAlignment.Left, Type = TutorialType.DOWN}, Begin=TutorialData.Stage32Begin, End=TutorialData.Stage32End, IsComplete=TutorialData.Stage811IsComplete, ExitCond = TutorialData.Stage32ExitCond},
            
            {Dir={index="jiantx03.spr",x=300,y=280}, EffectPos=nil, TxtPos = {Txt="点击镶嵌按钮",Align = UITextAlignment.Left, Type = TutorialType.LEFT}, Begin=TutorialData.Stage812Begin, End=TutorialData.Stage812End, IsComplete=TutorialData.Stage812IsComplete, ExitCond = TutorialData.Stage812ExitCond},
            
            {Dir={index="jianty03.spr",x=710,y=-110}, EffectPos=nil, TxtPos = {Txt="点击关闭",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage34Begin, End=TutorialData.Stage34End, IsComplete=TutorialData.Stage34IsComplete, ExitCond = TutorialData.Stage34ExitCond},
            
        },
    },
    
    
    [541] = {
        BeginFunc=TutorialData.Stage241Begin,      --判断任务是否开始
        EndFunc=TutorialData.Stage241End,        --任务结束清理事件
        Task =  
        {
            {Dir={index="jianty03.spr",x=780,y=150}, EffectPos=nil, TxtPos = {Txt="点击出城",Align = UITextAlignment.Center, Type = TutorialType.DOWN},Begin=TutorialData.Stage2411Begin, End=TutorialData.Stage2411End, IsComplete=TutorialData.Stage2411IsComplete, ExitCond = TutorialData.Stage2411ExitCond},
            {Dir={index="jianty03.spr",x=530,y=-50}, EffectPos=nil, TxtPos = {Txt="选择城池",Align = UITextAlignment.Center, Type = TutorialType.DOWN}, Begin=TutorialData.Stage2412Begin, End=TutorialData.Stage2412End, IsComplete=TutorialData.Stage2412IsComplete, ExitCond = TutorialData.Stage2412ExitCond},
            {Dir={index="jiantx03.spr",x=0,y=0}, EffectPos=nil,TxtPos = {Txt="选择副本",Align = UITextAlignment.Center, Type = TutorialType.LEFT},Begin=TutorialData.Stage2413Begin, End=TutorialData.Stage2413End, IsComplete=TutorialData.Stage5413IsComplete, ExitCond = TutorialData.Stage2413ExitCond},
            {Dir={index="jiantx03.spr",x=350,y=200}, EffectPos=nil,TxtPos = {Txt="点击扫荡",Align = UITextAlignment.Center, Type = TutorialType.LEFT},Begin=TutorialData.Stage5414Begin, End=TutorialData.Stage5414End, IsComplete=TutorialData.Stage5414IsComplete, ExitCond = TutorialData.Stage5414ExitCond},
            {Dir={index="jiantx03.spr",x=630,y=380}, EffectPos=nil, TxtPos = {Txt="点击开始",Align = UITextAlignment.Center, Type = TutorialType.LEFT},Begin=TutorialData.Stage6414Begin, End=TutorialData.Stage6414End, IsComplete=TutorialData.Stage6414IsComplete, ExitCond = TutorialData.Stage6414ExitCond},
            {Dir={index="jiantx03.spr",x=700,y=380}, EffectPos=nil,TxtPos = {Txt="点击加速",Align = UITextAlignment.Center, Type = TutorialType.LEFT},Begin=TutorialData.Stage7414Begin, End=TutorialData.Stage7414End, IsComplete=TutorialData.Stage7414IsComplete, ExitCond = TutorialData.Stage7414ExitCond},
            
        },
    },
};

------------------------------------------------------------------------------------
--更新stage事件
GameDataEvent.Register(GAMEDATAEVENT.USERSTAGEATTR,"p.TaskBegin",p.TaskBegin);
------------------------------------------------------------------------------------



