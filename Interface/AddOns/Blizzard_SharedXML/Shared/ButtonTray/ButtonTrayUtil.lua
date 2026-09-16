
ButtonTrayUtil = {};

function ButtonTrayUtil.TestButtonTraySetup(button, label, callback, tooltipText)
	button:SetText(label);
	button:SetWidth(button:GetTextWidth() + 20);
	button.tooltipText = tooltipText;
	button.tooltipDisabled = false;

	local function TalentTestButtonTrayButtonOnClick(scriptButton)
		callback();
	end

	button:SetScript("OnClick", TalentTestButtonTrayButtonOnClick);
end

function ButtonTrayUtil.TestCheckboxTraySetup(button, labelText, callback, customFont, tooltipText)
	button:SetCallback(callback);
	button:SetLabelText(labelText);
	button.Label:SetFontObject(customFont);
	button:SetTooltipText(tooltipText);
	button:SetTooltipDisabled(false);
end


function ButtonTrayUtil.TestDropdownTraySetup(dropdownControl, label, enum, nameTranslation, isSet, setSelected)
	if not label then
		return;
	end

	dropdownControl:SetLabelText(label);
	MenuUtil.CreateEnumRadioMenu(dropdownControl:GetDropdownButton(),
		enum,
		nameTranslation,
		isSet,
		setSelected);
end

function ButtonTrayUtil.TestSliderTraySetup(slider, label, callback, min, max, currentValue, increment)
	slider:SetupSlider(min, max, currentValue, increment, label);
	slider:SetCallback(callback);
end