---------------------------------------------------
--描述: 运量界面
--时间: 2012.9.13
--作者: tzq
---------------------------------------------------
Transport = {}
local p = Transport;

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

--一些可变的控件集合
p.MutableCtr = { Btn          = {btnTransport = 8, btnClearCdLoot = 12, btnClearCdTrans = 11},
                             Lable      = {txtLootCdlabel = 10, txtTransCdlabel = 9,}, };
                           
--一些不可变的控件集合
p.ImmutableCtr = { Btn          = {btnClose = 3, btnRefresh = 7,},
                                 Lable       = {txtTransTime = 4, txtLootTime = 5, txtPlayerInfo = 6}, 
                                 List          = {listMsg = 24, txtInfo = 2, viewIni = "transport/Transport_Text.ini",
                                                      ViewSize = CGSizeMake(420*ScaleFactor, 20*ScaleFactor),} };
                          
                                        
p.tbTimer = { LootTimer    = {LableTime = 13, CountDownNum = 0, TimerTag = -1, },    --拦截冷却倒计时
                       TransTimer  = {LableTime = 14, CountDownNum = 0, TimerTag = -1,},      --粮草抵达倒计时
                       TransCarTimer  = {CountDownNum = 0, TimerTag = -1,},   --粮车运行定时期
                       --RefreshPlayerTimer =  {CountDownNum = 0, TimerTag = -1,}, --刷新玩家之后定时期
                       };                             
                            
--保存一些固定不变的值  跟粮车无关   grain_static表
p.tbGrainStatic = {};  
--保存一些固定不变的值  跟粮车相关关grain_config表
p.tbGrainConfig = {};  
--从服务段获取的玩家的运送粮车相关信息
p.tbPlayerInfo = {};
--从服务段获取的页面显示的其他玩家的运送粮车相关信息
p.tbOtherUserInfo = {};
--要显示的玩家信息
p.tbMsgInfo = {};

p.TotalMsgNum = 30;  --显示的总的消息条数
                      
--layerTag层tag, btnNum运粮界面要显示的按钮数, btnTagStar按钮tag的开始点
p.tbTransLayer =  {layerTag = 1001, btnNum = 30, btnTagStar = 100, btnW = 60*ScaleFactor, btnH = 60*ScaleFactor, 
                                 layerWidth = 480*ScaleFactor;
                                 layerRect = CGRectMake(0, 75*ScaleFactor, 480*ScaleFactor, 145*ScaleFactor),};                                                    
                                
p.tbTransBtns = {}; 
p.randomYpos = {};

function p.LoadUI ()
    ArenaUI.isInChallenge = 2;
--------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end

--------------------添加运送粮草活动层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.TransportUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, 1);
    
    --添加背景图
    local pool = DefaultPicPool();
    if CheckP(pool) then
        local pic = pool:AddPicture(GetSMImgPath("action/transport.png"), false); 
        if CheckP(pic) then
            layer:SetBackgroundImage(pic);
        end
    end
    
