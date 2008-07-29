GLYPHTYPE_MAJOR = 1;
GLYPHTYPE_MINOR = 2;

GLYPH_MINOR = { r = 0, g = 0.25, b = 1};
GLYPH_MAJOR = { r = 1, g = 0.25, b = 0};

GLYPH_SLOTS = {};
-- Empty Texture
GLYPH_SLOTS[0] = { left = 0.78125; right = 0.91015625; top = 0.69921875; bottom = 0.828125;}
-- Major Glyphs
GLYPH_SLOTS[1] = { left = 0.392578125; right = 0.521484375; top = 0.87109375; bottom = 1;}
GLYPH_SLOTS[4] = { left = 0; right = 0.12890625; top = 0.87109375; bottom = 1;}
GLYPH_SLOTS[6] = { left = 0.26171875; right = 0.390625; top = 0.87109375; bottom = 1;}
GLYPH_SLOTS[5] = { left = 0.130859375; right = 0.259765625; top = 0.87109375; bottom = 1;}
-- Minor Glyphs
GLYPH_SLOTS[3] = { left = 0.654296875; right = 0.783203125; top = 0.87109375; bottom = 1;}
GLYPH_SLOTS[2] = { left = 0.5234375; right = 0.65234375; top = 0.87109375; bottom = 1;}

function GlyphFrameGlyph_OnLoad (self)
	local name = self:GetName();
	self.glyph = getglobal(name .. "Glyph");
	self.setting = getglobal(name .. "Setting");
	self.background = getglobal(name .. "Background");
	self.ring = getglobal(name .. "Ring");
	self.shine = getglobal(name .. "Shine");
	self.elapsed = 0;
end

function GlyphFrameGlyph_UpdateSlot (self)
	local id = self:GetID();
	
	local enabled, glyphType, glyphSpell = GetGlyphSocketInfo(id);
	
	if ( glyphType == 2 ) then
		GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MINOR);
	else
		GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MAJOR);
	end
	
	if ( not enabled ) then
		self.background:Hide();
		self.glyph:Hide();
		self.ring:Hide();
	elseif ( not glyphSpell ) then
		self.background:SetTexCoord(GLYPH_SLOTS[0].left, GLYPH_SLOTS[0].right, GLYPH_SLOTS[0].top, GLYPH_SLOTS[0].bottom);
		self.glyph:Hide();
	else
		self.background:SetTexCoord(GLYPH_SLOTS[id].left, GLYPH_SLOTS[id].right, GLYPH_SLOTS[id].top, GLYPH_SLOTS[id].bottom);
		self.glyph:Show();
		return true;
	end
end

function GlyphFrameGlyph_SetGlyphType (glyph, glyphType)
	if ( glyphType == GLYPHTYPE_MAJOR ) then
		glyph.glyph:SetVertexColor(GLYPH_MAJOR.r, GLYPH_MAJOR.g, GLYPH_MAJOR.b);
		glyph.setting:SetWidth(108);
		glyph.setting:SetHeight(108);
		glyph.setting:SetTexCoord(0.740234375, 0.953125, 0.484375, 0.697265625);
		glyph.ring:SetWidth(82);
		glyph.ring:SetHeight(82);
		glyph.ring:SetTexCoord(0.767578125, 0.92578125, 0.32421875, 0.482421875);
		glyph.shine:SetTexCoord(0.9609375, 1, 0.9609375, 1);
	else
		glyph.glyph:SetVertexColor(GLYPH_MINOR.r, GLYPH_MINOR.g, GLYPH_MINOR.b);
		glyph.setting:SetWidth(86);
		glyph.setting:SetHeight(86);
		glyph.setting:SetTexCoord(0.765625, 0.927734375, 0.15625, 0.31640625);
		glyph.ring:SetWidth(62);
		glyph.ring:SetHeight(62);
		glyph.ring:SetTexCoord(0.787109375, 0.908203125, 0.033203125, 0.154296875);
		glyph.shine:SetTexCoord(0.9609375, 1, 0.921875, 0.9609375);
	end
end

function GlyphFrameGlyph_OnUpdate (self, elapsed)
	local GLYPHFRAMEGLYPH_FINISHED = 6;
	local GLYPHFRAMEGLYPH_START = 2;
	local GLYPHFRAMEGLYPH_HOLD = 4;

	if ( self.glyph:IsShown() ) then
		self.elapsed = self.elapsed + elapsed;
		
		local elapsed = self.elapsed
		if ( elapsed >= GLYPHFRAMEGLYPH_FINISHED ) then
			self.setting:SetAlpha(.6);
			self.elapsed = 0;
		elseif ( elapsed <= GLYPHFRAMEGLYPH_START ) then
			self.setting:SetAlpha(.6 + (.4 * elapsed/GLYPHFRAMEGLYPH_START));
		elseif ( elapsed >= GLYPHFRAMEGLYPH_HOLD ) then
			self.setting:SetAlpha(1 - (.4 * (elapsed - GLYPHFRAMEGLYPH_HOLD) / (GLYPHFRAMEGLYPH_FINISHED - GLYPHFRAMEGLYPH_HOLD) ) );
		end
	end
	
	if ( self.hasCursor and SpellIsTargeting() ) then
		if ( GlyphMatchesSocket(self:GetID()) ) then
			SetCursor("CAST_CURSOR");
		else
			SetCursor("CAST_ERROR_CURSOR");
		end
	end
