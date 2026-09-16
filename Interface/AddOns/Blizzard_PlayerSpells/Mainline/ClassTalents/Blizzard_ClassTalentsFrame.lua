function ClassTalentsFrameMixin:UpdateInspectingPvPSlots(isInspecting)
	self.PvPTalentSlotTray:SetPoint("RIGHT", self.BottomBar, "RIGHT", isInspecting and -24 or -114, 0);
	self.PvPTalentSlotTray:SetShown(not isInspecting or (self:GetInspectUnit() ~= nil));
end

function ClassTalentsFrameMixin:SetPvPTalentFrames(frame)
	self.PvPTalentList:SetTalentFrame(frame);
	self.PvPTalentSlotTray:SetTalentFrame(frame);
end

function ClassTalentsFrameMixin:RefreshTreeCurrencyDisplay()
	local specCurrencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[2] or nil;
	self.SpecCurrencyDisplay:SetAmount(specCurrencyInfo and specCurrencyInfo.quantity or 0);
	local specName = self:GetSpecName();
	if specName then
		self.SpecCurrencyDisplay:SetPointTypeText(string.upper(specName));
	end	
end

function ClassTalentsFrameMixin:SetSearchBoxDefaultPosition()
	self.SearchBox:SetPoint("LEFT", self.LoadSystem, "RIGHT", 20, 0);
end
