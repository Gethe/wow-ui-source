
PvPTalentSlotButtonMixin = {};

local SLOT_NEW_STATE_OFF = 1;
local SLOT_NEW_STATE_SHOW_IF_ENABLED = 2;
local SLOT_NEW_STATE_ACKNOWLEDGED = 3;

function PvPTalentSlotButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self.slotNewState = SLOT_NEW_STATE_OFF;
end

function PvPTalentSlotButtonMixin:OnShow()
	self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE");
end

function PvPTalentSlotButtonMixin:OnHide()
	self:UnregisterEvent("PLAYER_PVP_TALENT_UPDATE");
end

function PvPTalentSlotButtonMixin:OnEvent(event)
	if (event == "PLAYER_PVP_TALENT_UPDATE") then
		self.predictedSetting:Clear();
		self:Update();
	end
end

function PvPTalentSlotButtonMixin:GetSelectedTalent()
	return self.predictedSetting:Get();
end

function PvPTalentSlotButtonMixin:SetSelectedTalent(talentID)
	local selectedTalentID = self:GetSelectedTalent();
	if (selectedTalentID and selectedTalentID == talentID) then
		return;
	end
	self.predictedSetting:Set(talentID);
	self:Update();
end

function PvPTalentSlotButtonMixin:SetUp(slotIndex)
	self.slotIndex = slotIndex;
	self.predictedSetting = CreatePredictedSetting(
		{
			["setFunction"] = function(value)
				return LearnPvpTalent(value, slotIndex);
			end, 
			["getFunction"] = function()
				if not self:IsPendingTalentRemoval() then
					local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slotIndex);
					return slotInfo and slotInfo.selectedTalentID;
				end
			end, 
		}
	);
	
	self:Update();
end

function PvPTalentSlotButtonMixin:SetPendingTalentRemoval(isPending)
	self.isPendingRemoval = isPending;
end

function PvPTalentSlotButtonMixin:IsPendingTalentRemoval()
	return self.isPendingRemoval or false;
end

function PvPTalentSlotButtonMixin:Update()
	if (not self.slotIndex) then
		error("Slot must be setup with a slot index first.");
	end

	local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(self.slotIndex);
	self.Texture:Show();
	local selectedTalentID = self:GetSelectedTalent();
	if (selectedTalentID) then
		local _, name, texture = GetPvpTalentInfoByID(selectedTalentID);
		SetPortraitToTexture(self.Texture, texture);
	else
		self.Texture:SetAtlas("pvptalents-talentborder-empty");
	end

	local showNewLabel = false;
	if (slotInfo and slotInfo.enabled) then
		self.Border:SetAtlas("pvptalents-talentborder");
		self:Enable();
		showNewLabel = self.slotNewState == SLOT_NEW_STATE_SHOW_IF_ENABLED;
	else
		self.Border:SetAtlas("pvptalents-talentborder-locked");
		self:Disable();
		self.Texture:Hide();
		if slotInfo and not slotInfo.enabled and self.slotNewState == SLOT_NEW_STATE_OFF then
			if UnitLevel("player") < slotInfo.level then
				self.slotNewState = SLOT_NEW_STATE_SHOW_IF_ENABLED;
			end
		end
	end
	self.New:SetShown(showNewLabel);
	self.NewGlow:SetShown(showNewLabel);
end

function PvPTalentSlotButtonMixin:OnEnter()
	local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(self.slotIndex);
	if not slotInfo then
		return;
	end

	if (self.slotNewState == SLOT_NEW_STATE_SHOW_IF_ENABLED and slotInfo.enabled) then
		self.slotNewState = SLOT_NEW_STATE_ACKNOWLEDGED;
		self.New:Hide();
		self.NewGlow:Hide();
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local selectedTalentID = self:GetSelectedTalent();
	if (selectedTalentID) then
		GameTooltip:SetPvpTalent(selectedTalentID, false, GetActiveSpecGroup(true), self.slotIndex);
	else
		GameTooltip:SetText(PVP_TALENT_SLOT);
		if (not slotInfo.enabled) then
			GameTooltip:AddLine(PVP_TALENT_SLOT_LOCKED:format(C_SpecializationInfo.GetPvpTalentSlotUnlockLevel(self.slotIndex)), RED_FONT_COLOR:GetRGB());
		else
			GameTooltip:AddLine(PVP_TALENT_SLOT_EMPTY, GREEN_FONT_COLOR:GetRGB());
		end
	end

	GameTooltip:Show();
end

function PvPTalentSlotButtonMixin:OnClick()
	local selectedTalentID = self:GetSelectedTalent();
	if (IsModifiedClick("CHATLINK") and selectedTalentID) then
		local _, name = GetPvpTalentInfoByID(selectedTalentID);
		local link = GetPvpTalentLink(selectedTalentID);
		HandleGeneralTalentFrameChatLink(self, name, link);
		return;
	end
	self:GetParent():SelectSlot(self);