-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("transport/Transport.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
    
-------------------------------添加子层显示玩家粮车信息------------------------------------    
    local layerTrans = createNDUILayer();
	if layerTrans == nil then
		return false;
	end
    
	layerTrans:Init();
	layerTrans:SetTag(p.tbTransLayer.layerTag);
	layerTrans:SetFrameRect(p.tbTransLayer.layerRect);
	layer:AddChild(layerTrans);
-------------------------------初始化数据------------------------------------     
    --发送登入消息
    p.initData();
    p.RefreshUI();   --当刚刚进入的时候刷新页面
    --p.RefreshMsg();
    local BtnClose = GetButton(layer, p.ImmutableCtr.Btn.btnClose);
    BtnClose:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    return true;
end

-----------------------------初始化数据---------------------------------
function p.initData()

    p.tbGrainStatic = {};  
    --获取表grain_static数据
    local StaticIdlist = GetDataBaseIdList("grain_static");
    for i, v in pairs(StaticIdlist) do
        local Record = {}; 
        Record.id = v;
        Record.LootMax = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.LOOT_MAX);                --截粮次数上限
        Record.BeLootMax = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.BE_LOOT_MAX);           --单次被截上限       
        Record.EscortMax = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.ESCORT_MAX);                --护送次数上限 
        Record.RefreshMax = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.REFRESH_MAX);                --刷新粮车品质次数上限
        Record.QicEsAwBase = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.QUICK_ESCORT_AWARD_BASE);               --快速护送所需金币基础值        
        Record.QicEsAwGrow = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.QUICK_ESCORT_AWARD_GROW);     --快速护送所需金币乘以时间的基础值         
        Record.RefCarBase = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.REFRESH_CAR_NEED_BASE);               --刷新粮车所需金币基础值
        Record.RefCarGrow = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.REFRESH_CAR_NEED_GROW);    --刷新粮车所需金币乘以时间的基础值        
        Record.ClEsCdBase = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.CLEAE_ESCORT_CDTIME_BASE);     --去除拦截冷却时间所需金币基础值               
        Record.ClEsCdGrow = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.CLEAE_ESCORT_CDTIME_GROW); --去除拦截冷却时间所需金币乘以时间的基础值
        
        Record.CallNeedBase = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.CALL_MAX_CAR_NEED_BASE);  --召唤粮车所需金币        
        Record.EnPerPercent = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.ENCOURAGE_PER_PERCENT);  --每次鼓舞士气加成百分比                
        Record.EnMax = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.ENCOURAGE_MAX);    --士气加成最高点  
        Record.EnBase = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.ENCOURAGE_NEED_BASE); --每次鼓舞士气所需金币      
        Record.BeLootPercent = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.BE_LOOT_BENIFIT_PERCENT);  --每次被截粮降收益百分比 
        Record.LootCdTime = GetDataBaseDataN("grain_static", v, DB_GRAIN_STATIC.LOOT_GRAIN_CD);             --拦截冷却时间  
        
        LogInfo("trans initdata static id = %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d,  %d", 
                        Record.id, Record.LootMax, Record.BeLootMax, Record.EscortMax, Record.RefreshMax, Record.QicEsAwBase, Record.QicEsAwGrow, Record.RefCarBase, Record.RefCarGrow, Record.ClEsCdBase, Record.ClEsCdGrow, Record.CallNeedBase, Record.EnPerPercent, Record.EnMax, Record.EnBase, Record.BeLootPercent, Record.LootCdTime);
        p.tbGrainStatic = Record;     --只有一条的信息                         
    end
    
    
    p.tbGrainConfig = {};  
    --获取表grain_config数据 
    local ConfigIdlist = GetDataBaseIdList("grain_config");
    for i, v in pairs(ConfigIdlist) do
        local Record = {}; 
        Record.id = v;
        Record.Name = GetDataBaseDataS("grain_config", v, DB_GRAIN_CONFIG.NAME);                --粮车名字
        Record.UpPercent = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.UP_PECENT);    --成功刷新几率    
        Record.LastTime = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.LAST_TIME);        --运送粮车持续时间
        Record.Repute = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.AWARD_REPUTE);            --奖励声望
        Record.MoneyBase = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.AWARD_MONEY_BASE);          --奖励银币基础    
        Record.MoneyGrow = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.AWARD_MONEY_GROW);        --奖励银币因子       
        Record.EMoneyBase = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.AWARD_EMONEY_BASE);          --奖励金币基础
        Record.EMoneyGrow = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.AWARD_EMONEY_GROW);    --奖励金币因子     
        Record.Soph = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.AWARD_SOPH);       --奖励将魂        
        Record.Stamina = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.AWARD_STAMINA);   --奖励军令
        Record.ItemType = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.AWARD_ITEM_TYPE);           --奖励物品类型
        Record.ItemCount = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.AWARD_ITEM_COUNT);       --奖励物品数量            
        Record.ItemLosePercent = GetDataBaseDataN("grain_config", v, DB_GRAIN_CONFIG.BE_LOOT_ITEM_ODDS_PERCENT);   --物品被截时掉落概率
  
        LogInfo("trans config id = %d, %s, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d", 
                        Record.id, Record.Name, Record.UpPercent, Record.LastTime, Record.Repute, Record.MoneyBase, Record.MoneyGrow, Record.MoneyBase, Record.MoneyGrow, Record.Soph, Record.Stamina, Record.ItemType, Record.ItemCount, Record.ItemLosePercent);
        table.insert(p.tbGrainConfig, Record);                
    end
    
    for i, v in pairs(p.tbGrainConfig) do
        LogInfo("i = %d, LastTime = %d, lll = %d", i, v.LastTime, p.tbGrainConfig[i].LastTime);
    end

    
    
    if p.tbGrainConfig ~= nil then
        table.sort(p.tbGrainConfig, function(a,b) return a.id < b.id  end);
    end 
    
    --初始化时间定时期标志
    p.tbTimer.LootTimer.TimerTag = -1;
    p.tbTimer.TransTimer.TimerTag = -1;
    p.tbTimer.TransCarTimer.TimerTag = -1; 
    
    
    p.tbTimer.TransCarTimer.TimerTag = RegisterTimer(p.OnTimer, 2);  --两秒中运行一次粮车
    
    --[[
    if p.tbTimer.RefreshPlayerTimer.CountDownNum <= 0 then
        layer = p.GetParent();
        if p.tbTimer.RefreshPlayerTimer.TimerTag ~= -1 then
              UnRegisterTimer(p.tbTimer.RefreshPlayerTimer.TimerTag);
              p.tbTimer.RefreshPlayerTimer.TimerTag = -1;
              p.tbTimer.RefreshPlayerTimer.CountDownNum = 0;
        end
        local btn = GetButton(layer, p.ImmutableCtr.Btn.btnRefresh);
        btn:SetTitle("刷新玩家");
    end
    ]]

    --初始化其他玩家运粮界面的信息
    p.initTransLayerInfo();
