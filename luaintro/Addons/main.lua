
if addon.InGetInfo then
	return {
		name    = "Main",
		desc    = "displays a simple loading bar",
		author  = "jK",
		date    = "2012,2013",
		license = "GPL2",
		layer   = 0,
		depend  = {"LoadProgress"},
		enabled = true,
	}
end

local showTips = (Spring.GetConfigInt("loadscreen_tips",1) == 1)

local showTipAboveBar = true
local showTipBackground = false	-- false = tips shown below the loading bar

local tips = {
	"Have trouble finding metal spots?\nPress F4 to switch to the metal map.",
	"Queue-up multiple consecutive unit actions by holding SHIFT.",
	"Tweak graphic preferences in options (top right corner of the screen).\nWhen your FPS drops, switch to a lower graphic preset.",
	"Radars are cheap. Make them early in the game to effectively counter initial strikes.",
	--"To see detailed info about each unit in-game switch on \"Extensive unit info\" via Options menu",
	"In general, vehicles are a good choice for flat and open battlefields. Bots are better on hills.",
	"Go for Wind Generators when the average wind speed is over 7. Current, minimum, and maximum wind speeds are shown to the right of the energy bar.",
	"If your economy is based on wind generators, always build an E storage to have a reserve for when the wind speed drops.",
	"Commanders have a manual D-Gun weapon, which can decimate every unit with one shot.\nPress D to quickly initiate aiming.",
	"Spread buildings to prevent chain explosions.\nPress ALT+Z and ALT+X to adjust auto-spacing.",
	"It is effective to move your units in spread formations.\nDrag your mouse while initiating a move order to draw multiple waypoints.",
	--"Artillery vehicles can move in reverse if you press 'Ctrl' while giving a command behind it. Use this to keep shooting during a retreat.",
	"T2 factories are expensive. You can reclaim your T1 lab for metal to fund it.",
	"Air strikes and air drops may come at any time, always have at least one anti-air unit in your base.",
	"With Q + double click LMB you can place a label with text on the map.\nQ + middle mouse button for an empty label. Q + mouse drag to draw lines",
	"Always check your Com-counter (next to resource bars). If you have the last Commander you better hide it quick!",
	"Expanding territory is essential for gaining economic advantage.\nTry to secure as many metal spots and geothermal vents as you can.",
	"Think in advance about reclaiming metal from wrecks piling up at the front.",
	"Nano turrets can be picked up by transporters. This way you can move them where you need more buildpower.",
	"Set your factories on Repeat to let it build a continuous queue of units.",
	"Use the Fight Command (F) with your rez-bots to make them reclaim and repair everything in the vicinity.\nOptionally turn on Repeat to let them do this forever.",
	"When you're overflowing energy... build metal makers to convert energy to metal.",
	"Press F3 to go to the location of the last notification or label by a team mate",
	"Select all units of the same type by pressing CTRL+Z.",
	"You can pause the game with the PAUSE/BREAK key, or by typing /pause",
	"Did your team member drop out of the game? Type /take to add all of his units to your army.",
	"Give your nano turrets a Fight Command (F) to let it repair and reclaim everything within reach.",
	"Press E and drag and area circle to quickly rEclaim all resources/wreckages.",
	"Press R and drag and area circle to quickly Repair all units inside this circle.",
	"Press CTRL+C to quickly select and center the camera on your Commander.",
	"Think ahead and include anti-air and support units in your army.",
	"Mastering hotkeys is the key to proficiency.\nUse Z,X,C,V to quickly cycle between most frequently built structures.",
	"To share resources with team mates:\nClick-drag metal/energy bar next to player's name to send resources.",
	"To share units with team mates:\nSelect the unit(s) and click the tank-icon next to the players name.",
	"It is efficient to support your lab with constructors increasing its build-power.\nRight click on the factory with a constructor selected to guard (assist) with construction",
	"Remember to separate your highly explosive buildings (like metal makers) from the rest of your base.",
	"Most long-ranged units are very vulnerable in close combat. Always keep a good distance from your targets. Try to use the Fight (F) Command",
	"Keep all your builders busy.\nPress CTRL+B to select and center camera on your idle constructor.",
	"The best way to prevent air strikes is building fighters and putting them on PATROL in front of your base.",
	"Use radar jammers to hide your units from enemy radar and hinder artillery strikes.",
	"Cloaking your Commander while stationary drains 100 energy/second. It costs 1000 energy/second when walking.",
	"Combine CLOAK with radar jamming to completely hide your units.",
	"Long-ranged units need scouting for accurate aiming.\nGenerate a constant stream of fast, cheap units for better vision.",
	"You can assign units to groups by pressing CTRL+[num].\nSelect the group using numbers (1-9).",
	"When performing a bombing run fly your fighters first to eliminate enemy's fighter-wall.\nUse FIGHT or PATROL command for more effective engagement.",
	"You can disable enemy's anti-nukes using EMP missiles (built by ARM T2 cons).",
	"Shields in BAR are 'plasma-deflector-shields'. They only deflect plasma shells. Everything else will go through.",
	"Don't build too much stuff around your Moho-geothermal power plants or everything will go boom!",
	"If you encounter a bug, or have a great idea or want to contribute in any way, please join BAR on Discord.",
	"Build long range anti-air on an extended front line to slowly dismantle enemy's fighter-wall.",
	"Your commander's Dgun can be used for insta-killing T3 units.\nDon't forget to CLOAK first. For quickly cloaking press K.",
	"If you are certain of losing some unit in enemy territory, self-destruct (CTRL+D) it to prevent him from getting the metal.",
	"Mines are super-cheap and quick to build. Remember to make them away from enemy's line of sight.",
	"Enemy's mines, radars, and jammers may be disabled using the Juno - built by both factions with T1 constructors.",
	"Use Alt+0-9 sets autogroup# for selected unit type(s). Newly built units get added to group# equal to their autogroup#. Alt BACKQUOTE (~) remove units.",
}

