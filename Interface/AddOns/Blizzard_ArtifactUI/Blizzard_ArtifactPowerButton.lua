------------------------------------------------------------------
--   ArtifactPowerButtonTemplate
------------------------------------------------------------------

ArtifactPowerButtonMixin = {};

ARTIFACT_POWER_STYLE_RUNE = 1;
ARTIFACT_POWER_STYLE_MAXED = 2;
ARTIFACT_POWER_STYLE_CAN_UPGRADE = 3;
ARTIFACT_POWER_STYLE_PURCHASED = 4;
ARTIFACT_POWER_STYLE_UNPURCHASED = 5;
ARTIFACT_POWER_STYLE_UNPURCHASED_LOCKED = 6;

ARTIFACT_POWER_STYLE_PURCHASED_READ_ONLY = 7;
ARTIFACT_POWER_STYLE_UNPURCHASED_READ_ONLY = 8;

local ARTIFACT_TRAIT_SOUND_HANDLE;

local function PlayArtifactTraitSound(sound)
	if ARTIFACT_TRAIT_SOUND_HANDLE ~= nil then
		StopSound(ARTIFACT_TRAIT_SOUND_HANDLE);
		ARTIFACT_TRAIT_SOUND_HANDLE = nil;
	end
	
	local soundPlayed, handle = PlaySound(sound, "SFX");
	if soundPlayed then
		ARTIFACT_TRAIT_SOUND_HANDLE = handle;
	end
end

function ArtifactPowerButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	
	self.LightRune:SetAtlas(self:GenerateRune(), true);
end

function ArtifactPowerButtonMixin:GenerateRune()
	local NUM_RUNE_TYPES = 11;
	local runeIndex = math.random(1, NUM_RUNE_TYPES);
	return ("Rune-%02d-light"):format(runeIndex)
end

function ArtifactPowerButtonMixin:OnEnter()
	if self.style ~= ARTIFACT_POWER_STYLE_RUNE and not self.locked then
		local _, cursorItemID = GetCursorInfo();
		if cursorItemID and IsArtifactRelicItem(cursorItemID) then
			-- no tooltip
			return;
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetArtifactPowerByID(self:GetPowerID());

		self.UpdateTooltip = self.OnEnter;
	end
end

local SEQUENCE = { "LeftButton", "RightButton", "RightButton", "RightButton", "RightButton", "RightButton", "LeftButton", "RightButton", "RightButton", };
function ArtifactPowerButtonMixin:OnClick(button)
	if self.style ~= ARTIFACT_POWER_STYLE_RUNE and not self.locked then
		if ( IsModifiedClick("CHATLINK") ) then
			ChatEdit_InsertLink(C_ArtifactUI.GetPowerHyperlink(self:GetPowerID()));
			return;
		end
		if not C_ArtifactUI.IsArtifactDisabled() and not C_ArtifactUI.IsAtForge() then
			UIErrorsFrame:AddMessage(ARTIFACT_TRAITS_NO_FORGE_ERROR, RED_FONT_COLOR:GetRGBA());
			return;
		end
		if button == "LeftButton" and C_ArtifactUI.AddPower(self:GetPowerID()) then
			self:PlayPurchaseAnimation();
		elseif self.isStart then
			local sequenceIndex = self.sequenceIndex or 1;
			if button == SEQUENCE[sequenceIndex] then
				self.sequenceIndex = sequenceIndex + 1;
				if self.sequenceIndex > #SEQUENCE then
					self:GetParent():PlayReveal(1);
					self.sequenceIndex = nil;
				end
			else
				self.sequenceIndex = nil;
			end
		end
	end
end

function ArtifactPowerButtonMixin:OnDragStart()
end

