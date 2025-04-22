local MaxSpellBookTypes = 5;
SpellBookFrames = {	"SpellBookSpellIconsFrame", "SpellBookProfessionFrame", "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame", "SpellBookCoreAbilitiesFrame", "SpellBookWhatHasChanged" };

local ceil = ceil;
local strlen = strlen;
local tinsert = tinsert;
local tremove = tremove;

function SpellBookFrameMixin:OnLoad()
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");

	SpellBookFrame.bookType = BOOKTYPE_SPELL;
	-- Init page nums
	SPELLBOOK_PAGENUMBERS[1] = 1;
	SPELLBOOK_PAGENUMBERS[2] = 1;
	SPELLBOOK_PAGENUMBERS[3] = 1;
	SPELLBOOK_PAGENUMBERS[4] = 1;
	SPELLBOOK_PAGENUMBERS[5] = 1;
	SPELLBOOK_PAGENUMBERS[6] = 1;
	SPELLBOOK_PAGENUMBERS[7] = 1;
	SPELLBOOK_PAGENUMBERS[8] = 1;
	SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = 1;
	
	-- Set to the first tab by default
	SpellBookFrame.selectedSkillLine = 1;

	-- Initialize tab flashing
	SpellBookFrame.flashTabs = nil;

	-- Initialize portrait texture
	SetPortraitToTexture(self.portrait, "Interface\\Spellbook\\Spellbook-Icon");

	ButtonFrameTemplate_HideButtonBar(SpellBookFrame);
	ButtonFrameTemplate_HideAttic(SpellBookFrame);
	SpellBookFrameInsetBg:Hide();
end

function SpellBookFrameMixin:OnEvent(event, ...)
	if ( event == "SPELLS_CHANGED" ) then
		if ( SpellBookFrame:IsVisible() ) then
			if ( GetNumSpellTabs() < SpellBookFrame.selectedSkillLine ) then
				SpellBookFrame.selectedSkillLine = 2;
			end
			self:Update();
		end
	elseif ( event == "LEARNED_SPELL_IN_TAB" ) then
		self:Update();
		local spellID, tabNum, isGuildSpell = ...;
		local flashFrame = _G["SpellBookSkillLineTab"..tabNum.."Flash"];
		if ( SpellBookFrame.bookType == BOOKTYPE_PET or isGuildSpell) then
			return;
		elseif ( tabNum <= GetNumSpellTabs() ) then
			if ( flashFrame ) then
				flashFrame:Show();
				SpellBookFrame.flashTabs = 1;
			end
		end
	elseif (event == "SKILL_LINES_CHANGED") then
		SpellBook_UpdateProfTab();
	elseif (event == "PLAYER_GUILD_UPDATE") then
		-- default to class tab if the selected one is gone - happens if you leave a guild with perks
		if ( GetNumSpellTabs() < SpellBookFrame.selectedSkillLine ) then
			self:Update();
		else
			self:UpdateSkillLineTabs();
		end
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		local unit = ...;
		if ( unit == "player" ) then
			SpellBookFrame.selectedSkillLine = 2; -- number of skilllines will change!
			self:Update();
		end
	end
end

function SpellBookFrameMixin:Update()
	-- Hide all tabs
	SpellBookFrameTabButton3:Hide();
	SpellBookFrameTabButton4:Hide();
	SpellBookFrameTabButton5:Hide();

	-- Setup tabs
	-- player spells and professions are always shown
	SpellBookFrameTabButton1:Show();
	SpellBookFrameTabButton1.bookType = BOOKTYPE_SPELL;
	SpellBookFrameTabButton1.binding = "TOGGLESPELLBOOK";
	SpellBookFrameTabButton1:SetText(SpellBookInfo[BOOKTYPE_SPELL].title);
	SpellBookFrameTabButton2:Show();
	SpellBookFrameTabButton2.bookType = BOOKTYPE_PROFESSION;
	SpellBookFrameTabButton2:SetText(SpellBookInfo[BOOKTYPE_PROFESSION].title);
	SpellBookFrameTabButton2.binding = "TOGGLECHARACTER1"; --since default bindngs are shared by all of Classic I am using the old binding name instead of TOGGLEPROFESSIONBOOK

	local numTabs = 3;
	-- check to see if we have a pet
	local hasPetSpells, petToken = HasPetSpells();
	SpellBookFrame.petTitle = nil;
	if ( hasPetSpells and PetHasSpellbook() ) then
		SpellBookFrame.petTitle = _G["PET_TYPE_"..petToken];
		local nextTab = _G["SpellBookFrameTabButton"..3];
		nextTab:Show();
		nextTab.bookType = BOOKTYPE_PET;
		nextTab.binding = "TOGGLEPETBOOK";
		nextTab:SetText(SpellBookInfo[BOOKTYPE_PET].title);
		numTabs = numTabs + 1;
	elseif (SpellBookFrame.bookType == BOOKTYPE_PET) then
		SpellBookFrame.bookType = _G["SpellBookFrameTabButton"..2].bookType;
	end

	local level = UnitLevel("player");
	
	if ( level >= 20 ) then
		local nextTab = _G["SpellBookFrameTabButton"..numTabs];
		nextTab:Show();
		nextTab.bookType = BOOKTYPE_CORE_ABILITIES;
		nextTab.binding = "TOGGLECOREABILITIESBOOK";
		nextTab:SetText(SpellBookInfo[BOOKTYPE_CORE_ABILITIES].title);
		numTabs = numTabs+1;
	end
	
	if ( level >= 40 ) then
		local nextTab = _G["SpellBookFrameTabButton"..numTabs];
		nextTab:Show();
		nextTab.bookType = BOOKTYPE_WHAT_HAS_CHANGED;
		nextTab.binding = "TOGGLEWHATHASCHANGEDBOOK";
		nextTab:SetText(SpellBookInfo[BOOKTYPE_WHAT_HAS_CHANGED].title);
	end
	
	PanelTemplates_SetNumTabs(SpellBookFrame, numTabs);

	-- Make sure the correct tab is selected
	for i=1,MaxSpellBookTypes do
		local tab = _G["SpellBookFrameTabButton"..i];
		if ( tab.bookType == SpellBookFrame.bookType ) then
			SpellBookFrame.currentTab = tab;
			PanelTemplates_SelectTab(tab);
		else
			PanelTemplates_DeselectTab(tab);
		end
	end
	
	-- setup display
	for i, frame in ipairs(SpellBookFrames) do
		local found = false;
		for j,frame2 in ipairs(SpellBookInfo[SpellBookFrame.bookType].showFrames) do
			if (frame == frame2) then
				_G[frame]:Show();
				found = true;
				break;
			end
		end
		if (found == false) then
			_G[frame]:Hide();
		end
	end
	

	if SpellBookInfo[SpellBookFrame.bookType].bgFileL then
		SpellBookPage1:SetTexture(SpellBookInfo[SpellBookFrame.bookType].bgFileL);
	else
		SpellBookPage1:SetTexture("Interface\\Spellbook\\Spellbook-Page-1");
	end
	if SpellBookInfo[SpellBookFrame.bookType].bgFileR then
		SpellBookPage2:SetTexture(SpellBookInfo[SpellBookFrame.bookType].bgFileR);
	else
		SpellBookPage2:SetTexture("Interface\\Spellbook\\Spellbook-Page-2");
	end

	SpellBookFrame:SetTitle(SpellBookInfo[SpellBookFrame.bookType].title);

	local tabUpdate = SpellBookInfo[SpellBookFrame.bookType].updateFunc;
	if(tabUpdate) then
		tabUpdate()
	end
