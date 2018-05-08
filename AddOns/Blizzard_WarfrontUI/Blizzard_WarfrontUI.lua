WarfrontEventRegisterMixin = {};

function WarfrontEventRegisterMixin:OnLoad()
	self:RegisterEvent("SCENARIO_UPDATE");
	self:RegisterEvent("SCENARIO_COMPLETED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function WarfrontEventRegisterMixin:OnEvent(event)
	if ( event == "SCENARIO_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
		-- temp
		local name = C_Scenario.GetInfo();
		self.inWarfrontScenario = (name == "The Battle for Stromgarde");
	elseif ( event == "SCENARIO_COMPLETED" and self.inWarfrontScenario ) then
		self:OnScenarioCompleted();
	end
end

function WarfrontEventRegisterMixin:OnScenarioCompleted()
	-- temp
	UIParentLoadAddOn("Blizzard_PVPUI");
	PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE);
	TopBannerManager_Show(self, { name="The Battle for Stromgarde", description="Horde wins!" });
end

-- only units that appear in both buildable and capturable locations need enabledCondition

local ASSETS = {
	["WEAPON_UPGRADE_1"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14442,
		},
	},
	["WEAPON_UPGRADE_2"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14645,
		},
	},
	["WEAPON_UPGRADE_3"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14647,
		},
	},
	["ARMOR_UPGRADE_1"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},		
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14458,
		},
	},
	["ARMOR_UPGRADE_2"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14646,
		},
	},
	["ARMOR_UPGRADE_3"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14648,
		},
	},
	["STRONGHOLD"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14525, progressWSID = 14524 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14601, progressWSID = 14600 },
		},
	},
	["FORTRESS"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14538, progressWSID = 14536 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14603, progressWSID = 14602 },
		},	
	},
};

local LOCATIONS = {
	["BARRACKS"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14500, progressWSID = 14499 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14593, progressWSID = 14590 },
		},
	},
	["ARMORY"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14509, progressWSID = 14507 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14594, progressWSID = 14591 },
		},
	},
	["WORKSHOP"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14514, progressWSID = 14512 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14595, progressWSID = 14592 },
		},
	},
	["ALTAR"] = {
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14543, progressWSID = 14542 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14599, progressWSID = 14598 },
		},
	},
};

--===============================================================================================

local CHOICES = {
	[313] = {
		options = {
			[764] = { location = "BARRACKS", index = 1 },
			[1024] = { location = "BARRACKS", index = 2 },
		},
		percentageOnHeader = true,
	},
	[358] = {
		options = {
			[1021] = { location = "ALTAR", index = 1 },
			[1027] = { location = "ALTAR", index = 2 },	
		},
		percentageOnHeader = true,
	},
	[320] = {
		options = {
			[779] = { asset = "STRONGHOLD", index = 1 },
			[1028] = { asset = "STRONGHOLD", index = 2 },
		},
		percentageOnHeader = true,
	},
	[328] = {
		options = {
			[818] = { location = "WORKSHOP", index = 1 },
			[1026] = { location = "WORKSHOP", index = 2 },
		},
		percentageOnHeader = true,
	},	
	[329] = {
		options = {
			[820] = { location = "ARMORY", index = 1 },
			[1025] = { location = "ARMORY", index = 2 },
		},
		percentageOnHeader = true,
	},	
	[357] = {
		options = {
			[1017] = { asset = "FORTRESS", index = 1 },
			[1029] = { asset = "FORTRESS", index = 2 },
		},
		percentageOnHeader = true,
	},
	[332] = {
		options = {
			[828] = { asset = "WEAPON_UPGRADE_1", xOffset = 127 },
			[833] = { asset = "ARMOR_UPGRADE_1", xOffset = 127 },
			[1151] = { asset = "WEAPON_UPGRADE_2", xOffset = 127 },
			[1159] = { asset = "ARMOR_UPGRADE_2", xOffset = 127 },
			[1155] = { asset = "WEAPON_UPGRADE_3", xOffset = 127 },
			[1163] = { asset = "ARMOR_UPGRADE_3", xOffset = 127 },
		},
	},
};

WarfrontPlayerChoiceHookMixin = { };

local function WarfrontPlayerChoiceHook_Update(self, ...)
	WarfrontPlayerChoiceHook:Reset();
	WarfrontPlayerChoiceHook.oldUpdateFunc(self, ...);
	
	WarfrontPlayerChoiceHook.choice = CHOICES[self.choiceID];
	if not WarfrontPlayerChoiceHook.choice then
		WarfrontPlayerChoiceHook.Percentage:Hide();
		return;
	end

	for i, option in ipairs(self.Options) do
		if option:IsShown() then
			local currentValue, maxValue = WarfrontPlayerChoiceHook:GetValuesForOption(option.optID);
			if maxValue > 0 then
				WarfrontPlayerChoiceHook:AddProgressBar(option);
			end
		end
	end
