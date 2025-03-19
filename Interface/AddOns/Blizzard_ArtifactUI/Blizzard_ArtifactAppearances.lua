ArtifactAppearancesMixin = {}

function ArtifactAppearancesMixin:OnLoad()
	self:RegisterEvent("ARTIFACT_UPDATE");

	self.appearanceSetPool = CreateFramePool("FRAME", self, "ArtifactAppearanceSetTemplate");
	self.appearanceSlotPool = CreateFramePool("BUTTON", self, "ArtifactAppearanceSlotTemplate");
end

function ArtifactAppearancesMixin:OnShow()
	self:Refresh();
	C_ArtifactUI:SetForgeCamera();
end

function ArtifactAppearancesMixin:OnHide()
	C_ArtifactUI.SetPreviewAppearance(nil);
end

function ArtifactAppearancesMixin:OnEvent(event, ...)
	if event == "ARTIFACT_UPDATE" then
		self:RefreshIfVisible();
	end
end

function ArtifactAppearancesMixin:OnNewItemEquipped()
	self:RefreshIfVisible();
end

function ArtifactAppearancesMixin:RefreshIfVisible()
	if self:IsVisible() then
		self:Refresh();
	end
end

function ArtifactAppearancesMixin:Refresh()
	self.appearanceSetPool:ReleaseAll();
	self.appearanceSlotPool:ReleaseAll();

	local lastUnlockedAppearances = self.currentUnlockedAppearances;
	self.currentUnlockedAppearances = {};

	self.activeAppearanceID = C_ArtifactUI.GetPreviewAppearance() or select(8, C_ArtifactUI.GetArtifactInfo());

	local prevAppearanceSet = nil;
	local scrollChildHeight = 0;
	for setIndex = 1, C_ArtifactUI.GetNumAppearanceSets() do
		local appearanceSet = self:SetupAppearanceSet(setIndex, prevAppearanceSet);
		if appearanceSet then
			prevAppearanceSet = appearanceSet;
		end
	end

	local MAX_LARGE_ENTRIES = 5;
	local useSmallSize = self.appearanceSetPool:GetNumActive() > MAX_LARGE_ENTRIES;

	for appearanceSet in self.appearanceSetPool:EnumerateActive() do
		appearanceSet:SetHeight(useSmallSize and 89 or 103);
	end

	self:ProcessAppearanceDeltas(lastUnlockedAppearances, self.currentUnlockedAppearances);
end

function ArtifactAppearancesMixin:ProcessAppearanceDeltas(lastUnlockedAppearances, currentUnlockedAppearances)
	if lastUnlockedAppearances then
		for appearanceID in pairs(currentUnlockedAppearances) do
			if not lastUnlockedAppearances[appearanceID] then
				PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_UNLOCK);
				break;
			end
		end
	end
end

function ArtifactAppearancesMixin:SetupAppearanceSet(setIndex, prevAppearanceSet)
	local setID, setName, setDescription, numAppearanceSlots = C_ArtifactUI.GetAppearanceSetInfo(setIndex);
	if setID and numAppearanceSlots > 0 then
		local appearanceSet;
		for appearanceIndex = 1, numAppearanceSlots do
			local appearanceID, appearanceName, displayIndex, appearanceUnlocked, unlockConditionText, uiCameraID, altHandUICameraID, swatchR, swatchG, swatchB, modelAlpha, modelDesaturation, appearanceObtainable = C_ArtifactUI.GetAppearanceInfo(setIndex, appearanceIndex);

			if appearanceID then
				if not appearanceSet then
					appearanceSet = self.appearanceSetPool:Acquire();
					appearanceSet.numAppearanceSlots = 0;

					appearanceSet.Name:SetText(setName);
					appearanceSet.DescriptionTooltipArea.tooltip = setDescription;

					if prevAppearanceSet then
						appearanceSet:SetPoint("TOPLEFT", prevAppearanceSet, "BOTTOMLEFT", 0, 0);
					else
						appearanceSet:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -80);
					end

					appearanceSet:Show();
				end

				self:AddAppearanceSlot(appearanceSet, appearanceID, swatchR, swatchG, swatchB, appearanceUnlocked, unlockConditionText, appearanceObtainable);
			end
		end

		return appearanceSet;
	end

	return nil;
