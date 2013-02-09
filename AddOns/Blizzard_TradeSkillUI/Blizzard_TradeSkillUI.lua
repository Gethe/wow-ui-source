

TRADE_SKILLS_DISPLAYED = 8;
TRADE_SKILL_GUILD_CRAFTERS_DISPLAYED = 10;
MAX_TRADE_SKILL_REAGENTS = 8;
TRADE_SKILL_HEIGHT = 16;
TRADE_SKILL_TEXT_WIDTH = 270;
TRADE_SKILL_SKILLUP_TEXT_WIDTH = 30;
TRADE_SKILL_LINKED_NAME_WIDTH = 120;
SUB_SKILL_BAR_WIDTH = 60;

TradeSkillTypePrefix = {
["optimal"] = " [+++] ",
["medium"] = " [++] ",
["easy"] = " [+] ",
["trivial"] = " ", 
["header"] = " ",
["subheader"] = " ",
}

TradeSkillTypeColor = { };
TradeSkillTypeColor["optimal"]	= { r = 1.00, g = 0.50, b = 0.25,	font = GameFontNormalLeftOrange };
TradeSkillTypeColor["medium"]	= { r = 1.00, g = 1.00, b = 0.00,	font = GameFontNormalLeftYellow };
TradeSkillTypeColor["easy"]		= { r = 0.25, g = 0.75, b = 0.25,	font = GameFontNormalLeftLightGreen };
TradeSkillTypeColor["trivial"]	= { r = 0.50, g = 0.50, b = 0.50,	font = GameFontNormalLeftGrey };
TradeSkillTypeColor["header"]	= { r = 1.00, g = 0.82, b = 0,		font = GameFontNormalLeft };
TradeSkillTypeColor["subheader"]= { r = 1.00, g = 0.82, b = 0,		font = GameFontNormalLeft };

UIPanelWindows["TradeSkillFrame"] = {area = "left", pushable = 3, showFailedFunc = "TradeSkillFrame_ShowFailed" };

CURRENT_TRADESKILL = "";

local SUBSKILL_RANKS = { };				-- tracks subskill ranks for figuring out which one just skilled up in order to flash the rank numbers
local SUBSKILL_FLASH_BAR;				-- the subskill progress bar that's currently flashing
local SUBSKILL_FLASH_NAME;				-- the name of the subskill that's currently flashing
local SUBSKILL_FLASH_ELAPSED_TIME;		-- current elapsed time for the flash
local SUBSKILL_FLASH_DURATION = 1;		-- how long the flash should take

function TradeSkillFrame_Show()
	ShowUIPanel(TradeSkillFrame);
	TradeSkillCreateButton:Disable();
	TradeSkillCreateAllButton:Disable();
	local tsIndex = 0;
	if ( GetTradeSkillSelectionIndex() == 0 ) then
		tsIndex = GetFirstTradeSkill();
	else
		tsIndex = GetTradeSkillSelectionIndex();
	end	
	TradeSkillFrame_SetSelection(tsIndex);
	
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	TradeSkillListScrollFrameScrollBar.doNotHide = true;
	TradeSkillListScrollFrameScrollBar:SetMinMaxValues(0, 0); 
	TradeSkillListScrollFrameScrollBar:SetValue(0);
	if ( IsTradeSkillGuild() ) then
		TradeSkillFramePortrait:Hide();
		TradeSkillFrameTabardBackground:Show();
		TradeSkillFrameTabardEmblem:Show();
		TradeSkillFrameTabardBorder:Show();
		SetLargeGuildTabardTextures("player", TradeSkillFrameTabardEmblem, TradeSkillFrameTabardBackground, TradeSkillFrameTabardBorder);
	else
		TradeSkillFrameTabardBackground:Hide();
		TradeSkillFrameTabardEmblem:Hide();
		TradeSkillFrameTabardBorder:Hide();
		TradeSkillFramePortrait:Show();
		SetPortraitToTexture(TradeSkillFramePortrait, GetTradeSkillTexture() );
	end
	TradeSkillOnlyShowMakeable(TradeSkillFrame.filterTbl.hasMaterials);
	TradeSkillOnlyShowSkillUps(TradeSkillFrame.filterTbl.hasSkillUp);
	TradeSkillFrame_Update();

	TradeSkillSetFilter(-1, -1);		
	-- Moved to the bottom to prevent addons which hook it from blocking tradeskills
	CloseDropDownMenus();
