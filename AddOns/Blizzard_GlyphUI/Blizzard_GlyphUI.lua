GLYPHTYPE_MAJOR = 1;
GLYPHTYPE_MINOR = 2;

GLYPH_MINOR = { r = 0, g = 0.25, b = 1};
GLYPH_MAJOR = { r = 1, g = 0.25, b = 0};

GLYPH_SLOTS = {};
-- Empty Texture
GLYPH_SLOTS[0] = { left = 0.78125, right = 0.91015625, top = 0.69921875, bottom = 0.828125 };
-- Major Glyphs
GLYPH_SLOTS[3] = { left = 0.392578125, right = 0.521484375, top = 0.87109375, bottom = 1 };
GLYPH_SLOTS[1] = { left = 0, right = 0.12890625, top = 0.87109375, bottom = 1 };
GLYPH_SLOTS[5] = { left = 0.26171875, right = 0.390625, top = 0.87109375, bottom = 1 };
-- Minor Glyphs
GLYPH_SLOTS[2] = { left = 0.130859375, right = 0.259765625, top = 0.87109375, bottom = 1 };
GLYPH_SLOTS[6] = { left = 0.654296875, right = 0.783203125, top = 0.87109375, bottom = 1 };
GLYPH_SLOTS[4] = { left = 0.5234375, right = 0.65234375, top = 0.87109375, bottom = 1 };

NUM_GLYPH_SLOTS = 6;

local slotAnimations = {};
local TOPLEFT, TOP, TOPRIGHT, BOTTOMRIGHT, BOTTOM, BOTTOMLEFT = 3, 1, 5, 4, 2, 6;
slotAnimations[TOPLEFT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -85, ["yStart"] = 17, ["yStop"] = 60};
slotAnimations[TOP] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -13, ["yStart"] = 17, ["yStop"] = 100};
slotAnimations[TOPRIGHT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = 59, ["yStart"] = 17, ["yStop"] = 60};
slotAnimations[BOTTOM] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -13, ["yStart"] = 17, ["yStop"] = -64};
slotAnimations[BOTTOMLEFT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -87, ["yStart"] = 18, ["yStop"] = -27};
slotAnimations[BOTTOMRIGHT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = 61, ["yStart"] = 18, ["yStop"] = -27};

local HIGHLIGHT_BASEALPHA = .4;


function GlyphFrame_Toggle ()
	TalentFrame_LoadUI();
	if ( PlayerTalentFrame_ToggleGlyphFrame ) then
		PlayerTalentFrame_ToggleGlyphFrame(GetActiveTalentGroup());
	end
end

function GlyphFrame_Open ()
	TalentFrame_LoadUI();
	if ( PlayerTalentFrame_OpenGlyphFrame ) then
		PlayerTalentFrame_OpenGlyphFrame(GetActiveTalentGroup());
	end
end


function GlyphFrameGlyph_OnLoad (self)
	local name = self:GetName();
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self.glyph = _G[name .. "Glyph"];
	self.setting = _G[name .. "Setting"];
	self.highlight = _G[name .. "Highlight"];
	self.background = _G[name .. "Background"];
	self.ring = _G[name .. "Ring"];
	self.shine = _G[name .. "Shine"];
	self.elapsed = 0;
	self.tintElapsed = 0;
	self.glyphType = nil;
end

function GlyphFrameGlyph_UpdateSlot (self)
	local id = self:GetID();
	local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup;
	local enabled, glyphType, glyphSpell, iconFilename = GetGlyphSocketInfo(id, talentGroup);

	local isMinor = glyphType == 2;
	if ( isMinor ) then
		GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MINOR);
	else
		GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MAJOR);
	end

	self.elapsed = 0;
	self.tintElapsed = 0;

	local slotAnimation = slotAnimations[id];
	if ( not enabled ) then
		slotAnimation.glyph = nil;
		if ( slotAnimation.sparkle ) then
			slotAnimation.sparkle:StopAnimating();
			slotAnimation.sparkle:Hide();
		end
		self.shine:Hide();
		self.background:Hide();
		self.glyph:Hide();
		self.ring:Hide();
		self.setting:SetTexture("Interface\\Spellbook\\UI-GlyphFrame-Locked");
		self.setting:SetTexCoord(.1, .9, .1, .9);
	elseif ( not glyphSpell ) then
		slotAnimation.glyph = nil;	
		if ( slotAnimation.sparkle ) then
			slotAnimation.sparkle:StopAnimating();
			slotAnimation.sparkle:Hide();
		end
		self.spell = nil;
		self.shine:Show();
		self.background:Show();
		self.background:SetTexCoord(GLYPH_SLOTS[0].left, GLYPH_SLOTS[0].right, GLYPH_SLOTS[0].top, GLYPH_SLOTS[0].bottom);
		if ( not GlyphMatchesSocket(id) ) then
			self.background:SetAlpha(1);
		end
		self.glyph:Hide();
		self.ring:Show();
	else
		slotAnimation.glyph = true;
		self.spell = glyphSpell;
		self.shine:Show();
		self.background:Show();
		self.background:SetAlpha(1);
		self.background:SetTexCoord(GLYPH_SLOTS[id].left, GLYPH_SLOTS[id].right, GLYPH_SLOTS[id].top, GLYPH_SLOTS[id].bottom);
		self.glyph:Show();
		if ( iconFilename ) then
			self.glyph:SetTexture(iconFilename);
		else
			self.glyph:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune1");
		end
		self.ring:Show();
	end
