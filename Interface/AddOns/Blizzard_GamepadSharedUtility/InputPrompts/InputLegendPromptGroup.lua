local LEGEND_BACKGROUND_PADDING = 10;   -- Spacing between the prompts and the background border.
local BORDER_MERGE_OFFSEET = -6;		--[[ Offset applied to the prompt container group that shifts it to the left so that
											 the border of the prompt container overlaps that of the modifier section's border ]]

local LEGEND_BACKGROUND_BORDER_FOCUSED_STYLE_ATLAS = "gamepad-footer-slot-framefocused";
local LEGEND_BACKGROUND_BORDER_ENABLED_STYLE_ATLAS = "gamepad-footer-slot-frameenabled";
local LEGEND_BACKGROUND_BORDER_NEUTRAL_STYLE_ATLAS = "gamepad-footer-slot-frameneutral";
local LEGEND_BACKGROUND_SLOT_ATLAS = "gamepad-footer-slot-bg";

local MODIFIER_FOCUSED_FRAME_LEVEL = 5;
local MODIFIER_ENABLED_FRAME_LEVEL = 4;
local PROMPT_CONTAINER_FOCUSED_FRAME_LEVEL = 5;
local PROMPT_CONTAINER_NEUTRAL_FRAME_LEVEL = 4;

local MODIFIER_ARROW_FOCUSED_ALPHA = 1;
local MODIFIER_ARROW_ENABLED_ALPHA = 0.7;
local MODIFIER_ARROW_WIDTH = 10;
local MODIFIER_ARROW_HEIGHT = 10;
local MODIFIER_ARROW_ROTATION = math.pi/2;
local MODIFIER_ARROW_ATLAS = "minimal-scrollbar-small-arrow-bottom-down";
local MODIFIER_ARROW_LEFT_PADDING = 3;

local SupportedPromptTemplates =
{
	StandardOneIcon =
	{
		name = "StandardOneIcon",
		template = "InputPromptOneIconWithTextTemplate",
	},
	StandardTwoIcon =
	{
		name = "StandardTwoIcon",
		template = "InputPromptTwoIconWithTextTemplate",
	}
}

InputPromptLegends = { PromptTemplates = SupportedPromptTemplates, InputPromptLegendMixin = {}, FrameActionMixin = {}}
local InputPromptLegendMixin = InputPromptLegends.InputPromptLegendMixin;
local FrameActionMixin = InputPromptLegends.FrameActionMixin;

--[[
	Creates a frame action prompt object.

	actionID - Unique id/name for the frame action prompt that is used to reference
			   the frame action in the future within the input prompt legend group the
			   frame action is added to.

	promptTemplate - The type of prompt this frame action represents. See InputPromptLegendMixin's
					 PromptTemplates member for supported templates.

	promptInputKeys - A table containing the string ids for the input keys in the order they will
					  be assigned to the promptTemplate input icons.

	promptText - The text that should be displayed in the promptTemplates text field.
]]
function InputPromptLegends.CreateFrameAction(actionID, promptTemplate, promptInputKeys, promptText)
	local frameAction = CreateFromMixins(FrameActionMixin);
	frameAction.promptID = actionID;
	frameAction.template = promptTemplate;
	frameAction.inputKeys = promptInputKeys;
	frameAction.text = promptText;
	frameAction.initializePromptAsInactive = false;

	return frameAction;
end

--[[
	Assigns a divider type to the frame action which is used by prompt templates that support dividers.
	See InputPrompts.lua for divider types.

	dividerType - string indicating the type of divider that should be used (GAMEPAD_PROMPT_DIVIDER_PLUS, GAMEPAD_PROMPT_DIVIDER_SLASH, etc.).
]]
function FrameActionMixin:SetDividerType(dividerType)
	self.divider = dividerType;
end

function FrameActionMixin:InitializePromptAsInactive()
	self.initializePromptAsInactive = true;
end

function FrameActionMixin:GetPromptID()
	return self.promptID;
end

--[[
	Creates an input prompt legend object.

	parentFrame - The owner of the input prompt legend object.

	parentKey - The key used to store the input prompt legend object in the parent .
]]
function InputPromptLegends.CreateInputLegend(parentFrame, parentKey, useWideBackground)
	local inputPromptLegend = CreateFrame("FRAME", nil, parentFrame);
	inputPromptLegend = Mixin(inputPromptLegend, InputPromptLegendMixin);
	inputPromptLegend:SetParentKey(parentKey);

	inputPromptLegend.promptMap = {};
	inputPromptLegend.promptFrames = {};
	inputPromptLegend.promptFramesAddOrder = {};
	inputPromptLegend.actions = {};
	inputPromptLegend.wrapAroundRowWidth = false;   -- By default the input legends use a single row. Enable wrapping by using SetLegendWidth.

	local promptContainerFrame = CreateFrame("Frame", nil, inputPromptLegend);
	inputPromptLegend.promptContainerFrame = promptContainerFrame;
	promptContainerFrame:SetPoint("TOPLEFT", inputPromptLegend, "TOPLEFT");

	-- Add the background
	promptContainerFrame.backgroundSlot = promptContainerFrame:CreateTexture();
	promptContainerFrame.backgroundBorder = promptContainerFrame:CreateTexture();
	if (useWideBackground) then
		inputPromptLegend:ApplyWideStyle();
	else
		inputPromptLegend:ApplyDefaultStyle();
	end
	promptContainerFrame:SetFrameLevel(PROMPT_CONTAINER_NEUTRAL_FRAME_LEVEL);

	return inputPromptLegend;
end

function InputPromptLegendMixin:ApplyDefaultStyle()
	self.promptContainerFrame.backgroundSlot:ClearAllPoints();
	self.promptContainerFrame.backgroundSlot:SetAllPoints();
	self.promptContainerFrame.backgroundSlot:SetAtlas(LEGEND_BACKGROUND_SLOT_ATLAS, true);
	self.promptContainerFrame.backgroundSlot:SetAlpha(1);
	self.promptContainerFrame.backgroundBorder:SetAllPoints();
	self.promptContainerFrame.backgroundBorder:SetAtlas(LEGEND_BACKGROUND_BORDER_NEUTRAL_STYLE_ATLAS, true);
	self.promptContainerFrame.backgroundBorder:SetAlpha(1);
	self.promptContainerFrame.backgroundBorder:Show();
end

function InputPromptLegendMixin:ApplyWideStyle()
	self.promptContainerFrame.backgroundSlot:ClearAllPoints();
	self.promptContainerFrame.backgroundSlot:SetPoint("CENTER")
	self.promptContainerFrame.backgroundSlot:SetAtlas("gamepad-glues-footer-bga", true);
	self.promptContainerFrame.backgroundSlot:SetAlpha(1);
	self.promptContainerFrame.backgroundBorder:Hide();
end

--[[
	Adds a frame action to the legend's list of frame actions

	frameAction - A FrameAction object containing information about
				  a prompt that the legend wil display.
]]
function InputPromptLegendMixin:AddFrameAction(frameAction)
	-- Add error checking against same action ids.
	table.insert(self.actions, { action = frameAction, isFrameAction = true });
end

function InputPromptLegendMixin:RefreshWithPromptedBindings(promptedBindings)
	-- We might be removing a prompt by omitting it from this list, so hide everything first.
	for _, frame in pairs(self.promptFrames) do
		frame:Hide();
	end

	-- Attempt to re-use frames that we have previously generated.
	for _, promptedBinding in ipairs(promptedBindings) do
		local template = promptedBinding:GetInputIconTemplate();
		local keys = promptedBinding.customDisplayKey and {promptedBinding.customDisplayKey} or promptedBinding.keys;
		local label = promptedBinding.labelFunction and promptedBinding.labelFunction() or promptedBinding.label;
		local showEnabled = promptedBinding:AreConditionsMet();
		local divider = GAMEPAD_PROMPT_DIVIDER_SLASH;

		local promptFrame = self:GetOrCreatePromptFrameUsingTemplateAndInputs(template.name, keys, divider);
		promptFrame:SetPromptText(label);

		if showEnabled then
			promptFrame:EnablePrompt();
		else
			promptFrame:DisablePrompt();
		end

		promptFrame:Show();
	end

	self:ApplyDefaultPromptPositioning();
end

--[[
	Creates a new prompt frame or grabs an existing one based on the input the prompt is displaying.

	templateName - The name of the template that the prompt frame should use. See InputPromptLegends.PromptTemplates
				   for supported templates.

	inputKeys - A table containing the inputs, in order, to be assigned to the prompt's icons.

	dividerType - The type of divider to be used in the template, if applicable.
]]
function InputPromptLegendMixin:GetOrCreatePromptFrameUsingTemplateAndInputs(templateName, inputKeys, dividerType)
	-- Format the key for the prompt that is associated with this template, inputKey, and divider combo
	local promptKey = templateName;
	for _, value in ipairs(inputKeys) do
		promptKey = promptKey .. value;
	end

	if (dividerType) then
		promptKey = promptKey .. dividerType;
	end

	-- Using the formatted key, get the associated prompt frame if one exists.
	local promptFrame = self.promptFrames[promptKey];
	if (promptFrame) then
		-- A prompt using the specified template and specific inputs (and divider) already exists
		return promptFrame;
	end

	-- Create a new prompt using the provided template, and store it with the formatted key in the legend's promptFrames table.
	promptFrame = CreateFrame("Frame", nil, self.promptContainerFrame, SupportedPromptTemplates[templateName].template);
	self.promptFrames[promptKey] = promptFrame;
	table.insert(self.promptFramesAddOrder, promptKey);

	-- Apply prompt customization based on the input and divider types passed in.
	promptFrame:SetPoint("TOPLEFT", 0, 0);

	for index, value in ipairs(inputKeys) do
		promptFrame:SetPromptInputIconKey(index, value);
	end

	if (dividerType) then
		promptFrame:SetDividerType(dividerType);
	end

	promptFrame.template = templateName;

	-- Return the newly created prompt frame.
	return promptFrame;
end

--[[
	Creates the input prompts displayed in the legend based on the added frame actions.
	The current implementation intention is that a legend has added all the frame actions the legend will
	display and then this function is called just once for the legend. There is currently no logic that
	supports refreshing the legend by adding/removing prompts.

	After the prompt frames have been created the default positioning algorithm will adjust the positions of the prompt frames.
]]
function InputPromptLegendMixin:InitializePrompts()
	for _, actionTable in ipairs(self.actions) do
		if (actionTable.isFrameAction) then
			local frameAction = actionTable.action;
			local promptFrame = self:GetOrCreatePromptFrameUsingTemplateAndInputs(frameAction.template.name, frameAction.inputKeys, frameAction.divider);
			self.promptMap[frameAction.promptID] = promptFrame;
			promptFrame:SetPromptText(frameAction.text);

			--[[
				If this is the first frame action associated with this input prompt its
				initialization settings will be used to initialize the frame action data
				and set the initial style and text for the prompt.

				Additional frame actions that use this prompt can be switched to using the
				ChangePromptTextToFrameAction function, but the prompt data enabled and active
				settings will remain the same unless changed by calling other functions such as
				SetFrameActionPromptEnabled or SetFrameActionPromptActiveByID.
			]]
			if (not promptFrame.frameActionData) then
				promptFrame.frameActionData =
				{
					isEnabled = true,
					isActive = not frameAction.initializePromptAsInactive,
					frameActionDisplayedByPrompt = frameAction.promptID,
					promptTextMap = {};
				}

				-- Frame actions are enabled by default
				if (frameAction.initializePromptAsInactive) then
					promptFrame:ApplyInactiveEnabledPromptStyling();
				else
					promptFrame:EnablePrompt();
				end
			end

			--[[
				Store the text in the prompt text map for this frame action. This provides
				the ability to reference the frame action text by promptID later.
			]]
			promptFrame.frameActionData.promptTextMap[frameAction.promptID] = frameAction.text;
		end
	end

	--[[
		Loop through the created prompts and update the text of the prompt to the first frame action that was added using
		that input.
	]]
	for _, promptFrame in pairs(self.promptMap) do
		if (promptFrame.frameActionData) then
			local frameActionPromptDisplayedText = self:GetDisplayedFrameActionText(promptFrame.frameActionData);
			promptFrame:SetPromptText(frameActionPromptDisplayedText);
		end
	end

	self:ApplyDefaultPromptPositioning();
end

function InputPromptLegendMixin:ChangePromptTextToFrameAction(frameActionID)
	local promptFrame = self.promptMap[frameActionID];
	if (promptFrame and promptFrame.frameActionData) then
		promptFrame.frameActionData.frameActionDisplayedByPrompt = frameActionID;
		local newPromptTextToDisplay = self:GetDisplayedFrameActionText(promptFrame.frameActionData);
		promptFrame:SetPromptText(newPromptTextToDisplay);
	end
end

--[[
	Sets the desired width of the input legend. When the width is set
	the legend will no longer use the single-line layout but will instead
	wrap the prompts around the specified width.

	legendWidth - The total width of the legend (including the modifier section if added).
]]
function InputPromptLegendMixin:SetLegendWidth(legendWidth)
	-- Add width validation checks
	self.wrapAroundRowWidth = true;
	self:SetWidth(legendWidth);
end

--[[
	Adds a modifier section to the left of the prompt container group on the input legend.
	The width of the modifier section is included in the wrapping calculations in the default
	positioning function.

	Currently the modifier is always LB+, but the function could be expanded to take in
	a set of input keys and a prompt template.
]]
function InputPromptLegendMixin:AddModifierSection()
	local modifierFrame = CreateFrame("Frame", nil, self);
	self.modifierFrame = modifierFrame;
	modifierFrame:SetPoint("TOPLEFT", self, "TOPLEFT");

	-- Add the background.
	modifierFrame.backgroundSlot = modifierFrame:CreateTexture();
	modifierFrame.backgroundSlot:SetAllPoints();
	modifierFrame.backgroundSlot:SetAtlas(LEGEND_BACKGROUND_SLOT_ATLAS, true);
	modifierFrame.backgroundSlot:SetAlpha(1);
	modifierFrame.backgroundBorder = modifierFrame:CreateTexture();
	modifierFrame.backgroundBorder:SetAllPoints();
	modifierFrame.backgroundBorder:SetAtlas(LEGEND_BACKGROUND_BORDER_FOCUSED_STYLE_ATLAS, true);
	modifierFrame:SetFrameLevel(MODIFIER_FOCUSED_FRAME_LEVEL);

	self.promptContainerFrame.backgroundBorder:SetAlpha(1);

	-- Add the modifier prompt.
	local modPrompt = CreateFrame("Frame", nil, modifierFrame, "InputPromptOneIconTemplate");
	modPrompt:SetPoint("LEFT", modifierFrame, "LEFT", LEGEND_BACKGROUND_PADDING, 0);
	modPrompt:SetPromptInputIconKey(1, GAMEPAD_SHOULDER_LEFT);
	modifierFrame.arrowTexture = modPrompt:CreateTexture(nil, "ARTWORK");
	modifierFrame.arrowTexture:SetAtlas(MODIFIER_ARROW_ATLAS);
	modifierFrame.arrowTexture:SetSize(MODIFIER_ARROW_WIDTH, MODIFIER_ARROW_HEIGHT);
	modifierFrame.arrowTexture:SetPoint("LEFT", modPrompt, "RIGHT", MODIFIER_ARROW_LEFT_PADDING, 0);
	modifierFrame.arrowTexture:SetRotation(MODIFIER_ARROW_ROTATION);

	-- Update the width of the modifier section to surround the modifier prompt.
	local modFrameWidth = (2 * LEGEND_BACKGROUND_PADDING) + modPrompt:GetWidth() + modifierFrame.arrowTexture:GetWidth() + MODIFIER_ARROW_LEFT_PADDING;
	modifierFrame:SetWidth(modFrameWidth);

	-- When the modifier is added, the prompt container frame needs to now depend on it
	self.promptContainerFrame:SetPoint("TOPLEFT", modifierFrame, "TOPRIGHT", BORDER_MERGE_OFFSEET, 0);
end

function InputPromptLegendMixin:SetFrameActionPromptEnabled(frameActionID, enabled)
	local frameActionPrompt = self.promptMap[frameActionID];
	if (frameActionPrompt and frameActionPrompt.frameActionData) then
		frameActionPrompt.frameActionData.isEnabled = enabled;
		if (enabled) then
			if (not frameActionPrompt.frameActionData.isActive) then
				frameActionPrompt:ApplyInactiveEnabledPromptStyling();
			else
				frameActionPrompt:EnablePrompt();
			end
		else
			frameActionPrompt:DisablePrompt();
		end
	end
end

--[[
	Using a frame action ID, the prompt associated with the frame action will have the
	isActive flag in the frame action data updated to true or false depending on the
	activeState value.

	frameActionID - The id of the frame action that is used to get the linked prompt frame.

	activeState - Boolean indicating if the linked prompt should be marked as active (true) or inactive (false).
]]
function InputPromptLegendMixin:SetFrameActionPromptActiveByID(frameActionID, activeState)
	local frameActionPrompt = self.promptMap[frameActionID];
	if (frameActionPrompt and frameActionPrompt.frameActionData) then
		frameActionPrompt.frameActionData.isActive = activeState;
		self:SetFrameActionPromptEnabled(frameActionID, frameActionPrompt.frameActionData.isEnabled);
	end
end

--[[
	Using the frames generated by the InputPromptLegendMixin:InitializePrompts function, this function
	applies formatting that either places the prompts in a horizontal line or wraps around the legend
	width if one is specified using the SetLegendWidth function.
]]
function InputPromptLegendMixin:ApplyDefaultPromptPositioning()
	local ICON_SIZE = 24; -- The height and width of an icon appearing in a legend prompt
	local STANDARD_PROMPT_PADDING = 15;
	local STANDARD_PROMPT_BETWEEN_ROW_PADDING = 11;
	local NEW_ROW_HEIGHT_OFFSET = -(ICON_SIZE + STANDARD_PROMPT_BETWEEN_ROW_PADDING);

	local promptContainerWidthUsed = 0;
	local promptContainerWidth = self:GetWidth();
	if (self.modifierFrame) then
		promptContainerWidth = promptContainerWidth - self.modifierFrame:GetWidth() - BORDER_MERGE_OFFSEET;
	end
	self.promptContainerFrame:SetWidth(promptContainerWidth);
	local rowHeightOffset = -LEGEND_BACKGROUND_PADDING;

	for index, value in ipairs(self.promptFramesAddOrder) do
		local promptFrame = self.promptFrames[value];

		if promptFrame:IsShown() then
			if (index == 1) then
				-- Position the prompt so that the whole prompt is inside of the container bounds instead of sticking out slightly
				promptFrame:SetPoint("TOPLEFT", self.promptContainerFrame, LEGEND_BACKGROUND_PADDING, rowHeightOffset);

				-- Update the amount of space we have used in the row
				promptContainerWidthUsed = LEGEND_BACKGROUND_PADDING + promptFrame:GetWidth() + STANDARD_PROMPT_PADDING;
			else
				local promptWidth = promptFrame:GetWidth();

				-- Does the prompt need to go into a new row?
				if (self.wrapAroundRowWidth and (promptContainerWidthUsed + promptWidth + LEGEND_BACKGROUND_PADDING > promptContainerWidth)) then
					rowHeightOffset = rowHeightOffset + NEW_ROW_HEIGHT_OFFSET;
					promptFrame:SetPoint("TOPLEFT", self.promptContainerFrame, LEGEND_BACKGROUND_PADDING, rowHeightOffset);
					promptContainerWidthUsed = LEGEND_BACKGROUND_PADDING + promptWidth + STANDARD_PROMPT_PADDING;
				else
					promptFrame:SetPoint("TOPLEFT", self.promptContainerFrame, promptContainerWidthUsed, rowHeightOffset);
					promptContainerWidthUsed = promptContainerWidthUsed + promptWidth + STANDARD_PROMPT_PADDING;
				end
			end
		end
	end

	if (not self.wrapAroundRowWidth) then
		local containerWidth = promptContainerWidthUsed - STANDARD_PROMPT_PADDING + LEGEND_BACKGROUND_PADDING;
		self.promptContainerFrame:SetWidth(containerWidth);
		if (self.modifierFrame) then
			local modifierWidth = self.modifierFrame:GetWidth();
			self:SetWidth(containerWidth + modifierWidth);
		else
			self:SetWidth(containerWidth);
		end
	end

	local legendHeight = -rowHeightOffset + ICON_SIZE + LEGEND_BACKGROUND_PADDING;
	self:SetHeight(legendHeight);
	self.promptContainerFrame:SetHeight(legendHeight);
	if (self.modifierFrame) then
		self.modifierFrame:SetHeight(legendHeight);
	end
end

function InputPromptLegendMixin:GetDisplayedFrameActionText(promptFrameActionData)
	return promptFrameActionData.promptTextMap[promptFrameActionData.frameActionDisplayedByPrompt];
end

function InputPromptLegendMixin:ApplyFocusedStyleToModifierSection()
	if (not self.modifierFrame) then
		return;
	end

	self.modifierFrame.backgroundBorder:SetAtlas(LEGEND_BACKGROUND_BORDER_FOCUSED_STYLE_ATLAS, true);
	self.modifierFrame:SetFrameLevel(MODIFIER_FOCUSED_FRAME_LEVEL);
	self.modifierFrame.arrowTexture:SetTexCoord(0, 1, 0, 1);
	self.modifierFrame.arrowTexture:SetAlpha(MODIFIER_ARROW_FOCUSED_ALPHA);
end

function InputPromptLegendMixin:ApplyEnabledStyleToModifierSection()
	if (not self.modifierFrame) then
		return;
	end

	self.modifierFrame.backgroundBorder:SetAtlas(LEGEND_BACKGROUND_BORDER_ENABLED_STYLE_ATLAS, true);
	self.modifierFrame:SetFrameLevel(MODIFIER_ENABLED_FRAME_LEVEL);
	self.modifierFrame.arrowTexture:SetTexCoord(0, 1, 1, 0);
	self.modifierFrame.arrowTexture:SetAlpha(MODIFIER_ARROW_ENABLED_ALPHA);
end

function InputPromptLegendMixin:ApplyFocusedStyleToPromptContainer()
	self.promptContainerFrame.backgroundBorder:SetAtlas(LEGEND_BACKGROUND_BORDER_FOCUSED_STYLE_ATLAS, true);
	self.promptContainerFrame:SetFrameLevel(PROMPT_CONTAINER_FOCUSED_FRAME_LEVEL);
end

function InputPromptLegendMixin:ApplyNeutralStyleToPromptContainer()
	self.promptContainerFrame.backgroundBorder:SetAtlas(LEGEND_BACKGROUND_BORDER_NEUTRAL_STYLE_ATLAS, true);
	self.promptContainerFrame:SetFrameLevel(PROMPT_CONTAINER_NEUTRAL_FRAME_LEVEL);
end

function InputPromptLegendMixin:OnBackgroundAlphaChanged()
	self.promptContainerFrame.backgroundSlot:SetAlpha(1);
	self.promptContainerFrame.backgroundBorder:SetAlpha(1);

	if (self.modifierFrame) then
		self.modifierFrame.backgroundSlot:SetAlpha(1);

		--[[
			If the legend has a modifier section the prompt container must have
			a visible border to help indicate that the prompts are connected with
			the modifier button and can be accessed if it is pressed.
		]]
		self.promptContainerFrame.backgroundBorder:SetAlpha(1);
	end
end

--[[
	This table contains resuable non-specific frame actions that are reused across multiple different
	input legends so we don't need to create duplicates across the various files that use input legends.
]]
InputPromptLegends.CommonReusableFrameActions =
{
	PAD2_EXIT = InputPromptLegends.CreateFrameAction("Exit", InputPromptLegends.PromptTemplates.StandardOneIcon, { GAMEPAD_FACE_RIGHT }, FRAME_ACTION_EXIT),
	PAD2_CLOSE = InputPromptLegends.CreateFrameAction("Close", InputPromptLegends.PromptTemplates.StandardOneIcon, { GAMEPAD_FACE_RIGHT }, FRAME_ACTION_CLOSE),
	PAD2_BACK = InputPromptLegends.CreateFrameAction("Back", InputPromptLegends.PromptTemplates.StandardOneIcon, { GAMEPAD_FACE_RIGHT }, FRAME_ACTION_BACK),
	PAD2_CANCEL = InputPromptLegends.CreateFrameAction("Cancel", InputPromptLegends.PromptTemplates.StandardOneIcon, { GAMEPAD_FACE_RIGHT }, FRAME_ACTION_CANCEL),
	PADBACK_BLANK = InputPromptLegends.CreateFrameAction("Focus", InputPromptLegends.PromptTemplates.StandardOneIcon, { GAMEPAD_MENU_LEFT }, ""),
	TRIGGERS_ROTATE_CHARACTER = InputPromptLegends.CreateFrameAction("RotateCharacter", InputPromptLegends.PromptTemplates.StandardTwoIcon, { GAMEPAD_TRIGGER_LEFT, GAMEPAD_TRIGGER_RIGHT }, FRAME_ACTION_ROTATE_CHARACTER);
}
