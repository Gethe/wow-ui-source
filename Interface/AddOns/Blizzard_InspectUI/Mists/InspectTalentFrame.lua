
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
		InspectTalentFrameTalents_OnShow(self.InspectTalents);
		InspectGlyphFrameGlyph_UpdateGlyphs(self.InspectGlyphs, false);
		InspectTalentFrameSpec_OnShow(self.InspectSpec);
	end
	
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		InspectGlyphFrameGlyph_OnClear(self);
	end
end

function InspectTalentFrameMixin:OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
end

InspectGlyphFrameGlyphMixin = {};

function InspectGlyphFrameGlyphMixin:OnClear()
	InspectGlyphFrameGlyph_UpdateGlyphs(self.InspectGlyphs, true);
	InspectTalentFrameSpec_OnClear(self);
	TalentFrame_Clear(self.InspectTalents);
end

--------------------------------------------------------------------------------
------------------  Glyph Button Functions     ---------------------------
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

function InspectGlyphFrameGlyphMixin:OnLoad()
	self.elapsed = 0;
	self.tintElapsed = 0;
	self.glyphType = nil;
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function InspectGlyphFrameGlyph_UpdateGlyphs(self, clearSlots)
	InspectGlyphFrameGlyph_UpdateSlot(self.Glyph1, clearSlots);
	InspectGlyphFrameGlyph_UpdateSlot(self.Glyph2, clearSlots);
	InspectGlyphFrameGlyph_UpdateSlot(self.Glyph3, clearSlots);
	InspectGlyphFrameGlyph_UpdateSlot(self.Glyph4, clearSlots);
	InspectGlyphFrameGlyph_UpdateSlot(self.Glyph5, clearSlots);
	InspectGlyphFrameGlyph_UpdateSlot(self.Glyph6, clearSlots);	
end

function InspectGlyphFrameGlyph_UpdateSlot (self, clear)
	local id = self:GetID();
	local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup;
	local enabled, glyphType, glyphTooltipIndex, glyphSpell, iconFilename, glyphID = GetGlyphSocketInfo(id, talentGroup, true, INSPECTED_UNIT);
	if not glyphType then
		return;
	end
	
	self:SetGlyphType(self, glyphType);

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
			SetPortraitToTexture(self.glyph, iconFilename);
		else
			self.glyph:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune1");
		end
		self:Show();
	end
end

function InspectGlyphFrameGlyphMixin:SetGlyphType (glyph, glyphType)
	local info = INSPECT_GLYPH_TYPE_INFO[glyphType];
	if info then
		glyph.glyphType = glyphType;
		
		glyph.ring:SetWidth(info.ring.size);
		glyph.ring:SetHeight(info.ring.size);
		glyph.ring:SetTexCoord(info.ring.left, info.ring.right, info.ring.top, info.ring.bottom);
		
		glyph.highlight:SetWidth(info.highlight.size);
		glyph.highlight:SetHeight(info.highlight.size);
		glyph.highlight:SetTexCoord(info.highlight.left, info.highlight.right, info.highlight.top, info.highlight.bottom);
		
		glyph.glyph:SetWidth(info.ring.size - 4);
		glyph.glyph:SetHeight(info.ring.size - 4);
	end
end

function InspectGlyphFrameGlyphMixin:OnUpdate(elapsed)
	local id = self:GetID();
	if GlyphMatchesSocket(id) then
		self.highlight:SetAlpha(0.5);
	else
		self.highlight:SetAlpha(0.0);
	end
end

function InspectGlyphFrameGlyphMixin:OnClick()

	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local link = C_PaperDollInfo.GetGlyphLinkByID(self.glyphID);
		if link then
			ChatEdit_InsertLink(link);
		end
	end
end

function InspectGlyphFrameGlyphMixin:OnEnter()
	self.hasCursor = true;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetGlyph(self:GetID(), 1, true, INSPECTED_UNIT);
	GameTooltip:Show();
end

function InspectGlyphFrameGlyphMixin:OnLeave()
	self.hasCursor = nil;
	GameTooltip:Hide();
end

--------------------------------------------------------------------------------
------------------  Specialization Button Functions     ---------------------------
--------------------------------------------------------------------------------
function InspectTalentFrameSpec_OnShow(self)
	local spec = nil;
	if(INSPECTED_UNIT ~= nil) then
		spec = GetInspectSpecialization(INSPECTED_UNIT);
	end
	if(spec ~= nil and spec > 0) then
		local role1 = GetSpecializationRoleByID(spec);
		if(role1 ~= nil) then
			local id, name, description, icon, background = GetSpecializationInfoByID(spec);
			self.specIcon:Show();
			SetPortraitToTexture(self.specIcon, icon);
			self.specName:SetText(name);
			self.roleIcon:Show();
			self.roleName:SetText(_G[role1]);
			self.roleIcon:SetTexCoord(GetTexCoordsForRole(role1));
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

InspectTalentFrameSpecMixin = {};

function InspectTalentFrameSpecMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip:AddLine(self.tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:SetMinimumWidth(300, true);
	GameTooltip:Show();
end

function InspectTalentFrameSpecMixin:OnLeave()
	GameTooltip:SetMinimumWidth(0, 0);
	GameTooltip:Hide();
end

--------------------------------------------------------------------------------
------------------  Talent Button Functions     ---------------------------
--------------------------------------------------------------------------------
function InspectTalentFrameTalents_OnLoad(self)
	self.inspect = true;
end

function InspectTalentFrameTalents_OnShow(self)
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
			ChatEdit_InsertLink(link);
		end
	end
end
