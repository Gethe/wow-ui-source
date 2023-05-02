PartyPoseRewardsMixin = { };

local IMPACT_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(214, 1983536);	-- 8FX_AZERITE_GENERIC_IMPACTHIGH_CHEST
local HOLD_MODEL_SCENE_INFO	= StaticModelInfo.CreateModelSceneEntry(234, 1983980);		-- 8FX_AZERITE_EMPOWER_STATECHEST

function PartyPoseRewardsMixin:OnLoad()
	local startingSound = SOUNDKIT.UI_80_ISLANDS_AZERITECOLLECTION_START;
	local loopingSound = SOUNDKIT.UI_80_ISLANDS_AZERITECOLLECTION_LOOP;
	local endingSound = SOUNDKIT.UI_80_ISLANDS_AZERITECOLLECTION_STOP;

	local loopStartDelay = 0;
	local loopEndDelay = 0;
	local loopFadeTime = 400; -- ms
	self.loopingSoundEmitter = CreateLoopingSoundEffectEmitter(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime);
end

function PartyPoseRewardsMixin:OnEnter()
	if (self.objectType == "item") then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(self.objectLink);
	elseif (self.objectType == "currency") then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetCurrencyByID(self.id, self.originalQuantity);
	end

	GameTooltip:Show();
	CursorUpdate(self);

	self:PauseRewardAnimation();

	self.loopingSoundEmitter:CancelLoopingSound();
end

function PartyPoseRewardsMixin:OnLeave()
	GameTooltip:Hide();
	ResetCursor();

	self:ResumeRewardAnimation();
end

function PartyPoseRewardsMixin:OnHide()
	self.loopingSoundEmitter:CancelLoopingSound();

	self.AnimFade:Stop();
	self.AnimFade.FadeIn:SetFromAlpha(0);
	self.AnimFade.FadeOut:SetToAlpha(0);
end

function PartyPoseRewardsMixin:SetupReward(rewardData)
	self.Name:SetText(rewardData.name);
	self.Icon:SetTexture(rewardData.texture);

	self.id = rewardData.id;
	self.objectType = rewardData.objectType;
	self.quantity = rewardData.quantity;
	self.originalQuantity = rewardData.originalQuantity;
	self.objectLink = rewardData.objectLink;

	if (rewardData.quantity > 1) then
		self.Count:SetText(rewardData.quantity);
		self.Count:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.Count:Show();
	else
		self.Count:Hide();
	end

	self:SetRewardsQuality(rewardData.quality);
end

function PartyPoseRewardsMixin:IsAzeriteCurrency()
	return (self.objectType == "currency" and self.id == C_CurrencyInfo.GetAzeriteCurrencyID());
end

function PartyPoseRewardsMixin:SetRewardsQuality(quality)
	if (quality) then
		local atlasTexture = LOOT_BORDER_BY_QUALITY[quality];
		self.IconBorder:SetAtlas(atlasTexture, true);
		local color = ITEM_QUALITY_COLORS[quality];
		self.Name:SetVertexColor(color.r, color.g, color.b);
	else
		self.IconBorder:SetTexture([[Interface\Common\WhiteIconFrame]]);
		self.Name:SetVertexColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end

	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(self.id) then
		self.IconOverlay:SetAtlas([[AzeriteIconFrame]]);
		self.IconOverlay:Show();
	else
		self.IconOverlay:Hide();
	end
end

function PartyPoseRewardsMixin:PlayRewardAnimation()
	self.AnimFade:Play();

	if (self:IsAzeriteCurrency()) then
		self.loopingSoundEmitter:StartLoopingSound();
		C_Timer.After(2,
			function()
				self.loopingSoundEmitter:FinishLoopingSound();
			end
		);
	end
end

function PartyPoseRewardsMixin:PauseRewardAnimation()
	self.AnimFade.FadeIn:SetFromAlpha(1);
	self.AnimFade.FadeOut:SetToAlpha(1);
	self.AnimFade:Pause();
	self:GetParent():GetParent():PauseRewardAnimation();
end

function PartyPoseRewardsMixin:ResumeRewardAnimation()
	if self:GetParent():GetParent():CanResumeAnimation() then
		self.AnimFade.FadeIn:SetFromAlpha(0);
		self.AnimFade.FadeOut:SetToAlpha(0);
		self.AnimFade:Play();
		self:GetParent():GetParent():ResumeRewardAnimation();
	end
