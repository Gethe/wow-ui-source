
function InspectTalentFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_READY");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function InspectTalentFrame_OnEvent(self, event, unit)
	if ( not InspectFrame:IsShown() ) then
		return;
	end

	if (event == "INSPECT_READY" and InspectFrame.unit and (UnitGUID(InspectFrame.unit) == unit)) then
		InspectTalentFrameTalents_OnShow(self.InspectTalents);
		InspectTalentFrameSpec_OnShow(self.InspectSpec);
	end
end

function InspectTalentFrame_OnShow(self)
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
end

--------------------------------------------------------------------------------
------------------  Specialization Button Functions     ---------------------------
--------------------------------------------------------------------------------
function InspectTalentFrameSpec_OnShow(self)
	local spec = nil;
	local sex = nil;
	if(INSPECTED_UNIT ~= nil) then
		spec = GetInspectSpecialization(INSPECTED_UNIT);
		sex = UnitSex(INSPECTED_UNIT);
	end
	if(spec ~= nil and spec > 0 and sex ~= nil) then
		local role1 = GetSpecializationRoleByID(spec);
		if(role1 ~= nil) then
			local id, name, description, icon = GetSpecializationInfoByID(spec, sex);
			self.specIcon:Show();
			SetPortraitToTexture(self.specIcon, icon);
			self.specName:SetText(name);
			self.roleIcon:Show();
			self.roleName:SetText(_G[role1]);
			local showDisabled = false;
			self.roleIcon:SetAtlas(GetIconForRole(role1, showDisabled), TextureKitConstants.IgnoreAtlasSize);
			self.tooltip = description;
		end
	else
		InspectTalentFrameSpec_OnClear(self);
	end
end

function InspectTalentFrameSpec_OnClear(self)
	self.specName:SetText("");
	self.specIcon:Hide();
	self.roleName:SetText("");
	self.roleIcon:Hide();
end

function InspectTalentFrameSpec_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 28, -18);
	GameTooltip:AddLine(self.tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:SetMinimumWidth(300, true);
	GameTooltip:Show();
end

function InspectTalentFrameSpec_OnLeave(self)
	GameTooltip:SetMinimumWidth(0, false);
	GameTooltip:Hide();
end

--------------------------------------------------------------------------------
------------------  Talent Button Functions     ---------------------------
--------------------------------------------------------------------------------
function InspectTalentFrameTalents_OnLoad(self)
	self.inspect = true;
end

function InspectTalentFrameTalents_OnShow(self)
	self.talentGroup = GetActiveSpecGroup(true);
	TalentFrame_Update(self, INSPECTED_UNIT);
end

function InspectTalentFrameTalent_OnEnter(self)
	local classDisplayName, class, classID = UnitClass(INSPECTED_UNIT);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	
	GameTooltip:SetTalent(self:GetID(),true, self.talentGroup, INSPECTED_UNIT, classID);
end

function InspectTalentFrameTalent_OnClick(self)
	if ( IsModifiedClick("CHATLINK") ) then
		local _, _, classID = UnitClass(INSPECTED_UNIT);
		ChatEdit_InsertLink(GetTalentLink(self:GetID()));
	end
end
