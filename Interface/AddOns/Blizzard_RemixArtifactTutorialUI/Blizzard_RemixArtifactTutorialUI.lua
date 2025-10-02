
RemixArtifactTutorialControllerMixin = CreateFromMixins(CallbackRegistrantMixin);

local REMIX_ARTIFACT_TUTORIAL_CONTROLLER_EVENTS = {
	"PLAYER_EQUIPMENT_CHANGED",
	"REMIX_ARTIFACT_UPDATE",
	"REMIX_ARTIFACT_ITEM_SPECS_LOADED",
};

local INV_SLOT_TO_CHAR_SLOT_FRAME_NAME = {
	[16] = "CharacterMainHandSlot",
	[17] = "CharacterSecondaryHandSlot",
};

-- This is an OnLoad function since this is load on demand, but the load should always occur after Player Entering World
function RemixArtifactTutorialControllerMixin:OnLoad()
	if not PlayerIsTimerunning() then
		return;
	end

	FrameUtil.RegisterFrameForEvents(self, REMIX_ARTIFACT_TUTORIAL_CONTROLLER_EVENTS);

	EventRegistry:RegisterCallback("PaperDollFrame.VisibilityUpdated", self.OnPaperDollFrameVisibilityUpdated, self);

	self:UpdateArtifactSlot(INVSLOT_MAINHAND);
	self:UpdateArtifactSlot(INVSLOT_OFFHAND);
end

function RemixArtifactTutorialControllerMixin:RegisterForRemixArtifactFrameEvents()
	self.traitFrame = RemixArtifactFrame;

	EventRegistry:RegisterCallback("RemixArtifactFrame.VisibilityUpdated", self.OnRemixArtifactFrameVisibilityUpdated, self);
end

function RemixArtifactTutorialControllerMixin:OnEvent(event, ...)
	if event == "PLAYER_EQUIPMENT_CHANGED" then
		local slotID = ...;
		self:UpdateArtifactSlot(slotID);
	elseif event == "REMIX_ARTIFACT_UPDATE" then
		self:UpdateTutorialState();
	elseif event == "REMIX_ARTIFACT_ITEM_SPECS_LOADED" then
		local loadSuccessful = ...;
		if loadSuccessful then
			self:UpdateTutorialState();
		end
	end
end

function RemixArtifactTutorialControllerMixin:UpdateArtifactSlot(slotID)
	if C_RemixArtifactUI.ItemInSlotIsRemixArtifact(slotID) then
		self.currEquippedArtifactSlotID = slotID;
	elseif slotID == self.currEquippedArtifactSlotID then
		-- If the slot is being updated to a non-artifact, we want to clear the current slot
		self.currEquippedArtifactSlotID = nil;
	end

	self:UpdateTutorialState();
end

function RemixArtifactTutorialControllerMixin:UpdateTutorialState()
	self:UpdateRootNodeState();

	if not self:ShouldShowTutorial() or not self.currEquippedArtifactSlotID or (self.traitFrame and self.traitFrame:IsShown()) then
		HelpTip:Hide(self, REMIX_ARTIFACT_TUTORIAL_CHOOSE_TRAITS_TEXT);
		HelpTip:Hide(self, REMIX_ARTIFACT_TUTORIAL_CLICK_TO_OPEN_TEXT);
		MicroButtonPulseStop(CharacterMicroButton);
		return;
	end

	local equipmentPageShown = PaperDollItemsFrame:IsVisible();
	if not equipmentPageShown then
		local helpTipInfo = {
			text = REMIX_ARTIFACT_TUTORIAL_CHOOSE_TRAITS_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			hideArrow = false,
			offsetY = 10,
		};

		HelpTip:Show(self, helpTipInfo, CharacterMicroButton);
		MicroButtonPulse(CharacterMicroButton);
		HelpTip:Hide(self, REMIX_ARTIFACT_TUTORIAL_CLICK_TO_OPEN_TEXT);
	elseif equipmentPageShown then
		local helpTipInfo = {
			text = REMIX_ARTIFACT_TUTORIAL_CLICK_TO_OPEN_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			hideArrow = false,
			offsetY = 10,
		};

		local equippedItemFrame = _G[INV_SLOT_TO_CHAR_SLOT_FRAME_NAME[self.currEquippedArtifactSlotID]];
		HelpTip:Show(self, helpTipInfo, equippedItemFrame);
		HelpTip:Hide(self, REMIX_ARTIFACT_TUTORIAL_CHOOSE_TRAITS_TEXT);
	end
