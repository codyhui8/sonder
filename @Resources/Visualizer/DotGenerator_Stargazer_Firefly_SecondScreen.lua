floor = math.floor
ceil  = math.ceil
sin = math.sin
cos = math.cos
tan = math.tan
pi = math.pi

function Initialize()
	dofile(SKIN:GetVariable('@')..'Visualizer\\MeasureGenerator.lua')
	den = 200-tonumber(SKIN:GetVariable('Stargazer_Density'))
	if den == 0 then den = 1 end
	s = tonumber(SKIN:GetVariable('Stargazer_Speed'))
	dir = tonumber(SKIN:GetVariable('Stargazer_Direction'))
	angle = tonumber(SKIN:GetVariable('Stargazer_Angle')) * pi / 180
	FloatAmount = tonumber(SKIN:GetVariable('Ash_FloatAmount'))

	w = tonumber(SKIN:GetVariable('Stargazer_Width_SecondScreen'))
	h = tonumber(SKIN:GetVariable('Stargazer_Height_SecondScreen'))
	transformh = h * tan(angle) * 2
	h = h + transformh
	m = math.floor(w/den)
	n = math.floor(h/den)
	MeasureGeneratorStargazer(m,tonumber(SKIN:GetVariable('Preview')))

	start = dir == 1 and 0 or w

	dotSize  = tonumber(SKIN:GetVariable('Dot_Max_Size'))
	W_Amount = tonumber(SKIN:GetVariable('Ellipse_W_Scale'))
	H_Amount = tonumber(SKIN:GetVariable('Ellipse_H_Scale'))

	DepthAmountX = tonumber(SKIN:GetVariable('DepthAmount_X'))
	DepthAmountY = tonumber(SKIN:GetVariable('DepthAmount_Y'))

	gradOrient = tonumber(SKIN:GetVariable('GradientOrientation'))
	if gradOrient == 0 then
		VisualizerColor1,VisualizerColor2 = SKIN:GetVariable('VisualizerColor2'),SKIN:GetVariable('VisualizerColor1')
		gradOrient = 0
	elseif gradOrient == 90 then
		VisualizerColor1,VisualizerColor2 = SKIN:GetVariable('VisualizerColor2'),SKIN:GetVariable('VisualizerColor1')
		gradOrient = 1
	elseif gradOrient == 180 then
		VisualizerColor1,VisualizerColor2 = SKIN:GetVariable('VisualizerColor1'),SKIN:GetVariable('VisualizerColor2')
		gradOrient = 0
	else
		VisualizerColor1,VisualizerColor2 = SKIN:GetVariable('VisualizerColor1'),SKIN:GetVariable('VisualizerColor2')
		gradOrient = 1	
	end
	grad1 = {separateRGB(VisualizerColor1)}
	grad2 = {separateRGB(VisualizerColor2)}

	dot = {}
	for i = 1, n do
		dot[i] = {}
		for j = 1, m do
			-- Starter dot locations
			dot[i][j] ={x = math.random(0,w),
						y = math.random(0,h), 
						color = (grad1[1]+(grad2[1]-grad1[1])*(i/n*gradOrient + j/m*(1-gradOrient)))..','..(grad1[2]+(grad2[2]-grad1[2])*(i/n*gradOrient + j/m*(1-gradOrient)))..','..(grad1[3]+(grad2[3]-grad1[3])*(i/n*gradOrient + j/m*(1-gradOrient)))}
		end
	end
	audioMeasure = {}
	for i = 1,m do
		audioMeasure[i] = SKIN:GetMeasure('MeasureAudio'..i..'_SecondScreen')
	end
end

init = true
function Update()
	if not init then clearMod() else init = false end
	shapeCount = 2
	for i = 1, m do
		local audio = audioMeasure[i]:GetValue()
		drawAsh(i, dotSize*audio)
	end
end
speedScaler = 5
function drawAsh(anchorX,scale)
	for i = 1, n do
		dot[i][anchorX].x = dot[i][anchorX].x + dir*s*speedScaler*anchorX/m*audioMeasure[1]:GetValue()
		local xpos = dot[i][anchorX].x
		local ypos = (dot[i][anchorX].y + outSine(dot[i][anchorX].x,0,-FloatAmount,w,anchorX))
		local newxpos = xpos * cos(angle) - ypos * sin(angle)
		local newypos = xpos * sin(angle) + ypos * cos(angle) - transformh
		-- print (xpos .. ', ' .. ypos .. ', ' .. newxpos .. ', ' .. newypos)
		SKIN:Bang('!SetOption Shape Shape'..shapeCount..' "Ellipse '..(newxpos)..','
				..(newypos)..','
				..(scale * anchorX/m * W_Amount)..','..(scale * anchorX/m * H_Amount)..' |StrokeWidth 0 | Fill Color '..dot[i][anchorX].color..'"')
		shapeCount = shapeCount + 1
		if dot[i][anchorX].x > w or dot[i][anchorX].x < 0 then 
			dot[i][anchorX].x = start
			dot[i][anchorX].y = math.random(0,h)
		end
	end
end

function separateRGB(color)
	local rgb = {}
	if color:match(',') then
		for piece in color:gmatch('%d+') do
			table.insert(rgb,tonumber(piece))
		end
	else
		color = color .. 'ffffff'
		for piece in color:gmatch('..') do
			table.insert(rgb,tonumber(piece,16))
		end
	end
	return rgb[1],rgb[2],rgb[3]
end

function clearMod()
	for i=2,shapeCount do
		SKIN:Bang('!SetOption Shape Shape'..i..' "Ellipse 0,0,0,0"')
	end
end

function outSine(t, b, c, d,omega)
  return c * math.sin(t / d * (pi * omega/m*8)) + b
end