FairSelection.DB = FairSelection.DB or {}
local DBHandler = DBHandler or {}

function FairSelection.DB:Init()
	FairSelection:Message("Initialize database "..string.lower(FairSelection.CFG.DB.Type))

	include("fairselection/database/"..string.lower(FairSelection.CFG.DB.Type))
	DBHandler = HANDLER
	HANDLER = nil

	DBHandler:Init()
end

function FairSelection.DB:sqlError(sql, err)
	FairSelection:Message("===============================================================")
	FairSelection:Error("Query errored!")
	FairSelection:Error("Query: "..sql)
	FairSelection:Error("Error: "..err)
	FairSelection:Message("===============================================================")
end

function FairSelection.DB:esPrefix(sql)
	return string.Replace(sql, "prefix_", FairSelection.CFG.DB.Prefix)
end

function FairSelection.DB:connect()
	DBHandler:connect()
end

function FairSelection.DB:query()
	DBHandler:query()
end

function FairSelection.DB:prepare()
	DBHandler:prepare()
end
