TRADE_SKILLS_DISPLAYED = 8;
MAX_TRADE_SKILL_REAGENTS = 8;
TRADE_SKILL_HEIGHT = 16;
TRADE_SKILL_TEXT_WIDTH = 275;
TRADE_SKILL_SKILLUP_TEXT_WIDTH = 30;
SUB_SKILL_BAR_WIDTH = 60;

-- Used to denote skill types in Colorblind mode
TradeSkillTypePrefix = {
["optimal"] = " [+++] ",
["medium"] = " [++] ",
["easy"] = " [+] ",
["trivial"] = " ", 
["header"] = " ",
["subheader"] = " ",
}

-- Used to denote skill types outside of Colorblind mode
TradeSkillTypeColor = { };
TradeSkillTypeColor["optimal"]	= { r = 1.00, g = 0.50, b = 0.25, font = "GameFontNormalLeftOrange" };       
TradeSkillTypeColor["medium"]	= { r = 1.00, g = 1.00, b = 0.00, font = "GameFontNormalLeftYellow" };       
TradeSkillTypeColor["easy"]		= { r = 0.25, g = 0.75, b = 0.25, font = "GameFontNormalLeftLightGreen" };   
TradeSkillTypeColor["trivial"]	= { r = 0.50, g = 0.50, b = 0.50, font = "GameFontNormalLeftGrey" };         
TradeSkillTypeColor["header"]	= { r = 1.00, g = 0.82, b = 0,    font = "GameFontNormalLeft" };
TradeSkillTypeColor["subheader"]= { r = 1.00, g = 0.82, b = 0,	font = "GameFontNormalLeft" };

-- Current Trade Skill name. Used for detecting if the player swaps which tradeskill the window should show.
local currentTradeSkillName = "";

local SUBSKILL_RANKS = { };				-- tracks subskill ranks for figuring out which one just skilled up in order to flash the rank numbers
local SUBSKILL_FLASH_BAR;				-- the subskill progress bar that's currently flashing
local SUBSKILL_FLASH_NAME;				-- the name of the subskill that's currently flashing
local SUBSKILL_FLASH_ELAPSED_TIME;		-- current elapsed time for the flash
local SUBSKILL_FLASH_DURATION = 1;		-- how long the flash should take

function TradeSkillFrame_OnShow(self)
	ShowUIPanel(TradeSkillFrame);
	TradeSkillCreateButton:Disable();
	TradeSkillCreateAllButton:Disable();
	if ( GetTradeSkillSelectionIndex() == 0 ) then
		TradeSkillFrame_SetSelection(GetFirstTradeSkill());
	else
		TradeSkillFrame_SetSelection(GetTradeSkillSelectionIndex());
	end
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	TradeSkillListScrollFrameScrollBar.doNotHide = true;
	TradeSkillListScrollFrameScrollBar:SetMinMaxValues(0, 0); 
	TradeSkillListScrollFrameScrollBar:SetValue(0);
	SetPortraitTexture(TradeSkillFramePortrait, "player");
	TradeSkillFrame_Update(self);

	TradeSkillInputBox:SetNumber(1);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	TradeSkillFrame_InitFilterMenu(self.FilterDropdown);
end

function TradeSkillFrame_OnUpdate(self, elapsed)
	if ( SUBSKILL_FLASH_BAR ) then
		SUBSKILL_FLASH_ELAPSED_TIME = SUBSKILL_FLASH_ELAPSED_TIME + elapsed;
		if ( SUBSKILL_FLASH_ELAPSED_TIME > SUBSKILL_FLASH_DURATION ) then
			TradeSkilSubSkillRank_StopFlash();
		else
			local alpha = math.sin(SUBSKILL_FLASH_ELAPSED_TIME * math.pi / SUBSKILL_FLASH_DURATION);	-- just a half-sine curve
			SUBSKILL_FLASH_BAR.Rank:SetAlpha(alpha);
			SUBSKILL_FLASH_BAR.Rank:SetText(SUBSKILL_FLASH_BAR.currentRank.."/"..SUBSKILL_FLASH_BAR.maxRank);
		end
	end
	TradeSkillFrame_PlaytimeUpdate();