function ArtifactPowerButtonMixin:PlayPurchaseAnimation()
	self.PowerUnlockedAnim:Stop();
	self.GoldPowerUnlockedAnim:Stop();
	self.PointSpentAnim:Stop();
	self.FinalPointSpentAnim:Stop();

	if self.isFinal and self.tier ~= 1 then
		-- Placeholder
		self.RingGlow:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.PointBurstLeft:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.PointBurstRight:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.FinalPointSpentAnim:Play();
		PlayArtifactTraitSound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TRAIT_GOLD_TRAIT);
	elseif self.isGoldMedal then
		self.PointBurstLeft:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.PointBurstRight:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.GoldPointSpentAnim:Play();
		if self.tier == 2 then
			PlayArtifactTraitSound(SOUNDKIT.UI_72_ARTIFACT_FORGE_FINAL_TRAIT_UNLOCKED);
		else
			PlayArtifactTraitSound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TRAIT_GOLD_TRAIT);
		end
	elseif self.isStart then
		if self.tier ~= 1 then
			self.RingGlow:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.PointBurstLeft:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.PointBurstRight:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.FinalPointSpentAnim:Play();
			PlayArtifactTraitSound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TRAIT_GOLD_TRAIT);
		end
	else
		if self.currentRank + 1 == self.maxRank then
			self.RingGlow:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.PointBurstLeft:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.PointBurstRight:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.FinalPointSpentAnim:Play();
			if ArtifactUI_HasPurchasedAnything() then
				PlayArtifactTraitSound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TRAIT_FINALRANK);
			end
		else
			self.RingGlow:SetVertexColor(0.30980392156863, 1, 0.2156862745098);
			self.PointBurstLeft:SetVertexColor(0.30980392156863, 1, 0.2156862745098);
			self.PointBurstRight:SetVertexColor(0.30980392156863, 1, 0.2156862745098);
			self.PointSpentAnim:Play();
			if ArtifactUI_HasPurchasedAnything() then
				PlayArtifactTraitSound(SOUNDKIT.UI_70_ARTIFACT_FORGE_TRAIT_RANKUP);
			end
		end
	end
end

function ArtifactPowerButtonMixin:PlayUnlockAnimation()
	if self.isFinal then
		self.FinalPowerUnlockedAnim:Stop();
		self.FinalPowerShownAnim:Stop();
		if self.prereqsMet then
			self.FinalPowerUnlockedAnim:Play();
		else
			self.FinalPowerShownAnim:Play();
		end
	elseif self.isGoldMedal then
		self.GoldPowerUnlockedAnim:Play();
	elseif not self.isStart or self.tier ~= 1 then
		self.RingGlow:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.PowerUnlockedAnim:Play();
	end
end

function ArtifactPowerButtonMixin:QueueRevealAnimation(delay)
	if not self.queuedRevealDelay or delay < self.queuedRevealDelay then
		self.queuedRevealDelay = delay;
		return true;
	end
	return false;
end

local function OnRevealAnimFinished(animGroup)
	if animGroup.onFinishedAnimation then
		animGroup.onFinishedAnimation(animGroup:GetParent());
	end
end

function ArtifactPowerButtonMixin:PlayRevealAnimation(onFinishedAnimation)
	if self.queuedRevealDelay then
		if self.hasSpentAny then
			self.queuedRevealDelay = nil;
			return false;
		end
		
		self:SetLocked(true);
		
		self.RevealAnim.Start:SetEndDelay(self.queuedRevealDelay);

		self.LightRune:Show();

		self.Icon:SetAlpha(0);
		self.IconBorder:SetAlpha(0);

		self.Rank:SetAlpha(0);
		self.RankBorder:SetAlpha(0);

		self.IconDesaturated:SetAlpha(0);
		self.IconBorderDesaturated:SetAlpha(0);

		self.RevealAnim:SetScript("OnFinished", OnRevealAnimFinished);
		self.RevealAnim.onFinishedAnimation = onFinishedAnimation;
		self.RevealAnim:Play();

		self.queuedRevealDelay = nil;

		return true;
	end
	return false;
end

function ArtifactPowerButtonMixin:UpdatePowerType()
	self:SetSize(37, 37);
	if self.isStart and self.tier == 1 then
		self.Icon:SetSize(52, 52);
		self.CircleMask:SetSize(52, 52);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-MainProc", true);
		self.IconBorderDesaturated:SetAtlas("Artifacts-PerkRing-MainProc", true);
	elseif self.isFinal and self.tier ~= 1 then
		self:SetSize(94, 94);
		self.Icon:SetSize(94, 94);
		self.CircleMask:SetSize(94, 94);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-Final", true);
		self.IconBorderDesaturated:SetAtlas("Artifacts-PerkRing-Final", true);
	elseif self.isGoldMedal then
		self.Icon:SetSize(50, 50);
		self.CircleMask:SetSize(50, 50);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-GoldMedal", true);
		self.IconBorderDesaturated:SetAtlas("Artifacts-PerkRing-GoldMedal", true);
	else
		self.Icon:SetSize(45, 45);
		self.CircleMask:SetSize(45, 45);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-Small", true);
		self.IconBorderDesaturated:SetAtlas("Artifacts-PerkRing-Small", true);
	end
