TRADE_SKILLS_DISPLAYED = 8;
MAX_TRADE_SKILL_REAGENTS = 8;
TRADE_SKILL_HEIGHT = 16;
TRADE_SKILL_TEXT_WIDTH = 275;

-- Used to denote skill types in Colorblind mode
TradeSkillTypePrefix = {
["optimal"] = " [+++] ",
["medium"] = " [++] ",
["easy"] = " [+] ",
["trivial"] = " ", 
["header"] = " ",
}

-- Used to denote skill types outside of Colorblind mode
TradeSkillTypeColor = { };
TradeSkillTypeColor["optimal"]	= { r = 1.00, g = 0.50, b = 0.25, font = "GameFontNormalLeftOrange" };       
TradeSkillTypeColor["medium"]	= { r = 1.00, g = 1.00, b = 0.00, font = "GameFontNormalLeftYellow" };       
TradeSkillTypeColor["easy"]		= { r = 0.25, g = 0.75, b = 0.25, font = "GameFontNormalLeftLightGreen" };   
TradeSkillTypeColor["trivial"]	= { r = 0.50, g = 0.50, b = 0.50, font = "GameFontNormalLeftGrey" };         
TradeSkillTypeColor["header"]	= { r = 1.00, g = 0.82, b = 0,    font = "GameFontNormalLeft" };

-- Current Trade Skill name. Used for detecting if the player swaps which tradeskill the window should show.
local currentTradeSkillName = "";

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
	TradeSkillListScrollFrameScrollBar:SetMinMaxValues(0, 0); 
	TradeSkillListScrollFrameScrollBar:SetValue(0);
	SetPortraitTexture(TradeSkillFramePortrait, "player");
	TradeSkillOnlyShowMakeable(TradeSkillFrameAvailableFilterCheckButton:GetChecked());
	TradeSkillFrame_Update();

	-- Moved to the bottom to prevent addons which hook it from blocking tradeskills
	CloseDropDownMenus();
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
		TradeSkillFrame_Update();
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( arg1 == "player" ) then
			SetPortraitTexture(TradeSkillFramePortrait, "player");
		end
	elseif ( event == "UPDATE_TRADESKILL_RECAST" ) then
		TradeSkillInputBox:SetNumber(GetTradeskillRepeatCount());
	end
end