end
-----------------------------初始化运粮界面中其他玩家所代表的按钮信息---------------------------------
function p.initTransLayerInfo()
    LogInfo("p.initTransLayerInfo begin");
    local layer = p.GetParent();
    local transLayer = GetUiLayer(layer, p.tbTransLayer.layerTag);
    
    p.tbTransBtns = {}; 
    
    --获取可以显示的y坐标集合
    p.randomYpos = {};
    local count = 120/10;
    for i = 1, count do
        p.randomYpos[i] = ((i - 1)*8)*ScaleFactor;
        LogInfo("i = %d, p.randomYpos = %d", i, p.randomYpos[i]);
    end
    
    --初始化要显示的button
    for i = 1, p.tbTransLayer.btnNum do
        local btn	= createNDUIButton(); 
        btn:Init();
        local record = {};
        record.id = i;
        record.btn = btn;
        record.tag = p.tbTransLayer.btnTagStar + i - 1;
        record.norPic = nil;
        record.selPic = nil;  
        record.nPlayerId = 0;   
        record.nLooterId1 = 0;   
        record.nLooterId2 = 0;       
        record.nCdTime = 0;
        record.nTotalTime = 0;  
        
        --从1到count之间获取一个随机数
        local num = i%3;
        if num == 0 then
            num = 3;
        end
        local ranNum = math.random((num - 1)*4 + 1, num*4);

        math.random(1, count);
        record.startY = p.randomYpos[ranNum];  
        LogInfo("startY = %d, ranNum = %d, num = %d", record.startY, ranNum, num);
        record.onEvent = p.OnTransLayerUIEvent;
        table.insert(p.tbTransBtns, record);
        
        LogInfo("i = %d, p.tbTransLayer.btnNum = %d, tag = %d", i, p.tbTransLayer.btnNum, record.tag);
        btn:SetTag(record.tag);
        btn:SetFrameRect(CGRectMake(0, record.startY, p.tbTransLayer.btnW, p.tbTransLayer.btnH));
        btn:SetLuaDelegate(record.onEvent);
        LogInfo("p.initTransLayerInfo begin");
        btn:SetVisible(false);
        transLayer:AddChild(btn); 
    end
end

--初始化button数据
function p.SetButtonInit()
    for i, v in pairs(p.tbTransBtns) do
        if v.nPlayerId ~= 0 then
            local num = i%3;
            if num == 0 then
                num = 3;
            end
            local ranNum = math.random((num - 1)*4 + 1, num*4);
            v.startY = p.randomYpos[ranNum]; 
            v.btn:SetFrameRect(CGRectMake(0, v.startY, p.tbTransLayer.btnW, p.tbTransLayer.btnH));
            v.nPlayerId = 0;
            v.nCdTime = 0;
            v.nLooterId1 = 0;   
            v.nLooterId2 = 0;    
            v.btn:SetVisible(false); 
            
            LogInfo("p.SetButtonInit i = %d, v.nPlayerId = %d, v.startY = %d", i, v.nPlayerId, v.startY);
        end
    end
end


--显示其他玩家相关的数据
function p.RefreshTransLayerUI()
        LogInfo("p.RefreshTransLayerUI begin");
        --table.sort(p.tbTransBtns, function(a,b) return a.nPlayerId > b.nPlayerId   end);
        LogInfo("before p.tbOtherUserInfo = %d", table.getn(p.tbOtherUserInfo));
        
       --遍历获取的其他玩家的粮车信息
       for i, v in pairs(p.tbOtherUserInfo) do
            LogInfo("i = %d", i);
            --是否已经有button存储玩家数据

            --遍历所有的按钮,如果玩家已经存储在按钮中,那么更新玩家的位置
            local bHasBtnStorPlayer = false;
            for j, m in pairs(p.tbTransBtns) do

                 --找到存储玩家的button
                 if v.nPlayerId == m.nPlayerId then
                    --玩家已经完成运粮任务 存储玩家的按钮释放位置还原回去
                    if v.bStatus ~= 1 then   
                        local num = j%3;
                        if num == 0 then
                            num = 3;
                        end
                        local ranNum = math.random((num - 1)*4 + 1, num*4);
                        m.startY = p.randomYpos[ranNum]; 
                        m.btn:SetFrameRect(CGRectMake(0, m.startY, p.tbTransLayer.btnW, p.tbTransLayer.btnH));
                        m.nPlayerId = 0;
                        m.nCdTime = 0;
                        m.nLooterId1 = 0;   
                        m.nLooterId2 = 0;    
                        m.btn:SetVisible(false);
                        LogInfo("i = %d , btnNum = %d", i, table.getn(p.tbTransBtns));     
                    else  
                        --计算玩家最新的x坐标
                        local nTotalTime = p.tbGrainConfig[v.nGrain_config_id].LastTime;
                        m.nCdTime = v.nCarArriveCdTime;
                        m.nTotalTime = nTotalTime;
                        m.nLooterId1 = v.nLooterId1;   
                        m.nLooterId2 = v.nLooterId2;    
                        local  nTimeLast = nTotalTime - v.nCarArriveCdTime;
                        local nTotalLenth = p.tbTransLayer.layerWidth;
                        local nHasWalk = math.floor((nTimeLast*(nTotalLenth - 30*ScaleFactor))/nTotalTime);
                        
                        LogInfo("i = %d, nTotalTime = %d, nTimeLast = %d  nTotalLenth = %d, nHasWalk = %d, m.startY = %d, btnW = %d, btnH = %d", i, nTotalTime, nTimeLast, nTotalLenth, nHasWalk, m.startY, p.tbTransLayer.btnW, p.tbTransLayer.btnH);
                        
                        m.btn:SetFrameRect(CGRectMake(nHasWalk, m.startY, p.tbTransLayer.btnW, p.tbTransLayer.btnH));
                        m.btn:SetVisible(true);
                    end
                    bHasBtnStorPlayer = true;
                    break;
                end
            end   --结束在按钮中查找的for循环
            
            --在已存在的按钮中没有找到玩家的信息,找一个空按钮存储
            if not bHasBtnStorPlayer and v.bStatus == 1 then 
            
                for j, m in pairs(p.tbTransBtns) do
                    LogInfo("j = %d,  m.nPlayerId = %d", j, m.nPlayerId);
                    if m.nPlayerId == 0 then --找到第一个未存储玩家数据的button
                        LogInfo("i = %d, j = %d  v.nPlayerId = %d, m.nPlayerId = %d, config_id = %d", i, j, v.nPlayerId, m.nPlayerId, v.nGrain_config_id);
                        m.nPlayerId = v.nPlayerId;
                        m.btn:SetVisible(true);
                        
                        --设置按钮的坐标
                        local nTotalTime = p.tbGrainConfig[v.nGrain_config_id].LastTime;
                        m.nCdTime = v.nCarArriveCdTime;
                        m.nTotalTime = nTotalTime;
                        m.nLooterId1 = v.nLooterId1;   
                        m.nLooterId2 = v.nLooterId2;    
                        local  nTimeLast = nTotalTime - v.nCarArriveCdTime;
                        local nTotalLenth = p.tbTransLayer.layerWidth;
                        local nHasWalk = math.floor((nTimeLast*(nTotalLenth - 30*ScaleFactor))/nTotalTime);
                        --nHasWalk = (i - 1)/10*nTotalLenth - 80;
                        LogInfo("i = %d, nTotalTime = %d, nTimeLast = %d  nTotalLenth = %d, nHasWalk = %d, m.startY = %d, btnW = %d, btnH = %d", i, nTotalTime, nTimeLast, nTotalLenth, nHasWalk, m.startY, p.tbTransLayer.btnW, p.tbTransLayer.btnH);
                        
                        LogInfo("refresh nHasWalk = %d, nTimeLast = %d, nTotalLenth = %d, nTotalTime = %d", nHasWalk,    
                                        nTimeLast, nTotalLenth, nTotalTime);
                        
                        m.btn:SetFrameRect(CGRectMake(nHasWalk, m.startY, p.tbTransLayer.btnW, p.tbTransLayer.btnH));
                        --m.btn:SetFrameRect(CGRectMake(nHasWalk, 240, p.tbTransLayer.btnW, p.tbTransLayer.btnH));
                        local pic = nil;
                        if v.nPlayerId ~= GetPlayerId() then
                            pic = GetTransCarPic(v.nGrain_config_id);
                            m.btn:SetImage(pic);
                        else
                            pic = GetTransCarPic(v.nGrain_config_id + 5);
                            m.btn:SetImage(pic);
                        end
                        
                        --m.btn:SetImage(pic);
                        pic = GetTransCarPic(v.nGrain_config_id + 5);
                        m.btn:SetTouchDownImage(pic);
                        break;
                    end
                end  --结束在新按钮中的查找空按钮的循环
            end  --结束if未找到已存在的情况
       end --结束总的循环
       
       
        LogInfo("before btnNum = %d", table.getn(p.tbOtherUserInfo));
      
       local record = {};
       --遍历所有玩家信息,清空已经运送完毕的数据
       for i, v in pairs(p.tbOtherUserInfo) do
            if v.bStatus == 1 then
                table.insert(record, v);
            end
       end
       
       p.tbOtherUserInfo = record;
       
       LogInfo("after btnNum = %d", table.getn(p.tbOtherUserInfo));
