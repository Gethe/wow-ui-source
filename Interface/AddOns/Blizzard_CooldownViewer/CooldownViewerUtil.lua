COOLDOWN_VIEWER_CLASS_AND_SPEC_FORMAT = "%s - %s"; -- TODO: Localize

local soundCategoryKeyToText =
{
	[Enum.CooldownViewerSoundCategory.Animals] = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_ANIMALS,
	[Enum.CooldownViewerSoundCategory.Devices] = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_DEVICES,
	[Enum.CooldownViewerSoundCategory.Impacts] = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_IMPACTS,
	[Enum.CooldownViewerSoundCategory.Instruments] = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_INSTRUMENTS,
	[Enum.CooldownViewerSoundCategory.Short] = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_SHORT,
	[Enum.CooldownViewerSoundCategory.War2] = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_WAR2,
	[Enum.CooldownViewerSoundCategory.War3] = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_WAR3,
}

local function MakeClassAndSpecTag(class, spec)
	assertsafe(spec < 10, "MakeClassAndSpecTag can only use one digit for encoding spec");
	return class * 10 + spec;
end

local function GetClassAndSpecFromTag(classAndSpecTag)
	local tag = tonumber(classAndSpecTag);
	assertsafe(classAndSpecTag ~= nil and classAndSpecTag > 0, "GetClassAndSpecFromTag passed invalid tag [%s]", tostring(classAndSpecTag));
	local classID = math.floor(tag / 10);
	local spec = tag % 10;
	return classID, spec;
end

local function GetCurrentClassAndSpec()
	local classID = select(3, UnitClass("player"));
	local specialization = C_SpecializationInfo.GetSpecialization();

	return classID, specialization;
end

local soundTypeToTextMapping;
local soundTypeToSoundKitMapping;
local function CreateSoundTypeMapping(currentTable)
	for key, value in ipairs (currentTable) do
		if value.soundEnum and value.text and value.soundKitID then
			soundTypeToTextMapping[value.soundEnum] = value.text;
			soundTypeToSoundKitMapping[value.soundEnum] = value.soundKitID;
		elseif type(value) == "table" then
			CreateSoundTypeMapping(value);
		end
	end
end

local function CheckCreateSoundAlertData()
	if not soundTypeToTextMapping then
		soundTypeToTextMapping = {};
		soundTypeToSoundKitMapping = {};
		CreateSoundTypeMapping(CooldownViewerSoundData);
	end
end

CooldownViewerUtil = {};

function CooldownViewerUtil.GetCurrentClassAndSpecTag()
	local classID, specialization = GetCurrentClassAndSpec();

	if classID and specialization then
		return MakeClassAndSpecTag(classID, specialization);
	end

	return nil;
end

function CooldownViewerUtil.GetClassAndSpecTagText(classAndSpecTag)
	local classID, specIndex = GetClassAndSpecFromTag(classAndSpecTag);

	if classID and specIndex then
		local className = GetClassInfo(classID);
		local isInspect, isPet, inspectTarget, gender, groupIndex = false, false, nil, nil, nil;
		local specName = select(2, C_SpecializationInfo.GetSpecializationInfo(specIndex, isInspect, isPet, inspectTarget, gender, groupIndex, classID));

		if className and specName then
			return COOLDOWN_VIEWER_CLASS_AND_SPEC_FORMAT:format(className, specName);
		end
	end

	return nil;
end

function CooldownViewerUtil.IsDisabledCategory(category)
	return category == Enum.CooldownViewerCategory.HiddenSpell or category == Enum.CooldownViewerCategory.HiddenAura;
end

function CooldownViewerUtil.AddSoundAlertRadio(alertData, createRadioCallback, isSelected, setSelected, useHighlightStyle)
	local alertButton = createRadioCallback(alertData.text, isSelected, setSelected, alertData.soundEnum);

	alertButton:AddInitializer(function(button, _description, _menu)
		local playSampleButton = MenuTemplates.AttachUtilityButton(button);
		playSampleButton.Texture:Hide();
		CooldownViewerAlert_SetupTypeButton(playSampleButton, Enum.CooldownViewerAlertType.Sound);

		local offsetX = useHighlightStyle and -5 or 0;
		local offsetY = 0;
		MenuTemplates.SetUtilityButtonAnchor(playSampleButton, MenuVariants.GearButtonAnchor, button, offsetX, offsetY); -- gear means throw on the right
		MenuTemplates.SetUtilityButtonTooltipText(playSampleButton, COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_PLAY_SAMPLE);
		MenuTemplates.SetUtilityButtonClickHandler(playSampleButton, function()
			local alert = CooldownViewerAlert_Create(Enum.CooldownViewerAlertType.Sound, Enum.CooldownViewerAlertEventType.Available, alertData.soundEnum);
			local cooldownItem = nil;
			local soundSubType = useHighlightStyle and "Voice" or "Gameplay SFX";
			-- spellName will only be present for TTS cases.
			CooldownViewerAlert_PlayAlert(cooldownItem, alertData.spellName, alert, soundSubType);
		end);

		if button.Layout then
			button:Layout();
		end
	end);
end

-- Both cooldown viewer and settings use sound alerts in dropdowns and use these to build that up, need to do slight differences depending on useHighlightStyle (settings).
function CooldownViewerUtil.BuildSoundMenus(baseDescription, isSelectedCallback, setSelectCallback, useHighlightStyle)
	local function BuildMenu(description, currentTable)
		local CreateButton = useHighlightStyle and GenerateClosure(description.CreateHighlightButton, description) or GenerateClosure(description.CreateButton, description);
		local CreateRadio = useHighlightStyle and GenerateClosure(description.CreateHighlightRadio, description) or GenerateClosure(description.CreateRadio, description);
		for key, value in ipairs(currentTable) do
			if value.soundEnum and value.text then
				CooldownViewerUtil.AddSoundAlertRadio(value, CreateRadio, isSelectedCallback, setSelectCallback, useHighlightStyle);
			elseif type(value) == "table" then
				local nestedDescription = CreateButton(soundCategoryKeyToText[key], nop, -1);
				BuildMenu(nestedDescription, value);
			end
		end
	end

	BuildMenu(baseDescription, CooldownViewerSoundData);
end

function CooldownViewerUtil.GetSoundTypeText(soundEnum)
	CheckCreateSoundAlertData();
	return soundTypeToTextMapping[soundEnum];
end

function CooldownViewerUtil.GetSoundTypeSoundKit(soundEnum)
	CheckCreateSoundAlertData();
	return soundTypeToSoundKitMapping[soundEnum];
end