HousingBlueprintBudgetsContainerMixin = {};

function HousingBlueprintBudgetsContainerMixin:OnLoad()
	self.budgetEntryPool = CreateFramePool("BUTTON", self, "HousingBlueprintBudgetTemplate");
	
	self.InteriorBudgets.Label:SetText(HOUSING_BLUEPRINT_BUDGET_SECTION_INTERIOR);
	self.ExteriorBudgets.Label:SetText(HOUSING_BLUEPRINT_BUDGET_SECTION_EXTERIOR);
end

function HousingBlueprintBudgetsContainerMixin:SetBackgroundAlpha(backgroundAlpha)
	self.Background:SetAlpha(backgroundAlpha);
end

function HousingBlueprintBudgetsContainerMixin:SetInfo(budgetInfo, blueprintType)
	self:ClearData();

	-- Rooms are the only blueprint type that add to the existing spent budgets rather than replace them, so need to display "available" rather than "max"
	local isRoomBlueprint = blueprintType == Enum.HousingBlueprintType.Room;

	local numInterior = 0;
	for budgetType, budgetEntry in pairs(budgetInfo.interiorBudgets) do
		if budgetEntry.cost > 0 then -- skip showing any no-cost budgets
			numInterior = numInterior + 1;
		
			local budgetFrame = self.budgetEntryPool:Acquire();
			budgetFrame.layoutIndex = numInterior;
			budgetFrame:SetParent(self.InteriorBudgets);
			budgetFrame:Init(budgetEntry, --[[isInterior=]]true, --[[removeCurrentFromAvailable=]]isRoomBlueprint);
			budgetFrame:Show();

			if budgetFrame:IsInsufficient() then
				self.insufficientBudgetTypes[budgetType] = true;
			end
		end
	end

	local numExterior = 0;
	for budgetType, budgetEntry in pairs(budgetInfo.exteriorBudgets) do
		if budgetEntry.cost > 0 then -- skip showing any no-cost budgets
			numExterior = numExterior + 1;

			local budgetFrame = self.budgetEntryPool:Acquire();
			budgetFrame.layoutIndex = numExterior;
			budgetFrame:SetParent(self.ExteriorBudgets);
			budgetFrame:Show();
			budgetFrame:Init(budgetEntry, --[[isInterior=]]false, --[[removeCurrentFromAvailable=]]false);

			if budgetFrame:IsInsufficient() then
				self.insufficientBudgetTypes[budgetType] = true;
			end
		end
	end

	self.InteriorBudgets:SetShown(numInterior > 0);
	self.ExteriorBudgets:SetShown(numExterior > 0);

	self.isShowingAnyBudgets = numInterior > 0 or numExterior > 0;
	self:SetShown(self.isShowingAnyBudgets);
end

function HousingBlueprintBudgetsContainerMixin:ClearData()
	self.insufficientBudgetTypes = {};
	self.isShowingAnyBudgets = false;
	self.budgetEntryPool:ReleaseAll();
	-- Reset width so that it properly expands as part of the containing Layout frame, without bloating the resulting parent width
	self.InteriorBudgets:SetWidth(1);
	self.ExteriorBudgets:SetWidth(1);
end

function HousingBlueprintBudgetsContainerMixin:IsShowingAnyBudgets()
	return self.isShowingAnyBudgets;
end

function HousingBlueprintBudgetsContainerMixin:GetInsufficientBudgetTypes()
	return self.insufficientBudgetTypes;
end


local BudgetTypeVisuals = {
	[Enum.HousingBudgetType.DecorPlacement] = {
		interior = { icon = "house-decor-budget-icon", tooltip = HOUSING_BLUEPRINT_DECOR_INTERIOR_BUDGET_TOOLTIP },
		exterior = { icon = "house-decor-exteriorbudget-icon", tooltip = HOUSING_BLUEPRINT_DECOR_EXTERIOR_BUDGET_TOOLTIP },
	},
	[Enum.HousingBudgetType.PetDecor] = {
		interior = { icon = "house-decor-pets-icon", tooltip = HOUSING_BLUEPRINT_DECOR_PET_BUDGET_TOOLTIP },
		exterior = { icon = "house-decor-pets-icon", tooltip = HOUSING_BLUEPRINT_DECOR_PET_BUDGET_TOOLTIP },
	},
	[Enum.HousingBudgetType.RoomPlacement] = {
		interior = { icon = "house-room-limit-icon", tooltip = HOUSING_BLUEPRINT_ROOM_BUDGET_TOOLTIP },
	},
};

HousingBlueprintBudgetMixin = {};

function HousingBlueprintBudgetMixin:OnLoad()
	self.Icon:SetAtlas(self.icon);
end

function HousingBlueprintBudgetMixin:Init(budgetEntry, isInterior, removeCurrentFromAvailable)
	local typeVisuals = BudgetTypeVisuals[budgetEntry.budgetType];
	if not typeVisuals then
		assertsafe(false, "Missing visuals for budget type %d", budgetEntry.budgetType);
		return;
	end
	local visuals = isInterior and typeVisuals.interior or typeVisuals.exterior;
	if not visuals then
		assertsafe(false, "Missing context-specific visuals for budget type %d, is interior: %s", budgetEntry.budgetType, isInterior and "true" or "false");
		return;
	end

	self.Icon:SetAtlas(visuals.icon);
	self.tooltipText = visuals.tooltip;
	self.budgetEntry = budgetEntry;

	if self.budgetEntry.max then
		self.amountAvailable = self.budgetEntry.max;
		if removeCurrentFromAvailable then
			self.amountAvailable = self.amountAvailable - (self.budgetEntry.current or 0);
		end
		self.Text:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_BUDGET_COMPARE_FMT:format(self.budgetEntry.cost, self.amountAvailable));
	else
		self.amountAvailable = nil;
		self.Text:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_BUDGET_FMT:format(self.budgetEntry.cost));
	end

	local textColor = self:IsInsufficient() and RED_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
	self.Text:SetTextColor(textColor:GetRGB());

	self:MarkDirty();
end

function HousingBlueprintBudgetMixin.Reset(framePool, self)
	self.budgetEntry = nil;
	self.tooltipText = nil;
	self.amountAvailable = nil;
	Pool_HideAndClearAnchors(framePool, self);
end

function HousingBlueprintBudgetMixin:IsInsufficient()
	return self.amountAvailable ~= nil and self.budgetEntry.cost > self.amountAvailable;
end

function HousingBlueprintBudgetMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip_AddHighlightLine(GameTooltip, self.tooltipText);
	GameTooltip:Show();
end

function HousingBlueprintBudgetMixin:OnLeave()
	GameTooltip:Hide();
end

local BudgetTypeTranslator;
if Enum.HousingBudgetType then
	BudgetTypeTranslator = EnumUtil.GenerateNameTranslation(Enum.HousingBudgetType);
else
	BudgetTypeTranslator = function() return "Unknown"; end
end

function HousingBlueprintBudgetMixin:GetDebugName()
	if not self.budgetEntry then
		return "Unused";
	end
	return BudgetTypeTranslator(self.budgetEntry.budgetType);
end
