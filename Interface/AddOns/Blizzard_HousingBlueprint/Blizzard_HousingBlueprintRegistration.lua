do
	local exportAttributes = 
	{ 
		area = "centerOrLeft",
		pushable = 1,
	};
	local importAttributes = 
	{ 
		area = "centerOrLeft",
		pushable = 1,
	};
	local contentListAttributes = 
	{ 
		area = "left",
		pushable = 1,
	};
	local renameAttributes = 
	{ 
		area = "centerOrLeft",
		pushable = 1,
	};
	RegisterUIPanel(HousingBlueprintExportFrame, exportAttributes);
	RegisterUIPanel(HousingBlueprintImportFrame, importAttributes);
	RegisterUIPanel(HousingBlueprintContentListFrame, contentListAttributes);
	RegisterUIPanel(HousingBlueprintRenameFrame, renameAttributes);
end

local function HousingBlueprintFrame_EscapePressed()
	if HousingBlueprintExportFrame:TryHandleEscape() then
		return true;
	end
	if HousingBlueprintImportFrame:TryHandleEscape() then
		return true;
	end
	if HousingBlueprintRenameFrame:TryHandleEscape() then
		return true;
	end

	return false;
end

RegisterGameMenuEscHandler(GameMenuEscPriority.FrameworkPre, HousingBlueprintFrame_EscapePressed);
