TitleUtil = {};

function TitleUtil.GetNameFromTitleMaskID(titleMaskID)
	local titleName = GetTitleName(titleMaskID);
	if titleName then
		return strtrim(titleName);
	end
end