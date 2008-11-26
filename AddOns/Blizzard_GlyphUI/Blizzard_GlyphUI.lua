GLYPHTYPE_MAJOR = 1;
GLYPHTYPE_MINOR = 2;

GLYPH_MINOR = { r = 0, g = 0.25, b = 1};
GLYPH_MAJOR = { r = 1, g = 0.25, b = 0};

GLYPH_SLOTS = {};
-- Empty Texture
GLYPH_SLOTS[0] = { left = 0.78125; right = 0.91015625; top = 0.69921875; bottom = 0.828125;}
-- Major Glyphs
GLYPH_SLOTS[3] = { left = 0.392578125; right = 0.521484375; top = 0.87109375; bottom = 1;}
GLYPH_SLOTS[1] = { left = 0; right = 0.12890625; top = 0.87109375; bottom = 1;}
GLYPH_SLOTS[5] = { left = 0.26171875; right = 0.390625; top = 0.87109375; bottom = 1;}
-- Minor Glyphs
GLYPH_SLOTS[2] = { left = 0.130859375; right = 0.259765625; top = 0.87109375; bottom = 1;}
GLYPH_SLOTS[6] = { left = 0.654296875; right = 0.783203125; top = 0.87109375; bottom = 1;}
GLYPH_SLOTS[4] = { left = 0.5234375; right = 0.65234375; top = 0.87109375; bottom = 1;}

NUM_GLYPH_SLOTS = 6

local slotAnimations = {}
local TOPLEFT, TOP, TOPRIGHT, BOTTOMRIGHT, BOTTOM, BOTTOMLEFT = 3, 1, 5, 4, 2, 6
slotAnimations[TOPLEFT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -85, ["yStart"] = 17, ["yStop"] = 60};
slotAnimations[TOP] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -13, ["yStart"] = 17, ["yStop"] = 100};
slotAnimations[TOPRIGHT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = 59, ["yStart"] = 17, ["yStop"] = 60}
slotAnimations[BOTTOM] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -13, ["yStart"] = 17, ["yStop"] = -64}
slotAnimations[BOTTOMLEFT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -87, ["yStart"] = 18, ["yStop"] = -27}
slotAnimations[BOTTOMRIGHT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = 61, ["yStart"] = 18, ["yStop"] = -27}

local GLYPHFRAME_PULSEIN, GLYPHFRAME_PULSEOUT, GLYPHFRAME_FINISHED = .2, .2, 1.5;
local HIGHLIGHT_BASEALPHA = .4;


function GlyphFrameGlyph_OnLoad (self)
	local name = self:GetName();
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self.glyph = getglobal(name .. "Glyph");
	self.setting = getglobal(name .. "Setting");
	self.highlight = getglobal(name .. "Highlight");
	self.background = getglobal(name .. "Background");
	self.ring = getglobal(name .. "Ring");
	self.shine = getglobal(name .. "Shine");
	self.elapsed = 0;
	self.tintElapsed = 0;
	self.glyphType = nil;
end

function GlyphFrameGlyph_UpdateSlot (self)
	local id = self:GetID();
	
	local enabled, glyphType, glyphSpell, iconFilename = GetGlyphSocketInfo(id);

	local isMinor = glyphType == 2;
	if ( isMinor ) then
		GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MINOR);
	else
		GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MAJOR);
	end
	
	self.elapsed = 0;
	self.tintElapsed = 0;
	
	if ( not enabled ) then
		slotAnimations[id].glyph = nil;
		self.shine:Hide();
		self.background:Hide();
		self.glyph:Hide();
		self.ring:Hide();
		self.setting:SetTexture("Interface\\Spellbook\\UI-GlyphFrame-Locked");
		self.setting:SetTexCoord(.1, .9, .1, .9);
	elseif ( not glyphSpell ) then
		slotAnimations[id].glyph = nil;	
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
		slotAnimations[id].glyph = true;
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
		if ( not MouseIsOver(self) ) then
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

	if ( IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible() ) then
		local link = GetGlyphLink(id);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	elseif ( button == "RightButton" ) then
		if ( IsShiftKeyDown() ) then
			local glyphName;
			local _, _, glyphSpell = GetGlyphSocketInfo(id);
			if ( glyphSpell ) then
				glyphName = GetSpellInfo(glyphSpell);
				local dialog = StaticPopup_Show("CONFIRM_REMOVE_GLYPH", glyphName);
				dialog.data = id;
			end
		end
	elseif ( self.glyph:IsShown() and GlyphMatchesSocket(id) ) then
		local dialog = StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", id);
		dialog.data = id;
	else
		PlaceGlyphInSocket(id);
	end
