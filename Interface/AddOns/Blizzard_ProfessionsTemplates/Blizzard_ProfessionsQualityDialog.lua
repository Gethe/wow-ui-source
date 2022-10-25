ProfessionsQualityDialogMixin = CreateFromMixins(CallbackRegistryMixin);

ProfessionsQualityDialogMixin:GenerateCallbackEvents(
{
    "Accepted",
});

function ProfessionsQualityDialogMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self:SetTitle(PROFESSIONS_QUALITY_DIALOG_TITLE);

	self.containers = {self.Container1, self.Container2, self.Container3};

	local function GetQuantityOutstanding(qualityIndex)
		return self:GetQuantityRequired() - (self:Accumulate() - self:GetQuantityAllocated(qualityIndex));
	end
	
	local function Allocate(qualityIndex, value)
		value = math.min(value, Professions.GetReagentQuantityInPossession(self:GetReagent(qualityIndex)));

		self.allocations:Allocate(self:GetReagent(qualityIndex), value);
		
		local overflow = math.max(0, self:Accumulate() - self:GetQuantityRequired());
		if overflow > 0 then
			for deallocateIndex = 1, self:GetReagentSlotCount() do
				if deallocateIndex ~= qualityIndex then
					local reagent = self:GetReagent(deallocateIndex);
					local oldQuantity = self.allocations:GetQuantityAllocated(reagent);
					local deallocatable = math.min(overflow, oldQuantity);
					if deallocatable > 0 then
						overflow = overflow - deallocatable;

						local newQuantity = oldQuantity - deallocatable;
						self.allocations:Allocate(reagent, newQuantity);
					end
				end

				if overflow <= 0 then
					break;
				end
			end
		end

		for qualityIndex = 1, self:GetReagentSlotCount() do
			local container = self.containers[qualityIndex];
			local editBox = container.EditBox;
			editBox:SetValue(self.allocations:GetQuantityAllocated(self:GetReagent(qualityIndex)));
		end

		self:EvaluateAllocations();
		return value;
	end

	for qualityIndex, container in ipairs(self.containers) do
		local editBox = container.EditBox;

		local function ApplyEditBoxText(editBox)
			Allocate(qualityIndex, math.min(self:GetQuantityRequired(), tonumber(editBox:GetText()) or 0));
		end

		editBox:SetScript("OnEnterPressed", ApplyEditBoxText);
		editBox:SetScript("OnEditFocusLost", ApplyEditBoxText);
		editBox:SetScript("OnTextChanged", function(editBox, userChanged)
			if not userChanged then
				Allocate(qualityIndex, tonumber(editBox:GetText()) or 0);
			end
		end);

		local button = container.Button;
		button:SetScript("OnClick", function(button, buttonName, down)
			if IsShiftKeyDown() then
				Professions.HandleQualityReagentItemLink(self.recipeID, self.reagentSlotSchematic, qualityIndex);
			else
				if buttonName == "LeftButton" then
					Allocate(qualityIndex, self:GetQuantityRequired());
				elseif buttonName == "RightButton" then
					Allocate(qualityIndex, 0)
				end
			end
		end);

		button:SetScript("OnEnter", function()
			GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT");
			local reagent = self:GetReagent(qualityIndex);
			GameTooltip:SetItemByID(reagent.itemID);
			GameTooltip:Show();
		end);

		button:SetScript("OnLeave", function()
			GameTooltip:Hide();
		end);
	end
	
	self.onCloseCallback = function(button)
		PlaySound(SOUNDKIT.UI_PROFESSION_QUALITY_DIALOG_EXIT);
		return true;
	end
	
	local function OnCancel()
		self:Hide();
		PlaySound(SOUNDKIT.UI_PROFESSION_QUALITY_DIALOG_EXIT);
	end

	self.CancelButton:SetText(CANCEL);
	self.CancelButton:SetScript("OnClick", OnCancel);

	self.AcceptButton:SetText(ACCEPT);
	self.AcceptButton:SetScript("OnClick", function(button, buttonName, down)
		self:TriggerEvent(ProfessionsQualityDialogMixin.Event.Accepted, self.allocations, self.reagentSlotSchematic);
		self:Hide();
		PlaySound(SOUNDKIT.UI_PROFESSION_QUALITY_DIALOG_CONFIRM);
	end);
end

function ProfessionsQualityDialogMixin:OnHide()
	self:UnregisterEvents();
	self.reagentSlotSchematic = nil;
	self.recipeID = nil;
	self.allocations = nil;
end

function ProfessionsQualityDialogMixin:GetReagent(qualityIndex)
	return self.reagentSlotSchematic.reagents[qualityIndex];
end

function ProfessionsQualityDialogMixin:GetReagentSlotCount()
	return #self.reagentSlotSchematic.reagents;
end

function ProfessionsQualityDialogMixin:Init(recipeID, reagentSlotSchematic, allocations, slotIndex, disallowZeroAllocations)
	self.reagentSlotSchematic = reagentSlotSchematic;
	self.recipeID = recipeID;
	self.slotIndex = slotIndex;
	self.allocations = allocations;
	self.disallowZeroAllocations = disallowZeroAllocations;

	self:Setup();
end

function ProfessionsQualityDialogMixin:ReinitAllocations(allocations)
	self.allocations = allocations;
	self:Setup();
end

function ProfessionsQualityDialogMixin:Setup()
	for qualityIndex, reagent in ipairs(self.reagentSlotSchematic.reagents) do
		local container = self.containers[qualityIndex];
		local itemID = reagent.itemID;
		local button = container.Button;
		button:SetItem(itemID);

		-- The min and max values will be recalculated after our initial values are set.
		local editBox = container.EditBox;
		editBox:SetMinMaxValues(0, math.huge);

		local quantity = self:GetQuantityAllocated(qualityIndex);
		editBox:SetText(quantity);

		local count = Professions.GetReagentQuantityInPossession(reagent);
		button:SetItemButtonCount(count);

		local enabled = count > 0;
		button:DesaturateHierarchy(enabled and 0 or 1);
		editBox:SetEnabled(enabled);
	end

	self:EvaluateAllocations();
end

function ProfessionsQualityDialogMixin:GetSlotIndex()
	return self.slotIndex;
end

function ProfessionsQualityDialogMixin:Open(recipeID, reagentSlotSchematic, allocations, slotIndex, disallowZeroAllocations)
	self:Init(recipeID, reagentSlotSchematic, allocations, slotIndex, disallowZeroAllocations);
	self:Show();
end

function ProfessionsQualityDialogMixin:Close()
	self:Hide();
end

function ProfessionsQualityDialogMixin:Accumulate()
	return self.allocations:Accumulate();
end

function ProfessionsQualityDialogMixin:GetQuantityAllocated(qualityIndex)
	return self.allocations:GetQuantityAllocated(self:GetReagent(qualityIndex));
end

function ProfessionsQualityDialogMixin:GetQuantityRequired()
	return self.reagentSlotSchematic.quantityRequired;
end

function ProfessionsQualityDialogMixin:EvaluateAllocations()
	local quantityRequired = self:GetQuantityRequired();
	local quantityAllocated = self:Accumulate();

	for qualityIndex, reagent in ipairs(self.reagentSlotSchematic.reagents) do
		local container = self.containers[qualityIndex];
		local editBox = container.EditBox;
		editBox:SetMinMaxValues(0, math.min(self:GetQuantityRequired(), Professions.GetReagentQuantityInPossession(reagent)));
	end

	local canEnable = not self.disallowZeroAllocations and quantityAllocated == 0;
	self.AcceptButton:SetEnabled(canEnable or quantityAllocated >= quantityRequired);
end