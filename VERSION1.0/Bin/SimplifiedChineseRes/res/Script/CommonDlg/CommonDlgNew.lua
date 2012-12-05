---------------------------------------------------
--描述: 通用对话框
--时间: 2012.6.4
--作者: chh
---------------------------------------------------




---------------------------------说明----------------------------
----事件回调原型-----
--回调原型1. function (eventType, param)
--回调原型2. function (eventType, param, val)

---带有 “确定”和“定时消失”功能
--function CommonDlgNew.ShowYesDlg(tip, callback, param, timeout);(回调原型1)

---带有“确定”和“取消”功能
--function CommonDlgNew.ShowYesOrNoDlg(tip, callback, param, timeout);(回调原型1)

---带有“确定”和“取消”和“不在提示复选框”功能(bIsTip:提示框的值真或假)
--function CommonDlgNew.ShowNotHintDlg(tip, callback, param, timeout);(回调原型2)

---带有 “输入框”和“确定”和“取消" 功能(nNum:输入的数量)
--function CommonDlgNew.ShowInputDlg(tip, callback, param, nDefault, nMaxLength);(回调原型2)

---带有  “纯文本提示” 功能
--function CommonDlgNew.ShowTipDlg(tip);

---带有  “纯文本提示动画” 功能
--function CommonDlgNew.ShowTipsDlg(tTips);

CommonDlgNew = {};
local p = CommonDlgNew;

----对话框id生成------
local tIdGen = {};
local nCurId = NMAINSCENECHILDTAG.CommonDlgNew;
local nMaxId = 65535*2;
local tIdCur = {};

--事件回调列表
local tCallBackList = {};
--tCallBackList{callback:function(nId, nEvent, param), param:param, timeoutevent:p.BtnOk}


--定时器ID列表
local tTimeTag2DlgId = {};

p.BtnOk     = 101;  --确定
p.BtnNo     = 102;  --取消
p.LblTip    = 103;  --提示文字
p.InputNum  = 104;  --输入框
p.ChkNotTip = 105;  --不在显示复选框

p.OrderLayer= 10000; --提示框的排序

--提示框大小
local winsize = GetWinSize();

p.TipFontSize   = 18;

------------------------------------------------------------------------------------------------
function p.ShowYesDlg(tip, callback, param, timeout,color,flag)
    --color:1表示默认颜色
    --color:2表示绿色颜色
    --color:4表示红色颜色
    --color:10表示紫色颜色
    --flag:表示要不要显示确定按钮
    local scene = GetRunningScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlgNew.ShowYesDlg failed!");
		return 0;
	end
	
	local bSucess, nTag = p.GenerateDlgId();
	
	if not bSucess then
		return 0;
	end
	
    --创建层
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:bringToTop();
	layer:SetTag(nTag);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, p.OrderLayer);
    layer:SetDestroyNotify(p.OnDeConstruct);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("ShowYesDlg.ini", layer, p.OnUIEventShowYesDlg, 0, 0);
    if flag==1 then
        local determine = GetButton(layer, p.BtnOk);
        determine:SetVisible(false);
    end
	uiLoad:Free();
	
    --设置回调信息
    if(callback) then
        tCallBackList[nTag] = {};
        tCallBackList[nTag].callback = callback;
        tCallBackList[nTag].param = param;
        tCallBackList[nTag].timeoutevent = p.BtnOk;
    end
	
    --设置显示文字
	local lb = RecursiveLabel(scene, {nTag, p.LblTip});
	if CheckP(lb) then
		if not CheckS(tip) then
			lb:SetText("");
		else
			lb:SetText(tip);
		end
        if color==2 then
            LogInfo("*******color==2*******");
            lb:SetFontColor(ccc4(0,100,0,255));
        elseif color==4 then
            LogInfo("*******color==4*******");
            lb:SetFontColor(ccc4(220,20,60,255));
        elseif color==10 then
            LogInfo("*******color==10*******");
            lb:SetFontColor(ccc4(139,0,139,255));      
        end
	end
    
    --定时器
	if CheckN(timeout) and 0 < timeout then
		local nTimeTag	= _G.RegisterTimer(p.OnProcessTimer, timeout);
        LogInfo("p.ShowYesDlg nTimeTag:[%d]",nTimeTag);
        if CheckN(nTimeTag) then
            tTimeTag2DlgId[nTimeTag] = nTag;
        end
	end
	
    --音效
    Music.PlayEffectSound(Music.SoundEffect.POPWIN);

    LogInfo("CommonDlgNew.ShowYesDlg:nTag:[%d]",nTag);
	return nTag;
