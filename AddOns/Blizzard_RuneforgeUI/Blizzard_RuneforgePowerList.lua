
RuneforgePowerButtonMixin = {};

function RuneforgePowerButtonMixin:SetPowerID(powerID)
	self.powerID = powerID;

	local hasPowerID = powerID ~= nil;
	self.powerInfo = hasPowerID and C_LegendaryCrafting.GetRuneforgePowerInfo(powerID) or nil;
	self.Icon:SetShown(hasPowerID);
	if hasPowerID then
		self.Icon:SetTexture(self.powerInfo and self.powerInfo.iconFileID or QUESTION_MARK_ICON);
		self:RegisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
	else
		self:UnregisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
	end
end

function RuneforgePowerButtonMixin:GetPowerID()
	return self.powerID;
end

function RuneforgePowerButtonMixin:OnHide()
	self:UnregisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
end

function RuneforgePowerButtonMixin:OnEvent(event, ...)
	if event == "RUNEFORGE_POWER_INFO_UPDATED" then
		local powerID = ...;
		if powerID == self:GetPowerID() then
			self:SetPowerID(powerID);

			if self:IsMouseOver() then
				self:OnEnter();
			end
		end
	end
end

function RuneforgePowerButtonMixin:OnEnter()
	if self.powerInfo then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", self.tooltipOffsetX or 0, self.tooltipOffsetY or 0);

		local wrap = true;
		GameTooltip_AddColoredLine(GameTooltip, self.powerInfo.description, GREEN_FONT_COLOR, wrap);

		GameTooltip:Show();
	end
end

function RuneforgePowerButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function RuneforgePowerButtonMixin:OnHide()
	self:UnregisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
end


RuneforgePowerSlotMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgePowerSlotMixin:OnLoad()
	self.Icon:SetPoint("CENTER", -5, 2);
	self.Icon:SetSize(64, 64);
end

function RuneforgePowerSlotMixin:OnShow()
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.OnBaseItemChanged, self);
end

function RuneforgePowerSlotMixin:OnHide()
	RuneforgePowerButtonMixin.OnHide(self);

	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self);
end

function RuneforgePowerSlotMixin:OnClick(buttonName)
	self:GetRuneforgeFrame():TogglePowerList();
end

function RuneforgePowerSlotMixin:Reset()
	self:SetPowerID(nil);
	self.SelectedTexture:Hide();
end

function RuneforgePowerSlotMixin:UpdateState()
	local powerSelected = self:GetPowerID() ~= nil;
	self.SelectedTexture:SetShown(powerSelected);

	local hasItem = self:GetRuneforgeFrame():GetItem() ~= nil;
	local alpha = (not powerSelected and hasItem) and 1 or 0;
	self:GetNormalTexture():SetAlpha(alpha);
	self:GetPushedTexture():SetAlpha(alpha);
end

function RuneforgePowerSlotMixin:SetPowerID(powerID)
	if self:GetPowerID() == powerID then
		return;
	end

	RuneforgePowerButtonMixin.SetPowerID(self, powerID);

	self:GetRuneforgeFrame():TriggerEvent(RuneforgeFrameMixin.Event.PowerSelected, powerID);
	self:UpdateState();
end

function RuneforgePowerSlotMixin:OnBaseItemChanged()
	self:Reset();
	self:UpdateState();
end


RuneforgePowerMixin = {};

function RuneforgePowerMixin:GetPowerList()
	return self:GetParent():GetParent();
end

function RuneforgePowerMixin:SetPowerIndex(powerIndex)
	self.powerIndex = powerIndex;

	local powerID, isSelected = self:GetPowerList():GetPower(powerIndex);
	self:SetPowerID(powerID);
	self.SelectedTexture:SetShown(isSelected);
end

function RuneforgePowerMixin:OnShow()
	self:SetAlpha(self:IsEnabled() and 1.0 or 0.5);
end

function RuneforgePowerMixin:OnClick()
	self:GetPowerList():OnPowerSelected(self.powerIndex);
end


RuneforgePowerListMixin = {};

function RuneforgePowerListMixin:OnLoad()
	ScrollFrame_OnLoad(self);

	self.powerPool = CreateFramePool("BUTTON", self.ScrollChild, "RuneforgePowerTemplate");
end

function RuneforgePowerListMixin:OpenPowerList(powers)
	self.powers = powers;
	self:GeneratePowerFrames();
end

function RuneforgePowerListMixin:GeneratePowerFrames()
	self.powerPool:ReleaseAll();

	local numPowers = self:GetNumPowers();
	local buttonsEnabled = self:GetParent():GetRuneforgeFrame():HasItem();

	local function FactoryFunction(index)
		if index > numPowers then
			return nil;
		end

		local frame = self.powerPool:Acquire();
		frame:SetPowerIndex(index);
		frame:SetEnabled(buttonsEnabled);
		frame:Show();
		return frame;
	end

	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.ScrollChild, "TOPLEFT");
	local totalWidth = self:GetWidth();
	local totalHeight = nil;
	local overrideDirection = nil;
	local overridePadding = -4;
	AnchorUtil.GridLayoutFactory(FactoryFunction, anchor, totalWidth, totalHeight, overrideDirection, overridePadding, overridePadding);
end

function RuneforgePowerListMixin:GetNumPowers()
	return self.powers and #self.powers or 0;
end

function RuneforgePowerListMixin:GetPower(index)
	local powerID = self.powers[index];
	return powerID, self:GetParent():GetPowerID() == powerID;
end

function RuneforgePowerListMixin:OnPowerSelected(index)
	self:GetParent():SelectPowerID(self:GetPower(index));
end


RuneforgePowerFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgePowerFrameMixin:OpenPowerList(powers)
	self.PowerList:OpenPowerList(powers);
end

function RuneforgePowerFrameMixin:SelectPowerID(powerID)
	self:GetRuneforgeFrame():SetPowerID(powerID);
	self:Hide();
end

function RuneforgePowerFrameMixin:GetPowerID()
	return self:GetRuneforgeFrame():GetPowerID();
end