end

function GlyphFrameGlyph_SetGlyphType (glyph, glyphType)
	glyph.glyphType = glyphType;
	
	glyph.setting:SetTexture("Interface\\Spellbook\\UI-GlyphFrame");
	if ( glyphType == GLYPHTYPE_MAJOR ) then
		glyph.glyph:SetVertexColor(GLYPH_MAJOR.r, GLYPH_MAJOR.g, GLYPH_MAJOR.b);
		glyph.setting:SetWidth(108);
		glyph.setting:SetHeight(108);
		glyph.setting:SetTexCoord(0.740234375, 0.953125, 0.484375, 0.697265625);
		glyph.highlight:SetWidth(108);
		glyph.highlight:SetHeight(108);
		glyph.highlight:SetTexCoord(0.740234375, 0.953125, 0.484375, 0.697265625);
		glyph.ring:SetWidth(82);
		glyph.ring:SetHeight(82);
		glyph.ring:SetPoint("CENTER", glyph, "CENTER", 0, -1);
		glyph.ring:SetTexCoord(0.767578125, 0.92578125, 0.32421875, 0.482421875);
		glyph.shine:SetTexCoord(0.9609375, 1, 0.9609375, 1);
		glyph.background:SetWidth(70);
		glyph.background:SetHeight(70);
	else
		glyph.glyph:SetVertexColor(GLYPH_MINOR.r, GLYPH_MINOR.g, GLYPH_MINOR.b);
		glyph.setting:SetWidth(86);
		glyph.setting:SetHeight(86);
		glyph.setting:SetTexCoord(0.765625, 0.927734375, 0.15625, 0.31640625);
		glyph.highlight:SetWidth(86);
		glyph.highlight:SetHeight(86);
		glyph.highlight:SetTexCoord(0.765625, 0.927734375, 0.15625, 0.31640625);
		glyph.ring:SetWidth(62);
		glyph.ring:SetHeight(62);
		glyph.ring:SetPoint("CENTER", glyph, "CENTER", 0, 1);
		glyph.ring:SetTexCoord(0.787109375, 0.908203125, 0.033203125, 0.154296875);
		glyph.shine:SetTexCoord(0.9609375, 1, 0.921875, 0.9609375);
		glyph.background:SetWidth(64);
		glyph.background:SetHeight(64);
	end
end