end

function TradeSkillFrame_Hide()
	HideUIPanel(TradeSkillFrame);
end

function TradeSkillFrame_ShowFailed(self)
	CloseTradeSkill();
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
	
	self.text:SetFontObject(GameFontHighlightLeft);
	self.text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
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
		
		self.text:SetFontObject(self.font);
		self.text:SetVertexColor(self.r, self.g, self.b);
	end
	self.SubSkillRankBar.Rank:SetText("");
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
		end
		TradeSkillFrame_Update();
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local arg1 = ...;
		if ( not arg1 or arg1 == "player" ) then
			SetPortraitTexture(TradeSkillFramePortrait, "player");
		end
	elseif ( event == "UPDATE_TRADESKILL_RECAST" ) then
		TradeSkillInputBox:SetNumber(GetTradeskillRepeatCount());
	elseif ( event == "GUILD_RECIPE_KNOWN_BY_MEMBERS" ) then
		if ( TradeSkillGuildFrame.queriedSkill == TradeSkillFrame.selectedSkill ) then
			TradeSkillGuildFrame:Show();
		end
	elseif ( event == "TRADE_SKILL_NAME_UPDATE" ) then
		TradeSkillFrame_SetLinkName();
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		TradeSkillFrame_Update();
	end
end

function TradeSkillFrame_Update()
	local numTradeSkills = GetNumTradeSkills();
	local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
	local name, rank, maxRank = GetTradeSkillLine();
    local isTradeSkillGuild = IsTradeSkillGuild();
	
	if ( CURRENT_TRADESKILL ~= name ) then
		StopTradeSkillRepeat();
		if ( CURRENT_TRADESKILL ~= "" ) then
			-- To fix problem with switching between two tradeskills
			UIDropDownMenu_Initialize(TradeSkillFilterDropDown, TradeSkillFilterDropDown_Initialize);
			--TradeSkillSetFilter(-1, -1);
			
			--UIDropDownMenu_SetSelectedID(TradeSkillFilterDropDown, 1);

			--UIDropDownMenu_Initialize(TradeSkillSubClassDropDown, TradeSkillSubClassDropDown_Initialize);
			--UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, 1);
		end
		CURRENT_TRADESKILL = name;
	end

	if ( not IsTradeSkillReady() ) then
		numTradeSkills = 0;
		TradeSkillFrameSearchBox:SetEnabled(false);
		TradeSkillFilterButton:SetEnabled(false);
		TradeSkillLinkButton:SetEnabled(false);
		TradeSkillFrame.RetrievingFrame:Show();
	else
		TradeSkillFrameSearchBox:SetEnabled(true);
		TradeSkillFilterButton:SetEnabled(true);
		TradeSkillLinkButton:SetEnabled(true);
		TradeSkillFrame.RetrievingFrame:Hide();
	end

	-- If no tradeskills
	if ( numTradeSkills == 0 ) then
		TradeSkillFrameTitleText:SetFormattedText(TRADE_SKILL_TITLE, GetTradeSkillLine());
		TradeSkillSkillName:Hide();
		TradeSkillSkillIcon:Hide();
		TradeSkillRequirementLabel:Hide();
		TradeSkillRequirementText:SetText("");
		TradeSkillCollapseAllButton:Disable();
		for i=1, MAX_TRADE_SKILL_REAGENTS, 1 do
			_G["TradeSkillReagent"..i]:Hide();
		end
	else
		TradeSkillSkillName:Show();
		TradeSkillSkillIcon:Show();
		TradeSkillCollapseAllButton:Enable();
	end

	
	TradeSkillHighlightFrame:Hide();
	local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps, indentLevel, showProgressBar, currentRank, maxRank, startingRank;
	local skillIndex, skillButton, skillButtonText, skillButtonCount, skillButtonNumSkillUps, skillButtonNumSkillUpsIcon, skillButtonNumSkillUpsText, skillButtonSubSkillRankBar;
	local nameWidth, countWidth, usedWidth;
	
	local skillNamePrefix = " ";
	local diplayedSkills = TRADE_SKILLS_DISPLAYED;
	local hasFilterBar = TradeSkillFilterBar:IsShown();
	local numList = numTradeSkills;
	if  hasFilterBar then
		diplayedSkills = TRADE_SKILLS_DISPLAYED - 1;
		numList = numList+1;
	end	
	local buttonIndex = 0;

	-- ScrollFrame update
	FauxScrollFrame_Update(TradeSkillListScrollFrame, numList, TRADE_SKILLS_DISPLAYED, TRADE_SKILL_HEIGHT, nil, nil, nil, TradeSkillHighlightFrame, 293, 316, true );
	
	for i=1, diplayedSkills, 1 do
		skillIndex = i + skillOffset;
		skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps, indentLevel, showProgressBar, currentRank, maxRank, startingRank = GetTradeSkillInfo(skillIndex);

		if hasFilterBar then
			buttonIndex = i+1;
		else
			buttonIndex = i;
		end
		
		skillButton = _G["TradeSkillSkill"..buttonIndex];
		skillButtonText = _G["TradeSkillSkill"..buttonIndex.."Text"];
		skillButtonCount = _G["TradeSkillSkill"..buttonIndex.."Count"];
		skillButtonNumSkillUps = _G["TradeSkillSkill"..buttonIndex.."NumSkillUps"];
		skillButtonNumSkillUpsText = _G["TradeSkillSkill"..buttonIndex.."NumSkillUpsText"];
		skillButtonNumSkillUpsIcon = _G["TradeSkillSkill"..buttonIndex.."NumSkillUpsIcon"];
		skillButtonSubSkillRankBar = _G["TradeSkillSkill"..buttonIndex.."SubSkillRankBar"];
		if ( skillIndex <= numTradeSkills ) then
			--turn on the multiskill icon
			if not isTradeSkillGuild and numSkillUps > 1 and skillType=="optimal" then
				skillButtonNumSkillUps:Show();
				skillButtonNumSkillUpsText:SetText(numSkillUps);
				usedWidth = TRADE_SKILL_SKILLUP_TEXT_WIDTH;
			else 
				skillButtonNumSkillUps:Hide();
				usedWidth = 0;
			end

			local color;
			-- override colors for guild
			if ( isTradeSkillGuild and skillType ~= "header" and skillType ~= "subheader" ) then
				color = TradeSkillTypeColor["easy"];
			else
				color = TradeSkillTypeColor[skillType];
			end
			if ( color ) then
				skillButton:SetNormalFontObject(color.font);
				skillButtonText:SetVertexColor(color.r, color.g, color.b);
				skillButtonCount:SetVertexColor(color.r, color.g, color.b);
				skillButton.r = color.r;
				skillButton.g = color.g;
				skillButton.b = color.b;
				skillButton.font = color.font;
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
				skillButtonCount:SetText("");
				if ( isExpanded ) then
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				else
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				end
				_G["TradeSkillSkill"..buttonIndex.."Highlight"]:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
				skillButton:UnlockHighlight();
				skillButton.isHighlighted = false;
			else
				if ( not skillName ) then
					return;
				end
				skillButton:SetNormalTexture("");
				_G["TradeSkillSkill"..buttonIndex.."Highlight"]:SetTexture("");
				if ( numAvailable <= 0 ) then
					skillButton:SetText(skillNamePrefix..skillName);
					skillButtonCount:SetText("");
					textWidth = textWidth - usedWidth;
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
					TradeSkillHighlightFrame:SetPoint("TOPLEFT", "TradeSkillSkill"..buttonIndex, "TOPLEFT", 0, 0);
					TradeSkillHighlightFrame:Show();
					skillButtonText:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
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
		local skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(i);
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
	if ( not IsTradeSkillReady() ) then
		id = 0;
	end

	local skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(id);
	local creatable = 1;
	if ( not skillName ) then
		creatable = nil;
	end
	TradeSkillHighlightFrame:Show();
	TradeSkillGuildFrame.queriedSkill = nil;		-- always cancel any pending queries
	TradeSkillGuildFrame:Hide();
	if ( skillType == "header" or skillType == "subheader" ) then
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
	
	TradeSkillSkillName:SetText(skillName);
	local cooldown, isDayCooldown = GetTradeSkillCooldown(id);
	
	if ( not cooldown ) then
		TradeSkillSkillCooldown:SetText("");
	elseif ( not isDayCooldown ) then
		TradeSkillSkillCooldown:SetText(COOLDOWN_REMAINING.." "..SecondsToTime(cooldown));
	elseif ( cooldown > 60 * 60 * 24 ) then	--Cooldown is greater than 1 day.
		TradeSkillSkillCooldown:SetText(COOLDOWN_REMAINING.." "..SecondsToTime(cooldown, true, false, 1, true));
	else
		TradeSkillSkillCooldown:SetText(COOLDOWN_EXPIRES_AT_MIDNIGHT);
	end

	TradeSkillSkillIcon:SetNormalTexture(GetTradeSkillIcon(id));
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
			--fix text overflow when the reagent count is too high
			if (math.floor(count:GetStringWidth()) > math.floor(reagent.icon:GetWidth() + .5)) then 
			--round count width down because the leftmost number can overflow slightly without looking bad
			--round icon width because it should always be an int, but sometimes it's a slightly off float
				count:SetText(playerReagentCount.."\n/"..reagentCount);
			end
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


	local skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier = GetTradeSkillLine();
	local color;
	
	--Hide inapplicable buttons if we are inspecting. Otherwise show them
	if ( IsTradeSkillGuild() ) then
		-- highlight color
		color = TradeSkillTypeColor["easy"];
		-- title
		TradeSkillFrameTitleText:SetFormattedText(GUILD_TRADE_SKILL_TITLE, skillLineName);
		-- bottom bar
		TradeSkillCreateButton:Hide();
		TradeSkillCreateAllButton:Hide();
		TradeSkillDecrementButton:Hide();
		TradeSkillInputBox:Hide();
		TradeSkillIncrementButton:Hide();
		TradeSkillLinkButton:Hide();
		TradeSkillViewGuildCraftersButton:Show();
		if ( GetTradeSkillSelectionIndex() > 0 ) then
			TradeSkillViewGuildCraftersButton:Enable();
		else
			TradeSkillViewGuildCraftersButton:Disable();
		end
		-- status bar
		TradeSkillRankFrame:Hide();	
	else
		-- highlight color
		color = TradeSkillTypeColor[skillType];
		-- title
		TradeSkillFrameTitleText:SetFormattedText(TRADE_SKILL_TITLE, skillLineName);
		-- bottom bar
		TradeSkillViewGuildCraftersButton:Hide();
		-- status bar
		TradeSkillRankFrame:SetStatusBarColor(0.0, 0.0, 1.0, 0.5);
		TradeSkillRankFrameBackground:SetVertexColor(0.0, 0.0, 0.75, 0.5);
		TradeSkillRankFrame:SetMinMaxValues(0, skillLineMaxRank);
		TradeSkillRankFrame:SetValue(skillLineRank);
		if ( skillLineModifier > 0 ) then
			TradeSkillRankFrameSkillRank:SetFormattedText(TRADESKILL_RANK_WITH_MODIFIER, skillLineRank, skillLineModifier, skillLineMaxRank);
		else
			TradeSkillRankFrameSkillRank:SetFormattedText(TRADESKILL_RANK, skillLineRank, skillLineMaxRank);
		end
		
		if IsTrialAccount() then
			local _, _, profCap = GetRestrictedAccountData();
			if skillLineRank >= profCap then
				local text = TradeSkillRankFrameSkillRank:GetText();
				text = text.." "..RED_FONT_COLOR_CODE..TRIAL_CAPPED
				TradeSkillRankFrameSkillRank:SetText(text);
			end
		end

		TradeSkillRankFrame:Show();
		
		local linked = IsTradeSkillLinked();
		if ( linked ) then
			TradeSkillCreateButton:Hide();
			TradeSkillCreateAllButton:Hide();
			TradeSkillDecrementButton:Hide();
			TradeSkillInputBox:Hide();
			TradeSkillIncrementButton:Hide();
			TradeSkillLinkButton:Hide();
		else		
			--Change button names and show/hide them depending on if this tradeskill creates an item or casts something
			if ( not altVerb ) then
				--Its an item with 'Create'
				TradeSkillCreateAllButton:Show();
				TradeSkillDecrementButton:Show();
				TradeSkillInputBox:Show();
				TradeSkillIncrementButton:Show();
			else
				--Its something else
				TradeSkillCreateAllButton:Hide();
				TradeSkillDecrementButton:Hide();
				TradeSkillInputBox:Hide();
				TradeSkillIncrementButton:Hide();				
				--TradeSkillFrameBottomLeftTexture:SetTexture([[Interface\ClassTrainerFrame\UI-ClassTrainer-BotLeft]]);
				--TradeSkillFrameBottomRightTexture:SetTexture([[Interface\ClassTrainerFrame\UI-ClassTrainer-BotRight]]);
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
	TradeSkillFrame_SetLinkName();
	if ( color ) then
		TradeSkillHighlight:SetVertexColor(color.r, color.g, color.b);
	end	
