-- luacheck: ignore 111 (setting non-standard global variable)

-- TODO: This is mostly wrong, need to redo the entire file because the originals have already been
-- nuked...rebuild this from whatever is in the repo, don't even try to piece it together

local function LocalizeFrames_PVPHonorKills()
	if(PVPHonorKillsLabel) then
		PVPHonorKillsLabel:SetPoint("TOPLEFT", "PVPHonor", 15, -33);
		PVPHonorKillsLabel:SetSize(50, 12);
	end
end

local l10nTable = {
	deDE = {
		localize = function()

		end
	},
	enGB = {
		localize = function()
		end,
	},

	enUS = {

	},

	esES = {
		localizeFrames = LocalizeFrames_PVPHonorKills,
	},
	esMX = {
		localizeFrames = LocalizeFrames_PVPHonorKills,
	},

	frFR = {
		localize = function() end,
	},

	itIT = {
		localize = function() end,
	},

	koKR = {
		localizeFrames = function()
			local point, relativeTo, relativePoint, xOfs, yOfs;

			-- Pet Frame
			PetFrameHealthBarText:SetPoint("CENTER", PetFrameHealthBarText:GetParent(), "TOPLEFT", 81, -26);
			PetFrameManaBarText:SetPoint("CENTER", PetFrameManaBarText:GetParent(), "TOPLEFT", 81, -35);

			MIN_CHARACTER_SEARCH = 1;
		end,
	},

	ptBR = {
		localizeFrames = function()
			FriendsFriendsFrameDropdown:SetWidth(132);
		end,
	},

	ptPT = {
		localize = function()
			-- Put this in the SharedXMLGame addon when TBC is converted.
			SOCIAL_ITEM_ARMORY_LINK = "http://eu.battle.net/wow/pt/item";
		end,

		localizeFrames = function()
			FriendsFriendsFrameDropdown:SetWidth(132);
		end
	},

	ruRU = {
		localize = function()

		end,

		localizeFrames = function()

		end,
	},

	zhCN = {
		localizeFrames = function()
			-- Mailframe tabs
			for i=1, (MailFrame.numTabs or 0) do
				local tabName = "MailFrameTab"..i;
				_G[tabName.."Text"]:SetPoint("CENTER", tabName, "CENTER", 0, 5);
			end

			local point, relativeTo, relativePoint, xOfs, yOfs;

			-- Pet Frame
			PetFrameHealthBarText:SetPoint("CENTER", PetFrameHealthBarText:GetParent(), "TOPLEFT", 82, -26);
			PetFrameManaBarText:SetPoint("CENTER", PetFrameManaBarText:GetParent(), "TOPLEFT", 82, -34);

			-- Friends
			for _, button in pairs(FriendsFrameFriendsScrollFrame.buttons) do
				button.info:SetPoint("TOPLEFT", button.name, "BOTTOMLEFT", 0, -6);
			end

			MIN_CHARACTER_SEARCH = 1;

			-- Quest Log
			QuestLogQuestCount:SetPoint("TOPRIGHT", QuestLogCountTopRight, "BOTTOMLEFT", 1, 6); -- +0, +3
			QuestLogDailyQuestCount:SetPoint("TOPRIGHT", QuestLogQuestCount, "BOTTOMRIGHT", 0, 1); -- +0, +3
		end,
	},

	zhTW = {
		localizeFrames = function()
			-- Mailframe tabs
			for i=1, (MailFrame.numTabs or 0) do
				local tabName = "MailFrameTab"..i;
				_G[tabName.."Text"]:SetPoint("CENTER", tabName, "CENTER", 0, 5);
			end

			local point, relativeTo, relativePoint, xOfs, yOfs;

			-- Pet Frame
			PetFrameHealthBarText:SetPoint("CENTER", PetFrameHealthBarText:GetParent(), "TOPLEFT", 82, -25);
			PetFrameManaBarText:SetPoint("CENTER", PetFrameManaBarText:GetParent(), "TOPLEFT", 82, -36);

			-- Trade Frame
			TradeFramePlayerEnchantText:SetPoint("TOPLEFT", TradeFrame, 26, -371);

			MIN_CHARACTER_SEARCH = 1;

			-- Quest Log
			QuestLogQuestCount:SetPoint("TOPRIGHT", QuestLogCountTopRight, "BOTTOMLEFT", 1, 6); -- +0, +3
			QuestLogDailyQuestCount:SetPoint("TOPRIGHT", QuestLogQuestCount, "BOTTOMRIGHT", 0, 1); -- +0, +3、游戏中有用户实名认证系统，认证为未成年人的用户将接受以下管理：
		end,
	},
};

SetupLocalization(l10nTable);