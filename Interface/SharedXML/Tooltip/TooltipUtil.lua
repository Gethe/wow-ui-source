TooltipUtil = {};

function TooltipUtil.ShouldDoItemComparison()
	return IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems");
end