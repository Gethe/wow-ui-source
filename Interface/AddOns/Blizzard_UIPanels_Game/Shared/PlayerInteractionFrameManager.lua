local registeredInteractionManagerFrameInfo = { };
local registeredInteractionManagerConditions = { };

local function ValidateInteractionFrameInfo(interactionType, frameInfo)
	if type(interactionType) ~= "number" then
		error("RegisterPlayerInteraction expected interactionType to be a number.");
	end

	if type(frameInfo) ~= "table" then
		error("RegisterPlayerInteraction expected frameInfo to be a table.");
	end

	if type(frameInfo.frame) ~= "string" then
		error("RegisterPlayerInteraction expected frameInfo.frame to be a string.");
	end

	if frameInfo.loadFunc and type(frameInfo.loadFunc) ~= "function" then
		error("RegisterPlayerInteraction expected frameInfo.loadFunc to be a function.");
	end

	if frameInfo.showFunc and type(frameInfo.showFunc) ~= "function" then
		error("RegisterPlayerInteraction expected frameInfo.showFunc to be a function.");
	end

	if frameInfo.hideFunc and type(frameInfo.hideFunc) ~= "function" then
		error("RegisterPlayerInteraction expected frameInfo.hideFunc to be a function.");
	end
	
	return frameInfo;
end

local function ValidateInteractionConditions(interactionType, conditions)
	if type(interactionType) ~= "number" then
		error("AddPlayerInteractionConditions expected interactionType to be a number.");
	end

	if type(conditions) ~= "table" then
		error("AddPlayerInteractionConditions expected conditions to be a table.");
	end

	if conditions.loadCondition and type(conditions.loadCondition) ~= "function" then
		error("AddPlayerInteractionConditions expected conditions.loadCondition to be a function.");
	end

	if conditions.showCondition and type(conditions.showCondition) ~= "function" then
		error("AddPlayerInteractionConditions expected conditions.showCondition to be a function.");
	end

	if conditions.hideCondition and type(conditions.hideCondition) ~= "function" then
		error("AddPlayerInteractionConditions expected conditions.hideCondition to be a function.");
	end

	return conditions;
end

--[[
Registers frame behavior for a player interaction type.

frame = [REQUIRED][STRING] - Global frame name. The frame may not be loaded yet.
showFunc = [OPTIONAL][FUNCTION] - Called when the interaction is shown. If omitted, ShowUIPanel is called for frame.
hideFunc = [OPTIONAL][FUNCTION] - Called when the interaction is hidden. If omitted, HideUIPanel is called for frame.
loadFunc = [OPTIONAL][FUNCTION] - Called before show when the frame is not loaded yet.

Example:
RegisterPlayerInteraction(Enum.PlayerInteractionType.Trainer,
	{
		frame = "ClassTrainerFrame",
		loadFunc = ClassTrainerFrame_LoadUI,
		showFunc = ShowTrainerFrame,
		hideFunc = HideTrainerFrame,
	});
]]
function RegisterPlayerInteraction(interactionType, frameInfo)
	if registeredInteractionManagerFrameInfo[interactionType] then
		error("RegisterPlayerInteraction received a duplicate registration for interactionType "..interactionType..".");
	end

	registeredInteractionManagerFrameInfo[interactionType] = ValidateInteractionFrameInfo(interactionType, frameInfo);
end

--[[
Registers optional gating logic for a player interaction type. Use this for game-state checks that should control whether load, show, or hide are allowed.

loadCondition = [OPTIONAL][FUNCTION] - Must return true before loadFunc is called.
showCondition = [OPTIONAL][FUNCTION] - Must return true before the interaction is shown.
hideCondition = [OPTIONAL][FUNCTION] - Must return true before the interaction is hidden.

Example:
AddPlayerInteractionConditions(Enum.PlayerInteractionType.Auctioneer,
	{
		showCondition = function()
			return not GameLimitedMode_IsActive();
		end,
	});
]]
function AddPlayerInteractionConditions(interactionType, conditions)
	if registeredInteractionManagerConditions[interactionType] then
		error("AddPlayerInteractionConditions received duplicate conditions for interactionType "..interactionType..".");
	end

	registeredInteractionManagerConditions[interactionType] = ValidateInteractionConditions(interactionType, conditions);
end

PlayerInteractionFrameManagerMixin = { };

local function GetFrameInfo(interactionType)
	return registeredInteractionManagerFrameInfo[interactionType];
end

local function GetInteractionConditions(interactionType)
	return registeredInteractionManagerConditions[interactionType];
end

local function GetInteractionFrame(frameInfo)
	return _G[frameInfo.frame];
end

local function CheckCondition(conditionFunc)
	return not conditionFunc or conditionFunc();
end

function PlayerInteractionFrameManagerMixin:ShowFrame(interactionType)
	local frameInfo = GetFrameInfo(interactionType);
	if not frameInfo then
		return;
	end

	local conditions = GetInteractionConditions(interactionType);
	local interactionFrame = GetInteractionFrame(frameInfo);

	if frameInfo.loadFunc and not interactionFrame and CheckCondition(conditions and conditions.loadCondition) then
		frameInfo.loadFunc();
		interactionFrame = GetInteractionFrame(frameInfo);
	end

	if not CheckCondition(conditions and conditions.showCondition) then
		return;
	end

	if frameInfo.showFunc then
		frameInfo.showFunc();
	else
		ShowUIPanel(interactionFrame, frameInfo.forceShow);
	end
end

function PlayerInteractionFrameManagerMixin:HideFrame(interactionType)
	local frameInfo = GetFrameInfo(interactionType);
	if not frameInfo then
		return;
	end

	local interactionFrame = GetInteractionFrame(frameInfo);

	-- The frame isn't loaded, so nothing to hide.
	if not interactionFrame then
		return;
	end

	local conditions = GetInteractionConditions(interactionType);

	if not CheckCondition(conditions and conditions.hideCondition) then
		return;
	end

	if frameInfo.hideFunc then
		frameInfo.hideFunc();
	else
		HideUIPanel(interactionFrame);
	end
end

function PlayerInteractionFrameManagerMixin:OnLoad()
	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW");
	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE");
end

function PlayerInteractionFrameManagerMixin:OnEvent(event, ...)
	if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
		local interactionType = ...;
		self:ShowFrame(interactionType);
	elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
		local interactionType = ...;
		self:HideFrame(interactionType);
	end
end

local frame = CreateFrame("Frame");
Mixin(frame, PlayerInteractionFrameManagerMixin);
frame:SetScript("OnEvent", PlayerInteractionFrameManagerMixin.OnEvent);
frame:OnLoad();
