local AZERITE_GLOW_MODEL_SCENE_ID = 214; 

local AZERITE_GLOW_MODEL_ACTORS = 
{
	Precast =  { effectID = 1983524, name = "precast" }, 
	Absorb  =  { effectID = 2101311, name = "absorb" },
	Breathe =  { effectID = 1983552, name = "breathe" },
}

PartyPoseRewardsMixin = { }; 

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
	self.Glow.AnimFadeOut:Play();	
	self.Shine.AnimFadeOut:Play();
			
	self:Show();
	self.AnimFadeOut:Play();
	
	if (self:IsAzeriteCurrency()) then
		self.loopingSoundEmitter:StartLoopingSound();
		self:GetParent():PlayModelSceneAnimations();
		self:GetParent():AnchorModelScenesToRewards(self.Icon);
	end
end

function PartyPoseRewardsMixin:StopRewardAnimation()
	self.Glow.AnimFadeOut:Stop();	
	self.Shine.AnimFadeOut:Stop();
	self.AnimFadeOut:Stop();
end

function PartyPoseRewardsMixin:OnEnter()
	if (self.objectType == "item") then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetItemByID(self.id);
	elseif (self.objectType == "currency") then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetCurrencyByID(self.id, self.quantity);
	end
	
	GameTooltip:Show(); 
	CursorUpdate(self);
	
	self:StopRewardAnimation(); 
	self.Glow:SetAlpha(0); 
	self.Shine:SetAlpha(0); 
	
	if (self:IsAzeriteCurrency()) then 
		self.loopingSoundEmitter:CancelLoopingSound();
		self:GetParent():HideAzeriteGlowModelScenes();
	end	
	
	self:SetAlpha(1); 
	self:Show();
end

function PartyPoseRewardsMixin:OnAnimationFinished()
	if (self:IsAzeriteCurrency()) then 
		self:GetParent():HideAzeriteGlowModelScenes();
		self.loopingSoundEmitter:FinishLoopingSound();
	end	
	
	self:Hide(); 
	self:GetParent():PlayNextRewardAnimation(self);
end

function PartyPoseRewardsMixin:OnHide()
	self.loopingSoundEmitter:CancelLoopingSound();
end

function PartyPoseRewardsMixin:OnLeave()
	GameTooltip:Hide();
	ResetCursor();
	self:Hide();
	self:GetParent():PlayNextRewardAnimation(self); 
end

function PartyPoseRewardsMixin:OnLoad()
	local startingSound = SOUNDKIT.UI_80_ISLANDS_AZERITECOLLECTION_START;
	local loopingSound = SOUNDKIT.UI_80_ISLANDS_AZERITECOLLECTION_LOOP;
	local endingSound = SOUNDKIT.UI_80_ISLANDS_AZERITECOLLECTION_STOP;

	local loopStartDelay = 0;
	local loopEndDelay = 0;
	local loopFadeTime = 400; -- ms
	self.loopingSoundEmitter = CreateLoopingSoundEffectEmitter(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime);
end

PartyPoseMixin = { };

function PartyPoseMixin:AnchorModelScenesToRewards(relativeFrame)
	self.RewardAnimations.AzeriteGlow:ClearAllPoints();
	self.RewardAnimations.AzeriteGlow:SetPoint("CENTER", relativeFrame, "CENTER", -25, 45);
end

function PartyPoseMixin:UpdateAzeriteGlowModelActor(scene, fileID, name, forceUpdate)	
	local actor = scene:GetActorByTag(name);
	if (actor) then
		actor:SetModelByFileID(fileID);
	end
end

function PartyPoseMixin:HideAzeriteGlowModelScenes()
	self.RewardAnimations.AzeriteGlow:Hide();
end

function PartyPoseMixin:PlayNextRewardAnimation(rewardObj)
	local reward = self.rewardPool:GetNextActive(rewardObj); 
	
	if (reward) then 
		reward:PlayRewardAnimation(); 
	end
end

function PartyPoseMixin:AddReward(label, texture, count, quality, id, objectType, objectLink, quantity)
	local rewardFrame = self.rewardPool:Acquire();
	
	rewardFrame:SetPoint("BOTTOM", self, "BOTTOM", -15, 15);
	rewardFrame.Name:SetText(label);
	rewardFrame.Icon:SetTexture(texture);
	
	rewardFrame.id = id; 
	rewardFrame.objectType = objectType;
	rewardFrame.quantity = quantity;
	rewardFrame.objectLink = objectLink; 
	
	if (count > 1) then
		rewardFrame.Count:SetText(count);
		rewardFrame.Count:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		relativeFrame.Count:Show(); 
	else
		rewardFrame.Count:Hide();
	end

	rewardFrame:SetRewardsQuality(quality);
	
	return rewardFrame;
