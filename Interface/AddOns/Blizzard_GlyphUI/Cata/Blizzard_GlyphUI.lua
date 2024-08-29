NUM_GLYPH_SLOTS = 9;

GLYPH_TYPE_MAJOR = 1;
GLYPH_TYPE_MINOR = 2;
GLYPH_TYPE_PRIME = 3;

SHOW_INSCRIPTION_LEVEL = 25;

GLYPH_ID_MINOR_1 = 2;
GLYPH_ID_MAJOR_1 = 1;
GLYPH_ID_PRIME_1 = 7;
GLYPH_ID_MINOR_2 = 3;
GLYPH_ID_MAJOR_2 = 4;
GLYPH_ID_PRIME_2 = 8;
GLYPH_ID_MINOR_3 = 5;
GLYPH_ID_MAJOR_3 = 6;
GLYPH_ID_PRIME_3 = 9;
--[[
    7
  4 2 1
   3 5
8   6   9
]]--

GLYPH_STRING = { PRIME_GLYPH, MAJOR_GLYPH, MINOR_GLYPH}
GLYPH_STRING_PLURAL = { PRIME_GLYPHS, MAJOR_GLYPHS, MINOR_GLYPHS}

GLYPH_HEADER_BUTTON_HEIGHT = 23;
GLYPH_BUTTON_HEIGHT = 40;
GLYPH_BUTTON_OFFSET = 1;

GLYPH_FILTER_KNOWN = 8;
GLYPH_FILTER_UNKNOWN = 16;


GLYPH_TYPE_INFO = {};
GLYPH_TYPE_INFO[GLYPH_TYPE_PRIME] =  {
	ring = { size = 82, left = 0.85839844, right = 0.93847656, top = 0.22265625, bottom = 0.30273438 };
	highlight = { size = 96, left = 0.85839844, right = 0.95214844, top = 0.30468750, bottom = 0.39843750 };
}
GLYPH_TYPE_INFO[GLYPH_TYPE_MAJOR] =  {
	ring = { size = 66, left = 0.85839844, right = 0.92285156, top = 0.00097656, bottom = 0.06542969 };
	highlight = { size = 80, left = 0.85839844, right = 0.93652344, top = 0.06738281, bottom = 0.14550781 };
}
GLYPH_TYPE_INFO[GLYPH_TYPE_MINOR] =  {
	ring = { size = 61, left = 0.92480469, right = 0.98437500, top = 0.00097656, bottom = 0.06054688 };
	highlight = { size = 75, left = 0.85839844, right = 0.93164063, top = 0.14746094, bottom = 0.22070313 };
}

local slotAnimations = {};
---local TOPLEFT, TOP, TOPRIGHT, BOTTOMRIGHT, BOTTOM, BOTTOMLEFT = 3, 1, 5, 4, 2, 6;
slotAnimations[1] = {  ["xStart"] = 0, ["xStop"] = -85, ["yStart"] = -12, ["yStop"] =   60};
slotAnimations[2] = {  ["xStart"] = 0, ["xStop"] = -13, ["yStart"] = -12, ["yStop"] = 100};
slotAnimations[3] = {  ["xStart"] = 0, ["xStop"] =  59, ["yStart"] = -12, ["yStop"] =   60};
slotAnimations[4] = {  ["xStart"] = 0, ["xStop"] = -13, ["yStart"] = -12, ["yStop"] =  -124};
slotAnimations[5] = {  ["xStart"] = 0, ["xStop"] = -87, ["yStart"] = -12, ["yStop"] =  -27};
slotAnimations[6] = {  ["xStart"] = 0, ["xStop"] =  61, ["yStart"] = -12, ["yStop"] =  -27};
slotAnimations[7] = {  ["xStart"] = 0, ["xStop"] =  61, ["yStart"] = -12, ["yStop"] = -27};
slotAnimations[8] = {  ["xStart"] = 0, ["xStop"] =  61, ["yStart"] = -12, ["yStop"] = -27};
slotAnimations[9] = {  ["xStart"] = 0, ["xStop"] =  61, ["yStart"] = -6, ["yStop"] = -27};