end

function p.OnUIEventShowYesDlg(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("CommonDlgNew.OnUIEventShowYesDlg[%d]", tag);
	
	local bSucess, nDlgId = p.GetDlgIdByChildNode(uiNode);
	if not bSucess then
		LogError("CommonDlgNew.OnUIEventShowYesDlg dlg id error");
		return true;
	end
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.BtnOk == tag or p.BtnNo == tag then
			p.CloseDlg(nDlgId, tag);
		end
	end
	return true;
end





------------------------------------------------------------------------------------------------
function p.ShowYesOrNoDlg(tip, callback, param, timeout)
    local scene = GetRunningScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlgNew.ShowYesDlg failed!");
		return 0;
	end
	
	local bSucess, nTag = p.GenerateDlgId();
	
	if not bSucess then
		return 0;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:bringToTop();
	layer:SetTag(nTag);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, p.OrderLayer);
	layer:SetDestroyNotify(p.OnDeConstruct);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("ShowYesOrNoDlg.ini", layer, p.OnUIEventShowYesOrNoDlg, 0, 0);
	uiLoad:Free();
	
    if(callback) then
        tCallBackList[nTag] = {};
        tCallBackList[nTag].callback = callback;
        tCallBackList[nTag].param = param;
        tCallBackList[nTag].timeoutevent = p.BtnNo;
        LogInfo("callback nTag:[%d]",nTag);
    end
	
	local lb = RecursiveLabel(scene, {nTag, p.LblTip});

	if CheckP(lb) then
		if not CheckS(tip) then
			lb:SetText("");
		else
			lb:SetText(tip);
		end
	end
    
    --定时器
	if CheckN(timeout) and 0 < timeout then
		local nTimeTag	= _G.RegisterTimer(p.OnProcessTimer, timeout);
        if CheckN(nTimeTag) then
            tTimeTag2DlgId[nTimeTag] = nTag;
        end
	end

    --音效
    Music.PlayEffectSound(Music.SoundEffect.POPWIN);


	return nTag;
end

function p.OnUIEventShowYesOrNoDlg(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("CommonDlgNew.OnUIEventShowYesOrNoDlg[%d]", tag);
	
	local bSucess, nDlgId = p.GetDlgIdByChildNode(uiNode);
	if not bSucess then
		LogError("CommonDlgNew.OnUIEventShowYesDlg dlg id error");
		return true;
	end
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        LogInfo("tCallBackList tag:[%d]",tag);
        local pParent = uiNode:GetParent();
        p.CloseDlg(nDlgId, tag, tCallBackList[pParent:GetTag()].param);
	end
	return true;
end



------------------------------------------------------------------------------------------------
function p.ShowNotHintDlg(tip, callback, param, timeout)
    local scene = GetRunningScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlgNew.ShowNotHintDlg failed!");
		return 0;
	end
	
	local bSucess, nTag = p.GenerateDlgId();
	
	if not bSucess then
		return 0;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:bringToTop();
	layer:SetTag(nTag);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, p.OrderLayer);
	layer:SetDestroyNotify(p.OnDeConstruct);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("ShowNotHintDlg.ini", layer, p.OnUIEventShowNotHintDlg, 0, 0);
	uiLoad:Free();
	
    if(callback) then
        tCallBackList[nTag] = {};
        tCallBackList[nTag].callback = callback;
        tCallBackList[nTag].param = param;
        tCallBackList[nTag].timeoutevent = p.BtnNo;
    end
	
	local lb = RecursiveLabel(scene, {nTag, p.LblTip});

	if CheckP(lb) then
		if not CheckS(tip) then
			lb:SetText("");
		else
			lb:SetText(tip);
		end
	end
    
    --定时器
	if CheckN(timeout) and 0 < timeout then
		local nTimeTag	= _G.RegisterTimer(p.OnProcessTimer, timeout);
        if CheckN(nTimeTag) then
            tTimeTag2DlgId[nTimeTag] = nTag;
        end
	end

    --音效
    Music.PlayEffectSound(Music.SoundEffect.POPWIN);

	return nTag;