end

function TradeSkillFrameButton_OnEnter(self)
	self.count:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	self.skillup.icon:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	self.skillup.countText:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	if ( self.SubSkillRankBar.currentRank and self.SubSkillRankBar.maxRank) then
		if ( self.SubSkillRankBar == SUBSKILL_FLASH_BAR ) then
			TradeSkilSubSkillRank_StopFlash();
		end
		self.SubSkillRankBar.Rank:SetText(self.SubSkillRankBar.currentRank.."/"..self.SubSkillRankBar.maxRank);
	end
end

function TradeSkillFrameButton_OnLeave(self)
	if ( not self.isHighlighted ) then
		self.count:SetVertexColor(self.r, self.g, self.b);
		self.skillup.icon:SetVertexColor(self.r, self.g, self.b);
		self.skillup.countText:SetVertexColor(self.r, self.g, self.b);
	end
	self.SubSkillRankBar.Rank:SetText("");
end

function SetAllInventorySlotsFiltered(filtered)
	for filterIndex, name in ipairs({GetTradeSkillInvSlots()}) do
		SetTradeSkillInvSlotFilter(filterIndex, filtered, 1);
	end
end

function TradeSkillFrame_InitFilterMenu(dropdown, onUpdate, onDefault, ignoreSkillLine)
	if not TradeSkillFrame:IsShown() then
		return;
	end

	local function IsSlotChecked(filterIndex) 
		return GetTradeSkillInvSlotFilter(filterIndex) == 1;
	end

	local function SetSlotChecked(filterIndex) 
		if(IsSlotChecked(filterIndex)) then
			SetTradeSkillInvSlotFilter(filterIndex, 0, 1);
		else
			SetTradeSkillInvSlotFilter(filterIndex, 1, 1);
		end	
	end

	local function IsSubClassSelected(filterIndex) 
		return GetTradeSkillSubClassFilter(filterIndex) == 1;
	end

	local function SetSubClassSelected(filterIndex)
		local on = 1;
		if(IsSubClassSelected(filterIndex)) then
			on = 0;
		end
		SetTradeSkillSubClassFilter(filterIndex, on, 0);
	end

	dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_FILTER");


		rootDescription:CreateCheckbox(TRADESKILL_FILTER_HAS_SKILL_UP, GetOnlyShowSkillUps, function()
			TradeSkillOnlyShowSkillUps(not GetOnlyShowSkillUps());
		end);


		rootDescription:CreateCheckbox(CRAFT_IS_MAKEABLE, GetOnlyShowMakeable, function()
			TradeSkillOnlyShowMakeable(not GetOnlyShowMakeable());
		end);

		
		local slotsSubmenu = rootDescription:CreateButton(TRADESKILL_FILTER_SLOTS);
		for filterIndex, name in ipairs({GetTradeSkillInvSlots()}) do 
			slotsSubmenu:CreateCheckbox(name, IsSlotChecked, SetSlotChecked, filterIndex);
		end

		local subClassSubmenu = rootDescription:CreateButton(TRADESKILL_FILTER_CATEGORY);
		for index, name in ipairs({GetTradeSkillSubClasses()}) do
			if( name ~= "") then
				subClassSubmenu:CreateCheckbox(name, IsSubClassSelected, SetSubClassSelected, index);
			end
		end
	end);
end

function TradeSkillFrame_OnHide(self)
	CloseTradeSkill();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function TradeSkillFrame_Hide()
	HideUIPanel(TradeSkillFrame);
end

function TradeSkillFrame_OnLoad(self)
	self:RegisterEvent("TRADE_SKILL_UPDATE");
	self:RegisterEvent("TRADE_SKILL_FILTER_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UPDATE_TRADESKILL_RECAST");
