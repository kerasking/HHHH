---------------------------------------------------
--描述: 通用对话框
--时间: 2013.1.22
--作者: chh
---------------------------------------------------

---------------------------------说明----------------------------
---带有  “纯文本提示动画” 功能
--function CommonScrollDlg.ShowTipDlg(tTips);

CommonScrollDlg = {};
local p = CommonScrollDlg;


local TAG_TXT           = 1;    --遮罩层
local TAG_ANIMATE       = 2;    --动画
local TAG_SCROLL_TXT	= 113;	--滚动文字
local nShowCount    = 3;                                --同时能显示font的数量
local nTimerLoopTime= 1/10;                             --定时器循环时间

p.FontCacheLists    = {};                               --全部缓存未显示公告列表  
p.FontLists			= {};								--全部正在滚动的公告

p.nTimerTag			= nil;



-- tTips格式{nTip1,sColor1}
function p.ShowTipDlg(tTips)
    LogInfo("CommonScrollDlg.ShowTipDlg");
    
    local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonScrollDlg.ShowTipsDlg failed!");
		return nil;
	end
    
    table.insert(p.FontCacheLists,tTips);
    
    if(p.nTimerTag == nil) then
        p.nTimerTag	= _G.RegisterTimer(p.OnProcessTextTimer, nTimerLoopTime);
    end
end

-----定时器回调-----
function p.OnProcessTextTimer(nTimeTag)
    LogInfo("CommonScrollDlg.OnProcessTextTimer");
    
    --插入到显示区
    for i=1,nShowCount do
        local bIsExists = p.IsExistsIndex(i);
        if( bIsExists and #p.FontCacheLists>0) then
            LogInfo("#p.FontCacheLists:[%d],i:[%d]", #p.FontCacheLists,i);
            
            --创建tip
            p.CreateMsgUI(i);
            return true;
        end
    end
    
    local scene = GetSMGameScene();
    for i,v in ipairs(p.FontLists) do
		local label = RecursiveLabel(scene,{v[1],TAG_TXT,TAG_SCROLL_TXT});
		if(label) then
			local rect = label:GetFrameRect();
			label:SetFrameRect(CGRectMake(rect.origin.x-5*CoordScaleX,rect.origin.y,rect.size.w,rect.size.h));
			LogInfo("v[3]:[%d]",v[3]);
			v[3] = v[3] - 1;
			
			--改变动画
            local animate = RecursivUISprite(scene,{v[1],TAG_ANIMATE});
			if(v[3]==0) then	--播放结束动画
				local szAniPath = NDPath_GetAnimationPath();
                animate:ChangeSprite(szAniPath.."scroll02.spr");
                animate:setExtra(1); --don't change "1"
			elseif(v[3] < 0 and animate:IsAnimationComplete()) then	--删除滚动条
				table.remove(p.FontLists,i);
				local layer = GetUiNode(scene, v[1]);
                layer:RemoveFromParent(true);
			end
		else
			table.remove(p.FontLists,i);
		end
    end
    
    if( #p.FontLists == 0 and p.nTimerTag ) then
        _G.UnRegisterTimer( p.nTimerTag );
        p.nTimerTag = nil;
    end
end    


--判断索引是否存在
function p.IsExistsIndex(nIndex)
	LogInfo("p.IsExistsIndex nIndex:[%d]",nIndex);
    for i,v in ipairs(p.FontLists) do
        if( v[2] == nIndex ) then
			LogInfo("IsExistsIndex false!");
            return false;
        end
    end
    return true;
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
    local layer = createNDUILayer();
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
    local animate = RecursivUISprite(layer,{TAG_ANIMATE});
    local szAniPath = NDPath_GetAnimationPath();
    animate:ChangeSprite(szAniPath.."scroll01.spr");
    animate:setExtra(1); --don't change "1"
    
    local winsize = GetWinSize(); 
    
    local svc = RecursiveScrollContainer(layer,{TAG_TXT});
    local rect = svc:GetFrameRect();
    local r = GetWinSize().w/960.0;
--    svc:SetFrameRect(CGRectMake(rect.origin.x+(rect.size.w-rect.size.w*r)/2,rect.origin.y,rect.size.w*r,rect.size.h));
    
--    rect = svc:GetFrameRect();
    
    LogInfo("chh:x:[%05f],y:[%05f],w:[%05f],h:[%05f]",rect.origin.x,rect.origin.y,rect.size.w,rect.size.h);
    
    LogInfo("txtlen:[%d]",string.len(sTip));
    local label = CreateLabel(sTip,CGRectMake(rect.size.w, 0, 14*CoordScaleX*string.len(sTip), rect.size.h),14,sFontColor);
    label:SetTextAlignment(UITextAlignment.Left);
    label:SetTag(TAG_SCROLL_TXT);
    svc:AddChild(label);
    
    --设置层的位置
    local rect = animate:GetFrameRect();
	layer:SetFrameRect(CGRectMake((winsize.w-rect.size.w)/2, 80*CoordScaleX+nIndex*rect.size.h, rect.size.w , rect.size.h));
    
    
    --插入动画队列
    LogInfo("rect.size.w:[%d],5*CoordScaleX:[%d],rect.size.w/5*CoordScaleX:[%d]",rect.size.w,5*CoordScaleX,rect.size.w/5*CoordScaleX);
    table.insert(p.FontLists,{nTag,nIndex,math.floor(rect.size.w/(5*CoordScaleX))+string.len(sTip)});
	
    --删除缓存队列
    table.remove(p.FontCacheLists,1);
end