end

do
	local STARTING_X_OFFSET = 0;
	local STARTING_Y_OFFSET = 0;
	local SLOT_PADDING = 12;

	function ArtifactAppearancesMixin:AddAppearanceSlot(appearanceSet, appearanceID, swatchR, swatchG, swatchB, appearanceUnlocked, unlockConditionText, appearanceObtainable)
		appearanceSet.numAppearanceSlots = appearanceSet.numAppearanceSlots + 1;

		local appearanceSlot = self.appearanceSlotPool:Acquire();

		local x = (appearanceSet.numAppearanceSlots - 1) * appearanceSlot:GetWidth() + SLOT_PADDING * appearanceSet.numAppearanceSlots;

		appearanceSlot:SetPoint("LEFT", appearanceSet.Name, "RIGHT", STARTING_X_OFFSET + x, STARTING_Y_OFFSET);

		local isActive = appearanceID == self.activeAppearanceID;

		appearanceSlot.SwatchTexture:SetVertexColor(swatchR, swatchG, swatchB, appearanceUnlocked and 1.0 or .5);

		appearanceSlot.unobtainable = not appearanceObtainable and not appearanceUnlocked;
		appearanceSlot.LockedIcon:SetShown(not appearanceUnlocked);
		appearanceSlot.UnobtainableCover:SetShown(appearanceSlot.unobtainable);
		appearanceSlot.Border:SetShown(appearanceUnlocked);
		appearanceSlot.Selected:SetShown(isActive);
		appearanceSlot.Selected:SetAlpha(appearanceUnlocked and 1.0 or .3);
		appearanceSlot.HighlightTexture:SetAlpha(isActive and 0.0 or 1.0);
		
		appearanceSlot.appearanceID = appearanceID;
		appearanceSlot.appearanceUnlocked = appearanceUnlocked;
		appearanceSlot.unlockConditionText = unlockConditionText;
		appearanceSlot.isActive = isActive;

		appearanceSlot:Show();
		appearanceSlot:SetEnabled(not appearanceSlot.unobtainable);

		if appearanceUnlocked then
			self.currentUnlockedAppearances[appearanceID] = true;
		end
	end
end

ArtifactAppearanceSlotMixin = {};

function ArtifactAppearanceSlotMixin:OnLoad()
	self:RegisterForClicks("LeftButtonDown");
end

function ArtifactAppearanceSlotMixin:OnClick(button)
	if button == "LeftButton" then
		if self.appearanceUnlocked then
			if not self.isActive then
				local activeAppearanceID = self:GetParent().activeAppearanceID;
				local currentAppearanceSetID = C_ArtifactUI.GetAppearanceInfoByID(activeAppearanceID);
				local newAppearanceSetID = C_ArtifactUI.GetAppearanceInfoByID(self.appearanceID);
				if currentAppearanceSetID == newAppearanceSetID then
					PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_COLOR_SELECT);
				else
					PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_CHANGE);
				end
				
				self:GetParent():GetParent():OnAppearanceChanging();
				C_ArtifactUI.SetPreviewAppearance(self.appearanceID);
				C_ArtifactUI.SetAppearance(self.appearanceID);
				
				self:GetParent():Refresh();
			end
		else
			if not self.isActive then
				C_ArtifactUI.SetPreviewAppearance(self.appearanceID);
				self:GetParent():Refresh();
			end
			PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_LOCKED);
		end
	end
end

function ArtifactAppearanceSlotMixin:OnEnter()
	if self.unobtainable then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
		GameTooltip:SetText(NO_LONGER_AVAILABLE, nil, nil, nil, nil, true);
		GameTooltip:Show();
	elseif self.unlockConditionText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
		GameTooltip:SetText(self.unlockConditionText, nil, nil, nil, nil, true);
		GameTooltip:Show();
	end
end