local Queries = { 
    Update = "UPDATE Fishingmod SET Catches = %d, Exp = %d WHERE UniqueID = %d",
    Get = "SELECT * FROM Fishingmod WHERE UniqueID = %d",
    Create = "INSERT INTO Fishingmod( UniqueID, Exp, Catches ) VALUES( %d, 0, 0 )",
    Table = "CREATE TABLE Fishingmod ( UniqueID int, Catches int, Exp int )"
}

function fishingmod.GainEXP(ply, Amount )
	ply.fishingmod_exp = ply.fishingmod_exp + Amount
	ply.fishingmod_catches = ply.fishingmod_catches + 1
	fishingmod.UpdatePlayerInfo(ply)
	--print("player", ply, "amount", Amount, "previous exp", ply.fishingmod_exp, "previous catches", ply.fishingmod_catches)
    sql.Query( Queries.Update:format( ply.fishingmod_catches, ply.fishingmod_exp, ply:UniqueID() ) )
end

hook.Add( "PlayerInitialSpawn", "Fishingmod:ExpPlayerJoined", function( ply )
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		local Query = sql.Query( Queries.Get:format( ply:UniqueID() ) )
		if( !Query ) then
			print("No Unique ID in database, creating new")
			sql.Query( Queries.Create:format( ply:UniqueID() ) )
			ply.fishingmod_catches = 0
			ply.fishingmod_exp = 0
			fishingmod.UpdatePlayerInfo(ply)
			return
		end
		--print("catches", tonumber(Query[1].Catches), "exp", tonumber(Query[1].Exp))
		ply.fishingmod_catches = tonumber(Query[1].Catches)
		ply.fishingmod_exp = tonumber(Query[1].Exp)
		fishingmod.UpdatePlayerInfo(ply)
	end)

end )

if( !sql.TableExists( "Fishingmod" ) ) then
	sql.Query( Queries.Table )
end