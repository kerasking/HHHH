---------------------------------------------------
--描述: 登陆loading界面
--时间: 2012.3.26
--作者: HJQ
---------------------------------------------------

Login_LoadingUI = {}
local p = Login_LoadingUI;

local ID_LOADING_PROCESS_CTRL = 90;

local nProcessTimeTag	= 0;

function p.LoadUI()
    local scene = GetSMLoginScene();
        if scene == nil then
            LogInfo("scene == nil,load Login_MainUI failed!");
            return false;
    end
    scene:RemoveAllChildren(true);
    local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Login_LoadingUI);
    layer:SetFrameRect(RectFullScreenUILayer);
    layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
    scene:AddChild(layer);

    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end

    uiLoad:Load("Loading.ini", layer, p.OnUIEvent, 0, 0);
    uiLoad:Free();

    local LoadingProcess = RecursivUIExp(layer, {ID_LOADING_PROCESS_CTRL} );
    if CheckP(LoadingProcess) then
        LoadingProcess:SetProcess(0);
        LoadingProcess:SetTotal(100);
    end

	p.OnConstruct();
	layer:SetDestroyNotify(p.OnDeConstruct);
	
    return true;
end

function p.GetProcessCtrl()
	local scene = GetSMLoginScene();
	if scene == nil then
		LogInfo("scene == nil,load Login_MainUI p.GetProcessCtrl!");
		return false;
    end
	
	local LoadingProcess = RecursivUIExp(scene, {NMAINSCENECHILDTAG.Login_LoadingUI, ID_LOADING_PROCESS_CTRL});
	return LoadingProcess;
end

function p.SetStyle(nValue)
    local LoadingProcess = p.GetProcessCtrl();
    if CheckP(LoadingProcess) then
        LoadingProcess:SetStyle(nValue);
    end
end

function p.SetProcess(nPercent)
    local LoadingProcess = p.GetProcessCtrl();
    if CheckP(LoadingProcess) then
        LoadingProcess:SetProcess(nPercent);
    end
end

function p.OnUIEvent(uiNode, uiEventType, param)
	return true;
end

function p.OnProcessTimer(nTag)
	if not CheckN(nProcessTimeTag) or
		not CheckN(nTag) or
		nTag ~= nProcessTimeTag then
		return;
	end
	
	local LoadingProcess = p.GetProcessCtrl();
	if not CheckP(LoadingProcess) then
		return;
	end
	
	local nCurProcess	= ConvertN(LoadingProcess:GetProcess());
	local nToatl		= ConvertN(LoadingProcess:GetTotal());
	
	p.SetProcess((nCurProcess + 20) % nToatl);
end

function p.OnConstruct()
	nProcessTimeTag	= _G.RegisterTimer(p.OnProcessTimer, 1);
end

function p.OnDeConstruct()
	_G.UnRegisterTimer(nProcessTimeTag);
end