end

function p.OnUIEventShowNotHintDlg(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventShowNotHintDlg[%d]", tag);
	
	local bSucess, nDlgId = p.GetDlgIdByChildNode(uiNode);
	if not bSucess then
		LogError("CommonDlg.OnUIEventShowNotHintDlg dlg id error");
		return true;
	end
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
        local chk = GetUiNode(uiNode:GetParent(),p.ChkNotTip);
        chk = ConverToCheckBox(chk);
        local bIsTag = chk:IsSelect();
        p.CloseDlg(nDlgId, tag, bIsTag);
        
	end
	return true;
end





------------------------------------------------------------------------------------------------
function p.ShowInputDlg(tip, callback, param, nDefault, nMaxLength)
    local scene = GetRunningScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlg.ShowInputDlg failed!");
		return 0;
	end
	
	local bSucess, nTag = p.GenerateDlgId();
	
	if not bSucess then
		return 0;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:bringToTop();
	layer:SetTag(nTag);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, p.OrderLayer);
	layer:SetDestroyNotify(p.OnDeConstruct);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("ShowInputDlg.ini", layer, p.OnUIEventInputDlg, 0, 0);
	uiLoad:Free();
	
    local inputBox = GetUiNode(layer,p.InputNum);
    inputBox = ConverToEdit(inputBox);
    
    if(nMaxLength) then
        inputBox:SetMaxLength(nMaxLength);
    else
        inputBox:SetMaxLength(10);
    end
    
    
    if(not CheckN(nDefault)) then
        nDefault = 1;
    end
    
    inputBox:SetText(nDefault.."");
    
    if(callback) then
        tCallBackList[nTag] = {};
        tCallBackList[nTag].callback = callback;
        tCallBackList[nTag].param = param;
        tCallBackList[nTag].timeoutevent = p.BtnNo;
    end
	
	local lb = RecursiveLabel(scene, {nTag, p.LblTip});

	if CheckP(lb) then
		if not CheckS(tip) then
			lb:SetText("");
		else
			lb:SetText(tip);
		end
	end
 
    --音效
    Music.PlayEffectSound(Music.SoundEffect.POPWIN);

	return nTag;
end

