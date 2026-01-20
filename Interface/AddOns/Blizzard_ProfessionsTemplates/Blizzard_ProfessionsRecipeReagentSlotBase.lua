-- This file should be renamed to *ReagentSlotButton.
ProfessionsReagentSlotButtonMixin = CreateFromMixins(ProfessionsButtonMixin);

function ProfessionsReagentSlotButtonMixin:GetReagent()
	return self.reagent;
end

function ProfessionsReagentSlotButtonMixin:SetReagent(reagent)
	ProfessionsButtonMixin.SetReagent(self, reagent);

	self.reagent = reagent;

	self:Update();
end

function ProfessionsReagentSlotButtonMixin:Init()
	self.reagent = nil;
	self.showLargeAddIcon = nil;
	self.QualityOverlay:SetAtlas(nil);
	self.AddIcon:SetShown(false);
	self.CropFrame:SetShown(false);
	self:SetLocked(false);
end

function ProfessionsReagentSlotButtonMixin:Clear()
	self.reagent = nil;

	self:SetItem(nil);
	self:Update();
end

function ProfessionsReagentSlotButtonMixin:Update()
	self:UpdateOverlay();
	self:UpdateCursor();
end

function ProfessionsReagentSlotButtonMixin:SetLocked(locked)
	self.locked = locked;
	self:Update();
end

function ProfessionsReagentSlotButtonMixin:SetModifyingRequired(isModifyingRequired)
	self.showLargeAddIcon = isModifyingRequired;
	self.CropFrame:SetShown(isModifyingRequired);

	if isModifyingRequired then
		local scale = .65;
		self:SetNormalAtlas("itemupgrade_greenplusicon", false);
		self:GetNormalTexture():SetScale(scale);
		self:GetNormalTexture():SetDrawLayer("BORDER");

		self:SetPushedAtlas("itemupgrade_greenplusicon_pressed", false);
		self:GetPushedTexture():SetScale(scale);
		self:GetPushedTexture():SetDrawLayer("BORDER");

		self:ClearHighlightTexture();
	else	
		local scale = 1;
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
		self:GetNormalTexture():SetScale(scale);
		self:GetNormalTexture():SetDrawLayer("BORDER");

		self:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
		self:GetPushedTexture():SetScale(scale);
		self:GetPushedTexture():SetDrawLayer("BORDER");

		self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
	end
end

function ProfessionsReagentSlotButtonMixin:UpdateOverlay()
	if not self.InputOverlay then
		return;
	end

	self.InputOverlay.LockedIcon:SetShown(self.locked);

	local reagent = self:GetReagent();
	local showAddIcon = reagent == nil;

	if self.locked or self.showLargeAddIcon then
		showAddIcon = false;
	end

	self.InputOverlay.AddIcon:SetShown(showAddIcon);
end

function ProfessionsReagentSlotButtonMixin:UpdateCursor()
	if not self:IsMouseMotionFocus() then
		return;
	end

	local onEnterScript = self:GetScript("OnEnter");
	if onEnterScript ~= nil then
		onEnterScript(self);
	end
end
