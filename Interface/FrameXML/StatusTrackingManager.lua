StatusTrackingManagerMixin = { };

function StatusTrackingManagerMixin:SetTextLocked(isLocked)
	if ( self.textLocked ~= isLocked ) then
		self.textLocked = isLocked;
		self:UpdateBarVisibility();
	end
end

function StatusTrackingManagerMixin:IsTextLocked()
	return self.textLocked;
end

function StatusTrackingManagerMixin:UpdateBarVisibility()
	for i, bar in ipairs(self.bars) do
		if(bar:ShouldBeVisible()) then
			bar:UpdateTextVisibility();
		end
	end
end

function StatusTrackingManagerMixin:AddBarFromTemplate(frameType, template)
	local bar = CreateFrame(frameType, nil, self, template);
	table.insert(self.bars, bar);
	self:UpdateBarsShown();
end

function StatusTrackingManagerMixin:SetBarAnimation(Animation)
	for i, bar in ipairs(self.bars) do
		bar.StatusBar:SetDeferAnimationCallback(Animation);
	end
end

function StatusTrackingManagerMixin:UpdateBarTicks()
	for i, bar in ipairs(self.bars) do
		if(bar:ShouldBeVisible()) then
			bar:UpdateTick();
		end
	end
end

function StatusTrackingManagerMixin:ShowVisibleBarText()
	for i, bar in ipairs(self.bars) do
		if(bar:ShouldBeVisible()) then
			bar:ShowText();
		end
	end
end

function StatusTrackingManagerMixin:HideVisibleBarText()
	for i, bar in ipairs(self.bars) do
		if(bar:ShouldBeVisible()) then
			bar:HideText();
		end
	end
end

function StatusTrackingManagerMixin:UpdateBarsShown()
	local visibleBars = {};
	for i, bar in ipairs(self.bars) do
		if ( bar:ShouldBeVisible() ) then
			table.insert(visibleBars, bar);
		end
	end

	table.sort(visibleBars, function(left, right) return left:GetPriority() < right:GetPriority() end);
	self:LayoutBars(visibleBars);
end

function StatusTrackingManagerMixin:HideStatusBars()
	self.MainStatusTrackingBarContainer.shouldShow = false;
	self.MainStatusTrackingBarContainer:UpdateShownState();

	self.SecondaryStatusTrackingBarContainer.shouldShow = false;
	self.SecondaryStatusTrackingBarContainer:UpdateShownState();

	for i, bar in ipairs(self.bars) do
		bar:Hide();
	end
end

function StatusTrackingManagerMixin:LayoutBar(bar, isTopBar)
	bar:Update();
	bar:Show();

	local barContainer = isTopBar and self.SecondaryStatusTrackingBarContainer or self.MainStatusTrackingBarContainer;
	barContainer.shouldShow = true;
	barContainer:UpdateShownState();

	bar:ClearAllPoints();
	bar:SetPoint("BOTTOMLEFT", barContainer, "BOTTOMLEFT", 1, 5);

	local frameHeight = barContainer:GetHeight() - 6;
	local frameWidth = barContainer:GetWidth() - 6;
	bar.StatusBar:SetSize(frameWidth, frameHeight);
	bar:SetSize(frameWidth, frameHeight);
end

function StatusTrackingManagerMixin:LayoutBars(visBars)
	self:HideStatusBars();

	local TOP_BAR = true;
	if ( #visBars > 1 ) then
		self:LayoutBar(visBars[2], not TOP_BAR);
		self:LayoutBar(visBars[1], TOP_BAR);
	elseif( #visBars == 1 ) then
		self:LayoutBar(visBars[1], not TOP_BAR);
	end

	self:UpdateBarTicks();
end

function StatusTrackingManagerMixin:OnLoad()
	self.bars = {};

	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED");
	self:RegisterEvent("ENABLE_XP_GAIN");
	self:RegisterEvent("DISABLE_XP_GAIN");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("ARTIFACT_XP_UPDATE");
	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterUnitEvent("UNIT_LEVEL", "player")
	self:UpdateBarsShown();
end

function StatusTrackingManagerMixin:OnEvent(event, ...)
	if ( event == "CVAR_UPDATE" ) then
		self:UpdateBarVisibility();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		local initialLogin, reloadingUI = ...;
		if ( initialLogin or reloadingUI ) then
			self:AddBarFromTemplate("FRAME", "ReputationStatusBarTemplate");
			self:AddBarFromTemplate("FRAME", "HonorStatusBarTemplate");
			self:AddBarFromTemplate("FRAME", "ArtifactStatusBarTemplate");
			self:AddBarFromTemplate("FRAME", "ExpStatusBarTemplate");
			self:AddBarFromTemplate("FRAME", "AzeriteBarTemplate");
			UIParent_ManageFramePositions();
		end
	end
	self:UpdateBarsShown();
end

StatusTrackingBarContainerMixin = {};

function StatusTrackingBarContainerMixin:UpdateShownState()
	self:SetShown(self.shouldShow or self.isInEditMode);
end