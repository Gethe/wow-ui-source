
UIERRORS_HOLD_TIME = 5;

function UIErrorsFrame_OnLoad()
	this:RegisterEvent("SYSMSG");
	this:RegisterEvent("UI_INFO_MESSAGE");
	this:RegisterEvent("UI_ERROR_MESSAGE");
end

function UIErrorsFrame_OnEvent(event, message)
	if ( event == "SYSMSG" ) then
		this:AddMessage(message, arg2, arg3, arg4, 1.0, UIERRORS_HOLD_TIME);
	elseif ( event == "UI_INFO_MESSAGE" ) then
		this:AddMessage(message, 1.0, 1.0, 0.0, 1.0, UIERRORS_HOLD_TIME);
	elseif ( event == "UI_ERROR_MESSAGE" ) then
		this:AddMessage(message, 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME);
	end
end