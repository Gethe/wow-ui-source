
ClassTalentFrameMixin = {};

local ClassTalentFrameEvents = {
};

local ClassTalentFrameUnitEvents = {
	"PLAYER_SPECIALIZATION_CHANGED",
};

function ClassTalentFrameMixin:OnLoad()
	TabSystemOwnerMixin.OnLoad(self);
	self:SetTabSystem(self.TabSystem);
	self.specTabID = self:AddNamedTab(TALENT_FRAME_TAB_LABEL_SPEC, self.SpecTab);
	self.talentTabID = self:AddNamedTab(TALENT_FRAME_TAB_LABEL_TALENTS, self.TalentsTab);

	self.CloseButton:SetScript("OnClick", GenerateClosure(self.CheckConfirmClose, self));

	local classFile = PlayerUtil.GetClassFile();
	local left, right, bottom, top = unpack(CLASS_ICON_TCOORDS[string.upper(classFile)]);
	self.PortraitOverlay.Portrait:SetTexCoord(left, right, bottom, top);
end

function ClassTalentFrameMixin:OnShow()
	if not self:GetTab() then
		self:SetTab(PlayerUtil.CanUseClassTalents() and self.talentTabID or self.specTabID);
	end

	FrameUtil.RegisterFrameForEvents(self, ClassTalentFrameEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, ClassTalentFrameUnitEvents, "player");

	self:UpdateTabs();
end

function ClassTalentFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ClassTalentFrameEvents);
	FrameUtil.UnregisterFrameForEvents(self, ClassTalentFrameUnitEvents);
end

function ClassTalentFrameMixin:OnEvent(event)
	if event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdateTabs();
	end
end

function ClassTalentFrameMixin:UpdateTabs()
	local canUseTalents = PlayerUtil.CanUseClassTalents();
	self.TabSystem:SetTabShown(self.talentTabID, canUseTalents);
	if not canUseTalents and (self.talentTabID == self:GetTab())  then
		self:SetTab(self.specTabID);
	end
end

function ClassTalentFrameMixin:CheckConfirmResetAction(callback)
	if (self:GetTab() == self.talentTabID) and self.TalentsTab:HasAnyConfigChanges() then
		local referenceKey = self;
		if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			local customData = {
				text = TALENT_FRAME_CONFIRM_CLOSE,
				callback = callback,
				acceptText = CONTINUE,
				cancelText = CANCEL,
				referenceKey = referenceKey,
			};

			StaticPopup_ShowCustomGenericConfirmation(customData);
		end
	else
		callback();
	end
end

function ClassTalentFrameMixin:SetTab(tabID)
	-- Overrides TabSystemOwnerMixin.SetTab.

	local callback = GenerateClosure(TabSystemOwnerMixin.SetTab, self, tabID);
	self:CheckConfirmResetAction(callback);
	return true; -- Don't show the tab as selected yet.
end

function ClassTalentFrameMixin:CheckConfirmClose()
	-- No need to check before closing anymore.
	HideUIPanel(self);
end