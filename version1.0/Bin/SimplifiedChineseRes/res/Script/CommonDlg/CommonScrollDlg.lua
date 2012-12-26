---------------------------------------------------
--描述: 通用对话框
--时间: 2012.9.10
--作者: chh
---------------------------------------------------

---------------------------------说明----------------------------
---带有  “纯文本提示动画” 功能
--function CommonScrollDlg.ShowTipDlg(tTips);

CommonScrollDlg = {};
local p = CommonScrollDlg;

--提示框大小
local winsize = GetWinSize();

p.FontCacheLists    = {};                               --全部缓存未显示公告列表  

--{nTag,nIndex,nState}       nIndex:排序放置的位置   nState: 0.正在滚动 1.滚动完成正在播放收起动画
p.FontLists         = {};                               --全部正在滚动的公告  
p.TipFontSize       = 18;                               --字体大小
p.nShowCount        = 3;                                --同时能显示font的数量
p.nFontHeight       = p.TipFontSize*ScaleFactor;        --字体高度

p.nTimerLoopTime    = 1/10;                             --定时器循环时间
p.nTimerTag         = nil;

p.TAG_TXT           = 1;    --文本
p.TAG_ANIMATE       = 2;    --动画


-- tTips格式{nTip1,sColor1}
function p.ShowTipDlg(tTips)
    LogInfo("CommonScrollDlg.ShowTipDlg");
    
    local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonScrollDlg.ShowTipsDlg failed!");
		return 0;
	end
    
    table.insert(p.FontCacheLists,tTips);
    
    --p.CreateMsgUI(1);
    
    if(p.nTimerTag == nil) then
        p.nTimerTag	= _G.RegisterTimer(p.OnProcessTextTimer, p.nTimerLoopTime);
    end
    
end



--创建公告动画
function p.CreateMsgUI(nIndex)
    LogInfo("CommonScrollDlg.CreateMsgUI nIndex:[%d]",nIndex);
    
    --判断是否可添加
    if(#p.FontCacheLists==0) then
        LogInfo("#p.FontCacheLists == 0");
        return;
    end
    
    local tTip = p.FontCacheLists[1];
    
    local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonScrollDlg.ShowTipsDlg failed!");
		return 0;
	end
    
    local bSucess, nTag = CommonDlgNew.GenerateDlgId();
    if not bSucess then
        return 0;
    end
    
    local sTip = tTip[1];
    local sFontColor = tTip[2];
    
    if(sTip == nil) then
        LogInfo("sTip is nil!");
        sTip = "";
    end
    
    if(sFontColor == nil) then
        LogInfo("sFontColor is nil!");
        sFontColor = ItemColor[0];
    end
    
    --创建node
    local layer = createNDUINode();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag( nTag );
	scene:AddChild(layer);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("notice.ini", layer, nil, 0, 0);
    uiLoad:Free();
    
    
    --设置动画
    local animate = RecursivUISprite(layer,{p.TAG_ANIMATE});
    local szAniPath = NDPath_GetAnimationPath();
    animate:ChangeSprite(szAniPath.."scroll01.spr");
    
    
    --设置文本
    local label = GetLabel(layer,p.TAG_TXT);
    label:SetTextAlignment(UITextAlignment.LeftRCenter);
    label:SetOffsetXEnd();
    if(sFontColor) then
        label:SetFontColor(sFontColor);
    end
    label:SetText(sTip);
    
    
    --设置层的位置
    local rect = RectFullScreenUILayer;
    local ypos = animate:GetFrameRect().size.h * ( nIndex-1 );
	layer:SetFrameRect(CGRectMake(rect.origin.x,ypos,rect.size.w,rect.size.h));
    
    
    --插入动画队列
    local nState = 0;
    table.insert(p.FontLists,{nTag,nIndex,nState});
    
    --删除缓存队列
    table.remove(p.FontCacheLists,1);
end

--判断索引是否存在
function p.IsExistsIndex(nIndex)
    for i,v in ipairs(p.FontLists) do
        LogInfo("i:[%d],v[2]:[%d] == nIndex:[%d]",i,v[2],nIndex);
        if( v[2] == nIndex ) then
            return false;
        end
    end
    return true;
end

-----定时器回调-----
function p.OnProcessTextTimer(nTimeTag)
    LogInfo("CommonScrollDlg.OnProcessTextTimer");
    
    --插入到显示区
    for i=1,p.nShowCount do
        local bIsExists = p.IsExistsIndex(i);
        if( bIsExists and #p.FontCacheLists>0) then
            LogInfo("#p.FontCacheLists:[%d],i:[%d]", #p.FontCacheLists,i);
            
            --创建tip
            p.CreateMsgUI(i);
            return true;
        end
    end
    
    
    --运行文字滚动动画
    LogInfo("p.FontLists:[%d]",#p.FontLists);
    local scene = GetSMGameScene();
    for i,v in ipairs(p.FontLists) do
        
        local layer = GetUiNode(scene, v[1]);
        if( layer ) then
            
            --设置文本位置
            local label = GetLabel(layer, p.TAG_TXT);
            if( label ) then
                
                label:SetOffsetX(label:GetOffsetX()-5*ScaleFactor);
                
                LogInfo("label:GetOffsetX():[%d],label:GetTextSize().w:[%d]",label:GetOffsetX(),label:GetTextSize().w);
                
                
                if(label:GetOffsetX()<-label:GetTextSize().w) then
                    
                    --改变动画
                    local animate = RecursivUISprite(layer,{p.TAG_ANIMATE});
                    
                    if( animate and v[3] == 0) then
                        local szAniPath = NDPath_GetAnimationPath();
                        animate:ChangeSprite(szAniPath.."scroll02.spr");
                        v[3] = 1;
                    end
                    
                    if( v[3] == 1 and animate:IsAnimationComplete() ) then
                        LogInfo("p.OnProcessTextTimer animate:IsAnimationComplete!");
                        
                        --判断动画是否完成完成后就删除结点
                        table.remove(p.FontLists,i);
                        layer:RemoveFromParent(true);
                    end
                    
                    --[[
                    if( #p.FontLists == 0 and p.nTimerTag ) then
                        _G.UnRegisterTimer( p.nTimerTag );
                        p.nTimerTag = nil;
                    end
                    ]]
                end
            end
        else
            LogInfo("p.OnProcessTextTimer layer is nil!");
            table.remove(p.FontLists,i);
        end
                                           
    end
    
    
    if( #p.FontLists == 0 and p.nTimerTag ) then
        _G.UnRegisterTimer( p.nTimerTag );
        p.nTimerTag = nil;
    end
    
end
