
-- A spot for shared widget functionality

WidgetUtil = {};

local function GetReplaceFormatAndCallback(textFormatType)
	if textFormatType == Enum.UIWidgetTextFormatType.TimeOneLevel then
		local function ReplaceWithTimeOneLevel(digits)
			return SecondsToTime(tonumber(digits), false, true, 1, true);
		end

		return "%d+", ReplaceWithTimeOneLevel;
	elseif textFormatType == Enum.UIWidgetTextFormatType.TimeTwoLevel then
		local function ReplaceWithTimeTwoLevel(digits)
			return SecondsToTime(tonumber(digits), false, true, 2, true);
		end

		return "%d+", ReplaceWithTimeTwoLevel;
	elseif textFormatType == Enum.UIWidgetTextFormatType.LeadingZeroesWithSixDigits then
		local function ReplaceWithLeadingZeroes(digits)
			return FormattingUtil.AddLeadingZeroes(tonumber(digits), 6);
		end

		return "%d+", ReplaceWithLeadingZeroes;
	end

	return nil;
end

function WidgetUtil.FormatTextByType(text, textFormatType)
	local replaceFormat, replaceCallback = GetReplaceFormatAndCallback(textFormatType);
	if replaceFormat and replaceCallback then
		return string.gsub(text, replaceFormat, replaceCallback);
	end

	return text;
end

function WidgetUtil.UpdateTextWithAnimation(widget, setTextCallback, updateAnimType, newText)
	if widget.updateAnimCancelCallback then
		widget.updateAnimCancelCallback();
		widget.updateAnimCancelCallback = nil;
	end

	local showNumberAnimation = updateAnimType == Enum.UIWidgetUpdateAnimType.FlashAndAnimateNumber;
	local showFlash = showNumberAnimation or (updateAnimType == Enum.UIWidgetUpdateAnimType.Flash);
	local textChanged = not widget.previousText or (widget.previousText ~= newText);
	if showFlash and textChanged then
		if widget.Flash then
			widget.Flash:Play();
		end
	end

	widget.previousText = newText;
	setTextCallback(newText);

	if showNumberAnimation and textChanged then
		local previousValues = {};

		if widget.previousText then
			local function StorePreviousValue(previousValueText)
				table.insert(previousValues, tonumber(previousValueText));
			end

			string.gsub(widget.previousText, "%d+", StorePreviousValue);
		end

		local function SetTextString(_widgetSelf, elapsedTime, duration)
			local currentIndex = 1;
			local function UpdateValue(valueString)
				local previousValue = previousValues[currentIndex] or 0;
				currentIndex = currentIndex + 1;
				return previousValue + math.ceil((tonumber(valueString) - previousValue) * (elapsedTime / duration));
			end

			local animText = string.gsub(newText, "%d+", UpdateValue);
			widget.previousText = animText;
			setTextCallback(animText);
		end

		local duration = 1;
		widget.updateAnimCancelCallback = ScriptAnimationUtil.StartScriptAnimationGeneric(widget, SetTextString, duration);
	end
end
