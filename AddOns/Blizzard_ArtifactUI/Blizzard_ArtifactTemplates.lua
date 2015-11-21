------------------------------------------------------------------
--   ArtifactPowerButtonTemplate
------------------------------------------------------------------

ArtifactPowerButtonMixin = {};

ARTIFACT_POWER_STYLE_MAXED = 1;
ARTIFACT_POWER_STYLE_CAN_UPGRADE = 2;
ARTIFACT_POWER_STYLE_PURCHASED = 3;
ARTIFACT_POWER_STYLE_UNPURCHASED = 4;

ARTIFACT_POWER_STYLE_PURCHASED_READ_ONLY = 5;
ARTIFACT_POWER_STYLE_UNPURCHASED_READ_ONLY = 6;

function ArtifactPowerButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp");
end

function ArtifactPowerButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetArtifactPowerByID(self:GetPowerID());

	self.UpdateTooltip = self.OnEnter;
end

function ArtifactPowerButtonMixin:OnClick()
	if C_ArtifactUI.AddPower(self:GetPowerID()) then
		self:PlayPurchaseAnimation();
	end
end

function ArtifactPowerButtonMixin:PlayPurchaseAnimation()
	self.PowerUnlockedAnim:Stop();
	self.GoldPowerUnlockedAnim:Stop();

	if self.isGoldMedal then
		self.PointBurstLeft:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.PointBurstRight:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.GoldPointSpentAnim:Play();
	elseif not self.isStart then
		if self.currentRank + 1 == self.maxRank then
			self.RingGlow:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.PointBurstLeft:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
			self.PointBurstRight:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
							
			self.PointSpentAnim:Stop();
			self.FinalPointSpentAnim:Play();
		else
			self.RingGlow:SetVertexColor(0.30980392156863, 1, 0.2156862745098);
			self.PointBurstLeft:SetVertexColor(0.30980392156863, 1, 0.2156862745098);
			self.PointBurstRight:SetVertexColor(0.30980392156863, 1, 0.2156862745098);
			self.PointSpentAnim:Play();
		end
	end
end

function ArtifactPowerButtonMixin:PlayUnlockAnimation()
	if self.isGoldMedal == "gold" then
		self.GoldPowerUnlockedAnim:Play();
	elseif not self.isStart then
		self.RingGlow:SetVertexColor(1, 0.81960784313725, 0.3921568627451);
		self.PowerUnlockedAnim:Play();
	end
end

function ArtifactPowerButtonMixin:UpdatePowerType()
	if self.isStart then
		self.Icon:SetSize(52, 52);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-MainProc", true);
	elseif self.isGoldMedal then
		self.Icon:SetSize(50, 50);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-GoldMedal", true);
	else
		self.Icon:SetSize(45, 45);
		self.IconBorder:SetAtlas("Artifacts-PerkRing-Small", true);
	end
end

function ArtifactPowerButtonMixin:SetStyle(style)
	local desaturated = false;
	self.Icon:SetVertexColor(1, 1, 1);
	self.IconDesaturated:SetVertexColor(1, 1, 1);
	
	self.IconBorder:SetVertexColor(1, 1, 1);
	if style == ARTIFACT_POWER_STYLE_MAXED then
		self.Rank:SetText(self.currentRank);
		self.Rank:SetTextColor(1, 0.82, 0);
		self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		self.RankBorder:Show();		
	elseif style == ARTIFACT_POWER_STYLE_CAN_UPGRADE then
		self.Rank:SetText(self.currentRank);
		self.Rank:SetTextColor(0.1, 1, 0.1);
		self.RankBorder:SetAtlas("Artifacts-PointsBoxGreen", true);
		self.RankBorder:Show();		
	elseif style == ARTIFACT_POWER_STYLE_PURCHASED then
		self.Rank:SetText(self.currentRank);
		self.Rank:SetTextColor(1, 0.82, 0);
		self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		self.RankBorder:Show();
	elseif style == ARTIFACT_POWER_STYLE_PURCHASED_READ_ONLY then
		self.Rank:SetText(self.currentRank);
		self.Rank:SetTextColor(1, 0.82, 0);
		self.RankBorder:SetAtlas("Artifacts-PointsBox", true);
		self.RankBorder:Show();
	elseif style == ARTIFACT_POWER_STYLE_UNPURCHASED_READ_ONLY or style == ARTIFACT_POWER_STYLE_UNPURCHASED then
		self.Icon:SetVertexColor(.25, .25, .25);
		self.IconBorder:SetVertexColor(.25, .25, .25);
		self.IconDesaturated:SetVertexColor(.25, .25, .25);
		self.RankBorder:Hide();
		self.Rank:SetText(nil);
		desaturated = true;
	end

	self.Icon:SetAlpha(desaturated and 0.0 or 1.0);

	self.IconBorder:SetDesaturated(desaturated);
