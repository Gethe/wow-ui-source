local _addonName, addonTable = ...;

AuraButtonBorderStyle =
{
	Atlas = 0,
	Color = 1,
};

AuraContainerAuraDataType =
{
	Aura = 0,
	ItemEnchantment = 1,
};

AuraContainerItemEnchantmentSlot =
{
	MainHand = 0,
	OffHand = 1,
	Ranged = 2,
};

AuraContainerItemEnchantmentSortOrder =
{
	[AuraContainerItemEnchantmentSlot.MainHand] = 1,
	[AuraContainerItemEnchantmentSlot.OffHand] = 2,
	[AuraContainerItemEnchantmentSlot.Ranged] = 3,
};

AuraContainerItemEnchantmentToInventorySlot =
{
	[AuraContainerItemEnchantmentSlot.MainHand] = assertsafe(INVSLOT_MAINHAND, "Inventory constants not found; AuraContainer TOC dependencies may need updating."),
	[AuraContainerItemEnchantmentSlot.OffHand] = INVSLOT_OFFHAND,
	[AuraContainerItemEnchantmentSlot.Ranged] = INVSLOT_RANGED,
};

AuraContainerItemEnchantmentSortMethod =
{
	-- Sort by internal enchantment slot ordering.
	Slot = 0,

	-- Sort by remaining duration. Permanent enchantments sort last in normal
	-- direction and first in reverse direction.
	Duration = 1,
};

AuraContainerSortMethod =
{
	Default = 0,
	BigDefensive = 1,
	UnitFrameDebuff = 2,
	ImportantOnly = 3,
	Expiration = 4,
	ExpirationOnly = 5,
	Name = 6,
	NameOnly = 7,
};

AuraContainerSortDirection =
{
	Normal = 0,
	Reverse = 1,
};

AuraContainerFrameRefreshResult =
{
	None = 0,

	-- If set, indicates that aura frames have been acquired, released, or
	-- have had their layout index changed in this refresh. Containers should
	-- respond to this by performing re-anchoring work.
	FrameAssignmentsChanged = bit.lshift(1, 0),

	-- If set, indicates that this group has transitioned between having zero
	-- and one acquired frames (in either direction). Containers may respond
	-- to this by collapsing groups in layout.
	VisibilityChanged = bit.lshift(1, 1),
};

do
	local DefaultAuraDurationFormatter = C_StringUtil.CreateSecondsFormatter();
	addonTable.DefaultAuraDurationFormatter = DefaultAuraDurationFormatter;

	-- This curve is set up to format durations with an inflated bound on
	-- interval brackets, such that values <= 90 seconds render as seconds
	-- values (eg. '90 s'). The '+1' on the curve points is to because
	-- curves promote to the next interval on exact matches, and we want 90
	-- to render as '90 s' and not '1 m'.
	local maxIntervalSecondsMultiplier = 1.5;
	local maxIntervalCurve = C_CurveUtil.CreateCurve();
	maxIntervalCurve:AddPoint(1 + (maxIntervalSecondsMultiplier * SECONDS_PER_MIN), Enum.SecondsFormatterInterval.Minutes);
	maxIntervalCurve:AddPoint(1 + (maxIntervalSecondsMultiplier * SECONDS_PER_HOUR), Enum.SecondsFormatterInterval.Hours);
	maxIntervalCurve:AddPoint(1 + (maxIntervalSecondsMultiplier * SECONDS_PER_DAY), Enum.SecondsFormatterInterval.Days);

	DefaultAuraDurationFormatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter);
	DefaultAuraDurationFormatter:SetMinInterval(Enum.SecondsFormatterInterval.Seconds);
	DefaultAuraDurationFormatter:SetMaxIntervalCurve(maxIntervalCurve);
	DefaultAuraDurationFormatter:SetDesiredUnitCount(1);
end

CustomAuraContainerConstants =
{
	-- Number of frames to allocate in our batched allocator. Must be sufficiently
	-- high to obfuscate the number of auras as this invokes initialization callbacks.
	FrameCreationBatchSize = 10;

	-- Access restrictions to be applied post-creation of new aura frames.
	AccessRestrictionFlags = Enum.ScriptObjectAccessRestriction.DenyTaintedAccessWhenAurasAreSecret;
};

-- Default container-level layout settings for the shared flow layout pass.
-- These describe where layout starts, how it grows, and the padding/row width
-- applied around all dynamic aura filter groups.
CustomAuraContainerLayoutDefaults =
{
	anchorPoint = "TOPLEFT",

	horizontalGrowthDirection = AnchorUtil.FlowDirection.Right,
	verticalGrowthDirection = AnchorUtil.FlowDirection.Down,

	paddingLeft = 0,
	paddingRight = 0,
	paddingTop = 0,
	paddingBottom = 0,

	rowWidth = math.huge,
};

CustomAuraContainerGroupDefaultOptions =
{
	-- Maximum number of aura frames this filter group may display.
	maxFrameCount = math.huge;

	-- Additional templates inherited by frames created for this filter group.
	-- CustomAuraButtonTemplate is always inherited first.
	templateNames = nil;

	-- Optional callback invoked after each frame is created.
	initializeFrame = nil;

	-- Optional candidate filters applied after the aura filter string.
	candidateFilters = nil;

	-- Sort method used to order auras accepted by this filter group.
	sortMethod = AuraContainerSortMethod.Default;

	-- Sort direction applied to the selected sort method.
	sortDirection = AuraContainerSortDirection.Normal;

	-- Optional flow layout settings for this filter group's visible frames.
	layout = nil;
};

