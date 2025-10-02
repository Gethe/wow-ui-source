-- These values aren't actually part of the enum
-- They exist so that disabled states can be managed using the same category enums
-- There are checks to ensure that they don't match any of the pre-existing enum values
Enum.CooldownViewerCategory.HiddenSpell = -1;
Enum.CooldownViewerCategory.HiddenAura = -2;

Enum.CDMLayoutMode =
{
	AccessOnly = false,
	AllowCreate = true,
};

-- TODO: Define in tag...or share with editmode?
Enum.CooldownLayoutType =
{
	Character = 1,
	Account = 2,
};

Enum.CooldownLayoutStatus =
{
	Success = 0,
	InvalidLayoutName = 1,
	TooManyLayouts = 2,
	AttemptToModifyDefaultLayoutWouldCreateTooManyLayouts = 3,
	TooManyAlerts = 4,
	InvalidOrderChange = 5,
};

Enum.CooldownLayoutAction =
{
	ChangeOrder = 0,
	ChangeCategory = 1,
	AddLayout = 2,
	AddAlert = 3,
};
