-- luacheck: ignore 111 (setting non-standard global variable)

local l10nTable = {
	deDE = {},
	enGB = {
		localize = function()
			HARASSMENT_POLICY_TEXT = "For more information about our harassment policy please go to:\n www.wow-europe.com/en/policy/";
			HELPFRAME_ACCOUNT_ENDTEXT = "For assistance with any issues like these, please contact Billing & Account Services:\n\nBy Web at:  www.wow-europe.com/en/support/";
			HELPFRAME_HOME_TEXT2 = "Additionally, we encourage all players to first utilize the forums and the website to pursue information about their respective issues at |cffffd200www.wow-europe.com|r , and request that specific attention be paid to our game policies at |cffffd200www.wow-europe.com/en/policy/|r .";
			PHYSICAL_HARASSMENT_DESCRIPTION = "The sole purpose and intent in any action used to continually upset, aggravate, or otherwise annoy another player may be considered Physical Harassment or ‘grief play’.  However, make sure that the situation that is being petitioned falls outside the realm of the PvP policy (www.wow-europe.com/en/policy/)";
			PVP_POLICY_URL = "|cffffd200http://www.wow-europe.com/en/policy/|r";
			HELPFRAME_TECHNICAL_BULLET_TITLE2 = "You may find that a solution for your issue has already been posted on the Technical Support Forum, located on the World of Warcraft site at:\n\nwww.wow-europe.com\n\nIf your technical issue is not addressed by the solutions posted there, please contact our Technical Support Department:\n\nBy Web at: www.wow-europe.com/en/support/\nBy Email at: www.wow-europe.com/en/support/";
			HELPFRAME_HOME_TEXT1 = "Game Masters are normally available to assist you 24 hours a day, 7 days a week. Game Masters will be able to assist you no matter which character you are currently playing on.  Keep in mind that there are some issues that Game Masters will |cffffd200NOT|r be able to assist you with.  They include, but are |cffffd200NOT|r limited to the following:";
			MANAGE_ACCOUNT_URL = "http://signup.wow-europe.com";
			HELPFRAME_ACCOUNT_ENDTEXT = "For assistance with any similar issues, please contact Billing & Account Services:\n\nBy phone: you will find the number for your country on this Web page |cffffd200www.wow-europe.com/en/support/accountbilling.html|r\nBy Web at: |cffffd200www.wow-europe.com/en/support/accountbilling.html|r\nBy Webform at: |cffffd200www.wow-europe.com/support/webform/billingDefault.html?lan=en|r\n\nWe also recommend that you check the Account Management section at: \n\n|cffffd200 www.wow-europe.com/account|r \n\nIn the Account Management section, you can view your subscription information, add game cards, and access other important account functions and options.";
			KBASE_ERROR_LOAD_FAILURE = "The Knowledge Base is currently unavailable. Please refer to http://www.wow-europe.com/en/support/ for help with support issues, or submit a petition using the button below.";
			ACHIEVEMENT_TOOLTIP_COMPLETE = "Achievement earned by %1$s on %3$d/%2$d/20%4$02d";
			SOCIAL_ITEM_ARMORY_LINK = "http://eu.battle.net/wow/en/item";
		end,
	},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ptPT = {
		localize = function()
			SOCIAL_ITEM_ARMORY_LINK = "http://eu.battle.net/wow/pt/item";
		end,
	},
	ruRU = {},
	zhCN = {},
	zhTW = {
        localize = function()
        end,

        localizeFrames = function()
        end,
    },
};

SetupLocalization(l10nTable);