end

function ArtifactPowerButtonMixin:SetStyle(style)
	local rankTextColor = CreateColor(0, 0, 0);
	local iconVertexColor = CreateColor(1, 1, 1);
	local iconAlpha = 1;
	local iconBorderAlpha = 1;
	local iconBorderDesaturatedAlpha = 0;

	self.style = style;
	self.IconDesaturated:SetAlpha(1);
	self.IconDesaturated:SetVertexColor(1, 1, 1);
	self.Rank:SetAlpha(1);
	self.RankBorder:SetAlpha(1);
	self.IconBorder:SetVertexColor(1, 1, 1);
	self.LightRune:Hide();

	local artifactDisabled = C_ArtifactUI.IsArtifactDisabled();

	if style == ARTIFACT_POWER_STYLE_RUNE then
		self.LightRune:Show();
		self.LightRune:SetDesaturated(artifactDisabled);

		iconAlpha = 0;
		iconBorderAlpha = 0;

		self.Rank:SetText(nil);
		self.Rank:SetAlpha(0);
		self.RankBorder:SetAlpha(0);

		self.IconDesaturated:SetAlpha(0);
	elseif style == ARTIFACT_POWER_STYLE_MAXED then
		self.Rank:SetText(self.currentRank);
		rankTextColor:SetRGB(1, 0.82, 0);
		self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		self.RankBorder:Show();		
	elseif style == ARTIFACT_POWER_STYLE_CAN_UPGRADE then
		self.Rank:SetText(self.currentRank);
		rankTextColor:SetRGB(0.1, 1, 0.1);
		if artifactDisabled then
			self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		else
			self.RankBorder:SetAtlas("Artifacts-PointsBoxGreen", true);
		end
		self.RankBorder:Show();
	elseif style == ARTIFACT_POWER_STYLE_PURCHASED or style == ARTIFACT_POWER_STYLE_PURCHASED_READ_ONLY then
		self.Rank:SetText(self.currentRank);
		rankTextColor:SetRGB(1, 0.82, 0);
		self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		self.RankBorder:Show();
	elseif style == ARTIFACT_POWER_STYLE_UNPURCHASED then
		self.IconBorder:SetVertexColor(.9, .9, .9);
		iconVertexColor:SetRGB(.6, .6, .6);

		self.Rank:SetText(self.currentRank);
		rankTextColor:SetRGB(1, 0.82, 0);
		self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		self.RankBorder:Show();
	elseif style == ARTIFACT_POWER_STYLE_UNPURCHASED_READ_ONLY or style == ARTIFACT_POWER_STYLE_UNPURCHASED_LOCKED then
		if self.isGoldMedal or self.isStart then
			iconVertexColor:SetRGB(.4, .4, .4);
			self.IconBorder:SetVertexColor(.7, .7, .7);
			self.IconDesaturated:SetVertexColor(.4, .4, .4);
			self.RankBorder:Hide();
			self.Rank:SetText(nil);
			iconBorderDesaturatedAlpha = 0.5;
			iconAlpha = .5;
		else
			iconVertexColor:SetRGB(.15, .15, .15);
            self.IconBorder:SetVertexColor(.4, .4, .4);
            self.IconDesaturated:SetVertexColor(.15, .15, .15);
            self.RankBorder:Hide();
            self.Rank:SetText(nil);
			iconAlpha = .2;
		end
	end

	if artifactDisabled then
		rankTextColor = DISABLED_FONT_COLOR;
		iconAlpha = 0;
		if style ~= ARTIFACT_POWER_STYLE_RUNE then
			iconBorderDesaturatedAlpha = 1;
		end
		self.IconBorder:Hide();
	else
		self.IconBorder:Show();
	end

	self.Rank:SetTextColor(rankTextColor:GetRGB());
	self.Icon:SetVertexColor(iconVertexColor:GetRGB());
	self.Icon:SetAlpha(iconAlpha);
	self.IconBorder:SetAlpha(iconBorderAlpha);
	self.IconBorderDesaturated:SetAlpha(iconBorderDesaturatedAlpha);
end

function ArtifactPowerButtonMixin:ApplyTemporaryRelicType(relicType, relicLink)
	if self.style ~= ARTIFACT_POWER_STYLE_RUNE and self.originalRelicType == nil and self.originalRelicLink == nil then
		self.originalRelicType = self.relicType or false;
		self.originalRelicLink = self.relicLink or false;
		self:ApplyRelicType(relicType, relicLink, true);
	end
