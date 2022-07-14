
-- LootJournal Shadowlands update: Resurrected from the great beyond for runeforge legendary powers.

local NO_SPEC_FILTER = 0;
local NO_CLASS_FILTER = 0;

local RuneforgePowerFilterOrder = {
	Enum.RuneforgePowerFilter.All,
	Enum.RuneforgePowerFilter.Available,
	Enum.RuneforgePowerFilter.Unavailable,
};


RuneforgeLegendaryPowerLootJournalMixin = CreateFromMixins(RuneforgePowerBaseMixin);

function RuneforgeLegendaryPowerLootJournalMixin:InitElement(lootJournal)
	self.lootJournal = lootJournal;
end

function RuneforgeLegendaryPowerLootJournalMixin:UpdateDisplay()
	self:SetPowerID(self.lootJournal:GetPowerID(self:GetListIndex()));
end

function RuneforgeLegendaryPowerLootJournalMixin:OnPowerSet(oldPowerID, newPowerID)
	local powerInfo = self:GetPowerInfo();
	self.Icon:SetTexture(powerInfo.iconFileID);

	local isAvailable = powerInfo.state == Enum.RuneforgePowerState.Available;
	self.Icon:SetDesaturation(isAvailable and 0 or 1);
	self.UnavailableBackground:SetShown(not isAvailable);
	self.Name:SetText(powerInfo.name);
	self.Name:SetTextColor(LEGENDARY_ORANGE_COLOR:GetRGBA());
	
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
	self:UpdateRuneforgePowerFilterButtonText();

	self.PowersFrame:SetElementTemplate("RuneforgeLegendaryPowerLootJournalTemplate", self);

	self.PowersFrame:SetGetNumResultsFunction(GenerateClosure(self.GetNumPowers, self));

	local stride = 2;
	local xPadding = 20;
	local yPadding = 0;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, xPadding, yPadding);
	self.PowersFrame:SetLayout(layout);
end

function LootJournalMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, LootJournalEvents);

	self:UpdatePowers();

	local pendingPowerID = self:GetPendingPowerID();
	if pendingPowerID then
		self:OpenToPowerID(pendingPowerID);
	end
end

function LootJournalMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, LootJournalEvents);
end

function LootJournalMixin:OnEvent()
	self:UpdatePowers();
end

function LootJournalMixin:SetPendingPowerID(powerID)
	self.pendingPowerID = powerID;
end

function LootJournalMixin:GetPendingPowerID()
	return self.pendingPowerID;
end

function LootJournalMixin:OpenToPowerID(powerID)
	if not self:ScrollToPowerID(powerID) then
		self:SetRuneforgePowerFilter(Enum.RuneforgePowerFilter.All);
		if not self:ScrollToPowerID(powerID) then
			local classID = RuneforgeUtil.GetPreviewClassAndSpec();
			self:SetClassAndSpecFilters(classID, NO_SPEC_FILTER);
			self:ScrollToPowerID(powerID);
		end
	end
end

function LootJournalMixin:ScrollToPowerID(powerID)
	for elementFrame in self.PowersFrame:EnumerateElementFrames() do
		if elementFrame:GetPowerID() == powerID then
			-- Scroll to the frame that has a matching power.
			local yOffset = select(5, elementFrame:GetPoint());
			local function UpdateScrollBar()
				self.PowersFrame.ScrollBar:SetValue(-yOffset);
			end

			-- We have to delay the update until the scroll bar has been properly initialized.
			-- Unforunately there's no easy way to force this to happen and we just have to wait
			-- until OnLayerUpdate refreshes the scroll bar.
			C_Timer.After(0, UpdateScrollBar);
			return true;
		end
	end

	return false;
end

function LootJournalMixin:GetNumPowers()
	return #self.powers;
end

function LootJournalMixin:GetPowerID(listIndex)
	return self.powers[listIndex];
end

function LootJournalMixin:Refresh()
	if self:IsShown() then
		self.PowersFrame:RefreshListDisplay();
	end
end