end

function SpellBookFrameMixin:UpdatePages()
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if ( maxPages == nil or maxPages == 0 ) then
		return;
	end
	if ( currentPage > maxPages ) then
		if (SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = maxPages;
		else
			SPELLBOOK_PAGENUMBERS[SpellBookFrame.bookType] = maxPages;
		end
		currentPage = maxPages;
		if ( currentPage == 1 ) then
			SpellBookPrevPageButton:Disable();
		else
			SpellBookPrevPageButton:Enable();
		end
		if ( currentPage == maxPages ) then
			SpellBookNextPageButton:Disable();
		else
			SpellBookNextPageButton:Enable();
		end
	end
	if ( currentPage == 1 ) then
		SpellBookPrevPageButton:Disable();
	else
		SpellBookPrevPageButton:Enable();
	end
	if ( currentPage == maxPages ) then
		SpellBookNextPageButton:Disable();
	else
		SpellBookNextPageButton:Enable();
	end
	SpellBookPageText:SetFormattedText(PAGE_NUMBER, currentPage);
end

function SpellButtonMixin:OnClick(button)
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if ( slot > MAX_SPELLS or slotType == "FUTURESPELL") then
		return;
	end

	if (self.isPassive) then 
		return;
	end

	if ( button ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET ) then
		if ( self.offSpecID == 0 ) then
			ToggleSpellAutocast(slot, SpellBookFrame.bookType);
		end
	else
		local _, id = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		if (slotType == "FLYOUT") then
			SpellFlyout:Toggle(id, self, "RIGHT", 1, false, self.offSpecID, true);
			SpellFlyout:SetBorderColor(181/256, 162/256, 90/256);
		else
			if ( SpellBookFrame.bookType ~= BOOKTYPE_SPELLBOOK or self.offSpecID == 0 ) then
				CastSpell(slot, SpellBookFrame.bookType);
			end
		end
		self:UpdateSelection();
	end
end


function SpellButtonMixin:UpdateSelection()
	-- We only highlight professions that are open. We used to highlight active shapeshifts and pet
	-- stances but we removed the highlight on those to avoid conflicting with the not-on-your-action-bar highlights.
	if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
		local slot = SpellBook_GetSpellBookSlot(self);
		if ( slot and IsSelectedSpellBookItem(slot, SpellBookFrame.bookType) ) then
			self:SetChecked(true);
		else
			self:SetChecked(false);
		end
	end
end

function SpellButtonMixin:UpdateButton()
	if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
		UpdateProfessionButton(self);
		return;
	end

	if ( not SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = 2;
	end
	local _, _, offset, numSlots, _, offSpecID, shouldHide, specID = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineNumSlots = numSlots;
	SpellBookFrame.selectedSkillLineOffset = offset;
	local isOffSpec = (offSpecID ~= 0) and (SpellBookFrame.bookType == BOOKTYPE_SPELL);
	self.offSpecID = offSpecID;
	
	if (not self.SpellName.shadowX) then
		self.SpellName.shadowX, self.SpellName.shadowY = self.SpellName:GetShadowOffset();
	end

	local slot, slotType, slotID = SpellBook_GetSpellBookSlot(self);
	local name = self:GetName();
	local iconTexture = _G[name.."IconTexture"];
	local spellString = _G[name.."SpellName"];
	local subSpellString = _G[name.."SubSpellName"];
	local cooldown = _G[name.."Cooldown"];
	local autoCastableTexture = _G[name.."AutoCastable"];
	local slotFrame = _G[name.."SlotFrame"];
	local normalTexture = _G[name.."NormalTexture"];
	local highlightTexture = _G[name.."Highlight"];
	local texture;
	if ( slot ) then
		texture = GetSpellBookItemTexture(slot, SpellBookFrame.bookType);
	end

	-- Hide flyout if it's currently open
	if (SpellFlyout:IsShown() and SpellFlyout:GetParent() == self)  then
		SpellFlyout:Hide();
	end

	-- If no spell, hide everything and return, or kiosk mode and future spell
	if ( not texture or (strlen(texture) == 0) or (slotType == "FUTURESPELL" and Kiosk.IsEnabled())) then
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		autoCastableTexture:Hide();
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		self:SetChecked(false);
		slotFrame:Hide();
		self.IconTextureBg:Hide();
		self.SeeTrainerString:Hide();
		self.RequiredLevelString:Hide();
		self.UnlearnedFrame:Hide();
		self.TrainFrame:Hide();
		self.TrainTextBackground:Hide();
		self.TrainBook:Hide();
		self.FlyoutArrow:Hide();
		self:Disable();
		self.TextBackground:SetDesaturated(isOffSpec);
		self.TextBackground2:SetDesaturated(isOffSpec);
		self.EmptySlot:SetDesaturated(isOffSpec);
		return;
	else
		self:Enable();
	end

	self:UpdateCooldown();

	local autoCastAllowed, autoCastEnabled = GetSpellAutocast(slot, SpellBookFrame.bookType);
	if ( autoCastAllowed ) then
		autoCastableTexture:Show();
	else
		autoCastableTexture:Hide();
	end
	if ( autoCastEnabled and not self.shine ) then
		self.shine = SpellBook_GetAutoCastShine();
		self.shine:Show();
		self.shine:SetParent(self);
		self.shine:SetPoint("CENTER", self, "CENTER");
		AutoCastShine_AutoCastStart(self.shine);
	elseif ( autoCastEnabled ) then
		self.shine:Show();
		self.shine:SetParent(self);
		self.shine:SetPoint("CENTER", self, "CENTER");
		AutoCastShine_AutoCastStart(self.shine);
	elseif ( not autoCastEnabled ) then
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
	end

	local spellName, _, spellID = GetSpellBookItemName(slot, SpellBookFrame.bookType);
	local isPassive = IsPassiveSpell(slot, SpellBookFrame.bookType);
	self.isPassive = isPassive;

	if ( isPassive ) then
		highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
	else
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	iconTexture:SetTexture(texture);
	spellString:SetText(spellName);

	local specs =  {GetSpecsForSpell(slot, SpellBookFrame.bookType)};
	local specName = table.concat(specs, PLAYER_LIST_DELIMITER);

	self.SpellSubName:SetHeight(6);
	subSpellString:SetText("");
	if spellID then
		local spell = Spell:CreateFromSpellID(spellID);
		spell:ContinueOnSpellLoad(function()
			local subSpellName = spell:GetSpellSubtext();
			if ( subSpellName == "" ) then
				if ( specName and specName ~= "" ) then
					if ( isPassive ) then
						subSpellName = specName .. ", " .. SPELL_PASSIVE_SECOND
					else
						subSpellName = specName;
					end
				elseif ( IsTalentSpell(slot, SpellBookFrame.bookType) ) then
					if ( isPassive ) then
						subSpellName = TALENT_PASSIVE
					else
						subSpellName = TALENT
					end
				elseif ( isPassive ) then
					subSpellName = SPELL_PASSIVE;
				end
			end

			subSpellString:SetText(subSpellName);
		end);
	end

	-- If there is no spell sub-name, move the bottom row of text up
	if ( subSpellName == "" ) then
		spellString:SetPoint("LEFT", self, "RIGHT", 5, 1);
	else
		spellString:SetPoint("LEFT", self, "RIGHT", 5, 3);
	end

	iconTexture:Show();
	spellString:Show();
	subSpellString:Show();

	if slotType ~= "FUTURESPELL" then
		slotFrame:Show();
		self.UnlearnedFrame:Hide();
		self.TrainFrame:Hide();
		self.IconTextureBg:Hide();
		iconTexture:SetAlpha(1);
		iconTexture:SetDesaturated(false);
		self.RequiredLevelString:Hide();
		self.SeeTrainerString:Hide();
		self.TrainTextBackground:Hide();
		self.TrainBook:Hide();
		self.SpellName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.SpellName:SetShadowOffset(self.SpellName.shadowX, self.SpellName.shadowY);
		self.SpellName:SetPoint("LEFT", self, "RIGHT", 8, 4);
		
		self.SpellSubName:SetTextColor(0, 0, 0);
		if ( slotType == "SPELL" and isOffSpec ) then
			local level = GetSpellLevelLearned(slotID);
			if ( level and level > UnitLevel("player") ) then
				self.RequiredLevelString:Show();
				self.RequiredLevelString:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
				self.RequiredLevelString:SetTextColor(0.25, 0.12, 0);
			end
		end

		local _, actionID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);

		if self.SpellHighlightTexture then
			self.SpellHighlightTexture:Hide();
			if ( (SpellBookFrame.selectedSkillLine > 1 and not isOffSpec) or SpellBookFrame.bookType == BOOKTYPE_PET ) then
				if ( slotType == "SPELL" ) then
					-- If the spell is passive we never show the highlight.  Otherwise, check if there are any action
					-- buttons with this spell.
					self.SpellHighlightTexture:SetShown(not isPassive and not C_ActionBar.IsOnBarOrSpecialBar(actionID));
				elseif ( slotType == "FLYOUT" ) then
					self.SpellHighlightTexture:SetShown(not C_ActionBar.HasFlyoutActionButtons(actionID));
				elseif ( slotType == "PETACTION" ) then
					if ( isPassive ) then
						self.SpellHighlightTexture:Hide();
					else
						local onBarSomewhere = C_ActionBar.HasPetActionButtons(actionID) or C_ActionBar.HasPetActionPetBarIndices(actionID);
						self.SpellHighlightTexture:SetShown(not onBarSomewhere);
					end
				end
			end
		end
	else
		local level = GetSpellAvailableLevel(slot, SpellBookFrame.bookType);
		slotFrame:Hide();
		if self.SpellHighlightTexture then
			self.SpellHighlightTexture:Hide();
		end

		self.IconTextureBg:Show();
		iconTexture:SetAlpha(0.5);
		iconTexture:SetDesaturated(true);
		if (level and level > UnitLevel("player")) then
			self.SeeTrainerString:Hide();
			self.RequiredLevelString:Show();
			self.RequiredLevelString:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
			self.RequiredLevelString:SetTextColor(0.25, 0.12, 0);
			self.UnlearnedFrame:Show();
			self.TrainFrame:Hide();
			self.TrainTextBackground:Hide();
			self.TrainBook:Hide();
			self.SpellName:SetTextColor(0.25, 0.12, 0);
			self.SpellSubName:SetTextColor(0.25, 0.12, 0);
			self.SpellName:SetShadowOffset(0, 0);
			self.SpellName:SetPoint("LEFT", self, "RIGHT", 8, 6);
		else
			self.SeeTrainerString:Show();
			self.RequiredLevelString:Hide();
			self.TrainFrame:Show();
			self.UnlearnedFrame:Hide();
			self.TrainTextBackground:Show();
			self.TrainBook:Show();
			self.SpellName:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			self.SpellName:SetShadowOffset(self.SpellName.shadowX, self.SpellName.shadowY);
			self.SpellName:SetPoint("LEFT", self, "RIGHT", 24, 8);
			self.SpellSubName:SetTextColor(0, 0, 0);
		end
	end

	if (slotType == "FLYOUT") then
		SetClampedTextureRotation(self.FlyoutArrow, 90);
		self.FlyoutArrow:Show();
	else
		self.FlyoutArrow:Hide();
	end

	-- set all the desaturated offspec pages
	slotFrame:SetDesaturated(isOffSpec);
	self.TextBackground:SetDesaturated(isOffSpec);
	self.TextBackground2:SetDesaturated(isOffSpec);
	self.EmptySlot:SetDesaturated(isOffSpec);
	self.FlyoutArrow:SetDesaturated(isOffSpec);
	if (isOffSpec) then
		iconTexture:SetDesaturated(isOffSpec);
		self.SpellName:SetTextColor(0.75, 0.75, 0.75);
		self.RequiredLevelString:SetTextColor(0.1, 0.1, 0.1);
		autoCastableTexture:Hide();
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
	else
		self:UpdateSelection();
	end
end

function SpellBook_GetSpellBookSlot(spellButton)
	local id = spellButton:GetID()
	if ( SpellBookFrame.bookType == BOOKTYPE_PROFESSION) then
		return id + spellButton:GetParent().spellOffset;
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		local slot = id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
		if ( SpellBookFrame.numPetSpells and slot <= SpellBookFrame.numPetSpells) then
			local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			return slot, slotType, slotID;
		end
	else
		local relativeSlot = id + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] - 1));
		if ( SpellBookFrame.selectedSkillLineNumSlots and relativeSlot <= SpellBookFrame.selectedSkillLineNumSlots) then
			local slot = SpellBookFrame.selectedSkillLineOffset + relativeSlot;
			local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			return slot, slotType, slotID;
		end
	end
	return nil, nil, nil;
