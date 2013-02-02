GLYPH_STRING = { MAJOR_GLYPH, MINOR_GLYPH}
GLYPH_STRING_PLURAL = { MAJOR_GLYPHS, MINOR_GLYPHS}

GLYPH_HEADER_BUTTON_HEIGHT = 23;
GLYPH_BUTTON_HEIGHT = 40;
GLYPH_BUTTON_OFFSET = 1;

GLYPH_FILTER_KNOWN = 8;
GLYPH_FILTER_UNKNOWN = 16;


GLYPH_TYPE_INFO = {};
GLYPH_TYPE_INFO[GLYPH_TYPE_MAJOR] =  {
	ring = { size = 84, left = 0.00390625, right = 0.33203125, top = 0.27539063, bottom = 0.43945313 };
	highlight = { size = 98, left = 0.54296875, right = 0.92578125, top = 0.00195313, bottom = 0.19335938 };
}
GLYPH_TYPE_INFO[GLYPH_TYPE_MINOR] =  {
	ring = { size = 68, left = 0.33984375, right = 0.60546875, top = 0.27539063, bottom = 0.40820313 };
	highlight = { size = 82, left = 0.61328125, right = 0.93359375, top = 0.27539063, bottom = 0.43554688 };
}

local GLYPH_DURATION_MODIFIERS = { 1.25, 1.5, 1.8 };


function GlyphFrame_Toggle ()
	if ( PlayerTalentFrame_ToggleGlyphFrame ) then
		PlayerTalentFrame_ToggleGlyphFrame(GetActiveSpecGroup());
	end
end

function GlyphFrame_Open ()
	if ( PlayerTalentFrame_OpenGlyphFrame ) then
		PlayerTalentFrame_OpenGlyphFrame(GetActiveSpecGroup());
	end
end

function GlyphFrame_OnLoad (self)
	local name = self:GetName();
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("GLYPH_ADDED");
	self:RegisterEvent("GLYPH_REMOVED");
	self:RegisterEvent("GLYPH_UPDATED");
	self:RegisterEvent("USE_GLYPH");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");

	self.scrollFrame.update = GlyphFrame_UpdateGlyphList;
	self.scrollFrame.stepSize = 12;
	self.scrollFrame.scrollBar.doNotHide = true;
	self.scrollFrame.dynamic = GlyphFrame_CalculateScroll;
	HybridScrollFrame_CreateButtons(self.scrollFrame, "GlyphSpellButtonTemplate", 0, -1, "TOPLEFT", "TOPLEFT", 0, -GLYPH_BUTTON_OFFSET, "TOP", "BOTTOM");
end


function GlyphFrame_OnShow (self)
	GlyphFrame_Update(self);
	ButtonFrameTemplate_HideAttic(PlayerTalentFrame);
	PlayerTalentFrameInset:SetPoint("BOTTOMRIGHT",  -197,  PANEL_INSET_BOTTOM_BUTTON_OFFSET);
--	PlayerTalentFrameActivateButton:SetPoint( "BOTTOMRIGHT", -5, 4);
	SetGlyphNameFilter("");
	GlyphFrame_UpdateGlyphList ();
end

function GlyphFrame_OnHide (self)
	ButtonFrameTemplate_ShowButtonBar(PlayerTalentFrame);
--	PlayerTalentFrameActivateButton:SetPoint( "TOPRIGHT", -10, -30);
end

function GlyphFrame_OnEnter (self)
	-- if ( SpellIsTargeting() ) then
		-- SetCursor("CAST_ERROR_CURSOR");
	-- end
end

function GlyphFrame_OnLeave (self)

end

