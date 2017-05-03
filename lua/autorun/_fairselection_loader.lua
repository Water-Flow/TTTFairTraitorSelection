FairSelection = FairSelection or {}

if SERVER then
	include("fairselection/sv_init.lua")
	include("fairselection/sv_functions.lua")
	include("fairselection/sv_database.lua")
	include("fairselection/sv_player.lua")

	FairSelection:Message("Initialization...")
	FairSelection:VersionCheck()
	FairSelection:LoadConfig()
	FairSelection:Message("Config loaded.")
	FairSelection.DB:Init()
	FairSelection.DB:connect()
	FairSelection:Message("Initialization completed!")
end