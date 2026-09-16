-- Used to register templates for different types of visual alerts so they can be pooled and acquired and
-- released as necessary for visual alert targets that need to display visual alerts.
VisualAlertsManagerMixin = {};

function VisualAlertsManagerMixin:OnLoad()
	self.poolCollection = CreateFramePoolCollection();
	self.payloadToTemplateLookup = {};
	VisualAlerts_RegisterAll(self);
end

function VisualAlertsManagerMixin:RegisterAlert(visualAlertType, alertTemplate)
	local existingTemplate = self.payloadToTemplateLookup[visualAlertType];
	assertsafe(existingTemplate == nil, "VisualAlertsManager: Attempting to register duplicate alert payload %s (existing: %s, new: %s)", tostring(visualAlertType), tostring(existingTemplate), tostring(alertTemplate));
	if not existingTemplate then
		self.payloadToTemplateLookup[visualAlertType] = alertTemplate;
		self.poolCollection:CreatePool("Frame", nil, alertTemplate); -- Acquired frames will be reparented to their target.
	end
end

function VisualAlertsManagerMixin:IsAlertRegistered(visualAlertType)
	return self.payloadToTemplateLookup[visualAlertType] ~= nil;
end

function VisualAlertsManagerMixin:AcquireAlert(visualAlertType, target)
	local alertTemplate = self.payloadToTemplateLookup[visualAlertType];
	assertsafe(alertTemplate ~= nil, "VisualAlertsManager: No registered alert template for payload %s", tostring(visualAlertType));
	if alertTemplate then
		local alert = self.poolCollection:Acquire(alertTemplate);
		alert.alertManager = self;
		alert:SetAlertTarget(target); -- this is the chance to setup data on the alert, anchor it, and show it, at the bare minimum the base should do something like: self:SetParent(target);
		return alert;
	end

	return nil;
end

function VisualAlertsManagerMixin:ReleaseAlert(alert)
	alert:ClearAlertTarget();
	alert.alertManager = nil;
	self.poolCollection:Release(alert);
end
