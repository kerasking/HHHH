---------------------------------------------------
--描述: 直接在屏幕中心播放特效动画
--时间: 2012.7.22
--作者: Guosen
---------------------------------------------------
-- 播放特效动画接口
-- PlayEffectAnimation.ShowAnimation( nEffectAniOrdinal )
-- 参数：相应的动画ID，如下
-- 1,军衔提升
-- 2,等级提升
-- 3,坐骑升级
-- 4,升阶成功
-- 5,神铸成功
-- 6,招募成功
-- 7,开启战役

---------------------------------------------------

PlayEffectAnimation = {}
local p = PlayEffectAnimation;

---------------------------------------------------
--
local Z_ORDER_SHOWEFFECTLAYER		= NMAINSCENECHILDTAG.CommonDlgNew + 1;--5001;	-- 动画播放层的Z次序

---------------------------------------------------
-- ".spr"文件数组
-- 把要演示的精灵的".spr"文件名填加到该数组中即可
p.tSprFileArray		= {
	"junx03.spr",		-- 1,军衔提升
	"dengj03.spr",		-- 2,等级提升
	"zuoq03.spr",		-- 3,坐骑升级
	"shengj03.spr",		-- 4,升阶成功
	"shenz03.spr",		-- 5,神铸成功
	"zhaom03.spr",		-- 6,招募成功
	"zhany03.spr",		-- 7,开启战役
};


---------------------------------------------------
p.nTimerID			= nil;	-- 定时器编号
p.nEffectAniOrdinal	= nil;	-- 特效编号

---------------------------------------------------
function p.GetCurrentScene()
	--local pDirector = DefaultDirector();
	--if ( pDirector == nil ) then
	--	LogInfo( "PlayEffectAnimation: pDirector == nil" );
	--	return nil;
	--end
	--local pScene = pDirector:GetRunningScene();
	local pScene = GetSMGameScene();
	if ( pScene == nil ) then
		LogInfo( "PlayEffectAnimation: GetCurrentScene() pScene is nil" );
	end
	return pScene;
end

---------------------------------------------------
-- 获得动画所在层
function p.GetAniLayer()
    local pScene = p.GetCurrentScene();
    local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.EffectAniLayer );
    if not CheckP( pLayer ) then
        LogInfo( "PlayEffectAnimation: GetAniLayer() pLayer is nil" );
        return nil;
    end
    return pLayer;
end

---------------------------------------------------
--
function p.ShowAnimation( nEffectAniOrdinal )
	if ( nEffectAniOrdinal == nil ) or ( nEffectAniOrdinal < 1 ) or ( nEffectAniOrdinal > #p.tSprFileArray ) then
		return false;
	end
	--
	if ( p.nEffectAniOrdinal ~= nil ) then----
        LogInfo( "PlayEffectAnimation: PlayEffectAnimation() failed! p.nEffectAniOrdinal is exist" );
		return false;
	end
	
    local pScene = p.GetCurrentScene();
    if ( pScene == nil ) then
        LogInfo( "PlayEffectAnimation: PlayEffectAnimation() failed! pScene is nil" );
        return false;
    end
    local pLayer = p.GetAniLayer();
    if ( pLayer == nil ) then
    	pLayer = createNDUILayer();
    	if ( pLayer == nil ) then
        	LogInfo( "PlayEffectAnimation: PlayEffectAnimation() failed! pLayer is nil" );
    	    return false;
    	end
    	pLayer:Init();
    	pLayer:SetTag( NMAINSCENECHILDTAG.EffectAniLayer );
    	pScene:AddChildZ( pLayer, Z_ORDER_SHOWEFFECTLAYER );
    end
	
	-- 创建精灵NODE
	local tWinSize		= GetWinSize();
	local pSpriteNode	= createUISpriteNode();
	pSpriteNode:Init();
	pSpriteNode:SetFrameRect( CGRectMake(0, 0, tWinSize.w, tWinSize.h ) );
	local szAniPath		= NDPath_GetAnimationPath();
	local szSprFile		= p.tSprFileArray[nEffectAniOrdinal];
	pSpriteNode:ChangeSprite( szAniPath .. szSprFile );
	pLayer:AddChild( pSpriteNode );
    pSpriteNode:SetTag( nEffectAniOrdinal );
	p.nEffectAniOrdinal	= nEffectAniOrdinal;

	if ( p.nTimerID == nil ) then
		p.nTimerID = RegisterTimer( p.OnTimerCoutDownCounter, 1/24 );
	end
    return true;
end

---------------------------------------------------
--获取界面层
function p.OnTimerCoutDownCounter( nTimerID )
    local pLayer = p.GetAniLayer();
    if ( pLayer == nil ) then
        LogInfo( "PlayEffectAnimation: OnTimerCoutDownCounter()  pLayer is nil" );
		UnRegisterTimer( nTimerID );
    	p.nEffectAniOrdinal	= nil;
		p.nTimerID	= nil;
		return;
    end
    local pSpriteNode = ConverToSprite( GetUiNode( pLayer, p.nEffectAniOrdinal ) );
    if ( pSpriteNode == nil ) then
        LogInfo( "PlayEffectAnimation: OnTimerCoutDownCounter()  pSpriteNode is nil" );
    	pLayer:RemoveFromParent( true );
		UnRegisterTimer( nTimerID );
    	p.nEffectAniOrdinal	= nil;
		p.nTimerID			= nil;
		return;
    end
    if ( pSpriteNode:IsAnimationComplete() ) then
        LogInfo( "PlayEffectAnimation: OnTimerCoutDownCounter()  IsAnimationComplete" );
    	pSpriteNode:RemoveFromParent( true );
    	pLayer:GetParent():RemoveChild( pLayer, true );
		UnRegisterTimer( nTimerID );
    	p.nEffectAniOrdinal	= nil;
		p.nTimerID			= nil;
    end
end