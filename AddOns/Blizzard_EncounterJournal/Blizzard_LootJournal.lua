
-- LootJournal Shadowlands update: Resurrected from the great beyond for runeforge legendary powers.

local NO_SPEC_FILTER = 0;
local NO_CLASS_FILTER = 0;

local function LootJournal_GetPreviewClassAndSpec()
	local classID = select(3, UnitClass("player"));
	local spec = GetSpecialization();
	local specID = spec and GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")) or -1;
	return classID, specID;
end


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
	self.Icon:SetDesaturation(isAvailable and 0 or 0.8);
	self.Icon:SetAlpha(isAvailable and 1.0 or 0.7);
	self.Name:SetText(powerInfo.name);
end

function RuneforgeLegendaryPowerLootJournalMixin:ShouldShowUnavailableError()
	return true;
end


LootJournalMixin = {};

function LootJournalMixin:OnLoad()
	self:SetClassAndSpecFilters(LootJournal_GetPreviewClassAndSpec());

	self.PowersFrame:SetElementTemplate("RuneforgeLegendaryPowerLootJournalTemplate", self);

	self.PowersFrame:SetGetNumResultsFunction(GenerateClosure(self.GetNumPowers, self));

	local stride = 2;
	local xPadding = 20;
	local yPadding = 0;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, xPadding, yPadding);
	self.PowersFrame:SetLayout(layout);
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

function LootJournalMixin:GetClassFilter()
	return self.classFilter or NO_CLASS_FILTER;
end

function LootJournalMixin:GetSpecFilter()
	return self.specFilter or NO_SPEC_FILTER;
end

function LootJournalMixin:SetClassAndSpecFilters(newClassFilter, newSpecFilter)
	if self.classFilter ~= newClassFilter or self.specFilter ~= newSpecFilter then
		local classID = (newClassFilter ~= NO_CLASS_FILTER) and newClassFilter or nil;
		local specID = (newSpecFilter ~= NO_SPEC_FILTER) and newSpecFilter or nil;
		self.powers = C_LegendaryCrafting.GetRuneforgePowersByClassAndSpec(classID, specID);

		self.classFilter = newClassFilter;
		self.specFilter = newSpecFilter;
		self:UpdateClassButtonText();
		self:Refresh();
	end

	CloseDropDownMenus(1);
end

function LootJournalMixin:GetClassAndSpecFilters()
	return self.classFilter, self.specFilter;
end

function LootJournalMixin:ToggleClassDropDown()
	ToggleDropDownMenu(1, nil, self.ClassDropDown, self.ClassDropDownButton, 5, 0);
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