end

function PartyPoseRewardsMixin:OnAnimationFinished()
	self:PlayNextRewardAnimation();
end

function PartyPoseRewardsMixin:PlayNextRewardAnimation()
	self:GetParent():GetParent():PlayNextRewardAnimation();
end

function PartyPoseRewardsMixin:CheckForIndefinitePause()
	if not self:GetParent():GetParent():CanResumeAnimation() then
		self:PauseRewardAnimation();
		self.isPlayingRewards = false;
	end
end

PartyPoseMixin = { };

function PartyPoseMixin:HideAzeriteGlowModelScenes()
	self.RewardAnimations.ImpactModelScene:Hide();
	self.RewardAnimations.HoldModelScene:Hide();
end

function PartyPoseMixin:PlayNextRewardAnimation()
	local rewardData = table.remove(self.pendingRewardData, 1);

	local rewardFrame = self.RewardAnimations.RewardFrame;
	rewardFrame:Hide();
	if rewardData then
		rewardFrame:Show();
		rewardFrame:SetupReward(rewardData);
		rewardFrame:PlayRewardAnimation();
		if rewardFrame:IsAzeriteCurrency() then
			self:PlayModelSceneAnimations();
		else
			self:HideAzeriteGlowModelScenes();
		end
	end
end

function PartyPoseMixin:PauseRewardAnimation()
	if self.RewardAnimations.RewardFrame:IsAzeriteCurrency() then
		self.RewardAnimations.HoldModelScene.RewardModelAnim:Pause();
	end
end

function PartyPoseMixin:ResumeRewardAnimation()
	if self.RewardAnimations.RewardFrame:IsAzeriteCurrency() then
		self.RewardAnimations.HoldModelScene.RewardModelAnim:Play();
	end
end

function PartyPoseMixin:CanResumeAnimation()
	return self.pendingRewardData and #self.pendingRewardData > 0;
end

function PartyPoseMixin:AddReward(name, texture, quality, id, objectType, objectLink, quantity, originalQuantity, isCurrencyContainer)
	local rewardData = {
		name = name,
		texture = texture,
		quality = quality,
		id = id,
		objectType = objectType,
		objectLink = objectLink,
		quantity = quantity,
		originalQuantity = originalQuantity,
		isCurrencyContainer = isCurrencyContainer,
	};

	table.insert(self.pendingRewardData, rewardData);
end

function PartyPoseMixin:GetFirstReward()
	return self.rewardPool:GetNextActive();
end

function PartyPoseMixin:PlayModelSceneAnimations(forceUpdate)
	self.RewardAnimations.ImpactModelScene:Show();
	self.RewardAnimations.HoldModelScene:Show();

	local impactActor = StaticModelInfo.SetupModelScene(self.RewardAnimations.ImpactModelScene, IMPACT_MODEL_SCENE_INFO, forceUpdate);
	if (impactActor) then
		impactActor:SetAnimation(0, 0, 1, 0);
		C_Timer.After(.2, function() impactActor:SetAnimation(0, 0, 0, 0); end);
	end

	StaticModelInfo.SetupModelScene(self.RewardAnimations.HoldModelScene, HOLD_MODEL_SCENE_INFO, forceUpdate);

	self.RewardAnimations.HoldModelScene.RewardModelAnim:Play();
end

function PartyPoseMixin:UpdateShadow(actor)
	local shadowTexture = actor.shadowTexture;
	assert(shadowTexture);

	local positionVector = CreateVector3D(actor:GetPosition());
	positionVector:ScaleBy(actor:GetScale());
	local x, y, depthScale = self.ModelScene:Transform3DPointTo2D(positionVector:GetXYZ());

	if (not x or not y or not depthScale) then
		shadowTexture:Hide();
		return;
	end

	shadowTexture:ClearAllPoints();
	depthScale = Lerp(.05, 1, ClampedPercentageBetween(depthScale, .8, 1))
	-- Scales down the texture depending on it's depthScale.
	shadowTexture:SetScale(depthScale);

	-- Need to apply the effective scale to account for UI Scaling.
	local inverseScale = self.ModelScene:GetEffectiveScale() * depthScale;
	-- The position of the character can be found by the offset on the screen.
	shadowTexture:SetPoint("CENTER", self.ModelScene, "BOTTOMLEFT", (x / inverseScale) + 2, (y / inverseScale) - 4);
	shadowTexture:Show();
