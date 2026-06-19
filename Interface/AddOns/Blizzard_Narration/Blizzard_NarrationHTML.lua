
---------------------------------------------------------------------------
-- NarrationHTMLMixin
--
-- Narrates as: concatenated text of all text entries in GetTextData
---------------------------------------------------------------------------

NarrationHTMLMixin = {};

function NarrationHTMLMixin:NarrationGetName()
	local textData = self:GetTextData();
	if not textData or #textData < 1 then
		return nil;
	end

	local textList = {};
	for _, contentNode in ipairs(textData) do
		textList[#textList + 1] = contentNode.text;
	end
	return table.concat(textList, " ");
end
