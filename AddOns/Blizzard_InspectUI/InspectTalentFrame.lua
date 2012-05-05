
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

function InspectGlyphFrameGlyph_OnLoad (self)
	self.elapsed = 0;
	self.tintElapsed = 0;
	self.glyphType = nil;
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end


function InspectGlyphFrameGlyph_UpdateSlot (self)
	local id = self:GetID();
	local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup;
	local enabled, glyphType, glyphTooltipIndex, glyphSpell, iconFilename = GetGlyphSocketInfo(id, talentGroup, true, inspectedUnit);
	if not glyphType then
		return;
	end
	
	InspectGlyphFrameGlyph_SetGlyphType(self, glyphType);

	self.elapsed = 0;
	self.tintElapsed = 0;

	local slotAnimation = slotAnimations[id];
	local _, _, _, offsetX, offsetY = self:GetPoint();
	slotAnimation.xStop = offsetX;-- (self:GetWidth()/2.0);
	slotAnimation.yStop = offsetY;-- (self:GetHeight()/2.0);
	
	
	if ( not enabled ) then
		slotAnimation.glyph = nil;
		self:Hide();
	elseif ( not glyphSpell ) then
		slotAnimation.glyph = nil;
		self.spell = nil;
		self.glyph:SetTexture("");
		self:Show();
	else
		slotAnimation.glyph = true;
		self.spell = glyphSpell;
		self.glyph:Show();
		if ( iconFilename ) then
			SetPortraitToTexture(self.glyph, iconFilename);
		else
			self.glyph:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune1");
		end
		self:Show();
	end
end


function InspectGlyphFrameGlyph_SetGlyphType (glyph, glyphType)
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
		glyph.glyph:SetAlpha(0.75);
	end
end


function InspectGlyphFrameGlyph_OnUpdate (self, elapsed)
	local id = self:GetID();
	if GlyphMatchesSocket(id) then
		self.highlight:SetAlpha(0.5);
		self.glow:Play();
	else
		self.highlight:SetAlpha(0.0);
		self.glow:Stop();
	end
end


function InspectGlyphFrameGlyph_OnClick (self, button)
	local id = self:GetID();
	local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup;
	local _, _, _, glyphSpell = GetGlyphSocketInfo(id, talentGroup);

	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local link = GetGlyphLink(id, talentGroup);
		if link then
			ChatEdit_InsertLink(link);
		end
	elseif talentGroup == GetActiveSpecGroup()  then
		if button == "RightButton" then
			local glyphName;
			if ( glyphSpell ) then
				glyphName = GetSpellInfo(glyphSpell);
				local dialog = StaticPopup_Show("CONFIRM_REMOVE_GLYPH", nil, nil, {name = glyphName, id = id});
			end
		elseif  GlyphMatchesSocket(id)  then
			if glyphSpell then
				local dialog = StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", nil, nil, id);
			else
				PlaceGlyphInSocket(id);
			end
		end
	end
end


function InspectGlyphFrameGlyph_OnEnter (self)
	self.hasCursor = true;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetGlyph(self:GetID(), 1, true, inspectedUnit);
	GameTooltip:Show();
end


function InspectGlyphFrameGlyph_OnLeave (self)
	self.hasCursor = nil;
	GameTooltip:Hide();
end


function InspectGlyphFrameHeader_OnClick (self, button)
	ToggleGlyphFilter(self.filter);
	GlyphFrame_UpdateGlyphList ();
end


function InspectGlyphFrameSpell_OnClick (self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local _, _, _, _, _, link = GetGlyphInfo(self.glyphIndex);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	else
		if self.disabledBG:IsShown() then
			return;
		end
		CastGlyph(self.glyphIndex);
	end
end

--------------------------------------------------------------------------------
------------------  Specialization Button Functions     ---------------------------
--------------------------------------------------------------------------------
function InspectTalentFrameSpec_OnShow(self)
	local spec = nil;
	if(inspectedUnit ~= nil) then
		spec = GetInspectSpecialization(inspectedUnit);
	end
	
	if(spec ~= nil and spec > 0) then
		local id, name, description, icon, background = GetSpecializationInfoByID(spec);
		SetPortraitToTexture(self.specIcon, icon);
		self.specName:SetText(name);
		local role1 = GetSpecializationRoleByID(spec);
		self.roleName:SetText(_G[role1]);
		self.roleIcon:SetTexCoord(GetTexCoordsForRole(role1));
		self.tooltip = description;
	else
		self.specName:SetText("");
		self.specIcon:SetTexCoord(0,0,0,0);
		self.roleName:SetText("");
		self.roleIcon:SetTexCoord(0,0,0,0);
	end
end

function InspectTalentFrameSpec_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip:AddLine(self.tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:SetMinimumWidth(300, true);
	GameTooltip:Show();
end

function InspectTalentFrameSpec_OnLeave(self)
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
	TalentFrame_Update(self);
end

function InspectTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	
	GameTooltip:SetTalent(self:GetID(),
		true, self.talentGroup);
end

