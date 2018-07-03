PartyPoseRewardsMixin = { };

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
		GameTooltip:SetItemByID(self.id);
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

	self.RewardAnimations.ImpactModelScene:SetFromModelSceneID(214, forceUpdate);
	local impactActor = self.RewardAnimations.ImpactModelScene:GetActorByTag("effect");
	if (impactActor) then
		impactActor:SetModelByFileID(1983536); -- 8FX_AZERITE_GENERIC_IMPACTHIGH_CHEST

		impactActor:SetAnimation(0, 0, 1, 0);
		C_Timer.After(.2, function() impactActor:SetAnimation(0, 0, 0, 0); end);
	end

	self.RewardAnimations.HoldModelScene:SetFromModelSceneID(234, forceUpdate);
	local holdActor = self.RewardAnimations.HoldModelScene:GetActorByTag("effect");
	if (holdActor) then
		holdActor:SetModelByFileID(1983980); -- 8FX_AZERITE_EMPOWER_STATECHEST
	end

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

	local playerActor = self.ModelScene:GetActorByTag("player");
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

function PartyPoseMixin:PlaySounds(partyPoseInfo, winnerFactionGroup) 
	local factionGroup = UnitFactionGroup("player"); 
	if (factionGroup == winnerFactionGroup) then
		PlaySound(partyPoseInfo.victorySoundKitID); 
	else 
		PlaySound(partyPoseInfo.defeatSoundKitID); 
	end
end

function PartyPoseMixin:SetupTheme(styleData)
	if self.Topper then
		self.Topper:SetPoint("BOTTOM", self.TopBorder, "TOP", 0, styleData.topperOffset);
		self.Topper:SetAtlas(styleData.Topper, true);

		if styleData.topperBehindFrame then
			self.Topper:SetDrawLayer("BACKGROUND", -7);
		else
			self.Topper:SetDrawLayer("ARTWORK", 2);
		end
	end

	self.TitleBg:SetAtlas(styleData.TitleBG, true);
	
	self.TitleText:SetDrawLayer("OVERLAY", 7);
	self.TitleBg:SetDrawLayer("OVERLAY", 6);
	
	self.TitleBg:ClearAllPoints();
	self.TitleBg:SetPoint("CENTER", self.ModelScene, "TOP", 0, 25);

	if self.ModelScene then
		self.ModelScene.Bg:SetAtlas(styleData.ModelSceneBG);
	end

	self.TopLeftCorner:SetAtlas(styleData.TopLeft, true);
	self.TopRightCorner:SetAtlas(styleData.TopRight, true);
	self.BotLeftCorner:SetAtlas(styleData.BottomLeft, true);
	self.BotRightCorner:SetAtlas(styleData.BottomRight, true);

	self.TopBorder:SetAtlas(styleData.Top, true);
	self.BottomBorder:SetAtlas(styleData.Bottom, true);
	self.LeftBorder:SetAtlas(styleData.Left, true);
	self.RightBorder:SetAtlas(styleData.Right, true);

	self.TopLeftCorner:SetTexCoord(0, 1, 0, 1);
	self.TopRightCorner:SetTexCoord(1, 0, 0, 1);
	self.BotLeftCorner:SetTexCoord(0, 1, 1, 0);
	self.BotRightCorner:SetTexCoord(1, 0, 1, 0);

	self.Background:ClearAllPoints();
	self.Background:SetPoint("TOPLEFT", self.TopLeftCorner, 4, -4);
	self.Background:SetPoint("BOTTOMRIGHT", self.BotRightCorner, -4, 4);

	local border = AnchorUtil.CreateNineSlice(self);
	border:SetTopLeftCorner(self.TopLeftCorner, -20, 20);
	border:SetTopRightCorner(self.TopRightCorner, 20, 20);
	border:SetBottomLeftCorner(self.BotLeftCorner, -20, styleData.bottomCornerYOffset);
	border:SetBottomRightCorner(self.BotRightCorner, 20, styleData.bottomCornerYOffset);
	border:SetTopEdge(self.TopBorder);
	border:SetLeftEdge(self.LeftBorder);
	border:SetRightEdge(self.RightBorder);
	border:SetBottomEdge(self.BottomBorder);
	border:Apply();
end

function PartyPoseMixin:OnLoad()
	UIPanelWindows[self:GetName()] = { area = "center", pushable = 0, whileDead = 1, ignoreControlLost = true, checkFit = 1 };
	self.ModelScene.shadowPool = CreateTexturePool(self.ModelScene, "BORDER", 1, "PartyPoseModelShadowTextureTemplate");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");
end

function PartyPoseMixin:OnEvent(event, ...)
	if (event == "UI_MODEL_SCENE_INFO_UPDATED") then
		local forceUpdate = true;
		self:SetModelScene(self.ModelScene:GetModelSceneID(), self.ModelScene.partyCategory, forceUpdate);
		self:PlayModelSceneAnimations(forceUpdate);
	elseif ( event == "PLAYER_LEAVING_WORLD" ) then
		HideUIPanel(self);
	end
end