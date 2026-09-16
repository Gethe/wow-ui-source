function LocalizeGarrisonAlerts_zh()
	if GarrisonBuildingAlertSystem then
		GarrisonBuildingAlertSystem:AddLocalizationHook(function(frame)
			frame.Title:SetPoint("TOP", 18, -16);
			frame.Name:SetPoint("TOP", frame.Title, "BOTTOM", 0, -7);
		end);
	end

	if GarrisonFollowerAlertSystem then
		GarrisonFollowerAlertSystem:AddLocalizationHook(function(frame)
			frame.Title:SetPoint("TOP", 20, -15);
			frame.Name:SetPoint("TOP", frame.Title, "BOTTOM", 0, -8);
		end);
	end

	if GarrisonShipFollowerAlertSystem then
		GarrisonShipFollowerAlertSystem:AddLocalizationHook(function(frame)
			frame.Title:SetPoint("TOP", 45, -13);
			frame.Name:SetPoint("TOP", frame.Title, "BOTTOM", 0, -6);
			frame.Class:SetPoint("TOP", frame.Name, "BOTTOM", 0, -1);
		end);
	end

	if GarrisonTalentAlertSystem then
		GarrisonTalentAlertSystem:AddLocalizationHook(function(frame)
			frame.Name:SetPoint("TOP", frame.Title, "BOTTOM", 0, -5);
		end);
	end
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
		localizeFrames = function()
			LocalizeGarrisonAlerts_zh();
        end,
	},
	zhTW = {
        localizeFrames = function()
			LocalizeGarrisonAlerts_zh();
        end,
    },
};

SetupLocalization(l10nTable);