local GLYPH_SPARKLE_SIZES = 3;
local GLYPH_DURATION_MODIFIERS = { 1.25, 1.5, 1.8 };


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

function GlyphFrame_OnLoad (self)
	local name = self:GetName();
	self.sparkleFrame = SparkleFrame:New(self);
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("GLYPH_ADDED");
	self:RegisterEvent("GLYPH_REMOVED");
	self:RegisterEvent("GLYPH_UPDATED");
	self:RegisterEvent("USE_GLYPH");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	
	self.scrollFrame.update = GlyphFrame_UpdateGlyphList;
	self.scrollFrame.scrollBar.doNotHide = true;
	self.scrollFrame.dynamic = GlyphFrame_CalculateScroll;
	HybridScrollFrame_CreateButtons(self.scrollFrame, "GlyphSpellButtonTemplate", 0, -1, "TOPLEFT", "TOPLEFT", 0, -GLYPH_BUTTON_OFFSET, "TOP", "BOTTOM");

	GlyphFrame_SetupFilterDropdown(self);
end

function GlyphFrame_SetupFilterDropdown (self)
	self.FilterDropdown:SetWidth(170);
	self.FilterDropdown:SetDefaultText(ALL_GLYPHS);

	local function IsSelected(filter)
		return IsGlyphFlagSet(filter);
	end

	local function SetSelected(filter)
		ToggleGlyphFilter(filter);
		GlyphFrame_UpdateGlyphList();
	end

	self.FilterDropdown:SetSelectionText(function(selections)
		local known = IsGlyphFlagSet(GLYPH_FILTER_KNOWN);
		local unknown = IsGlyphFlagSet(GLYPH_FILTER_UNKNOWN);
		if known and unknown then
			return ALL_GLYPHS;
		elseif known then
			return USED;
		elseif unknown then
			return UNAVAILABLE;
		end
		return NONE;
	end);

	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_GLYPH_FILTER");

		rootDescription:CreateCheckbox(USED, IsSelected, SetSelected, GLYPH_FILTER_KNOWN); 
		rootDescription:CreateCheckbox(UNAVAILABLE, IsSelected, SetSelected, GLYPH_FILTER_UNKNOWN); 
	end);
end

function GlyphFrame_OnShow (self)
	GlyphFrame_Update(self);
	ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
	PlayerTalentFrameInset:SetPoint("BOTTOMRIGHT",  -197,  PANEL_INSET_BOTTOM_OFFSET);
	PlayerTalentFrameActivateButton:SetPoint( "TOpRIGHT", -205, -35);
	SetGlyphNameFilter("");
	GlyphFrame_UpdateGlyphList ();

	_G["PlayerTalentFrame".."BtnCornerLeft"]:Hide();
	_G["PlayerTalentFrame".."BtnCornerRight"]:Hide();
end

function GlyphFrame_OnHide (self)
	ButtonFrameTemplate_ShowAttic(PlayerTalentFrame);
	ButtonFrameTemplate_ShowButtonBar(PlayerTalentFrame);
	PlayerTalentFrameActivateButton:SetPoint( "TOPRIGHT", -10, -30);
	
	_G["PlayerTalentFrame".."BtnCornerLeft"]:Show();
	_G["PlayerTalentFrame".."BtnCornerRight"]:Show();
end

function GlyphFrame_OnEnter (self)

end

function GlyphFrame_OnLeave (self)

end

