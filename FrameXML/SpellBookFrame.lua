MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 8;
SPELLS_PER_PAGE = 14;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);
BOOKTYPE_SPELL = "spell";
BOOKTYPE_PET = "pet";
SPELLBOOK_PAGENUMBERS = {};

function ToggleSpellBook(bookType)
	local doToggle = 1;
	-- If has no pet spells and is trying to open the corresponding book, then do nothing
	if ( not HasPetSpells() and bookType == BOOKTYPE_PET ) then
		doToggle = nil;
	end
	if ( doToggle ) then
		local isVisible = SpellBookFrame:IsVisible();
		HideUIPanel(SpellBookFrame);
		if ( (not isVisible or (SpellBookFrame.bookType ~= bookType)) ) then
			SpellBookFrame.bookType = bookType;
			ShowUIPanel(SpellBookFrame);
		end
		local currentPage, maxPages = SpellBook_GetCurrentPage();
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
		SpellBookPageText:SetText(format(TEXT(PAGE_NUMBER), currentPage));
	end
end

function SpellBookFrame_OnLoad()
	this:RegisterEvent("SPELLS_CHANGED");
	this:RegisterEvent("LEARNED_SPELL_IN_TAB");

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
	SPELLBOOK_PAGENUMBERS["pet"] = 1;
	
	-- Set to the first tab by default
	SpellBookSkillLineTab_OnClick(1);

	-- Initialize tab flashing
	SpellBookFrame.flashTabs = nil;
end

function SpellBookFrame_OnEvent()
	if ( event == "SPELLS_CHANGED" and SpellBookFrame:IsVisible() ) then
		SpellBookFrame_Update();
	elseif ( event == "LEARNED_SPELL_IN_TAB" ) then
		local flashFrame = getglobal("SpellBookSkillLineTab"..arg1.."Flash");
		if ( flashFrame ) then
			flashFrame:Show();
			SpellBookFrame.flashTabs = 1;
		end
	end
end

function SpellBookFrame_OnShow()
	UpdateMicroButtons();
	SpellBookFrame_Update(1);
	
	-- If there are tabs waiting to flash, then flash them... yeah..
	if ( SpellBookFrame.flashTabs ) then
		UIFrameFlash(SpellBookTabFlashFrame, 0.5, 0.5, 30, nil);
	end
end

