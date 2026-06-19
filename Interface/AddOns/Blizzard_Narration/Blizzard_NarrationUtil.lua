-- Narration Utilities
--
-- Regions can define the following methods to customize their narration behavior:
--
--		NarrationGetName() -> string or nil
--			Returns the display name for the region. Falls back to GetText() if not defined.
--
--		NarrationGetContext() -> string or nil
--			Returns the control type and status string (e.g. "Button", "Check Button, Enabled").
--			Falls back to GetObjectType()-based lookup with automatic status from IsEnabled/GetChecked/etc.
--
--		NarrationGetDescription() -> string or nil
--			Returns an additional descriptive string read after name and context.
--
--		NarrationGetIndexInfo() -> { index = number, total = number } or nil
--			Returns positional information (e.g. "3 of 10") for items in a list.
--			Use NarrationUtil.MakeIndexInfo.
--
--		NarrationIgnoreCheckedState() -> boolean
--			Returns true if the checked/unchecked state should be omitted from the context narration,
--			typically for check buttons whose checked state represents selection rather than a
--			traditional on/off toggle.
--
--		NarrationNavigationShouldSkipTooltips() -> boolean
--			Returns true if tooltip narration should be suppressed when this region is focused,
--			typically because the region already includes the tooltip information in its own narration.
--
--		NarrationShouldIgnoreFocus() -> boolean
--			Returns true if standard narration should be suppressed when this region is focused,
--			typically because the region implements Narration functions but wants to narrate in
--			response to a manual trigger instead of directly on mouse over.
--
--		NarrationShouldIgnoreFocusReplay() -> boolean
--			Returns true if replay narration on refocusing (i.e. when clicked) should be suppressed
--			typically for a button that opens an element like the game menu button.
--
--		NarrationGetForwardedRegion() -> region
--			Returns another region that should be narrated instead of this one.
--			Resolved recursively. Use NarrationForwardToParentMixin for the common case
--			of forwarding to the parent frame.

local NARRATION_SCREEN_CONTEXT = {
	login = NARRATION_CONTEXT_LOGIN,
	realmlist = NARRATION_CONTEXT_REALM_LIST,
	charselect = NARRATION_CONTEXT_CHAR_SELECT,
	charcreate = NARRATION_CONTEXT_CHAR_CREATE,
};

local NARRATION_OBJECT_NAMES = {
	Button = NARRATION_OBJECT_BUTTON,
	CheckButton = NARRATION_OBJECT_CHECK_BUTTON,
	Slider = NARRATION_OBJECT_SLIDER,
};

local function GetRegionName(region)
	if region.NarrationGetName then
		return region:NarrationGetName();
	end

	if region.GetText then
		local text = region:GetText();
		if text and text ~= "" then
			return text;
		end
	end

	return nil;
end

local function GetRegionContext(region)
	if region.NarrationGetContext then
		return region:NarrationGetContext();
	end

	local objectType = region:GetObjectType();
	local objectName = NARRATION_OBJECT_NAMES[objectType];
	if not objectName then
		return nil;
	end

	if region.IsEnabled and not region:IsEnabled() then
		return string.format(NARRATION_STATUS_DISABLED_FORMAT, objectName);
	end

	if objectType == "CheckButton" and region.GetChecked then
		if not region.NarrationIgnoreCheckedState or not region:NarrationIgnoreCheckedState() then
			if region:GetChecked() then
				return string.format(NARRATION_STATUS_CHECKED_FORMAT, objectName);
			else
				return string.format(NARRATION_STATUS_UNCHECKED_FORMAT, objectName);
			end
		end
	end

	return objectName;
end

local function GetRegionDescription(region)
	if region.NarrationGetDescription then
		return region:NarrationGetDescription();
	end

	return nil;
end

local function GetRegionIndexInfo(region)
	if region.NarrationGetIndexInfo then
		return region:NarrationGetIndexInfo();
	end

	return nil;
end

NarrationUtil = {};

NarrationUtil.TriggerType = {
	Context = 1,
	Navigation = 2,
	Notification = 3,
	Tooltip = 4,

	-- Used when the region reports when it is focused instead of going through a usual narration source.
	ManualFocus = 5,
};

function NarrationUtil.ShouldBeEnabled()
	return CVarCallbackRegistry:GetCVarValueBool("accessibilityScreenNarrationEnabled") and C_Glue.IsOnGlueScreen();
end

function NarrationUtil.MakeIndexInfo(index, total)
	if not index or not total then
		return nil;
	end

	return { index = index, total = total };
end

function NarrationUtil.GetCheckboxContext(checkbox)
	if not checkbox:IsEnabled() then
		return NARRATION_STATUS_DISABLED_FORMAT:format(NARRATION_OBJECT_CHECKBOX);
	end

	if checkbox:GetChecked() then
		return NARRATION_STATUS_CHECKED_FORMAT:format(NARRATION_OBJECT_CHECKBOX);
	else
		return NARRATION_STATUS_UNCHECKED_FORMAT:format(NARRATION_OBJECT_CHECKBOX);
	end
end

