TooltipUtil = {};

function TooltipUtil.ShouldDoItemComparison()
	return IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems");
end

function TooltipUtil.SurfaceArgs(tbl)
	if not tbl.args then
		return;
	end
	for i, arg in ipairs(tbl.args) do
		tbl[arg.field] = arg.stringVal or arg.intVal or arg.floatVal or arg.boolVal or arg.colorVal or arg.guidVal;
	end	
end

function TooltipUtil.GetDisplayedItem(tooltip)
	if tooltip:IsTooltipType(Enum.TooltipDataType.Item) then
		local tooltipData = tooltip:GetTooltipData();
		local hyperlink;
		if tooltipData.guid then
			hyperlink = C_Item.GetItemLinkByGUID(tooltipData.guid);
		elseif tooltipData.hyperlink then
			hyperlink = tooltipData.hyperlink;
		end
		if hyperlink then
			local name = GetItemInfo(hyperlink);
			return name, hyperlink, tooltipData.id;
		end
	end
end

function TooltipUtil.GetDisplayedSpell(tooltip)
	if tooltip:IsTooltipType(Enum.TooltipDataType.Spell) then
		local tooltipData = tooltip:GetTooltipData();
		local id = tooltipData.id;
		local name = GetSpellInfo(id);
		return name, id;
	end
end

function TooltipUtil.GetDisplayedUnit(tooltip)
	if tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		local tooltipData = tooltip:GetTooltipData();
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
			if not lineData.type then
				TooltipUtil.SurfaceArgs(lineData);
			end
			if lineTypes[lineData.type] then
				tinsert(resultTable, lineData);
			end
		end
	end

	return resultTable;
end