end     

-----------------------------获取粮车显示的图片--------------------------------
function GetTransCarPic(type)

    local pool = _G.DefaultPicPool();
    local Pic = pool:AddPicture( _G.GetSMImgPath( "transport/icon_transport1.png" ), false);  
    local nWidth = p.tbTransLayer.btnW;
    local nHeight = p.tbTransLayer.btnH;  

    local nCutX = 0;
    local nCutY	 = 0;
      
    if type <= 5 then
        nCutX = nWidth * (type - 1);
        nCutY = 0;
    else
        nCutX = nWidth * (type - 5 - 1);
        nCutY = nHeight;
    end
    
    LogInfo("type = %d, nCutX = %d, nCutY = %d, nWidth = %d, nHeight = %d", type, nCutX, nCutY, nWidth, nHeight);
    Pic:Cut( _G.CGRectMake( nCutX, nCutY, nWidth, nHeight) );
    
    return Pic;
end

-----------------------------运送粮草层事件处理---------------------------------
function p.OnTransLayerUIEvent(uiNode, uiEventType, param)
    local BtnClick = NUIEventType.TE_TOUCH_BTN_CLICK;
	local tag = uiNode:GetTag();
    LogInfo("p.OnTransLayerUIEvent tag = %d", tag);

	if uiEventType == BtnClick then
        for i, v in pairs(p.tbTransBtns) do
            LogInfo("tag = %d", v.tag);
            if v.tag == tag then
                LogInfo("tag = %d, i = %d", v.tag, i); 
                --弹出拦截提示框
                local nPlayerId = GetPlayerId();
                if v.nPlayerId == nPlayerId then 
                    CommonDlgNew.ShowYesDlg("亲～您不可以拦截自己的粮车啊.",nil,nil,3);
                else
                   --p.tbPlayerInfo
                    LogInfo("v.nLooterId1 = %d, v.nLooterId2 = %d, nPlayerId = %d", v.nLooterId1, v.nLooterId2, nPlayerId); 
                   --if p.tbPlayerInfo == v.nPlayerId or  p.tbPlayerInfo == v.nPlayerId then
                    if v.nLooterId1 == nPlayerId or  v.nLooterId2 == nPlayerId then
                        CommonDlgNew.ShowYesDlg("亲～您已经拦截过他了,请手下留情吧!",nil,nil,3);
                        return true;
                    end   

                    --获取是否再拦截冷却当中
                    local cdTime = p.tbTimer.LootTimer.CountDownNum;
                    LogInfo("p.tbTimer.LootTimer.CountDownNum = %d", p.tbTimer.LootTimer.CountDownNum); 
                    if cdTime > 0 then
                        CommonDlgNew.ShowYesDlg("亲～您拦截的太凶狠了,请休息一会吧.!",nil,nil,3);
                        return true;
                    end
                
                    --获取还可以拦截别人的次数
                    local LootTime = p.tbGrainStatic.LootMax - p.tbPlayerInfo.nLootOtherNum;
                    if LootTime <= 0 then
                        CommonDlgNew.ShowYesDlg("您今天不可以再进行拦截了!",nil,nil,3);
                    else
                        --弹出拦截提示框
                        TransportLoot.LoadUI(v.nPlayerId);
                    end
                end
                break;
            end
        end
	end
    return true;