end

ProfessionsUnlearnButtonMixin = {};

function ProfessionsUnlearnButtonMixin:OnEnter()
    self.Icon:SetAlpha(1.0);
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP);
end

function ProfessionsUnlearnButtonMixin:OnLeave()
    self.Icon:SetAlpha(0.75);
	GameTooltip_Hide();
end

function ProfessionsUnlearnButtonMixin:OnMouseDown()
    self.Icon:SetPoint("TOPLEFT", 1, -1);
end

function ProfessionsUnlearnButtonMixin:OnMouseUp()
    self.Icon:SetPoint("TOPLEFT", 0, 0);
end


function UpdateProfessionButton(self)
	local parent = self:GetParent();
	if not parent.professionInitialized then
		return;
	end

	local spellIndex = self:GetID() + parent.spellOffset;
	local texture = GetSpellBookItemTexture(spellIndex, SpellBookFrame.bookType);
	local spellName, _, spellID = GetSpellBookItemName(spellIndex, SpellBookFrame.bookType);
	local isPassive = IsPassiveSpell(spellIndex, SpellBookFrame.bookType);
	if ( isPassive ) then
		self.highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		self.spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
	else
		self.highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		self.spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	self.IconTexture:SetTexture(texture);
	local start, duration, enable = GetSpellCooldown(spellIndex, SpellBookFrame.bookType);
	CooldownFrame_Set(self.cooldown, start, duration, enable);
	if ( enable == 1 ) then
		self.IconTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		self.IconTexture:SetVertexColor(0.4, 0.4, 0.4);
	end

	self.spellString:SetText(spellName);
	self.subSpellString:SetText("");
	if spellID then
		local spell = Spell:CreateFromSpellID(spellID);
		spell:ContinueOnSpellLoad(function()
			self.subSpellString:SetText(spell:GetSpellSubtext());
		end);
	end
	self.IconTexture:SetTexture(texture);

	self:UpdateSelection();
