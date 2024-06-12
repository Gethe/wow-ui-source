
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
		local name = C_Spell.GetSpellName(id);
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