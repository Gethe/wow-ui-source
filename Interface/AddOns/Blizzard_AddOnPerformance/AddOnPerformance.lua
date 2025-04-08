
StaticPopupDialogs["ADDON_PERFORMANCE_SPECIFIC_ERROR"] = {
	text = ADDON_PERFORMANCE_SPECIFIC_ERROR_TEXT,
	button1 = DISABLE,
	button2 = IGNORE_DIALOG,
	OnAccept = function(self, data)
		ShowUIPanel(AddonList);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ADDON_PERFORMANCE_OVERALL_ERROR"] = {
	text = ADDON_PERFORMANCE_OVERALL_ERROR_TEXT,
	button1 = DISABLE,
	button2 = IGNORE_DIALOG,
	OnAccept = function(self, data)
		ShowUIPanel(AddonList);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

local AddOnPerformanceMixin = { };

function AddOnPerformanceMixin:Init()
	self.shownPerformanceMessages = { };
	self.addOnHasPerformanceWarning = { };

	C_Timer.NewTicker(10, function() self:CheckAndDisplayPerformanceMessage() end);
end

function AddOnPerformanceMixin:DisplayMessage(msg)
	if msg.type == Enum.AddOnPerformanceMessageType.SpecificAddOnChatWarning and msg.addOnName then
		local message = string.format(ADDON_PERFORMANCE_SPECIFIC_WARNING_TEXT, msg.addOnName);
		Chat_AddSystemMessage(message);
	elseif msg.type == Enum.AddOnPerformanceMessageType.SpecificAddOnErrorDialog and msg.addOnName then
		StaticPopup_Show("ADDON_PERFORMANCE_SPECIFIC_ERROR", msg.addOnName);
	elseif msg.type == Enum.AddOnPerformanceMessageType.OverallAddOnErrorDialog then
		StaticPopup_Show("ADDON_PERFORMANCE_OVERALL_ERROR");
	else
		assertsafe(false, "Invalid addon performance msg.");
	end
end

function AddOnPerformanceMixin:CheckAndDisplayPerformanceMessage()
	-- Don't display the message or dialogs while in combat.
	if InCombatLockdown() then
		return;
	end

	local msg = C_AddOnProfiler.CheckForPerformanceMessage();
	if not msg then 
		return;
	end

	if msg.addOnName and not self.addOnHasPerformanceWarning[msg.addOnName] then
		self.addOnHasPerformanceWarning[msg.addOnName] = true;

		if AddonList:IsVisible() then
			AddonList_Update();
		end
	end

	if self.shownPerformanceMessages[msg.type] then
		return;
	end

	self.shownPerformanceMessages[msg.type] = true;
	C_AddOnProfiler.AddPerformanceMessageShown(msg);

	self:DisplayMessage(msg);
end

function AddOnPerformanceMixin:AddOnHasPerformanceWarning(addOnName)
	return self.addOnHasPerformanceWarning[addOnName];
end

AddOnPerformance = CreateAndInitFromMixin(AddOnPerformanceMixin);
