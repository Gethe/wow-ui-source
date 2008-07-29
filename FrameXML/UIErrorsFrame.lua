
function UIErrorsFrame_OnLoad(self)
	self:RegisterEvent("SYSMSG");
	self:RegisterEvent("UI_INFO_MESSAGE");
	self:RegisterEvent("UI_ERROR_MESSAGE");
end

function UIErrorsFrame_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4 = ...
	if ( event == "SYSMSG" ) then
		self:AddMessage(arg1, arg2, arg3, arg4, 1.0);
	elseif ( event == "UI_INFO_MESSAGE" ) then
		self:AddMessage(arg1, 1.0, 1.0, 0.0, 1.0);
	elseif ( event == "UI_ERROR_MESSAGE" ) then
		self:AddMessage(arg1, 1.0, 0.1, 0.1, 1.0);
	end
end