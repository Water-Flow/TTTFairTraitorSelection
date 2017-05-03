--[[
	MySQLoo Handler for FairSelection
]]
require('mysqloo')
local CONN

-- Initialize database setup
function HANDLER:Init()
	if not FairSelection.CFG.DB.Port then
		FairSelection.CFG.DB.Port = 3306
	elseif not isnumber(FairSelection.CFG.DB.Port) then
		FairSelection.CFG.DB.Port = tonumber(FairSelection.CFG.DB.Port)
	end

	CONN = mysqloo.connect(FairSelection.CFG.DB.Hostname, FairSelection.CFG.DB.Username, FairSelection.CFG.DB.Password, FairSelection.CFG.DB.Database, FairSelection.CFG.DB.Port)
end

-- Connects to the database
function HANDLER:connect()
	local function CONN:onConnected()
		FairSelection:Message("Database connection established!")

		HANDLER:CheckTimer()
	end

	local function CONN:onConnectionFailed(err)
		FairSelection:Error("SQL Error: "..err)
	end

	CONN:connect()
end

-- Checks if connection is established, if not trying to connect
function HANDLER:CheckTimer()
	timer.Create("FairSelectionDatabaseConnectionCheck", 90, 0, function()
		if CONN:status() != mysqloo.DATABASE_CONNECTED then
			FairSelection:Error("Database connection interrupted!")
			FairSelection:Message("Try to reconnect...")
			HANDLER:connect()
		end
	end)
end

function HANDLER:CreateDatabase()

end

function HANDLER:query(sql, callback)
	if not callback then callback = nil end

	local sql = FairSelection.DB:esPrefix(sql)
	local query = CONN:query(sql)

	if query != nil then
		function query:onSuccess(data)
			row = data[1]

			if isfunction(callback) then
				callback(data)
			end
		end

		function query:onError(err)
			FairSelection.DB:sqlError(sql, err)
		end

		query:start()
		query:wait()
	end

	return row
end

function HANDLER:prepare(sql, args, callback)
	if not callback then callback = nil end
	
	local sql = FairSelection.DB:esPrefix(sql)
	local query = CONN:prepare(sql)

	if query != nil then
		function query:onSuccess(data)
			row = data[1]

			if isfunction(callback) then
				callback(data)
			end
		end

		function query:onError(err)
			FairSelection.DB:sqlError(sql, err)
		end

		if not args then
			args = nil
		else
			local count = 1

			for _, arg in pairs(args) do
				if type(arg) == 'string' then
					query:setString(count, arg)
				elseif type(arg) == 'number' then
					query:setNumber(count, arg)
				elseif type(arg) == 'boolean' then
					query:setBoolean(count, arg)
				else
					query:setNull(count)
				end

				count = count + 1
			end
		end

		query:start()
		query:wait()
	end
	
	return row
end