end
-----------------------------开始的时候刷新页面数据---------------------------------
function p.RefreshUI()
    LogInfo("trans p.RefreshUI begin when add");
                        
    if p.tbPlayerInfo == nil then
        return;
    end
    
    --运粮准备页
    if IsUIShow(NMAINSCENECHILDTAG.TransportPrepareUI) then
        --刷新粮车准备页面
        LogInfo("refresh prepare");
        TransportPrepare.RefreshUI();
    elseif IsUIShow(NMAINSCENECHILDTAG.TransportUI) then --运粮页面
        LogInfo("refresh Player");
        p.RefreshPlayer();    
        p.RefreshTransLayerUI();
    end
    
    LogInfo("trans p.RefreshUI end");
end

--显示主角相关的数据
function p.RefreshPlayer()
    LogInfo("p.RefreshPlayer tabsize = %d begin bStatus = %d", table.getn(p.tbPlayerInfo), p.tbPlayerInfo.bStatus);
    
    if p.tbPlayerInfo.bStatus == 1 then     --正在运粮
        LogInfo("p.RefreshPlayer bStatus == 1");
        p.SetMutableCtrStatus(true);
    else     --不在运粮
        --关闭不需要显示的button与文本
        LogInfo("p.RefreshPlayer bStatus == 0");
        p.SetMutableCtrStatus(false);
    end
    
    --刷新显示提示消息
    p.RefreshMsg();
    
    LogInfo("p.RefreshPlayer end");
end

--设置一些可变控件的显示与否
function p.SetMutableCtrStatus(bFlag)

    LogInfo("p.SetMutableCtrStatus begin");
    local layer = p.GetParent();
    local tbBtn = p.MutableCtr.Btn;
    local tbTxt = p.MutableCtr.Lable;
    
    if bFlag then   --玩家正在运送粮草
        local btn = GetButton(layer, tbBtn.btnTransport);
        btn:SetVisible(false);   --隐藏运送粮草按钮
        btn = GetButton(layer, tbBtn.btnClearCdTrans);
        btn:SetVisible(true);    --显示快马加鞭按钮
        
        local lab = GetLabel(layer, tbTxt.txtTransCdlabel)
        lab:SetVisible(true);  --显示粮草抵达时间 标签
        lab = GetLabel(layer, p.tbTimer.TransTimer.LableTime)
        lab:SetVisible(true);  --显示粮草抵达倒计时
    else
        local btn = GetButton(layer, tbBtn.btnTransport);
        btn:SetVisible(true);   --显示运送粮草按钮
        btn = GetButton(layer, tbBtn.btnClearCdTrans);
        btn:SetVisible(false);    --隐藏快马加鞭按钮
        
        local lab = GetLabel(layer, tbTxt.txtTransCdlabel)
        lab:SetVisible(false);  --隐藏粮草抵达时间 标签
        lab = GetLabel(layer, p.tbTimer.TransTimer.LableTime)
        lab:SetVisible(false);  --隐藏粮草抵达倒计时
    end
    
    --显示还可运粮次数
    local str = "";
    local TransTime = p.tbGrainStatic.EscortMax - p.tbPlayerInfo.nHasTransNum;
    LogInfo("TransTime = %d,  EscortMax = %d, HasTransNum = %d", TransTime, p.tbGrainStatic.EscortMax, p.tbPlayerInfo.nHasTransNum);
    str = str.."你今天还可以运送粮草"..TransTime.."次";
    SetLabel(layer, p.ImmutableCtr.Lable.txtTransTime, str);
    
    --显示还可拦截次数
    str = "";
    local LootTime = p.tbGrainStatic.LootMax - p.tbPlayerInfo.nLootOtherNum;
    LogInfo("LootTime = %d,  LootMax = %d, OtherNum = %d", LootTime, p.tbGrainStatic.LootMax, p.tbPlayerInfo.nLootOtherNum);
    str = str.."你今天还可以拦截他人粮草"..LootTime.."次";
    SetLabel(layer, p.ImmutableCtr.Lable.txtLootTime, str);
  
    --显示拦截冷却时间
    str = "";
    p.tbTimer.LootTimer.CountDownNum = p.tbPlayerInfo.nCanLootCdTime;
    str = FormatTime(p.tbTimer.LootTimer.CountDownNum, 1);
    SetLabel(layer, p.tbTimer.LootTimer.LableTime, str);    
    
    LogInfo("Loottime = %d", p.tbTimer.LootTimer.CountDownNum);
   
     if p.tbTimer.LootTimer.CountDownNum > 0 then
        if p.tbTimer.LootTimer.TimerTag == -1 then
            p.tbTimer.LootTimer.TimerTag = RegisterTimer(p.OnTimer, 1);
        end
    end
             
    if  bFlag  then   --如果正在运送粮草
        --显示粮草抵达时间
        str = "";
        p.tbTimer.TransTimer.CountDownNum = p.tbPlayerInfo.nCarArriveCdTime;
        str = FormatTime(p.tbTimer.TransTimer.CountDownNum, 1);
        SetLabel(layer, p.tbTimer.TransTimer.LableTime, str);    
        LogInfo("CdTransTime = %d", p.tbTimer.TransTimer.CountDownNum);
            
        if p.tbTimer.TransTimer.CountDownNum > 0 then
            if p.tbTimer.TransTimer.TimerTag == -1 then
                p.tbTimer.TransTimer.TimerTag = RegisterTimer(p.OnTimer, 1);
            end
        end
    end

    LogInfo("p.SetMutableCtrStatus end");