end

function RemixArtifactTutorialControllerMixin:ShouldShowTutorial()
	local specIndex = C_RemixArtifactUI.GetCurrItemSpecIndex();

	if not specIndex then
		-- If the artifact isn't equipped then we don't wanna do this
		return false;
	end

	return not GetCVarBitfield("closedRemixArtifactTutorialFrames", specIndex);
end

function RemixArtifactTutorialControllerMixin:OnPaperDollFrameVisibilityUpdated(_shown)
	self:UpdateTutorialState();
end

function RemixArtifactTutorialControllerMixin:OnRemixArtifactFrameVisibilityUpdated(shown)
	self:UpdateTutorialState();

	if shown then
		self:AddStaticEventMethod(self.traitFrame, TalentFrameBaseMixin.Event.ConfigCommitted, self.OnRemixArtifactFrameConfigCommitted);
		self:AddStaticEventMethod(self.traitFrame, TalentFrameBaseMixin.Event.TalentButtonNodeUpdated, self.OnTalentButtonBaseUpdated);
	else
		self:RemoveStaticEventMethod(self.traitFrame, TalentFrameBaseMixin.Event.ConfigCommitted, self.OnRemixArtifactFrameConfigCommitted);
		self:RemoveStaticEventMethod(self.traitFrame, TalentFrameBaseMixin.Event.TalentButtonNodeUpdated, self.OnTalentButtonBaseUpdated);

		local rootNode = self.traitFrame:GetRootTalentButton();
		if not rootNode then
			return;
		end

		rootNode:StopGlow();
	end
end

function RemixArtifactTutorialControllerMixin:OnRemixArtifactFrameConfigCommitted(_configID)
	if not self.traitFrame then
		return;
	end

	local nodeID = nil;
	local isCommitUpdate = true;
	self:UpdateRootNodeState(nodeID, isCommitUpdate);
end

function RemixArtifactTutorialControllerMixin:OnTalentButtonBaseUpdated(nodeID)
	self:UpdateRootNodeState(nodeID);
end

-- nodeID, multiple nodes could send of multiple events. This allows for us to check if the root node and the node sending the update are equal
-- isCommitUpdate, we only want to "acknowledge" the tutorial as completed when the player has committed their changes
function RemixArtifactTutorialControllerMixin:UpdateRootNodeState(nodeID, isCommitUpdate)
	if not self.traitFrame then
		return;
	end

	if self.traitFrame:IsShown() then
		local rootNode = self.traitFrame:GetRootTalentButton();
		if not rootNode then
			return;
		end

		local nodeInfo = rootNode:GetNodeInfo();
		if not nodeInfo or (nodeID and nodeID ~= rootNode:GetNodeID()) then
			return;
		end

		self.traitFrame:RegisterNodeForUpdateInfoEvent(rootNode:GetNodeID());

		if nodeInfo.activeRank > 0 then
			local specIndex = C_RemixArtifactUI.GetCurrItemSpecIndex();
			if (specIndex and isCommitUpdate) then
				SetCVarBitfield("closedRemixArtifactTutorialFrames", specIndex, true);
			end

			HelpTip:Hide(self, REMIX_ARTIFACT_TUTORIAL_CHOOSE_TRAITS_TEXT);
			HelpTip:Hide(self, REMIX_ARTIFACT_TUTORIAL_CLICK_TO_OPEN_TEXT);
			rootNode:StopGlow();
			MicroButtonPulseStop(CharacterMicroButton);
		else
			rootNode:StartGlow();
		end
	end
end