end

function TradeSkillFrame_SetLinkName()
	local linked, linkedName = IsTradeSkillLinked();
	TradeSkillFrameTitleText:ClearAllPoints();
	if ( linkedName ) then
		TradeSkillLinkNameButton:Show();
		local linkedText = "["..linkedName.."]";
		TradeSkillFrameDummyString:Show();
		TradeSkillFrameDummyString:Hide();
		TradeSkillFrameDummyString:SetText(linkedText);
		local linkedNameWidth = TradeSkillFrameDummyString:GetWidth();
		if linkedNameWidth > TRADE_SKILL_LINKED_NAME_WIDTH then
			linkedNameWidth = TRADE_SKILL_LINKED_NAME_WIDTH;
		end
		TradeSkillLinkNameButton:SetWidth(linkedNameWidth);
		TradeSkillLinkNameButtonTitleText:SetWidth(linkedNameWidth);
		TradeSkillLinkNameButtonTitleText:SetText(linkedText);
		TradeSkillLinkNameButton.linkedName = linkedName;
		TradeSkillFrameTitleText:SetPoint("TOP", -linkedNameWidth/2,  -4);
	else
		TradeSkillLinkNameButton:Hide();
		TradeSkillFrameTitleText:SetPoint("TOP", 0,  -4);
	end