end

function FormatProfession(frame, index)
	if index then
		frame.missingHeader:Hide();
		frame.missingText:Hide();

		local name, texture, rank, maxRank, numSpells, spellOffset, skillLine, rankModifier, specializationIndex, specializationOffset, skillLineName = GetProfessionInfo(index);
		frame.professionInitialized = true;
		frame.skillName = name;
		frame.spellOffset = spellOffset;
		frame.skillLine = skillLine;
		frame.specializationIndex = specializationIndex;
		frame.specializationOffset = specializationOffset;

		frame.statusBar:SetMinMaxValues(1,maxRank);
		frame.statusBar:SetValue(rank);

		if frame.UnlearnButton ~= nil then
			frame.UnlearnButton:Show();
			frame.UnlearnButton:SetScript("OnClick", function() 
				StaticPopup_Show("UNLEARN_SKILL", name, nil, skillLine);
			end);
		end

		local prof_title = "";
		if (skillLineName) then
			prof_title = skillLineName;
		else
			for i=1,#PROFESSION_RANKS do
				local value,title = PROFESSION_RANKS[i][1], PROFESSION_RANKS[i][2];
				if maxRank < value then break end
				prof_title = title;
			end
		end
		frame.rank:SetText(prof_title);

		frame.statusBar:Show();
		if rank == maxRank then
			frame.statusBar.capRight:Show();
		else
			frame.statusBar.capRight:Hide();
		end

		frame.statusBar.capped:Hide();
		frame.statusBar.rankText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		frame.statusBar.tooltip = nil;

		-- trial cap
		if ( GameLimitedMode_IsActive() ) then
			local _, _, profCap = GetRestrictedAccountData();
			if rank >= profCap and profCap > 0 then
				frame.statusBar.capped:Show();
				frame.statusBar.rankText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				frame.statusBar.tooltip = RED_FONT_COLOR_CODE..CAP_REACHED_TRIAL..FONT_COLOR_CODE_CLOSE;
			end
		end

		if frame.icon and texture then
			SetPortraitToTexture(frame.icon, texture);
		end

		frame.professionName:SetText(name);

		if ( rankModifier > 0 ) then
			frame.statusBar.rankText:SetFormattedText(TRADESKILL_RANK_WITH_MODIFIER, rank, rankModifier, maxRank);
		else
			frame.statusBar.rankText:SetFormattedText(TRADESKILL_RANK, rank, maxRank);
		end

		local hasSpell = false;
		if numSpells <= 0 then
			frame.SpellButton1:Hide();
			frame.SpellButton2:Hide();
		elseif numSpells == 1 then
			hasSpell = true;
			frame.SpellButton2:Hide();
			frame.SpellButton1:Show();
			UpdateProfessionButton(frame.SpellButton1);
		else
			hasSpell = true;
			frame.SpellButton1:Show();
			frame.SpellButton2:Show();
			UpdateProfessionButton(frame.SpellButton1);
			UpdateProfessionButton(frame.SpellButton2);
		end

		if hasSpell and SpellBookFrame.showProfessionSpellHighlights and C_ProfSpecs.ShouldShowPointsReminderForSkillLine(skillLine) then
			UIFrameFlash(frame.SpellButton1.Flash, 0.5, 0.5, -1);
		else
			UIFrameFlashStop(frame.SpellButton1.Flash);
		end

		if numSpells >  2 then
			local errorStr = "Found "..numSpells.." skills for "..name.." the max is 2:"
			for i=1,numSpells do
				errorStr = errorStr.." ("..GetSpellBookItemName(i + spelloffset, SpellBookFrame.bookType)..")";
			end
			assert(false, errorStr)
		end
	else
		frame.missingHeader:Show();
		frame.missingText:Show();

		if frame.icon then
			SetPortraitToTexture(frame.icon, "Interface\\Icons\\INV_Scroll_04");
			frame.specialization:SetText("");
		end
		frame.SpellButton1:Hide();
		frame.SpellButton2:Hide();
		frame.statusBar:Hide();
		frame.rank:SetText("");
		frame.professionName:SetText("");

		if frame.UnlearnButton ~= nil then
			frame.UnlearnButton:Hide();
		end
	end