end

function GlyphFrameGlyph_OnClick (self, button)
	local id = self:GetID();
	-- self.background:IsShown() is only true when the slot is unlocked.
	if ( GlyphMatchesSocket(id) and self.background:IsShown() ) then
		local dialog = StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", id);
		dialog.data = id;
	end
end

GLYPHFRAME_PULSEIN = .2;
GLYPHFRAME_PULSEOUT = .2;
GLYPHFRAME_FINISHED = 1.5;

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
end

function GlyphFrame_PulseGlow ()
	local frame = GlyphFrame;
	frame.pulseElapsed = 0;
	frame.glow:Show();
	frame:SetScript("OnUpdate", GlyphFrame_OnUpdate);
end

function GlyphFrame_OnShow (self)
	-- for i, slot in next, slotAnimations do
		-- GlyphFrame_StopSlotAnimation(i);
	-- end
	
	-- for i, slot in next, slotAnimations do
		-- local enabled, glyphType, glyphSpell = GetGlyphSocketInfo(i)
		-- if ( glyphSpell ) then
			-- GlyphFrame_StartCenterPulse();
			-- GlyphFrame_StartSlotAnimation(i);
		-- end
	-- end
end

function GlyphFrame_OnLoad (self)
	-- self.glow = getglobal(self:GetName() .. "Glow");
	-- self.sparkleFrame = SparkleFrame:New(self);
end

function GlyphFrame_OnEnter (self)
	if ( SpellIsTargeting() ) then
		SetCursor("CAST_ERROR_CURSOR");
	end
end

function GlyphFrame_OnLeave (self)

end

-- slotAnimations = {}
-- local TOPLEFT, TOP, TOPRIGHT, BOTTOMRIGHT, BOTTOM, BOTTOMLEFT = 1, 2, 3, 4, 5, 6
-- slotAnimations[TOPLEFT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -85, ["yStart"] = 17, ["yStop"] = 60};
-- slotAnimations[TOP] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -13, ["yStart"] = 17, ["yStop"] = 100};
-- slotAnimations[TOPRIGHT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = 59, ["yStart"] = 17, ["yStop"] = 60}
-- slotAnimations[BOTTOMRIGHT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -13, ["yStart"] = 17, ["yStop"] = -64}
-- slotAnimations[BOTTOM] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = -87, ["yStart"] = 18, ["yStop"] = -27}
-- slotAnimations[BOTTOMLEFT] = {["point"] = "CENTER", ["xStart"] = -13, ["xStop"] = 61, ["yStart"] = 18, ["yStop"] = -27}

-- local centerPulsing = false
-- function GlyphFrame_StartCenterPulse ()
	-- if ( centerPulsing ) then
		-- return;
	-- end
	-- GlyphFrameSparkleFrame:StartAnimation("bigPulse", "Pulse", "SparkleTextureSuperHuge", true, "CENTER", -8, 16, .4, .6, .4, 1, 2, 3)
	-- GlyphFrameSparkleFrame:StartAnimation("bigPulse", "Pulse", "SparkleTextureSuperHuge", true, "CENTER", -8, 16, .7, .3, .7, .5, 1, 1.5)
	-- centerPulsing = true;
-- end

-- function GlyphFrame_StartSlotAnimation (slotID)
	-- local animation = slotAnimations[slotID];
	-- GlyphFrameSparkle:Show();
	-- if ( not animation.started ) then
		-- GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", "SparkleTextureSmall", true, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, 2);
		-- GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", "SparkleTextureSmall", true, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, 2.25);
		-- GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", "SparkleTextureSmall", true, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, 2.5);
		-- GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", "SparkleTextureSmall", true, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, 3);
		-- GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", "SparkleTextureSmall", true, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, 3.75);
		-- GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", "SparkleTextureKindaSmall", true, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, 4);
		-- GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", "SparkleTextureKindaSmall", true, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, 4.5);
		-- GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", "SparkleTextureNormal", true, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, 5);
		-- GlyphFrameSparkleFrame:StartAnimation(slotID, "LinearTranslate", "SparkleTextureNormal", true, animation.point, animation.xStart, animation.xStop, animation.yStart, animation.yStop, 6);
		-- GlyphFrameSparkleFrame:SetAnimationVertexColor(slotID, 1, 1, 1, .4);
	-- end
	-- animation.started = true;
-- end

-- function GlyphFrame_StopSlotAnimation (slotID)
	-- local animation = slotAnimations[slotID];
	-- if ( animation.started ) then
		-- GlyphFrameSparkleFrame:EndAnimation(slotID);
		-- animation.started = nil;

	-- end
-- end