end

function TradeSkillSkillButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		TradeSkillFrame_SetSelection(self:GetID());
		TradeSkillFrame_Update();
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


-- DROP DOWN MENU MAGIC


-- function TradeSkillSubClassDropDown_OnLoad(self)
	-- SetTradeSkillSubClassFilter(0, 1, 1);
	-- UIDropDownMenu_Initialize(self, TradeSkillSubClassDropDown_Initialize);
	-- UIDropDownMenu_SetWidth(self, 120);
	-- UIDropDownMenu_SetSelectedID(self, 1);
-- end

-- function TradeSkillSubClassDropDown_Initialize()
	-- TradeSkillFilterFrame_LoadSubClasses(GetTradeSkillSubClasses());
-- end

-- function TradeSkillFilterFrame_LoadSubClasses(...)
	-- local selectedID = UIDropDownMenu_GetSelectedID(TradeSkillSubClassDropDown);
	-- local numSubClasses = select("#", ...);
	-- local allChecked = GetTradeSkillSubClassFilter(0);

	-- -- the first button in the list is going to be an "all subclasses" button
	-- local info = UIDropDownMenu_CreateInfo();
	-- info.text = ALL_SUBCLASSES;
	-- info.func = TradeSkillSubClassDropDownButton_OnClick;
	-- -- select this button if nothing else was selected
	-- info.checked = allChecked and (selectedID == nil or selectedID == 1);
	-- UIDropDownMenu_AddButton(info);
	-- if ( info.checked ) then
		-- UIDropDownMenu_SetText(TradeSkillSubClassDropDown, ALL_SUBCLASSES);
	-- end

	-- local checked;
	-- for i=1, select("#", ...), 1 do
		-- -- if there are no filters then don't check any individual subclasses
		-- if ( allChecked ) then
			-- checked = nil;
		-- else
			-- checked = GetTradeSkillSubClassFilter(i);
			-- if ( checked ) then
				-- UIDropDownMenu_SetText(TradeSkillSubClassDropDown, select(i, ...));
			-- end
		-- end
		-- info.text = select(i, ...);
		-- info.func = TradeSkillSubClassDropDownButton_OnClick;
		-- info.checked = checked;
		-- UIDropDownMenu_AddButton(info);
	-- end
