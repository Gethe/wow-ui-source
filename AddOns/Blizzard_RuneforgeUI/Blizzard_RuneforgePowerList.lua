
local RuneforgePowerListRowSize = 4;
local RuneforgePowerListNumRows = 3;


RuneforgePowerButtonMixin = CreateFromMixins(RuneforgePowerBaseMixin);

function RuneforgePowerButtonMixin:OnPowerSet(oldPowerID, powerID)
	local hasPowerID = powerID ~= nil;
	self.Icon:SetShown(hasPowerID);
	if hasPowerID then
		self.Icon:SetTexture(self.powerInfo and self.powerInfo.iconFileID or QUESTION_MARK_ICON);

		local isAvailable = self.powerInfo.state == Enum.RuneforgePowerState.Available;
		local isActive = isAvailable and self:IsSelectionActive();
		self.Icon:SetDesaturated(not isAvailable);
	end
end

function RuneforgePowerButtonMixin:OnEnter()
	local powerInfo = self:GetPowerInfo();
	if powerInfo ~= nil then
		RuneforgePowerBaseMixin.OnEnter(self);
	end
end

function RuneforgePowerButtonMixin:SetSelectionActive(selectionActive)
	self.selectionActive = selectionActive;
end

function RuneforgePowerButtonMixin:IsSelectionActive()
	return self.selectionActive;
end


RuneforgePowerSlotMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgePowerSlotMixin:OnLoad()
	self.Icon:SetPoint("CENTER", -5, 2);
	self.Icon:SetSize(64, 64);

	self:AddEffectData("primary", RuneforgeUtil.Effect.PowerSlotted, RuneforgeUtil.EffectTarget.None);
	self:AddEffectData("chains", RuneforgeUtil.Effect.PowerInChainsEffect, RuneforgeUtil.EffectTarget.ItemSlot);
	self:AddEffectData("chains2", RuneforgeUtil.Effect.PowerOutChainsEffect, RuneforgeUtil.EffectTarget.ReverseItemSlot);
end

function RuneforgePowerSlotMixin:OnShow()
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.OnBaseItemChanged, self);

	self:UpdateState();
end

function RuneforgePowerSlotMixin:OnHide()
	RuneforgePowerButtonMixin.OnHide(self);

	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self);
end

function RuneforgePowerSlotMixin:OnClick(buttonName)
	if buttonName == "RightButton" then
		self:Reset();
	else
		self:GetRuneforgeFrame():TogglePowerList();
	end
end

function RuneforgePowerSlotMixin:IsSelectionActive()
	return self:IsEnabled();
end

function RuneforgePowerSlotMixin:Reset()
	self:SetPowerID(nil);
	self.SelectedTexture:Hide();
end

function RuneforgePowerSlotMixin:UpdateState()
	local powerSelected = self:GetPowerID() ~= nil;
	self.SelectedTexture:SetShown(powerSelected);

	local isUpgrading = self:IsRuneforgeUpgrading();
	local hasItem = self:GetRuneforgeFrame():GetItem() ~= nil;
	local alpha = (not powerSelected and hasItem and not isUpgrading) and 1 or 0;
	self:GetNormalTexture():SetAlpha(alpha);
	self:GetPushedTexture():SetAlpha(alpha);

	local slotAlpha = isUpgrading and 0.35 or 1.0;
	self.SelectedTexture:SetAlpha(slotAlpha);
	self:SetAlpha(slotAlpha);

	self:SetEnabled(not isUpgrading);

	local showEffects = powerSelected and not isUpgrading;
	self:SetEffectShown("primary", showEffects);
	self:SetEffectShown("chains", showEffects);
	self:SetEffectShown("chains2", showEffects);
end

function RuneforgePowerSlotMixin:OnPowerSet(oldPowerID, powerID)
	if oldPowerID == powerID then
		return;
	end

	RuneforgePowerButtonMixin.OnPowerSet(self, oldPowerID, powerID);

	local runeforgeFrame = self:GetRuneforgeFrame();
	runeforgeFrame:TriggerEvent(RuneforgeFrameMixin.Event.PowerSelected, powerID);

	self:UpdateState();

	if oldPowerID == nil then
		runeforgeFrame:FlashRunes();
	end

	if not runeforgeFrame:IsRuneforgeUpgrading() then
		PlaySound(SOUNDKIT.UI_RUNECARVING_SELECT_LEGENDARY_POWER);
	end
end

function RuneforgePowerSlotMixin:OnBaseItemChanged()
	if self:IsRuneforgeCrafting() then
		self:Reset();
		self:UpdateState();
	elseif self:IsRuneforgeUpgrading() then
		local runeforgeFrame = self:GetRuneforgeFrame();
		local item = runeforgeFrame:GetItem();
		if item == nil then
			self:Reset();
			self:UpdateState();
		else
			local info = runeforgeFrame:GetRuneforgeComponentInfo();
			self:SetPowerID(info.powerID);
		end
	end
end


RuneforgePowerMixin = {};

function RuneforgePowerMixin:InitElement(powerList)
	self.powerList = powerList;
end

function RuneforgePowerMixin:GetPowerList()
	return self.powerList;
end

function RuneforgePowerMixin:UpdateDisplay()
	local powerIndex = self:GetListIndex();

	local powerList = self:GetPowerList();
	self:SetSelectionActive(powerList:GetRuneforgeFrame():HasItem());

	local powerID, isSelected = powerList:GetPower(powerIndex);
	self:SetPowerID(powerID);
	self.SelectedTexture:SetShown(isSelected);
