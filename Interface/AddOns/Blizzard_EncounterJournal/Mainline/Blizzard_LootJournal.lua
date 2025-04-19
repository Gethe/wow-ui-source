
-- LootJournal Shadowlands update: Resurrected from the great beyond for runeforge legendary powers.

local UNSPECIFIED_SPEC_FILTER = 0;
local UNSPECIFIED_CLASS_FILTER = 0;

local RuneforgePowerFilterOrder = {
	Enum.RuneforgePowerFilter.All,
	Enum.RuneforgePowerFilter.Available,
	Enum.RuneforgePowerFilter.Unavailable,
};


RuneforgeLegendaryPowerLootJournalMixin = CreateFromMixins(RuneforgePowerBaseMixin);

function RuneforgeLegendaryPowerLootJournalMixin:Init(elementData)
	self:SetPowerID(elementData.powerID);
end

function RuneforgeLegendaryPowerLootJournalMixin:OnClick()
	self:OnSelected();
end

function RuneforgeLegendaryPowerLootJournalMixin:OnPowerSet(oldPowerID, newPowerID)
	local powerInfo = self:GetPowerInfo();
	self.Icon:SetTexture(powerInfo.iconFileID);

	local isAvailable = powerInfo.state == Enum.RuneforgePowerState.Available;
	if isAvailable then
		self.Name:SetTextColor(LEGENDARY_ORANGE_COLOR:GetRGBA());
		self.Icon:SetDesaturation(powerInfo.matchesCovenant and 0 or 0.75);
	else
		self.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGBA());
		self.Icon:SetDesaturation(1);
	end

	self.UnavailableBackground:SetShown(not isAvailable);
	self.Name:SetText(powerInfo.name);

	local showUnavailableOverlay = not isAvailable or not powerInfo.matchesCovenant;
	self.UnavailableOverlay:SetShown(showUnavailableOverlay);
	self.BackgroundOverlay:SetAtlas(isAvailable and "ui-ej-memory-darkring" or "ui-ej-memory-disabledring", TextureKitConstants.UseAtlasSize);
	self.BackgroundOverlay:SetShown(showUnavailableOverlay);
	
	local alpha = isAvailable and 1.0 or 0.5;
	self.Icon:SetAlpha(alpha);
	self.Name:SetAlpha(alpha);
	self.SpecName:SetAlpha(alpha);

	local hasSpecName = powerInfo.specName ~= nil;
	
	local yOffset = not hasSpecName and 0 or ((self.Name:GetNumLines() == 2) and 7 or 8);
	self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 12, yOffset);

	self.SpecName:SetShown(hasSpecName);
	if hasSpecName then
		self.SpecName:SetText(powerInfo.specName);
	end
end

function RuneforgeLegendaryPowerLootJournalMixin:ShouldShowUnavailableError()
	return true;
end


LootJournalMixin = {};

local LootJournalEvents = {
	"NEW_RUNEFORGE_POWER_ADDED",
};

function LootJournalMixin:OnLoad()
	self:SetClassAndSpecFilters(RuneforgeUtil.GetPreviewClassAndSpec());

	local stride = 2;
	local view = CreateScrollBoxListGridView(stride);
	view:SetElementInitializer("RuneforgeLegendaryPowerLootJournalTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	view:SetPadding(0,0,0,0,20,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ClassDropdown:SetWidth(175);
	self.RuneforgePowerDropdown:SetWidth(130);
end

function LootJournalMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, LootJournalEvents);

	self:UpdatePowers();

	local pendingPowerID = self:GetPendingPowerID();
	if pendingPowerID then
		self:OpenToPowerID(pendingPowerID);
	end

	self:SetupClassDropdown();
	self:SetupRuneforgePowerDropdown();
end

function LootJournalMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, LootJournalEvents);
end

function LootJournalMixin:OnEvent(event, ...)
	if event == "NEW_RUNEFORGE_POWER_ADDED" then
	self:UpdatePowers();
end
end