-- end

function TradeSkillFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, TradeSkillFilterDropDown_Initialize, "MENU");
	TradeSkillFilterDropDownText:SetJustifyH("CENTER");
	TradeSkillFilterDropDownButton:Show();
end


function TradeSkillUpdateFilterBar(subName, slotName)

	local filterText = "";
	if TradeSkillFrame.filterTbl.hasMaterials then 
		filterText = filterText..CRAFT_IS_MAKEABLE;
	end
	
	if TradeSkillFrame.filterTbl.hasSkillUp then 
		if filterText ~= "" then filterText = filterText..", "; end
		filterText = filterText..TRADESKILL_FILTER_HAS_SKILL_UP;
	end

	if TradeSkillFrame.filterTbl.subClassValue > 0 then 	
		if filterText ~= "" then filterText = filterText..", "; end 
		if not subName then
			subName = TradeSkillFrame.filterTbl.subClassText;
		end
		filterText = filterText..subName;
		TradeSkillFrame.filterTbl.subClassText = subName;
	end
	
	if TradeSkillFrame.filterTbl.slotValue > 0 then 
		if filterText ~= "" then filterText = filterText..", "; end
		if not slotName then
			slotName = TradeSkillFrame.filterTbl.slotText;
		end
		filterText = filterText..slotName;
		TradeSkillFrame.filterTbl.slotText = slotName;
	end

	 if filterText == "" then
		TradeSkillFilterBar:Hide();
		TradeSkillSkill1:Show();
		
	else
		TradeSkillFilterBar:Show();	
		TradeSkillSkill1:Hide();
		TradeSkillFilterBarText:SetText(FILTER..": "..filterText);
	end

	TradeSkillListScrollFrameScrollBar:SetValue(0);
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	TradeSkillFrame_Update();
end

