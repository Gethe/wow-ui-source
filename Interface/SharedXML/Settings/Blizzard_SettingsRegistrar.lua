local securecallfunction = securecallfunction;

SettingsRegistrar = {};

function SettingsRegistrar:OnLoad()
	if IsOnGlueScreen() then
		self.allowCallRegistrants = true;
	else
		self.registrants = {};

		local function Callback()
			self.allowCallRegistrants = true;

			local function CallRegistrant(index, registrant)
				registrant();
			end
			secureexecuterange(self.registrants, CallRegistrant);

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