function GlyphFrame_OnEvent (self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local name = ...;
		if ( name == "Blizzard_GlyphUI" and C_AddOns.IsAddOnLoaded("Blizzard_TalentUI") or name == "Blizzard_TalentUI" ) then
			self:ClearAllPoints();
			self:SetParent(PlayerTalentFrameInset);
			self:SetPoint("TOPLEFT", "PlayerTalentFrameInset", 3, -3);
			self:SetPoint("BOTTOMRIGHT", "PlayerTalentFrameInset", -3, 3);
		end
	elseif ( event == "USE_GLYPH") then
		GlyphFrame_UpdateGlyphList();
		GlyphFrame_Update(self);
	elseif ( event == "PLAYER_LEVEL_UP" ) then
		GlyphFrame_Update(self);
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
				if ( glyphType == GLYPH_TYPE_MINOR ) then
					PlaySound(SOUNDKIT.GLYPH_MINOR_CREATE);
				elseif ( glyphType == GLYPH_TYPE_MAJOR ) then
					PlaySound(SOUNDKIT.GLYPH_MAJOR_CREATE);
				else
					PlaySound(SOUNDKIT.GLYPH_MAJOR_CREATE);
				end
			elseif ( event == "GLYPH_REMOVED" ) then
				if ( glyphType == GLYPH_TYPE_MINOR ) then
					PlaySound(SOUNDKIT.GLYPH_MINOR_DESTROY);
				elseif ( glyphType == GLYPH_TYPE_MAJOR ) then
					PlaySound(SOUNDKIT.GLYPH_MAJOR_DESTROY);
				else
					PlaySound(SOUNDKIT.GLYPH_MAJOR_DESTROY);
				end
			end
		end

		--Refresh tooltip!
		if ( GameTooltip:IsOwned(glyph) ) then
			GlyphFrameGlyph_OnEnter(glyph);
		end
	end
end


function GlyphFrame_OnUpdate (self, elapsed)
end

function GlyphFrame_PulseGlow ()
	GlyphFrame.glow.pulse:Play();
end

function GlyphFrame_Update (self)
	local isActiveTalentGroup =
		PlayerTalentFrame and not PlayerTalentFrame.pet and
		PlayerTalentFrame.talentGroup == GetActiveTalentGroup(PlayerTalentFrame.pet);
	
	SetDesaturation(GlyphFrame.background, not isActiveTalentGroup);

	for i = 1, NUM_GLYPH_SLOTS do
		local glyph = _G["GlyphFrameGlyph"..i];
		GlyphFrameGlyph_UpdateSlot(glyph);
		SetDesaturation(glyph.ring, not isActiveTalentGroup);
		SetDesaturation(glyph.glyph, not isActiveTalentGroup);
		if isActiveTalentGroup then
			glyph.highlight:Show();
		else
			glyph.highlight:Hide();
		end
	end
	
	local name, count, texture, spellID = GetGlyphClearInfo();
	if name then 
		self.clearInfo.name:SetText(name);
		self.clearInfo.count:SetText(count);
		self.clearInfo.icon:SetTexture(texture);
		self.clearInfo.spellID = spellID
	else
		self.clearInfo.name:SetText("");
		self.clearInfo.count:SetText("");
		self.clearInfo.icon:SetTexture("");
	end
end


function GlyphFrame_UpdateGlyphList ()
	local scrollFrame = GlyphFrame.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numGlyphs = GetNumGlyphs();
	
	local currentHeader = 1;	
	local header = _G["GlyphFrameHeader"..currentHeader];
	while header do
		header:Hide();
		currentHeader = currentHeader + 1;
		header = _G["GlyphFrameHeader"..currentHeader];
	end
	currentHeader = 1;	
	
	local selectedIndex = GetSelectedGlyphSpellIndex();
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i;
		if index <= numGlyphs  then
			local name, glyphType, isKnown, icon, glyphID = GetGlyphInfo(index);
			if name == "header" then
				button:Hide();
				header = _G["GlyphFrameHeader"..currentHeader];
				if header then
					local filter = isKnown;
					header:SetPoint("BOTTOM", button, 0 , 0);
					header:Show();
					header:SetParent(button:GetParent());
					currentHeader = currentHeader + 1;
					
					header.filter = filter;
					header.gType = glyphType;
					header.name:SetText(GLYPH_STRING_PLURAL[glyphType]);

					if  IsGlyphFlagSet(filter) then
						header.expandedIcon:Show();
						header.collapsedIcon:Hide();
					else
						header.expandedIcon:Hide();
						header.collapsedIcon:Show();
					end
					button:SetHeight(GLYPH_HEADER_BUTTON_HEIGHT);
				end
			else
				button:SetHeight(GLYPH_BUTTON_HEIGHT);
				button.glyphIndex = index;
				button.icon:SetTexture(icon);
				button.tooltipName = name;
				button.glyphID = glyphID;
				if isKnown then
					button.icon:SetDesaturated(false);
					button.name:SetText(name);
					button.typeName:SetText(GLYPH_STRING[glyphType]);
					button.disabledBG:Hide();
					if selectedIndex and selectedIndex == index then
						button.selectedTex:Show();
					else
						button.selectedTex:Hide();
					end
				else
					button.selectedTex:Hide();
					button.icon:SetDesaturated(true);
					button.name:SetText(GRAY_FONT_COLOR_CODE..name);
					button.typeName:SetText(GRAY_FONT_COLOR_CODE..GLYPH_STRING[glyphType]);
					button.disabledBG:Show();
				end
				
				if button.showingTooltip then
					GameTooltip:SetGlyphByID(button.glyphID);
				end
				
				button:Show();
			end
		else
			button:Hide();
		end
	end
	
	local totalHeight = (numGlyphs-3) * (GLYPH_BUTTON_HEIGHT + 0);
	totalHeight = totalHeight + (3 * (GLYPH_HEADER_BUTTON_HEIGHT + 0));
	HybridScrollFrame_Update(scrollFrame, totalHeight+5, 330);

	GlyphFrame.FilterDropdown:GenerateMenu();
end


function GlyphFrame_CalculateScroll(offset)
	local heightLeft = offset;
	local buttonHeight;
	local numGlyphs = GetNumGlyphs();

	for i = 1, numGlyphs do
		local name = GetGlyphInfo(i);
		if name == "header" then
			buttonHeight = GLYPH_HEADER_BUTTON_HEIGHT;
		else
			buttonHeight = GLYPH_BUTTON_HEIGHT;
		end
		
		if ( heightLeft - buttonHeight <= 0 ) then
			return i - 1, heightLeft;
		else
			heightLeft = heightLeft - buttonHeight;
		end
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
	sparkle:SetPoint("CENTER", GlyphFrame.background, "CENTER", animation.xStart, animation.yStart);
	sparkle:Show();

	-- init animation
	local offsetX, offsetY = animation.xStop - animation.xStart, animation.yStop - animation.yStart;
	local animGroupAnim = sparkle.animGroup;
	animGroupAnim.translate:SetOffset(offsetX, offsetY);
	animGroupAnim.translate:SetDuration(duration);
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


function GlyphFrame_OnTextChanged(self)
	local text = self:GetText();
	
	if ( text == SEARCH ) then
		SetGlyphNameFilter("");
		return;
	end
	
	SetGlyphNameFilter(text);
	GlyphFrame_UpdateGlyphList();
end

--------------------------------------------------------------------------------
------------------  Glyph Button Functions     ---------------------------
--------------------------------------------------------------------------------

function GlyphFrameGlyph_OnLoad (self)
	self.elapsed = 0;
	self.tintElapsed = 0;
	self.glyphType = nil;
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end


function GlyphFrameGlyph_UpdateSlot (self)
	local id = self:GetID();
	local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup;
	local enabled, glyphType, glyphTooltipIndex, glyphSpell, iconFilename = GetGlyphSocketInfo(id, talentGroup);
	if not glyphType then
		return;
	end

	-- Unlock Glyph Display
	if id == 3 then -- second minor glyph
		if enabled then
			GlyphFrame.levelOverlay1:Hide();
			GlyphFrame.levelOverlayText1:Hide();
		else
			GlyphFrame.levelOverlay1:Show();
			GlyphFrame.levelOverlayText1:SetText(_G["GLYPH_SLOT_TOOLTIP"..glyphTooltipIndex]);
			GlyphFrame.levelOverlayText1:Show();
		end
	end
	if id == 5 then -- third minor glyph
		if enabled then
			GlyphFrame.levelOverlay2:Hide();
			GlyphFrame.levelOverlayText2:Hide();
		else
			GlyphFrame.levelOverlay2:Show();
			GlyphFrame.levelOverlayText2:SetText(_G["GLYPH_SLOT_TOOLTIP"..glyphTooltipIndex]);
			GlyphFrame.levelOverlayText2:Show();
		end
	end
	
	
	GlyphFrameGlyph_SetGlyphType(self, glyphType);

	self.elapsed = 0;
	self.tintElapsed = 0;

	local slotAnimation = slotAnimations[id];
	local _, _, _, offsetX, offsetY = self:GetPoint();
	slotAnimation.xStop = offsetX;
	slotAnimation.yStop = offsetY;
	
	
	if ( not enabled ) then
		slotAnimation.glyph = nil;
		if ( slotAnimation.sparkle ) then
			slotAnimation.sparkle:StopAnimating();
			slotAnimation.sparkle:Hide();
		end
		self:Hide();
	elseif ( not glyphSpell ) then
		slotAnimation.glyph = nil;
		if ( slotAnimation.sparkle ) then
			slotAnimation.sparkle:StopAnimating();
			slotAnimation.sparkle:Hide();
		end
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


function GlyphFrameGlyph_SetGlyphType (glyph, glyphType)
	local info = GLYPH_TYPE_INFO[glyphType];
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


function GlyphFrameGlyph_OnUpdate (self, elapsed)
	local id = self:GetID();
	if GlyphMatchesSocket(id) then
		self.highlight:SetAlpha(0.5);
		self.glow:Play();
	else
		self.glow:Stop();
		self.highlight:SetAlpha(0.0);
	end
end


function GlyphFrameGlyph_OnClick (self, button)
	local id = self:GetID();
	local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup;
	local _, _, _, glyphSpell = GetGlyphSocketInfo(id, talentGroup);

	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local link = GetGlyphLink(id, talentGroup);
		if link then
			ChatEdit_InsertLink(link);
		end
	elseif talentGroup == GetActiveTalentGroup()  then
		local glyphName;
		if button == "RightButton" then
			if  IsShiftKeyDown() then
				if glyphSpell then
					glyphName = GetSpellInfo(glyphSpell);
					local dialog = StaticPopup_Show("CONFIRM_REMOVE_GLYPH", nil, nil, {name = glyphName, id = id});
				end
			end
		elseif  GlyphMatchesSocket(id)  then
			if glyphSpell then
				local newGlyphName = GetPendingGlyphInfo();
				if ( glyphSpell and newGlyphName ) then
					glyphName = GetSpellInfo(glyphSpell);
					StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", nil, nil, {id = id, currentName = glyphName, name = newGlyphName});
				end
			else
				PlaceGlyphInSocket(id);
			end
		end
	end
end


function GlyphFrameGlyph_OnEnter (self)
	self.hasCursor = true;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetGlyph(self:GetID(), PlayerTalentFrame and PlayerTalentFrame.talentGroup);
	self.UpdateTooltip = GlyphFrameGlyph_OnEnter;
	GameTooltip:Show();
end


function GlyphFrameGlyph_OnLeave (self)
	self.hasCursor = nil;
	GameTooltip:Hide();
end


function GlyphFrameHeader_OnClick (self, button)
	ToggleGlyphFilter(self.filter);
	GlyphFrame_UpdateGlyphList ();
end


function GlyphFrameSpell_OnClick (self, button)
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

function GlyphFrameSpell_OnEnter (self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetGlyphByID(self.glyphID);
	self.UpdateTooltip = GlyphFrameSpell_OnEnter;
	self.showingTooltip = true;
	GameTooltip:Show();
end




