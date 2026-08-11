
-- Narration Edit Box
--
-- Provides reusable mixins for adding narration to edit boxes.

local function GetLabelText(self)
	if self.narrationLabel then
		return self.narrationLabel;
	end

	if self.narrationLabelRegion then
		local text = self.narrationLabelRegion:GetText();
		if text and text ~= "" then
			return text;
		end
	end

	if self.Label then
		local text = self.Label:GetText();
		if text and text ~= "" then
			return text;
		end
	end

	return nil;
end

local function GetInstructionText(self)
	if self.Instructions then
		local text = self.Instructions:GetText();
		if text and text ~= "" then
			return text;
		end
	end

	return self.instructionText;
end

local function GetCurrentText(self)
	if self.narrationHideText then
		local text = self:GetText();
		if text and text ~= "" then
			return NARRATION_STATUS_HIDDEN;
		end

		return nil;
	end

	local text = self:GetText();
	if text and text ~= "" then
		return text;
	end

	return nil;
end

---------------------------------------------------------------------------
-- NarrationEditBoxMixin
--
-- For standard input boxes.
-- Narrates as: <label>, Edit Field, <current text>
--
-- Configurable key-values:
--		narrationLabel (string or global) - Explicit name override.
--		narrationLabelRegion (region) - A FontString whose text is used as the label.
--		narrationHideText (boolean) - Reports "Hidden" instead of actual text.
---------------------------------------------------------------------------

NarrationEditBoxMixin = {};

function NarrationEditBoxMixin:SetNarrationLabelRegion(region)
	self.narrationLabelRegion = region;
end

function NarrationEditBoxMixin:NarrationGetName()
	return GetLabelText(self) or GetInstructionText(self);
end

function NarrationEditBoxMixin:NarrationGetContext()
	if not self:IsEnabled() then
		return NARRATION_STATUS_DISABLED_FORMAT:format(NARRATION_OBJECT_EDIT_FIELD);
	end

	return NARRATION_OBJECT_EDIT_FIELD;
end

function NarrationEditBoxMixin:NarrationGetDescription()
	return GetCurrentText(self);
end

---------------------------------------------------------------------------
-- NarrationSearchBoxMixin
--
-- For search and filter fields. Supports two modes:
--
-- Labeled mode (has narrationLabel or Label):
--		<label>, Search Field, <current text>
--
-- Unlabeled mode (default for search templates):
--		<current text or instructions>, Search Field
--
-- Configurable key-values:
--		narrationLabel (string or global) - Explicit name; enables labeled mode.
--		narrationHideText (boolean) - Reports "Hidden" instead of actual text.
---------------------------------------------------------------------------

-- Fully overrides all Narration* methods from NarrationEditBoxMixin, which may be
-- applied via the InputBoxScriptTemplate inheritance chain.
NarrationSearchBoxMixin = {};

function NarrationSearchBoxMixin:NarrationGetName()
	local label = GetLabelText(self);
	if label then
		return label;
	end

	return GetCurrentText(self) or GetInstructionText(self);
end

function NarrationSearchBoxMixin:NarrationGetContext()
	if not self:IsEnabled() then
		return NARRATION_STATUS_DISABLED_FORMAT:format(NARRATION_OBJECT_SEARCH_FIELD);
	end

	return NARRATION_OBJECT_SEARCH_FIELD;
end

function NarrationSearchBoxMixin:NarrationGetDescription()
	-- If we have a label, that will be returned as the name and the current text
	-- or instructions should be the description.
	local label = GetLabelText(self);
	if label then
		return GetCurrentText(self) or GetInstructionText(self);
	end

	return nil;
end