local infolog = VFS.LoadFile("infolog.txt")
local usingIntelGpu = false
if infolog then
	local function lines(str)
		local t = {}
		local function helper(line) table.insert(t, line) return "" end
		helper((str:gsub("(.-)\r?\n", helper)))
		return t
	end

	-- store changelog into array
	local fileLines = lines(infolog)
	for i, line in ipairs(fileLines) do
		if string.sub(line, 1, 3) == '[F='  then
			break
		end
		if string.find(line, 'GL vendor') then
			if string.find(string.lower(line), 'intel') then
				usingIntelGpu = true
			end
		end
		if string.find(line, 'GLSL version') then
			if string.find(string.lower(line), 'intel') then
				usingIntelGpu = true
			end
		end
		if string.find(line, 'GL renderer') then
			if string.find(string.lower(line), 'intel') then
				usingIntelGpu = true
			end
		end
	end
end

-- Since math.random is not random and always the same, we save a counter to a file and use that.
local randomTip = ''
if showTips then
	local filename = "LuaUI/Config/randomseed.txt"
	local k = os.time() % 1500
	if VFS.FileExists(filename) then
		k = tonumber(VFS.LoadFile(filename))
		if not k then k = 0 end
	end
	k = k + 1
	local file = assert(io.open(filename,'w'), "Unable to save latest randomseed from "..filename)
	if file then
		file:write(k)
		file:close()
		file = nil
	end

	randomTip = tips[((math.ceil(k/2)) % #tips) + 1]
end

-- for guishader
local function CheckHardware()
	if (not (gl.CopyToTexture ~= nil)) then
		return false
	end
	if (not (gl.RenderToTexture ~= nil)) then
		return false
	end
	if (not (gl.CreateShader ~= nil)) then
		return false
	end
	if (not (gl.DeleteTextureFBO ~= nil)) then
		return false
	end
	if (not gl.HasExtension("GL_ARB_texture_non_power_of_two")) then
		return false
	end
	if Platform ~= nil and Platform.gpuVendor == 'Intel' then
		return false
	end
	return true
end
local guishader = CheckHardware()

local blurIntensity = 0.007
local blurShader
local screencopy
local blurtex
local blurtex2
local stenciltex
local screenBlur = false
local guishaderRects = {}
local guishaderDlists = {}
local oldvs = 0
local vsx, vsy   = Spring.GetViewGeometry()
local ivsx, ivsy = vsx, vsy
local lastLoadMessage = ""

local wsx, wsy, _, _ = Spring.GetWindowGeometry()
local ssx, ssy, _, _ = Spring.GetScreenGeometry()
if wsx > ssx or wsy > ssy then

end

function lines(str)
	local t = {}
	local function helper(line)
		t[#t + 1] = line
		return ""
	end
	helper((str:gsub("(.-)\r?\n", helper)))
	return t
end

function addon.LoadProgress(message, replaceLastLine)
	lastLoadMessage = message
end

local defaultFont = 'Poppins-Regular.otf'
local fontfile = 'fonts/'..Spring.GetConfigString("bar_font", defaultFont)
if not VFS.FileExists(fontfile) then
	Spring.SetConfigString('bar_font', defaultFont)
	fontfile = 'fonts/'..defaultFont
end

local defaultFont2 = 'Exo2-SemiBold.otf'
local fontfile2 = 'fonts/'..Spring.GetConfigString("bar_font2", defaultFont2)
if not VFS.FileExists(fontfile2) then
	Spring.SetConfigString('bar_font2', defaultFont2)
	fontfile2 = 'fonts/'..defaultFont2
end

local height = math.floor(vsy * 0.038) -- loading bar height (in pixels)

local posYorg = math.floor((0.065 * vsy)+0.5) / vsy
local posX = math.floor(((((posYorg*1.44)*vsy)/vsx) * vsx)+0.5) / vsx

local borderSize = math.max(1, math.floor(vsy * 0.0027))

local fontSize = 40
local fontScale = math.min(3, (0.5 + (vsx*vsy / 3500000)))
local font = gl.LoadFont(fontfile, fontSize*fontScale, (fontSize/2)*fontScale, 1)
local loadedFontSize =  fontSize*fontScale
local font2Size = 46
local font2 = gl.LoadFont(fontfile2, font2Size*fontScale, (font2Size/4)*fontScale, 1.3)
local loadedFont2Size =  font2Size*fontScale

function DrawStencilTexture()
    if next(guishaderRects) or next(guishaderDlists) then
		if stenciltex then
			gl.DeleteTextureFBO(stenciltex)
		end
		stenciltex = gl.CreateTexture(vsx, vsy, {
			border = false,
			min_filter = GL.NEAREST,
			mag_filter = GL.NEAREST,
			wrap_s = GL.CLAMP,
			wrap_t = GL.CLAMP,
			fbo = true,
		})
    else
        gl.RenderToTexture(stenciltex, gl.Clear, GL.COLOR_BUFFER_BIT ,0,0,0,0)
        return
    end

    gl.RenderToTexture(stenciltex, function()
        gl.Clear(GL.COLOR_BUFFER_BIT,0,0,0,0)
        gl.PushMatrix()
        gl.Translate(-1,-1,0)
        gl.Scale(2/vsx,2/vsy,0)
		for _,rect in pairs(guishaderRects) do
			gl.Rect(rect[1],rect[2],rect[3],rect[4])
		end
		for _,dlist in pairs(guishaderDlists) do
			gl.CallList(dlist)
		end
        gl.PopMatrix()
    end)
end

function CreateShaders()

    if (blurShader) then
        gl.DeleteShader(blurShader or 0)
    end

    -- create blur shaders
    blurShader = gl.CreateShader({
        fragment = [[
		#version 150 compatibility
        uniform sampler2D tex2;
        uniform sampler2D tex0;
        uniform float intensity;

        void main(void)
        {
            vec2 texCoord = vec2(gl_TextureMatrix[0] * gl_TexCoord[0]);
            float stencil = texture2D(tex2, texCoord).a;
            if (stencil<0.01)
            {
                gl_FragColor = texture2D(tex0, texCoord);
                return;
            }
            gl_FragColor = vec4(0.0,0.0,0.0,1.0);

            float sum = 0.0;
            for (int i = -1; i <= 1; ++i)
                for (int j = -1; j <= 1; ++j) {
                    vec2 samplingCoords = texCoord + vec2(i, j) * intensity;
                    float samplingCoordsOk = float( all( greaterThanEqual(samplingCoords, vec2(0.0)) ) && all( lessThanEqual(samplingCoords, vec2(1.0)) ) );
                    gl_FragColor.rgb += texture2D(tex0, samplingCoords).rgb * samplingCoordsOk;
                    sum += samplingCoordsOk;
            }
            gl_FragColor.rgb /= sum;
        }
    ]],

        uniformInt = {
            tex0 = 0,
            tex2 = 2,
        },
        uniformFloat = {
            intensity = blurIntensity,
        }
    })

    if (blurShader == nil) then
        --Spring.Log(widget:GetInfo().name, LOG.ERROR, "guishader blurShader: shader error: "..gl.GetShaderLog())
        --widgetHandler:RemoveWidget(self)
        return false
    end

    -- create blurtextures
    screencopy = gl.CreateTexture(vsx, vsy, {
        border = false,
        min_filter = GL.NEAREST,
        mag_filter = GL.NEAREST,
    })
    blurtex = gl.CreateTexture(ivsx, ivsy, {
        border = false,
        wrap_s = GL.CLAMP,
        wrap_t = GL.CLAMP,
        fbo = true,
    })
    blurtex2 = gl.CreateTexture(ivsx, ivsy, {
        border = false,
        wrap_s = GL.CLAMP,
        wrap_t = GL.CLAMP,
        fbo = true,
    })

    intensityLoc = gl.GetUniformLocation(blurShader, "intensity")
end

function gradientv(px,py,sx,sy, c1,c2)
	gl.Color(c1)
	gl.Vertex(px, sy, 0)
	gl.Vertex(sx, sy, 0)
	gl.Color(c2)
	gl.Vertex(sx, py, 0)
	gl.Vertex(px, py, 0)
end

function gradienth(px,py,sx,sy, c1,c2)
	gl.Color(c1)
	gl.Vertex(sx, sy, 0)
	gl.Vertex(sx, py, 0)
	gl.Color(c2)
	gl.Vertex(px, py, 0)
	gl.Vertex(px, sy, 0)
end

function bartexture(px,py,sx,sy, texLength, texHeight)
	local texHeight = texHeight or 1
	local width = (sx-px) / texLength * 4
	gl.TexCoord(width, texHeight)
	gl.Vertex(sx, sy, 0)
	gl.TexCoord(width, 0)
	gl.Vertex(sx, py, 0)
	gl.TexCoord(0,0)
	gl.Vertex(px, py, 0)
	gl.TexCoord(0,texHeight)
	gl.Vertex(px, sy, 0)
end

local lastLoadMessage = ""
local lastProgress = {0, 0}

local progressByLastLine = {
	["Parsing Map Information"] = {0, 15},
	["Loading GameData Definitions"] = {10, 20},
	["Creating Unit Textures"] = {15, 25},
	["Loading Weapon Definitions"] = {20, 50},
	["Loading LuaRules"] = {40, 80},
	["Loading LuaUI"] = {70, 95},
	["[LoadFinalize] finalizing PFS"] = {80, 95},
	["Finalizing"] = {100, 100}
}
for name,val in pairs(progressByLastLine) do
	progressByLastLine[name] = {val[1]*0.01, val[2]*0.01}
end

function addon.LoadProgress(message, replaceLastLine)
	lastLoadMessage = message
	if message:find("Path") then -- pathing has no rigid messages so cant use the table
		lastProgress = {0.8, 1.0}
	end
	lastProgress = progressByLastLine[message] or lastProgress
end

function addon.DrawLoadScreen()
	local posY = posYorg

	-- tip
	local lineHeight = font2Size * 1.12
	local wrappedTipText, numLines = font2:WrapText(randomTip, vsx * 1.35)
	local tipLines = lines(wrappedTipText)
	local tipPosYtop = posY + (height/vsy)+(borderSize/vsy) + (posY*0.9) + ((lineHeight * #tipLines)/vsy)
	if showTips and not showTipBackground and not showTipAboveBar then
		if #tipLines > 1 then
			posY = posY + ( (lineHeight*0.75/vsy) * (#tipLines-1) )
			tipPosYtop = posY
		else
			tipPosYtop = posY - (lineHeight* 0.2/vsy)
		end
	end

	if guishader then
		if not blurShader then
			CreateShaders()
			guishaderRects['loadprocess1'] = {(posX*vsx)-borderSize, (posY*vsy)-borderSize, (vsx-(posX*vsx))+borderSize, ((posY*vsy)+height+borderSize)}
			if showTips and showTipAboveBar and showTipBackground then
				guishaderRects['loadprocess2'] = {(posX*vsx)-borderSize, ((posY*vsy)+height+borderSize), (vsx-(posX*vsx))+borderSize, tipPosYtop*vsy}
			end
			if usingIntelGpu then
				guishaderRects['loadprocess3'] = {0, 0.95*vsy, vsx,vsy}
			end
			DrawStencilTexture()
		end

		if next(guishaderRects) or next(guishaderDlists) then

			gl.Texture(false)
			gl.Color(1,1,1,1)
			gl.Blending(false)

			gl.CopyToTexture(screencopy, 0, 0, 0, 0, vsx, vsy)
			gl.Texture(screencopy)
			gl.TexRect(0,1,1,0)
			gl.RenderToTexture(blurtex, gl.TexRect, -1,1,1,-1)

			gl.UseShader(blurShader)
			gl.Uniform(intensityLoc, blurIntensity)
			gl.Texture(2,stenciltex)
			gl.Texture(2,false)

			gl.Texture(blurtex)
			gl.RenderToTexture(blurtex2, gl.TexRect, -1,1,1,-1)
			gl.Texture(blurtex2)
			gl.RenderToTexture(blurtex, gl.TexRect, -1,1,1,-1)
			gl.UseShader(0)

			if blurIntensity >= 0.0015 then
				gl.UseShader(blurShader)
				gl.Uniform(intensityLoc, blurIntensity*0.5)

				gl.Texture(blurtex)
				gl.RenderToTexture(blurtex2, gl.TexRect, -1,1,1,-1)
				gl.Texture(blurtex2)
				gl.RenderToTexture(blurtex, gl.TexRect, -1,1,1,-1)
				gl.UseShader(0)
			end

			if blurIntensity >= 0.003 then
				gl.UseShader(blurShader)
				gl.Uniform(intensityLoc, blurIntensity*0.25)

				gl.Texture(blurtex)
				gl.RenderToTexture(blurtex2, gl.TexRect, -1,1,1,-1)
				gl.Texture(blurtex2)
				gl.RenderToTexture(blurtex, gl.TexRect, -1,1,1,-1)
				gl.UseShader(0)
			end

			if blurIntensity >= 0.005 then
				gl.UseShader(blurShader)
				gl.Uniform(intensityLoc, blurIntensity*0.125)

				gl.Texture(blurtex)
				gl.RenderToTexture(blurtex2, gl.TexRect, -1,1,1,-1)
				gl.Texture(blurtex2)
				gl.RenderToTexture(blurtex, gl.TexRect, -1,1,1,-1)
				gl.UseShader(0)
			end

			gl.Texture(blurtex)
			gl.TexRect(0,1,1,0)
			gl.Texture(false)

			gl.Blending(true)
		end
	end

	local loadProgress = SG.GetLoadProgress()
	if loadProgress == 0 then
		loadProgress = lastProgress[1]
	else
		loadProgress = math.min(math.max(loadProgress, lastProgress[1]), lastProgress[2])
	end

	local vsx, vsy = gl.GetViewSizes()

	local loadvalue = math.max(0, loadProgress) * (1-posX-posX)
	loadvalue = math.floor((loadvalue * vsx)+0.5) / vsx

	-- fade away bottom
	if showTips and not showTipBackground then
		gl.BeginEnd(GL.QUADS, gradientv, 0, 0, 1, tipPosYtop+(height*3/vsy), {0,0,0,0}, {0,0,0,0.55})
	end

	-- border
	gl.Color(0,0,0,0.6)
	gl.Rect(posX,posY+(height/vsy),1-posX,posY+((height+borderSize)/vsy))	-- top
	gl.Rect(posX,posY,1-posX,posY-(borderSize/vsy))	-- bottom
	gl.Rect(posX-(borderSize/vsx),posY-(borderSize/vsy),posX,posY+((height+borderSize)/vsy))	-- left
	gl.Rect(1-posX,posY-(borderSize/vsy),(1-posX)+(borderSize/vsx),posY+((height+borderSize)/vsy))	-- right

	-- background
	gl.Color(0.15,0.15,0.15,(blurShader and 0.55 or 0.7))
	gl.Rect(posX+loadvalue,posY,1-posX,posY+(height/vsy))

	-- progress value
	gl.Color((0.4-(loadProgress/7)), (loadProgress*0.35), 0, 0.85)
	gl.Rect(posX,posY,posX+loadvalue,posY+(height)/vsy)

	gl.Blending(GL.SRC_ALPHA, GL.ONE)

	-- background
	gl.Color(0.2,0.2,0.2,0.12)
	gl.Rect(posX,posY,1-posX,posY+(height/vsy))

	-- progress value
	gl.Color((0.45-(loadProgress/7)), (loadProgress*0.38), 0, 0.2)
	gl.BeginEnd(GL.QUADS, gradientv, posX, posY, posX+loadvalue, posY+((height)/vsy), {1,1,1,0.2}, {1,1,1,0})
	gl.BeginEnd(GL.QUADS, gradientv, posX, posY, posX+loadvalue, posY+(((height)*0.3)/vsy), {1,1,1,0}, {1,1,1,0.04})
	-- progress value texture
	gl.Color((0.4-(loadProgress/7)), (loadProgress*0.3), 0, 0.2)
	gl.Texture(':ng:luaui/images/rgbnoise.png')
	gl.BeginEnd(GL.QUADS, bartexture, posX,posY,1-posX,posY+((height)/vsy), (height*7)/vsy, (height*7)/vsy)
	gl.Texture(false)

	-- progress value gloss
	gl.BeginEnd(GL.QUADS, gradientv, posX, posY+(((height)*0.93)/vsy), posX+loadvalue, posY+((height)/vsy), {1,1,1,0.18}, {1,1,1,0})
	gl.BeginEnd(GL.QUADS, gradientv, posX, posY+(((height)*0.77)/vsy), posX+loadvalue, posY+((height)/vsy), {1,1,1,0.15}, {1,1,1,0})
	gl.BeginEnd(GL.QUADS, gradientv, posX, posY+(((height)*0.3)/vsy),  posX+loadvalue, posY+((height)/vsy), {1,1,1,0.15}, {1,1,1,0})
	gl.BeginEnd(GL.QUADS, gradientv, posX, posY, posX+loadvalue, posY+(((height)*0.3)/vsy), {1,1,1,0}, {1,1,1,0.01})

	-- bar gloss
	gl.Color(1,1,1, 0.1)
	gl.BeginEnd(GL.QUADS, gradientv, posX+loadvalue, posY+(((height)*0.93)/vsy), 1-posX, posY+((height)/vsy), {1,1,1,0.12}, {1,1,1,0})
	gl.BeginEnd(GL.QUADS, gradientv, posX+loadvalue, posY+(((height)*0.77)/vsy), 1-posX, posY+((height)/vsy), {1,1,1,0.1}, {1,1,1,0})
	gl.BeginEnd(GL.QUADS, gradientv, posX+loadvalue, posY+(((height)*0.3)/vsy),  1-posX, posY+((height)/vsy), {1,1,1,0.1}, {1,1,1,0})
	gl.BeginEnd(GL.QUADS, gradientv, posX+loadvalue, posY, 1-posX, posY+(((height)*0.3)/vsy), {1,1,1,0}, {1,1,1,0.018})

	gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)

	-- progress text
	gl.PushMatrix()
		gl.Scale(1/vsx,1/vsy,1)
		gl.Translate(vsx/2, (posY*vsy)+(height*0.68), 0)
		local barTextSize = height*0.54
		font:SetTextColor(0.88,0.88,0.88,1)
		font:SetOutlineColor(0,0,0,0.85)
		font:Print(lastLoadMessage, 0, 0, barTextSize, "oac")
	gl.PopMatrix()


	if showTips then

		-- tip background
		if showTipBackground and showTipAboveBar then
			gl.Color(0,0,0,(blurShader and 0.22 or 0.3))
			gl.Rect(posX-(borderSize/vsx), posY+(height/vsy)+(borderSize/vsy), 1-posX+(borderSize/vsx), tipPosYtop)

			gl.BeginEnd(GL.QUADS, gradientv, posX-(borderSize/vsx), posY+(height/vsy)+(borderSize/vsy), 1-posX+(borderSize/vsx), tipPosYtop, {1,1,1,0.045}, {1,1,1,0})
			--gl.BeginEnd(GL.QUADS, gradientv, posX-(borderSize/vsx), tipPosYtop-(height/vsy), 1-posX+(borderSize/vsx), tipPosYtop, {1,1,1,0.04}, {1,1,1,0})
			--gl.Color(0,0,0,0.1)
			--gl.Rect(posX, posY+(height/vsy)+(borderSize/vsy), 1-posX, tipPosYtop-(borderSize/vsy))
		end

		-- tip text
		local barTextSize = height*0.74
		gl.PushMatrix()
		gl.Scale(1/vsx,1/vsy,1)
		gl.Translate(vsx/2, (tipPosYtop*vsy)-(barTextSize*0.75), 0)
		font2:SetTextColor(1,1,1,1)
		font2:SetOutlineColor(0,0,0,0.8)
		for i,line in pairs(tipLines) do
			font2:Print(line, 0, -lineHeight*(i-1), barTextSize, "oac")
		end
		gl.PopMatrix()
	end

	if usingIntelGpu then
		gl.Color(0.15,0.15,0.15,(blurShader and 0.55 or 0.7))
		gl.Rect(0,0.95,1,1)
		gl.PushMatrix()
		gl.Scale(1/vsx,1/vsy,1)
		gl.Translate(vsx/2, 0.988*vsy, 0)
		font2:SetTextColor(0.8,0.8,0.8,1)
		font2:SetOutlineColor(0,0,0,0.8)
		font2:Print('\255\200\200\200You are using the integrated \255\255\255\255Intel graphics\255\200\200\200 card.      Your experience might be sub optimal.', 0, 0, height*0.66, "oac")
		gl.PopMatrix()
	end
end


function addon.MousePress(...)
	--Spring.Echo(...)
end


function addon.Shutdown()
	if guishader then
		for id, dlist in pairs(guishaderDlists) do
			gl.DeleteList(dlist)
		end
		if blurtex then
			gl.DeleteTextureFBO(blurtex)
			gl.DeleteTextureFBO(blurtex2)
			gl.DeleteTextureFBO(stenciltex)
		end
		gl.DeleteTexture(screencopy or 0)
		if (gl.DeleteShader) then
			gl.DeleteShader(blurShader or 0)
		end
		blurShader = nil
	end
	gl.DeleteFont(font)
	gl.DeleteFont(font2)
end
