-- ------------------------------------------------------------------------------------------------------------
-- Interact Key Helptip
-- ------------------------------------------------------------------------------------------------------------
local SOFT_TARGET_INTERACT_TUTORIAL_FINISHED_INTERACTIONS = 2; 
local function CanShowInteractTutorial() 
	local hasDoneSoftTargetTutorial = tonumber(GetCVar("softTargetInteractionTutorialTotalInteractions")) >= SOFT_TARGET_INTERACT_TUTORIAL_FINISHED_INTERACTIONS; 
	return (not hasDoneSoftTargetTutorial and tonumber(GetCVar("softTargetInteract")) > Enum.SoftTargetEnableFlags.Gamepad)
end 

local function GetBindingKeyText() 
	local bindingIndex = C_KeyBindings.GetBindingIndex("INTERACTTARGET");
	local _, _, binding1, binding2 = GetBinding(bindingIndex);
	local bindingText = nil;
	if (binding1) then
		bindingText = GetBindingText(binding1);
	elseif (binding2) then 
		bindingText = GetBindingText(binding2);
	end
	return bindingText; 
end 

Class_InteractKeyWatcher = class("InteractKeyWatcher", Class_TutorialBase);
function Class_InteractKeyWatcher:GetBindingKeyText() 
	return GetBindingKeyText(); 
end

function Class_InteractKeyWatcher:GetHelptip()
	local bindingText = self:GetBindingKeyText();
	if(not bindingText) then 
		return nil;
	end 
	local helptipText = INTERACT_KEY_TUTORIAL:format(bindingText, tonumber(GetCVar("softTargetInteractionTutorialTotalInteractions")))
	local helpTipInfo = {
		text = helptipText,
		buttonStyle = HelpTip.ButtonStyle.Close,
		alignment = HelpTip.Alignment.Center,
		targetPoint = HelpTip.Point.LeftEdgeCenter,
		offsetX = 700, 
		offsetY = 50,
		hideArrow = true,
		onAcknowledgeCallback = GenerateClosure(self.CloseTutorial, self),
		acknowledgeOnHide = false,
		system = "TutorialSoftTargetInteraction",
		handlesGlobalMouseEventCallback = function() return true; end,
	};
	return helpTipInfo; 
end

function Class_InteractKeyWatcher:StartWatching()
	Dispatcher:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_SOFT_TARGET_INTERACTION", self);
end

function Class_InteractKeyWatcher:StopWatching()
	Dispatcher:UnregisterEvent("PLAYER_SOFT_INTERACT_CHANGED", self);
	Dispatcher:UnregisterEvent("PLAYER_SOFT_TARGET_INTERACTION", self);
end 

function Class_InteractKeyWatcher:UpdateHelptip()
	local helptipInfo = self:GetHelptip();
	if(helptipInfo and CanShowInteractTutorial()) then
		HelpTip:Show(UIParent, helptipInfo);
	end
end 

function Class_InteractKeyWatcher:PLAYER_SOFT_INTERACT_CHANGED(...)
	local _, currentTarget = ...; 
	if(currentTarget and not HelpTip:IsShowingAnyInSystem("TutorialSoftTargetInteraction")) then 
		self:UpdateHelptip(); 
	end
end

function Class_InteractKeyWatcher:PLAYER_SOFT_TARGET_INTERACTION(...)
	local currInteractions = tonumber(GetCVar("softTargetInteractionTutorialTotalInteractions")); 
	local interactionNumber = currInteractions + 1;
	SetCVar("softTargetInteractionTutorialTotalInteractions", interactionNumber); 
	HelpTip:HideAllSystem("TutorialSoftTargetInteraction");
	self:UpdateHelptip();
	if(interactionNumber >= SOFT_TARGET_INTERACT_TUTORIAL_FINISHED_INTERACTIONS) then
		self:StopWatching(); 
	end
end

function Class_InteractKeyWatcher:CloseTutorial()
	TutorialManager:StopWatcher(self:Name(), true);
	HelpTip:HideAllSystem("TutorialSoftTargetInteraction");
end

-- ------------------------------------------------------------------------------------------------------------
-- Interact Key No Interact Key
-- ------------------------------------------------------------------------------------------------------------
Class_InteractKeyNoKeybindWatcher = class("InteractKeyNoKeybindWatcher", Class_TutorialBase);

local function CanShowInteractKeyNoKeybindTutorial()
	if ((not GetCVarBool("interactKeyWarningTutorial")) and tonumber(GetCVar("softTargetInteract")) > Enum.SoftTargetEnableFlags.Gamepad and not GetBindingKeyText()) then 
		return true;
	else 
		return false; 
	end
end

function Class_InteractKeyNoKeybindWatcher:GetHelptip()
	local helpTipInfo = {
		text = INTERACT_KEY_TUTORIAL_NO_INTERACT_KEY_ASSIGNED,
		buttonStyle = HelpTip.ButtonStyle.Close,
		alignment = HelpTip.Alignment.Center,
		targetPoint = HelpTip.Point.LeftEdgeCenter,
		cvar = "interactKeyWarningTutorial",
		cvarValue = 1,
		offsetX = 700, 
		offsetY = 50,
		hideArrow = true,
		system = "TutorialInteractKeySetBinding",
		handlesGlobalMouseEventCallback = function() return true; end,
	};
	return helpTipInfo; 
end

function Class_InteractKeyNoKeybindWatcher:StartWatching()
	Dispatcher:RegisterEvent("UPDATE_BINDINGS", self);
	self:EvaluateHelptip(); 
end

function Class_InteractKeyNoKeybindWatcher:EvaluateHelptip()
	local helptipInfo = self:GetHelptip();
	if(helptipInfo and CanShowInteractKeyNoKeybindTutorial()) then
		HelpTip:Show(UIParent, helptipInfo);
	end
end

function Class_InteractKeyNoKeybindWatcher:StopWatching()
	Dispatcher:UnregisterEvent("UPDATE_BINDINGS", self);
end 

function Class_InteractKeyNoKeybindWatcher:UPDATE_BINDINGS()
	if (not CanShowInteractKeyNoKeybindTutorial()) then 
		HelpTip:HideAllSystem("TutorialInteractKeySetBinding");
		self:StopWatching(); 
	else	
		self:EvaluateHelptip(); 
	end
end 

function AddFrameTutorials()
	if (CanShowInteractTutorial()) then
		TutorialManager:AddWatcher(Class_InteractKeyWatcher:new(), true);
	end

	if(CanShowInteractKeyNoKeybindTutorial()) then 
		TutorialManager:AddWatcher(Class_InteractKeyNoKeybindWatcher:new(), true);
	end 
end