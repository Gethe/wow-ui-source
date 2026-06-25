function LocalizePlayerFrame(offsXVehicle, offsYVehicle, offsX, offsY)
	PlayerFrame_UpdatePlayerNameTextAnchor = function()
		if (PlayerFrame.unit == "vehicle") then
			PlayerName:SetPoint("TOPLEFT", offsXVehicle, offsYVehicle);
		else
			PlayerName:SetPoint("TOPLEFT", offsX, offsY);
		end
	end
end

function LocalizezhCN()
	LocalizePlayerFrame(92, -26, 85, -26);
end

function LocalizezhTW()
	LocalizePlayerFrame(92, -27, 85, -27);
end

local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localize = LocalizezhCN,
	},
	zhTW = {
		localize = LocalizezhTW,
	},
};

SetupLocalization(l10nTable);
