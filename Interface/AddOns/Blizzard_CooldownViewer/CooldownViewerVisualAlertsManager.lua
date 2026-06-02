CooldownViewerVisualAlertsManagerMixin = {};

function CooldownViewerVisualAlertsManagerMixin:OnLoad()
	self.poolCollection = CreateFramePoolCollection();
	self.payloadToTemplateLookup = {};
end

function CooldownViewerVisualAlertsManagerMixin:RegisterAlert(alertPayload, alertTemplate)
	local existingTemplate = self.payloadToTemplateLookup[alertPayload];
	assertsafe(existingTemplate == nil, "CooldownViewerVisualAlertsManager: Attempting to register duplicate alert payload %s (existing: %s, new: %s)", tostring(alertPayload), tostring(existingTemplate), tostring(alertTemplate));
	if not existingTemplate then
		self.payloadToTemplateLookup[alertPayload] = alertTemplate;
		self.poolCollection:CreatePool("Frame", nil, alertTemplate); -- Acquired frames will be reparented to their target.
	end
end

function CooldownViewerVisualAlertsManagerMixin:AcquireAlert(alertPayload, target)
	local alertTemplate = self.payloadToTemplateLookup[alertPayload];
	assertsafe(alertTemplate ~= nil, "CooldownViewerVisualAlertsManager: No registered alert template for payload %s", tostring(alertPayload));
	if alertTemplate then
		local alert = self.poolCollection:Acquire(alertTemplate);
		alert:SetAlertTarget(target); -- this is the chance to setup data on the alert, anchor it, and show it, at the bare minimum the base should do something like: self:SetParent(target);
		return alert;
	end

	return nil;
end

function CooldownViewerVisualAlertsManagerMixin:ReleaseAlert(alert)
	alert:ClearAlertTarget();
	self.poolCollection:Release(alert);
end
