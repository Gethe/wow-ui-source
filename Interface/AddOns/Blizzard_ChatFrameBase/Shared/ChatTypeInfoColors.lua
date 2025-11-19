-- Initialize all chat types with placeholder default colors. These are
-- replaced when chat settings load later.
--
-- This needs to be performed before ChatFrameEditBoxTemplate is instantiated
-- as there are a few code paths that trigger an :UpdateHeader() call on
-- the editbox which is reliant upon these colors being initialized.

for index, value in pairs(ChatTypeInfo) do
	value.r = 1.0;
	value.g = 1.0;
	value.b = 1.0;
	value.id = GetChatTypeIndex(index);
end
