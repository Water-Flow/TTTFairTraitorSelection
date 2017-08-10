function FairSelection:Message(msg)
	MsgC(Color(84, 13, 165), "[TTTFairSelection] "..msg.."\n")
end

function FairSelection:Error(msg)
	MsgC(Color(84, 13, 165), "[TTTFairSelection] ", Color(179, 15, 15), msg.."\n")
end

function FairSelection:DefaultChance()
	return math.random(1, 5)
end

function FairSelection:GetActivePlayerTotalChance()
	local total = 0

	for _, ply in ipairs(player.GetHumans()) do
		if IsValid(ply) and (ply:GetChance() ~= nil) then
			total = total + ply:GetChance()
		end
	end

	return total
end

function FairSelection:UpdatePlayerChance()
	for _, ply in ipairs(player.GetHumans()) do
		FairSelection.DB:prepare("UPDATE prefix_chances SET chance=?, lastupdate=? WHERE steamid=?", {ply:GetChance(), os.time(), ply:SteamID64()})
	end
end