end

function RuneforgePowerMixin:IsAvailable()
	return self:GetPowerInfo().state == Enum.RuneforgePowerState.Available;
end

function RuneforgePowerMixin:OnSelected()
	if not RuneforgePowerButtonMixin.OnSelected(self) and self:IsSelectionActive() and self:IsAvailable() then
		self:GetPowerList():OnPowerSelected(self:GetListIndex());
	end
end

function RuneforgePowerMixin:OnPowerSet(oldPowerID, powerID)
	RuneforgePowerButtonMixin.OnPowerSet(self, oldPowerID, powerID);

	local hasPower = powerID ~= nil;
	self.Border:SetShown(hasPower);

	if hasPower then
		local isAvailable = self:IsAvailable();
		self.UnavailableOverlay:SetShown(not isAvailable);

		local isActive = isAvailable and self:IsSelectionActive();
		self:SetAlpha(isActive and 1.0 or 0.5);
	else
		self.UnavailableOverlay:Hide();
	end
end


RuneforgePowerListMixin = {};

function RuneforgePowerListMixin:OnLoad()
	PagedListMixin.OnLoad(self);
	
	self:SetGetNumResultsFunction(GenerateClosure(self.GetNumPowers, self));
	self:SetElementTemplate("RuneforgePowerTemplate", self);
	self:SetRefreshCallback(GenerateClosure(self.OnPowerListRefreshed, self))

	local stride = RuneforgePowerListRowSize;
	local padding = -4;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, padding, padding);
	layout:SetCustomOffsetFunction(GenerateClosure(self.GetCustomOffsetForPower, self));

	local numDisplayedElements = RuneforgePowerListRowSize * RuneforgePowerListNumRows;
	self:SetLayout(layout, numDisplayedElements);
end

function RuneforgePowerListMixin:OnHide()
	self:SetPage(1);
end

function RuneforgePowerListMixin:OpenPowerList(specPowers, offspecPowers)
	self.specPowers = specPowers;
	self.offspecPowers = offspecPowers;
	self.numSpecRows = math.ceil(#self.specPowers / RuneforgePowerListRowSize);

	if #offspecPowers > 0 then
		local numSpecOnlyPages = math.floor(self.numSpecRows / RuneforgePowerListNumRows);
		self.combinedSpecPageIndex = numSpecOnlyPages + 1;
	else
		self.combinedSpecPageIndex = nil;
	end

	self:RefreshListDisplay();
end

function RuneforgePowerListMixin:GetNumSpecRows()
	return self.numSpecRows or 0;
end

function RuneforgePowerListMixin:GetNumPowers()
	if self.specPowers == nil then
		return 0;
	end

	return (self:GetNumSpecRows() * RuneforgePowerListRowSize) + #self.offspecPowers;
end

function RuneforgePowerListMixin:GetPower(index)
	local numSpecElements = self:GetNumSpecRows() * RuneforgePowerListRowSize;
	if index <= numSpecElements then
		return self.specPowers[index];
	else
		return self.offspecPowers[index - numSpecElements];
	end
end

function RuneforgePowerListMixin:OnPowerSelected(index)
	self:GetParent():SelectPowerID(self:GetPower(index));
end

function RuneforgePowerListMixin:OnPowerListRefreshed()
	self:LayoutList();

	local otherSpecRow = self:GetOtherSpecializationRow();
	local hasOtherSpecRow = otherSpecRow ~= nil;
	self.OtherSpecializationsLabel:SetShown(hasOtherSpecRow);
	if hasOtherSpecRow then
		local elementFrame = self:GetElementFrame(otherSpecRow * RuneforgePowerListRowSize);
		self.OtherSpecializationsLabel:SetPoint("BOTTOM", elementFrame, "TOP", 0, 2);
	end
end

function RuneforgePowerListMixin:IsOnCombinedSpecPage()
	return self:GetPage() == self.combinedSpecPageIndex;
end

function RuneforgePowerListMixin:GetOtherSpecializationRow()
	if self:IsOnCombinedSpecPage() then
		return self:GetNumSpecRows() % RuneforgePowerListNumRows + 1;
	end

	return nil;
end

function RuneforgePowerListMixin:GetCustomOffsetForPower(row, col)
	local otherSpecRow = self:GetOtherSpecializationRow();
	if (otherSpecRow ~= nil) and (row >= otherSpecRow) then
		return 0, -30;
	end

	return 0, 0;
end

function RuneforgePowerListMixin:GetRuneforgeFrame()
	return self:GetParent():GetRuneforgeFrame();
end


RuneforgePowerFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgePowerFrameMixin:OnLoad()
	self.PageControl:SetPagedList(self.PowerList);
end

function RuneforgePowerFrameMixin:OnMouseWheel(...)
	self.PowerList:OnMouseWheel(...);
end

function RuneforgePowerFrameMixin:OpenPowerList(specPowers, offspecPowers)
	self.PowerList:OpenPowerList(specPowers, offspecPowers);
end

function RuneforgePowerFrameMixin:SelectPowerID(powerID)
	self:GetRuneforgeFrame():SetPowerID(powerID);
	self:Hide();
end

function RuneforgePowerFrameMixin:GetPowerID()
	return self:GetRuneforgeFrame():GetPowerID();
end