end

function SpellBook_UpdateProfTab()
	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
	FormatProfession(PrimaryProfession1, prof1);
	FormatProfession(PrimaryProfession2, prof2);
	FormatProfession(SecondaryProfession1, arch);
	FormatProfession(SecondaryProfession2, fish);
	FormatProfession(SecondaryProfession3, cook);
	FormatProfession(SecondaryProfession4, firstAid);
	SpellBookPage1:SetDesaturated(false);
	SpellBookPage2:SetDesaturated(false);
end

-- *************************************************************************************

-- String prefixes for text
SPEC_CORE_ABILITY_TEXT = {}
SPEC_CORE_ABILITY_TEXT[250] = "DK_BLOOD";
SPEC_CORE_ABILITY_TEXT[251] = "DK_FROST";
SPEC_CORE_ABILITY_TEXT[252] = "DK_UNHOLY";

SPEC_CORE_ABILITY_TEXT[102] = "DRUID_BALANCE";
SPEC_CORE_ABILITY_TEXT[103] = "DRUID_FERAL";
SPEC_CORE_ABILITY_TEXT[104] = "DRUID_GUARDIAN";
SPEC_CORE_ABILITY_TEXT[105] = "DRUID_RESTO";

SPEC_CORE_ABILITY_TEXT[253] = "HUNTER_BM";
SPEC_CORE_ABILITY_TEXT[254] = "HUNTER_MM";
SPEC_CORE_ABILITY_TEXT[255] = "HUNTER_SV";

SPEC_CORE_ABILITY_TEXT[62] = "MAGE_ARCANE";
SPEC_CORE_ABILITY_TEXT[63] = "MAGE_FIRE";
SPEC_CORE_ABILITY_TEXT[64] = "MAGE_FROST";

SPEC_CORE_ABILITY_TEXT[268] = "MONK_BREW";
SPEC_CORE_ABILITY_TEXT[270] = "MONK_MIST";
SPEC_CORE_ABILITY_TEXT[269] = "MONK_WIND";

SPEC_CORE_ABILITY_TEXT[65] = "PALADIN_HOLY";
SPEC_CORE_ABILITY_TEXT[66] = "PALADIN_PROT";
SPEC_CORE_ABILITY_TEXT[70] = "PALADIN_RET";

SPEC_CORE_ABILITY_TEXT[256] = "PRIEST_DISC";
SPEC_CORE_ABILITY_TEXT[257] = "PRIEST_HOLY";
SPEC_CORE_ABILITY_TEXT[258] = "PRIEST_SHADOW";

SPEC_CORE_ABILITY_TEXT[259] = "ROGUE_ASS";
SPEC_CORE_ABILITY_TEXT[260] = "ROGUE_COMBAT";
SPEC_CORE_ABILITY_TEXT[261] = "ROGUE_SUB";

SPEC_CORE_ABILITY_TEXT[262] = "SHAMAN_ELE";
SPEC_CORE_ABILITY_TEXT[263] = "SHAMAN_ENHANCE";
SPEC_CORE_ABILITY_TEXT[264] = "SHAMAN_RESTO";

SPEC_CORE_ABILITY_TEXT[265] = "WARLOCK_AFFLICTION";
SPEC_CORE_ABILITY_TEXT[266] = "WARLOCK_DEMO";
SPEC_CORE_ABILITY_TEXT[267] = "WARLOCK_DESTRO";

SPEC_CORE_ABILITY_TEXT[71] = "WARRIOR_ARMS";
SPEC_CORE_ABILITY_TEXT[72] = "WARRIOR_FURY";
SPEC_CORE_ABILITY_TEXT[73] = "WARRIOR_PROT";