function GlyphFrame_OnEvent (self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local name = ...;
		if ( name == "Blizzard_GlyphUI" and IsAddOnLoaded("Blizzard_TalentUI") or name == "Blizzard_TalentUI" ) then
			self:ClearAllPoints();
			self:SetParent(PlayerTalentFrameInset);
			self:SetPoint("TOPLEFT", "PlayerTalentFrameInset", 3, -3);
			self:SetPoint("BOTTOMRIGHT", "PlayerTalentFrameInset", -3, 3);
		end
	elseif ((event == "USE_GLYPH") or (event == "PLAYER_TALENT_UPDATE")) then
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
					PlaySound("Glyph_MinorCreate");
				elseif ( glyphType == GLYPH_TYPE_MAJOR ) then
					PlaySound("Glyph_MajorCreate");
				else
					PlaySound("Glyph_MajorCreate");
				end
			elseif ( event == "GLYPH_REMOVED" ) then
				--GlyphFrame_StopSlotAnimation(index);
				if ( glyphType == GLYPH_TYPE_MINOR ) then
					PlaySound("Glyph_MinorDestroy");
				elseif ( glyphType == GLYPH_TYPE_MAJOR ) then
					PlaySound("Glyph_MajorDestroy");
				else
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


function GlyphFrame_PulseGlow ()
	GlyphFrame.glow.pulse:Play();
end

function GlyphFrame_Update (self)
	local isActiveTalentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup == GetActiveSpecGroup();
	
	SetDesaturation(GlyphFrame.background, not isActiveTalentGroup);
	SetDesaturation(GlyphFrame.levelOverlay1, not isActiveTalentGroup);
	SetDesaturation(GlyphFrame.levelOverlay2, not isActiveTalentGroup);
	if ( isActiveTalentGroup ) then
		GlyphFrame.levelOverlayText1:SetTextColor(0.2, 0.1, 0.09, 0.8);
		GlyphFrame.levelOverlayText2:SetTextColor(0.2, 0.1, 0.09, 0.8);
	else
		GlyphFrame.levelOverlayText1:SetTextColor(0.2, 0.2, 0.2, 0.8);
		GlyphFrame.levelOverlayText2:SetTextColor(0.2, 0.2, 0.2, 0.8);
	end

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

	-- spec icon
	local specialization = GetSpecialization(false, false, PlayerTalentFrame.talentGroup);
	if ( specialization ) then
		local _, _, _, icon = GetSpecializationInfo(specialization, false, self.isPet);
		local specIcon = GlyphFrame.specIcon;
		GlyphFrame.specRing:Show();
		specIcon:Show();
		SetPortraitToTexture(specIcon, icon);
		SetDesaturation(specIcon, true);
		if ( isActiveTalentGroup ) then
			SetDesaturation(GlyphFrame.specRing, false);
		else
			SetDesaturation(GlyphFrame.specRing, true);
		end
	else
		GlyphFrame.specRing:Hide();
		GlyphFrame.specIcon:Hide();
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
			local name, glyphType, isKnown, icon, glyphID, link, subText = GetGlyphInfo(index);
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
				local glyphSubText;
				if(subText ~= nil) then
					glyphSubText = subText;
				else
					glyphSubText = "";
				end
				if isKnown then
					button.icon:SetDesaturated(0);
					button.name:SetText(name);
					button.typeName:SetText(glyphSubText);
					button.disabledBG:Hide();
					if selectedIndex and selectedIndex == index then
						button.selectedTex:Show();
					else
						button.selectedTex:Hide();
					end
				else
					button.selectedTex:Hide();
					button.icon:SetDesaturated(1);
					button.name:SetText(GRAY_FONT_COLOR_CODE..name);
					button.typeName:SetText(GRAY_FONT_COLOR_CODE..glyphSubText);
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
	
	local totalHeight = (numGlyphs-2) * (GLYPH_BUTTON_HEIGHT + 0);
	totalHeight = totalHeight + (2 * (GLYPH_HEADER_BUTTON_HEIGHT + 0));
	HybridScrollFrame_Update(scrollFrame, totalHeight+10, 330);
	
	local known =  IsGlyphFlagSet(GLYPH_FILTER_KNOWN);
	local unknown =  IsGlyphFlagSet(GLYPH_FILTER_UNKNOWN);
	if known and unknown then
		UIDropDownMenu_SetText(GlyphFrameFilterDropDown, ALL_GLYPHS);
	elseif known then
		UIDropDownMenu_SetText(GlyphFrameFilterDropDown, USED);
	elseif unknown then
		UIDropDownMenu_SetText(GlyphFrameFilterDropDown, UNAVAILABLE);
	else
		UIDropDownMenu_SetText(GlyphFrameFilterDropDown, NONE);
	end
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


function GlyphFrame_OnTextChanged(self)
	local text = self:GetText();
	
	if ( text == SEARCH ) then
		SetGlyphNameFilter("");
		return;
	end
	
	SetGlyphNameFilter(text);
	GlyphFrame_UpdateGlyphList();
end


function GlyphFrameFilter_Modify(self, arg1)
	ToggleGlyphFilter(arg1);
	GlyphFrame_UpdateGlyphList ();
end 


function GlyphFrameFilter_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.func = GlyphFrameFilter_Modify;
	
	
	info.text = USED;
	info.checked = IsGlyphFlagSet(GLYPH_FILTER_KNOWN);
	info.arg1 = GLYPH_FILTER_KNOWN
	UIDropDownMenu_AddButton(info);
	
	info.text = UNAVAILABLE;
	info.checked = IsGlyphFlagSet(GLYPH_FILTER_UNKNOWN);
	info.arg1 = GLYPH_FILTER_UNKNOWN
	UIDropDownMenu_AddButton(info);
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

	local slotAnimation = SLOT_ANIMATIONS[id];
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
		
		glyph.glyph:SetWidth(info.ring.size - 6);
		glyph.glyph:SetHeight(info.ring.size - 6);
		glyph.glyph:SetAlpha(0.75);
	end
end


function GlyphFrameGlyph_OnUpdate (self, elapsed)
	local id = self:GetID();
	if GlyphMatchesSocket(id) then
		self.highlight:SetAlpha(0.5);
		self.glow:Play();
	else
		self.highlight:SetAlpha(0.0);
		self.glow:Stop();
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
	elseif talentGroup == GetActiveSpecGroup()  then
		if button == "RightButton" then
			local glyphName;
			if ( glyphSpell ) then
				glyphName = GetSpellInfo(glyphSpell);
				local dialog = StaticPopup_Show("CONFIRM_REMOVE_GLYPH", nil, nil, {name = glyphName, id = id});
			end
		elseif  GlyphMatchesSocket(id)  then
			if glyphSpell then
				local glyphIndex = GetSelectedGlyphSpellIndex();
				local glyphName = GetGlyphInfo(glyphIndex);
				local dialog = StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", nil, nil, {name = glyphName, id = id});
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
	GameTooltip:Show();
end


function GlyphFrameGlyph_OnLeave (self)
	self.hasCursor = nil;
	GameTooltip:Hide();
end


function GlyphFrameHeader_OnClick (self, button)
	PlaySound("igMainMenuOptionCheckBoxOn");
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
		StaticPopup_Hide("CONFIRM_GLYPH_PLACEMENT");
	end
end






