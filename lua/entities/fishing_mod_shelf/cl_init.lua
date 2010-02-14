include('shared.lua')

local sprite = Material( "sprites/splodesprite" )

function ENT:Draw()
	self:DrawModel()
	
--[[ 	
	render.SetMaterial( sprite )
	for k, v in pairs( self.storage ) do
		render.DrawSprite( self:GetPos() + ( self:GetUp() * v.position.z ) + ( self:GetRight() * v.position.x ) + ( self:GetForward() * v.position.y ), 1, 1, Color( 255, 255, 255, 255 ) )
	end
 ]]
end