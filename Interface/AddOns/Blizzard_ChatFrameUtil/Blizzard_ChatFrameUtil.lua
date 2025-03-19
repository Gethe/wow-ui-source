-- ChatFrameUtil: Shared functions to be used for formatting/display of text in chat frame(s).

-- Used in UIParent and AuctionHouseFrame to show AH notifications whether or not AH UI is shown
function ChatFrameUtil.GetAuctionHouseNotificationText(auctionHouseNotificationType, formatArg)
	if auctionHouseNotificationType == Enum.AuctionHouseNotification.BidPlaced then
		return ERR_AUCTION_BID_PLACED;
	elseif auctionHouseNotificationType == Enum.AuctionHouseNotification.AuctionRemoved then
		return ERR_AUCTION_REMOVED;
	elseif auctionHouseNotificationType == Enum.AuctionHouseNotification.AuctionWon then
		return ERR_AUCTION_WON_S:format(formatArg);
	elseif auctionHouseNotificationType == Enum.AuctionHouseNotification.AuctionOutbid then
		return ERR_AUCTION_OUTBID_S:format(formatArg);
	elseif auctionHouseNotificationType == Enum.AuctionHouseNotification.AuctionSold then
		return ERR_AUCTION_SOLD_S:format(formatArg);
	elseif auctionHouseNotificationType == Enum.AuctionHouseNotification.AuctionExpired then
		return ERR_AUCTION_EXPIRED_S:format(formatArg);
	end

	return "";
end