end

function TradeSkillFrame_OnEvent(self, event, ...)
	if ( not TradeSkillFrame:IsShown() ) then
		return;
	end
	if ( event == "TRADE_SKILL_UPDATE" or event == "TRADE_SKILL_FILTER_UPDATE" ) then
		TradeSkillCreateButton:Disable();
		TradeSkillCreateAllButton:Disable();
		if ( (event ~= "TRADE_SKILL_FILTER_UPDATE") and (GetTradeSkillSelectionIndex() > 1) and (GetTradeSkillSelectionIndex() <= GetNumTradeSkills()) ) then
			TradeSkillFrame_SetSelection(GetTradeSkillSelectionIndex());
		else
			TradeSkillFrame_SetSelection(GetFirstTradeSkill());
			FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
			TradeSkillListScrollFrameScrollBar:SetValue(0);
		end
		TradeSkillFrame_Update(self);
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( arg1 == "player" ) then
			SetPortraitTexture(TradeSkillFramePortrait, "player");
		end
	elseif ( event == "UPDATE_TRADESKILL_RECAST" ) then
		TradeSkillInputBox:SetNumber(GetTradeskillRepeatCount());
	end
end

function TradeSkillFrame_Update(self)
	local numTradeSkills = GetNumTradeSkills();
	local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
	local name, rank, maxRank = GetTradeSkillLine();

	if (currentTradeSkillName ~= name) then
		StopTradeSkillRepeat();
		if(currentTradeSkillName ~= "" ) then
			-- To fix problem with switching between two tradeskills
			TradeSkillFrame_InitFilterMenu(self.FilterDropdown);
		end
		currentTradeSkillName = name;
	end

	-- If no tradeskills
	if ( numTradeSkills == 0 ) then
		TradeSkillFrameTitleText:SetFormattedText(TRADE_SKILL_TITLE, GetTradeSkillLine());
		TradeSkillSkillName:Hide();
--		TradeSkillSkillLineName:Hide();
		TradeSkillSkillIcon:Hide();
		TradeSkillRequirementLabel:Hide();
		TradeSkillRequirementText:SetText("");
		TradeSkillCollapseAllButton:Disable();
		for i=1, MAX_TRADE_SKILL_REAGENTS, 1 do
			_G["TradeSkillReagent"..i]:Hide();
		end
	else
		TradeSkillSkillName:Show();