-- Hardcoded spell id's for spec display
SPEC_CORE_ABILITY_DISPLAY = {}
SPEC_CORE_ABILITY_DISPLAY[250] = {	45462,	45477,	55050,	49998,	56815,			}; --Blood
SPEC_CORE_ABILITY_DISPLAY[251] = {	45462,	49184,	49020,	49143,					}; --Frost
SPEC_CORE_ABILITY_DISPLAY[252] = {	45462,	45477,	55090,	85948,	63560,	47541,	}; --Unholy

SPEC_CORE_ABILITY_DISPLAY[102] = {	79577,	8921,	93402,	5176,	2912,	78674,	}; --Balance
SPEC_CORE_ABILITY_DISPLAY[103] = {	5221,	33917 ,	1822,	52610,	1079,	22568,	}; --Feral
SPEC_CORE_ABILITY_DISPLAY[104] = {	33745,	77758,	33917,	62606,	22842,			}; --Guardian
SPEC_CORE_ABILITY_DISPLAY[105] = {	774,	8936,	50464,	5185,	33763,	18562,	}; --Restoration

SPEC_CORE_ABILITY_DISPLAY[253] = {	1978,	34026,	3044,	77767,	53351,			}; --Beast Mastery
SPEC_CORE_ABILITY_DISPLAY[254] = {	1978,	19434,	53209,	3044,	56641,	53351,	}; --Marskmanship
SPEC_CORE_ABILITY_DISPLAY[255] = {	1978,	3674,	53301,	3044,	77767,	53351,	}; --Survival

SPEC_CORE_ABILITY_DISPLAY[62] = {	114664,	30451,	5143,	44425,	}; --Arcane
SPEC_CORE_ABILITY_DISPLAY[63] = {	133,	11129,	108853,	11366,	}; --Fire
SPEC_CORE_ABILITY_DISPLAY[64] = {	116,	44614,	84714,	30455,	}; --Frost

SPEC_CORE_ABILITY_DISPLAY[268] = {	100780,	115295,	100784,	115180,	115181, }; --Brewmaster
SPEC_CORE_ABILITY_DISPLAY[270] = {	116694,	115151,	116670,	115175,	115460, }; --Mistweaver
SPEC_CORE_ABILITY_DISPLAY[269] = {	100780,	100787,	100784,	107428,	115072,	113656,	}; --Windwalker

SPEC_CORE_ABILITY_DISPLAY[65] = {	20473,	19750,	635,	82326,	85673,	53563,	}; --Holy
SPEC_CORE_ABILITY_DISPLAY[66] = {	31935,	20271,	35395,	26573,	119072,	53600,	}; --Protection
SPEC_CORE_ABILITY_DISPLAY[70] = {	20271,	35395,	879,	84963,	85256,	24275,	}; --Retribution

SPEC_CORE_ABILITY_DISPLAY[256] = {	33076,	47540,	2061,	2050,	2060,	17		}; --Discipline
SPEC_CORE_ABILITY_DISPLAY[257] = {	33076,	139,	2061,	2050,	2060,	126172	}; --Holy
SPEC_CORE_ABILITY_DISPLAY[258] = {	589,	34914,	8092,	15407,	2944,	32379,	}; --Shadow

SPEC_CORE_ABILITY_DISPLAY[259] = {	1329,	1943,	5171,	32645,	111240,	}; --Assassination
SPEC_CORE_ABILITY_DISPLAY[260] = {	1752,	84617,	5171,	2098,			}; --Combat
SPEC_CORE_ABILITY_DISPLAY[261] = {	53,		16511,	1943,	5171,	2098,	}; --Subtlety

SPEC_CORE_ABILITY_DISPLAY[262] = {	8050,	324,	8042,	51505,	403,	}; --Elemental
SPEC_CORE_ABILITY_DISPLAY[263] = {	8050,	17364,	60103,	403,			}; --Enhancement
SPEC_CORE_ABILITY_DISPLAY[264] = {	974,	61295,	8004,	331,	77472,	}; --Restoration

SPEC_CORE_ABILITY_DISPLAY[265] = {	172,	980,	30108,	103103,	1120,	48181,	}; --Affliction
SPEC_CORE_ABILITY_DISPLAY[266] = {	104315,	172,	105174,	686,	6353,	103958,	}; --Demonology
SPEC_CORE_ABILITY_DISPLAY[267] = {	108647,	348,	17962,	29722,	116858,	17877,	}; --Destruction

SPEC_CORE_ABILITY_DISPLAY[71] = {	100,	86346,	12294,	7384,	1464,	5308,	}; --Arms
SPEC_CORE_ABILITY_DISPLAY[72] = {	100,	23881,	85288,	100130,	5308,			}; --Fury	
SPEC_CORE_ABILITY_DISPLAY[73] = {	100,	23922,	6572,	20243,	2565,			}; --Protection

function SpellBook_GetCoreAbilityButton(index)
	local button = SpellBookCoreAbilitiesFrame.Abilities[index];
	if ( not button ) then
		SpellBookCoreAbilitiesFrame.Abilities[index] = CreateFrame("BUTTON", nil, SpellBookCoreAbilitiesFrame, "CoreAbilitySpellTemplate");
		button = SpellBookCoreAbilitiesFrame.Abilities[index];
		button:SetPoint("TOP", SpellBookCoreAbilitiesFrame.Abilities[index-1], "BOTTOM", 0, -29);
	end
	return button;
end

function SpellBook_GetCoreAbilitySpecTab(index)
	local tab = SpellBookCoreAbilitiesFrame.SpecTabs[index];
	if ( not tab ) then
		SpellBookCoreAbilitiesFrame.SpecTabs[index] = CreateFrame("CHECKBUTTON", nil, SpellBookCoreAbilitiesFrame, "CoreAbilitiesSkillLineTabTemplate");
		tab = SpellBookCoreAbilitiesFrame.SpecTabs[index]
		tab:SetPoint("TOPLEFT", SpellBookCoreAbilitiesFrame.SpecTabs[index-1], "BOTTOMLEFT", 0, -17);
	end
	return tab;
end

SpellBookCoreAbilitiesMixin = {};