function TradeSkillSetFilter(subclass, slot, subName, slotName, subclassCategory)

	TradeSkillFrame.filterTbl.subClassValue = subclass;
	TradeSkillFrame.filterTbl.slotValue = slot;

	SetTradeSkillCategoryFilter(subclass, subclassCategory);
	SetTradeSkillInvSlotFilter(slot, 1, 1);

	
	TradeSkillUpdateFilterBar(subName, slotName);
	CloseDropDownMenus();
end


function TradeSkillFilterDropDown_Initialize(self, level)
	
	local info = UIDropDownMenu_CreateInfo();
	
	if level == 1 then
	
		info.text = CRAFT_IS_MAKEABLE
		info.func = 	function() 
							TradeSkillFrame.filterTbl.hasMaterials  = not TradeSkillFrame.filterTbl.hasMaterials;
							TradeSkillOnlyShowMakeable(TradeSkillFrame.filterTbl.hasMaterials);  
							TradeSkillUpdateFilterBar();
						end 
		info.keepShownOnClick = true;
		info.checked = 	TradeSkillFrame.filterTbl.hasMaterials
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		
		if ( not IsTradeSkillGuild() ) then
			info.text = TRADESKILL_FILTER_HAS_SKILL_UP;
			info.func = 	function() 
								TradeSkillFrame.filterTbl.hasSkillUp  = not TradeSkillFrame.filterTbl.hasSkillUp;
								TradeSkillOnlyShowSkillUps(TradeSkillFrame.filterTbl.hasSkillUp);
								TradeSkillUpdateFilterBar();
							end 
			info.keepShownOnClick = true;
			info.checked = 	TradeSkillFrame.filterTbl.hasSkillUp;
			info.isNotRadio = true;
			UIDropDownMenu_AddButton(info, level);
		end
		
		info.checked = 	nil;
		info.isNotRadio = nil;
				
		info.text = TRADESKILL_FILTER_SLOTS
		info.func =  nil;
		info.notCheckable = true;
		info.keepShownOnClick = false;
		info.hasArrow = true;	
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)
				
		info.text = TRADESKILL_FILTER_SUBCLASS
		info.func =  nil;
		info.notCheckable = true;
		info.keepShownOnClick = false;
		info.hasArrow = true;
		info.value = 2;
		UIDropDownMenu_AddButton(info, level)
	
	elseif level == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			local slots = { GetTradeSkillSubClassFilteredSlots(0) };
			local subslots = {};
			for i,slot in pairs(slots) do
				info.text = slot;
				info.func =  function() TradeSkillSetFilter(0, i, "", slots[i]); end;
				info.notCheckable = true;
				info.hasArrow = false;	
				UIDropDownMenu_AddButton(info, level);
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
			local subClasses = { GetTradeSkillSubClasses() };
			local subslots = {};
			for i,subClass in pairs(subClasses) do
				info.text = subClass;
				info.func =  function() TradeSkillSetFilter(i, 0, subClasses[i], "", 0); end
				info.notCheckable = true;
				subslots  = { GetTradeSkillSubCategories(i) };
				info.hasArrow = #subslots > 1;
				info.value = i;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	elseif level == 3 then	
		local subClasses = { GetTradeSkillSubClasses() };
		local subslots;
		subslots = { GetTradeSkillSubCategories(UIDROPDOWNMENU_MENU_VALUE) };
		for i,slot in pairs(subslots) do
			info.text = slot;
			info.func =  function() TradeSkillSetFilter(UIDROPDOWNMENU_MENU_VALUE, 0, subClasses[UIDROPDOWNMENU_MENU_VALUE], subslots[i], i); end
			info.notCheckable = true;
			info.value = {UIDROPDOWNMENU_MENU_VALUE, i};
			UIDropDownMenu_AddButton(info, level);
		end
	end

