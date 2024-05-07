local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {
		localize = function()
			-- Adjust Macro Name Input Box's Texture Width
			MacroPopupFrame.BorderBox.IconSelectorEditBox.IconSelectorPopupNameMiddle:SetWidth(190);

			-- Adjust the spacing and size of the Macro Character Limit fontstring.
			MacroFrameCharLimitText:SetPoint("BOTTOM", MacroFrame, "BOTTOM", -15, 103);
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localize = function()
			-- Adjust Macro text
			MacroFrameCharLimitText:SetPoint("BOTTOM", "MacroFrame", "BOTTOM", -15, 30);
			MacroFrameCharLimitText:SetFontObject(SpellFont_Small);

			MacroFrameEnterMacroText:SetPoint("TOPLEFT", "MacroFrameSelectedMacroBackground", "BOTTOMLEFT", 8, 7);

			-- Adjust Macro Name Input Box's Texture Width
			MacroPopupFrame.BorderBox.IconSelectorEditBox.IconSelectorPopupNameMiddle:SetWidth(190);
		end,
	},
	zhTW = {
		localize = function()
			-- Adjust Macro text
			MacroFrameCharLimitText:SetPoint("BOTTOM", "MacroFrame", "BOTTOM", -15, 30);

			MacroFrameEnterMacroText:SetPoint("TOPLEFT", "MacroFrameSelectedMacroBackground", "BOTTOMLEFT", 8, 7);

			-- Adjust Macro Name Input Box's Texture Width
			MacroPopupFrame.BorderBox.IconSelectorEditBox.IconSelectorPopupNameMiddle:SetWidth(190);

			-- Adjust MacroTab2 size
			PanelTemplates_TabResize(MacroFrameTab2, -15, nil, 130);
		end,
	},
};

SetupLocalization(l10nTable);