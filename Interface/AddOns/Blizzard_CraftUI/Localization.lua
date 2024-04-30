local function Localize_zh()
	local i = 1;
	repeat
		local craft = getglobal("CraftReagent"..i.."Count");
		if ( (i % 2) ~= 0 ) then
			if ( craft ) then
				local parent = "CraftReagent"..i.."IconTexture";
				craft:ClearAllPoints();
				craft:SetJustifyH("LEFT");
				craft:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 2);
			end
		end
		i = i + 1
	until ( not craft)
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
		localize = Localize_zh,
	},
	zhTW = {
		localize = Localize_zh,
	},
};

SetupLocalization(l10nTable);