end

function GlyphFrameGlyph_OnEnter (self)
	if ( self.background:IsShown() ) then
		self.highlight:Show();
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetGlyph(self:GetID());
	GameTooltip:Show();
end

function GlyphFrameGlyph_OnLeave (self)
	self.highlight:Hide();
	GameTooltip:Hide();
end

local GLYPH_SPARKLE_SIZES = 3;
local GLYPH_DURATION_MODIFIERS = { 1.25, 1.5, 1.8 };

function GlyphFrame_OnUpdate (self, elapsed)
	if ( self.pulseElapsed ) then
		self.pulseElapsed = self.pulseElapsed + elapsed;
		local pulseElapsed = self.pulseElapsed;
		if ( pulseElapsed >= GLYPHFRAME_FINISHED ) then
			self.glow:Hide();
			self.glow:SetAlpha(0);
			self.pulseElapsed = nil;
		elseif ( pulseElapsed <= GLYPHFRAME_PULSEIN ) then
			self.glow:SetAlpha(pulseElapsed/GLYPHFRAME_PULSEIN);
		elseif ( pulseElapsed >= GLYPHFRAME_PULSEOUT ) then
			self.glow:SetAlpha(1 - ( (pulseElapsed - GLYPHFRAME_PULSEOUT) / (GLYPHFRAME_FINISHED - GLYPHFRAME_PULSEOUT) ) );
		end
	end
	
	for i = 1, 6 do
		if ( not slotAnimations[i].started and slotAnimations[i].glyph ) then
			local sparkleSize = math.random(GLYPH_SPARKLE_SIZES);
			GlyphFrame_StartSlotAnimation(i, sparkleSize * GLYPH_DURATION_MODIFIERS[sparkleSize], sparkleSize);
		end
	end
end

function GlyphFrame_PulseGlow ()
	local frame = GlyphFrame;
	frame.pulseElapsed = 0;
	frame.glow:Show();
	frame:SetScript("OnUpdate", GlyphFrame_OnUpdate);
end

function GlyphFrame_OnShow (self)
	GlyphFrame_Update();
end

function GlyphFrame_OnLoad (self)
	self.glow = getglobal(self:GetName() .. "Glow");
	self.sparkleFrame = SparkleFrame:New(self);
	self:RegisterEvent("GLYPH_ADDED");
	self:RegisterEvent("GLYPH_REMOVED");
	self:RegisterEvent("GLYPH_UPDATED");
	self:RegisterEvent("GLYPHFRAME_OPEN");
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
	if ( event == "GLYPHFRAME_OPEN" or event == "PLAYER_LEVEL_UP" ) then
		GlyphFrame_Update();
	else
		local index = ...;
		local glyph = getglobal("GlyphFrameGlyph" .. index);
		if ( glyph ) then
			-- update the glyph
			GlyphFrameGlyph_UpdateSlot(glyph);
			-- play effects based on the event and glyph type
			local glyphType = glyph.glyphType;
			if ( event == "GLYPH_ADDED" or event == "GLYPH_UPDATED" ) then
				if ( glyphType == GLYPHTYPE_MINOR ) then
					GlyphFrame_PulseGlow();
					PlaySound("Glyph_MinorCreate");
				elseif ( glyphType == GLYPHTYPE_MAJOR ) then
					GlyphFrame_PulseGlow();
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
		GlyphFrameGlyph_OnEnter(glyph);
	end
end

function GlyphFrame_Update ()
	for i = 1, NUM_GLYPH_SLOTS do
		GlyphFrameGlyph_UpdateSlot(getglobal("GlyphFrameGlyph" .. i));
	end
end

function GlyphFrame_FinishAnimation (sparkle)
	if ( sparkle.name and slotAnimations[sparkle.name] ) then
		slotAnimations[sparkle.name].started = false;
	end
end

function GlyphFrame_StartSlotAnimation (slotID, duration, size)
	local animation = slotAnimations[slotID];
	GlyphFrameSparkle:Show();
	
	local template;
	
	if ( size == 1 ) then
		template = "SparkleTextureSmall";
	elseif ( size == 2 ) then
		template = "SparkleTextureKindaSmall";
	else
		template = "SparkleTextureNormal";
	end
		
	local sparkle = GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", template, false, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, duration);		
	sparkle:SetOnFinished(GlyphFrame_FinishAnimation);
	animation.started = true;
end

function GlyphFrame_StopSlotAnimation (slotID)
	local animation = slotAnimations[slotID];
	if ( animation.started ) then
		GlyphFrameSparkleFrame:EndAnimation(slotID);
		animation.started = nil;
	end
end
