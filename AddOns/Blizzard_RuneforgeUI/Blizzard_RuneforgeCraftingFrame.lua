
RuneforgeCraftingFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

local RuneforgeCraftingFrameEvents = {
	"GLOBAL_MOUSE_DOWN",
};

function RuneforgeCraftingFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RuneforgeCraftingFrameEvents);

	self:RegisterRefreshMethod(self.Refresh);
end

function RuneforgeCraftingFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeCraftingFrameEvents);

	self:UnregisterRefreshMethod(self.Refresh);
end

function RuneforgeCraftingFrameMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = ...;
		local isRightButton = buttonName == "RightButton";

		local mouseFocus = GetMouseFocus();
		if isRightButton or (not DoesAncestryInclude(self.PowerFrame, mouseFocus) and mouseFocus ~= self.PowerSlot) then
			self.PowerFrame:Hide();
		end

		if isRightButton or (not DoesAncestryInclude(self.ModifierFrame, mouseFocus)) then
			self.ModifierFrame:CloseSelector();
		end
	end
end

function RuneforgeCraftingFrameMixin:SetItem(item)
	return self.BaseItemSlot:SetItem(item);
end

function RuneforgeCraftingFrameMixin:GetItem()
	return self.BaseItemSlot:GetItem();
end

function RuneforgeCraftingFrameMixin:SetPowerID(powerID)
	return self.PowerSlot:SetPowerID(powerID);
end

function RuneforgeCraftingFrameMixin:GetPowerID()
	return self.PowerSlot:GetPowerID();
end

function RuneforgeCraftingFrameMixin:GetModifiers()
	return self.ModifierFrame:GetModifiers();
end

function RuneforgeCraftingFrameMixin:TogglePowerList()
	if self.PowerFrame:IsShown() then
		self.PowerFrame:Hide();
	else
		self.PowerFrame:OpenPowerList(self:GetRuneforgeFrame():GetPowers());
		self.PowerFrame:Show();
	end
end

function RuneforgeCraftingFrameMixin:Refresh()
	local hasItem = self:GetItem() ~= nil;
	if self.RunesGlow:IsShown() == hasItem then
		return;
	end

	self:GetRuneforgeFrame():SetRunesShown(hasItem);
	self.RunesGlow:SetShown(hasItem);

	if hasItem then
		self.RunesGlow.FadeIn:Play();
	end
end

function RuneforgeCraftingFrameMixin:GetRuneforgeFrame()
	return self:GetParent();
end
