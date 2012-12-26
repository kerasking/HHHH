---------------------------------------------------
--描述: 战斗活动层处理
--时间: 2012.11.1
--作者: chh
---------------------------------------------------

function HSBattleUILayer( bIsVisible )
    if( not CheckN(bIsVisible) ) then
        LogInfo("not CheckN(bIsVisible),HSBattleUILayer bIsVisible failed!");
        return;
    end
    if( bIsVisible == 0 ) then
        bIsVisible = false;
    else
        bIsVisible = true;
    end

    local scene = GetRunningScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load HiddenBattleUILayer failed!");
		return nil;
	end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    if( layer ) then
        layer:SetVisible( bIsVisible );
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    if( layer ) then
        layer:SetVisible( bIsVisible );
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DynMapGuide);
    if( layer ) then
        layer:SetVisible( bIsVisible );
    end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BattleBossUI);
    if( layer ) then
        layer:SetVisible( bIsVisible );
    end
    
end

function ProcessBattleUILayer()
    local scene = GetRunningScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load ProcessBattleUILayer failed!");
		return false;
	end
    
    local layerAffixNormalBoss = GetUiLayer(scene, NMAINSCENECHILDTAG.AffixNormalBoss);
    local layerArena = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
    local layerDynMapGuide = GetUiLayer(scene, NMAINSCENECHILDTAG.DynMapGuide);
    local layerBattleBossUI = GetUiLayer(scene, NMAINSCENECHILDTAG.BattleBossUI);
    
    if( layerAffixNormalBoss or layerArena or layerDynMapGuide or layerBattleBossUI) then
        return true;
    end
    return false;
end