--		TradeSkillSkillLineName:Show();
		TradeSkillSkillIcon:Show();
		TradeSkillCollapseAllButton:Enable();
	end

	if ( rank < 75 ) and ( not IsTradeSkillLinked() ) then
		TradeSkillFrameSearchBox:Hide();
		SetTradeSkillItemNameFilter("");	--In case they are switching from an inspect WITH a filter directly to their own without.
	else
		TradeSkillFrameSearchBox:Show();
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(TradeSkillListScrollFrame, numTradeSkills, TRADE_SKILLS_DISPLAYED, TRADE_SKILL_HEIGHT, nil, nil, nil, TradeSkillHighlightFrame, 293, 316, true );

	TradeSkillHighlightFrame:Hide();

	local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps, indentLevel, showProgressBar, currentRank, startingRank;
	local skillIndex, skillButton, skillButtonText, skillButtonCount, skillButtonNumSkillUps, skillButtonNumSkillUpsIcon, skillButtonNumSkillUpsText, skillButtonSubSkillRankBar;
	local nameWidth, countWidth, usedWidth;

	local skillNamePrefix = " ";
	for i=1, TRADE_SKILLS_DISPLAYED, 1 do
		skillIndex = i + skillOffset;
		skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps, indentLevel, showProgressBar, currentRank, maxRank, startingRank = GetTradeSkillInfo(skillIndex);

		skillButton = _G["TradeSkillSkill"..i];
		skillButtonText = _G["TradeSkillSkill"..i.."Text"];
		skillButtonCount = _G["TradeSkillSkill"..i.."Count"];
		skillButtonNumSkillUps = _G["TradeSkillSkill"..i.."NumSkillUps"];
		skillButtonNumSkillUpsText = _G["TradeSkillSkill"..i.."NumSkillUpsText"];
		skillButtonNumSkillUpsIcon = _G["TradeSkillSkill"..i.."NumSkillUpsIcon"];
		skillButtonSubSkillRankBar = _G["TradeSkillSkill"..i.."SubSkillRankBar"];
		if ( skillIndex <= numTradeSkills ) then	
			-- Set button widths if scrollbar is shown or hidden
			if ( TradeSkillListScrollFrame:IsShown() and numSkillUps > 1 and skillType=="optimal") then
				skillButtonNumSkillUps:Show();
				skillButtonNumSkillUpsText:SetText(numSkillUps);
				usedWidth = TRADE_SKILL_SKILLUP_TEXT_WIDTH;
			else
				skillButtonNumSkillUps:Hide();
				usedWidth = 0;
			end
			local color = TradeSkillTypeColor[skillType];
			if ( color ) then
				skillButton:SetNormalFontObject(color.font);
				skillButtonCount:SetVertexColor(color.r, color.g, color.b);
				skillButton.r = color.r;
				skillButton.g = color.g;
				skillButton.b = color.b;
				skillButtonNumSkillUpsText:SetVertexColor(color.r, color.g, color.b);
				skillButtonNumSkillUpsIcon:SetVertexColor(color.r, color.g, color.b);
			end

			if ( ENABLE_COLORBLIND_MODE == "1" ) then
				skillNamePrefix = TradeSkillTypePrefix[skillType] or " ";
			end

			local textWidth = TRADE_SKILL_TEXT_WIDTH;
			if(indentLevel ~= 0) then
				textWidth = TRADE_SKILL_TEXT_WIDTH - 20;
				skillButton:GetNormalTexture():SetPoint("LEFT", 23, 0);
				skillButton:GetDisabledTexture():SetPoint("LEFT", 23, 0);
				skillButton:GetHighlightTexture():SetPoint("LEFT", 23, 0);
			else
				skillButton:GetNormalTexture():SetPoint("LEFT", 3, 0);
				skillButton:GetDisabledTexture():SetPoint("LEFT", 3, 0);
				skillButton:GetHighlightTexture():SetPoint("LEFT", 3, 0);
			end
			
			skillButton:SetID(skillIndex);
			skillButton:Show();

			skillButtonSubSkillRankBar:Hide();
			if ( skillButtonSubSkillRankBar == SUBSKILL_FLASH_BAR and skillName ~= SUBSKILL_FLASH_NAME ) then
				-- we were flashing this bar and now we're reusing it for another skill, kill the flash
				TradeSkilSubSkillRank_StopFlash();
			end
			-- Handle headers
			if ( skillType == "header" or skillType == "subheader" ) then
				--probably only want to show progress bar for categories (headers)
				if ( showProgressBar ) then
					skillButtonSubSkillRankBar:Show();
					TradeSkilSubSkillRank_Set(skillButtonSubSkillRankBar, skillName, currentRank, startingRank, maxRank);
					textWidth = textWidth - SUB_SKILL_BAR_WIDTH;
				end

				skillButtonText:SetWidth(textWidth);
				skillButton:SetText(skillName);
				skillButtonText:SetWidth(TRADE_SKILL_TEXT_WIDTH);
				skillButtonCount:SetText("");
				if ( isExpanded ) then
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				else
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				end
				_G["TradeSkillSkill"..i.."Highlight"]:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
				_G["TradeSkillSkill"..i]:UnlockHighlight();
				skillButton:UnlockHighlight();
				skillButton.isHighlighted = false;
			-- Handle skill entries
			else
				if ( not skillName ) then
					return;
				end
				skillButton:ClearNormalTexture();
				_G["TradeSkillSkill"..i.."Highlight"]:SetTexture("");
				-- None creatable, no brackets needed
				if ( numAvailable <= 0 ) then
					skillButton:SetText(skillNamePrefix..skillName);
					skillButtonCount:SetText(skillCountPrefix);
					textWidth = textWidth - usedWidth;
				-- Some creatable, handle showing num in brackets
				else
					skillName = skillNamePrefix..skillName;
					skillButtonCount:SetText("["..numAvailable.."]");
					TradeSkillFrameDummyString:SetText(skillName);
					nameWidth = TradeSkillFrameDummyString:GetWidth();
					countWidth = skillButtonCount:GetWidth();
					skillButtonText:SetText(skillName);
					if ( nameWidth + 2 + countWidth > textWidth - usedWidth ) then
						textWidth = textWidth - 2 - countWidth - usedWidth;
					else
						textWidth = 0;
					end
				end
				skillButtonText:SetWidth(textWidth);
				-- Place the highlight and lock the highlight state
				if ( GetTradeSkillSelectionIndex() == skillIndex ) then
					TradeSkillHighlightFrame:SetPoint("TOPLEFT", "TradeSkillSkill"..i, "TOPLEFT", 0, 0);
					TradeSkillHighlightFrame:Show();
					skillButtonCount:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

					skillButtonNumSkillUpsText:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
					skillButtonNumSkillUpsIcon:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
					skillButton:LockHighlight();
					skillButton.isHighlighted = true;
				else
					skillButton:UnlockHighlight();
					skillButton.isHighlighted = false;
				end
			end
			
		else
			skillButton:Hide();
		end
	end
	
	-- Set the expand/collapse all button texture
	local numHeaders = 0;
	local notExpanded = 0;
	for i=1, numTradeSkills, 1 do
		skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(i);
		if ( skillName and (skillType == "header" or skillType == "subheader") ) then
			numHeaders = numHeaders + 1;
			if ( not isExpanded ) then
				notExpanded = notExpanded + 1;
			end
		end
		if ( GetTradeSkillSelectionIndex() == i ) then
			-- Set the max makeable items for the create all button
			TradeSkillFrame.numAvailable = math.abs(numAvailable);
		end
	end
	-- If all headers are not expanded then show collapse button, otherwise show the expand button
	if ( notExpanded ~= numHeaders ) then
		TradeSkillCollapseAllButton.collapsed = nil;
		TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	else
		TradeSkillCollapseAllButton.collapsed = 1;
		TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	end
