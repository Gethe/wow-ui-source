local next = next;
local securecallfunction = securecallfunction;

local function SecureNext(elements, key)
    return securecallfunction(next, elements, key);
end

SettingsRegistrar = {};

function SettingsRegistrar:OnLoad()
	if IsOnGlueScreen() then
		self.allowCallRegistrants = true;
	else
		self.registrants = {};

		local function Callback()
			self.allowCallRegistrants = true;

			for index, registrant in SecureNext, self.registrants do
				securecallfunction(registrant);
			end

			C_EventUtils.NotifySettingsLoaded();
		end

		EventUtil.ContinueAfterAllEvents(Callback, "VARIABLES_LOADED", "PLAYER_ENTERING_WORLD");
	end
end

function SettingsRegistrar:AddRegistrant(registrant)
	if self.allowCallRegistrants then
		securecallfunction(registrant);
	else
		table.insert(self.registrants, registrant);
	end
end

SettingsRegistrar:OnLoad();