function TradeSkillFrame_Update()
	local numTradeSkills = GetNumTradeSkills();
	local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
	local name, rank, maxRank = GetTradeSkillLine();

	if (currentTradeSkillName ~= name) then
		StopTradeSkillRepeat();
		if(currentTradeSkillName ~= "" ) then
			-- To fix problem with switching between two tradeskills
			UIDropDownMenu_Initialize(TradeSkillInvSlotDropDown, TradeSkillInvSlotDropDown_Initialize);
			UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, 1);

			UIDropDownMenu_Initialize(TradeSkillSubClassDropDown, TradeSkillSubClassDropDown_Initialize);
			UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, 1);
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
		TradeSkillFrameEditBox:Hide();
		SetTradeSkillItemNameFilter("");	--In case they are switching from an inspect WITH a filter directly to their own without.
	else
		TradeSkillFrameEditBox:Show();
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(TradeSkillListScrollFrame, numTradeSkills, TRADE_SKILLS_DISPLAYED, TRADE_SKILL_HEIGHT, nil, nil, nil, TradeSkillHighlightFrame, 293, 316 );

	TradeSkillHighlightFrame:Hide();

	local skillName, skillType, numAvailable, isExpanded, altVerb;
	local skillIndex, skillButton, skillButtonText, skillButtonCount;
	local nameWidth, countWidth;

	local skillNamePrefix = " ";
	for i=1, TRADE_SKILLS_DISPLAYED, 1 do
		skillIndex = i + skillOffset;
		skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(skillIndex);
		skillButton = _G["TradeSkillSkill"..i];
		skillButtonText = _G["TradeSkillSkill"..i.."Text"];
		skillButtonCount = _G["TradeSkillSkill"..i.."Count"];
		if ( skillIndex <= numTradeSkills ) then	
			-- Set button widths if scrollbar is shown or hidden
			if ( TradeSkillListScrollFrame:IsShown() ) then
				skillButton:SetWidth(293);
			else
				skillButton:SetWidth(323);
			end
			local color = TradeSkillTypeColor[skillType];
			if ( color ) then
				skillButton:SetNormalFontObject(color.font);
				skillButtonCount:SetVertexColor(color.r, color.g, color.b);
				skillButton.r = color.r;
				skillButton.g = color.g;
				skillButton.b = color.b;
			end

			if ( ENABLE_COLORBLIND_MODE == "1" ) then
				skillNamePrefix = TradeSkillTypePrefix[skillType] or " ";
			end
			
			skillButton:SetID(skillIndex);
			skillButton:Show();
			-- Handle headers
			if ( skillType == "header" ) then
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
			-- Handle skill entries
			else
				if ( not skillName ) then
					return;
				end
				skillButton:SetNormalTexture("");
				_G["TradeSkillSkill"..i.."Highlight"]:SetTexture("");
				-- None creatable, no brackets needed
				if ( numAvailable <= 0 ) then
					skillButton:SetText(skillNamePrefix..skillName);
					skillButtonText:SetWidth(TRADE_SKILL_TEXT_WIDTH);
					skillButtonCount:SetText(skillCountPrefix);
				-- Some creatable, handle showing num in brackets
				else
					skillName = skillNamePrefix..skillName;
					skillButtonCount:SetText("["..numAvailable.."]");
					TradeSkillFrameDummyString:SetText(skillName);
					nameWidth = TradeSkillFrameDummyString:GetWidth();
					countWidth = skillButtonCount:GetWidth();
					skillButtonText:SetText(skillName);
					if ( nameWidth + 2 + countWidth > TRADE_SKILL_TEXT_WIDTH ) then
						skillButtonText:SetWidth(TRADE_SKILL_TEXT_WIDTH-2-countWidth);
					else
						skillButtonText:SetWidth(0);
					end
				end
				
				-- Place the highlight and lock the highlight state
				if ( GetTradeSkillSelectionIndex() == skillIndex ) then
					TradeSkillHighlightFrame:SetPoint("TOPLEFT", "TradeSkillSkill"..i, "TOPLEFT", 0, 0);
					TradeSkillHighlightFrame:Show();
					skillButtonCount:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
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
		if ( skillName and skillType == "header" ) then
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

function TradeSkillFrame_SetSelection(id)
	local skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(id);
	local creatable = 1;
	if( not skillName ) then
		creatable = nil;
	end
	TradeSkillHighlightFrame:Show();
	if ( skillType == "header" ) then
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
		TradeSkillCreateButton:SetText(altVerb or CREATE);
		TradeSkillCreateButton:Show();
	end
end

function TradeSkillSkillButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		TradeSkillFrame_SetSelection(self:GetID());
		TradeSkillFrame_Update();
	end
end

function TradeSkillFilter_OnTextChanged(self)
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

function TradeSkillSubClassDropDown_OnLoad(self)
	SetTradeSkillSubClassFilter(0, 1, 1);
	UIDropDownMenu_Initialize(self, TradeSkillSubClassDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 120);
	UIDropDownMenu_SetSelectedID(self, 1);
end

function TradeSkillSubClassDropDown_Initialize()
	TradeSkillFilterFrame_LoadSubClasses(GetTradeSkillSubClasses());
end