end

function TradeSkilSubSkillRank_Set(rankBar, skillName, currentRank, startingRank, maxRank)
	if ( SUBSKILL_RANKS[skillName] and currentRank > SUBSKILL_RANKS[skillName] and TradeSkillFrame:IsShown() ) then
		-- this bar needs to have skill rank flashing unless the mouse is already over
		rankBar.Rank:SetText(currentRank.."/"..rankBar.maxRank);
		if ( not rankBar:GetParent():IsMouseOver() ) then
			TradeSkilSubSkillRank_StartFlash(rankBar, skillName);
		end
	elseif ( not rankBar:GetParent():IsMouseOver() ) then
		rankBar.Rank:SetText("");
	end

	SUBSKILL_RANKS[skillName] = currentRank;
	rankBar:SetMinMaxValues(startingRank, maxRank);
	rankBar:SetValue(currentRank);
	rankBar.currentRank = currentRank;
	rankBar.maxRank = maxRank;
end

function TradeSkilSubSkillRank_StartFlash(rankBar, skillName)
	TradeSkilSubSkillRank_StopFlash();
	SUBSKILL_FLASH_BAR = rankBar;
	SUBSKILL_FLASH_NAME = skillName;
	SUBSKILL_FLASH_ELAPSED_TIME = 0;
end

