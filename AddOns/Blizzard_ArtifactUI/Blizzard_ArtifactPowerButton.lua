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

function ArtifactPowerButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");

	local NUM_RUNE_TYPES = 11;
	local runeIndex = math.random(1, NUM_RUNE_TYPES);

	self.LightRune:SetAtlas(("Rune-%02d-light"):format(runeIndex), true);
end

function ArtifactPowerButtonMixin:OnEnter()
	if self.style ~= ARTIFACT_POWER_STYLE_RUNE and not self.locked then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetArtifactPowerByID(self:GetPowerID());

		self.UpdateTooltip = self.OnEnter;
	end
end

local SEQUENCE = { "LeftButton", "RightButton", "RightButton", "RightButton", "RightButton", "RightButton", "LeftButton", "RightButton", "RightButton", };
function ArtifactPowerButtonMixin:OnClick(button)
	if self.style ~= ARTIFACT_POWER_STYLE_RUNE and not self.locked then
		if button == "LeftButton" and C_ArtifactUI.AddPower(self:GetPowerID()) then
			self:PlayPurchaseAnimation();
		elseif self.isStart then
			local sequenceIndex = self.sequenceIndex or 1;
			if button == SEQUENCE[sequenceIndex] then
				self.sequenceIndex = sequenceIndex + 1;
				if self.sequenceIndex > #SEQUENCE then
					self:GetParent():PlayReveal();
					self.sequenceIndex = nil;
				end
			else
				self.sequenceIndex = nil;
			end
		end
	end
end

function ArtifactPowerButtonMixin:OnDragStart()
	if not self.locked and self.spellID and not IsPassiveSpell(self.spellID) then
		PickupSpell(self.spellID);
	end
end

function ArtifactPowerButtonMixin:PlayPurchaseAnimation()
	self.PowerUnlockedAnim:Stop();
	self.GoldPowerUnlockedAnim:Stop();
	self.PointSpentAnim:Stop();

	if self.isGoldMedal then
		self.PointBurstLeft:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.PointBurstRight:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.GoldPointSpentAnim:Play();
		PlaySound("UI_70_Artifact_Forge_Trait_GoldTrait");
	elseif not self.isStart then
		if self.currentRank + 1 == self.maxRank then
			self.RingGlow:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.PointBurstLeft:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.PointBurstRight:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
							
			self.FinalPointSpentAnim:Play();
			PlaySound("UI_70_Artifact_Forge_Trait_FinalRank");
		else
			self.RingGlow:SetVertexColor(0.30980392156863, 1, 0.2156862745098);
			self.PointBurstLeft:SetVertexColor(0.30980392156863, 1, 0.2156862745098);
			self.PointBurstRight:SetVertexColor(0.30980392156863, 1, 0.2156862745098);
			self.PointSpentAnim:Play();
			PlaySound("UI_70_Artifact_Forge_Trait_RankUp");
		end
	end
end

function ArtifactPowerButtonMixin:PlayUnlockAnimation()
	if self.isFinal then
		self.FinalPowerUnlockedAnim:Stop();
		self.FinalPowerUnlockedAnim:Play();
	elseif self.isGoldMedal then
		self.GoldPowerUnlockedAnim:Play();
	elseif not self.isStart then
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
	if self.isStart then
		self.Icon:SetSize(52, 52);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-MainProc", true);
		self.IconBorderDesaturated:SetAtlas("Artifacts-PerkRing-MainProc", true);
	elseif self.isGoldMedal then
		self.Icon:SetSize(50, 50);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-GoldMedal", true);
		self.IconBorderDesaturated:SetAtlas("Artifacts-PerkRing-GoldMedal", true);
	else
		self.Icon:SetSize(45, 45);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-Small", true);
		self.IconBorderDesaturated:SetAtlas("Artifacts-PerkRing-Small", true);
	end
end

function ArtifactPowerButtonMixin:SetStyle(style)
	self.style = style;
	self.Icon:SetAlpha(1);
	self.Icon:SetVertexColor(1, 1, 1);
	self.IconDesaturated:SetAlpha(1);
	self.IconDesaturated:SetVertexColor(1, 1, 1);
	
	self.IconBorder:SetAlpha(1);
	self.IconBorder:SetVertexColor(1, 1, 1);
	self.IconBorderDesaturated:SetAlpha(0);

	self.Rank:SetAlpha(1);
	self.RankBorder:SetAlpha(1);

	self.LightRune:Hide();

	if style == ARTIFACT_POWER_STYLE_RUNE then
		self.LightRune:Show();

		self.Icon:SetAlpha(0);
		self.IconBorder:SetAlpha(0);

		self.Rank:SetAlpha(0);
		self.RankBorder:SetAlpha(0);

		self.IconDesaturated:SetAlpha(0);
	elseif style == ARTIFACT_POWER_STYLE_MAXED then
		self.Rank:SetText(self.currentRank);
		self.Rank:SetTextColor(1, 0.82, 0);
		self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		self.RankBorder:Show();		
	elseif style == ARTIFACT_POWER_STYLE_CAN_UPGRADE then
		self.Rank:SetText(self.currentRank);
		self.Rank:SetTextColor(0.1, 1, 0.1);
		self.RankBorder:SetAtlas("Artifacts-PointsBoxGreen", true);
		self.RankBorder:Show();
	elseif style == ARTIFACT_POWER_STYLE_PURCHASED or style == ARTIFACT_POWER_STYLE_PURCHASED_READ_ONLY then
		self.Rank:SetText(self.currentRank);
		self.Rank:SetTextColor(1, 0.82, 0);
		self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		self.RankBorder:Show();
	elseif style == ARTIFACT_POWER_STYLE_UNPURCHASED then
		self.Icon:SetVertexColor(.6, .6, .6);
		self.IconBorder:SetVertexColor(.9, .9, .9);

		self.Rank:SetText(self.currentRank);
		self.Rank:SetTextColor(1, 0.82, 0);
		self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		self.RankBorder:Show();
	elseif style == ARTIFACT_POWER_STYLE_UNPURCHASED_READ_ONLY or style == ARTIFACT_POWER_STYLE_UNPURCHASED_LOCKED then
		if self.isGoldMedal or self.isStart then
			self.Icon:SetVertexColor(.4, .4, .4);
			self.IconBorder:SetVertexColor(.7, .7, .7);
			self.IconDesaturated:SetVertexColor(.4, .4, .4);
			self.RankBorder:Hide();
			self.Rank:SetText(nil);
			self.IconBorderDesaturated:SetAlpha(.5);
			self.Icon:SetAlpha(.5);
		else
			self.Icon:SetVertexColor(.15, .15, .15);
            self.IconBorder:SetVertexColor(.4, .4, .4);
            self.IconDesaturated:SetVertexColor(.15, .15, .15);
            self.RankBorder:Hide();
            self.Rank:SetText(nil);
			self.Icon:SetAlpha(.2);
		end
	end
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

