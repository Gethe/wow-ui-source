
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