end

function PartyPoseMixin:SetupShadow(actor)
	self.onActorSizeChangedCallback = self.onActorSizeChangedCallback or function(actor)
		self:UpdateShadow(actor);
	end;

	actor:SetOnSizeChangedCallback(self.onActorSizeChangedCallback);
	actor.shadowTexture = self.ModelScene.shadowPool:Acquire();
	self:UpdateShadow(actor);
end

-- Creates the model scene and adds the actors from a particular ID.
function PartyPoseMixin:SetModelScene(sceneID, partyCategory, forceUpdate)
	self.ModelScene:SetFromModelSceneID(sceneID, forceUpdate);
	self.ModelScene.shadowPool:ReleaseAll();
	self.ModelScene.partyCategory = partyCategory;

	local playerActor = self.ModelScene:GetPlayerActor();
	if (playerActor) then
		if (playerActor:SetModelByUnit("player")) then
			self:SetupShadow(playerActor);
		end
	end

	local numPartyMembers = GetNumGroupMembers(partyCategory) - 1;
	for i=1, numPartyMembers do
		local partyActor = self.ModelScene:GetActorByTag("party"..i);
		if (partyActor) then
			if (partyActor:SetModelByUnit("party"..i)) then
				self:SetupShadow(partyActor);
			end
		end
	end
	self.ModelScene:Show();
end

function PartyPoseMixin:AddCreatureActor(displayID, name)
	local actor = self.ModelScene:GetActorByTag(name);
	if (actor) then
		if (actor:SetModelByCreatureDisplayID(displayID)) then
			self:SetupShadow(actor);
		end
	end
end

function PartyPoseMixin:AddModelSceneActors(actors)
	for scriptTag, displayID in pairs(actors) do
		self:AddCreatureActor(displayID, scriptTag);
	end
end

function PartyPoseMixin:PlaySounds()
	if (self.partyPoseData.playerWon) then
		PlaySound(self.partyPoseData.partyPoseInfo.victorySoundKitID);
	else
		PlaySound(self.partyPoseData.partyPoseInfo.defeatSoundKitID);
	end
end

do
	function PartyPoseMixin:SetupTheme()
		if self.OverlayElements.Topper then
			self.OverlayElements.Topper:SetPoint("BOTTOM", self.Border, "TOP", 0, self.partyPoseData.themeData.topperOffset);
			self.OverlayElements.Topper:SetAtlas(self.partyPoseData.themeData.Topper, true);
		end

		self.TitleBg:ClearAllPoints();
		self.TitleBg:SetPoint("CENTER", self.ModelScene, "TOP", 0, 25);
		self.TitleBg:SetAtlas(self.partyPoseData.themeData.TitleBG, true);
		self.TitleBg:SetDrawLayer("OVERLAY", 6);
		self.TitleText:SetDrawLayer("OVERLAY", 7);

		-- TODO: Potentially move this to theme data to avoid special case code like this.
		self.Border:ClearAllPoints();
		self.Border:SetPoint("TOPLEFT", self, "TOPLEFT", -(self.partyPoseData.themeData.borderPaddingX or 0), self.partyPoseData.themeData.borderPaddingY or 0);
		self.Border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", self.partyPoseData.themeData.borderPaddingX or 0, -(self.partyPoseData.themeData.borderPaddingY or 0));

		NineSliceUtil.ApplyLayoutByName(self.Border, self.partyPoseData.themeData.nineSliceLayout, self.partyPoseData.themeData.nineSliceTextureKit);
	end

	local function WidgetsLayout(widgetContainerFrame, sortedWidgets)
		local widgetsHeight = 0;
		local maxWidgetWidth = 1;

		for index, widgetFrame in ipairs(sortedWidgets) do
			if ( index == 1 ) then
				widgetFrame:SetPoint("TOP", widgetContainerFrame, "TOP", 0, 0);
				widgetsHeight = widgetsHeight + widgetFrame:GetWidgetHeight();
			else
				local relative = sortedWidgets[index - 1];
				widgetFrame:SetPoint("TOP", relative, "BOTTOM", 0, 5);
				widgetsHeight = widgetsHeight + widgetFrame:GetWidgetHeight() - 5;
			end

			local widgetWidth = widgetFrame:GetWidgetWidth();
			if widgetWidth > maxWidgetWidth then
				maxWidgetWidth = widgetWidth;
			end
		end

		widgetContainerFrame:SetHeight(math.max(widgetsHeight, 1));
		widgetContainerFrame:SetWidth(maxWidgetWidth);
	end

	function PartyPoseMixin:LoadPartyPose(partyPoseData, forceUpdate)
		self.partyPoseData = partyPoseData;

		if self.Score then
			self.Score:RegisterForWidgetSet(partyPoseData.partyPoseInfo.widgetSetID, WidgetsLayout);
		end
		local partyPoseText = partyPoseData.partyPoseInfo.titleText;
		partyPoseText = (partyPoseText and partyPoseText ~= "") and partyPoseText or nil; 

		if (partyPoseData.playerWon) then
			self.TitleText:SetText(partyPoseText or PARTY_POSE_VICTORY);
			self:SetModelScene(partyPoseData.partyPoseInfo.victoryModelSceneID, partyPoseData.themeData.partyCategory, forceUpdate);
		else
			self.TitleText:SetText(partyPoseText or PARTY_POSE_DEFEAT);
			self:SetModelScene(partyPoseData.partyPoseInfo.defeatModelSceneID, partyPoseData.themeData.partyCategory, forceUpdate);
		end

		self.ModelScene.Bg:SetAtlas(partyPoseData.modelSceneData.ModelSceneBG);

		if partyPoseData.modelSceneData.addModelSceneActors then
			self:AddModelSceneActors(partyPoseData.modelSceneData.addModelSceneActors);
		end

		self:SetupTheme();
		self:SetLeaveButtonText();
		self:PlaySounds();
	end