end

function ArtifactPowerButtonMixin:ApplyRelicType(relicType, relicItemID, suppressAnimation)
	if relicType then
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

		if self.relicItemID ~= relicItemID and not suppressAnimation then
			self.RelicAppliedAnim:Play();
		end
	else
		self.RelicTraitBG:Hide();
		self.RelicTraitGlow:Hide();
		self.RelicTraitGlowRing:Hide();
	end
	self.relicItemID = relicItemID;
end

local HIGHLIGHT_ALPHA = 1.0;
local NO_HIGHLIGHT_ALPHA = .8;
function ArtifactPowerButtonMixin:SetRelicHighlightEnabled(enabled)
	self.RelicTraitGlow:SetShown(enabled);
	self.RelicTraitGlowRing:SetShown(enabled);
	self.RelicTraitBG:SetAlpha(enabled and HIGHLIGHT_ALPHA or NO_HIGHLIGHT_ALPHA);
end

function ArtifactPowerButtonMixin:GetPowerID()
	return self.powerID;
end

function ArtifactPowerButtonMixin:SetupButton(powerID, anchorRegion)
	local spellID, cost, currentRank, maxRank, bonusRanks, x, y, prereqsMet, isStart, isGoldMedal = C_ArtifactUI.GetPowerInfo(powerID);
	self:ClearAllPoints();
	self:SetPoint("CENTER", anchorRegion, "TOPLEFT", x * anchorRegion:GetWidth(), -y * anchorRegion:GetHeight());

	local name, _, texture = GetSpellInfo(spellID);
	self.Icon:SetTexture(texture);
	self.IconDesaturated:SetTexture(texture);

	local wasJustUnlocked = prereqsMet and self.prereqsMet == false;
	local wasRespecced = self.currentRank and currentRank < self.currentRank;

	if wasRespecced then
		self:StopAllAnimations();
	end
	
	self.powerID = powerID;
	self.spellID = spellID;
	self.currentRank = currentRank;
	self.maxRank = maxRank;
	self.isStart = isStart;
	self.isGoldMedal = isGoldMedal;

	local isAtForge = C_ArtifactUI.IsAtForge();
	local isAtPointCap = C_ArtifactUI.GetTotalPurchasedRanks() >= C_ArtifactUI.GetMaxPurchasedRanks();

	self.isCompletelyPurchased = currentRank == maxRank or self.isStart;
	self.hasSpentAny = currentRank > bonusRanks;
	self.couldSpendPoints = C_ArtifactUI.GetPointsRemaining() >= cost and isAtForge and not isAtPointCap;
	self.isMaxRank = currentRank == maxRank;
	self.prereqsMet = prereqsMet;

	self:UpdatePowerType();

	if isAtForge and self.prereqsMet then
		if self.isMaxRank then
			self:SetStyle(ARTIFACT_POWER_STYLE_MAXED);			
		elseif C_ArtifactUI.GetPointsRemaining() >= cost and not isAtPointCap then
			self:SetStyle(ARTIFACT_POWER_STYLE_CAN_UPGRADE);
		elseif self.currentRank > 0 then
			self:SetStyle(ARTIFACT_POWER_STYLE_PURCHASED);
		else
			self:SetStyle(ARTIFACT_POWER_STYLE_UNPURCHASED);
		end
	else
		if C_ArtifactUI.IsPowerKnown(powerID) then
			self:SetStyle(ARTIFACT_POWER_STYLE_PURCHASED_READ_ONLY);
		else
			self:SetStyle(ARTIFACT_POWER_STYLE_UNPURCHASED_READ_ONLY);
		end
	end

	if wasJustUnlocked then
		self:PlayUnlockAnimation();
	end

	self.RelicTraitBG:Hide();
	self.RelicTraitGlow:Hide();
	self.RelicTraitGlowRing:Hide();
end

function ArtifactPowerButtonMixin:ClearOldData()
	self.powerID = nil;
	self.spellID = nil;
	self.currentRank = nil;
	self.maxRank = nil;
	self.isStart = nil;
	self.isGoldMedal = nil;

	self.isCompletelyPurchased = nil;
	self.hasSpentAny = nil;
	self.couldSpendPoints = nil;
	self.isMaxRank = nil;
	self.prereqsMet = nil;

	self.relicItemID = nil;

	self:StopAllAnimations();
end

function ArtifactPowerButtonMixin:StopAllAnimations()
	self.GoldPowerUnlockedAnim:Stop();
	self.PowerUnlockedAnim:Stop();
	self.FinalPointSpentAnim:Stop();
	self.PointSpentAnim:Stop();
	self.GoldPointSpentAnim:Stop();
	self.RelicAppliedAnim:Stop();
end