end

function p.OnTimer(tag)

	local layer=p.GetParent();
    if layer == nil then
        p.DataFree();
        return;
    end
    
	if tag == p.tbTimer.LootTimer.TimerTag then  --拦截倒计时
        LogInfo("CountDownNum  = %d", p.tbTimer.LootTimer.CountDownNum);
		local str = FormatTime(p.tbTimer.LootTimer.CountDownNum, 1);
		SetLabel(layer, p.tbTimer.LootTimer.LableTime, str);
        
		if p.tbTimer.LootTimer.CountDownNum <= 0 then
            if p.tbTimer.LootTimer.TimerTag ~= -1 then
                UnRegisterTimer(p.tbTimer.LootTimer.TimerTag);
                p.tbTimer.LootTimer.TimerTag = -1;
            end
			p.tbTimer.LootTimer.CountDownNum = 0;
		else
			p.tbTimer.LootTimer.CountDownNum = p.tbTimer.LootTimer.CountDownNum - 1;
		end
	elseif tag == p.tbTimer.TransTimer.TimerTag  then  --运粮倒计时
		local str = FormatTime(p.tbTimer.TransTimer.CountDownNum, 1);
		SetLabel(layer, p.tbTimer.TransTimer.LableTime, str);
        LogInfo("CountDownNum  = %d", p.tbTimer.TransTimer.CountDownNum);
                
		if p.tbTimer.TransTimer.CountDownNum <= 0 then
            if p.tbTimer.TransTimer.TimerTag ~= -1 then
                UnRegisterTimer(p.tbTimer.TransTimer.TimerTag);
                p.tbTimer.TransTimer.TimerTag = -1;
            end
			p.tbTimer.TransTimer.CountDownNum = 0;
		else
			p.tbTimer.TransTimer.CountDownNum = p.tbTimer.TransTimer.CountDownNum - 1;
		end
        
    elseif tag == p.tbTimer.TransCarTimer.TimerTag  then  --粮草运送定时期
          LogInfo("CountDownNum  = %d", p.tbTimer.TransTimer.CountDownNum);
            
          for i, v in pairs(p.tbTransBtns) do
            if v.nPlayerId ~= 0 then
                v.nCdTime = v.nCdTime - 2;
                if v.nCdTime < 0 then
                    v.nCdTime = 0;
                end
                
                local  nTimeLast = v.nTotalTime - v.nCdTime;
                local nTotalLenth = p.tbTransLayer.layerWidth;
                local nHasWalk = math.floor((nTimeLast*(nTotalLenth - 30*ScaleFactor))/v.nTotalTime);
                LogInfo("timer nHasWalk = %d, nTimeLast = %d, nTotalLenth = %d, nTotalTime = %d", nHasWalk,    
                                        nTimeLast, nTotalLenth, v.nTotalTime);
                v.btn:SetFrameRect(CGRectMake(nHasWalk, v.startY, p.tbTransLayer.btnW, p.tbTransLayer.btnH));
            end
        end
        
        --[[
     elseif tag == p.tbTimer.RefreshPlayerTimer.TimerTag  then  --粮草运送定时期
     
        LogInfo("CountDownNum  = %d", p.tbTimer.RefreshPlayerTimer.CountDownNum);
        p.tbTimer.RefreshPlayerTimer.CountDownNum = p.tbTimer.RefreshPlayerTimer.CountDownNum - 1;
        
        if p.tbTimer.RefreshPlayerTimer.CountDownNum <= 0 then
            UnRegisterTimer(p.tbTimer.RefreshPlayerTimer.TimerTag);
            p.tbTimer.RefreshPlayerTimer.TimerTag = -1;
            if  IsUIShow(NMAINSCENECHILDTAG.TransportUI) then
                local btn = GetButton(layer, p.ImmutableCtr.Btn.btnRefresh);
                btn:SetTitle("刷新玩家");
            end
            
        else
            if  IsUIShow(NMAINSCENECHILDTAG.TransportUI) then
                local btn = GetButton(layer, p.ImmutableCtr.Btn.btnRefresh);
                local str = FormatTime(p.tbTimer.RefreshPlayerTimer.CountDownNum, 1);
                btn:SetTitle(str);
            end
        end
        ]]
	end   
    
end