function TradeSkilSubSkillRank_StopFlash()
	if ( SUBSKILL_FLASH_BAR ) then
		if ( not SUBSKILL_FLASH_BAR:GetParent():IsMouseOver() ) then
			SUBSKILL_FLASH_BAR.Rank:SetText("");
		end
		SUBSKILL_FLASH_BAR.Rank:SetAlpha(1);
		SUBSKILL_FLASH_BAR = nil;
		SUBSKILL_FLASH_ELAPSED_TIME = nil;
	end
end

function TradeSkillFrame_SetSelection(id)
	local skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(id);
	local creatable = 1;
	if( not skillName ) then
		creatable = nil;
	end
	TradeSkillHighlightFrame:Show();
	if ( skillType == "header"  or skillType == "subheader" ) then
		TradeSkillHighlightFrame:Hide();
		if ( isExpanded ) then
			CollapseTradeSkillSubClass(id);
		else
			ExpandTradeSkillSubClass(id);
		end
		return;
	end
	TradeSkillFrame.selectedSkill = id;
	SelectTradeSkill(id);
	if ( GetTradeSkillSelectionIndex() > GetNumTradeSkills() ) then
		return;
	end
	local color = TradeSkillTypeColor[skillType];
	if ( color ) then
		TradeSkillHighlight:SetVertexColor(color.r, color.g, color.b);
	end

	-- General Info
	local skillLineName, skillLineRank, skillLineMaxRank = GetTradeSkillLine();
	TradeSkillFrameTitleText:SetFormattedText(TRADE_SKILL_TITLE, skillLineName);
	-- Set statusbar info
	TradeSkillRankFrame:SetStatusBarColor(0.0, 0.0, 1.0, 0.5);
	TradeSkillRankFrameBackground:SetVertexColor(0.0, 0.0, 0.75, 0.5);
	TradeSkillRankFrame:SetMinMaxValues(0, skillLineMaxRank);
	TradeSkillRankFrame:SetValue(skillLineRank);
	TradeSkillRankFrameSkillRank:SetText(skillLineRank.."/"..skillLineMaxRank);

	TradeSkillSkillName:SetText(skillName);
	if ( GetTradeSkillCooldown(id) ) then
		TradeSkillSkillCooldown:SetText(COOLDOWN_REMAINING.." "..SecondsToTime(GetTradeSkillCooldown(id)));
	else
		TradeSkillSkillCooldown:SetText("");
	end
	local icon = GetTradeSkillIcon(id);
	if (icon) then
		TradeSkillSkillIcon:SetNormalTexture(icon);
	else
		TradeSkillSkillIcon:ClearNormalTexture();
	end
	local minMade,maxMade = GetTradeSkillNumMade(id);
	if ( maxMade > 1 ) then
		if ( minMade == maxMade ) then
			TradeSkillSkillIconCount:SetText(minMade);
		else
			TradeSkillSkillIconCount:SetText(minMade.."-"..maxMade);
		end
		if ( TradeSkillSkillIconCount:GetWidth() > 39 ) then
			TradeSkillSkillIconCount:SetText("~"..floor((minMade + maxMade)/2));
		end
	else
		TradeSkillSkillIconCount:SetText("");
	end
	
	-- Reagents
	local numReagents = GetTradeSkillNumReagents(id);

	if(numReagents > 0) then
		TradeSkillReagentLabel:Show();
	else
		TradeSkillReagentLabel:Hide();
	end

	for i=1, numReagents, 1 do
		local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
		local reagent = _G["TradeSkillReagent"..i]
		local name = _G["TradeSkillReagent"..i.."Name"];
		local count = _G["TradeSkillReagent"..i.."Count"];
		if ( not reagentName or not reagentTexture ) then
			reagent:Hide();
		else
			reagent:Show();
			SetItemButtonTexture(reagent, reagentTexture);
			name:SetText(reagentName);
			-- Grayout items
			if ( playerReagentCount < reagentCount ) then
				SetItemButtonTextureVertexColor(reagent, 0.5, 0.5, 0.5);
				name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				creatable = nil;
			else
				SetItemButtonTextureVertexColor(reagent, 1.0, 1.0, 1.0);
				name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			end
			if ( playerReagentCount >= 100 ) then
				playerReagentCount = "*";
			end
			count:SetText(playerReagentCount.." /"..reagentCount);
		end
	end
	-- Place reagent label
	local reagentToAnchorTo = numReagents;
	if ( (numReagents > 0) and (mod(numReagents, 2) == 0) ) then
		reagentToAnchorTo = reagentToAnchorTo - 1;
	end
	
	for i=numReagents + 1, MAX_TRADE_SKILL_REAGENTS, 1 do
		_G["TradeSkillReagent"..i]:Hide();
	end

	local spellFocus = BuildColoredListString(GetTradeSkillTools(id));
	if ( spellFocus ) then
		TradeSkillRequirementLabel:Show();
		TradeSkillRequirementText:SetText(spellFocus);
	else
		TradeSkillRequirementLabel:Hide();
		TradeSkillRequirementText:SetText("");
	end

	if ( creatable ) then
		TradeSkillCreateButton:Enable();
		TradeSkillCreateAllButton:Enable();
	else
		TradeSkillCreateButton:Disable();
		TradeSkillCreateAllButton:Disable();
	end
	
	if ( GetTradeSkillDescription(id) ) then
		TradeSkillDescription:SetText(GetTradeSkillDescription(id))
		TradeSkillReagentLabel:SetPoint("TOPLEFT", "TradeSkillDescription", "BOTTOMLEFT", 0, -10);
	else
		TradeSkillDescription:SetText(" ");
		TradeSkillReagentLabel:SetPoint("TOPLEFT", "TradeSkillDescription", "TOPLEFT", 0, 0);
	end

	-- Reset the number of items to be created
	TradeSkillInputBox:SetNumber(GetTradeskillRepeatCount());

	--Hide inapplicable buttons if we are inspecting. Otherwise show them
	if ( IsTradeSkillLinked() ) then
		TradeSkillCreateButton:Hide();
		TradeSkillCreateAllButton:Hide();
		TradeSkillDecrementButton:Hide();
		TradeSkillInputBox:Hide();
		TradeSkillIncrementButton:Hide();
		TradeSkillLinkButton:Hide();
		TradeSkillFrameBottomLeftTexture:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotLeft]]);
		TradeSkillFrameBottomRightTexture:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotRight]]);
	else
		--Change button names and show/hide them depending on if this tradeskill creates an item or casts something
		if ( not altVerb ) then
			--Its an item with 'Create'
			TradeSkillCreateAllButton:Show();
			TradeSkillDecrementButton:Show();
			TradeSkillInputBox:Show();
			TradeSkillIncrementButton:Show();
			
			TradeSkillFrameBottomLeftTexture:SetTexture([[Interface\TradeSkillFrame\UI-TradeSkill-BotLeft]]);
			TradeSkillFrameBottomRightTexture:SetTexture([[Interface\ClassTrainerFrame\UI-ClassTrainer-BotRight]])
		else
			--Its something else, like 'Enchant'
			TradeSkillCreateAllButton:Hide();
			TradeSkillDecrementButton:Hide();
			TradeSkillInputBox:Hide();
			TradeSkillIncrementButton:Hide();
			
			TradeSkillFrameBottomLeftTexture:SetTexture([[Interface\ClassTrainerFrame\UI-ClassTrainer-BotLeft]]);
			TradeSkillFrameBottomRightTexture:SetTexture([[Interface\ClassTrainerFrame\UI-ClassTrainer-BotRight]]);
		end
		if ( GetTradeSkillListLink() ) then
			TradeSkillLinkButton:Show();
		else
			TradeSkillLinkButton:Hide();
		end
		TradeSkillCreateButton:SetText(altVerb or CREATE_PROFESSION);
		TradeSkillCreateButton:Show();
	end