function SpellBookFrame_Update(showing)
	-- Hide all tabs
	SpellBookFrameTabButton1:Hide();
	SpellBookFrameTabButton2:Hide();
	SpellBookFrameTabButton3:Hide();
	
	-- Setup skillline tabs
	if ( showing ) then
		SpellBookSkillLineTab_OnClick(SpellBookFrame.selectedSkillLine);
		UpdateSpells();
	end

	local numSkillLineTabs = GetNumSpellTabs();
	local name, texture, offset, numSpells;
	local skillLineTab;
	for i=1, MAX_SKILLLINE_TABS do
		skillLineTab = getglobal("SpellBookSkillLineTab"..i);
		if ( i <= numSkillLineTabs and SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			name, texture, offset, numSpells = GetSpellTabInfo(i);
			skillLineTab:SetNormalTexture(texture);
			skillLineTab.tooltip = name;
			skillLineTab:Show();

			-- Set the selected tab
			if ( SpellBookFrame.selectedSkillLine == i ) then
				skillLineTab:SetChecked(1);
			else
				skillLineTab:SetChecked(nil);
			end
		else
			skillLineTab:Hide();
		end
	end

	-- Setup tabs
	local hasPetSpells, petToken = HasPetSpells();
	SpellBookFrame.petTitle = nil;
	if ( hasPetSpells ) then
		SpellBookFrame_SetTabType(SpellBookFrameTabButton1, BOOKTYPE_SPELL);
		SpellBookFrame_SetTabType(SpellBookFrameTabButton2, BOOKTYPE_PET, petToken);
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		-- if has no pet spells but trying to show the pet spellbook close the window;
		HideUIPanel(SpellBookFrame);
		SpellBookFrame.bookType = BOOKTYPE_SPELL;
	end
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		SpellBookTitleText:SetText(TEXT(SPELLBOOK));
		if ( showing ) then
			PlaySound("igSpellBookOpen");
		end
	else
		SpellBookTitleText:SetText(SpellBookFrame.petTitle);
		-- Need to change to pet book open sound
		if ( showing ) then
			PlaySound("igAbilityOpen");
		end
	end
end

function SpellBookFrame_SetTabType(tabButton, bookType, token)
	if ( bookType == BOOKTYPE_SPELL ) then
		tabButton.bookType = BOOKTYPE_SPELL;
		tabButton:SetText(TEXT(SPELLBOOK));
		tabButton.binding = "TOGGLESPELLBOOK";
	else
		tabButton.bookType = BOOKTYPE_PET;
		tabButton:SetText(TEXT(getglobal("PET_TYPE_"..token)));
		tabButton.binding = "TOGGLEPETBOOK";
		SpellBookFrame.petTitle = TEXT(getglobal("PET_TYPE_"..token));
	end
	if ( SpellBookFrame.bookType == bookType ) then
		tabButton:Disable();
	else
		tabButton:Enable();
	end
	tabButton:Show();
end


function SpellBookFrame_OnHide()
	if ( this.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igSpellBookClose");
	else
		-- Need to change to pet book close sound
		PlaySound("igAbilityClose");
	end
	UpdateMicroButtons();

	-- Stop the flash frame from flashing if its still flashing.. flash flash flash
	UIFrameFlashRemoveFrame(SpellBookTabFlashFrame);
	-- Hide all the flashing textures
	for i=1, MAX_SKILLLINE_TABS do
		getglobal("SpellBookSkillLineTab"..i.."Flash"):Hide();
	end
end

function SpellButton_OnLoad() 
	this:RegisterEvent("SPELLS_CHANGED");
	this:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	this:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	this:RegisterEvent("CRAFT_SHOW");
	this:RegisterEvent("CRAFT_CLOSE");
	this:RegisterEvent("TRADE_SKILL_SHOW");
	this:RegisterEvent("TRADE_SKILL_CLOSE");
	this:RegisterForDrag("LeftButton");
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	SpellButton_UpdateButton();
end

function SpellButton_OnEvent(event) 
	if ( event == "SPELLS_CHANGED" or event == "SPELL_UPDATE_COOLDOWN" ) then 
		SpellButton_UpdateButton();
	elseif ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		SpellButton_UpdateSelection();
	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		SpellButton_UpdateSelection();
		return;
	end

end

function SpellButton_OnEnter()
	local name, texture, offset, numSpells = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	local id = SpellBook_GetSpellID(this:GetID());
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	if ( GameTooltip:SetSpell(id, SpellBookFrame.bookType) ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end
end

function SpellButton_OnUpdate(elapsed)
	if ( not this.updateTooltip ) then
		return;
	end

	this.updateTooltip = this.updateTooltip - elapsed;
	if ( this.updateTooltip > 0 ) then
		return;
	end

	if ( GameTooltip:IsOwned(this) ) then
		SpellButton_OnEnter();
	else
		this.updateTooltip = nil;
	end
end

function SpellButton_OnClick(drag) 
	local id = SpellBook_GetSpellID(this:GetID());
	if ( id > MAX_SPELLS ) then
		return;
	end
	this:SetChecked("false");
	if ( drag ) then
		PickupSpell(id, SpellBookFrame.bookType );
	elseif ( IsShiftKeyDown() ) then
		if ( MacroFrame:IsVisible() ) then
			local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
			if ( spellName and not IsSpellPassive(id, SpellBookFrame.bookType) ) then
				if ( subSpellName and (strlen(subSpellName) > 0) ) then
					MacroFrame_AddMacroLine(TEXT(SLASH_CAST1).." "..spellName.."("..subSpellName..")");
				else
					MacroFrame_AddMacroLine(TEXT(SLASH_CAST1).." "..spellName);
				end
			end
		else
			PickupSpell(id, SpellBookFrame.bookType );
		end
	else
		CastSpell(id, SpellBookFrame.bookType);
		SpellButton_UpdateSelection();
	end
end

function SpellButton_UpdateSelection()
	local temp, texture, offset, numSpells = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	local id = SpellBook_GetSpellID(this:GetID());
	if ( (SpellBookFrame.bookType ~= BOOKTYPE_PET) and (id > (offset + numSpells)) ) then
		this:SetChecked("false");
		return;
	end

	if ( IsCurrentCast(id,  SpellBookFrame.bookType) ) then
		this:SetChecked("true");
	else
		this:SetChecked("false");
	end
end

function SpellButton_UpdateButton()
	if ( not this:IsVisible() ) then
		return;
	end
	if ( GameTooltip:IsOwned(this) ) then
		SpellButton_OnEnter();
	end

	if ( not SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = 1;
	end
	local temp, texture, offset, numSpells = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineOffset = offset;
	local id = SpellBook_GetSpellID(this:GetID());
	local name = this:GetName();
	local texture;
	local iconTexture = getglobal(name.."IconTexture");
	local spellString = getglobal(name.."SpellName");
	local subSpellString = getglobal(name.."SubSpellName");
	local cooldown = getglobal(name.."Cooldown");
	if ( (SpellBookFrame.bookType ~= BOOKTYPE_PET) and (id > (offset + numSpells)) ) then
		this:Disable();
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		getglobal(name.."NormalTexture"):SetVertexColor(1.0, 1.0, 1.0);
		return;
	else
		this:Enable();
	end
	texture = GetSpellTexture(id, SpellBookFrame.bookType);
	local highlightTexture = getglobal(name.."Highlight");
	local normalTexture = getglobal(name.."NormalTexture");
	-- If no spell, hide everything and return
	if ( not texture or (strlen(texture) == 0) ) then
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		this:SetChecked(0);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
		return;
	end
	
	local start, duration, enable = GetSpellCooldown(id, SpellBookFrame.bookType);
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
	if ( enable == 1 ) then
		iconTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		iconTexture:SetVertexColor(0.4, 0.4, 0.4);
	end
	
	local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
	local isPassive = IsSpellPassive(id, SpellBookFrame.bookType);
	if ( isPassive ) then
		normalTexture:SetVertexColor(0, 0, 0);
		highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		--subSpellName = TEXT(PASSIVE_PARENS);
		spellString:SetTextColor(0.77, 0.64, 0);
	else
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	iconTexture:SetTexture(texture);
	spellString:SetText(spellName);
	subSpellString:SetText(subSpellName);
	if ( subSpellName ~= "" ) then
		spellString:SetPoint("LEFT", this:GetName(), "RIGHT", 4, 7);
	else
		spellString:SetPoint("LEFT", this:GetName(), "RIGHT", 4, 2);
	end

	iconTexture:Show();
	spellString:Show();
	subSpellString:Show();
	SpellButton_UpdateSelection();
end

function PrevPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() - 1;
	SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	SpellBook_UpdatePageArrows();
	SpellBookPageText:SetText(format(TEXT(PAGE_NUMBER), pageNum));
	UpdateSpells();
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igAbiliityPageTurn");
	else
		SpellBookTitleText:SetText(SpellBookFrame.petTitle);
		-- Need to change to pet book pageturn sound
		PlaySound("igAbiliityPageTurn");
	end
end

function NextPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() + 1;
	SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	SpellBook_UpdatePageArrows();
	SpellBookPageText:SetText(format(TEXT(PAGE_NUMBER), pageNum));
	UpdateSpells();
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igAbiliityPageTurn");
	else
		SpellBookTitleText:SetText(SpellBookFrame.petTitle);
		-- Need to change to pet book pageturn sound
		PlaySound("igAbiliityPageTurn");
	end
end

function SpellBookSkillLineTab_OnClick(id)
	local update;
	if ( not id ) then
		update = 1;
		id = this:GetID();
	end
	SpellBookFrame.selectedSkillLine = id;
	local name, texture, offset, numSpells = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineOffset = offset;
	SpellBookFrame.selectedSkillLineNumSpells = numSpells;
	SpellBook_UpdatePageArrows();
	SpellBookFrame_Update();
	SpellBookPageText:SetText(format(TEXT(PAGE_NUMBER), SpellBook_GetCurrentPage()));
	if ( update ) then
		UpdateSpells();
	end
	-- Stop tab flashing
	local tabFlash = getglobal(this:GetName().."Flash");
	if ( tabFlash ) then
		tabFlash:Hide();
	end
end

function SpellBook_GetSpellID(id)
	if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		return id;
	else
		return id + SpellBookFrame.selectedSkillLineOffset + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] - 1));
	end
end

function SpellBook_UpdatePageArrows()
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if ( currentPage== 1 ) then
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

function SpellBook_GetCurrentPage()
	local currentPage, maxPages;
	local numPetSpells = HasPetSpells();
	if ( numPetSpells and SpellBookFrame.bookType == BOOKTYPE_PET ) then
		currentPage = SPELLBOOK_PAGENUMBERS["pet"];
		maxPages = ceil(numPetSpells/SPELLS_PER_PAGE);
	else
		currentPage = SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine];
		local name, texture, offset, numSpells = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
		maxPages = ceil(numSpells/SPELLS_PER_PAGE);
	end
	return currentPage, maxPages;
end