end

function ArtifactPowerButtonMixin:RemoveTemporaryRelicType()
	if self.style ~= ARTIFACT_POWER_STYLE_RUNE and self.originalRelicType ~= nil and self.originalRelicLink ~= nil then
		self:ApplyRelicType(self.originalRelicType or nil, self.originalRelicLink or nil, true);

		self.originalRelicType = nil;
		self.originalRelicLink = nil;
	end
end

function ArtifactPowerButtonMixin:ApplyRelicType(relicType, relicLink, suppressAnimation)
	if self.style == ARTIFACT_POWER_STYLE_RUNE then
		-- Runes cannot have relics
		relicType = nil;
		relicLink = nil;
	end

	if self.style ~= ARTIFACT_POWER_STYLE_RUNE and relicType then
		local relicTraitBGAtlas = ("Relic-%s-TraitBG"):format(relicType);
		self.RelicTraitBG:SetAtlas(relicTraitBGAtlas);
		self.RelicTraitBG:Show();

		local relicTraitGlowAtlas = ("Relic-%s-TraitGlow"):format(relicType);
		self.RelicTraitGlow:SetAtlas(relicTraitGlowAtlas);
		self.RelicTraitBurst:SetAtlas(relicTraitGlowAtlas);

		local relicTraitGlowRingAtlas = ("Relic-%s-TraitGlowRing"):format(relicType);
		self.RelicTraitGlowRing:SetAtlas(relicTraitGlowRingAtlas);
		self.RelicRingBurstGlow:SetAtlas(relicTraitGlowRingAtlas);

		local isLarge = self.isStart or self.isGoldMedal;
		local traitSize = isLarge and 120 or 82;
		self.RelicTraitBG:SetSize(traitSize, traitSize);
		self.RelicTraitGlow:SetSize(traitSize, traitSize);
		self.RelicTraitBurst:SetSize(traitSize, traitSize);

		local ringSize = isLarge and 98 or 82;
		self.RelicTraitGlowRing:SetSize(ringSize, ringSize);
		self.RelicRingBurstGlow:SetSize(ringSize, ringSize);

		self:SetRelicHighlightEnabled(false);

		if self.wasBonusRankJustIncreased and not suppressAnimation then
			self.RelicAppliedAnim:Play();
		end
	else
		self.RelicTraitBG:Hide();
		self.RelicTraitGlow:Hide();
		self.RelicTraitGlowRing:Hide();
	end
	self.relicType = relicType;
	self.relicLink = relicLink;
end


function ArtifactPowerButtonMixin:RemoveRelicType()
	self.relicType = nil;
	self.relicLink = nil;
	self.originalRelicType = nil;
	self.originalRelicLink = nil;

	self.RelicTraitBG:Hide();
	self.RelicTraitGlow:Hide();
	self.RelicTraitGlowRing:Hide();
end

local HIGHLIGHT_ALPHA = 1.0;
local NO_HIGHLIGHT_ALPHA = .8;
function ArtifactPowerButtonMixin:SetRelicHighlightEnabled(enabled)
	if self.style ~= ARTIFACT_POWER_STYLE_RUNE then
		self.RelicTraitGlow:SetShown(enabled);
		self.RelicTraitGlowRing:SetShown(enabled);
		self.RelicTraitBG:SetAlpha(enabled and HIGHLIGHT_ALPHA or NO_HIGHLIGHT_ALPHA);
	end
end

function ArtifactPowerButtonMixin:GetPowerID()
	return self.powerID;
end

function ArtifactPowerButtonMixin:GetLinearIndex()
	return self.linearIndex;
end

function ArtifactPowerButtonMixin:GetTier()
	return self.tier;
end

function ArtifactPowerButtonMixin:IsStart()
	return self.isStart;
end

function ArtifactPowerButtonMixin:IsFinal()
	return self.isFinal;
end

function ArtifactPowerButtonMixin:IsGoldMedal()
	return self.isGoldMedal;
end

function ArtifactPowerButtonMixin:SetLinksEnabled(enabled)
	self.linksEnabled = enabled;
end

function ArtifactPowerButtonMixin:AreLinksEnabled()
	return self.linksEnabled;
end

