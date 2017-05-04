FairSelection.Version = "1.0.0"

function FairSelection:LoadConfig()
	CONFIG = {}
	CONFIG.DB = {}

	include("fairselection/sv_config.lua")

	FairSelection.CFG = CONFIG
end

function FairSelection:VersionCheck()
	http.Fetch("https://raw.githubusercontent.com/Water-Flow/TTTFairTraitorSelection/release/VERSION", function(body)
		local msg = nil
		local version = "0.0.0"
		version = body
		local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
		local curmajor, curminor, curpatch = FairSelection.Version:match("(%d+)%.(%d+)%.(%d+)")
		
		major = tonumber(major) or 0
		minor = tonumber(minor) or 0
		patch = tonumber(patch) or 0

		curmajor = tonumber(curmajor) or 0
		curminor = tonumber(curminor) or 0
		curpatch = tonumber(curpatch) or 0

		if (curmajor < major) or (curminor < minor) or (curpatch < patch) then
			msg = "A new Version is available (%%%%%%%%)!"
		else
			msg = "Version: (%%%%%%%%)"
		end

		if msg then
			msg = string.gsub(msg, "%%+", version)
			FairSelection:Message(msg)
		end
	end,
	function()
		FairSelection:Error("Could not check for new version!")
	end)
end

math.randomseed(os.time())
local function shuffleTable(t)
	local rand = math.random
	local iterations = #t
	local j

	for i = iterations , 2, -1 do
		j = rand(i)
		t[i], t[j] = t[j], t[i]
	end
	
	return t
end

hook.Add("TTTBeginRound", "TTTFS_BeginRound", function()
	-- Set players role count
	for _, ply in ipairs(player.GetAll()) do
		if ply:GetRole() == ROLE_INNOCENT then
			ply:SetInnocentCount(ply:GetInnocentCount() + 1)
		elseif ply:GetRole() == ROLE_TRAITOR then
			ply:SetTraitorCount(ply:GetTraitorCount() + 1)
		elseif ply:GetRole() == ROLE_DETECTIVE then
			ply:SetDetectiveCount(ply:GetDetectiveCount() + 1)
		end

		ply:SetRoundsPlayed(ply:GetRoundsPlayed() + 1)

		FairSelection:UpdatePlayerChance()
	end
end)

function FairSelection:SelectPlayerForTraitor(choices, prev_roles)
	local total = 0
	local lastChance

	for _, v in pairs(choices) do
		total = total + v:GetChance()
	end

	local r = math.random(1, total)

	for _, pply in pairs(choices) do
		if (r - pply:GetChance()) <= 0 then
			lastChance = pply

			if IsValid(pply) and ((not table.HasValue(prev_roles[ROLE_TRAITOR], pply)) or (math.random(1, 3) == 2)) then
				if (not tobool(pply:GetPData("tpass", false)) and not tobool(pply:GetPData("dpass", false)) and not tobool(pply:GetPData("inno", false))) or tobool(pply:GetPData("tpassfail", false)) or tobool(pply:GetPData("dpassfail", false)) then
					return pply
				end
			end
		end

		r = r - pply:GetChance()
	end

	return lastChance
end

function FairSelection:SelectRoles(ts, ds, traitor_count, det_count, choices, prev_roles)
	local min_karma = GetConVarNumber("ttt_detective_karma_min") or 0
	
	while ts < traitor_count do
		choices = shuffleTable(choices)

		selectedPlayer = self:SelectPlayerForTraitor(choices, prev_roles)
		selectedPlayer:SetRole(ROLE_TRAITOR)
		selectedPlayer:SetChance(FairSelection:DefaultChance())
		table.RemoveByValue(choices, selectedPlayer)

		ts = ts + 1
	end
	
	while(ds < det_count) and (#choices >= 1) do
		if #choices <= (det_count - ds) then
			for _, pply in pairs(choices) do
				if IsValid(pply) then
					if (not tobool(pply:GetPData("tpass", false)) and not tobool(pply:GetPData("dpass", false)) and not tobool(pply:GetPData("inno", false))) or tobool(pply:GetPData("tpassfail", false)) or tobool(pply:GetPData("dpassfail", false)) then
						pply:SetRole(ROLE_DETECTIVE)
					end
				end
			end

			break
		end

		local pick = math.random(1, #choices)
		local pply = choices[pick]

		if (IsValid(pply) and ((pply:GetBaseKarma() > min_karma and table.HasValue(prev_roles[ROLE_INNOCENT], pply)) or math.random(1, 3) == 2)) then
			if not pply:GetAvoidDetective() then
				if (not tobool(pply:GetPData("tpass", false)) and not tobool(pply:GetPData("dpass", false)) and not tobool(pply:GetPData("inno", false))) or tobool(pply:GetPData("tpassfail", false)) or tobool(pply:GetPData("dpassfail", false)) then
					pply:SetRole(ROLE_DETECTIVE)
					ds = ds + 1
				end
			end

			table.remove(choices, pick)
		end
	end

	for _, v in pairs(choices) do
		if IsValid(v) and (not v:IsSpec()) and v:GetRole() == ROLE_INNOCENT then
			if FairSelection.CFG.KarmaIncreaseChance and v:GetBaseKarma() > FairSelection.CFG.KarmaIncreaseChanceThreshold then
				local extra = math.random(0, 2)
				v:AddChance(extra)
			end

			v:AddChance(math.random(6, 10))
		end
	end
end

function FairSelection:Standalone()
	local choices = {}
	local prev_roles = {
		[ROLE_INNOCENT] = {},
		[ROLE_TRAITOR] = {},
		[ROLE_DETECTIVE] = {}
	}

	if not GAMEMODE.LastRole then GAMEMODE.LastRole = {} end
	
	for _, v in pairs(player.GetAll()) do
		if IsValid(v) and (not v:IsSpec()) then
			local r = GAMEMODE.LastRole[v:UniqueID()] or v:GetRole() or ROLE_INNOCENT
			table.insert(prev_roles[r], v)
			table.insert(choices, v)
		end

		v:SetRole(ROLE_INNOCENT)
	end

	local choice_count = #choices
	local traitor_count = GetTraitorCount(choice_count)
	local det_count = GetDetectiveCount(choice_count)

	if choice_count == 0 then return end

	local ts = 0
	local ds = 0

	self:SelectRoles(ts, ds, traitor_count, det_count, choices, prev_roles)

	GAMEMODE.LastRole = {}

	for _, ply in ipairs(player.GetAll()) do
		ply:SetDefaultCredits()

		GAMEMODE.LastRole[ply:UniqueID()] = ply:GetRole()
	end
end

hook.Add("PlayerInitialSpawn", "TTFS_PlayerInitialSpawn", function(ply)
	if not ply:IsBot() then
		FairSelection.DB:prepare("SELECT chance FROM prefix_chances WHERE steamid=?", {ply:SteamID64()}, function(data)
			if table.Count(data) > 0 then
				ply:SetChance(data[1].chance)
			else
				local chance = FairSelection:DefaultChance()

				FairSelection.DB:prepare("INSERT INTO prefix_chances (steamid, chance, lastupdate) VALUES(?, ?, ?)", {ply:SteamID64(), chance, os.time()})
				ply:SetChance(chance)
			end
		end)
	end
end)

timer.Simple(5, function()
	if FairSelection.CFG.Standalone then
		SelectRoles = FairSelection:Standalone
	end
end)
