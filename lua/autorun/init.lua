if SERVER then

AddCSLuaFile('sh_config.lua')

include('sh_config.lua')

util.AddNetworkString("GetTrunkContent")
util.AddNetworkString("RemoveItemFromTrunk")


hook.Add('OnEntityCreated', 'VehInit', function(ent)

	if ( not ent:IsValid() or not ent:IsVehicle()) then return end

	ent.curtrunk = 0
	ent.maxtrunk = defaultTrunkSize
	
	timer.Simple(0.1, function()
		for i=0, #table.GetKeys( customTrunkSize ) do
			print(ent:GetVehicleClass())
			print(table.GetKeys( customTrunkSize )[i])
			if ent:GetVehicleClass() == table.GetKeys( customTrunkSize )[i] then
				ent.maxtrunk = customTrunkSize[ent:GetVehicleClass()]
			end
		end
	end)

	ent.inv = {}
	ent.lastent = Entity(1)
	ent:AddCallback( "PhysicsCollide", PhysCallback ) 
	

end)

function getCoffrePos(veh)

	local  minx, minz = veh:OBBMins(), veh:OBBMaxs()

	pos = Vector(veh:OBBCenter().x, minx.y, veh:OBBCenter().z)
	pos = veh:LocalToWorld(pos)

	return pos

end

function PhysCallback( ent, data )
	if data.HitPos:Distance(getCoffrePos(ent)) < 25 then
		for i=0, #table.GetKeys( allowedEnts ) do
			if data.HitEntity:GetClass() == table.GetKeys( allowedEnts )[i] then
				if ent.lastent != data.HitEntity then
					weight = ent.curtrunk + allowedEnts[table.GetKeys( allowedEnts )[i]]
					if weight <= ent.maxtrunk then
						ent.lastent = data.HitEntity
						ent.curtrunk = ent.curtrunk + allowedEnts[table.GetKeys( allowedEnts )[i]]
						table.Add(ent.inv, {serialize(data.HitEntity)})
						data.HitEntity:Remove()
					end
				end
			end
		end
	end
	
end

-- On dit merci FPtje

function getDTVars(ent)
    if not ent.GetNetworkVars then return nil end
    local name, value = debug.getupvalue(ent.GetNetworkVars, 1)
    if name ~= "datatable" then
        ErrorNoHalt("Warning: Datatable cannot be stored properly in trunk. Tell a developer!")
    end

    local res = {}

    for k,v in pairs(value) do
        res[k] = v.GetFunc(ent, v.index)
    end

    return res
end

function serialize(ent)
    local serialized = duplicator.CopyEntTable(ent)
    serialized.DT = getDTVars(ent)

   
    if ent.OnEntityCopyTableFinish then
        ent:OnEntityCopyTableFinish(serialized)
    end

    return serialized
end



net.Receive( "RemoveItemFromTrunk", function( len, pl )
	local veh = net.ReadEntity()
	local id = net.ReadInt(15)

	if not veh:IsValid() or not veh.inv[id] then return end

	local infos = veh.inv[id]

	local ent = deserialize( veh, infos )

	veh.curtrunk = veh.curtrunk - allowedEnts[infos.Class]

	veh.inv[id] = nil

end )

net.Receive( "GetTrunkContent", function( len, pl )
	local veh = net.ReadEntity()

	if not veh:IsValid() then return end

	if veh:isLocked() then
		DarkRP.notify(pl, 1, 3, "Ce véhicule est fermé")

		return
	end


	local pack = {}

	for k,v in pairs(veh.inv) do
		pack[k] = {
			name = v.PrintName,
			model = v.Model
		}

	end

	net.Start( "GetTrunkContent" )
	net.WriteEntity(veh)
	net.WriteInt(veh.curtrunk, 12)
	net.WriteTable( pack )

	net.Send(pl)

end )

function deserialize(veh, item)
    local ent = ents.Create(item.Class)
    duplicator.DoGeneric(ent, item)
    ent:Spawn()
    ent:Activate()

    duplicator.DoGenericPhysics(ent, nil, item)
    table.Merge(ent:GetTable(), item)

    if ent:IsWeapon() and ent.Weapon ~= nil and not ent.Weapon:IsValid() then ent.Weapon = ent end
    if ent.Entity ~= nil and not ent.Entity:IsValid() then ent.Entity = ent end

    local spawnPos = getCoffrePos(veh)

    spawnPos = spawnPos + Vector(-30,0,0)

    ent:SetPos(spawnPos)


    local phys = ent:GetPhysicsObject()
    timer.Simple(0, function() if phys:IsValid() then phys:Wake() end end)

    if ent.OnDuplicated then
        ent:OnDuplicated(item)
    end

    if ent.PostEntityPaste then
        ent:PostEntityPaste(ply, ent, {ent})
    end

    return ent
end



end