-- SpeedPlayer Mod

-- Refactored from FS17, FS19 by *TurboStar* | LS Modcompany

-- V1.0.0.0  		Initial release
-- V1.1.0.0

SpeedPlayer = {}

function SpeedPlayer:loadMap(...)
	self.SPEEDS = {0.8, 2.0, 4.0*0.7, 4.0, 12.0, 32.0, 60.0, 80.0} -- m/s
	self.SPEEDSLENGTH = #self.SPEEDS
	self.TEXTS = {[0.8] = "keyslow3", [2.0] = "keyslow2", [4.0*0.7] = "keyslow1", [4.0] = "key0", [12.0] = "key1", [32.0] = "key2", [60.0] = "key15", [80.0] = "key3", ["other"] = "othermod"}
	self.cont = 4
	self.eventIdReduce, self.eventIdIncrease = "", ""
	self.errorDisplayed = false
end

function SpeedPlayer:registerActionEvents()
	_, SpeedPlayer.eventIdReduce = g_inputBinding:registerActionEvent(InputAction.SPEEDMINUS, SpeedPlayer, SpeedPlayer.reduceSpeed, false, true, false, false, -1, true)
	_, SpeedPlayer.eventIdIncrease = g_inputBinding:registerActionEvent(InputAction.SPEEDPLUS, SpeedPlayer, SpeedPlayer.incrementSpeed, false, true, false, false, 1, true)
end
Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, SpeedPlayer.registerActionEvents)

function SpeedPlayer:deleteMap()
end

function SpeedPlayer:mouseEvent(...)
end

function SpeedPlayer:keyEvent(...)
end

--- Event callback used to reduce cont, so the speed
function SpeedPlayer:reduceSpeed()
	if (self.cont == 1) then return end
	self.cont = self.cont - 1
	-- g_inputBinding.events[SpeedPlayer.eventIdReduce].callbackState is -1 here
	
	local spe = self.SPEEDS[self.cont]
	self:setSpeed(spe)
end
--- Event callback used to increase cont, so the speed
function SpeedPlayer:incrementSpeed()
	if (self.cont == self.SPEEDSLENGTH) then return end
	self.cont = self.cont + 1
	-- g_inputBinding.events[SpeedPlayer.eventIdIncrease].callbackState is 1 here
	
	local spe = self.SPEEDS[self.cont]
	self:setSpeed(spe)
end

--- Set speed changing each player informations
-- @param speed of the player (m/s)
function SpeedPlayer:setSpeed(speed)
	local info = g_currentMission.player.motionInformation
	if speed ~= nil then 
		info.maxWalkingSpeed = tonumber(speed)
		info.maxRunningSpeed = tonumber(speed * (9/4))
		info.maxSwimmingSpeed = tonumber(speed / (4/3))
		info.maxCrouchingSpeed = tonumber(speed / 2)
		info.maxFallingSpeed = tonumber(speed * 1.5)
		-- info.maxCheatRunningSpeed = tonumber(speed * (34/4)) -- We keep cheats run at 34 m/s
	end
end

function SpeedPlayer:update(dt)
	if g_currentMission:getIsClient() then -- don't run on the Dedicated Server itself
		if g_gui.currentGui == nil and g_currentMission.controlledVehicle == nil then -- only if no vehicle is entered or menu is up
		
			if (self.cont ~= nil and (self.cont < 1 or self.cont > self.SPEEDSLENGTH)) or self.cont == nil then
				if not self.errorDisplayed then 
					print("SpeedPlayer: something is wrong on SpeedPlayer.cont ... Aborting functionality. Please report your log.txt")
					self.errorDisplayed = true
				end
				return
			end
			
			local eventIdReduce = self.eventIdReduce
			local eventIdIncrease = self.eventIdIncrease
			g_inputBinding:setActionEventActive(eventIdReduce, SpeedPlayer.cont ~= 1)
			g_inputBinding:setActionEventTextVisibility(eventIdReduce, SpeedPlayer.cont ~= 1)
			g_inputBinding:setActionEventActive(eventIdIncrease, SpeedPlayer.cont ~= SpeedPlayer.SPEEDSLENGTH)
			g_inputBinding:setActionEventTextVisibility(eventIdIncrease, SpeedPlayer.cont ~= SpeedPlayer.SPEEDSLENGTH)
			
			local info = g_currentMission.player.motionInformation
			if self.TEXTS[info.maxWalkingSpeed] ~= nil then g_currentMission:addExtraPrintText(g_i18n:getText(self.TEXTS[info.maxWalkingSpeed])) else g_currentMission:addExtraPrintText(g_i18n:getText(self.TEXTS["other"])) end
		end
		
	end
end

function SpeedPlayer:draw()
end

print("  Loaded SpeedPlayer Mod...")
addModEventListener(SpeedPlayer)