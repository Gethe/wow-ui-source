---------------
--NOTE - Please do not change this section without talking to Jacob
--We usually don't want to call out of this environment from this file.
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

setfenv(1, tbl);

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("C_AuthChallenge");
Import("IsShiftKeyDown");
Import("GetBindingFromClick");

Import("BLIZZARD_CHALLENGE_SUBMIT");
Import("BLIZZARD_CHALLENGE_CANCEL");
Import("BLIZZARD_CHALLENGE_CONNECTING");
Import("BLIZZARD_CHALLENGE_OKAY");
Import("BLIZZARD_CHALLENGE_DENIED_TITLE");
Import("BLIZZARD_CHALLENGE_DENIED_DESCRIPTION");
Import("BLIZZARD_CHALLENGE_ERROR_TITLE");
Import("BLIZZARD_CHALLENGE_ERROR_DESCRIPTION");
Import("BLIZZARD_CHALLENGE_SCREEN_EXPLANATION");

function AuthChallengeUI_OnLoad(self)
	C_AuthChallenge.SetFrame(self);
end

function AuthChallengeUI_Submit()
	C_AuthChallenge.Submit();
end

function AuthChallengeUI_Cancel()
	C_AuthChallenge.Cancel();
end

function AuthChallengeUI_OnTabPressed(self)
	C_AuthChallenge.OnTabPressed(self, IsShiftKeyDown());
end

function AuthChallengeUI_OnKeyDown(self, key)
	-- empty function to trap keystrokes
end