function GlyphFrameGlyph_OnUpdate (self, elapsed)
	local GLYPHFRAMEGLYPH_FINISHED = 6;
	local GLYPHFRAMEGLYPH_START = 2;
	local GLYPHFRAMEGLYPH_HOLD = 4;

	local hasGlyph = self.glyph:IsShown();
	
	if ( hasGlyph or self.elapsed > 0 ) then
		self.elapsed = self.elapsed + elapsed;
		
		elapsed = self.elapsed;
		if ( elapsed >= GLYPHFRAMEGLYPH_FINISHED ) then
			self.setting:SetAlpha(.6);
			self.elapsed = 0;
		elseif ( elapsed <= GLYPHFRAMEGLYPH_START ) then
			self.setting:SetAlpha(.6 + (.4 * elapsed/GLYPHFRAMEGLYPH_START));
		elseif ( elapsed >= GLYPHFRAMEGLYPH_HOLD ) then
			self.setting:SetAlpha(1 - (.4 * (elapsed - GLYPHFRAMEGLYPH_HOLD) / (GLYPHFRAMEGLYPH_FINISHED - GLYPHFRAMEGLYPH_HOLD) ) );
		end
	elseif ( self.background:IsShown() ) then
		self.setting:SetAlpha(.6);
	else
		self.setting:SetAlpha(.6);
	end
	
	
	local TINT_START, TINT_HOLD, TINT_FINISHED = .6, .8, 1.6;
	
	
	local id = self:GetID();
	if ( not hasGlyph and self.background:IsShown() and GlyphMatchesSocket(id) ) then
		self.tintElapsed = self.tintElapsed + elapsed;
		
		self.background:SetTexCoord(GLYPH_SLOTS[id].left, GLYPH_SLOTS[id].right, GLYPH_SLOTS[id].top, GLYPH_SLOTS[id].bottom);
		
		local highlight = false;
		if ( not self:IsMouseOver() ) then
			self.highlight:Show();
			highlight = true;
		end
		
		local alpha;
		elapsed = self.tintElapsed;
		if ( elapsed >= TINT_FINISHED ) then
			alpha = 1;
			
			self.tintElapsed = 0;
		elseif ( elapsed <= TINT_START ) then
			alpha = 1 - (.6 * elapsed/TINT_START);
		elseif ( elapsed >= TINT_HOLD ) then
			alpha = .4 + (.6 * (elapsed - TINT_HOLD) / (TINT_FINISHED - TINT_HOLD));
		end
		
		if ( alpha ) then
			self.background:SetAlpha(alpha);
			if ( highlight ) then
				self.highlight:SetAlpha(HIGHLIGHT_BASEALPHA * alpha);
			else
				self.highlight:SetAlpha(HIGHLIGHT_BASEALPHA);
			end
		end
	elseif ( not hasGlyph ) then
		self.background:SetTexCoord(GLYPH_SLOTS[0].left, GLYPH_SLOTS[0].right, GLYPH_SLOTS[0].top, GLYPH_SLOTS[0].bottom);
		self.background:SetAlpha(1);
	end
	
	if ( self.hasCursor and SpellIsTargeting() ) then
		if ( GlyphMatchesSocket(self:GetID()) and self.background:IsShown() ) then
			SetCursor("CAST_CURSOR");
		else
			SetCursor("CAST_ERROR_CURSOR");
		end
	end
end

function GlyphFrameGlyph_OnClick (self, button)
	local id = self:GetID();
	local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup;

	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local link = GetGlyphLink(id, talentGroup);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	elseif ( button == "RightButton" ) then
		if ( IsShiftKeyDown() and talentGroup == GetActiveTalentGroup() ) then
			local glyphName;
			local _, _, glyphSpell = GetGlyphSocketInfo(id, talentGroup);
			if ( glyphSpell ) then
				glyphName = GetSpellInfo(glyphSpell);
				local dialog = StaticPopup_Show("CONFIRM_REMOVE_GLYPH", glyphName);
				dialog.data = id;
			end
		end
	elseif ( talentGroup == GetActiveTalentGroup() ) then
		if ( self.glyph:IsShown() and GlyphMatchesSocket(id) ) then
			local dialog = StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", id);
			dialog.data = id;
		else
			PlaceGlyphInSocket(id);
		end
	end
end

function GlyphFrameGlyph_OnEnter (self)
	self.hasCursor = true;
	if ( self.background:IsShown() ) then
		self.highlight:Show();
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetGlyph(self:GetID(), PlayerTalentFrame and PlayerTalentFrame.talentGroup);
	GameTooltip:Show();
end

function GlyphFrameGlyph_OnLeave (self)
	self.hasCursor = nil;
	self.highlight:Hide();
	GameTooltip:Hide();
end

local GLYPH_SPARKLE_SIZES = 3;
local GLYPH_DURATION_MODIFIERS = { 1.25, 1.5, 1.8 };

function GlyphFrame_OnUpdate (self, elapsed)
	for i = 1, #slotAnimations do
		local animation = slotAnimations[i];
		if ( animation.glyph and not (animation.sparkle and animation.sparkle.animGroup:IsPlaying()) ) then
			local sparkleSize = math.random(GLYPH_SPARKLE_SIZES);
			GlyphFrame_StartSlotAnimation(i, sparkleSize * GLYPH_DURATION_MODIFIERS[sparkleSize], sparkleSize);
		end
	end
end

function GlyphFrame_PulseGlow ()
	GlyphFrame.glow:Show();
	GlyphFrame.glow.pulse:Play();
end

function GlyphFrame_OnShow (self)
	GlyphFrame_Update();
end

function GlyphFrame_OnLoad (self)
	local name = self:GetName();
	self.background = _G[name .. "Background"];
	self.sparkleFrame = SparkleFrame:New(self);
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("GLYPH_ADDED");
	self:RegisterEvent("GLYPH_REMOVED");
	self:RegisterEvent("GLYPH_UPDATED");
	self:RegisterEvent("USE_GLYPH");
	self:RegisterEvent("PLAYER_LEVEL_UP");