end

function TradeSkillSkillButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		TradeSkillFrame_SetSelection(self:GetID());
		TradeSkillFrame_Update(self);
	end
end

function TradeSkillSearch_OnTextChanged(self)
	local text = self:GetText();

	if ( text == SEARCH ) then
		SetTradeSkillItemNameFilter("");
		return;
	end

	local minLevel, maxLevel;
	local approxLevel = strmatch(text, "^~(%d+)");
	if ( approxLevel ) then
		minLevel = approxLevel - 2;
		maxLevel = approxLevel + 2;
	else
		minLevel, maxLevel = strmatch(text, "^(%d+)%s*-*%s*(%d*)$");
	end
	if ( minLevel ) then
		if ( maxLevel == "" or maxLevel < minLevel ) then
			maxLevel = minLevel;
		end
		SetTradeSkillItemNameFilter(nil);
		SetTradeSkillItemLevelFilter(minLevel, maxLevel);
	else
		SetTradeSkillItemLevelFilter(0, 0);
		SetTradeSkillItemNameFilter(text);
	end
end

function TradeSkillCollapseAllButton_OnClick(self)
	if (self.collapsed) then
		self.collapsed = nil;
		ExpandTradeSkillSubClass(0);
	else
		self.collapsed = 1;
		TradeSkillListScrollFrameScrollBar:SetValue(0);
		CollapseTradeSkillSubClass(0);
	end
