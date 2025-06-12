GLYPH_TYPE_MAJOR = 1;
GLYPH_TYPE_MINOR = 2;
-- Note that prime glyphs are not used in Mists and beyond
GLYPH_TYPE_PRIME = 3;

SHOW_INSCRIPTION_LEVEL = 25;


GLYPH_HEADER_BUTTON_HEIGHT = 23;
GLYPH_BUTTON_HEIGHT = 40;
GLYPH_BUTTON_OFFSET = 1;

GLYPH_FILTER_KNOWN = 8;
GLYPH_FILTER_UNKNOWN = 16;


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
		PlayerTalentFrame_ToggleGlyphFrame(C_SpecializationInfo.GetActiveSpecGroup());
	end
end

function GlyphFrame_Open ()
	TalentFrame_LoadUI();
	if ( PlayerTalentFrame_OpenGlyphFrame ) then
		PlayerTalentFrame_OpenGlyphFrame(C_SpecializationInfo.GetActiveSpecGroup());
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
	PlayerTalentFrameInset:SetPoint("BOTTOMRIGHT",  -197,  BOTTOM_RIGHT_OFFSET);
	--PlayerTalentFrameActivateButton:SetPoint( "TOPRIGHT", -205, -35);
	SetGlyphNameFilter("");
	GlyphFrame_UpdateGlyphList ();

	_G["PlayerTalentFrame".."BtnCornerLeft"]:Hide();
	_G["PlayerTalentFrame".."BtnCornerRight"]:Hide();
end

function GlyphFrame_OnHide (self)
	ButtonFrameTemplate_ShowButtonBar(PlayerTalentFrame);
	--PlayerTalentFrameActivateButton:SetPoint( "TOPRIGHT", -10, -30);
	
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
		PlayerTalentFrame.talentGroup == C_SpecializationInfo.GetActiveSpecGroup(PlayerTalentFrame.pet);
	
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

	-- spec icon
	if (ShouldDisplaySpecIconInBackground()) then
		local specialization = C_SpecializationInfo.GetSpecialization(false, false, PlayerTalentFrame.talentGroup);
		if ( specialization ) then
			local _, _, _, icon = C_SpecializationInfo.GetSpecializationInfo(specialization, false, self.isPet);
			local specIcon = GlyphFrame.specIcon;
			GlyphFrame.specRing:Show();
			specIcon:Show();
			SetPortraitToTexture(specIcon, icon);
			SetDesaturation(specIcon, true);
			SetDesaturation(GlyphFrame.specRing, not isActiveTalentGroup);
		else
			GlyphFrame.specRing:Hide();
			GlyphFrame.specIcon:Hide();
		end
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
			local name, glyphType, isKnown, icon, glyphID, _, subText = GetGlyphInfo(index);
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

				local glyphSubText = "";
				if (ShouldDisplaySpecTextInGlyphSubtext()) then
					if(subText ~= nil) then
						glyphSubText = subText;
					end
				else
					glyphSubText = GLYPH_STRING[glyphType];
				end

				if isKnown then
					button.icon:SetDesaturated(false);
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
					button.icon:SetDesaturated(true);
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
	
	local totalHeight = (numGlyphs-NUM_GLYPH_OFFSET) * (GLYPH_BUTTON_HEIGHT + 0);
	totalHeight = totalHeight + (NUM_GLYPH_OFFSET * (GLYPH_HEADER_BUTTON_HEIGHT + 0));
	HybridScrollFrame_Update(scrollFrame, totalHeight+HEIGHT_OFFSET, 330);

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
		
		glyph.glyph:SetWidth(info.ring.size - GLYPH_SIZE_OFFSET);
		glyph.glyph:SetHeight(info.ring.size - GLYPH_SIZE_OFFSET);
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
	elseif talentGroup == C_SpecializationInfo.GetActiveSpecGroup()  then
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




