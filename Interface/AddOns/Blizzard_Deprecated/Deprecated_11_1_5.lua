-- These are functions that were deprecated in 11.1.5 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

-- Console can no longer be send messages directly (ConsolePrint removed from the API). 
-- Use C_Log.LogMessage to ensure the message is received by the Console and other sources of internal tooling.
ConsolePrint = function(...)
	C_Log.LogMessage(string.join(" ", tostringall(...)));
end

-- 'message' renamed to SetBasicMessageDialogText in SharedBasicControls.
message = SetBasicMessageDialogText;