-- Used to determine both the height of the menu and of the buttons. The button width is double the height.
GameModeSelectFixedHeight = 100;

-- Horizontal offset for buttons. In practice, used to overlap the buttons a bit.
GameModeSelectButtonSpacing = -50;

-- Scale of the game logo texture depending on state.
GameModeSelectNormalTextureScale = {
	selected = 0.75,
	deselected = 0.75
};

-- To accommodate promo text under promo button logos, promo buttons scale their logos by this factor.
GameModeSelectPromoButtonTextureScale = 0.82;

-- Scale of the promo text depending on state.
GameModeSelectPromoTextScale = {
	selected = 1,
	deselected = 1
};