function SpellBookCoreAbilitiesMixin:OnClick()
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
	SpellBookCoreAbilitiesFrame.selectedSpec = self:GetID();
	SpellBook_UpdateCoreAbilitiesTab();
end

function SpellBookCoreAbilitiesMixin:UpdateTabs()
	local numSpecs = GetNumSpecializations();
	local currentSpec = GetSpecialization();
	local index = 1;
	local tab;
	if ( currentSpec ) then
		tab = SpellBook_GetCoreAbilitySpecTab(index);
		local id, name, description, icon = GetSpecializationInfo(currentSpec);
		tab:SetID(currentSpec);
		tab:SetNormalTexture(icon);
		tab:SetChecked(SpellBookCoreAbilitiesFrame.selectedSpec == tab:GetID());
		tab.tooltip = name;
		tab:Show();
		index = index + 1;
	end
	
	tab = SpellBook_GetCoreAbilitySpecTab(2);
	if ( currentSpec ) then
		tab:SetPoint("TOPLEFT", SpellBookCoreAbilitiesFrame.SpecTabs[1], "BOTTOMLEFT", 0, -40);
	else
		tab:SetPoint("TOPLEFT", SpellBookCoreAbilitiesFrame.SpecTabs[1], "BOTTOMLEFT", 0, -17);
	end
	
	for i=1, numSpecs do
		if ( not currentSpec or currentSpec ~= i ) then
			tab = SpellBook_GetCoreAbilitySpecTab(index);
			local id, name, description, icon = GetSpecializationInfo(i);
			tab:SetID(i);
			tab:SetNormalTexture(icon);
			tab:SetChecked(SpellBookCoreAbilitiesFrame.selectedSpec == tab:GetID());
			tab:GetNormalTexture():SetDesaturated(currentSpec and currentSpec ~= i);
			tab.tooltip = name;
			tab:Show();
			index = index + 1;
		end
	end
	for i = numSpecs + 1, #SpellBookCoreAbilitiesFrame.SpecTabs do
		SpellBook_GetCoreAbilitySpecTab(i):Hide();
	end
end

function SpellBook_UpdateCoreAbilitiesTab()
	SpellBookFrame:UpdatePages();
	SpellBookCoreAbilitiesFrame:UpdateTabs();
	
	local currentSpec = GetSpecialization();
	local desaturate = currentSpec and (currentSpec ~= SpellBookCoreAbilitiesFrame.selectedSpec);
	local specID, displayName = GetSpecializationInfo(SpellBookCoreAbilitiesFrame.selectedSpec);
	local draggable = false;
	if ( GetSpecialization() == SpellBookCoreAbilitiesFrame.selectedSpec ) then
		draggable = true;
	end
	
	SpellBookCoreAbilitiesFrame.SpecName:SetText(displayName);
	
	local abilityList = SPEC_CORE_ABILITY_DISPLAY[specID];
	if ( abilityList ) then
		for i=1, #abilityList do
			local name, subname = GetSpellInfo(abilityList[i]);
			local _, icon = GetSpellTexture(abilityList[i]);
			local button = SpellBook_GetCoreAbilityButton(i);
			local level = GetSpellLevelLearned(abilityList[i]);
			local showLevel = (level and level > UnitLevel("player"));
			local isPassive = IsPassiveSpell(abilityList[i]);
			
			button.spellID = abilityList[i];
			button.Name:SetText(name);
			button.InfoText:SetText(_G[SPEC_CORE_ABILITY_TEXT[specID].."_CORE_ABILITY_"..i]);

			button.iconTexture:SetTexture(icon);
			button.iconTexture:SetDesaturated(showLevel or desaturate);
			
			button.ActiveTexture:SetShown(not showLevel and not isPassive);
			button.ActiveTexture:SetDesaturated(desaturate);
			button.FutureTexture:SetShown(showLevel);
			button.FutureTexture:SetDesaturated(desaturate);
			button.EmptySlot:SetDesaturated(desaturate);
			button.draggable = draggable and not isPassive and not showLevel;
			
			if ( showLevel ) then
				button.RequiredLevel:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
			else
				button.RequiredLevel:SetText("");
			end
	
			if ( showLevel or isPassive ) then
				button.highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
			else
				button.highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
			end
	
			button:Show();
		end
	end
	for i = #abilityList + 1, #SpellBookCoreAbilitiesFrame.Abilities do
		SpellBook_GetCoreAbilityButton(i):Hide();
	end

	SpellBookPage1:SetDesaturated(desaturate);
	SpellBookPage2:SetDesaturated(desaturate);
end


-- *************************************************************************************
WHAT_HAS_CHANGED_TITLE = {}
WHAT_HAS_CHANGED_TITLE["HUNTER"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_HUNTER_2,		WHC_TITLE_HUNTER_3,		WHC_TITLE_HUNTER_4	};
WHAT_HAS_CHANGED_TITLE["WARLOCK"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_WARLOCK_2,	WHC_TITLE_WARLOCK_3,	WHC_TITLE_WARLOCK_4	};
WHAT_HAS_CHANGED_TITLE["PRIEST"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_PRIEST_2,		WHC_TITLE_PRIEST_3,		WHC_TITLE_PRIEST_4	};
WHAT_HAS_CHANGED_TITLE["PALADIN"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_PALADIN_2,	WHC_TITLE_PALADIN_3		};
WHAT_HAS_CHANGED_TITLE["MAGE"]		= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_MAGE_2,		WHC_TITLE_MAGE_3,		WHC_TITLE_MAGE_4	};
WHAT_HAS_CHANGED_TITLE["ROGUE"]		= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_ROGUE_2,		WHC_TITLE_ROGUE_3,		};
WHAT_HAS_CHANGED_TITLE["DRUID"]		= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_DRUID_2,		WHC_TITLE_DRUID_3,		WHC_TITLE_DRUID_4	};
WHAT_HAS_CHANGED_TITLE["SHAMAN"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_SHAMAN_2,		};
WHAT_HAS_CHANGED_TITLE["WARRIOR"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_WARRIOR_2,	WHC_TITLE_WARRIOR_3,	WHC_TITLE_WARRIOR_4	};
WHAT_HAS_CHANGED_TITLE["MONK"]		= { WHC_TITLE_MONK_1,		WHC_TITLE_MONK_2,		WHC_TITLE_MONK_3		};
WHAT_HAS_CHANGED_TITLE["DEATHKNIGHT"] = { WHC_TITLE_WARRIOR_1,	WHC_TITLE_DK_2,			WHC_TITLE_DK_3			};


