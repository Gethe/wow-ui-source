--[[
MenuVariants functions are suitable to be overwritten for game specific implementations. Some
implementations are here for reference despite being shared code.
]]--

MenuVariants = {};

MenuVariants.GearButtonTexture = [[Interface\WorldMap\GEAR_64GREY]];
MenuVariants.CancelButtonTexture = [[Interface\Buttons\UI-GroupLoot-Pass-Up]];
MenuVariants.DisabledHighlightOpacity = .4;

function MenuVariants.CreateFontString(frame)
	local fontString = frame:AttachFontString();
	fontString:SetPoint("LEFT");
	fontString:SetHeight(20);
	return fontString;
end

function MenuVariants.CreateDivider(frame)
	local divider = frame:AttachTexture();
	divider:SetPoint("LEFT");
	divider:SetPoint("RIGHT");
	divider:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent");
	divider:SetHeight(13);
	return divider;
end

function MenuVariants.CreateSubmenuArrow(frame)
	local arrow = frame:AttachTexture();
	frame.arrow = arrow;
	arrow:SetPoint("RIGHT");
	arrow:SetSize(16, 16);
	arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow");
	arrow:SetDrawLayer("ARTWORK");
	return arrow;
end

function MenuVariants.CreateHighlight(frame)
	local highlight = frame:AttachTexture();
	frame.highlight = highlight;
	highlight:SetAllPoints();
	highlight:SetBlendMode("ADD");
	highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	highlight:SetDrawLayer("BACKGROUND");
	highlight:Hide();
	return highlight;
end

function MenuVariants.GetCheckboxCheckSoundKit()
	return SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON;
end

function MenuVariants.GetCheckboxUncheckSoundKit()
	return SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF;
end

function MenuVariants.GetButtonSoundKit()
	return SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON;
end

function MenuVariants.GetDropdownOpenSoundKit()
	return SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON;
end

function MenuVariants.GetDropdownCloseSoundKit()
	return SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF;
end

local function GenerateError()
	error("Requires implementation in game specific version of MenuVariants.lua");
end

function MenuVariants.GetDefaultMenuMixin()
	GenerateError();
end

function MenuVariants.GetDefaultContextMenuMixin()
	GenerateError();
end