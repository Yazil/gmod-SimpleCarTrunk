if CLIENT then

include('sh_config.lua')

surface.CreateFont( "NameFont", {
	font = "Arial", 
	extended = false,
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

function getCoffrePos(veh)

	local  minx, minz = veh:OBBMins(), veh:OBBMaxs()

	pos = Vector(veh:OBBCenter().x, minx.y, veh:OBBCenter().z)
	pos = veh:LocalToWorld(pos)

	return pos

end

local countdown = 0

hook.Add("HUDPaint", "CoffreHud", function()

	local ent = LocalPlayer():GetEyeTrace().Entity

	if(IsValid(ent)) then
		
		if(ent:IsVehicle() && !LocalPlayer():InVehicle()) then

			for i=0, #table.GetKeys( customTrunkSize ) do
				if ent:GetVehicleClass() == table.GetKeys( customTrunkSize )[i] then
					if customTrunkSize[ent:GetVehicleClass()] == -1 then
						return
					end
				end
			end

			local dist = LocalPlayer():GetPos():Distance(getCoffrePos(ent))
			local pos = getCoffrePos(ent):ToScreen()

			if(dist < 100) then
				draw.SimpleText("Appuyez sur [Reload] pour ouvrir", "DermaDefault", pos.x, pos.y, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
				draw.SimpleText("le coffre", "DermaDefault", pos.x+8, pos.y+12, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

				if LocalPlayer():KeyDown(IN_RELOAD) and countdown==0 then
					
					countdown = 200
					requestCoffreContent(ent)

				end
			end
		end

	end

	if countdown > 0 then
		countdown = countdown - 1
	end

end)

function requestCoffreContent(veh)
	net.Start( "GetTrunkContent" )
	net.WriteEntity(veh)
	net.SendToServer()
end

net.Receive( "GetTrunkContent", function( len, pl )
	local veh = net.ReadEntity()
	local curtrunk = net.ReadInt(12)
	local content = net.ReadTable()

	if not veh:IsValid() then return end

	local maxtrunk = defaultTrunkSize


	for i=0, #table.GetKeys( customTrunkSize ) do
		if veh:GetVehicleClass() == table.GetKeys( customTrunkSize )[i] then
			maxtrunk = customTrunkSize[veh:GetVehicleClass()]
		end
	end

	openTrunkMenu(veh, curtrunk, maxtrunk,content)

end)

function openTrunkMenu(veh, curtrunk, maxtrunk,content)
	
	local Frame = vgui.Create( "DFrame" )
	Frame:SetTitle( "Coffre (" .. curtrunk .. "/" .. maxtrunk .. ")" )
	Frame:SetSize( 300,500 )
	Frame:Center()			
	Frame:MakePopup()
	Frame.Paint = function( self, w, h ) 
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 175 ) ) 
	end
			
	local DScrollPanel = vgui.Create( "DScrollPanel", Frame )
	DScrollPanel:Dock( FILL )


	for k, v in pairs(content) do
		local panel = DScrollPanel:Add( "DPanel" )
		panel:Dock( TOP )
		panel:DockMargin( 0, 0, 0, 5 )
		panel:SetSize( 300, 75 )
		panel.Paint = function( self, w, h ) 
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) ) 
		end


		local icon = vgui.Create( "DModelPanel", panel )
		icon:SetPos(0,0)
		icon:SetSize( 75, 75 )
		icon:SetModel( v.model )
		icon.DoClick = function ( )
			net.Start("RemoveItemFromTrunk")
			net.WriteEntity(veh)
			net.WriteInt(k,15)
			net.SendToServer()

			Frame:Close()
		end

		local label = vgui.Create( "DLabel", panel )
		label:SetFont("NameFont")
		label:SetPos( 90, 20 )
		label:SetSize( 200, 50 )
		label:SetText(v.name)

	end
end

end