WHAT_HAS_CHANGED_DISPLAY = {}
WHAT_HAS_CHANGED_DISPLAY["HUNTER"]	= { WHC_WARRIOR_1,	WHC_HUNTER_2,	WHC_HUNTER_3,	WHC_HUNTER_4	};
WHAT_HAS_CHANGED_DISPLAY["WARLOCK"]	= { WHC_WARRIOR_1,	WHC_WARLOCK_2,	WHC_WARLOCK_3,	WHC_WARLOCK_4	};
WHAT_HAS_CHANGED_DISPLAY["PRIEST"]	= { WHC_WARRIOR_1,	WHC_PRIEST_2,	WHC_PRIEST_3,	WHC_PRIEST_4	};
WHAT_HAS_CHANGED_DISPLAY["PALADIN"]	= { WHC_WARRIOR_1,	WHC_PALADIN_2,	WHC_PALADIN_3,	};
WHAT_HAS_CHANGED_DISPLAY["MAGE"]	= { WHC_WARRIOR_1,	WHC_MAGE_2,		WHC_MAGE_3,		WHC_MAGE_4 };
WHAT_HAS_CHANGED_DISPLAY["ROGUE"]	= { WHC_WARRIOR_1,	WHC_ROGUE_2,	WHC_ROGUE_3,	};
WHAT_HAS_CHANGED_DISPLAY["DRUID"]	= { WHC_WARRIOR_1,	WHC_DRUID_2,	WHC_DRUID_3,	WHC_DRUID_4		};
WHAT_HAS_CHANGED_DISPLAY["SHAMAN"]	= { WHC_WARRIOR_1,	WHC_SHAMAN_2,	};
WHAT_HAS_CHANGED_DISPLAY["WARRIOR"]	= { WHC_WARRIOR_1,	WHC_WARRIOR_2,	WHC_WARRIOR_3,	WHC_WARRIOR_4 };
WHAT_HAS_CHANGED_DISPLAY["MONK"]	= { WHC_MONK_1,		WHC_MONK_2,		WHC_MONK_3		};
WHAT_HAS_CHANGED_DISPLAY["DEATHKNIGHT"] = { WHC_WARRIOR_1,	WHC_DK_2,	WHC_DK_3		};

function SpellBook_GetWhatChangedItem(index)
	local frame = SpellBookWhatHasChanged.ChangedItems[index];
	if ( not frame ) then
		SpellBookWhatHasChanged.ChangedItems[index] = CreateFrame("SimpleHTML", nil, SpellBookWhatHasChanged, "WhatHasChangedEntryTemplate");
		frame = SpellBookWhatHasChanged.ChangedItems[index];
		frame:SetPoint("TOP", SpellBookWhatHasChanged.ChangedItems[index-1], "BOTTOM", 0, -80);
	end
	return frame;
end

function SpellBook_UpdateWhatHasChangedTab()
	local displayName, class = UnitClass("player");
	local changedList = WHAT_HAS_CHANGED_DISPLAY[class];
	local changedTitle = WHAT_HAS_CHANGED_TITLE[class];

	SpellBookWhatHasChanged.ClassName:SetText(displayName);

	if ( changedList ) then
		for i=1, #changedList do
			local frame = SpellBook_GetWhatChangedItem(i);
			frame.Number:SetText(i);
			frame.Title:SetText(changedTitle[i]);
			frame:SetText(changedList[i], true);
		end
	end
	for i = #changedList + 1, #SpellBookWhatHasChanged.ChangedItems do
		SpellBook_GetWhatChangedItem(i):Hide();
	end
	SpellBookPage1:SetDesaturated(false);
	SpellBookPage2:SetDesaturated(false);
end

-- *************************************************************************************

SpellBookFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 580, height = 500	},
	[1] = { ButtonPos = { x = 250,	y = -50},	HighLightBox = { x = 65, y = -25, width = 460, height = 462 },	ToolTipDir = "DOWN",	ToolTipText = SPELLBOOK_HELP_1 },
	[2] = { ButtonPos = { x = 520,	y = -30 },	HighLightBox = { x = 540, y = -5, width = 46, height = 100 },	ToolTipDir = "LEFT",	ToolTipText = SPELLBOOK_HELP_2 },
	[3] = { ButtonPos = { x = 520,	y = -150},	HighLightBox = { x = 540, y = -125, width = 46, height = 200 },	ToolTipDir = "LEFT",	ToolTipText = SPELLBOOK_HELP_3, MinLevel = 10 },
}

ProfessionsFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 545, height = 500	},
	[1] = { ButtonPos = { x = 150,	y = -110 }, HighLightBox = { x = 60, y = -35, width = 460, height = 195 }, ToolTipDir = "UP",	ToolTipText = PROFESSIONS_HELP_1 },
	[2] = { ButtonPos = { x = 150,	y = -325}, HighLightBox = { x = 60, y = -235, width = 460, height = 240 }, ToolTipDir = "UP",	ToolTipText = PROFESSIONS_HELP_2 },
}

CoreAbilitiesFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 580, height = 500	},
	[1] = { ButtonPos = { x = 430,	y = -30}, HighLightBox = { x = 65, y = -15, width = 460, height = 472 }, ToolTipDir = "RIGHT",	ToolTipText = CORE_ABILITIES_HELP_1 },
}

WhatHasChangedFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 580, height = 500	},
	[1] = { ButtonPos = { x = 430,	y = -30}, HighLightBox = { x = 65, y = -15, width = 460, height = 472 }, ToolTipDir = "DOWN",	ToolTipText = WHAT_HAS_CHANGED_HELP_1 },
}