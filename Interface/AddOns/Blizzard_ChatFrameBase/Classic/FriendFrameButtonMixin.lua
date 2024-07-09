FriendFrameButtonMixin = {};

function FriendFrameButtonMixin:OnLoad()
	local _, numBNetOnline = BNGetNumFriends();
	local numWoWOnline = C_FriendList.GetNumOnlineFriends() or 0;
	FriendsMicroButtonCount:SetText(numBNetOnline + numWoWOnline);
	FriendsMicroButtonCount:SetShadowOffset(1, 1);
end

function FriendFrameButtonMixin:OnClick()
	ToggleFriendsFrame(FRIEND_TAB_FRIENDS);
end

function FriendFrameButtonMixin:OnEnter()
	GameTooltip_AddNewbieTip(self, MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLESOCIAL"), 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_SOCIAL);
end

function FriendFrameButtonMixin:OnLeave()
	GameTooltip:Hide();
end