function LootJournalMixin:GetClassButtonText()
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	if classFilter == NO_CLASS_FILTER then
		return ALL_CLASSES;
	elseif specFilter == NO_SPEC_FILTER then
		local classInfo = C_CreatureInfo.GetClassInfo(classFilter);
		if classInfo then
			return classInfo.className;
		end
	else
		return GetSpecializationNameForSpecID(specFilter);
	end

	return "";
end

function LootJournalMixin:UpdateClassButtonText()
	self.ClassDropDownButton:SetText(self:GetClassButtonText());
end

function LootJournalMixin:GetRuneforgePowerFilterButtonText()
	local runeforgePowerFilter = self:GetRuneforgePowerFilter();
	return RuneforgeUtil.GetRuneforgeFilterText(runeforgePowerFilter);
end

function LootJournalMixin:UpdateRuneforgePowerFilterButtonText()
	self.RuneforgePowerFilterDropDownButton:SetText(self:GetRuneforgePowerFilterButtonText());
end

function LootJournalMixin:GetClassFilter()
	return self.classFilter or NO_CLASS_FILTER;
end

function LootJournalMixin:GetSpecFilter()
	return self.specFilter or NO_SPEC_FILTER;
end

function LootJournalMixin:UpdatePowers()
	local classFilter = self:GetClassFilter();
	local specFilter = self:GetSpecFilter();
	local classID = (classFilter ~= NO_CLASS_FILTER) and classFilter or nil;
	local specID = (specFilter ~= NO_SPEC_FILTER) and specFilter or nil;
	local runeforgePowerFilter = self:GetRuneforgePowerFilter();
	self.powers = C_LegendaryCrafting.GetRuneforgePowersByClassAndSpec(classID, specID, runeforgePowerFilter);
	self:Refresh();
end

function LootJournalMixin:SetClassAndSpecFilters(newClassFilter, newSpecFilter)
	if self.classFilter ~= newClassFilter or self.specFilter ~= newSpecFilter then
		local classID = (newClassFilter ~= NO_CLASS_FILTER) and newClassFilter or nil;
		local specID = (newSpecFilter ~= NO_SPEC_FILTER) and newSpecFilter or nil;

		self.classFilter = newClassFilter;
		self.specFilter = newSpecFilter;
		self:UpdateClassButtonText();
		self:UpdatePowers();
	end

	CloseDropDownMenus(1);
end

function LootJournalMixin:SetRuneforgePowerFilter(runeforgePowerFilter)
	self.runeforgePowerFilter = runeforgePowerFilter;
	self:UpdateRuneforgePowerFilterButtonText();
	self:UpdatePowers();
end

function LootJournalMixin:GetRuneforgePowerFilter()
	return self.runeforgePowerFilter or Enum.RuneforgePowerFilter.All;
end

function LootJournalMixin:GetClassAndSpecFilters()
	return self.classFilter, self.specFilter;
end

function LootJournalMixin:ToggleClassDropDown()
	ToggleDropDownMenu(1, nil, self.ClassDropDown, self.ClassDropDownButton, 5, 0);
end

function LootJournalMixin:ToggleRuneforgePowerFilterDropDown()
	ToggleDropDownMenu(1, nil, self.RuneforgePowerFilterDropDown, self.RuneforgePowerFilterDropDownButton, 5, 0);
end

function LootJournalMixin:OpenRuneforgePowerFilterDropDown()
	local runeforgePowerFilter = self:GetRuneforgePowerFilter();

	local function SetRuneforgePowerFilter(_, runeforgePowerFilter)
		self:SetRuneforgePowerFilter(runeforgePowerFilter);
	end

	for i, filter in ipairs(RuneforgePowerFilterOrder) do
		local info = UIDropDownMenu_CreateInfo();
		info.leftPadding = 10;
		info.text = RuneforgeUtil.GetRuneforgeFilterText(filter);
		info.checked = filter == runeforgePowerFilter;
		info.func = SetRuneforgePowerFilter;
		info.arg1 = filter;
		UIDropDownMenu_AddButton(info);
	end
end


LootJournalRuneforgePowerFilterDropDownButtonMixin = {};

