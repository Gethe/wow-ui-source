---------------
--NOTE - Please do not change this section
local _, tbl, secureCapsuleGet = ...;
if tbl then
	tbl.SecureCapsuleGet = secureCapsuleGet or SecureCapsuleGet;
	tbl.setfenv = tbl.SecureCapsuleGet("setfenv");
	tbl.getfenv = tbl.SecureCapsuleGet("getfenv");
	tbl.type = tbl.SecureCapsuleGet("type");
	tbl.unpack = tbl.SecureCapsuleGet("unpack");
	tbl.error = tbl.SecureCapsuleGet("error");
	tbl.pcall = tbl.SecureCapsuleGet("pcall");
	tbl.pairs = tbl.SecureCapsuleGet("pairs");
	tbl.setmetatable = tbl.SecureCapsuleGet("setmetatable");
	tbl.getmetatable = tbl.SecureCapsuleGet("getmetatable");
	tbl.pcallwithenv = tbl.SecureCapsuleGet("pcallwithenv");

	local function CleanFunction(f)
		local f = function(...)
			local function HandleCleanFunctionCallArgs(success, ...)
				if success then
					return ...;
				else
					tbl.error("Error in secure capsule function execution: "..(...));
				end
			end
			return HandleCleanFunctionCallArgs(tbl.pcallwithenv(f, tbl, ...));
		end
		setfenv(f, tbl);
		return f;
	end

	local function CleanTable(t, tableCopies)
		if not tableCopies then
			tableCopies = {};
		end

		local cleaned = {};
		tableCopies[t] = cleaned;

		for k, v in tbl.pairs(t) do
			if tbl.type(v) == "table" then
				if ( tableCopies[v] ) then
					cleaned[k] = tableCopies[v];
				else
					cleaned[k] = CleanTable(v, tableCopies);
				end
			elseif tbl.type(v) == "function" then
				cleaned[k] = CleanFunction(v);
			else
				cleaned[k] = v;
			end
		end
		return cleaned;
	end

	local function Import(name)
		local skipTableCopy = true;
		local val = tbl.SecureCapsuleGet(name, skipTableCopy);
		if tbl.type(val) == "function" then
			tbl[name] = CleanFunction(val);
		elseif tbl.type(val) == "table" then
			tbl[name] = CleanTable(val);
		else
			tbl[name] = val;
		end
	end

	Import("ipairs");
	Import("tInvert");
	Import("tinsert");
	Import("IsModifiedClick");
	Import("GetCVarBool");
	Import("C_CVar");
	Import("C_Item");
	Import("GetItemInfo");
	Import("GetSpellInfo");
	Import("UnitTokenFromGUID");
	Import("UnitName");

	if tbl.getmetatable(tbl) == nil then
		local secureEnvMetatable =
		{
			__metatable = false,
			__environment = false,
		}
		tbl.setmetatable(tbl, secureEnvMetatable);
	end
	setfenv(1, tbl);
end
----------------

TooltipUtil = {};

function TooltipUtil.ShouldDoItemComparison()
	return IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems");
end

function TooltipUtil.GetDisplayedItem(tooltip)
	if tooltip:IsTooltipType(Enum.TooltipDataType.Item) then
		local tooltipData = tooltip:GetPrimaryTooltipData();
		local hyperlink;
		if tooltipData.guid then
			hyperlink = C_Item.GetItemLinkByGUID(tooltipData.guid);
		elseif tooltipData.hyperlink then
			hyperlink = tooltipData.hyperlink;
		end
		if hyperlink then
			local name = C_Item.GetItemInfo(hyperlink);
			return name, hyperlink, tooltipData.id;
		end
	end
end

function TooltipUtil.GetDisplayedSpell(tooltip)
	if tooltip:IsTooltipType(Enum.TooltipDataType.Spell) then
		local tooltipData = tooltip:GetPrimaryTooltipData();
		local id = tooltipData.id;
		local name = GetSpellInfo(id);
		return name, id;
	end
end

function TooltipUtil.GetDisplayedUnit(tooltip)
	if tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		local tooltipData = tooltip:GetPrimaryTooltipData();
		local guid = tooltipData.guid;
		local unit = guid and UnitTokenFromGUID(guid);
		local name = unit and UnitName(unit);
		return name, unit, guid;
	end
end

function TooltipUtil.FindLinesFromGetter(lineTypeTable, getterName, ...)
	local tooltipData = C_TooltipInfo[getterName](...);
	return TooltipUtil.FindLinesFromData(lineTypeTable, tooltipData);
end

function TooltipUtil.FindLinesFromData(lineTypeTable, tooltipData)
	local resultTable = { };

	if lineTypeTable and tooltipData then
		local lineTypes = tInvert(lineTypeTable);

		for i, lineData in ipairs(tooltipData.lines) do
			if lineTypes[lineData.type] then
				tinsert(resultTable, lineData);
			end
		end
	end

	return resultTable;
end

function TooltipUtil.DebugCopyGameTooltip()
	local output = "";
	local numLines = GameTooltip:NumLines();
	if numLines > 0 then
		for i = 1, numLines do
			local leftString = _G["GameTooltipTextLeft"..i];
			output = output.."\n"..leftString:GetText();
			local rightString = _G["GameTooltipTextRight"..i];
			local rightText = rightString:GetText();
			if rightText and rightText ~= "" then
				output = output.."\t\t"..rightText;
			end
		end
		CopyToClipboard(output);
		DEFAULT_CHAT_FRAME:AddMessage("GameTooltip copied to clipboard", YELLOW_FONT_COLOR:GetRGB());
	end
end