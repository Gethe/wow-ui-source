-- Configuration for money lines appended to tooltips (GameTooltip_AddMoneyLine).
--
-- Produces output compatible with the legacy SetTooltipMoney using the
-- "STATIC" config. Zero values for denominations omitted are omitted, and
-- an input of zero raw copper should produce a blank line in the tooltip.
GameTooltipMoneyFormat = MoneyFormatterUtil.CreateFormatterConfig();
GameTooltipMoneyFormat:SetDisplayMode(MoneyFormatterDisplayMode.Texture);
GameTooltipMoneyFormat:SetZeroDisplayMode(MoneyFormatterZeroDisplayMode.Collapse);
GameTooltipMoneyFormat:SetValueFormatter(MoneyFormatterUtil.BreakUpLargeNumbers);
GameTooltipMoneyFormat:SetZeroDisplayText(" ");