end

function TradeSkillFrameIncrement_OnClick(self)
	if ( TradeSkillInputBox:GetNumber() < 100 ) then
		TradeSkillInputBox:SetNumber(TradeSkillInputBox:GetNumber() + 1);
	end
end

function TradeSkillFrameDecrement_OnClick(self)
	if ( TradeSkillInputBox:GetNumber() > 0 ) then
		TradeSkillInputBox:SetNumber(TradeSkillInputBox:GetNumber() - 1);
	end
end

function TradeSkillItem_OnEnter(self)
	if ( TradeSkillFrame.selectedSkill ~= 0 ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetTradeSkillItem(TradeSkillFrame.selectedSkill);
	end
	CursorUpdate(self);
end

function TradeSkillFrame_PlaytimeUpdate(self)
	if ( PartialPlayTime() ) then
		TradeSkillCreateButton:Disable();
		if (not TradeSkillCreateButtonMask:IsShown()) then
			TradeSkillCreateButtonMask:Show();
			TradeSkillCreateButtonMask.tooltip = format(PLAYTIME_TIRED_ABILITY, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		end
	
		TradeSkillCreateAllButton:Disable();
		if (not TradeSkillCreateAllButtonMask:IsShown()) then
			TradeSkillCreateAllButtonMask:Show();
			TradeSkillCreateAllButtonMask.tooltip = format(PLAYTIME_TIRED_ABILITY, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		end
	elseif ( NoPlayTime() ) then
		TradeSkillCreateButton:Disable();
		if (not TradeSkillCreateButtonMask:IsShown()) then
			TradeSkillCreateButtonMask:Show();
			TradeSkillCreateButtonMask.tooltip = format(PLAYTIME_UNHEALTHY_ABILITY, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		end
	
		TradeSkillCreateAllButton:Disable();
		if (not TradeSkillCreateAllButtonMask:IsShown()) then
			TradeSkillCreateAllButtonMask:Show();
			TradeSkillCreateAllButtonMask.tooltip = format(PLAYTIME_UNHEALTHY_ABILITY, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60));
		end
	else
		if (TradeSkillCreateButtonMask:IsShown() or TradeSkillCreateAllButtonMask:IsShown()) then
			TradeSkillCreateButtonMask:Hide();
			TradeSkillCreateButtonMask.tooltip = nil;

			TradeSkillCreateAllButtonMask:Hide();
			TradeSkillCreateAllButtonMask.tooltip = nil;

			TradeSkillFrame_SetSelection(TradeSkillFrame.selectedSkill);
			TradeSkillFrame_Update(self)
		end
	end
end