function TradeSkillFilterFrame_LoadSubClasses(...)
	local selectedID = UIDropDownMenu_GetSelectedID(TradeSkillSubClassDropDown);
	local numSubClasses = select("#", ...);
	local allChecked = GetTradeSkillSubClassFilter(0);

	-- the first button in the list is going to be an "all subclasses" button
	local info = UIDropDownMenu_CreateInfo();
	info.text = ALL_SUBCLASSES;
	info.func = TradeSkillSubClassDropDownButton_OnClick;
	-- select this button if nothing else was selected
	info.checked = allChecked and (selectedID == nil or selectedID == 1);
	UIDropDownMenu_AddButton(info);
	if ( info.checked ) then
		UIDropDownMenu_SetText(TradeSkillSubClassDropDown, ALL_SUBCLASSES);
	end

	local checked;
	for i=1, select("#", ...), 1 do
		-- if there are no filters then don't check any individual subclasses
		if ( allChecked ) then
			checked = nil;
		else
			checked = GetTradeSkillSubClassFilter(i);
			if ( checked ) then
				UIDropDownMenu_SetText(TradeSkillSubClassDropDown, select(i, ...));
			end
		end
		info.text = select(i, ...);
		info.func = TradeSkillSubClassDropDownButton_OnClick;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function TradeSkillInvSlotDropDown_OnLoad(self)
	SetTradeSkillInvSlotFilter(0, 1, 1);
	UIDropDownMenu_Initialize(self, TradeSkillInvSlotDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 120);
	UIDropDownMenu_SetSelectedID(self, 1);
end

function TradeSkillInvSlotDropDown_Initialize()
	TradeSkillFilterFrame_LoadInvSlots(GetTradeSkillInvSlots());
end

function TradeSkillFilterFrame_LoadInvSlots(...)
	UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, nil);
	local allChecked = GetTradeSkillInvSlotFilter(0);
	local info = UIDropDownMenu_CreateInfo();
	local filterCount = select("#", ...);
	info.text = ALL_INVENTORY_SLOTS;
	info.func = TradeSkillInvSlotDropDownButton_OnClick;
	info.checked = allChecked;
	UIDropDownMenu_AddButton(info);
	local checked;
	for i=1, filterCount, 1 do
		if ( allChecked and filterCount > 1 ) then
			checked = nil;
			UIDropDownMenu_SetText(TradeSkillInvSlotDropDown, ALL_INVENTORY_SLOTS);
		else
			checked = GetTradeSkillInvSlotFilter(i);
			if ( checked ) then
				UIDropDownMenu_SetText(TradeSkillInvSlotDropDown, select(i, ...));
			end
		end
		info.text = select(i, ...);
		info.func = TradeSkillInvSlotDropDownButton_OnClick;
		info.checked = checked;
		
		UIDropDownMenu_AddButton(info);
	end
end

function TradeSkillFilterFrame_InvSlotName(...)
	for i=1, select("#", ...), 1 do
		if ( GetTradeSkillInvSlotFilter(i) ) then
			return select(i, ...);
		end
	end
end

function TradeSkillSubClassDropDownButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, self:GetID());
	SetTradeSkillSubClassFilter(self:GetID() - 1, 1, 1);
	if ( self:GetID() ~= 1 ) then
		if ( TradeSkillFilterFrame_InvSlotName(GetTradeSkillInvSlots()) ~= TradeSkillInvSlotDropDown.selected ) then
			SetTradeSkillInvSlotFilter(0, 1, 1);
			UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, 1);
			UIDropDownMenu_SetText(TradeSkillInvSlotDropDown, ALL_INVENTORY_SLOTS);
		end
	end
	TradeSkillListScrollFrameScrollBar:SetValue(0);
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	TradeSkillFrame_Update();
end

function TradeSkillInvSlotDropDownButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, self:GetID());
	SetTradeSkillInvSlotFilter(self:GetID() - 1, 1, 1);
	TradeSkillInvSlotDropDown.selected = TradeSkillFilterFrame_InvSlotName(GetTradeSkillInvSlots());
	TradeSkillListScrollFrameScrollBar:SetValue(0);
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	TradeSkillFrame_Update();
end

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