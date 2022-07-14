ProfessionsReagentSlotButtonMixin = {};

function ProfessionsReagentSlotButtonMixin:SetItem(item)
	ItemButtonMixin.SetItem(self, item);

	self.InputOverlay:Hide();
end

function ProfessionsReagentSlotButtonMixin:Reset()
	ItemButtonMixin.Reset(self);
		
	self.InputOverlay:Show();

	self:UpdateCursor();
end

function ProfessionsReagentSlotButtonMixin:SetLocked(locked)
	self.InputOverlay.LockedIcon:SetShown(locked);
	self.InputOverlay.AddIcon:SetShown(not locked);
end

function ProfessionsReagentSlotButtonMixin:UpdateCursor()
	local onEnterScript = self:GetScript("OnEnter");
	if onEnterScript ~= nil then
		onEnterScript(self);
	end
end