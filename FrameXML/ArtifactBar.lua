ArtifactBarMixin = CreateFromMixins(StatusTrackingBarMixin);

function ArtifactBarMixin:GetPriority()
	return self.priority; 
end

function ArtifactBarMixin:ShouldBeVisible()
	return HasArtifactEquipped() and not C_ArtifactUI.IsEquippedArtifactMaxed() and not C_ArtifactUI.IsEquippedArtifactDisabled();
end

function ArtifactBarMixin:Update()
	local artifactItemID = C_ArtifactUI.GetEquippedArtifactItemID();
	if artifactItemID then
		local item = Item:CreateFromItemID(artifactItemID);
		item:ContinueOnItemLoad(function()
			local artifactItemID, _, _, _, artifactTotalXP, artifactPointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo();
			local numPointsAvailableToSpend, xp, xpForNextPoint = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(artifactPointsSpent, artifactTotalXP, artifactTier);

			self:SetBarValues(xp, 0, xpForNextPoint, numPointsAvailableToSpend + artifactPointsSpent);
	
			self.StatusBar.artifactItemID = artifactItemID;
			self.xp = xp;
			self.totalXP = artifactTotalXP;
			self.xpForNextPoint = xpForNextPoint;
			self.numPointsAvailableToSpend = numPointsAvailableToSpend;
			self:Show();
			self.Tick:SetShown(numPointsAvailableToSpend > 0);
			self.StatusBar.Underlay:SetShown(numPointsAvailableToSpend > 0);
			self.StatusBar.Overlay:Show();
			self.StatusBar.Overlay:SetAlpha(numPointsAvailableToSpend > 0 and .35 or .25);
			self:UpdateTick();
		end);
	end
end

function ArtifactBarMixin:UpdateOverlayFrameText()
	if ( self.OverlayFrame.Text:IsShown() ) then
		local xp = self.StatusBar:GetAnimatedValue();
		local _, xpForNextPoint = self.StatusBar:GetMinMaxValues();
		if ( xpForNextPoint > 0 ) then
			self.OverlayFrame.Text:SetFormattedText(ARTIFACT_POWER_BAR, BreakUpLargeNumbers(xp), BreakUpLargeNumbers(xpForNextPoint));
		end
	end
end

function ArtifactBarMixin:AnimatedValueChangedCallback()
	self:UpdateOverlayFrameText();
	self:UpdateTick();
end

function ArtifactBarMixin:OnLoad() 
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("ARTIFACT_XP_UPDATE");
	self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR");
	self:RegisterEvent("CVAR_UPDATE");
	self:SetBarColor(ARTIFACT_BAR_COLOR:GetRGB());
	self.priority = 4; 
	self.StatusBar:SetOnAnimatedValueChangedCallback(self:AnimatedValueChangedCallback());
end

function ArtifactBarMixin:OnEvent(event, ...)
	if( self:IsVisible() ) then 
		if ( event == "ARTIFACT_XP_UPDATE" or event == "UNIT_INVENTORY_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_EXTRA_ACTIONBAR") then
			self:Update();
		elseif ( event == "CVAR_UPDATE" ) then
			local name, value = ...;
			if ( name == "XP_BAR_TEXT" ) then
				self:UpdateTextVisibility();
			end
		end
	end
end

function ArtifactBarMixin:OnShow() 
	self:UpdateTextVisibility(); 
end

function ArtifactBarMixin:OnEnter()
	self:ShowText(); 
	self:UpdateOverlayFrameText();
	self.Tick:OnEnter();
end

function ArtifactBarMixin:OnLeave()
	self:HideText();
	self.Tick:OnLeave();
end

function ArtifactBarMixin:UpdateTick()
	self.Tick:UpdateTick();
end

function ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, artifactXP, artifactTier)
	local numPoints = 0;
	local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
	while artifactXP >= xpForNextPoint and xpForNextPoint > 0 do
		artifactXP = artifactXP - xpForNextPoint;

		pointsSpent = pointsSpent + 1;
		numPoints = numPoints + 1;

		xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
	end
	return numPoints, artifactXP, xpForNextPoint;
end

ArtifactTickMixin = { }
function ArtifactTickMixin:UpdateTick()
	if ( self:IsShown() ) then
		local xp = self:GetParent().xp;
		local xpForNextPoint = self:GetParent().xpForNextPoint;
		if ( xpForNextPoint > 0 ) then
			self:SetPoint("CENTER", self:GetParent(), "LEFT", (xp / xpForNextPoint) * self:GetParent():GetWidth(), 0);
		end
	end
end

function ArtifactTickMixin:OnEnter() 
	local arfifactTickParent = self:GetParent(); 
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
	GameTooltip:SetText(ARTIFACT_POWER_TOOLTIP_TITLE:format(BreakUpLargeNumbers(arfifactTickParent.totalXP, true), BreakUpLargeNumbers(arfifactTickParent.xp, true), BreakUpLargeNumbers(arfifactTickParent.xpForNextPoint, true)), HIGHLIGHT_FONT_COLOR:GetRGB());
	GameTooltip:AddLine(ARTIFACT_POWER_TOOLTIP_BODY:format(arfifactTickParent.numPointsAvailableToSpend), nil, nil, nil, true);
	GameTooltip:Show();
end

function ArtifactTickMixin:OnLeave()
	GameTooltip_Hide();
end