end

-- function TradeSkillFilterFrame_InvSlotName(...)
	-- for i=1, select("#", ...), 1 do
		-- if ( GetTradeSkillInvSlotFilter(i) ) then
			-- return select(i, ...);
		-- end
	-- end
-- end

-- function TradeSkillSubClassDropDownButton_OnClick(self)
	-- UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, self:GetID());
	-- SetTradeSkillSubClassFilter(self:GetID() - 1, 1, 1);
	-- if ( self:GetID() ~= 1 ) then
		-- if ( TradeSkillFilterFrame_InvSlotName(GetTradeSkillInvSlots()) ~= TradeSkillFilterDropDown.selected ) then
			-- SetTradeSkillInvSlotFilter(0, 1, 1);
			-- UIDropDownMenu_SetSelectedID(TradeSkillFilterDropDown, 1);
			-- UIDropDownMenu_SetText(TradeSkillFilterDropDown, FILTER);
		-- end
	-- end
	-- TradeSkillListScrollFrameScrollBar:SetValue(0);
	-- FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	-- TradeSkillFrame_Update();
-- end

-- function TradeSkillFilterDropDownButton_OnClick(self)
	-- UIDropDownMenu_SetSelectedID(TradeSkillFilterDropDown, self:GetID());
	-- SetTradeSkillInvSlotFilter(self:GetID() - 1, 1, 1);
	-- --TradeSkillFilterDropDown.selected = TradeSkillFilterFrame_InvSlotName(GetTradeSkillInvSlots());
	-- TradeSkillListScrollFrameScrollBar:SetValue(0);
	-- FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	-- TradeSkillFrame_Update();
-- end

function TradeSkillFrameIncrement_OnClick()
	if ( TradeSkillInputBox:GetNumber() < 100 ) then
		TradeSkillInputBox:SetNumber(TradeSkillInputBox:GetNumber() + 1);
	end
end

function TradeSkillFrameDecrement_OnClick()
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

