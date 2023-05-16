
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

	self:SetFrameLevelsFromBaseLevel(5000);

	self:UpdatePortrait();
end

function ClassTalentFrameMixin:OnShow()
	TalentMicroButton:EvaluateAlertVisibility();

	if not self:GetTab() then
		self:SetTab(PlayerUtil.CanUseClassTalents() and self.talentTabID or self.specTabID);
	end

	FrameUtil.RegisterFrameForEvents(self, ClassTalentFrameEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, ClassTalentFrameUnitEvents, "player");

	self:UpdateTabs();

	MultiActionBar_ShowAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_SPELLCOLLECTION);
	UpdateMicroButtons();
	EventRegistry:TriggerEvent("TalentFrame.OpenFrame");
	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);
end

function ClassTalentFrameMixin:OnHide()
	TalentMicroButton:EvaluateAlertVisibility();

	FrameUtil.UnregisterFrameForEvents(self, ClassTalentFrameEvents);
	FrameUtil.UnregisterFrameForEvents(self, ClassTalentFrameUnitEvents);

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);

	if self:IsInspecting() and not self.lockInspect then
		ClearInspectPlayer();
	end

	MultiActionBar_HideAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_SPELLCOLLECTION);
	UpdateMicroButtons();
	self.lockInspect = false;
end

function ClassTalentFrameMixin:OnEvent(event)
	if event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdateTabs();
		self:UpdatePortrait();
	end
end

function ClassTalentFrameMixin:GetTalentsTabButton()
	return self:GetTabButton(self.talentTabID);
end

function ClassTalentFrameMixin:UpdateTabs()
	local isInspecting = self:IsInspecting();
	self.TabSystem:SetTabShown(self.specTabID, not isInspecting);
	if self:IsInspecting() then
		self.TabSystem:SetTabShown(self.talentTabID, false);
	else
		local canUseTalents = PlayerUtil.CanUseClassTalents();
		self.TabSystem:SetTabShown(self.talentTabID, canUseTalents);
		if not canUseTalents and (self.talentTabID == self:GetTab())  then
			self:SetTab(self.specTabID);
		end
	end
end

function ClassTalentFrameMixin:CheckConfirmResetAction(callback, cancelCallback)
	if (self:GetTab() == self.talentTabID) and self.TalentsTab:HasAnyConfigChanges() then
		local referenceKey = self;
		if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			local customData = {
				text = TALENT_FRAME_CONFIRM_CLOSE,
				callback = callback,
				cancelCallback = cancelCallback,
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

function ClassTalentFrameMixin:UpdateFrameTitle()
	local tabID = self:GetTab();
	if self:IsInspecting() then
		local inspectUnit = self:GetInspectUnit();
		if inspectUnit then
			self:SetTitle(TALENTS_INSPECT_FORMAT:format(UnitName(self:GetInspectUnit())));
		else
			self:SetTitle(TALENTS_LINK_FORMAT:format(self:GetSpecName(), self:GetClassName()));
		end
	elseif tabID == self.specTabID then
		self:SetTitle(SPECIALIZATION);
	else -- tabID == self.talentTabID
		self:SetTitle(TALENTS);
	end
end

function ClassTalentFrameMixin:SetTab(tabID)
	TabSystemOwnerMixin.SetTab(self, tabID);

	self:UpdateFrameTitle();
	EventRegistry:TriggerEvent("ClassTalentFrame.TabSet", ClassTalentFrame, tabID);
	return true; -- Don't show the tab as selected yet.
end

function ClassTalentFrameMixin:LockInspect()
	if self:IsInspecting() then
		self.lockInspect = true;
	end
end

function ClassTalentFrameMixin:SetInspectUnit(inspectUnit)
	local inspectString = nil;
	local inspectStringLevel = nil;
	self:SetInspecting(inspectUnit, inspectString, inspectStringLevel);
end

function ClassTalentFrameMixin:SetInspectString(inspectString, inspectStringLevel)
	local inspectUnit = nil;
	self:SetInspecting(inspectUnit, inspectString, inspectStringLevel);
end

function ClassTalentFrameMixin:SetInspecting(inspectUnit, inspectString, inspectStringLevel)
	self.inspectUnit = inspectUnit;
	self.inspectString = inspectString;

	if inspectString then
		local success, specID = self.TalentsTab:ViewLoadout(inspectString, inspectStringLevel);
		if not success then
			self:SetInspecting(nil, nil, nil);
			return;
		end

		self.inspectStringSpecID = specID;
		self.inspectStringClassID = C_SpecializationInfo.GetClassIDFromSpecID(specID);
	else
		self.inspectStringSpecID = nil;
		self.inspectStringClassID = nil;
	end

	self:UpdateTabs();
	self.TalentsTab:UpdateInspecting();

	if inspectUnit or inspectString then
		self:SetTab(self.talentTabID);
	else
		self:UpdateFrameTitle();
	end

	self:UpdatePortrait();
end

function ClassTalentFrameMixin:IsInspecting()
	return (self.inspectUnit ~= nil) or (self.inspectString ~= nil);
end

function ClassTalentFrameMixin:GetInspectUnit()
	return self.inspectUnit;
end

function ClassTalentFrameMixin:GetInspectString()
	return self.inspectString, self.inspectStringClassID, self.inspectStringSpecID;
end

function ClassTalentFrameMixin:GetClassID()
	if self:IsInspecting() then
		local inspectUnit = self:GetInspectUnit();
		if inspectUnit then
			return select(3, UnitClass(inspectUnit));
		else
			return select(2, self:GetInspectString());
		end
	end

	return PlayerUtil.GetClassID();
end

function ClassTalentFrameMixin:GetSpecID()
	if self:IsInspecting() then
		local inspectUnit = self:GetInspectUnit();
		if inspectUnit then
			return GetInspectSpecialization(inspectUnit);
		else
			return select(3, self:GetInspectString());
		end
	end

	return PlayerUtil.GetCurrentSpecID();
end

function ClassTalentFrameMixin:GetUnitSex()
	-- If we're inspecting via string, use the player's sex.
	local unit = (self:IsInspecting() and self:GetInspectUnit()) or "player";
	return UnitSex(unit);
end

function ClassTalentFrameMixin:GetClassName()
	if self:IsInspecting() then
		local inspectUnit = self:GetInspectUnit();
		if inspectUnit then
			local className = UnitClass(inspectUnit);
			return className;
		else
			local classID = select(2, self:GetInspectString());
			local classInfo = C_CreatureInfo.GetClassInfo(classID);
			return classInfo.className;
		end
	end

	return PlayerUtil.GetClassName();
end

function ClassTalentFrameMixin:GetSpecName()
	local unitSex = self:GetUnitSex();
	local specID = self:GetSpecID();
	return select(2, GetSpecializationInfoByID(specID, unitSex));
end

function ClassTalentFrameMixin:CheckConfirmClose()
	-- No need to check before closing anymore.
	HideUIPanel(self);
	EventRegistry:TriggerEvent("TalentFrame.CloseFrame");
end

function ClassTalentFrameMixin:UpdatePortrait()
	local specID = self:GetSpecID();
	local specIcon = specID and PlayerUtil.GetSpecIconBySpecID(specID, self:GetInspectUnit() or "player") or nil;
	if specIcon then
		self:SetPortraitTexCoord(0, 1, 0, 1);
		self:SetPortraitToAsset(specIcon);
	else
		local classID = self:GetClassID();
		self:SetPortraitToClassIcon(C_CreatureInfo.GetClassInfo(classID).classFile);
	end
end