end

function WarfrontPlayerChoiceHookMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
	self.progressBarPool = CreateFramePool("FRAME", self, "TooltipProgressBarTemplate");
end

function WarfrontPlayerChoiceHookMixin:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		local addon = ...;
		if addon == "Blizzard_WarboardUI" then
			self:SetParent(WarboardQuestChoiceFrame);
			self:SetPoint("LEFT", WarboardQuestChoiceFrame.QuestionText, "RIGHT", 20, 0);
			self:Show();
			self:UnregisterEvent("ADDON_LOADED");
			self.oldUpdateFunc = WarboardQuestChoiceFrame.Update;
			WarboardQuestChoiceFrame.Update = WarfrontPlayerChoiceHook_Update;
		end
	end
end

function WarfrontPlayerChoiceHookMixin:Reset()
	self.progressBarPool:ReleaseAll();
end

function WarfrontPlayerChoiceHookMixin:OnUpdate()
	self:UpdateProgressBars();
end

function WarfrontPlayerChoiceHookMixin:GetTargetFromOptionInfo(optionInfo)
	if optionInfo then
		if optionInfo.location then
			return LOCATIONS[optionInfo.location];
		elseif optionInfo.asset then
			return ASSETS[optionInfo.asset];
		end
	end
	return nil;
end

function WarfrontPlayerChoiceHookMixin:GetValuesForOption(optionID)
	local progressWSID, costWSID = self:GetWorldStates(self.choice.options[optionID]);
	return C_Warfront.GetWorldStateValue(progressWSID), C_Warfront.GetWorldStateValue(costWSID);
end

function WarfrontPlayerChoiceHookMixin:GetWorldStates(optionInfo)
	local target = self:GetTargetFromOptionInfo(optionInfo);
	if target then
		if optionInfo.index then
			local costInfo = target.costs[optionInfo.index];
			return costInfo.progressWSID, costInfo.costWSID;
		elseif target.progressBar then
			return target.progressBar.currentValueWSID, target.progressBar.maxValueWSID;
		end
	end
	return 0, 0;
end

function WarfrontPlayerChoiceHookMixin:GetTotalValues()
	local totalCurrentValue = 0;
	local totalMaxValue = 0;
	for optID, optionInfo in pairs(self.choice.options) do
		local progressWSID, costWSID = self:GetWorldStates(optionInfo);
		local currentValue = C_Warfront.GetWorldStateValue(progressWSID);
		local maxValue = C_Warfront.GetWorldStateValue(costWSID);
		totalCurrentValue = totalCurrentValue + currentValue;
		totalMaxValue = totalMaxValue + maxValue;
	end
	return totalCurrentValue, totalMaxValue;
end

local function ProgressBarOnMouseDown(self, button)
	if button == "RightButton" and IsShiftKeyDown() and IsControlKeyDown() then
		local optionInfo = WarfrontPlayerChoiceHook.choice.options[self:GetParent().optID];
		local progressWSID, costWSID = WarfrontPlayerChoiceHook:GetWorldStates(optionInfo);
		local targetValue = C_Warfront.GetWorldStateValue(costWSID) - 10;
		ConsoleExec("setworldstate "..progressWSID.." "..targetValue);
	end
end

function WarfrontPlayerChoiceHookMixin:AddProgressBar(option)
	local progressBar = self.progressBarPool:Acquire();
	progressBar:SetParent(option);
	local optionInfo = self.choice.options[option.optID];
	local xOffset = optionInfo.xOffset or 0;
	progressBar:SetPoint("TOP", option, xOffset, -20);
	progressBar:Show();
	progressBar:SetScript("OnMouseDown", ProgressBarOnMouseDown);
end

function WarfrontPlayerChoiceHookMixin:UpdateProgressBars()
	if not self.choice then
		return;
	end

	for progressBar in self.progressBarPool:EnumerateActive() do
		local currentValue, maxValue = self:GetValuesForOption(progressBar:GetParent().optID);
		progressBar.Bar:SetMinMaxValues(0, maxValue);
		progressBar.Bar:SetValue(currentValue);
		progressBar.Bar.Label:SetText(FormatPercentage(currentValue / maxValue, true));
		if currentValue == maxValue then
			progressBar:GetParent().OptionButton:SetEnabled(false);
		end
	end

	if self.choice.percentageOnHeader then
		local totalCurrent, totalMax = self:GetTotalValues();
		self.Percentage:SetText(FormatPercentage(totalCurrent / totalMax, true));
		self.Percentage:Show();
	else
		self.Percentage:Hide();
	end
end