function NarrationUtil.MakeNarrationString(...)
	local parts = {};
	for i = 1, select("#", ...) do
		local str = select(i, ...);
		if str and str ~= "" then
			table.insert(parts, str);
		end
	end

	if #parts == 0 then
		return nil;
	end

	return table.concat(parts, NARRATION_SEPARATOR);
end

function NarrationUtil.MakeNarrationStringForMoney(money)
	local gold = math.floor(money / COPPER_PER_GOLD);
	local silver = math.floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = money % COPPER_PER_SILVER;
	if gold > 0 then
		return NARRATION_FULL_MONEY_FORMAT:format(gold, silver, copper);
	elseif silver > 0 then
		return NARRATION_SILVER_MONEY_FORMAT:format(silver, copper);
	else
		return NARRATION_COPPER_MONEY_FORMAT:format(copper);
	end
end

function NarrationUtil.MakeNarrationStringFromIndexInfo(indexInfo)
	if not indexInfo or not indexInfo.index or not indexInfo.total then
		return nil;
	end

	if indexInfo.total <= 1 then
		return nil;
	end

	return NARRATION_INDEX_INFO_FORMAT:format(indexInfo.index, indexInfo.total);
end

function NarrationUtil.MakeNarrationStringFromInfo(narrationInfo)
	local indexString = NarrationUtil.MakeNarrationStringFromIndexInfo(narrationInfo.indexInfo);
	return NarrationUtil.MakeNarrationString(narrationInfo.name, narrationInfo.context, narrationInfo.description, indexString);
end

function NarrationUtil.CreateNarrationInfo(name, triggerType, context, description, indexInfo)
	return {
		name = name,
		triggerType = triggerType,
		context = context,
		description = description,
		indexInfo = indexInfo,
	};
end

function NarrationUtil.ShouldRegionNavigationSkipTooltips(region)
	if not region or not region.NarrationNavigationShouldSkipTooltips then
		return false;
	end

	return region:NarrationNavigationShouldSkipTooltips();
end

function NarrationUtil.ResolveForwardedRegion(region)
	while region and region.NarrationGetForwardedRegion do
		region = region:NarrationGetForwardedRegion();
	end

	return region;
end

function NarrationUtil.RegionToNarrationInfo(region, triggerType)
	if not region then
		return nil;
	end

	local name = GetRegionName(region);
	if not name then
		return nil;
	end

	local context = GetRegionContext(region);
	local description = GetRegionDescription(region);
	local indexInfo = GetRegionIndexInfo(region);
	return NarrationUtil.CreateNarrationInfo(name, triggerType, context, description, indexInfo);
end

function NarrationUtil.NarrateCurrentScreen(text)
	local narrationInfo = NarrationUtil.CreateNarrationInfo(text, NarrationUtil.TriggerType.Context);
	EventRegistry:TriggerEvent("Narration.Speak", narrationInfo);
end

-- Use if you have a child that should narrate as if it is its parent.
NarrationForwardToParentMixin = {};

function NarrationForwardToParentMixin:NarrationGetForwardedRegion()
	return self:GetParent();
end

-- Use for regions that should narrate a fixed name set via Key-Value or SetNarrationName.
NarrationStaticNameMixin = {};

function NarrationStaticNameMixin:SetNarrationName(name)
	self.narrationName = name;
end

function NarrationStaticNameMixin:NarrationGetName()
	return self.narrationName;
end

-- Convenience function to apply NarrationStaticNameMixin and set the name in one call.
function NarrationUtil.SetStaticName(region, name)
	Mixin(region, NarrationStaticNameMixin);
	region:SetNarrationName(name);
end

-- Use for regions that should narrate a fixed description set via SetNarrationDescription.
NarrationStaticDescriptionMixin = {};

function NarrationStaticDescriptionMixin:SetNarrationDescription(description)
	self.narrationDescription = description;
end

function NarrationStaticDescriptionMixin:NarrationGetDescription()
	return self.narrationDescription;
end

-- Convenience function to apply NarrationStaticDescriptionMixin and set the description in one call.
function NarrationUtil.SetStaticDescription(region, description)
	Mixin(region, NarrationStaticDescriptionMixin);
	region:SetNarrationDescription(description);
end

-- Use for regions whose tooltips should be skipped during narration navigation.
NarrationSkipTooltipsMixin = {};

function NarrationSkipTooltipsMixin:NarrationNavigationShouldSkipTooltips()
	return true;
end

-- Use for child regions that should forward only their NarrationGetName to their parent.
-- Use NarrationForwardToParentMixin for complete forwarding.
NarrationForwardNameToParentMixin = {};

function NarrationForwardNameToParentMixin:NarrationGetName()
	return self:GetParent():NarrationGetName();
end

-- Use for child regions that should forward only their NarrationGetDescription to their parent.
-- Use NarrationForwardToParentMixin for complete forwarding.
NarrationForwardDescriptionToParentMixin = {};

function NarrationForwardDescriptionToParentMixin:NarrationGetDescription()
	return self:GetParent():NarrationGetDescription();
end

EventRegistry:RegisterCallback("GlueParent.ScreenChanged", function(_callbackEvent, screen, _oldScreen)
	local text = NARRATION_SCREEN_CONTEXT[screen];
	if not text then
		return;
	end

	NarrationUtil.NarrateCurrentScreen(text);
end);