function ArtifactPowerButtonMixin:IsStart()
	return self.isStart;
end

function ArtifactPowerButtonMixin:SetLocked(locked)
	self.locked = locked;
	if locked then
		if GameTooltip:SetOwner(self) then
			GameTooltip_Hide();
		end
	else
		if GetMouseFocus() == self then
			self:OnEnter();
		end
	end
end

function ArtifactPowerButtonMixin:CalculateDistanceTo(otherPowerButton)
	local cx, cy = self:GetCenter();
	local ocx, ocy = otherPowerButton:GetCenter();
	local dx, dy = ocx - cx, ocy - cy;
	return math.sqrt(dx * dx + dy * dy);
end

function ArtifactPowerButtonMixin:SetupButton(powerID, anchorRegion)
	local spellID, cost, currentRank, maxRank, bonusRanks, x, y, prereqsMet, isStart, isGoldMedal, isFinal = C_ArtifactUI.GetPowerInfo(powerID);
	self:ClearAllPoints();
	self:SetPoint("CENTER", anchorRegion, "TOPLEFT", x * anchorRegion:GetWidth(), -y * anchorRegion:GetHeight());

	local name, _, texture = GetSpellInfo(spellID);
	self.Icon:SetTexture(texture);
	self.IconDesaturated:SetTexture(texture);

	local totalPurchasedRanks = C_ArtifactUI.GetTotalPurchasedRanks();
	local wasJustUnlocked = prereqsMet and self.prereqsMet == false;
	local wasRespecced = self.currentRank and currentRank < self.currentRank;
	local wasBonusRankJustIncreased = self.bonusRanks and bonusRanks > self.bonusRanks;

	if wasRespecced then
		self:StopAllAnimations();
	end

	self.powerID = powerID;
	self.spellID = spellID;
	self.currentRank = currentRank;
	self.bonusRanks = bonusRanks;
	self.maxRank = maxRank;
	self.isStart = isStart;
	self.isGoldMedal = isGoldMedal;
	self.isFinal = isFinal;

	local isAtForge = C_ArtifactUI.IsAtForge();
	local isViewedArtifactEquipped = C_ArtifactUI.IsViewedArtifactEquipped();

	self.isCompletelyPurchased = currentRank == maxRank or self.isStart;
	self.hasSpentAny = currentRank > bonusRanks;
	self.couldSpendPoints = C_ArtifactUI.GetPointsRemaining() >= cost and isAtForge and isViewedArtifactEquipped;
	self.isMaxRank = currentRank == maxRank;
	self.prereqsMet = prereqsMet;
	self.wasBonusRankJustIncreased = wasBonusRankJustIncreased;
	self.cost = cost;

	self:UpdatePowerType();

	self:EvaluateStyle();

	if totalPurchasedRanks == 0 and prereqsMet and not self.isStart and isAtForge then
		self.FirstPointWaitingAnimation:Play();
	else
		self.FirstPointWaitingAnimation:Stop();
	end

	if totalPurchasedRanks > 1 and wasJustUnlocked then
		self:PlayUnlockAnimation();
	end
end

function ArtifactPowerButtonMixin:ShouldBeVisible()
	return not self.isFinal or self.prereqsMet;
end

function ArtifactPowerButtonMixin:EvaluateStyle()
	if C_ArtifactUI.GetTotalPurchasedRanks() == 0 and not self.prereqsMet then
		self:SetStyle(ARTIFACT_POWER_STYLE_RUNE);	
	elseif C_ArtifactUI.IsAtForge() and C_ArtifactUI.IsViewedArtifactEquipped() then
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
		if C_ArtifactUI.GetTotalPurchasedRanks() == 0 then
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

	self.isCompletelyPurchased = nil;
	self.hasSpentAny = nil;
	self.couldSpendPoints = nil;
	self.isMaxRank = nil;
	self.prereqsMet = nil;
	self.wasBonusRankJustIncreased = nil;

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
end