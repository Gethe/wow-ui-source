-- DO NOT PUT ANY SENSITIVE CODE IN THIS FILE
-- This file does not have access to the secure (forbidden) code.  It is only called via Outbound and no function in this file should ever return values.

function RedeemFailed(result)
	local error;
	if (result == LE_TOKEN_RESULT_ERROR_TRIAL_RESTRICTED) then
		error = TOKEN_TRIAL_RESTRICTIONS;
	elseif (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
		error = TOKEN_AUCTIONS_UNAVAILABLE;
	else
		error = SPELL_FAILED_ERROR;
	end
	UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0);
end
