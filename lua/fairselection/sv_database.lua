FairSelection.DB = FairSelection.DB or {}
local DBHandler = DBHandler or {}

function FairSelection.DB:Init()
	FairSelection:Message("Initialize database "..FairSelection.CFG.DB.Type)

	HANDLER = {}
	include("fairselection/database/"..string.lower(FairSelection.CFG.DB.Type)..".lua")
	DBHandler = HANDLER

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
	DBHandler:CreateDatabase()
end

function FairSelection.DB:query(sql, callback)
	DBHandler:query(sql, callback)
end

function FairSelection.DB:prepare(sql, args, callback)
	DBHandler:prepare(sql, args, callback)
end
