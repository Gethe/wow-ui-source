-- Value used as an initial default height for Damage Meter entry bars.
--
-- This is just used as a consistent dummy value in the absence of any
-- height configuration, eg. before edit mode settings have loaded.
DAMAGE_METER_DEFAULT_BAR_HEIGHT = 25;

-- Edit Mode stores text size in units scaled from 0 to 100 (and higher as
-- we allow oversizing the text). Internally, damage meter converts this to
-- a text scale that we want to represent on a range of 0 to 1.
DAMAGE_METER_TEXT_SIZE_TO_SCALE_MULTIPLIER = 0.01;