function LootJournalRuneforgePowerFilterDropDownButtonMixin:OnMouseDown(...)
	EJButtonMixin.OnMouseDown(self, ...);
	self:GetParent():ToggleRuneforgePowerFilterDropDown();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

local function OpenRuneforgePowerFilterDropDown(self)
	self:GetParent():OpenRuneforgePowerFilterDropDown();
end

function LootJournalRuneforgePowerFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, OpenRuneforgePowerFilterDropDown, "MENU");
end

-- Class and spec filter stuff. TODO: This should be factored out with the other class-and-spec filter buttons/dropdowns.
do
	LootJournalClassDropDownButtonMixin = {};

	function LootJournalClassDropDownButtonMixin:OnMouseDown(...)
		EJButtonMixin.OnMouseDown(self, ...);
		self:GetParent():ToggleClassDropDown();
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	local function OpenClassFilterDropDown(self, level)
		if level then
			self:GetParent():OpenClassFilterDropDown(level);
		end
	end

	function LootJournalClassDropDown_OnLoad(self)
		UIDropDownMenu_Initialize(self, OpenClassFilterDropDown, "MENU");
	end

	local CLASS_DROPDOWN = 1;

	function LootJournalMixin:OpenClassFilterDropDown(level)
		local filterClassID = self:GetClassFilter();
		local filterSpecID = self:GetSpecFilter();

		local function SetClassAndSpecFilters(_, classFilter, specFilter)
			self:SetClassAndSpecFilters(classFilter, specFilter);
		end

		local info = UIDropDownMenu_CreateInfo();

		if UIDROPDOWNMENU_MENU_VALUE == CLASS_DROPDOWN then 
			info.text = ALL_CLASSES;
			info.checked = filterClassID == NO_CLASS_FILTER;
			info.arg1 = NO_CLASS_FILTER;
			info.arg2 = NO_SPEC_FILTER;
			info.func = SetClassAndSpecFilters;
			UIDropDownMenu_AddButton(info, level);

			local numClasses = GetNumClasses();
			for i = 1, numClasses do
				local classDisplayName, classTag, classID = GetClassInfo(i);
				info.text = classDisplayName;
				info.checked = filterClassID == classID;
				info.arg1 = classID;
				info.arg2 = NO_SPEC_FILTER;
				info.func = SetClassAndSpecFilters;
				UIDropDownMenu_AddButton(info, level);
			end
		end

		if level == 1 then 
			info.text = CLASS;
			info.func =  nil;
			info.notCheckable = true;
			info.hasArrow = true;
			info.value = CLASS_DROPDOWN;
			UIDropDownMenu_AddButton(info, level);

			local classDisplayName, classTag, classID;
			if filterClassID ~= NO_CLASS_FILTER then
				classID = filterClassID;
				
				local classInfo = C_CreatureInfo.GetClassInfo(filterClassID);
				if classInfo then
					classDisplayName = classInfo.className;
					classTag = classInfo.classFile;
				end
			else
				classDisplayName, classTag, classID = UnitClass("player");
			end
			info.text = classDisplayName;
			info.notCheckable = true;
			info.arg1 = nil;
			info.arg2 = nil;
			info.func =  nil;
			info.hasArrow = false;
			UIDropDownMenu_AddButton(info, level);

			info.notCheckable = nil;
			local sex = UnitSex("player");
			for i = 1, GetNumSpecializationsForClassID(classID) do
				local specID, specName = GetSpecializationInfoForClassID(classID, i, sex);
				info.leftPadding = 10;
				info.text = specName;
				info.checked = filterSpecID == specID;
				info.arg1 = classID;
				info.arg2 = specID;
				info.func = SetClassAndSpecFilters;
				UIDropDownMenu_AddButton(info, level);
			end

			info.text = ALL_SPECS;
			info.leftPadding = 10;
			info.checked = classID == filterClassID and filterSpecID == NO_SPEC_FILTER;
			info.arg1 = classID;
			info.arg2 = NO_SPEC_FILTER;
			info.func = SetClassAndSpecFilters;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end
