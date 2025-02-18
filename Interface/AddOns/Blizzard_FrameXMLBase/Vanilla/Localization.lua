local l10n_Spanish = {
	localizeFrames = function()
	end,
};

local l10nTable = {
	deDE = {
		localizeFrames = function()
			LootFramePrev:SetFontObject(SystemFont_Small);
			LootFrameNext:SetFontObject(SystemFont_Small);
			StackSplitOkayButton:SetNormalFontObject(SystemFont_Small);
			StackSplitOkayButton:SetDisabledFontObject(SystemFont_Small);
			StackSplitOkayButton:SetHighlightFontObject(SystemFont_Small);
			StackSplitCancelButton:SetNormalFontObject(SystemFont_Small);
			StackSplitCancelButton:SetDisabledFontObject(SystemFont_Small);
			StackSplitCancelButton:SetHighlightFontObject(SystemFont_Small);

			FriendsFriendsFrameDropdown:SetWidth(146);

			SideDressUpModelResetButton:SetWidth(105);
		end,
	},

	enGB = {},

	esES = l10n_Spanish,
	esMX = l10n_Spanish,

	frFR = {
		localizeFrames = function()
			FriendsFriendsFrameDropdown:SetWidth(136);
		end,
	},

	itIT = {
		localizeFrames = function()
			FriendsFriendsFrameDropdown:SetWidth(136);
		end,
	},

	koKR = {
		localizeFrames = function()
			PetFrameHealthBarText:SetPoint("CENTER", PetFrameHealthBarText:GetParent(), "TOPLEFT", 81, -26);
			PetFrameManaBarText:SetPoint("CENTER", PetFrameManaBarText:GetParent(), "TOPLEFT", 81, -35);

			MIN_CHARACTER_SEARCH = 1;
		end,
	},

	ptBR = {},
	ptPT = {},
	ruRU = {
		localizeFrames = function()
			-- For the CraftUI, move the subtext closer to the text.
			CRAFT_SUBTEXT_OFFSET = 3;
			CRAFT_COST_OFFSET = -3;
		end,
	},

	zhCN = {
		localizeFrames = function()
			-- Mailframe tabs
			for i=1, (MailFrame.numTabs or 0) do
				local tabName = "MailFrameTab"..i;
				_G[tabName.."Text"]:SetPoint("CENTER", tabName, "CENTER", 0, 5);
			end

			-- Pet Frame
			PetFrameHealthBarText:SetPoint("CENTER", PetFrameHealthBarText:GetParent(), "TOPLEFT", 82, -26);
			PetFrameManaBarText:SetPoint("CENTER", PetFrameManaBarText:GetParent(), "TOPLEFT", 82, -34);

			-- Friends
			for _, button in pairs(FriendsFrameFriendsScrollFrame.buttons) do
				button.info:SetPoint("TOPLEFT", button.name, "BOTTOMLEFT", 0, -6);
			end

			MIN_CHARACTER_SEARCH = 1;

			-- Honor stuff
			HonorFrameCurrentSessionTitle:SetPoint("TOPLEFT", "HonorFrame", "TOPLEFT", 36, -111);
			HonorFrameCurrentHK:SetPoint("TOPLEFT", "HonorFrameCurrentSessionTitle", "BOTTOMLEFT", 10, 1);
			HonorFrameYesterdayTitle:SetPoint("TOPLEFT", "HonorFrameCurrentSessionTitle", "BOTTOMLEFT", 0, -36);
			HonorFrameYesterdayHK:SetPoint("TOPLEFT", "HonorFrameYesterdayTitle", "BOTTOMLEFT", 10, -1);
			HonorFrameThisWeekTitle:SetPoint("TOPLEFT", "HonorFrameYesterdayTitle", "BOTTOMLEFT", 0, -43);
			HonorFrameThisWeekHK:SetPoint("TOPLEFT", "HonorFrameThisWeekTitle", "BOTTOMLEFT", 10, 2);
			HonorFrameLastWeekTitle:SetPoint("TOPLEFT", "HonorFrameYesterdayTitle", "BOTTOMLEFT", 0, -97);
			HonorFrameLastWeekHK:SetPoint("TOPLEFT", "HonorFrameLastWeekTitle", "BOTTOMLEFT", 10, 2);
			HonorFrameLifeTimeTitle:SetPoint("TOPLEFT", "HonorFrameLastWeekTitle", "BOTTOMLEFT", 0, -60);
			HonorFrameLifeTimeHK:SetPoint("TOPLEFT", "HonorFrameLifeTimeTitle", "BOTTOMLEFT", 10, 2);
		end,
	},

	zhTW = {
		localizeFrames = function()
			-- Mailframe tabs
			for i=1, (MailFrame.numTabs or 0) do
				local tabName = "MailFrameTab"..i;
				_G[tabName.."Text"]:SetPoint("CENTER", tabName, "CENTER", 0, 5);
			end

			-- Pet Frame
			PetFrameHealthBarText:SetPoint("CENTER", PetFrameHealthBarText:GetParent(), "TOPLEFT", 82, -25);
			PetFrameManaBarText:SetPoint("CENTER", PetFrameManaBarText:GetParent(), "TOPLEFT", 82, -36);

			-- Trade Frame
			TradeFramePlayerEnchantText:SetPoint("TOPLEFT", TradeFrame, 26, -371);

			MIN_CHARACTER_SEARCH = 1;

			-- Honor stuff
			HonorFrameCurrentSessionTitle:SetPoint("TOPLEFT", "HonorFrame", "TOPLEFT", 36, -111);
			HonorFrameCurrentHK:SetPoint("TOPLEFT", "HonorFrameCurrentSessionTitle", "BOTTOMLEFT", 10, 1);
			HonorFrameYesterdayTitle:SetPoint("TOPLEFT", "HonorFrameCurrentSessionTitle", "BOTTOMLEFT", 0, -36);
			HonorFrameYesterdayHK:SetPoint("TOPLEFT", "HonorFrameYesterdayTitle", "BOTTOMLEFT", 10, -1);
			HonorFrameThisWeekTitle:SetPoint("TOPLEFT", "HonorFrameYesterdayTitle", "BOTTOMLEFT", 0, -43);
			HonorFrameThisWeekHK:SetPoint("TOPLEFT", "HonorFrameThisWeekTitle", "BOTTOMLEFT", 10, 2);
			HonorFrameLastWeekTitle:SetPoint("TOPLEFT", "HonorFrameYesterdayTitle", "BOTTOMLEFT", 0, -97);
			HonorFrameLastWeekHK:SetPoint("TOPLEFT", "HonorFrameLastWeekTitle", "BOTTOMLEFT", 10, 2);
			HonorFrameLifeTimeTitle:SetPoint("TOPLEFT", "HonorFrameLastWeekTitle", "BOTTOMLEFT", 0, -60);
			HonorFrameLifeTimeHK:SetPoint("TOPLEFT", "HonorFrameLifeTimeTitle", "BOTTOMLEFT", 10, 2);
		end,
	},
};

SetupLocalization(l10nTable);