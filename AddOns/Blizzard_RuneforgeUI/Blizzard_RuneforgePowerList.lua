
RuneforgePowerButtonMixin = {};

function RuneforgePowerButtonMixin:SetPowerID(powerID)
	self.powerID = powerID;

	-- TODO:: Change visuals
	if not powerID then
		self.Background:SetColorTexture(0, 0, 0, 0.4);
	elseif powerID % 3 == 0 then
		self.Background:SetColorTexture(1, 0, 0, 0.4);
	elseif powerID % 3 == 1 then
		self.Background:SetColorTexture(0, 1, 0, 0.4);
	elseif powerID % 3 == 2 then
		self.Background:SetColorTexture(0, 0, 1, 0.4);
	end

	self.powerInfo = powerID and C_LegendaryCrafting.GetRuneforgePowerInfo(powerID) or nil;

	if powerID then
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
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

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

function RuneforgePowerSlotMixin:OnShow()
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.PowerSelected, self.OnPowerSelected, self);
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.OnBaseItemChanged, self);
end

function RuneforgePowerSlotMixin:OnHide()
	RuneforgePowerButtonMixin.OnHide(self);

	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.PowerSelected, self);
	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self);
end

function RuneforgePowerSlotMixin:OnClick()
	self:GetRuneforgeFrame():TogglePowerList();
end

function RuneforgePowerSlotMixin:Reset()
	self:SetPowerID(nil);
end

function RuneforgePowerSlotMixin:OnPowerSelected(powerID)
	self:SetPowerID(powerID);
end

function RuneforgePowerSlotMixin:OnBaseItemChanged()
	self:Reset();
end

RuneforgePowerMixin = {};

function RuneforgePowerMixin:GetPowerList()
	return self:GetParent():GetParent();
end

function RuneforgePowerMixin:SetPowerIndex(powerIndex)
	self.powerIndex = powerIndex;

	local powerID = self:GetPowerList():GetPower(powerIndex);
	self:SetPowerID(powerID);
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
	local overridePadding = 10;
	AnchorUtil.GridLayoutFactory(FactoryFunction, anchor, totalWidth, totalHeight, overrideDirection, overridePadding, overridePadding);
end

function RuneforgePowerListMixin:GetNumPowers()
	return self.powers and #self.powers or 0;
end

function RuneforgePowerListMixin:GetPower(index)
	return self.powers[index];
end

function RuneforgePowerListMixin:OnPowerSelected(index)
	self:GetParent():SelectPowerID(self:GetPower(index));
end


RuneforgePowerFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgePowerFrameMixin:OpenPowerList(powers)
	self.PowerList:OpenPowerList(powers);
end

function RuneforgePowerFrameMixin:SelectPowerID(powerID)
	self:GetRuneforgeFrame():TriggerEvent(RuneforgeFrameMixin.Event.PowerSelected, powerID);
	self:Hide();
end

function RuneforgePowerFrameMixin:GetPowerID()
	return self:GetRuneforgeFrame():GetPowerID();
end