end

function GlyphFrame_OnEnter (self)
	if ( SpellIsTargeting() ) then
		SetCursor("CAST_ERROR_CURSOR");
	end
end

function GlyphFrame_OnLeave (self)

end

function GlyphFrame_OnEvent (self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local name = ...;
		if ( name == "Blizzard_GlyphUI" and IsAddOnLoaded("Blizzard_TalentUI") or name == "Blizzard_TalentUI" ) then
			self:ClearAllPoints();
			self:SetParent(PlayerTalentFrame);
			self:SetAllPoints();
			-- make sure this shows up above the talent UI
			local frameLevel = self:GetParent():GetFrameLevel() + 4;
			self:SetFrameLevel(frameLevel);
			PlayerTalentFrameCloseButton:SetFrameLevel(frameLevel + 1);
		end
	elseif ( event == "USE_GLYPH" or event == "PLAYER_LEVEL_UP" ) then
		GlyphFrame_Update();
	elseif ( event == "GLYPH_ADDED" or event == "GLYPH_REMOVED" or event == "GLYPH_UPDATED" ) then
		local index = ...;
		local glyph = _G["GlyphFrameGlyph" .. index];
		if ( glyph and self:IsVisible() ) then
			-- update the glyph
			GlyphFrameGlyph_UpdateSlot(glyph);
			-- play effects based on the event and glyph type
			GlyphFrame_PulseGlow();
			local glyphType = glyph.glyphType;
			if ( event == "GLYPH_ADDED" or event == "GLYPH_UPDATED" ) then
				if ( glyphType == GLYPHTYPE_MINOR ) then
					PlaySound("Glyph_MinorCreate");
				elseif ( glyphType == GLYPHTYPE_MAJOR ) then
					PlaySound("Glyph_MajorCreate");
				end
			elseif ( event == "GLYPH_REMOVED" ) then
				GlyphFrame_StopSlotAnimation(index);
				if ( glyphType == GLYPHTYPE_MINOR ) then
					PlaySound("Glyph_MinorDestroy");
				elseif ( glyphType == GLYPHTYPE_MAJOR ) then
					PlaySound("Glyph_MajorDestroy");
				end
			end
		end

		--Refresh tooltip!
		if ( GameTooltip:IsOwned(glyph) ) then
			GlyphFrameGlyph_OnEnter(glyph);
		end
	end
end

function GlyphFrame_Update ()
	local isActiveTalentGroup =
		PlayerTalentFrame and not PlayerTalentFrame.pet and
		PlayerTalentFrame.talentGroup == GetActiveTalentGroup(PlayerTalentFrame.pet);
	SetDesaturation(GlyphFrame.background, not isActiveTalentGroup);

	for i = 1, NUM_GLYPH_SLOTS do
		GlyphFrameGlyph_UpdateSlot(_G["GlyphFrameGlyph"..i]);
	end
end

function GlyphFrame_StartSlotAnimation (slotID, duration, size)
	local animation = slotAnimations[slotID];

	-- init texture to animate
	local sparkleName = "GlyphFrameSparkle"..slotID;
	local sparkle = _G[sparkleName];
	if ( not sparkle ) then
		sparkle = GlyphFrame:CreateTexture(sparkleName, "OVERLAY", "GlyphSparkleTexture");
		sparkle.slotID = slotID;
	end
	local template;
	if ( size == 1 ) then
		template = "SparkleTextureSmall";
	elseif ( size == 2 ) then
		template = "SparkleTextureKindaSmall";
	else
		template = "SparkleTextureNormal";
	end
	local sparkleDim = SparkleDimensions[template];
	sparkle:SetHeight(sparkleDim.height);
	sparkle:SetWidth(sparkleDim.width);
	sparkle:SetPoint("CENTER", GlyphFrame, animation.point, animation.xStart, animation.yStart);
	sparkle:Show();

	-- init animation
	local offsetX, offsetY = animation.xStop - animation.xStart, animation.yStop - animation.yStart;
	local animGroupAnim = sparkle.animGroup.translate;
	animGroupAnim:SetOffset(offsetX, offsetY);
	animGroupAnim:SetDuration(duration);
	animGroupAnim:Play();

	animation.sparkle = sparkle;
end

function GlyphFrame_StopSlotAnimation (slotID)
	local animation = slotAnimations[slotID];
	if ( animation.sparkle ) then
		animation.sparkle.animGroup:Stop();
		animation.sparkle:Hide();
		animation.sparkle = nil;
	end
end
