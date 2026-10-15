--[[
	The GamepadOverrideBarMixin holds the shared logic between all gamepad
	action bars that can override the standard gamepad action bars
	(possess bar, stance bar).

	Action bars that use the mixin should define these 2 keys before calling
	OnLoad (typically defined using key values in XML):

	[overrideCVar] - The name of the action bar override CVar that the action
					 bar override position is pulled from.
					 Ex: "GamepadPossessBarOverride"

	[overrideCVarChangedEvent] - The name of the event that is sent when the
								 value of the overrideCVar changes. A custom
								 event is needed so that we get both the new
								 value and the old value.
]]
GamepadOverrideBarMixin = CreateFromMixins(GamepadActionBarMixin);

function GamepadOverrideBarMixin:OnLoad()
	GamepadActionBarMixin.OnLoad(self);
	assert(self.overrideCVar, "Make sure to set an overrideCVar key value in XML.");
	assert(self.overrideCVarChangedEvent, "Make sure to set an overrideCVarChangedEvent key value in XML");
	self:RegisterEvent(self.overrideCVarChangedEvent); -- Listen for the override cvar changed event (custom to get both old and new values).

	self.overrideMap = {};
	self.isOverrideBarActive = false;
end

function GamepadOverrideBarMixin:OnEvent(event, ...)
	GamepadActionBarMixin.OnEvent(self, event, ...);

	if (event == self.overrideCVarChangedEvent) then
		self:OnOverrideCVarChanged(...);
	end
end

function GamepadOverrideBarMixin:OnOverrideCVarChanged(oldOverride, newOverride)
	if (not self.isOverrideBarActive) then
		self:UpdateOverrideBarPositioning();
		return;
	end

	local oldOverridePage = self:GetLinkedOverrideBarPage(oldOverride);
	local currentPage = self.pagingUnitOwner:GetCurrentPage();

	if (oldOverridePage == currentPage) then
		self:RevertOverrideBarModifications();
	end

	self:UpdateOverrideBarPositioning();

	local newOverridePage = self:GetLinkedOverrideBarPage(newOverride);
	if (newOverridePage == currentPage) then
		self:ApplyOverrideBarModifications();
	end
end

function GamepadOverrideBarMixin:UpdateOverrideBarPositioning()
	local overridePosition = self:GetOverrideCVarValue();
	local associatedAnchorFrame = self:GetLinkedOverrideBarAnchorFrame(overridePosition);
	self:ClearAllPoints();
	self:SetParent(associatedAnchorFrame);
	self:SetPoint("CENTER");
end

function GamepadOverrideBarMixin:GetActionBarLinkedWithOverrideBar()
	local parentAnchorFrame = self:GetParent();
	return parentAnchorFrame.Bar;
end

--Moving the anchors to the newBar and also changing to the parent to keep the scaling effect on the icon.
local function MoveIconToNewBar(icon, newBar)
	local point, _, relativePoint, offsetX, offsetY = icon:GetPoint();
	icon:ClearAllPoints();
	icon:SetPoint(point, newBar, relativePoint, offsetX, offsetY);
	icon:SetParent(newBar);
	newBar.modifierIcon = icon;
	newBar:ReinitializeSequences();
end

function GamepadOverrideBarMixin:ApplyOverrideBarModifications()
	local actionBarToOverride = self:GetActionBarLinkedWithOverrideBar();
	actionBarToOverride:Hide();

	-- Override bars may also be overridden
	if not self.pagingUnitOwner:IsAnyOverrideBarOverridingActionBar(self) then
		self:Show();
		self.pagingUnitOwner:ActionBarModKeyDownStateCheck();

		-- The modifier icon indicates which inputs are needed to focus the bar.
		if actionBarToOverride.modifierIcon then
			MoveIconToNewBar(actionBarToOverride.modifierIcon, self);
		end
	end
end

function GamepadOverrideBarMixin:RevertOverrideBarModifications()
	local overriddenActionBar = self:GetActionBarLinkedWithOverrideBar();
	--[[
		Forces the action bar linked with the override bar to be refreshed to the
		current CVar value allowing the visibility refresh function to take the
		currently overridden bar into account.
	]]
	self:UpdateOverrideBarPositioning();
	overriddenActionBar:RefreshActionBarVisibility();
	self:Hide();
	self.pagingUnitOwner:ActionBarModKeyDownStateCheck();

	local icon = overriddenActionBar.modifierIcon;
	if icon and icon:GetParent() == self then
		MoveIconToNewBar(overriddenActionBar.modifierIcon, overriddenActionBar);
	end
