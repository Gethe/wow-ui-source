
-- Narration Manager
--
-- This is in charge of taking in a stream of narration events and playing them.
-- Eventually this should handle tracking specific utteranceIDs and supporting controls to cancel and replay utterances.
--
-- Consumes events:
--
--		"Narration.Speak" (narrationInfo)
--			narrationInfo: See NarrationUtil.CreateNarrationInfo.
--
--		"Narration.Queue" (narrationInfo)
--			narrationInfo: See NarrationUtil.CreateNarrationInfo.
--
-- Generates:
--
-- 		"Narration.Interrupted" (triggerType)
--			triggerType: See NarrationUtil.TriggerType.
--
-- 		"Narration.SystemStatus" (isEnabled)
--			isEnabled: Whether the narration system is now active.

NarrationManagerMixin = {};

local function SpeakScreenNarration(text)
	local voiceID = CVarCallbackRegistry:GetCVarNumberOrDefault("accessibilityScreenNarrationVoice");
	local speechRate = CVarCallbackRegistry:GetCVarNumberOrDefault("accessibilityScreenNarrationSpeechRate");
	local speechVolume = CVarCallbackRegistry:GetCVarNumberOrDefault("accessibilityScreenNarrationSpeechVolume");
	C_VoiceChat.SpeakText(voiceID, text, speechRate, speechVolume);
end

local function SpeakNarrationInfo(narrationInfo)
	local text = NarrationUtil.MakeNarrationStringFromInfo(narrationInfo);
	if not text then
		return;
	end

	SpeakScreenNarration(text);
end

function NarrationManagerMixin:Init()
	CVarCallbackRegistry:SetCVarCachable("accessibilityScreenNarrationEnabled");
	CVarCallbackRegistry:RegisterCallback("accessibilityScreenNarrationEnabled", self.OnCVarChanged, self);

	CVarCallbackRegistry:SetCVarCachable("accessibilityScreenNarrationVoice");
	CVarCallbackRegistry:SetCVarCachable("accessibilityScreenNarrationSpeechRate");
	CVarCallbackRegistry:SetCVarCachable("accessibilityScreenNarrationSpeechVolume");

	if NarrationUtil.ShouldBeEnabled() then
		self:RegisterEvents();
	end
end

function NarrationManagerMixin:RegisterEvents()
	if self.eventsRegistered then
		assertsafe(false, "NarrationManager:RegisterEvents - Events already registered");
		return;
	end

	self.eventsRegistered = true;
	EventRegistry:RegisterCallback("Narration.Speak", self.OnSpeak, self);
	EventRegistry:RegisterCallback("Narration.Queue", self.OnQueue, self);
	EventRegistry:RegisterForOnUpdate(self, self.OnUpdate);
	EventRegistry:TriggerEvent("Narration.SystemStatus", true);
end

function NarrationManagerMixin:UnregisterEvents()
	if not self.eventsRegistered then
		assertsafe(false, "NarrationManager:UnregisterEvents - Events not registered");
		return;
	end

	self.eventsRegistered = false;
	EventRegistry:UnregisterCallback("Narration.Speak", self);
	EventRegistry:UnregisterCallback("Narration.Queue", self);
	EventRegistry:UnregisterForOnUpdate(self);
	C_VoiceChat.StopSpeakingText();
	EventRegistry:TriggerEvent("Narration.SystemStatus", false);
end

function NarrationManagerMixin:OnCVarChanged()
	local enabled = NarrationUtil.ShouldBeEnabled();
	if enabled then
		self:RegisterEvents();
	elseif self.eventsRegistered then
		self:UnregisterEvents();
	end
end

function NarrationManagerMixin:OnUpdate()
	-- Pressing the control key should instantly stop any active text narration.
	if IsControlKeyDown() then
		if not self.controlKeyDown then
			self.controlKeyDown = true;
			C_VoiceChat.StopSpeakingText();
		end
	else
		self.controlKeyDown = false;
	end
end

function NarrationManagerMixin:OnSpeak(narrationInfo)
	-- For now we always interrupt. Eventually this could take into account the trigger type
	-- and intelligently queue or interrupt based on priority, etc.
	C_VoiceChat.StopSpeakingText();
	EventRegistry:TriggerEvent("Narration.Interrupted", narrationInfo.triggerType);

	SpeakNarrationInfo(narrationInfo);
end

function NarrationManagerMixin:OnQueue(narrationInfo)
	SpeakNarrationInfo(narrationInfo);
end

NarrationManager = CreateAndInitFromMixin(NarrationManagerMixin);