function LootJournalMixin:SetupClassDropdown()
	local getClassFilter = GenerateClosure(self.GetClassFilter, self);
	local getSpecFilter = GenerateClosure(self.GetSpecFilter, self);
	local setClassAndSpecFilter = GenerateClosure(self.SetClassAndSpecFilters, self);
	ClassMenu.InitClassSpecDropdown(self.ClassDropdown, getClassFilter, getSpecFilter, setClassAndSpecFilter);
end

function LootJournalMixin:SetupRuneforgePowerDropdown()
	local function SetSelected(filter)
		self:SetRuneforgePowerFilter(filter);
	end

	local function IsSelected(filter)
		return filter == self:GetRuneforgePowerFilter();
	end

	self.RuneforgePowerDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LOOT_JOURNAL_POWER");

		for index, filter in ipairs(RuneforgePowerFilterOrder) do
			local text = RuneforgeUtil.GetRuneforgeFilterText(filter);
			rootDescription:CreateRadio(text, IsSelected, SetSelected, filter);
		end
	end);
end

function LootJournalMixin:SetPendingPowerID(powerID)
	self.pendingPowerID = powerID;
end

function LootJournalMixin:GetPendingPowerID()
	return self.pendingPowerID;
end

function LootJournalMixin:OpenToPowerID(powerID)
	local FindPower = function(elementData)
		return elementData.powerID == powerID;
	end;

	if not self.ScrollBox:FindByPredicate(FindPower) then
		self:SetRuneforgePowerFilter(Enum.RuneforgePowerFilter.All);
		
		if not self.ScrollBox:FindByPredicate(FindPower) then
			self:SetClassAndSpecFilters(RuneforgeUtil.GetPreviewClassAndSpec(), UNSPECIFIED_SPEC_FILTER);
		end
	end

	self:ScrollToPowerID(powerID);
end

function LootJournalMixin:ScrollToPowerID(powerID)
	self.ScrollBox:ScrollToElementDataByPredicate(function(elementData)
		return elementData.powerID == powerID;
	end);
end

function LootJournalMixin:Refresh()
	if self:IsShown() then
		local dataProvider = CreateDataProviderWithAssignedKey(self.powers, "powerID");
		self.ScrollBox:SetDataProvider(dataProvider);
	end
end

function LootJournalMixin:GetClassFilter()
	return self.classFilter or UNSPECIFIED_CLASS_FILTER;
end

function LootJournalMixin:GetSpecFilter()
	return self.specFilter or UNSPECIFIED_SPEC_FILTER;
end

function LootJournalMixin:UpdatePowers()
	local classFilter = self:GetClassFilter();
	local specFilter = self:GetSpecFilter();
	local classID = (classFilter ~= UNSPECIFIED_CLASS_FILTER) and classFilter or nil;
	local specID = (specFilter ~= UNSPECIFIED_SPEC_FILTER) and specFilter or nil;
	local covenantID = nil;
	local runeforgePowerFilter = self:GetRuneforgePowerFilter();
	self.powers = C_LegendaryCrafting.GetRuneforgePowersByClassSpecAndCovenant(classID, specID, covenantID, runeforgePowerFilter);
	self:Refresh();
end

function LootJournalMixin:SetClassAndSpecFilters(newClassFilter, newSpecFilter)
	if self.classFilter ~= newClassFilter or self.specFilter ~= newSpecFilter then
		local classID = (newClassFilter ~= UNSPECIFIED_CLASS_FILTER) and newClassFilter or nil;
		local specID = (newSpecFilter ~= UNSPECIFIED_SPEC_FILTER) and newSpecFilter or nil;

		self.classFilter = newClassFilter;
		self.specFilter = newSpecFilter;
		self:UpdatePowers();
	end
end

function LootJournalMixin:SetRuneforgePowerFilter(runeforgePowerFilter)
	self.runeforgePowerFilter = runeforgePowerFilter;
	self:UpdatePowers();
end

function LootJournalMixin:GetRuneforgePowerFilter()
	return self.runeforgePowerFilter or Enum.RuneforgePowerFilter.All;
end

function LootJournalMixin:GetClassAndSpecFilters()
	return self.classFilter, self.specFilter;
end