-----------是否刷新粮车响应函数---------------------------------
function p.onQuickTransCar(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then
        --向服务端发送快速运送粮车消息
        MsgTransport.MsgSendTransportInfo(MsgTransport.TransportActionType.QUICK_ARRIVE);
    end
end


-----------是否消除拦截冷却时间响应函数---------------------------------
function p.onClearLootTime(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then
        --向服务端发送快速运送粮车消息
        MsgTransport.MsgSendTransportInfo(MsgTransport.TransportActionType.REMOVE_LOOT_TIME);
    end
end

function p.DataFree()
    if p.tbTimer.LootTimer.TimerTag ~= -1 then
        UnRegisterTimer(p.tbTimer.LootTimer.TimerTag);
        p.tbTimer.LootTimer.TimerTag = -1;
        p.tbTimer.LootTimer.CountDownNum = 0;
    end
    
    if p.tbTimer.TransTimer.TimerTag ~= -1 then
        UnRegisterTimer(p.tbTimer.TransTimer.TimerTag);
        p.tbTimer.TransTimer.TimerTag = -1;
        p.tbTimer.TransTimer.CountDownNum = 0;
    end
    
    if p.tbTimer.TransCarTimer.TimerTag ~= -1 then
        UnRegisterTimer(p.tbTimer.TransCarTimer.TimerTag);
        p.tbTimer.TransCarTimer.TimerTag = -1;
        p.tbTimer.TransCarTimer.CountDownNum = 0;
    end    
    
    --[[
    if p.tbTimer.RefreshPlayerTimer.TimerTag ~= -1 then
        UnRegisterTimer(p.tbTimer.RefreshPlayerTimer.TimerTag);
        p.tbTimer.RefreshPlayerTimer.TimerTag = -1;
        p.tbTimer.RefreshPlayerTimer.CountDownNum = 0;
    end
    ]]
end 
-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
    local layer = p.GetParent();
    local BtnClick = NUIEventType.TE_TOUCH_BTN_CLICK;
	local tag = uiNode:GetTag();
    
    LogInfo("click tag = %d, btnClose = %d", tag, p.ImmutableCtr.Btn.btnClose);
    
	if uiEventType == BtnClick then
		if p.ImmutableCtr.Btn.btnClose == tag then                   --关闭    
            LogInfo("click CloseUI TransportUI");        
            p.DataFree();             
			CloseUI(NMAINSCENECHILDTAG.TransportUI);
            MsgTransport.MsgSendTransportInfo(MsgTransport.TransportActionType.LEAVE);    --发送离开运粮界面消息
        elseif p.ImmutableCtr.Btn.btnRefresh == tag then --显示玩家列表
            TransPlayerList.LoadUI();
        
        
        --[[
            if p.tbTimer.RefreshPlayerTimer.TimerTag == -1 then  --没有定时器在跑
                MsgTransport.MsgSendTransportInfo(MsgTransport.TransportActionType.ENTER);    --发送进入运粮界面消息
                p.tbTimer.RefreshPlayerTimer.TimerTag = RegisterTimer(p.OnTimer, 1);     
                p.tbTimer.RefreshPlayerTimer.CountDownNum = 60;
                local btn = GetButton(layer, p.ImmutableCtr.Btn.btnRefresh);
                local str = FormatTime(p.tbTimer.RefreshPlayerTimer.CountDownNum, 1);
                btn:SetTitle(str);
            end]]

        elseif p.MutableCtr.Btn.btnTransport == tag then          --运送粮草  
            --获得今天还可以运送的次数
            local TransTime = p.tbGrainStatic.EscortMax - p.tbPlayerInfo.nHasTransNum;
            if TransTime <= 0 then
                CommonDlgNew.ShowYesDlg("您今天不可以再进行运粮了!",nil,nil,3);
            else
                TransportPrepare.LoadUI();
            end
        elseif p.MutableCtr.Btn.btnClearCdTrans == tag then          --快马加鞭   
        
            if p.tbTimer.TransTimer.CountDownNum > 0 then
                local num = (math.floor((p.tbTimer.TransTimer.CountDownNum - 1)/60) + 1)* 2;
                local nPlayerId = GetPlayerId();
                local emoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);           
               
                 LogInfo("emoney = %d, num = %d, nPlayerId = %d", emoney, num, nPlayerId);  
                  
                if emoney < num then
                    CommonDlgNew.ShowYesDlg("金币不足,请充值,谢谢!",nil,nil,3);
                else
                    CommonDlgNew.ShowYesOrNoDlg( "是否花费"..num.."金币快速运送粮车", p.onQuickTransCar, true );
                end  
            end
        elseif p.MutableCtr.Btn.btnClearCdLoot == tag then --清除冷却时间
            LogInfo("p.tbTimer.LootTimer.CountDownNum = %d", p.tbTimer.LootTimer.CountDownNum);  
            if p.tbTimer.LootTimer.CountDownNum > 0 then
                local num = (math.floor((p.tbTimer.LootTimer.CountDownNum - 1)/60) + 1)* 2;
                local nPlayerId = GetPlayerId();
                local emoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);           
               
                 LogInfo("emoney = %d, num = %d, nPlayerId = %d", emoney, num, nPlayerId);  
                  
                if emoney < num then
                    CommonDlgNew.ShowYesDlg("金币不足,请充值,谢谢!",nil,nil,3);
                else
                    CommonDlgNew.ShowYesOrNoDlg( "是否花费"..num.."金币消除拦截冷却时间", p.onClearLootTime, true );
                end      
            end
        end
	end
    
	return true;
end