function p.OnUIEventInputDlg(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventShowNotHintDlg[%d]", tag);
	
	local bSucess, nDlgId = p.GetDlgIdByChildNode(uiNode);
	if not bSucess then
		LogError("CommonDlg.OnUIEventInputDlg dlg id error");
		return true;
	end
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(p.BtnOk == tag) then
            local inputBox = GetUiNode(uiNode:GetParent(),p.InputNum);
            inputBox = ConverToEdit(inputBox);
            local num = inputBox:GetText();
            p.CloseDlg(nDlgId, tag, num);
        elseif(p.BtnNo == tag) then
            p.CloseDlg(nDlgId, tag, 0);
        end
        
	end
	return true;
end



------------------------------------------------------------------------------------------------
function p.ShowTipDlg(sTip)
    LogInfo("p.ShowTipDlg:[%s]",sTip);
    p.ShowTipsDlg({{sTip,FontColor.Text}});
end


--格式{{nTime=0,nStates = 0,tFont_tag={nTag11，nTag12，nTag13...},{nTime=0,tFont_tag={nTag21，nTag22，nTag23...}}}
p.FontLists         = {};                             --全部字体  
p.nFontHeight       = p.TipFontSize*ScaleFactor;      --字体高度
p.nSlideSpeed       = 8*ScaleFactor;                  --滑动速度
p.nSlideVanishSpeed = 60;                             --滑动消失速度
p.nTimerTag         = nil;                            --定时器ID
p.nTimerLoopTime    = 1/10;                           --定时器循环时间
p.nShowCount        = 3;                              --同时能显示font的数量
p.nVanishTime       = 3;                              --消失的时间
p.nLevtRightOffset  = 2*ScaleFactor;                  --左右便宜位置

-- tTips格式{{nTip1,sColor1},{nTip2,sColor2},{nTip3,sColor3}}
function p.ShowTipsDlg(tTips)
    LogInfo("p.ShowTipsDlg:[%s]",tTips[1][1]);
    local scene = GetRunningScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlgNew.ShowTipsDlg failed!");
		return 0;
	end
    
    local nTags = {};
    nTags.nTime = os.time();
    nTags.nStates = 0;
    nTags.tFont_tag = {};
    
    for i,v in ipairs(tTips) do
        local bSucess, nTag = p.GenerateDlgId();
        if not bSucess then
            return 0;
        end
        
        local sTip = v[1];
        local sFontColor = v[2];
        
        
        if(sTip == nil) then
            LogInfo("sTip is nil!");
            sTip = "";
        end
        
        if(sFontColor == nil) then
            LogInfo("sFontColor is nil!");
            sFontColor = ItemColor[0];
        end
        
        local LabelRect = CGRectMake(-winsize.w ,-p.nFontHeight ,winsize.w, p.nFontHeight);
        local label  = CreateLabel(sTip, LabelRect, p.TipFontSize, sFontColor);
        label:SetTextAlignment(UITextAlignment.Center);
        label:SetTag(nTag);
        
        if(sFontColor) then
            label:SetFontColor(sFontColor);
        end
        scene:AddChildZ(label, p.OrderLayer);
        
        --插入文本框tag
        table.insert(nTags.tFont_tag,nTag);
        
        --定时器
        if(p.nTimerTag == nil) then
            p.nTimerTag	= _G.RegisterTimer(p.OnProcessTextTimer, p.nTimerLoopTime);
        end
        
        
    end
    
    --插入文本框tag
    p.InsertFont(nTags);
    
    --移除文本框Tag
    p.RemoveTooFont();
    
    --音效
    Music.PlayEffectSound(Music.SoundEffect.POPWIN);
end


--插入字体
function p.InsertFont(nTag)
    table.insert(p.FontLists,nTag);
end

--字体太多应该立刻删除
function p.RemoveTooFont()
    local nRemoveCount = #p.FontLists - p.nShowCount;
    LogInfo("nRemoveCount:[%d]",nRemoveCount);
    if(nRemoveCount > 0) then
        for i=1,nRemoveCount do
            LogInfo("p.RemoveTooFont i:[%d]",i);
            local fonts = p.FontLists[i];
            p.DeleteFontByIndex(fonts);
        end
    end
    
end


function p.DeleteFontByIndex(fonts)
    LogInfo("p.DeleteFontByIndex");
    local scene = GetRunningScene();
    for j,v in ipairs(fonts.tFont_tag) do
        LogInfo("v:[%d]",v);
        local label = GetLabel(scene, v);
        if(label) then
            LogInfo("p.DeleteFontByIndex success!");
            label:RemoveFromParent(true);
        else
            LogInfo("p.DeleteFontByIndex fail!");
        end
        p.ReturnDlgId(v);
    end
    table.remove(p.FontLists,1);
end

-----定时器回调-----
function p.OnProcessTextTimer(nTimeTag)
    
    --判断每一个字体是否在自己相应的位置（当前位置比自己相应位置高那么就不做操作）
    LogInfo("p.FontLists:[%d]",#p.FontLists);
    
    for i=1,#p.FontLists do
        local v =  p.FontLists[i];
        
        if(v ~= nil) then
            
            LogInfo("i:[%d]",i);
            --当前字体应该在的中心位置
            local nCurrShouldPos = winsize.h/2 - (#p.FontLists-1)*p.nFontHeight;
            
            --当前字体应该在的起始位置
            local nBeginShouldPos = winsize.h/2 - (#p.FontLists-i)*p.nFontHeight;
            LogInfo("nBeginShouldPos:[%d],#p.FontLists:[%d]",nBeginShouldPos,#p.FontLists);
            
            local bFlag = false;
            LogInfo( "#v.tFont_tag:[%d]",#v.tFont_tag );
            for j,nTag in ipairs(v.tFont_tag) do
                LogInfo( "j:[%d],nTag:[%d]",j,nTag );
                local scene = GetRunningScene();
                local label = GetLabel(scene, nTag);
                if(label) then
                    LogInfo( "label != nil!" );
                    --最终位置计算
                    local rect = label:GetFrameRect();
                    
                    local nShouldPos = nBeginShouldPos - (j-1)*p.nFontHeight;
                    local nMovedPos  = 0;
                    local nMovedLR   = 0;
                    if(i==#p.FontLists) then
                        --LogInfo("i:=[%d]",i);
                        nMovedPos = nShouldPos;
                    else
                        nMovedPos  = rect.origin.y;
                        nMovedPos = nMovedPos - p.nSlideSpeed;
                        if(nMovedPos<nShouldPos) then
                            nMovedPos = nShouldPos;
                        end
                    end
                    
                    
                    --左右动画计算
                    local nMod = v.nStates % 3;
                    if(v.nStates<=3) then
                        if(nMod == 0) then
                            nMovedLR = 0;
                        elseif(nMod == 1) then
                            nMovedLR = -p.nLevtRightOffset;
                        end
                    end
                    
                    
                    --超时消失计算
                    if(os.time()-v.nTime>=p.nVanishTime) then
                        
                        local color = label:GetFontColor();
                        if(color.a ~= 0) then
                            nMovedPos = rect.origin.y - p.nSlideSpeed;
                            local colora = color.a - p.nSlideVanishSpeed;
                            if(colora<0) then
                                colora = 0;
                            end
                            color.a = colora;
                            label:SetFontColor(color);
                        else
                            --LogInfo("a==0");
                            bFlag = true
                        end
                    end
                    
                    
                    local LabelRect = CGRectMake(nMovedLR ,nMovedPos ,winsize.w, p.nFontHeight);
                    label:SetFrameRect(LabelRect);
                else
                    LogInfo( "label == nil!" );
                    
                    bFlag = true;
                    
                end
                
                
            end
            
            v.nStates = v.nStates + 1;
            
            if(bFlag) then
                p.DeleteFontByIndex(v);
            end
        
        end
    end
    
    
    if(#p.FontLists == 0) then
        if(p.nTimerTag) then
            _G.UnRegisterTimer(p.nTimerTag);
            p.nTimerTag = nil;
        end
    end
    
end


------------------------------------------------------------------------------------------------
--产生一个对话框ID
function p.GenerateDlgId()
	for i=NMAINSCENECHILDTAG.CommonDlgNew, nMaxId do
		if nil == tIdGen[i] then
			tIdGen[i]	= true;
			if i == nCurId then
				nCurId		= nCurId + 1;
			end
			tIdCur[#tIdCur+1] = i;
			return true, i;
		end
	end
	LogError("对话框id生成 error");
	return false, 0;
end

--根据Tag返回对话框ID
function p.ReturnDlgId(nId)
	if not p.CheckDlgId(nId) then
		return;
	end
	
	local find = 0;
	for i, v in ipairs(tIdCur) do
		if v == nId then
			find = i;
		end
	end
	
	if find > 0 then
		for i=find, #tIdCur - 1 do 
			tIdCur[find] = tIdCur[find+1];
		end
		tIdCur[#tIdCur] = nil;
	end
	
	tIdGen[nId] = nil;
end

--检测对话框是否存在
function p.CheckDlgId(nId)
	if not CheckN(nId) or nId < NMAINSCENECHILDTAG.CommonDlg or nId > nMaxId then
		return false;
	end
	
	return true;
end

--获得头一个对话框ID
function p.GetTopDlgId()
	if #tIdCur > 0 and CheckN(tIdCur[#tIdCur]) then
		return true, tIdCur[#tIdCur];
	end
	return false, 0;
end

--卸载对话框事件
function p.UnDlgEvent(nDlgId)  
    tCallBackList[nDlgId] = nil;
end


----对话框销毁-------
function p.CloseDlg(nDlgId, nEventType, val)
	if not p.CheckDlgId(nDlgId) then
		return false;
	end
    
    --事件回调
    if p.CheckDlgId(nDlgId) and tCallBackList[nDlgId] then 
        if CheckFunc(tCallBackList[nDlgId].callback) then
            if(nEventType) then
                tCallBackList[nDlgId].callback(nEventType, tCallBackList[nDlgId].param, val);
                tCallBackList[nDlgId] = nil;
            end
        else
            tCallBackList[nDlgId] = nil;
        end
    end
	
    --销毁层
	local scene = GetRunningScene();
	if CheckP(scene) then
		scene:RemoveChildByTag(nDlgId, true);
		return true;
	end
	
	return false;
end

--关闭一个对话框
function p.CloseOneDlg()
	local bSucess, nId = p.GetTopDlgId();
	if not bSucess then
		LogInfo("CommonDlgNew: p.CloseOneDlg not bSucess");
		return false;
	end
	
	if not p.CloseDlg(nId) then
		LogInfo("p.CloseOneDlg not p.CloseDlg[%d]", nId);
		return false;
	end
	
	return true;
end

-----定时器回调-----
function p.OnProcessTimer(nTimeTag)
	
	if CheckT(tTimeTag2DlgId) and CheckN(tTimeTag2DlgId[nTimeTag]) then
        local nDlgTag = tTimeTag2DlgId[nTimeTag];
        LogInfo("CommonDlgNew.OnProcessTimer:nDlgTag:[%d]", nDlgTag);
        
        local eventType = nil;
        if(tCallBackList and tCallBackList[nDlgTag]) then
            eventType = tCallBackList[nDlgTag].timeoutevent;
        end
        
		p.CloseDlg(nDlgTag, eventType);
	end
	LogInfo("p.OnProcessTimer nTimeTag:[%d]",nTimeTag);
	_G.UnRegisterTimer(nTimeTag);
    tTimeTag2DlgId[nTimeTag] = nil;
end

--获得对话框根据节点
function p.GetDlgIdByChildNode(child)
	if not CheckP(child) then
        LogInfo("p.GetDlgIdByChildNode child is error!");
		return false, 0;
	end
	
	local dlg = PRecursiveUILayer(child, 1);
	if not CheckP(dlg) then
        LogInfo("p.GetDlgIdByChildNode dlg is error!");
		return false, 0;
	end
	
	local nTag = dlg:GetTag();
	
	if not p.CheckDlgId(nTag) then
		return false, 0;
	end
	
	return true, nTag;
end

--销毁层调用方法
function p.OnDeConstruct(node, bClearUp)
	if CheckP(node) and CheckB(bClearUp) and bClearUp then
		local nTag = node:GetTag();
		p.ReturnDlgId(nTag);
		
        
        --如果不是被用户选择或定时销毁那么就调用他的默认回调
        if p.CheckDlgId(nDlgId) and tCallBackList[nDlgId] and CheckFunc(tCallBackList[nDlgId].callback) then
        
            tCallBackList[nTag].callback(tCallBackList[nTag].timeoutevent, tCallBackList[nTag].param, val);
            tCallBackList[nDlgId] = nil;
            
        end
        
        --销毁定时器
		for i, v in pairs(tTimeTag2DlgId) do
            LogInfo("p.OnDeConstruct i:[%d],v:[%d]",i,v);
			if v == nTag then
				_G.UnRegisterTimer(i);
                LogInfo("tTimeTag2DlgId i:[%d]",i);
                tTimeTag2DlgId[i] = nil;
			end
		end
	end 
end