end

function GamepadOverrideBarMixin:SetOverrideMapping(overrideCVarVal, anchorFunc, pageNum)
	self.overrideMap[overrideCVarVal] = { anchor = anchorFunc, page = pageNum };
end

function GamepadOverrideBarMixin:GetLinkedOverrideBarAnchorFrame(overridePosition)
	local overrideValAsNum = tonumber(overridePosition);
	return self.overrideMap[overrideValAsNum].anchor(self.pagingUnitOwner);
end

function GamepadOverrideBarMixin:GetLinkedOverrideBarPage(overridePosition)
	local overrideValAsNum = tonumber(overridePosition);
	return self.overrideMap[overrideValAsNum].page;
end

function GamepadOverrideBarMixin:ApplyInitialOverridePositioning()
	local initialOverride = self:GetOverrideCVarValue();
	self:OnOverrideCVarChanged(initialOverride, initialOverride);
end

function GamepadOverrideBarMixin:GetOverrideCVarValue()
	return GetCVar(self.overrideCVar);
end

function GamepadOverrideBarMixin:IsOverrideBarActive()
	return self.isOverrideBarActive;
end

function GamepadOverrideBarMixin:RefreshActionBarVisibility()
	if not self.isOverrideBarActive then
		self:Hide();
		return;
	end

	local overrideBarIndex = self:GetOverrideCVarValue();
	local overrideBarPage = self:GetLinkedOverrideBarPage(overrideBarIndex);
	local currentPage = self.pagingUnitOwner:GetCurrentPage();
	if currentPage ~= overrideBarPage then
		self:Hide();
		return;
	end

	return GamepadActionBarMixin.RefreshActionBarVisibility(self);
end

function GamepadOverrideBarMixin:IsBarActivelyOverridingActionBar(actionBar)
	local overriddenActionBar = self:GetActionBarLinkedWithOverrideBar();
	local overrideBarIndex = self:GetOverrideCVarValue();
	local overrideBarPage = self:GetLinkedOverrideBarPage(overrideBarIndex);
	local currentPage = self.pagingUnitOwner:GetCurrentPage();
	return self.isOverrideBarActive and (overriddenActionBar == actionBar) and (currentPage == overrideBarPage);
end

function GamepadOverrideBarMixin:PageChangeHandler(oldPageNum)
	local currentPage = self.pagingUnitOwner:GetCurrentPage();
	local overrideBarIndex = self:GetOverrideCVarValue();
	local overrideBarPage = self:GetLinkedOverrideBarPage(overrideBarIndex);

	if (self.isOverrideBarActive) then
		if (oldPageNum == overrideBarPage) then
			self:RevertOverrideBarModifications();
		elseif (currentPage == overrideBarPage) then
			self:ApplyOverrideBarModifications();
		end
	end
end

function GamepadOverrideBarMixin:ActivateOverrideBar()
	self.isOverrideBarActive = true;

	local overrideBarIndex = self:GetOverrideCVarValue();
	local overrideBarPage = self:GetLinkedOverrideBarPage(overrideBarIndex);
	local currentPage = self.pagingUnitOwner:GetCurrentPage();

	if (overrideBarPage == currentPage) then
		self:ApplyOverrideBarModifications();
	end
end

function GamepadOverrideBarMixin:DeactivateOverrideBar()
	self.isOverrideBarActive = false;
	self:RevertOverrideBarModifications();
	self.pagingUnitOwner:RefreshPageTrackerSpecialPageSlotVisibility();
	self.pagingUnitOwner:HandleSpecialPageActiveStateChange();
end

--[[
	Calls ActivateOverrideBar or DeactivateOverrideBar on the override
	bar depending on the passed in value.

	activate - If true, ActivateOverrideBar will be called. Otherwise
			   DeactivateOverrideBar will be called.
]]
function GamepadOverrideBarMixin:ActivateOrDeactivateOverrideBar(activate)
	if (activate) then
		self:ActivateOverrideBar();
	else
		self:DeactivateOverrideBar();
	end
end