-----------------------------运输粮草界面信息更新----- 开始的时候获取的是所有的信息--------------------------------
function p.SetTransportInfo(tbUpInfoList)
   
    LogInfo("trans p.SetTransportInfo begin  = %d", table.getn(tbUpInfoList));
    LogInfo("trans tabSize = %d begin", table.getn(p.tbOtherUserInfo));
    
    if tbUpInfoList == nil then
        return;
    end
    
    for i, v in pairs(p.tbOtherUserInfo) do
            LogInfo("before update trans i = %d, nPlayerId = %d, Name = %s, LootTime = %d, CarTime = %d, bStatus = %d, fig_id = %d, LootedNum = %d, Morale = %d, TransNum = %d", 
                        i, v.nPlayerId, v.strPlayerName, v.nCanLootCdTime, v.nCarArriveCdTime, v.bStatus, v.nGrain_config_id, v.nLootOtherNum, v.nPersentMorale, v.nHasTransNum); 
    end

    
    --更新玩家信息
    for i, v in pairs(tbUpInfoList) do
        local bHasFind = false;
        --查找原先列表中有的数据,更新旧的数据
        for j, m in pairs(p.tbOtherUserInfo) do
            if v.nPlayerId == m.nPlayerId then  --更新这个玩家的数据
                p.tbOtherUserInfo[j] = tbUpInfoList[i];
                bHasFind = true;
                break;
            end
        end
        
        if not bHasFind then
            table.insert(p.tbOtherUserInfo, v);
        end
    end

    for i, v in pairs(p.tbOtherUserInfo) do
            LogInfo("trans i = %d, nPlayerId = %d, Name = %s, LootTime = %d, CarTime = %d, bStatus = %d, fig_id = %d, LootedNum = %d, Morale = %d, TransNum = %d", 
                        i, v.nPlayerId, v.strPlayerName, v.nCanLootCdTime, v.nCarArriveCdTime, v.bStatus, v.nGrain_config_id, v.nLootOtherNum, v.nPersentMorale, v.nHasTransNum); 
    end
    
    LogInfo("trans tabSize = %s end", table.getn(p.tbOtherUserInfo));
    
    --运粮准备页
    if IsUIShow(NMAINSCENECHILDTAG.TransportPrepareUI) then
        --刷新粮车准备页面
        LogInfo("refresh prepare");
        TransportPrepare.RefreshUI();
    elseif IsUIShow(NMAINSCENECHILDTAG.TransportUI) then --运粮页面
        LogInfo("refresh Player");
        p.RefreshPlayer();    
        p.RefreshTransLayerUI();
    end
    
	return true;
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.TransportUI);
	if nil == layer then
		return nil;
	end
    
	return layer;
end

----------------获取运送粮车是否可以开启------------------------------
function p.IsTransCanOpen()

    local NeedLev = GetDataBaseDataN("grain_static", 1, DB_GRAIN_STATIC.FUNC_REQ_LEVEL);         --所需等级      

    LogInfo("NeedLev = %d", NeedLev);

    --获取玩家的等级
    local nPlayerId     = GetPlayerId();
    local mainpetid 	= RolePetUser.GetMainPetId(nPlayerId);
    local nLev			= SafeS2N( RolePetFunc.GetPropDesc(mainpetid, PET_ATTR.PET_ATTR_LEVEL));
    LogInfo("nLev = %d", nLev);
    
    if nLev >= NeedLev then
        return true;
    else
        return false
    end
end

----------------设置玩家的信息------------------------------
function p.SetPlayerInfo(info)

    local layer = p.GetParent();
    local num = table.getn(p.tbMsgInfo);
    LogInfo("tzq Transport.SetPlayerInfo info = %s, num = %d", info, num);
    if num < p.TotalMsgNum then
        table.insert(p.tbMsgInfo, info);
    else
        p.tbMsgInfo[1] = nil;
        p.tbMsgInfo[p.TotalMsgNum] = info;
    end
    
    for i, v in pairs(p.tbMsgInfo) do
        LogInfo("tzq i = %d, info = %s", i, v);
    end
    
    p.RefreshMsg();
end

--刷新消息列表
function p.RefreshMsg()
    if  not IsUIShow(NMAINSCENECHILDTAG.TransportUI) then
        return;
    end
    
    local layer = p.GetParent();
    local ListContainer  = GetScrollViewContainer(layer, p.ImmutableCtr.List.listMsg);
    
    if (ListContainer == nil) then 
        return;
    end

    ListContainer:SetViewSize(p.ImmutableCtr.List.ViewSize);
    ListContainer:EnableScrollBar(true);
    ListContainer:RemoveAllView();
    
    --设置当前要显示的说明信息
    for i, v in pairs(p.tbMsgInfo) do
        LogInfo("tzq refreshMsg i = %d  info = %s", i, v); 
        p.AddMsgViewItem(ListContainer, i, p.ImmutableCtr.List.viewIni);
    end
    
    local num = table.getn(p.tbMsgInfo);
    if num > 4 then
        ListContainer:ShowViewByIndex(num - 4); 
    end
end

---------------------------添加控件元素-------------------------------------
function p.AddMsgViewItem(container, nId, uiFile)
    
    local view = createUIScrollView();
    if view == nil then
        LogInfo("p.LoadUI createUIScrollView failed");
        return;
    end
    
    container:SetViewSize(p.ImmutableCtr.List.ViewSize);
    
    view:Init(false);
    view:SetViewId(nId);
    view:SetTag(nId);  
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
    
    uiLoad:Load(uiFile, view, nil, 0, 0);
    LogInfo("tzq p.AddMsgViewItem uiFile = %s", uiFile); 
    SetLabel(view, p.ImmutableCtr.List.txtInfo, p.tbMsgInfo[nId]);
end

