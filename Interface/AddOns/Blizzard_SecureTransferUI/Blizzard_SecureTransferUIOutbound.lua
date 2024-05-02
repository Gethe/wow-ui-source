-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local SecureTransferOutbound = {};
secureEnv.SecureTransferOutbound = SecureTransferOutbound;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function SecureTransferOutbound.UpdateSendMailButton()
    securecall("SendMailFrame_EnableSendMailButton");
end
