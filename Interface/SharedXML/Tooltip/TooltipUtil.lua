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