-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()


--------------------------------------------

-- forward declarations and other locals


-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )	

local group = self.view

display.setStatusBar(display.HiddenStatusBar)
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )

-----------------------------------------
local performance = require('performance')
performance:newPerformanceMeter()
-----------------------------------------

physics.setGravity(0,9.8)
physics.setDrawMode("normal")

settings = {}
settings.reverse = false
settings.reverseInt = 0

if settings.reverse == true then
	settings.reverseInt = -1
else
	settings.reverseInt = 1
end

won = false
lost = false

music = audio.loadStream("music.mp3")
musicChannel = audio.play( music, { channel=1, loops=-1, fadein=3000 }  )

explosion = {}
explosion[1] = audio.loadSound("explosion1.wav")
explosion[2] = audio.loadSound("explosion2.wav")
explosion[3] = audio.loadSound("explosion3.wav")
explosion[4] = audio.loadSound("explosion4.wav")
 
local function playExplosion()
      local thisExplosion = math.random(#explosion) 
      audio.play(explosion[thisExplosion])
end

local background = display.newImage( "bg.jpg", true )
background.x = display.contentWidth / 2
background.y = display.contentHeight / 2

local balloon = display.newCircle( 777,494,25 )
balloon:setFillColor(255,0,0)
balloon.force = 0.0006
physics.addBody(balloon, { bounce = 0, radius = 12, friction = 1.0, filter = {maskBits = 2, categoryBits = 1} } )
balloon.isFixedRotation = true
balloon.angularVelocity = 0
balloon.ID = "balloon"
balloon.isBullet = true
balloon.paused = false
balloon.isVisible = false
balloon.canJump = false

currentParticle = 1
limit = 0
Particle = {}
explode = false

--local ground = display.newRect(0,450,1000,50)
--ground:setFillColor(180,30,30)
--physics.addBody(ground, "static", { bounce = 0, friction = 1.0, filter = {maskBits = 5, categoryBits = 2} } )

local camera = display.newGroup()
camera.shake = 0
local shake = false

camera:insert(balloon)
--camera:insert(ground)

Sensor = {}
currentSensor = 1
Wall = {}
currentWall = 1


function addSensor(x, y, width, height)
	x = x + width / 2
	y = y - height / 2
	Sensor[currentSensor] = display.newRect(x,y,width,height)
	Sensor[currentSensor].x = x
	Sensor[currentSensor].y = y
	Sensor[currentSensor].width = width
	Sensor[currentSensor].height = height
	Sensor[currentSensor]:setFillColor(80,80,80)
	Sensor[currentSensor].ID = "Sensor"..tostring(currentSensor)
	camera:insert(Sensor[currentSensor])
	physics.addBody(Sensor[currentSensor], "static", { bounce = 0, friction = 1.0, filter = {maskBits = 5, categoryBits = 2} } )
	currentSensor = currentSensor + 1
end

function addWall(x, y, width, height)
	x = x + width / 2
	y = y - height / 2
	Wall[currentWall] = display.newRect(x,y,width,height)
	Wall[currentWall].x = x
	Wall[currentWall].y = y
	Wall[currentWall].width = width
	Wall[currentWall].height = height
	Wall[currentWall]:setFillColor(180,30,30)
	Wall[currentWall].ID = "Wall"
	camera:insert(Wall[currentWall])
	physics.addBody(Wall[currentWall], "static", { bounce = 0, friction = 1.0, filter = {maskBits = 5, categoryBits = 2} } )
	currentWall = currentWall + 1
end

currentLevel = 2
map = require ('level'..currentLevel)

for i,v in pairs{sensors=addSensor, walls=addWall} do
	for _, data in ipairs(map[i]) do
		v(unpack(data))
	end
end

balloon.x, balloon.y = map.player[1], map.player[2]

count = #Sensor

function addParticle()	
	count = count - 1
	for i = 1, limit do				
		Particle[i] = {}
		Particle[i].size = math.random(3,6)
		Particle[i] = display.newRect(collX + math.random(-collW / 2, collW / 2), collY + math.random(-collH / 2,collH / 2),Particle[i].size,Particle[i].size)
		physics.addBody(Particle[i], { bounce = 0.035, friction = 0.9, filter = {maskBits = 6, categoryBits = 4} } )
		Particle[i]:setFillColor(80,80,80)
		camera:insert(Particle[i])
		--Particle[currentParticle].fixture:setUserData("particle")
		--Particle[currentParticle].fixture:setCategory(3)
		--Particle[currentParticle].fixture:setMask(4,5)
		currentParticle = currentParticle + 1
	end
	currentParticle = 1
end

local runtime = 0

local function getDeltaTime()
	local temp = system.getTimer()  --Get current game time in ms
	local dt = (temp-runtime) / (1000/60)  --60fps or 30fps as base
	runtime = temp  --Store game time
	return dt
end
	
local sheet1 = graphics.newImageSheet( "ball_anim.png", { width=24, height=24, numFrames=16 } )
local instance1 = display.newSprite( sheet1, { name="ball_idle", start=1, count=16, time=2000 } )
instance1.x = 0
instance1.y = 0
instance1:play()

function slowMotion()
	if count == 1 then		
		physics.pause()
		timer.performWithDelay( 700, function()
			physics.start()
		end, 1 )		
	end
end

function wonText()
	local wonText = display.newText("", 0, 0, native.systemFontBold, 24)
	wonText:setReferencePoint(display.CenterReferencePoint)
	wonText.x = display.contentWidth * 0.5
	wonText.y = display.contentHeight * 0.5
	wonText:setTextColor(255, 255, 255)
	wonText.text = "Level Completed"
	wonText.alpha = 0
	transition.to( wonText, { time=750, alpha=1.0 } )
end

function lostText()
	local lostText = display.newText("", 0, 0, native.systemFontBold, 24)
	lostText:setReferencePoint(display.CenterReferencePoint)
	lostText.x = display.contentWidth * 0.5
	lostText.y = display.contentHeight * 0.5
	lostText:setTextColor(255, 255, 255)
	lostText.text = "Try Again"
	lostText.alpha = 0
	transition.to( lostText, { time=750, alpha=1.0 } )
end

function update()	

	local dt = getDeltaTime()
	instance1:toFront()

	if explode then
		addParticle()
		explode = false
		for i,v in ipairs(Particle) do
			v:applyLinearImpulse(math.random(-2,2)/1000,math.random(-2,2)/1000)
		end
	end	
	
	if shake then
		camera.shake = math.random(-15,15)
	else
		camera.shake = 0
	end	
	
	camera.x = ((balloon.x - display.contentWidth / 2) * -1) + camera.shake
	camera.y = ((balloon.y - display.contentHeight / 2) * -1) + camera.shake
	
	instance1.x = balloon.x + camera.x
	instance1.y = balloon.y + camera.y
	
	if balloon.paused then
		balloon.isAwake = false
		balloon:setLinearVelocity(0,0)
	else
		balloon.isAwake = true
	end
end

function stopShake(event)
	shake = false
end

function onCollision(event)
	if (event.phase == "began") then
		if (event.object1.ID == 'Wall') or (event.object2.ID == 'Wall') then
			if (event.object1.ID == "balloon") or (event.object2.ID == "balloon") then
				lost = true
				lostText()
				restart = timer.performWithDelay(10, storyboard.gotoScene( "menu", "zoomInOutFade", 500))
				balloon.paused = true
				balloon.canJump = false
				transition.to( instance1, { time=750, alpha=0.0 } )
				playExplosion()
			end
		end
		for i,v in ipairs(Sensor) do
			if (event.object1.ID == Sensor[i].ID) or (event.object2.ID == Sensor[i].ID) then
				if (event.object1.ID == "balloon") or (event.object2.ID == "balloon") then
					--shake = true
					if (stopTimer) then
						timer.cancel(stopTimer)
					end
					stopShake()
					balloon.paused = true
					balloon.canJump = true
					collX, collY, collW, collH = Sensor[i].x, Sensor[i].y, Sensor[i].width, Sensor[i].height
					limit = (collW + collH) / 3
					if limit > 140 then limit = 140 end
					if count == 1 then
						won = true
						wonText()
						transition.to( instance1, { time=750, alpha=0.0 } ) 
						v:removeSelf()
						v = nil
						shake = true
						playExplosion()
						explode = true
						balloon.paused = true
						balloon.canJump = false
						stopTimer = timer.performWithDelay( 700, stopShake )
						slowMotion()
					end
				end
			end
		end
	end
	if (event.phase == "ended") then
		for i,v in ipairs(Sensor) do
			if (event.object1.ID == Sensor[i].ID) or (event.object2.ID == Sensor[i].ID) then
				if (event.object1.ID == "balloon") or (event.object2.ID == "balloon") then
					v:removeSelf()
					v = nil
					shake = true
					playExplosion()
					explode = true
					balloon.paused = false
					balloon.canJump = false				
					stopTimer = timer.performWithDelay( 700, stopShake )
					--slowMotion()
					print (count) --debug
				end
			end
		end
	end
end

function onTouch(event)
	if event.phase == "ended" and balloon.canJump then
		balloon.paused = false
		balloon:applyLinearImpulse(((event.x-balloon.x - camera.x)*balloon.force)*settings.reverseInt,((event.y-balloon.y - camera.y)*balloon.force)*settings.reverseInt)
		display.remove(line)
	end
	if event.phase == "moved" or event.phase == "began" then
		if (line) then
			display.remove(line)
		end
		if balloon.canJump then
			line = display.newLine(balloon.x + camera.x, balloon.y + camera.y, event.x, event.y)
			local dist = distanceFrom(event.x,event.y,balloon.x + camera.x,balloon.y + camera.y)*1.25
			if dist > 255 then dist = 255 end
			line:setColor(255,255,255,dist)
			line.width = 2
		end
	end
end

function distanceFrom(x1,y1,x2,y2)
	local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) * 0.65
	if distance > 255 then distance = 255 end
	return math.floor(distance + .5)
end

Runtime:addEventListener("touch", onTouch)

group:insert(background)
group:insert(balloon)
group:insert(instance1)
group:insert(camera)

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	if storyboard.getPrevious() ~= nil then
		--print("previous screen in mainmenu " ..  storyboard.getPrevious());
		storyboard.purgeScene(storyboard.getPrevious())
		storyboard.removeScene(storyboard.getPrevious())			
	end
	local group = self.view
	
	physics.start()
	Runtime:addEventListener("collision", onCollision)
	Runtime:addEventListener("enterFrame", update)
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	Runtime:removeEventListener("collision", onCollision)
	Runtime:removeEventListener("enterFrame", update)
	Runtime:removeEventListener("touch", onTouch)
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene