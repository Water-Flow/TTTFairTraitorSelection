local meta = FindMetaTable("Player")

function meta:GetChance()
	local chance = self.Chance

	if chance == nil then
		chance = FairSelection:DefaultChance()
	end

	return chance
end

function meta:GetRoundsPlayed()
	return self:GetNWInt("TTTFS_RoundsPlayed")
end

function meta:GetInnocentCount()
	return self:GetNWInt("TTTFS_InnocentCount")
end

function meta:GetDetectiveCount()
	return self:GetNWInt("TTTFS_DetectiveCount")
end

function meta:GetTraitorCount()
	return self:GetNWInt("TTTFS_TraitorCount")
end

function meta:GetTraitorChance()
	if IsValid(self) then
		return math.floor((self:GetChance() / FairSelection:GetActivePlayerTotalChance()) * 100)
	end
end

function meta:SetChance(chance)
	self.Chance = chance
end

function meta:AddChance(chance)
	self.Chance = self:GetChance() + chance
end

function meta:SetRoundsPlayed(count)
	return self:SetNWInt("TTTFS_RoundsPlayed", count)
end

function meta:SetInnocentCount(count)
	return self:SetNWInt("TTTFS_InnocentCount", count)
end

function meta:SetDetectiveCount(count)
	return self:SetNWInt("TTTFS_DetectiveCount", count)
end

function meta:SetTraitorCount(count)
	return self:SetNWInt("TTTFS_TraitorCount", count)
end