end

function PartyPoseMixin:GetPartyPoseData(mapID, winner)
	local playerFactionGroup = UnitFactionGroup("player");
	local partyPoseData = {};
	partyPoseData.partyPoseInfo = C_PartyPose.GetPartyPoseInfoByMapID(mapID);
	--winner is a faction string for warfronts & islands.. Otherwise it is a boolean. 
	partyPoseData.playerWon = (type(winner) == "string") and (PLAYER_FACTION_GROUP[winner] == playerFactionGroup) or winner;
	return partyPoseData;
end

function PartyPoseMixin:GetPartyPoseDataFromPartyPoseID(partyPoseID, winner)
	local playerFactionGroup = UnitFactionGroup("player");
	local partyPoseData = {};
	partyPoseData.partyPoseInfo = C_PartyPose.GetPartyPoseInfoByID(partyPoseID)
	--winner is a faction string for warfronts & islands.. Otherwise it is a boolean. 
	partyPoseData.playerWon = (type(winner) == "string") and (PLAYER_FACTION_GROUP[winner] == playerFactionGroup) or winner;
	return partyPoseData;
end

function PartyPoseMixin:LoadScreen(mapID, winner)
	self:LoadPartyPose(self:GetPartyPoseData(mapID, winner));
end

function PartyPoseMixin:LoadScreenByPartyPoseID(partyPoseID, winner)
	self:LoadPartyPose(self:GetPartyPoseDataFromPartyPoseID(partyPoseID, winner));
end

function PartyPoseMixin:ReloadPartyPose()
	if self.partyPoseData then
		local forceUpdate = true;
		self:LoadPartyPose(self.partyPoseData, forceUpdate);
		self:PlayModelSceneAnimations(forceUpdate);
	end
end

function PartyPoseMixin:OnLoad()
	UIPanelWindows[self:GetName()] = { area = "center", pushable = 0, whileDead = 1, ignoreControlLost = true, checkFit = 1, yOffset = -100 };
	self.ModelScene.shadowPool = CreateTexturePool(self.ModelScene, "BORDER", 1, "PartyPoseModelShadowTextureTemplate");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");
end

function PartyPoseMixin:OnEvent(event, ...)
	if (event == "UI_MODEL_SCENE_INFO_UPDATED") then
		self:ReloadPartyPose();
	elseif ( event == "PLAYER_LEAVING_WORLD" ) then
		HideUIPanel(self);
	end
end
