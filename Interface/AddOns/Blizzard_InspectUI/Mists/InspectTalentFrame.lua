InspectTalentFrameMixin = {};

function InspectTalentFrameMixin:OnLoad()
	self:RegisterEvent("INSPECT_READY");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function InspectTalentFrameMixin:OnEvent(event, unit)
	if ( not InspectFrame:IsShown() ) then
		return;
	end

	if (event == "INSPECT_READY" and InspectFrame.unit and (UnitGUID(InspectFrame.unit) == unit)) then
		self.InspectTalents:OnShow();
		self.InspectGlyphs:UpdateGlyphs(false);
		self.InspectSpec:OnShow();
	end
	
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self:OnClear();
	end
end

function InspectTalentFrameMixin:OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
end

function InspectTalentFrameMixin:OnClear()
	self.InspectGlyphs:UpdateGlyphs(true);
	self.InspectSpec:OnClear();
	TalentFrame_Clear(self.InspectTalents);
end

--------------------------------------------------------------------------------
------------------  Glyph Button Functions     ---------------------------------
--------------------------------------------------------------------------------
INSPECT_GLYPH_TYPE_INFO = {};
INSPECT_GLYPH_TYPE_INFO[GLYPH_TYPE_MAJOR] =  {
	ring = { size = 60, left = 0.00390625, right = 0.33203125, top = 0.27539063, bottom = 0.43945313 };
	highlight = { size = 98, left = 0.54296875, right = 0.92578125, top = 0.00195313, bottom = 0.19335938 };
}
INSPECT_GLYPH_TYPE_INFO[GLYPH_TYPE_MINOR] =  {
	ring = { size = 46, left = 0.33984375, right = 0.60546875, top = 0.27539063, bottom = 0.40820313 };
	highlight = { size = 82, left = 0.61328125, right = 0.93359375, top = 0.27539063, bottom = 0.43554688 };
}

InspectGlyphsMixin = {};

function InspectGlyphsMixin:UpdateGlyphs(clearSlots)
	self.Glyph1:UpdateSlot(clearSlots);
	self.Glyph2:UpdateSlot(clearSlots);
	self.Glyph3:UpdateSlot(clearSlots);
	self.Glyph4:UpdateSlot(clearSlots);
	self.Glyph5:UpdateSlot(clearSlots);
	self.Glyph6:UpdateSlot(clearSlots);	
end

InspectGlyphMixin = {};

function InspectGlyphMixin:OnLoad()
	self.elapsed = 0;
	self.tintElapsed = 0;
	self.glyphType = nil;
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function InspectGlyphMixin:OnShow()
	self:UpdateSlot(false);
end

function InspectGlyphMixin:OnClick()
	if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
		if self.glyphID then
			local glyphSlotIndex = self:GetID();
			local link = C_GlyphInfo.GetGlyphLink(glyphSlotIndex, self.glyphID);
			if link then
				ChatEdit_InsertLink(link);
			end
		end
	end
end

function InspectGlyphMixin:OnEnter()
	self.hasCursor = true;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetGlyph(self:GetID(), 1, true, INSPECTED_UNIT);
	GameTooltip:Show();
end

function InspectGlyphMixin:OnLeave()
	self.hasCursor = nil;
	GameTooltip:Hide();
end

function InspectGlyphMixin:OnUpdate(elapsed)
	local id = self:GetID();
	if GlyphMatchesSocket(id) then
		self.highlight:SetAlpha(0.5);
	else
		self.highlight:SetAlpha(0.0);
	end
end

function InspectGlyphMixin:UpdateSlot(clear)
	local id = self:GetID();
	local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup;
	local enabled, glyphType, glyphTooltipIndex, glyphSpell, iconFilename, glyphID = GetGlyphSocketInfo(id, talentGroup, true, INSPECTED_UNIT);
	if not glyphType then
		return;
	end
	
	self:SetGlyphType(glyphType);

	self.elapsed = 0;
	self.tintElapsed = 0;
	
	if ( not enabled ) then
		self:Hide();
	elseif (not glyphSpell or clear) then
		self.glyphID = nil;
		self.glyph:SetTexture("");
		self:Show();
	else
		self.glyphID = glyphID;
		if ( iconFilename ) then
			self.glyph:SetTexture(iconFilename);
		else
			self.glyph:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune1");
		end
		self:Show();
	end
end

function InspectGlyphMixin:SetGlyphType(glyphType)
	local info = INSPECT_GLYPH_TYPE_INFO[glyphType];
	if info then
		self.glyphType = glyphType;
		
		self.ring:SetWidth(info.ring.size);
		self.ring:SetHeight(info.ring.size);
		self.ring:SetTexCoord(info.ring.left, info.ring.right, info.ring.top, info.ring.bottom);
		
		self.highlight:SetWidth(info.highlight.size);
		self.highlight:SetHeight(info.highlight.size);
		self.highlight:SetTexCoord(info.highlight.left, info.highlight.right, info.highlight.top, info.highlight.bottom);
		
		self.glyph:SetWidth(info.ring.size - 4);
		self.glyph:SetHeight(info.ring.size - 4);
	end
end

--------------------------------------------------------------------------------
------------------  Specialization Button Functions     ------------------------
--------------------------------------------------------------------------------

InspectSpecMixin = {};

function InspectSpecMixin:OnShow()
	local spec = nil;
	if(INSPECTED_UNIT ~= nil) then
		spec = GetInspectSpecialization(INSPECTED_UNIT);
	end
	if(spec ~= nil and spec > 0) then
		local role1 = GetSpecializationRoleByID(spec);
		if(role1 ~= nil) then
			local id, name, description, icon, background = GetSpecializationInfoByID(spec);
			self.specIcon:Show();
			self.specIcon:SetTexture(icon);
			self.specName:SetText(name);
			self.roleIcon:Show();
			self.roleName:SetText(_G[role1]);
			self.roleIcon:SetTexCoord(GetTexCoordsForRole(role1));
			self.tooltip = description;
		end
	else
		self.InspectSpec:OnClear();
	end
end

function InspectSpecMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip:AddLine(self.tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:SetMinimumWidth(300, true);
	GameTooltip:Show();
end

function InspectSpecMixin:OnLeave()
	GameTooltip:SetMinimumWidth(0, 0);
	GameTooltip:SetMinimumWidth(0, false);
	GameTooltip:Hide();
end

function InspectSpecMixin:OnClear()
	self.specName:SetText("");
	self.specIcon:Hide();
	self.roleName:SetText("");
	self.roleIcon:Hide();
end

--------------------------------------------------------------------------------
------------------  Talent Button Functions     --------------------------------
--------------------------------------------------------------------------------

InspectTalentsMixin = {};

function InspectTalentsMixin:OnLoad()
	self.inspect = true;
end

function InspectTalentsMixin:OnShow()
	TalentFrame_Update(self, INSPECTED_UNIT);
end

InspectTalentButtonMixin = {};

function InspectTalentButtonMixin:OnEnter()
	local classDisplayName, class, classID = UnitClass(INSPECTED_UNIT);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	
	GameTooltip:SetTalent(self:GetID(), true, self.talentGroup, INSPECTED_UNIT, classID);
end

function InspectTalentButtonMixin:OnClick()
	if ( IsModifiedClick("CHATLINK") ) then
		local _, _, classID = UnitClass(INSPECTED_UNIT);
		local link = GetTalentLink(self:GetID(), InspectTalentFrame.InspectTalents.inspect, classID);
		if ( link ) then
			ChatFrameUtil.InsertLink(link);
		end
	end
end