function ArtifactPowerButtonMixin:HasBonusMaxRanksFromTier()
	return self.numMaxRankBonusFromTier > 0;
end

function ArtifactPowerButtonMixin:IsCompletelyPurchased()
	return self.isCompletelyPurchased;
end

function ArtifactPowerButtonMixin:HasSpentAny()
	return self.hasSpentAny;
end

function ArtifactPowerButtonMixin:ArePrereqsMet()
	return self.prereqsMet;
end

function ArtifactPowerButtonMixin:IsActiveForLinks()
	return self:IsCompletelyPurchased() or self:HasBonusMaxRanksFromTier();
end

function ArtifactPowerButtonMixin:CouldSpendPoints()
	return self.hasEnoughPower and self.prereqsMet and not self.isMaxRank;
end

function ArtifactPowerButtonMixin:GetCurrentRank()
	return self.currentRank;
end

function ArtifactPowerButtonMixin:IsMaxRank()
	return self.isMaxRank;
end

function ArtifactPowerButtonMixin:HasRanksFromCurrentTier()
	if self.tier == C_ArtifactUI.GetArtifactTier() then
		return self.currentRank > 0;
	else
		return self.currentRank > self.maxRank - self.numMaxRankBonusFromTier;
	end
end

function ArtifactPowerButtonMixin:SetLocked(locked)
	self.locked = locked;
	if locked then
		if GameTooltip:SetOwner(self) then
			GameTooltip_Hide();
		end
		
		self.FirstPointWaitingAnimation:Stop();
	else
		if GetMouseFocus() == self then
			self:OnEnter();
		end

		if self:ShouldGlow(C_ArtifactUI.GetTotalPurchasedRanks(), C_ArtifactUI.IsAtForge()) then
			self.FirstPointWaitingAnimation:Play();
		end
	end
end

function ArtifactPowerButtonMixin:UpdateIcon()
	if self.isFinal and self.tier == 2 then
		local finalAtlas = ("%s-FinalIcon"):format(self.textureKit);
		self.Icon:SetAtlas(finalAtlas, true);
		self.IconDesaturated:SetAtlas(finalAtlas, true);
	else
		local name, _, texture = GetSpellInfo(self.spellID);
		self.Icon:SetTexture(texture);
		self.IconDesaturated:SetTexture(texture);
	end
end

function ArtifactPowerButtonMixin:SetupButton(powerID, anchorRegion, textureKit)
	local powerInfo = C_ArtifactUI.GetPowerInfo(powerID);

	self:ClearAllPoints();
	local xOffset, yOffset = 0, 0;
	if powerInfo.offset then
		powerInfo.offset:ScaleBy(85);
		xOffset, yOffset = powerInfo.offset:GetXY();
	end
	self:SetPoint("CENTER", anchorRegion, "TOPLEFT", powerInfo.position.x * anchorRegion:GetWidth() + xOffset, -powerInfo.position.y * anchorRegion:GetHeight() - yOffset);

	local totalPurchasedRanks = C_ArtifactUI.GetTotalPurchasedRanks();
	local wasJustUnlocked = powerInfo.prereqsMet and self.prereqsMet == false;
	local wasRespecced = self.currentRank and powerInfo.currentRank < self.currentRank;
	local wasBonusRankJustIncreased = self.bonusRanks and powerInfo.bonusRanks > self.bonusRanks;

	if wasRespecced then
		self:StopAllAnimations();
	end

	self.powerID = powerID;
	self.spellID = powerInfo.spellID;
	self.currentRank = powerInfo.currentRank;
	self.bonusRanks = powerInfo.bonusRanks;
	self.maxRank = powerInfo.maxRank;
	self.isStart = powerInfo.isStart;
	self.isGoldMedal = powerInfo.isGoldMedal;
	self.isFinal = powerInfo.isFinal;
	self.tier = powerInfo.tier;
	self.textureKit = textureKit;
	self.linearIndex = powerInfo.linearIndex;
	self.numMaxRankBonusFromTier = powerInfo.numMaxRankBonusFromTier;

	local isAtForge = C_ArtifactUI.IsAtForge();
	local isViewedArtifactEquipped = C_ArtifactUI.IsViewedArtifactEquipped();

	self.isCompletelyPurchased = powerInfo.currentRank == powerInfo.maxRank or (self.tier == 1 and self.isStart);
	self.hasSpentAny = powerInfo.currentRank > powerInfo.bonusRanks;
	self.hasEnoughPower = C_ArtifactUI.GetPointsRemaining() >= powerInfo.cost and isAtForge and isViewedArtifactEquipped;
	self.isMaxRank = powerInfo.currentRank == powerInfo.maxRank;
	self.prereqsMet = powerInfo.prereqsMet;
	self.wasBonusRankJustIncreased = wasBonusRankJustIncreased;
	self.cost = powerInfo.cost;

	self:UpdatePowerType();

	self:EvaluateStyle();

	self:UpdateIcon();

	if self:ShouldGlow(totalPurchasedRanks, isAtForge) then
		self.FirstPointWaitingAnimation:Play();
	else
		self.FirstPointWaitingAnimation:Stop();
	end

	if totalPurchasedRanks > 1 and wasJustUnlocked then
		self:PlayUnlockAnimation();
	end
	