end

function PvPTalentSlotButtonMixin:OnDragStart()
	if (not self.isInspect) then
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(self.slotIndex);
		if slotInfo and slotInfo.selectedTalentID then
			local predictedTalentID = self:GetSelectedTalent();
			if (not predictedTalentID or predictedTalentID == slotInfo.selectedTalentID) then
				PickupPvpTalent(slotInfo.selectedTalentID);
			end
		end
	end
end


PvPTalentSlotTrayMixin = {};

local PvPTalentSlotTrayEvents = {
	"PLAYER_PVP_TALENT_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"WAR_MODE_STATUS_UPDATE",
};

local PvPTalentSlotTrayUnitEvents = {
	"PLAYER_SPECIALIZATION_CHANGED",
};

function PvPTalentSlotTrayMixin:OnLoad()
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
	for i, slot in ipairs(self.Slots) do
		slot:SetUp(i);
	end
end

function PvPTalentSlotTrayMixin:OnEvent(event, ...)
	if event == "PLAYER_PVP_TALENT_UPDATE" then
		self:ClearPendingRemoval();
		self:Update();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:Update();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:Update();
	elseif event == "WAR_MODE_STATUS_UPDATE" then
		self:Update();
	elseif event == "PLAYER_LEVEL_CHANGED" then
		self:Update();
	end
end

function PvPTalentSlotTrayMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, PvPTalentSlotTrayEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, PvPTalentSlotTrayUnitEvents, "player");

	self:Update();
end

function PvPTalentSlotTrayMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, PvPTalentSlotTrayEvents);
	FrameUtil.UnregisterFrameForEvents(self, PvPTalentSlotTrayUnitEvents);

	self:UnselectSlot();
end

function PvPTalentSlotTrayMixin:SetTalentFrame(talentFrame)
	if self.talentFrame or not talentFrame then
		return;
	end

	self.talentFrame = talentFrame;

	self:AddDynamicEventMethod(talentFrame, ClassTalentTalentsTabMixin.Event.PvPTalentListClosed, self.OnPvPTalentListClosed);
	self:AddDynamicEventMethod(talentFrame, ClassTalentTalentsTabMixin.Event.SelectTalentIDForSlot, self.OnSelectTalentIDForSlot);
end

function PvPTalentSlotTrayMixin:OnPvPTalentListClosed()
	self:ClearSlotSelection();
end

function PvPTalentSlotTrayMixin:OnSelectTalentIDForSlot(talentID, slotIndex)
	self:SelectTalentForSlot(talentID, slotIndex);
end

function PvPTalentSlotTrayMixin:GetTalentFrame()
	return self.talentFrame;
end

function PvPTalentSlotTrayMixin:ClearPendingRemoval()
	for slotIndex = 1, #self.Slots do
		local slot = self.Slots[slotIndex];
		slot:SetPendingTalentRemoval(false);
		slot:Update();
	end
end

function PvPTalentSlotTrayMixin:Update()
	-- TODO:: Check C_SpecializationInfo.CanPlayerUsePVPTalentUI()

	for _, slot in pairs(self.Slots) do
		slot:Update();
	end
end

function PvPTalentSlotTrayMixin:SelectSlot(slot)
	local talentFrame = self:GetTalentFrame();
	if not talentFrame then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (self.selectedSlotIndex) then
		local sameSelected = self.selectedSlotIndex == slot.slotIndex;
		self:UnselectSlot();
		if (sameSelected) then
			return;
		end
	end

	self.selectedSlotIndex = slot.slotIndex;
	slot.Arrow:Show();

	talentFrame:TriggerEvent(ClassTalentTalentsTabMixin.Event.OpenPvPTalentList, self.selectedSlotIndex);
end

function PvPTalentSlotTrayMixin:UnselectSlot()
	if not self:ClearSlotSelection() then
		return;
	end

	local talentFrame = self:GetTalentFrame();
	if not talentFrame then
		return;
	end

	talentFrame:TriggerEvent(ClassTalentTalentsTabMixin.Event.ClosePvPTalentList);
end

function PvPTalentSlotTrayMixin:ClearSlotSelection()
	if (not self.selectedSlotIndex) then
		return false;
	end

	local slot = self.Slots[self.selectedSlotIndex];

	slot.Arrow:Hide();
	self.selectedSlotIndex = nil;
	return true;
end

function PvPTalentSlotTrayMixin:SelectTalentForSlot(talentID, slotIndex)
	local slot = self.Slots[slotIndex];

	if (not slot or slot:GetSelectedTalent() == talentID) then
		return;
	end

	for existingSlotIndex = 1, #self.Slots do
		local existingSlot = self.Slots[existingSlotIndex];
		if existingSlot:GetSelectedTalent() == talentID then
			existingSlot:SetPendingTalentRemoval(true);
			break;
		end
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	slot:SetSelectedTalent(talentID);
	self:UnselectSlot();
end