end

function PartyPoseMixin:GetFirstReward()
	return self.rewardPool:GetNextActive(); 
end

function PartyPoseMixin:SetRewards()	
	local name, typeID, subtypeID, iconTextureFile, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = GetLFGCompletionReward();
	if (not numRewards) then
		return; 
	end
	
	for i = 1, numRewards do
		local texture, quantity, isBonus, bonusQuantity, name, quality, id, objectType = GetLFGCompletionRewardItem(i);
		local originalQuanity = quantity;
		local objectLink =  GetLFGCompletionRewardItemLink(i);
		if (objectType == "currency") then 
			name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(id, quantity, name, texture, quality, originalQuantity); 
		end
		
		if (objectType == "currency" or objectType == "item") then
			local reward = self:AddReward(name, texture, quantity, quality, id, objectType, objectLink, originalQuanity);		
		else 
			local money = moneyBase + moneyVar * numStrangers;
			self:AddReward(GetMoneyString(money), "Interface\\Icons\\inv_misc_coin_01", nil, 1);
		end
	end
	
	local firstReward = self:GetFirstReward();
	if (firstReward) then
		firstReward:PlayRewardAnimation();
	end	
end

function PartyPoseMixin:PlayModelSceneAnimations(forceUpdate)
	local precast = AZERITE_GLOW_MODEL_ACTORS.Precast;
	local absorb = AZERITE_GLOW_MODEL_ACTORS.Absorb; 
	local breathe = AZERITE_GLOW_MODEL_ACTORS.Breathe;
	
	self.RewardAnimations.AzeriteGlow:Show();
	self.RewardAnimations.AzeriteGlow:SetFromModelSceneID(AZERITE_GLOW_MODEL_SCENE_ID, forceUpdate);
	
	self:UpdateAzeriteGlowModelActor(self.RewardAnimations.AzeriteGlow, precast.effectID, precast.name, forceUpdate); 
	self:UpdateAzeriteGlowModelActor(self.RewardAnimations.AzeriteGlow, absorb.effectID, absorb.name, forceUpdate); 
	self:UpdateAzeriteGlowModelActor(self.RewardAnimations.AzeriteGlow, breathe.effectID, breathe.name, forceUpdate); 
end

-- Moves the shadow to underneath the model actor in the model scene. 
function PartyPoseMixin:SetupShadow(actor)
	local shadowTexture = self.ModelScene.shadowPool:Acquire(); 
	local positionVector = CreateVector3D(actor:GetPosition())
	positionVector:ScaleBy(actor:GetScale());
	local x, y, depthScale = self.ModelScene:Transform3DPointTo2D(positionVector:GetXYZ()); 
	
	if (not x or not y or not depthScale) then 
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

function PartyPoseMixin:ApplyVisualKitToEachActor(visKit)
	for actor in self.ModelScene:EnumerateActiveActors() do
		actor:ApplySpellVisualKit(visKit, true);
	end
end

-- Creates the model scene and adds the actors from a particular ID. 
function PartyPoseMixin:SetModelScene(sceneID, partyCategory)
	self.ModelScene:SetFromModelSceneID(sceneID, true); 
	self.ModelScene.shadowPool:ReleaseAll();
	
	local numPartyMembers = GetNumGroupMembers(partyCategory) - 1;
	local playerActor = self.ModelScene:GetActorByTag("player");
	if (playerActor) then 
		if (playerActor:SetModelByUnit("player")) then 
			self:SetupShadow(playerActor); 
		end
	end
	
	for i=1, numPartyMembers do
		local partyActor = self.ModelScene:GetActorByTag("party"..i); 
		if (partyActor) then 
			partyActor:SetModelByUnit("party"..i)
			self:SetupShadow(partyActor);
		end
	end
	self.ModelScene:Show(); 
end

function PartyPoseMixin:OnLoad()
	self.ModelScene:EnableMouse(false);
	self.ModelScene:EnableMouseWheel(false);
	self.ModelScene.shadowPool = CreateTexturePool(self.ModelScene, "BORDER", 1, "PartyPoseModelShadowTextureTemplate");
	self.rewardPool = CreateFramePool("BUTTON", self, "PartyPoseRewardsButtonTemplate");
	self:RegisterEvent("LFG_COMPLETION_REWARD");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function PartyPoseMixin:OnEvent(event, ...)
	if (event == "UI_MODEL_SCENE_INFO_UPDATED") then
		self:SetModelScene(self.ModelScene:GetModelSceneID()); 
		self:PlayModelSceneAnimations(true);
	elseif ( event == "LFG_COMPLETION_REWARD" ) then
		self:SetRewards(); 
	end
end