end

function ArtifactPowerButtonMixin:ShouldGlow(totalPurchasedRanks, isAtForge)
	if not isAtForge or not self.prereqsMet or C_ArtifactUI.IsArtifactDisabled() then
		return false;
	end
	
	if self.tier == 1 then
		return totalPurchasedRanks == 0 and not self.isStart;
	end
	
	return false;
end

function ArtifactPowerButtonMixin:EvaluateStyle()
	if not ArtifactUI_HasPurchasedAnything() and not self.prereqsMet then
		self:SetStyle(ARTIFACT_POWER_STYLE_RUNE);	
	elseif (C_ArtifactUI.IsAtForge() and C_ArtifactUI.IsViewedArtifactEquipped()) or C_ArtifactUI.IsArtifactDisabled() then
		if self.isMaxRank then
			self:SetStyle(ARTIFACT_POWER_STYLE_MAXED);			
		elseif self.prereqsMet and C_ArtifactUI.GetPointsRemaining() >= self.cost then
			self:SetStyle(ARTIFACT_POWER_STYLE_CAN_UPGRADE);
		elseif self.currentRank > 0 then
			self:SetStyle(ARTIFACT_POWER_STYLE_PURCHASED);
		elseif self.prereqsMet then
			self:SetStyle(ARTIFACT_POWER_STYLE_UNPURCHASED);
		else
			self:SetStyle(ARTIFACT_POWER_STYLE_UNPURCHASED_LOCKED);
		end
	else
		if not ArtifactUI_HasPurchasedAnything() and C_ArtifactUI.GetNumObtainedArtifacts() <= 1 then
			self:SetStyle(ARTIFACT_POWER_STYLE_RUNE);
		elseif C_ArtifactUI.IsPowerKnown(self.powerID) then
			self:SetStyle(ARTIFACT_POWER_STYLE_PURCHASED_READ_ONLY);
		else
			self:SetStyle(ARTIFACT_POWER_STYLE_UNPURCHASED_READ_ONLY);
		end
	end
end

function ArtifactPowerButtonMixin:ClearOldData()
	self.powerID = nil;
	self.spellID = nil;
	self.currentRank = nil;
	self.bonusRanks = nil;
	self.maxRank = nil;
	self.isStart = nil;
	self.isGoldMedal = nil;
	self.isFinal = nil;
	self.cost = nil;
	self.tier = nil;
	self.textureKit = nil;
	self.numMaxRankBonusFromTier = nil;

	self.isCompletelyPurchased = nil;
	self.hasSpentAny = nil;
	self.hasEnoughPower = nil;
	self.isMaxRank = nil;
	self.prereqsMet = nil;
	self.wasBonusRankJustIncreased = nil;
	self.linksEnabled = nil;

	self.relicType = nil;
	self.relicLink = nil;
	self.originalRelicType = nil;
	self.originalRelicLink = nil;

	self.locked = nil;

	self.queuedRevealDelay = nil;
	self.sequenceIndex = nil;

	self:StopAllAnimations();
end

function ArtifactPowerButtonMixin:StopAllAnimations()
	self.GoldPowerUnlockedAnim:Stop();
	self.PowerUnlockedAnim:Stop();
	self.FinalPointSpentAnim:Stop();
	self.PointSpentAnim:Stop();
	self.GoldPointSpentAnim:Stop();
	self.RelicAppliedAnim:Stop();
	self.RevealAnim:Stop();
	self.FinalPowerUnlockedAnim:Stop();
	self.FirstPointWaitingAnimation:Stop();
	self.Tier2FinalPowerSparks:Stop();
end