-- Default per-filter layout settings for a group's contribution to the shared
-- flow layout. These control spacing, gaps, row breaks, and optional element
-- size overrides for that filter's visible frames.
CustomAuraContainerGroupLayoutDefaultOptions =
{
	elementSpacingX = 0;
	elementSpacingY = 0;
	gapX = 0;
	gapY = 0;
	forceNewRow = false;
	elementWidth = nil;
	elementHeight = nil;
};

-- Default options for aura slot displays. An aura slot renders a single aura
-- at the front of a priority list. They do not take part in dynamic layout
-- and must be manually anchored.
--
-- This can be used to replicate "big defensive" style displays, dispel
-- type indicators, or indicators for specific spells by ID.
CustomAuraContainerSlotDefaultOptions =
{
	-- Additional templates inherited by the slot frame after CustomAuraButtonTemplate.
	templateNames = nil;

	-- Optional callback invoked after the slot frame is created.
	initializeFrame = nil;

	-- Optional candidate filters applied after the aura filter string.
	candidateFilters = nil;

	-- Sort method used to choose the preferred aura for this slot.
	sortMethod = AuraContainerSortMethod.Default;

	-- Sort direction applied to the selected sort method.
	sortDirection = AuraContainerSortDirection.Normal;
};

CustomAuraContainerAuraProcessingPolicy =
{
	-- Do not add container-specific aura processing metadata.
	None = 0,

	-- Store AuraUtil.ProcessAura's classification result on aura data before
	-- candidate filters are evaluated.
	ProcessAura = 1,
};

CustomAuraContainerProcessAuraPolicyDefaultOptions =
{
	-- If true, suppresses helpful aura classification.
	ignoreBuffs = false;
	-- If true, suppresses non-dispel debuff classification.
	ignoreDebuffs = false;
	-- If true, suppresses dispellable raid debuff classification.
	ignoreDispelDebuffs = false;
	-- If true, narrows debuff classification to the dispellable-only paths used
	-- by AuraUtil.ProcessAura.
	displayOnlyDispellableDebuffs = false;
};

CustomAuraContainerItemEnchantmentPlacement =
{
	-- Place item enchantment frames before aura groups in flow layout.
	BeforeAuraGroups = 0,

	-- Place item enchantment frames after aura groups in flow layout.
	AfterAuraGroups = 1,
};

CustomAuraContainerItemEnchantmentLayoutDefaultOptions =
{
	-- Where item enchantment frames are inserted relative to aura groups.
	placement = CustomAuraContainerItemEnchantmentPlacement.BeforeAuraGroups;

	elementSpacingX = 0;
	elementSpacingY = 0;
	gapX = 0;
	gapY = 0;
	forceNewRow = false;
	elementWidth = nil;
	elementHeight = nil;
};

CustomAuraContainerItemEnchantmentDefaultOptions =
{
	-- Additional templates inherited by the frame after CustomAuraButtonTemplate.
	templateNames = nil;

	-- Optional callback invoked after the frame is created.
	initializeFrame = nil;

	-- If true, enchantments without expiration times are treated as inactive.
	hidePermanent = false;
};

------------------------------------------------------------------------------
-- Re-export anything that should be shared between environments here. Tables
-- should be copied.

local _G = GetGlobalEnvironment();

_G.AuraButtonBorderStyle = securecopy(AuraButtonBorderStyle);
_G.AuraContainerAuraDataType = securecopy(AuraContainerAuraDataType);
_G.AuraContainerFrameRefreshResult = securecopy(AuraContainerFrameRefreshResult);
_G.AuraContainerItemEnchantmentSlot = securecopy(AuraContainerItemEnchantmentSlot);
_G.AuraContainerItemEnchantmentToInventorySlot = securecopy(AuraContainerItemEnchantmentToInventorySlot);
_G.AuraContainerItemEnchantmentSortMethod = securecopy(AuraContainerItemEnchantmentSortMethod);
_G.AuraContainerItemEnchantmentSortOrder = securecopy(AuraContainerItemEnchantmentSortOrder);
_G.AuraContainerSortMethod = securecopy(AuraContainerSortMethod);
_G.AuraContainerSortDirection = securecopy(AuraContainerSortDirection);

_G.CustomAuraContainerLayoutDefaults = securecopy(CustomAuraContainerLayoutDefaults);
_G.CustomAuraContainerGroupDefaultOptions = securecopy(CustomAuraContainerGroupDefaultOptions);
_G.CustomAuraContainerGroupLayoutDefaultOptions = securecopy(CustomAuraContainerGroupLayoutDefaultOptions);
_G.CustomAuraContainerSlotDefaultOptions = securecopy(CustomAuraContainerSlotDefaultOptions);
_G.CustomAuraContainerAuraProcessingPolicy = securecopy(CustomAuraContainerAuraProcessingPolicy);
_G.CustomAuraContainerProcessAuraPolicyDefaultOptions = securecopy(CustomAuraContainerProcessAuraPolicyDefaultOptions);
_G.CustomAuraContainerItemEnchantmentPlacement = securecopy(CustomAuraContainerItemEnchantmentPlacement);
_G.CustomAuraContainerItemEnchantmentLayoutDefaultOptions = securecopy(CustomAuraContainerItemEnchantmentLayoutDefaultOptions);
_G.CustomAuraContainerItemEnchantmentDefaultOptions = securecopy(CustomAuraContainerItemEnchantmentDefaultOptions);
