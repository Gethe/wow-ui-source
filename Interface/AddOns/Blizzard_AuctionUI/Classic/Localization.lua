local function LocalizeWoWToken(font)
	font = font or "GameFontNormalHugeBlack";
	WowTokenGameTimeTutorial.LeftDisplay.Label:SetFontObject(font);
	WowTokenGameTimeTutorial.RightDisplay.Label:SetFontObject(font);
end

local l10nTable = {
	deDE = {
		localize = function()
			PriceDropdown:SetWidth(100);
		end,
	},
	enGB = {
		localize = function()
		end,
	},

	enUS = {

	},

	esES = {
		localize = LocalizeWoWToken,
	},
	esMX = {
		localize = LocalizeWoWToken,
	},

	frFR = {
		localize = function()
			BrowseNameText:SetPoint("TOPLEFT", "AuctionFrameBrowse", "TOPLEFT", 80, -37);
			BrowseName:SetPoint("TOPLEFT", "BrowseNameText", "BOTTOMLEFT", 3, -6);
			BrowseLevelHyphen:SetPoint("LEFT", "BrowseMinLevel", "RIGHT", -1, 1);
			BrowseMinLevel:SetPoint("TOPLEFT", "BrowseLevelText", "BOTTOMLEFT", 7, -6);
			BrowseMaxLevel:SetPoint("LEFT", "BrowseMinLevel", "RIGHT", 10, 0);
			BrowseDropdown:SetPoint("TOPLEFT", "BrowseLevelText", "BOTTOMRIGHT", 10, 0);

			LocalizeWoWToken();
		end,
	},

	itIT = {
		localize = function()
			LocalizeWoWToken("Game18Font");
		end,
	},

	koKR = {
		localize = function()
			BrowseNameText:SetPoint("TOPLEFT", "AuctionFrameBrowse", "TOPLEFT", 80, -41);
			BrowseName:SetPoint("TOPLEFT", "BrowseNameText", "BOTTOMLEFT", 3, -6);

			BrowseLevelText:SetPoint("BOTTOMLEFT", "AuctionFrameBrowse", "TOPLEFT", 235, -52);

			BrowseMinLevel:SetWidth(35);
			BrowseMaxLevel:SetWidth(35);
		end,
	},

	ptBR = {
		localize = LocalizeWoWToken,
	},

	ptPT = {
		localize = LocalizeWoWToken,
	},

	ruRU = {
		localize = LocalizeWoWToken,
	},

	zhCN = {
		localize = function()
			-- Auction tabs
			for i=1, 3 do
				getglobal("AuctionFrameTab"..i.."Text"):SetPoint("CENTER", "AuctionFrameTab"..i, "CENTER", 0, 5);
			end

			-- Auction Browse Headers
			BrowseLevelText:SetPoint("BOTTOMLEFT", "AuctionFrameBrowse", "TOPLEFT", 230, -56);
			BrowseMinLevel:SetPoint("TOPLEFT", "BrowseLevelText", "BOTTOMLEFT", 3, -3);
			BrowseDropdown:SetPoint("TOPLEFT", "BrowseLevelText", "BOTTOMRIGHT", -5, 4);
			BrowseDropdownName:SetPoint("BOTTOMLEFT", "BrowseDropdown", "TOPLEFT", 20, -3);

			-- Bid Tab Headers
			BidDurationSort:SetWidth(90);
			BidBidSort:SetWidth(158);

			-- "Auction Item" text on Auctions tab
			AuctionsItemText:SetPoint("TOPLEFT", 25, -75)

			BrowseMinLevel:SetFontObject("ChatFontSmall");
			BrowseMaxLevel:SetFontObject("ChatFontSmall");
		end,
	},

	zhTW = {
		localize = function()
			-- Auction tabs
			for i=1, 3 do
				getglobal("AuctionFrameTab"..i.."Text"):SetPoint("CENTER", "AuctionFrameTab"..i, "CENTER", 0, 5);
			end
			-- Auction Headers
			BrowseLevelText:SetPoint("BOTTOMLEFT", "AuctionFrameBrowse", "TOPLEFT", 230, -56);
			BrowseMinLevel:SetPoint("TOPLEFT", "BrowseLevelText", "BOTTOMLEFT", 3, -2);
			BrowseDropdown:SetPoint("TOPLEFT", "BrowseLevelText", "BOTTOMRIGHT", -5, 4);
			BrowseDropdownName:SetPoint("BOTTOMLEFT", "BrowseDropdown", "TOPLEFT", 20, -3);

			-- Bid Tab Headers
			BidDurationSort:SetWidth(90);
			BidBidSort:SetWidth(158);

			-- "Auction Item" text on Auctions tab
			AuctionsItemText:SetPoint("TOPLEFT", 25, -76)

			BrowseMinLevel:SetFontObject("ChatFontSmall");
			BrowseMaxLevel:SetFontObject("ChatFontSmall");
		end,
	},
};

SetupLocalization(l10nTable);