function TradeSkillFrame_PlaytimeUpdate()
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
			TradeSkillFrame_Update()
		end
	end
end

function TradeSkillLinkDropDown_LinkPost(self, chan)
	local link = GetTradeSkillListLink();
	if link then 
		ChatFrame_OpenChat(chan.." "..link, DEFAULT_CHAT_FRAME);
	end
end


function TradeSkillLinkDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, TradeSkillLinkDropDown_Init, "MENU");
end

function TradeSkillLinkDropDown_Init(self, level)

	local info = UIDropDownMenu_CreateInfo();	
	info.notCheckable = true;	
	info.text = TRADESKILL_POST;
	info.isTitle = 1;
	UIDropDownMenu_AddButton(info);
	info.isTitle = nil;
	
	info = UIDropDownMenu_CreateInfo();	
	info.notCheckable = true;
	info.func = TradeSkillLinkDropDown_LinkPost
	
	info.text = GUILD;
	info.arg1 = SLASH_GUILD1;
	info.disabled = not IsInGuild();
	UIDropDownMenu_AddButton(info);
	
	info.text = PARTY;
	info.arg1 = SLASH_PARTY1;
	info.disabled = GetNumSubgroupMembers() == 0;
	UIDropDownMenu_AddButton(info);
	
	info.text = RAID;
	info.disabled = not IsInRaid();
	info.arg1 = SLASH_RAID1;
	UIDropDownMenu_AddButton(info);
	-- info.text = SAY;
	-- info.arg1 = SLASH_SAY1;
	-- UIDropDownMenu_AddButton(info);
	
	info.disabled = false
	local name;
	local chanels = {GetChannelList()};
	local channelCount = #chanels/2;
	for i=1, MAX_CHANNEL_BUTTONS, 1 do
		if ( i <= channelCount) then
			info.text = chanels[i*2];
			info.arg1 = "/"..chanels[(i-1)*2 + 1];
			UIDropDownMenu_AddButton(info);
		end
	end
end

--
-- Guild Crafters
--

function TradeSkillViewGuildCraftersButton_OnClick()
	TradeSkillGuildFrame.queriedSkill = TradeSkillFrame.selectedSkill;
	QueryGuildMembersForRecipe();
end

function TradeSkillGuildFrame_OnShow()
	TradeSkillGuildCraftersFrameScrollBar:SetValue(0);
	TradeSkillGuilCraftersFrame_Update();
end

function TradeSkillGuilCraftersFrame_Update()
	local skillLineID, recipeID, numMembers = GetGuildRecipeInfoPostQuery();
	local offset = FauxScrollFrame_GetOffset(TradeSkillGuildCraftersFrame);
	local index, button, name, classFileName, online;
	
	for i = 1, TRADE_SKILL_GUILD_CRAFTERS_DISPLAYED, 1 do
		index = i + offset;
		button = _G["TradeSkillGuildCrafter"..i];
		if ( index > numMembers ) then
			button:Hide();
		else
			name, classFileName, online = GetGuildRecipeMember(index);
			button:SetText(name);
			if ( online ) then
				button:Enable();
				if ( classFileName ) then
					local classColor = RAID_CLASS_COLORS[classFileName];
					_G["TradeSkillGuildCrafter"..i.."Text"]:SetTextColor(classColor.r, classColor.g, classColor.b);				
				end
			else
				button:Disable();
			end
			button:Show();
			button.name = name;
		end
	end
	FauxScrollFrame_Update(TradeSkillGuildCraftersFrame, numMembers, TRADE_SKILL_GUILD_CRAFTERS_DISPLAYED, TRADE_SKILL_HEIGHT);
end

function TradeSkillRetrievingFrame_OnUpdate(self, elapsed)
	if ( not self.timer ) then
		self.timer = 0.3;
	elseif ( self.timer < 0 ) then
		local dotCount = self.dotCount or 0;
		dotCount = dotCount + 1;
		if ( dotCount > 3 ) then
			dotCount = 0;
		end
		self.Dots:SetText(string.rep(".", dotCount));
		self.dotCount = dotCount;
		self.timer = 0.3;
	else
		self.timer = self.timer - elapsed;
	end
end