CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.INFO_DISPLAY_CVAR);

local PVP_CLASSIFICATION_ATLAS_ELEMENTS = {
	[Enum.PvPUnitClassification.FlagCarrierHorde] = "nameplates-icon-flag-horde",
	[Enum.PvPUnitClassification.FlagCarrierAlliance] = "nameplates-icon-flag-alliance",
	[Enum.PvPUnitClassification.FlagCarrierNeutral] = "nameplates-icon-flag-neutral",
	[Enum.PvPUnitClassification.CartRunnerHorde] = "nameplates-icon-cart-horde",
	[Enum.PvPUnitClassification.CartRunnerAlliance] = "nameplates-icon-cart-alliance",
	[Enum.PvPUnitClassification.AssassinHorde] = "nameplates-icon-bounty-horde",
	[Enum.PvPUnitClassification.AssassinAlliance] = "nameplates-icon-bounty-alliance",
	[Enum.PvPUnitClassification.OrbCarrierBlue] = "nameplates-icon-orb-blue",
	[Enum.PvPUnitClassification.OrbCarrierGreen] = "nameplates-icon-orb-green",
	[Enum.PvPUnitClassification.OrbCarrierOrange] = "nameplates-icon-orb-orange",
	[Enum.PvPUnitClassification.OrbCarrierPurple] = "nameplates-icon-orb-purple",
}

NamePlateClassificationFrameMixin = CreateFromMixins(NamePlateComponentMixin);

function NamePlateClassificationFrameMixin:OnLoad()
	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.INFO_DISPLAY_CVAR, self.OnInfoDisplayCVarChanged, self);

	self:UpdateShownState();
end

function NamePlateClassificationFrameMixin:OnEvent(event, ...)
	if event == "UNIT_CLASSIFICATION_CHANGED" then
		self:UpdateClassificationIndicator();
	end
end

function NamePlateClassificationFrameMixin:OnInfoDisplayCVarChanged()
	self:UpdateClassificationIndicator();
end

function NamePlateClassificationFrameMixin:SetOptions(optionTable)
	self.showPvPClassificationIndicator = optionTable.showPvPClassificationIndicator;
	self.showPvEClassificationIndicator = optionTable.showClassificationIndicator;
end

function NamePlateClassificationFrameMixin:SetUnit(unitToken)
	self.unitToken = unitToken;

	if self.unitToken ~= nil then
		self:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", self.unitToken);
	else
		self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
	end

	self:UpdatePvPClassificationEnabled();

	self:UpdateClassificationIndicator();
end

function NamePlateClassificationFrameMixin:UpdatePvPClassificationEnabled()
	self.enablePvPClassification = C_PvP.IsPVPMap();
end

function NamePlateClassificationFrameMixin:ShouldShowPvPClassificationIndicator()
	-- PvP classification is driven by auras that should only exist in battlegrounds, so avoid the
	-- call to UnitPvpClassification for all other situations.
	if self.enablePvPClassification ~= true then
		return false;
	end

	return self.showPvPClassificationIndicator;
end

function NamePlateClassificationFrameMixin:ShouldShowPvEClassificationIndicator()
	local showRarityIcon = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.INFO_DISPLAY_CVAR, Enum.NamePlateInfoDisplay.RarityIcon);
	if showRarityIcon == false then
		return false;
	end

	return self.showPvEClassificationIndicator;
end

function NamePlateClassificationFrameMixin:GetClassification()
	-- Allow special cases (e.g. the Options Preview Nameplate) to control the unit's classification.
	if self.explicitClassification ~= nil then
		return self.explicitClassification;
	end

	if self.unitToken ~= nil then
		return UnitClassification(self.unitToken);
	end

	return nil;
end

function NamePlateClassificationFrameMixin:GetClassificationAtlasElement()
	if self.unitToken == nil then
		return nil;
	end

	-- The classification frame is hidden when a raid icon is assigned to the unit.
	if self.raidTargetIndex ~= nil then
		return nil;
	end

	if self:IsWidgetsOnlyMode() then
		return nil;
	end

	if self:ShouldShowPvPClassificationIndicator() then
		local pvpClassification = UnitPvpClassification(self.unitToken);
		local classificationAtlasElement = PVP_CLASSIFICATION_ATLAS_ELEMENTS[pvpClassification];

		if classificationAtlasElement then
			return classificationAtlasElement;
		end
	end

	if self:ShouldShowPvEClassificationIndicator() then
		local classification = self:GetClassification();

		if classification == "elite" or classification == "worldboss" then
			return "nameplates-icon-elite-gold";
		elseif classification == "rare" then
			return "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Star";
		elseif classification == "rareelite" then
			return "nameplates-icon-elite-silver";
		end
	end

	return nil;
end

function NamePlateClassificationFrameMixin:UpdateClassificationIndicator()
	local classificationAtlasElement = self:GetClassificationAtlasElement();

	if self.classificationAtlasElement == classificationAtlasElement then
		return;
	end

	self.classificationAtlasElement = classificationAtlasElement;

	if self.classificationAtlasElement then
		self.classificationIndicator:SetAtlas(self.classificationAtlasElement);
	end

	self:UpdateShownState();
end

function NamePlateClassificationFrameMixin:ShouldBeShown()
	if self.classificationAtlasElement == nil then
		return false;
	end

	return true;
end

function NamePlateClassificationFrameMixin:UpdateShownState()
	self:UpdateClassificationIndicator();

	if self:ShouldBeShown() == true then
		self:Show();
	else
		self:Hide();
	end
end

function NamePlateClassificationFrameMixin:SetRaidTargetIndex(index)
	self.raidTargetIndex = index;

	self:UpdateClassificationIndicator();
end

function NamePlateClassificationFrameMixin:SetExplicitValues(explicitValues)
	self.explicitClassification = explicitValues.classification;

	self:UpdateClassificationIndicator();
end
