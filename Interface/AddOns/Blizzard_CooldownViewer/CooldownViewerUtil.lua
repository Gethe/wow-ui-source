COOLDOWN_VIEWER_CLASS_AND_SPEC_FORMAT = "%s - %s"; -- TODO: Localize

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
