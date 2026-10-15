--==================================================================================
--   █████╗ ██████╗  ██████╗ ██╗      ██████╗ ██╗  ██╗██╗███╗   ██╗ ██████╗
--  ██╔══██╗██╔══██╗██╔═══██╗██║     ██╔═══██╗██║ ██╔╝██║████╗  ██║██╔════╝
--  ███████║██████╔╝██║   ██║██║     ██║   ██║█████╔╝ ██║██╔██╗ ██║██║  ███╗
--  ██╔══██║██╔═══╝ ██║   ██║██║     ██║   ██║██╔═██╗ ██║██║╚██╗██║██║   ██║
--  ██║  ██║██║     ╚██████╔╝███████╗╚██████╔╝██║  ██╗██║██║ ╚████║╚██████╔╝
--  ╚═╝  ╚═╝╚═╝      ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝
--
--   APOLOKING [ DMVS ]  |  Anti-Ban Edition  |  v1.2 SOLARA
--   Juego : Murderers VS Sheriffs (DUELS)
--   Tecla : F8 abre / cierra
--   Compatible: Solara, Wave, Volt, Potassium, Synapse, Xeno, Delta, Codex
--==================================================================================

-- entorno global compatible (getgenv puede fallar en Solara)
local GENV = (function()
	local ok, g = pcall(function() return getgenv() end)
	if ok and type(g) == "table" then return g end
	return _G
end)()

if GENV.Apoloking and GENV.Apoloking.Destruir then
	pcall(function() GENV.Apoloking.Destruir() end)
end

--==================================================================================
-- 1) CONFIGURACION
--==================================================================================
local CFG = {
	Nombre     = "APOLOKING [ DMVS ]",
	Subtitulo  = "By Venice  |  Solara Edition",
	Version    = "v1.2",
	Acento     = Color3.fromRGB(0, 226, 255),
	TeclaUI    = Enum.KeyCode.F8,
	Escala     = 1,
	StreamMode = true,
	Watermark  = true,
}

-- Pon aqui tu enlace raw de GitHub. Es la forma MAS confiable de auto-exec.
local AUTOEXEC_URL = "https://raw.githubusercontent.com/malotee/Apoloking.lua/main/Apoloking.lua"

--==================================================================================
-- 2) SERVICIOS
--==================================================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TweenS     = game:GetService("TweenService")
local Stats      = game:GetService("Stats")
local TeleportS  = game:GetService("TeleportService")

local LP = Players.LocalPlayer
while not LP do task.wait() LP = Players.LocalPlayer end

local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if workspace.CurrentCamera then Camera = workspace.CurrentCamera end
end)

local function camara()
	if workspace.CurrentCamera then Camera = workspace.CurrentCamera end
	return Camera
end

local FILTRO_EXCLUIR = Enum.RaycastFilterType.Exclude

local function nuevo(clase, props, padre)
	local obj = Instance.new(clase)
	if props then
		for k, v in pairs(props) do
			if k ~= "Parent" then pcall(function() obj[k] = v end) end
		end
	end
	if padre then
		obj.Parent = padre
	elseif props and props.Parent then
		obj.Parent = props.Parent
	end
	return obj
end

local function redondear(obj, r)
	nuevo("UICorner", { CornerRadius = UDim.new(0, r or 8) }, obj)
	return obj
end

local function borde(obj, color, grosor, trans)
	nuevo("UIStroke", {
		Color = color or Color3.fromRGB(38, 43, 52), Thickness = grosor or 1,
		Transparency = trans or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, obj)
	return obj
end

local function tw(obj, t, props)
	pcall(function() TweenS:Create(obj, t, props):Play() end)
end

local function parentSeguro()
	if gethui then
		local ok, h = pcall(gethui)
		if ok and h then return h end
	end
	local ok, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok and cg and cg:FindFirstChild("RobloxGui") then return cg end
	return LP:WaitForChild("PlayerGui")
end

local function proteger(gui)
	if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
	if protect_gui then pcall(protect_gui, gui) end
end

--==================================================================================
-- 3) TEMA
--==================================================================================
local T = {
	Fondo  = Color3.fromRGB(10, 11, 14), Panel  = Color3.fromRGB(17, 19, 24),
	Panel2 = Color3.fromRGB(23, 26, 32), Panel3 = Color3.fromRGB(30, 34, 42),
	Borde  = Color3.fromRGB(38, 43, 52), Texto  = Color3.fromRGB(236, 241, 246),
	Sub    = Color3.fromRGB(128, 138, 154), Acento = CFG.Acento,
	Verde  = Color3.fromRGB(60, 220, 130), Rojo = Color3.fromRGB(255, 84, 84),
	Azul   = Color3.fromRGB(84, 160, 255),
}

local FUENTE      = Enum.Font.Gotham
local FUENTE_BOLD = Enum.Font.GothamBold
local FUENTE_MED  = Enum.Font.GothamMedium

--==================================================================================
-- 4) INTERFAZ
--==================================================================================
local GUI = nuevo("ScreenGui", {
	Name = "ApolokingUI", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999999,
})

local Root = nuevo("Frame", {
	Name = "Root", Size = UDim2.fromOffset(660, 440),
	Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = T.Fondo, BorderSizePixel = 0, ClipsDescendants = true,
}, GUI)
redondear(Root, 12)
borde(Root, T.Borde, 1)

local EscalaUI = nuevo("UIScale", { Scale = CFG.Escala }, Root)

local Top = nuevo("Frame", {
	Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = T.Panel, BorderSizePixel = 0,
}, Root)

nuevo("TextLabel", {
	Text = CFG.Nombre, Font = FUENTE_BOLD, TextSize = 19, TextColor3 = T.Texto,
	TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
	Position = UDim2.new(0, 18, 0, 7), Size = UDim2.new(0, 330, 0, 20),
}, Top)

nuevo("TextLabel", {
	Text = CFG.Subtitulo, Font = FUENTE, TextSize = 11, TextColor3 = T.Sub,
	TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
	Position = UDim2.new(0, 18, 0, 26), Size = UDim2.new(0, 330, 0, 14),
}, Top)

local function pildora(texto, xPos, color)
	local p = nuevo("Frame", {
		Size = UDim2.fromOffset(74, 26), Position = UDim2.new(1, xPos, 0, 10),
		BackgroundColor3 = T.Panel2, BorderSizePixel = 0,
	}, Top)
	redondear(p, 7)
	borde(p, T.Borde, 1)
	return nuevo("TextLabel", {
		Text = texto, Font = FUENTE_MED, TextSize = 11, TextColor3 = color or T.Texto,
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, p)
end

local okExec, nombreExec = pcall(function()
	if identifyexecutor then return identifyexecutor() end
	return "Executor"
end)
nombreExec = okExec and tostring(nombreExec) or "Executor"

pildora(nombreExec, -196, T.Acento)
pildora("0 FPS", -114, T.Verde)

local function botonVentana(icono, xPos, cb)
	local b = nuevo("TextButton", {
		Text = icono, Font = FUENTE_BOLD, TextSize = 13, TextColor3 = T.Sub,
		BackgroundTransparency = 1, Position = UDim2.new(1, xPos, 0, 12),
		Size = UDim2.fromOffset(22, 22),
	}, Top)
	b.MouseButton1Click:Connect(cb)
	b.MouseEnter:Connect(function() tw(b, 0.12, { TextColor3 = T.Texto }) end)
	b.MouseLeave:Connect(function() tw(b, 0.12, { TextColor3 = T.Sub }) end)
end

botonVentana("—", -72, function()
	local mini = Root:GetAttribute("Mini")
	Root:SetAttribute("Mini", not mini)
	tw(Root, 0.18, { Size = mini and UDim2.fromOffset(660, 440) or UDim2.fromOffset(660, 46) })
end)
botonVentana("□", -46, function()
	local grande = Root:GetAttribute("Grande")
	Root:SetAttribute("Grande", not grande)
	tw(Root, 0.18, { Size = grande and UDim2.fromOffset(660, 440) or UDim2.fromOffset(840, 520) })
end)
botonVentana("✕", -20, function() GUI.Enabled = false end)

local Sidebar = nuevo("Frame", {
	Size = UDim2.new(0, 158, 1, -46), Position = UDim2.new(0, 0, 0, 46),
	BackgroundColor3 = T.Fondo, BorderSizePixel = 0,
}, Root)
nuevo("UIListLayout", {
	Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, Sidebar)
nuevo("UIPadding", { PaddingTop = UDim.new(0, 10) }, Sidebar)

local Contenido = nuevo("Frame", {
	Size = UDim2.new(1, -158, 1, -46), Position = UDim2.new(0, 158, 0, 46),
	BackgroundColor3 = T.Panel, BorderSizePixel = 0,
}, Root)

local CirculoFOV, Watermark, RefrescarAcento, BtnGUI

local Paginas, Botones = {}, {}

local function crearPagina(nombre, icono)
	local btn = nuevo("TextButton", {
		Size = UDim2.new(1, -20, 0, 34), BackgroundColor3 = T.Panel,
		BorderSizePixel = 0, Text = "", AutoButtonColor = false,
	}, Sidebar)
	redondear(btn, 8)

	local marca = nuevo("Frame", {
		Size = UDim2.fromOffset(3, 16), Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = T.Acento,
		BorderSizePixel = 0, Visible = false,
	}, btn)
	redondear(marca, 2)

	local ic = nuevo("TextLabel", {
		Text = icono, Font = FUENTE_MED, TextSize = 15, TextColor3 = T.Sub,
		BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0),
		Size = UDim2.new(0, 20, 1, 0),
	}, btn)

	local tx = nuevo("TextLabel", {
		Text = nombre, Font = FUENTE_MED, TextSize = 12, TextColor3 = T.Sub,
		BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0),
		Size = UDim2.new(1, -46, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
	}, btn)

	local pagina = {
		Nombre = nombre,
		Marco = nuevo("ScrollingFrame", {
			Size = UDim2.new(1, -24, 1, -24), Position = UDim2.new(0, 12, 0, 12),
			BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
			ScrollBarImageColor3 = T.Acento, CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
		}, Contenido),
	}
	nuevo("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, pagina.Marco)

	Paginas[nombre] = pagina
	Botones[nombre] = { btn = btn, marca = marca, ic = ic, tx = tx }

	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(Paginas) do p.Marco.Visible = false end
		for _, b in pairs(Botones) do
			b.marca.Visible = false
			tw(b.btn, 0.12, { BackgroundColor3 = T.Panel })
			tw(b.ic, 0.12, { TextColor3 = T.Sub })
			tw(b.tx, 0.12, { TextColor3 = T.Sub })
		end
		pagina.Marco.Visible = true
		marca.Visible = true
		tw(btn, 0.12, { BackgroundColor3 = T.Panel2 })
		tw(ic, 0.12, { TextColor3 = T.Acento })
		tw(tx, 0.12, { TextColor3 = T.Texto })
	end)

	btn.MouseEnter:Connect(function()
		if not pagina.Marco.Visible then tw(btn, 0.1, { BackgroundColor3 = T.Panel2 }) end
	end)
	btn.MouseLeave:Connect(function()
		if not pagina.Marco.Visible then tw(btn, 0.1, { BackgroundColor3 = T.Panel }) end
	end)

	function pagina:Seccion(texto)
		local l = nuevo("TextLabel", {
			Text = "◈  " .. texto, Font = FUENTE_BOLD, TextSize = 11, TextColor3 = T.Sub,
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
			TextXAlignment = Enum.TextXAlignment.Left,
		}, self.Marco)
		l:SetAttribute("AcentoTexto", true)
		return l
	end

	function pagina:Label(titulo, desc)
		local f = nuevo("Frame", {
			Size = UDim2.new(1, 0, 0, desc and 46 or 34),
			BackgroundColor3 = T.Panel2, BorderSizePixel = 0,
		}, self.Marco)
		redondear(f, 8)
		nuevo("TextLabel", {
			Text = titulo, Font = FUENTE_MED, TextSize = 13, TextColor3 = T.Texto,
			BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, desc and 6 or 0),
			Size = UDim2.new(1, -24, 0, 18), TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, f)
		if desc then
			nuevo("TextLabel", {
				Text = desc, Font = FUENTE, TextSize = 11, TextColor3 = T.Sub,
				BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 24),
				Size = UDim2.new(1, -24, 0, 16), TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, f)
		end
		return f
	end

	function pagina:Toggle(titulo, desc, porDefecto, cb)
		local estado = porDefecto and true or false
		local f = nuevo("Frame", {
			Size = UDim2.new(1, 0, 0, desc and 48 or 38),
			BackgroundColor3 = T.Panel2, BorderSizePixel = 0,
		}, self.Marco)
		redondear(f, 8)

		nuevo("TextLabel", {
			Text = titulo, Font = FUENTE_MED, TextSize = 13, TextColor3 = T.Texto,
			BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, desc and 6 or 0),
			Size = UDim2.new(1, -80, 0, 18), TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, f)
		if desc then
			nuevo("TextLabel", {
				Text = desc, Font = FUENTE, TextSize = 11, TextColor3 = T.Sub,
				BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 24),
				Size = UDim2.new(1, -80, 0, 16), TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, f)
		end

		local sw = nuevo("Frame", {
			Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -52, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = T.Panel3, BorderSizePixel = 0,
		}, f)
		redondear(sw, 10)

		local bol = nuevo("Frame", {
			Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 3, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = T.Sub, BorderSizePixel = 0,
		}, sw)
		redondear(bol, 7)

		local click = nuevo("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, f)

		local function pintar()
			if estado then
				tw(sw, 0.15, { BackgroundColor3 = T.Acento })
				tw(bol, 0.15, { Position = UDim2.new(1, -17, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1) })
			else
				tw(sw, 0.15, { BackgroundColor3 = T.Panel3 })
				tw(bol, 0.15, { Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = T.Sub })
			end
		end

		local api = {}
		function api.Set(v, silencioso)
			estado = v and true or false
			pintar()
			if not silencioso and cb then task.spawn(cb, estado, false) end
		end
		function api.Get() return estado end

		click.MouseButton1Click:Connect(function() api.Set(not estado) end)
		pintar()
		if cb then task.spawn(cb, estado, true) end
		return api
	end

	function pagina:Slider(titulo, min, max, porDefecto, dec, cb)
		local f = nuevo("Frame", {
			Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = T.Panel2, BorderSizePixel = 0,
		}, self.Marco)
		redondear(f, 8)

		nuevo("TextLabel", {
			Text = titulo, Font = FUENTE_MED, TextSize = 13, TextColor3 = T.Texto,
			BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6),
			Size = UDim2.new(1, -80, 0, 18), TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, f)

		local val = nuevo("TextLabel", {
			Text = tostring(porDefecto), Font = FUENTE_MED, TextSize = 12, TextColor3 = T.Acento,
			BackgroundTransparency = 1, Position = UDim2.new(1, -60, 0, 6),
			Size = UDim2.new(0, 48, 0, 18), TextXAlignment = Enum.TextXAlignment.Right,
		}, f)
		val:SetAttribute("AcentoTexto", true)

		local pista = nuevo("Frame", {
			Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 38),
			BackgroundColor3 = T.Fondo, BorderSizePixel = 0,
		}, f)
		redondear(pista, 3)

		local lleno = nuevo("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = T.Acento, BorderSizePixel = 0 }, pista)
		redondear(lleno, 3)

		local bola = nuevo("Frame", {
			Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		}, pista)
		redondear(bola, 7)

		local actual = porDefecto
		local arrastrando = false

		local function pintar(alpha)
			lleno.Size = UDim2.new(alpha, 0, 1, 0)
			bola.Position = UDim2.new(alpha, 0, 0.5, 0)
		end

		local function setValor(v, disparar)
			v = math.clamp(v, min, max)
			if dec and dec > 0 then
				v = tonumber(string.format("%." .. dec .. "f", v))
			else
				v = math.floor(v + 0.5)
			end
			actual = v
			val.Text = tostring(v)
			pintar((v - min) / (max - min))
			if disparar and cb then task.spawn(cb, v) end
		end

		local zona = nuevo("TextButton", {
			Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.new(0, 0, 0, 28),
		}, f)

		zona.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				arrastrando = true
				local x = UIS:GetMouseLocation().X
				setValor(min + (max - min) * math.clamp((x - pista.AbsolutePosition.X) / math.max(pista.AbsoluteSize.X, 1), 0, 1), true)
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if arrastrando and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local x = UIS:GetMouseLocation().X
				setValor(min + (max - min) * math.clamp((x - pista.AbsolutePosition.X) / math.max(pista.AbsoluteSize.X, 1), 0, 1), true)
			end
		end)
		UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				arrastrando = false
			end
		end)

		pintar((porDefecto - min) / (max - min))
		return { Set = function(v, s) setValor(v, not s) end, Get = function() return actual end }
	end

	function pagina:Button(titulo, desc, cb)
		local f = nuevo("Frame", {
			Size = UDim2.new(1, 0, 0, desc and 48 or 36),
			BackgroundColor3 = T.Panel2, BorderSizePixel = 0,
		}, self.Marco)
		redondear(f, 8)
		nuevo("TextLabel", {
			Text = titulo, Font = FUENTE_MED, TextSize = 13, TextColor3 = T.Texto,
			BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, desc and 6 or 0),
			Size = UDim2.new(1, -40, 0, 18), TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, f)
		if desc then
			nuevo("TextLabel", {
				Text = desc, Font = FUENTE, TextSize = 11, TextColor3 = T.Sub,
				BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 24),
				Size = UDim2.new(1, -40, 0, 16), TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, f)
		end
		local fl = nuevo("TextLabel", {
			Text = "›", Font = FUENTE_BOLD, TextSize = 18, TextColor3 = T.Sub,
			BackgroundTransparency = 1, Position = UDim2.new(1, -28, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(20, 20),
		}, f)
		local b = nuevo("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, f)
		b.MouseEnter:Connect(function() tw(f, 0.12, { BackgroundColor3 = T.Panel3 }); tw(fl, 0.12, { TextColor3 = T.Acento }) end)
		b.MouseLeave:Connect(function() tw(f, 0.12, { BackgroundColor3 = T.Panel2 }); tw(fl, 0.12, { TextColor3 = T.Sub }) end)
		b.MouseButton1Click:Connect(function() if cb then task.spawn(cb) end end)
		return f
	end

	function pagina:Dropdown(titulo, desc, opciones, defecto, cb)
		local f = nuevo("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = T.Panel2, BorderSizePixel = 0,
		}, self.Marco)
		redondear(f, 8)
		nuevo("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, f)
		nuevo("UIPadding", {
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		}, f)

		local cab = nuevo("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1 }, f)
		nuevo("TextLabel", {
			Text = titulo, Font = FUENTE_MED, TextSize = 13, TextColor3 = T.Texto,
			BackgroundTransparency = 1, Size = UDim2.new(1, -100, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		}, cab)
		local valorLbl = nuevo("TextLabel", {
			Text = tostring(defecto), Font = FUENTE_MED, TextSize = 12, TextColor3 = T.Acento,
			BackgroundTransparency = 1, Size = UDim2.new(0, 90, 1, 0),
			Position = UDim2.new(1, -90, 0, 0), TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, cab)
		valorLbl:SetAttribute("AcentoTexto", true)

		if desc and desc ~= "" then
			nuevo("TextLabel", {
				Text = desc, Font = FUENTE, TextSize = 11, TextColor3 = T.Sub,
				BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
				TextXAlignment = Enum.TextXAlignment.Left,
			}, f)
		end

		local lista = nuevo("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Visible = false,
		}, f)
		nuevo("UIListLayout", { Padding = UDim.new(0, 3) }, lista)

		local api = {}
		local actual = defecto
		function api.Set(v, silencioso)
			actual = v
			valorLbl.Text = tostring(v)
			if not silencioso and cb then task.spawn(cb, v) end
		end
		function api.Get() return actual end

		for _, op in ipairs(opciones) do
			local ob = nuevo("TextButton", {
				Text = tostring(op), Font = FUENTE_MED, TextSize = 12, TextColor3 = T.Texto,
				BackgroundColor3 = T.Panel3, BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 24), AutoButtonColor = false,
			}, lista)
			redondear(ob, 6)
			ob.MouseButton1Click:Connect(function()
				api.Set(op)
				lista.Visible = false
			end)
			ob.MouseEnter:Connect(function() tw(ob, 0.1, { BackgroundColor3 = T.Acento, TextColor3 = T.Fondo }) end)
			ob.MouseLeave:Connect(function() tw(ob, 0.1, { BackgroundColor3 = T.Panel3, TextColor3 = T.Texto }) end)
		end

		local zona = nuevo("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22) }, cab)
		zona.MouseButton1Click:Connect(function() lista.Visible = not lista.Visible end)

		return api
	end

	function pagina:Keybind(titulo, desc, defecto, cb)
		local f = nuevo("Frame", {
			Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.Panel2, BorderSizePixel = 0,
		}, self.Marco)
		redondear(f, 8)
		nuevo("TextLabel", {
			Text = titulo, Font = FUENTE_MED, TextSize = 13, TextColor3 = T.Texto,
			BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -110, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, f)
		local key = defecto
		local lbl = nuevo("TextButton", {
			Text = key and key.Name or "Ninguna", Font = FUENTE_MED, TextSize = 12,
			TextColor3 = T.Acento, BackgroundColor3 = T.Panel3, BorderSizePixel = 0,
			Position = UDim2.new(1, -96, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(84, 24),
		}, f)
		lbl:SetAttribute("AcentoTexto", true)
		redondear(lbl, 6)

		local esperando, desde = false, 0
		lbl.MouseButton1Click:Connect(function()
			esperando = true
			desde = os.clock()
			lbl.Text = "..."
		end)

		UIS.InputBegan:Connect(function(i)
			if not esperando then return end
			if os.clock() - desde < 0.2 then return end
			local capturado
			if i.KeyCode ~= Enum.KeyCode.Unknown then
				capturado = i.KeyCode
			elseif i.UserInputType == Enum.UserInputType.MouseButton1
				or i.UserInputType == Enum.UserInputType.MouseButton2
				or i.UserInputType == Enum.UserInputType.MouseButton3 then
				capturado = i.UserInputType
			else
				return
			end
			key = capturado
			lbl.Text = capturado.Name
			esperando = false
			if cb then task.spawn(cb, capturado) end
		end)

		return { Get = function() return key end, Set = function(k) key = k; lbl.Text = k and k.Name or "Ninguna" end }
	end

	function pagina:ColorPicker(titulo)
		local f = nuevo("Frame", {
			Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = T.Panel2, BorderSizePixel = 0,
		}, self.Marco)
		redondear(f, 8)
		nuevo("TextLabel", {
			Text = titulo, Font = FUENTE_MED, TextSize = 13, TextColor3 = T.Texto,
			BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 5),
			Size = UDim2.new(1, -60, 0, 18), TextXAlignment = Enum.TextXAlignment.Left,
		}, f)
		local colores = {
			Color3.fromRGB(0, 226, 255), Color3.fromRGB(57, 255, 136),
			Color3.fromRGB(168, 85, 247), Color3.fromRGB(255, 77, 157),
			Color3.fromRGB(255, 165, 61), Color3.fromRGB(255, 77, 77),
			Color3.fromRGB(229, 231, 235),
		}
		for i, c in ipairs(colores) do
			local b = nuevo("TextButton", {
				Text = "", BackgroundColor3 = c, BorderSizePixel = 0,
				Position = UDim2.new(0, 12 + (i - 1) * 26, 0, 26),
				Size = UDim2.fromOffset(20, 20),
			}, f)
			redondear(b, 6)
			b.MouseButton1Click:Connect(function()
				T.Acento = c
				CFG.Acento = c
				if RefrescarAcento then RefrescarAcento() end
			end)
		end
		return f
	end

	return pagina
end

function RefrescarAcento()
	local contenedores = { Root }
	if BtnGUI then table.insert(contenedores, BtnGUI) end
	for _, cont in ipairs(contenedores) do
		for _, obj in ipairs(cont:GetDescendants()) do
			if obj:GetAttribute("AcentoTexto") then
				pcall(function() obj.TextColor3 = T.Acento end)
			end
			if obj:GetAttribute("AcentoFondo") then
				pcall(function() obj.BackgroundColor3 = T.Acento end)
			end
		end
	end
	if CirculoFOV then pcall(function() CirculoFOV.UIStroke.Color = T.Acento end) end
	if Watermark then Watermark.TextColor3 = T.Acento end
end

do
	local arrastrando, ini, iniPos = false, nil, nil
	Top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			arrastrando = true
			ini = UIS:GetMouseLocation()
			iniPos = Root.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if arrastrando and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = UIS:GetMouseLocation() - ini
			Root.Position = UDim2.new(iniPos.X.Scale, iniPos.X.Offset + d.X, iniPos.Y.Scale, iniPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			arrastrando = false
		end
	end)
end

--==================================================================================
-- 5) AVISOS
--==================================================================================
local Avisos = nuevo("Frame", {
	Size = UDim2.new(0, 250, 1, -60), Position = UDim2.new(1, -262, 0, 52),
	BackgroundTransparency = 1, ZIndex = 20,
}, GUI)
nuevo("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Right }, Avisos)

local function aviso(titulo, texto, dur)
	local f = nuevo("Frame", {
		Size = UDim2.new(1, 0, 0, texto and 54 or 38),
		BackgroundColor3 = T.Panel, BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 21,
	}, Avisos)
	redondear(f, 8)
	local st = borde(f, T.Borde, 1)
	st.Transparency = 1

	local barra = nuevo("Frame", {
		Size = UDim2.fromOffset(3, 16), Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = T.Acento, BorderSizePixel = 0,
	}, f)
	redondear(barra, 2)
	barra:SetAttribute("AcentoFondo", true)

	local t1 = nuevo("TextLabel", {
		Text = titulo, Font = FUENTE_BOLD, TextSize = 12, TextColor3 = T.Texto,
		BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 6),
		Size = UDim2.new(1, -20, 0, 16), TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1, TextTruncate = Enum.TextTruncate.AtEnd,
	}, f)

	local t2
	if texto then
		t2 = nuevo("TextLabel", {
			Text = texto, Font = FUENTE, TextSize = 11, TextColor3 = T.Sub,
			BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 24),
			Size = UDim2.new(1, -20, 0, 24), TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true, TextTransparency = 1,
		}, f)
	end

	tw(f, 0.25, { BackgroundTransparency = 0 })
	tw(st, 0.25, { Transparency = 0 })
	tw(t1, 0.25, { TextTransparency = 0 })
	if t2 then tw(t2, 0.25, { TextTransparency = 0 }) end

	task.delay(dur or 3, function()
		tw(f, 0.25, { BackgroundTransparency = 1 })
		tw(st, 0.25, { Transparency = 1 })
		tw(t1, 0.25, { TextTransparency = 1 })
		if t2 then tw(t2, 0.25, { TextTransparency = 1 }) end
		task.wait(0.3)
		if f then f:Destroy() end
	end)
end

--==================================================================================
-- 6) PAGINAS
--==================================================================================
local PagInfo   = crearPagina("Info", "ⓘ")
local PagConfig = crearPagina("Config", "⚙")
local PagAimbot = crearPagina("DotShot", "◉")
local PagCam    = crearPagina("CamLock", "◎")
local PagESP    = crearPagina("ESP", "▣")
local PagHitbox = crearPagina("Hitbox", "▤")
local PagAnti   = crearPagina("Anti-Ban", "✦")
local PagTools  = crearPagina("Tools", "⚒")

--==================================================================================
-- 7) MODULOS
--==================================================================================
local function rolDe(plr)
	local char = plr.Character
	if not char then return "Inocente" end
	local function buscar(cont)
		for _, t in ipairs(cont:GetChildren()) do
			local n = string.lower(t.Name)
			if string.find(n, "knife") or string.find(n, "cuchillo") then return "Asesino" end
			if string.find(n, "gun") or string.find(n, "revolver") or string.find(n, "pistol") then return "Sheriff" end
		end
	end
	local r = buscar(char)
	if r then return r end
	local mochila = plr:FindFirstChildOfClass("Backpack")
	if mochila then r = buscar(mochila) end
	return r or "Inocente"
end

local COLOR_ROL = {
	Asesino  = Color3.fromRGB(255, 72, 72),
	Sheriff  = Color3.fromRGB(72, 150, 255),
	Inocente = Color3.fromRGB(225, 232, 240),
}

local function vivo(plr)
	local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	return h and h.Health > 0
end

local function mismoEquipo(plr)
	if LP.Team and plr.Team then return plr.Team == LP.Team end
	return false
end

local function parteObjetivo(char, prioridad)
	if prioridad and char:FindFirstChild(prioridad) then return char[prioridad] end
	return char:FindFirstChild("HumanoidRootPart")
end

local function hayPared(desde, hacia, lista)
	local params = RaycastParams.new()
	params.FilterType = FILTRO_EXCLUIR
	params.IgnoreWater = true
	params.FilterDescendantsInstances = lista
	return workspace:Raycast(desde, hacia - desde, params) ~= nil
end

local function teclaCoincide(input, tecla)
	if not tecla then return false end
	local ok, tipo = pcall(function() return typeof(tecla) end)
	if not ok or tipo ~= "EnumItem" then return false end
	if tecla.EnumType == Enum.KeyCode then return input.KeyCode == tecla end
	if tecla.EnumType == Enum.UserInputType then return input.UserInputType == tecla end
	return false
end

--==================================================================================
-- 7.1) ESP
--==================================================================================
local ESP = {
	Activo = false, Resaltado = true, Caja = false, Nombre = true,
	Distancia = true, Tracer = false, Roles = true, MaxDist = 500, IgnorarLocal = true,
}

local ESP_Objetos = {}
local Tracers = {}

local function limpiarESP()
	for _, d in pairs(ESP_Objetos) do
		pcall(function() if d.hl then d.hl:Destroy() end end)
		pcall(function() if d.tag then d.tag:Destroy() end end)
		pcall(function() if d.box then d.box:Destroy() end end)
	end
	ESP_Objetos = {}
	for _, t in pairs(Tracers) do pcall(function() t.Visible = false end) end
end

local function crearESP(plr)
	if ESP_Objetos[plr] then return end
	if ESP.IgnorarLocal and plr == LP then return end
	local char = plr.Character
	if not char then return end

	local datos = {}
	ESP_Objetos[plr] = datos
	local rol = rolDe(plr)
	local color = ESP.Roles and COLOR_ROL[rol] or T.Acento

	if ESP.Resaltado then
		datos.hl = nuevo("Highlight", {
			Adornee = char, FillColor = color, OutlineColor = color,
			FillTransparency = CFG.StreamMode and 0.62 or 0.78,
			OutlineTransparency = 0.35,
		}, char)
	end

	if ESP.Nombre or ESP.Distancia then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local bb = nuevo("BillboardGui", {
				Size = UDim2.fromOffset(180, 34), StudsOffset = Vector3.new(0, 2.6, 0),
				AlwaysOnTop = true,
			}, hrp)
			datos.tag = bb
			datos.nombreLbl = nuevo("TextLabel", {
				Text = plr.Name, Font = FUENTE_BOLD, TextSize = 12, TextColor3 = color,
				BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
				TextStrokeTransparency = 0.4, TextStrokeColor3 = Color3.new(0, 0, 0),
			}, bb)
			datos.subLbl = nuevo("TextLabel", {
				Text = "", Font = FUENTE_MED, TextSize = 10, TextColor3 = color,
				BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 16),
				Size = UDim2.new(1, 0, 0, 14),
				TextStrokeTransparency = 0.4, TextStrokeColor3 = Color3.new(0, 0, 0),
			}, bb)
		end
	end

	if ESP.Caja then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			datos.box = nuevo("BoxHandleAdornment", {
				Adornee = hrp, Size = Vector3.new(3, 6, 2), Color3 = color,
				Transparency = 0.55, AlwaysOnTop = true, ZIndex = 5,
			}, hrp)
		end
	end
end

local function refrescarESP()
	limpiarESP()
	if not ESP.Activo then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if vivo(plr) then pcall(crearESP, plr) end
	end
	if ESP.Tracer then
		for _, plr in ipairs(Players:GetPlayers()) do
			if vivo(plr) and not (ESP.IgnorarLocal and plr == LP) then
				if not Tracers[plr] then
					Tracers[plr] = nuevo("Frame", {
						BackgroundColor3 = T.Acento, BorderSizePixel = 0,
						Size = UDim2.new(0, 1, 0, 1), AnchorPoint = Vector2.new(0.5, 0.5),
						ZIndex = 0, Visible = true,
					}, GUI)
				end
				Tracers[plr].Visible = true
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if not ESP.Activo then return end
	local cam = camara()
	if not cam then return end

	for plr, d in pairs(ESP_Objetos) do
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end
		local dist = (hrp.Position - cam.CFrame.Position).Magnitude

		if d.subLbl then
			local txt = ""
			if ESP.Nombre then txt = plr.Name end
			if ESP.Distancia then txt = (txt ~= "" and (txt .. "  |  ") or "") .. math.floor(dist) .. "m" end
			if ESP.Roles then txt = "[" .. rolDe(plr) .. "]  " .. txt end
			d.subLbl.Text = txt
		end
		if d.hl then d.hl.Enabled = dist <= ESP.MaxDist end
		if d.box then d.box.Transparency = dist <= ESP.MaxDist and 0.55 or 1 end
	end

	if ESP.Tracer then
		local vista = cam.ViewportSize
		local origen = Vector2.new(vista.X / 2, vista.Y)
		for plr, ln in pairs(Tracers) do
			local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if ln.Visible and hrp then
				local sp, enPantalla = cam:WorldToViewportPoint(hrp.Position)
				if enPantalla and sp.Z > 0 then
					local destino = Vector2.new(sp.X, sp.Y)
					local delta = destino - origen
					ln.Position = UDim2.fromOffset((origen.X + destino.X) / 2, (origen.Y + destino.Y) / 2)
					ln.Size = UDim2.fromOffset(math.max(delta.Magnitude, 1), 1)
					ln.Rotation = math.deg(math.atan2(delta.Y, delta.X))
					ln.BackgroundColor3 = ESP.Roles and COLOR_ROL[rolDe(plr)] or T.Acento
				end
			end
		end
	end
end)

--==================================================================================
-- 7.2) AIMBOT
--==================================================================================
local Aimbot = {
	Activo = false, Tecla = Enum.UserInputType.MouseButton2, ModoTecla = "Mantener",
	FOV = 140, Suavizado = 0.22, Parte = "Head", Prediccion = 0.12,
	TeamCheck = false, ParedCheck = false, MaxDist = 600, MostrarFOV = true,
	SoloClick = false, Prioridad = "Nadie",
}

local teclaApretada, alternarActivo, clickApretado = false, false, false

CirculoFOV = nuevo("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(280, 280), BackgroundTransparency = 1,
	Visible = false, ZIndex = 0,
}, GUI)
nuevo("UICorner", { CornerRadius = UDim.new(1, 0) }, CirculoFOV)
nuevo("UIStroke", { Color = T.Acento, Thickness = 1, Transparency = 0.4 }, CirculoFOV)

local function objetivoValido()
	local cam = camara()
	if not cam then return nil end
	local centro = cam.ViewportSize / 2
	local mejor, mejorPunt = nil, math.huge
	local yo = LP.Character

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and vivo(plr) then
			if not (Aimbot.TeamCheck and mismoEquipo(plr)) then
				local char = plr.Character
				local parte = parteObjetivo(char, Aimbot.Parte)
				if parte then
					local dist = (parte.Position - cam.CFrame.Position).Magnitude
					if dist <= Aimbot.MaxDist then
						local sp, enPantalla = cam:WorldToViewportPoint(parte.Position)
						if enPantalla and sp.Z > 0 then
							local d = (Vector2.new(sp.X, sp.Y) - centro).Magnitude
							if d <= Aimbot.FOV then
								local punt = d
								if Aimbot.Prioridad ~= "Nadie" and rolDe(plr) == Aimbot.Prioridad then
									punt = punt * 0.35
								end
								if Aimbot.ParedCheck then
									local lista = {}
									if yo then table.insert(lista, yo) end
									if char then table.insert(lista, char) end
									punt = punt * (hayPared(cam.CFrame.Position, parte.Position, lista) and 1.6 or 0.7)
								end
								if punt < mejorPunt then mejor, mejorPunt = plr, punt end
							end
						end
					end
				end
			end
		end
	end
	return mejor
end

local function posicionPredicha(plr)
	local char = plr.Character
	local parte = parteObjetivo(char, Aimbot.Parte)
	if not parte then return nil end
	if Aimbot.Prediccion <= 0 then return parte.Position end
	return parte.Position + (parte.AssemblyLinearVelocity * Aimbot.Prediccion)
end

UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if teclaCoincide(i, Aimbot.Tecla) then
		if Aimbot.ModoTecla == "Alternar" then alternarActivo = not alternarActivo else teclaApretada = true end
	end
	if i.UserInputType == Enum.UserInputType.MouseButton1 then clickApretado = true end
end)

UIS.InputEnded:Connect(function(i)
	if teclaCoincide(i, Aimbot.Tecla) then teclaApretada = false end
	if i.UserInputType == Enum.UserInputType.MouseButton1 then clickApretado = false end
end)

RunService.RenderStepped:Connect(function(dt)
	CirculoFOV.Visible = Aimbot.Activo and Aimbot.MostrarFOV
	if CirculoFOV.Visible then
		local cam = camara()
		if cam then
			local esc = cam.ViewportSize.Y / 1080
			CirculoFOV.Size = UDim2.fromOffset(math.max(Aimbot.FOV * 2 * esc, 40), math.max(Aimbot.FOV * 2 * esc, 40))
		end
	end

	if not Aimbot.Activo then return end
	local activo = (Aimbot.ModoTecla == "Alternar") and alternarActivo or teclaApretada
	if Aimbot.SoloClick and not clickApretado then activo = false end
	if not activo then return end

	local objetivo = objetivoValido()
	if not objetivo then return end
	local destino = posicionPredicha(objetivo)
	if not destino then return end

	local cam = camara()
	if not cam then return end
	local alpha = math.clamp(dt / math.max(Aimbot.Suavizado, 0.001), 0.02, 1)
	cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, destino), alpha)
end)

--==================================================================================
-- 7.3) CAMLOCK
--==================================================================================
local CamLock = {
	Activo = false, Tecla = Enum.KeyCode.C, ModoTecla = "Mantener",
	Distancia = 12, Altura = 3, Suavizado = 0.25,
}

local camTecla, camAlt = false, false

UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == CamLock.Tecla then
		if CamLock.ModoTecla == "Alternar" then camAlt = not camAlt else camTecla = true end
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.KeyCode == CamLock.Tecla then camTecla = false end
end)

RunService.RenderStepped:Connect(function(dt)
	if not CamLock.Activo then return end
	local activo = (CamLock.ModoTecla == "Alternar") and camAlt or camTecla
	if not activo then return end

	local objetivo = objetivoValido()
	if not objetivo then return end
	local char = objetivo.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local cam = camara()
	if not cam then return end
	local offset = hrp.CFrame * CFrame.new(0, CamLock.Altura, CamLock.Distancia)
	local alpha = math.clamp(dt / math.max(CamLock.Suavizado, 0.001), 0.02, 1)
	cam.CFrame = cam.CFrame:Lerp(CFrame.new(offset.Position, hrp.Position), alpha)
end)

--==================================================================================
-- 7.4) HITBOX
--==================================================================================
local Hitbox = {
	Activo = false, Escala = 5, Parte = "HumanoidRootPart",
	Intervalo = 0.15, IncluirLocal = true,
}

local originales = setmetatable({}, { __mode = "k" })

local function partesHitbox(char)
	if Hitbox.Parte == "Ambos" then
		local t = {}
		if char:FindFirstChild("HumanoidRootPart") then table.insert(t, char.HumanoidRootPart) end
		if char:FindFirstChild("Head") then table.insert(t, char.Head) end
		return t
	end
	local p = char:FindFirstChild(Hitbox.Parte)
	return p and { p } or {}
end

local function aplicarHitbox()
	for _, plr in ipairs(Players:GetPlayers()) do
		if Hitbox.IncluirLocal or plr ~= LP then
			local char = plr.Character
			if char then
				for _, parte in ipairs(partesHitbox(char)) do
					if parte:IsA("BasePart") then
						if not originales[parte] then originales[parte] = parte.Size end
						local o = originales[parte]
						local nuevoTam = Vector3.new(o.X * Hitbox.Escala, o.Y * Hitbox.Escala, o.Z * Hitbox.Escala)
						if (parte.Size - nuevoTam).Magnitude > 0.01 then
							pcall(function() parte.Size = nuevoTam end)
						end
					end
				end
			end
		end
	end
end

local function restaurarHitbox()
	for parte, tam in pairs(originales) do
		if parte and parte.Parent then pcall(function() parte.Size = tam end) end
	end
	table.clear(originales)
end

task.spawn(function()
	while true do
		task.wait(Hitbox.Intervalo)
		if Hitbox.Activo then pcall(aplicarHitbox) end
	end
end)

--==================================================================================
-- 7.5) SEGURIDAD  (reescrito para Solara)
--==================================================================================
local Seg = {
	AntiAFK = false, AntiKick = false, AutoRejoin = false,
	ProtegerGUI = false, HookMeta = false, RateLimit = true,
}

local conexionAFK
local function activarAntiAFK()
	if conexionAFK then pcall(function() conexionAFK:Disconnect() end) end
	if not Seg.AntiAFK then return end
	conexionAFK = LP.Idled:Connect(function()
		pcall(function()
			local vu = game:GetService("VirtualUser")
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end)
	end)
end

-- ---------- ANTI-KICK ----------
-- Metodo 1: AncestryChanged (API pura de Roblox, funciona en TODOS los ejecutores)
-- Metodo 2: sondeo de respaldo
-- Metodo 3: hook de metatabla (opcional, requiere getnamecallmethod que Solara NO tiene)
local kickeado = false

local function alSerKickeado(motivo)
	if kickeado then return end
	kickeado = true
	aviso("Kick detectado", tostring(motivo or "Expulsado"), 5)
	if not Seg.AntiKick then return end

	task.delay(0.05, function()
		local ok = pcall(function()
			if game.JobId and game.JobId ~= "" then
				TeleportS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
			else
				TeleportS:Teleport(game.PlaceId, LP)
			end
		end)
		if not ok then
			pcall(function() TeleportS:Teleport(game.PlaceId, LP) end)
		end
	end)
end

local function vigilarKick()
	LP.AncestryChanged:Connect(function(_, padre)
		if not padre then task.spawn(alSerKickeado, "Desconectado del servidor") end
	end)

	task.spawn(function()
		while true do
			task.wait(0.25)
			if not LP.Parent and not kickeado then
				task.spawn(alSerKickeado, "Desconectado del servidor")
			end
		end
	end)
end

local metodoAntiKick = "AncestryChanged"

local function instalarHookMeta()
	local ok = pcall(function()
		if not (getrawmetatable and setreadonly and getnamecallmethod) then
			error("funciones no disponibles")
		end
		local mt = getrawmetatable(game)
		if not mt or not mt.__namecall then error("sin __namecall") end
		local viejo = mt.__namecall
		local ncc = newcclosure or function(f) return f end
		setreadonly(mt, false)
		mt.__namecall = ncc(function(self, ...)
			if self == LP then
				local ok2, m = pcall(getnamecallmethod)
				if ok2 and m == "Kick" then
					local a = { ... }
					task.spawn(alSerKickeado, a[1])
				end
			end
			return viejo(self, ...)
		end)
		setreadonly(mt, true)
	end)
	if ok then metodoAntiKick = "AncestryChanged + Hook" end
	return ok
end

-- ---------- AUTO-EXEC ----------
local function instalarAutoExec()
	local q = queue_on_teleport or (syn and syn.queue_on_teleport) or queueonteleport
	if not q then return false end
	if AUTOEXEC_URL == "" then return false end
	pcall(q, string.format("loadstring(game:HttpGet('%s'))()", AUTOEXEC_URL))
	return true
end

local function activarProteccion()
	if syn and syn.protect_gui then pcall(syn.protect_gui, GUI) end
	if protect_gui then pcall(protect_gui, GUI) end
end

--==================================================================================
-- 8) PAGINAS
--==================================================================================

do
	PagInfo:Label("APOLOKING " .. CFG.Version .. "  SOLARA", "Anti-Ban Edition  |  Murderers VS Sheriffs")
	local estado = PagInfo:Label("Midiendo...", "")
	local lblEstado = estado:FindFirstChildWhichIsA("TextLabel")

	task.spawn(function()
		while true do
			local dt = RunService.RenderStepped:Wait()
			local fps = math.floor(1 / math.max(dt, 0.0001))
			local ping = 0
			pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
			if lblEstado then
				lblEstado.Text = string.format("FPS: %d   |   Ping: %d ms   |   Jugadores: %d", fps, ping, #Players:GetPlayers())
			end
		end
	end)

	PagInfo:Seccion("Controles")
	PagInfo:Label("F8", "Abrir / cerrar esta interfaz")
	PagInfo:Label("Click derecho", "Aim (mantener) con el aimbot activo")
	PagInfo:Label("C", "CamLock (mantener) con el camlock activo")
	PagInfo:Label("Boton flotante A", "Abre el menu tambien en touch")

	PagInfo:Seccion("Diagnostico del ejecutor")
	local function api(nombre, fn)
		local ok, r = pcall(fn)
		local tiene = ok and r ~= nil and r ~= false
		PagInfo:Label(nombre, tiene and "Disponible" or "NO disponible")
	end
	api("gethui()", function() return gethui end)
	api("protect_gui", function() return protect_gui end)
	api("getrawmetatable", function() return getrawmetatable end)
	api("getnamecallmethod", function() return getnamecallmethod end)
	api("setreadonly", function() return setreadonly end)
	api("newcclosure", function() return newcclosure end)
	api("queue_on_teleport", function() return queue_on_teleport end)
	api("setclipboard", function() return setclipboard end)
	PagInfo:Label("Metodo Anti-Kick", metodoAntiKick)
end

do
	PagConfig:Seccion("Interfaz")
	PagConfig:Toggle("Stream Mode", "Oculta el watermark y deja el ESP limpio", CFG.StreamMode, function(v, init)
		CFG.StreamMode = v
		if Watermark then Watermark.Visible = CFG.Watermark and not v end
		if not init then refrescarESP() end
	end)
	PagConfig:ColorPicker("Color de la interfaz")
	PagConfig:Slider("Tamaño de la interfaz", 0.7, 1.3, CFG.Escala, 2, function(v)
		CFG.Escala = v
		tw(EscalaUI, 0.12, { Scale = v })
	end)
	PagConfig:Keybind("Tecla de la interfaz", "Si F8 choca con Solara, cambiala aqui", CFG.TeclaUI, function(k)
		CFG.TeclaUI = k
		aviso("Tecla actualizada", k.Name, 2)
	end)
	PagConfig:Toggle("Watermark", "Texto flotante en pantalla", CFG.Watermark, function(v, init)
		CFG.Watermark = v
		if Watermark then Watermark.Visible = v and not CFG.StreamMode end
		if not init then aviso("Watermark", v and "Activado" or "Desactivado", 2) end
	end)
	PagConfig:Seccion("Comportamiento")
	PagConfig:Toggle("Rate Limit de remotos", "Evita spam (recomendado anti-kick)", true, function(v)
		Seg.RateLimit = v
	end)
end

do
	PagAimbot:Seccion("Aimbot")
	PagAimbot:Toggle("Activar Aimbot", "Por defecto DESACTIVADO", Aimbot.Activo, function(v, init)
		Aimbot.Activo = v
		if not init then aviso("Aimbot", v and "Activado" or "Desactivado", 2) end
	end)
	PagAimbot:Keybind("Tecla de apuntado", "Por defecto: click derecho", Enum.UserInputType.MouseButton2, function(k)
		Aimbot.Tecla = k
		aviso("Tecla de aim", k.Name, 2)
	end)
	PagAimbot:Dropdown("Modo de tecla", "Como se comporta la tecla", { "Mantener", "Alternar" }, "Mantener", function(v)
		Aimbot.ModoTecla = v
	end)
	PagAimbot:Slider("FOV", 20, 500, Aimbot.FOV, 0, function(v) Aimbot.FOV = v end)
	PagAimbot:Slider("Suavizado", 0.02, 1, Aimbot.Suavizado, 2, function(v) Aimbot.Suavizado = v end)
	PagAimbot:Slider("Prediccion", 0, 0.5, Aimbot.Prediccion, 2, function(v) Aimbot.Prediccion = v end)
	PagAimbot:Slider("Distancia maxima", 50, 2000, Aimbot.MaxDist, 0, function(v) Aimbot.MaxDist = v end)
	PagAimbot:Seccion("Objetivo")
	PagAimbot:Dropdown("Parte a apuntar", "Donde pega el aim", { "Head", "HumanoidRootPart", "UpperTorso" }, "Head", function(v)
		Aimbot.Parte = v
	end)
	PagAimbot:Dropdown("Prioridad", "A quien apuntar primero", { "Nadie", "Asesino", "Sheriff" }, "Nadie", function(v)
		Aimbot.Prioridad = v
	end)
	PagAimbot:Toggle("Team Check", "Ignora a los de tu equipo", false, function(v) Aimbot.TeamCheck = v end)
	PagAimbot:Toggle("Wall Check", "Penaliza a los que estan tras pared", false, function(v) Aimbot.ParedCheck = v end)
	PagAimbot:Toggle("Solo al clickear", "Solo apunta mientras disparas", false, function(v) Aimbot.SoloClick = v end)
	PagAimbot:Toggle("Mostrar circulo FOV", "", true, function(v) Aimbot.MostrarFOV = v end)
end

do
	PagCam:Seccion("CamLock")
	PagCam:Toggle("Activar CamLock", "Bloquea la camara en el enemigo", false, function(v) CamLock.Activo = v end)
	PagCam:Keybind("Tecla", "Por defecto: C", Enum.KeyCode.C, function(k) CamLock.Tecla = k end)
	PagCam:Dropdown("Modo", "", { "Mantener", "Alternar" }, "Mantener", function(v) CamLock.ModoTecla = v end)
	PagCam:Slider("Distancia", 4, 30, CamLock.Distancia, 0, function(v) CamLock.Distancia = v end)
	PagCam:Slider("Altura", -2, 12, CamLock.Altura, 0, function(v) CamLock.Altura = v end)
	PagCam:Slider("Suavizado", 0.02, 1, CamLock.Suavizado, 2, function(v) CamLock.Suavizado = v end)
end

do
	PagESP:Seccion("ESP")
	PagESP:Toggle("Activar ESP", "Por defecto DESACTIVADO", ESP.Activo, function(v, init)
		ESP.Activo = v
		refrescarESP()
		if not init then aviso("ESP", v and "Activado" or "Desactivado", 2) end
	end)
	PagESP:Toggle("Resaltado", "Contorno de color", true, function(v) ESP.Resaltado = v; refrescarESP() end)
	PagESP:Toggle("Caja", "Caja 3D alrededor", false, function(v) ESP.Caja = v; refrescarESP() end)
	PagESP:Toggle("Nombre", "", true, function(v) ESP.Nombre = v; refrescarESP() end)
	PagESP:Toggle("Distancia", "", true, function(v) ESP.Distancia = v; refrescarESP() end)
	PagESP:Toggle("Mostrar rol", "Asesino / Sheriff / Inocente", true, function(v) ESP.Roles = v; refrescarESP() end)
	PagESP:Toggle("Tracers", "Lineas hacia el enemigo", false, function(v) ESP.Tracer = v; refrescarESP() end)
	PagESP:Toggle("Ignorar mi personaje", "", true, function(v) ESP.IgnorarLocal = v; refrescarESP() end)
	PagESP:Slider("Distancia maxima", 50, 2000, ESP.MaxDist, 0, function(v) ESP.MaxDist = v end)
end

do
	PagHitbox:Seccion("Hitbox")
	PagHitbox:Toggle("Activar Hitbox", "Por defecto DESACTIVADO", Hitbox.Activo, function(v, init)
		Hitbox.Activo = v
		if not v then restaurarHitbox() end
		if not init then aviso("Hitbox", v and ("x" .. Hitbox.Escala) or "Desactivado", 2) end
	end)
	PagHitbox:Slider("Escala (1 - 30)", 1, 30, Hitbox.Escala, 0, function(v) Hitbox.Escala = v end)
	PagHitbox:Dropdown("Parte", "Que parte agrandar", { "HumanoidRootPart", "Head", "Ambos" }, "HumanoidRootPart", function(v)
		restaurarHitbox()
		Hitbox.Parte = v
	end)
	PagHitbox:Slider("Intervalo de actualizacion", 0.05, 0.5, Hitbox.Intervalo, 2, function(v) Hitbox.Intervalo = v end)
	PagHitbox:Toggle("Incluir mi personaje", "", true, function(v) Hitbox.IncluirLocal = v end)
	PagHitbox:Button("Restaurar tamaños", "Devuelve todo a lo normal", function()
		Hitbox.Activo = false
		restaurarHitbox()
		aviso("Hitbox", "Tamaños restaurados", 2)
	end)
end

do
	PagAnti:Seccion("Protecciones")
	PagAnti:Label("Escudo Anti-Ban", "La proteccion de GUI ya viene aplicada al cargar")
	PagAnti:Label("Metodo Anti-Kick activo", metodoAntiKick)

	PagAnti:Toggle("Proteger GUI", "Re-aplica la proteccion sobre la interfaz", false, function(v, init)
		Seg.ProtegerGUI = v
		if v and not init then activarProteccion(); aviso("Proteccion GUI", "Aplicada", 2) end
	end)

	PagAnti:Toggle("Anti-AFK", "No te saca por estar inactivo", false, function(v, init)
		Seg.AntiAFK = v
		activarAntiAFK()
		if not init then aviso("Anti-AFK", v and "Activado" or "Desactivado", 2) end
	end)

	PagAnti:Toggle("Anti-Kick (Rejoin)", "Si te kickean, vuelve al MISMO servidor", false, function(v, init)
		Seg.AntiKick = v
		if not init then aviso("Anti-Kick", v and "Activado" or "Desactivado", 2) end
	end)

	PagAnti:Toggle("Hook de metatabla", "Extra. Solara ya funciona sin esto", false, function(v, init)
		Seg.HookMeta = v
		if v then
			if instalarHookMeta() then
				aviso("Hook", "Instalado. Reinicia el script si algo raro pasa.", 4)
			else
				aviso("Hook", "Tu ejecutor no lo soporta bien", 3)
			end
		end
	end)

	PagAnti:Toggle("Auto-Exec al rejoin", "Requiere AUTOEXEC_URL arriba", false, function(v, init)
		Seg.AutoRejoin = v
		if v and not init then
			if instalarAutoExec() then aviso("Auto-Exec", "Listo", 2)
			else aviso("Auto-Exec", "Pon tu AUTOEXEC_URL", 4) end
		end
	end)

	PagAnti:Button("Aplicar TODO el escudo", "Activa todas las protecciones de golpe", function()
		Seg.ProtegerGUI, Seg.AntiAFK, Seg.AntiKick = true, true, true
		activarProteccion()
		activarAntiAFK()
		aviso("Escudo Anti-Ban", "Todo activado", 3)
	end)

	PagAnti:Seccion("Consejos anti-kick")
	PagAnti:Label("No abuses del Hitbox", "Usa escala 3 - 6, no 30 de golpe")
	PagAnti:Label("Deja el Rate Limit ON", "Reduce el spam de remotos")
	PagAnti:Label("Aimbot suave", "Suavizado 0.2 - 0.4 se ve natural")
	PagAnti:Label("Solara es externo", "Si te sacan seguido, prueba Wave o Volt (100% sUNC)")
end

do
	PagTools:Seccion("Servidor")
	PagTools:Button("Rejoin servidor", "Vuelve al mismo servidor", function()
		pcall(function() TeleportS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
	end)
	PagTools:Button("Copiar JobId", "Copia el ID del servidor", function()
		pcall(function() setclipboard(game.JobId) end)
		aviso("JobId copiado", game.JobId, 3)
	end)
	PagTools:Seccion("Utilidades")
	PagTools:Button("Desactivar todo", "Apaga todos los modulos", function()
		Aimbot.Activo, ESP.Activo, Hitbox.Activo, CamLock.Activo = false, false, false, false
		restaurarHitbox()
		refrescarESP()
		aviso("Modulos", "Todo desactivado", 2)
	end)
	PagTools:Button("Ocultar UI (Panic)", "Esconde la interfaz al instante", function()
		GUI.Enabled = false
	end)
	PagTools:Button("Info del executor", "Muestra executor y version", function()
		aviso("Executor", tostring(nombreExec) .. " | " .. CFG.Version, 3)
	end)
end

--==================================================================================
-- 9) WATERMARK + BOTON FLOTANTE
--==================================================================================
Watermark = nuevo("TextLabel", {
	Text = CFG.Nombre .. "  |  " .. CFG.Version, Font = FUENTE_BOLD, TextSize = 13,
	TextColor3 = T.Acento, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8),
	Size = UDim2.fromOffset(280, 20), TextXAlignment = Enum.TextXAlignment.Left,
	TextStrokeTransparency = 0.6, TextStrokeColor3 = Color3.new(0, 0, 0), ZIndex = 5,
	Visible = CFG.Watermark and not CFG.StreamMode,
}, GUI)
Watermark:SetAttribute("AcentoTexto", true)

BtnGUI = nuevo("ScreenGui", {
	Name = "ApolokingBoton", ResetOnSpawn = false,
	IgnoreGuiInset = true, DisplayOrder = 999998,
})
local Btn = nuevo("TextButton", {
	Text = "A", Font = FUENTE_BOLD, TextSize = 16, TextColor3 = T.Acento,
	BackgroundColor3 = T.Panel, BorderSizePixel = 0,
	Position = UDim2.new(0, 10, 0, 10), Size = UDim2.fromOffset(38, 38),
	AutoButtonColor = false,
}, BtnGUI)
redondear(Btn, 19)
borde(Btn, T.Borde, 1)
Btn:SetAttribute("AcentoTexto", true)
Btn.MouseButton1Click:Connect(function() GUI.Enabled = not GUI.Enabled end)
Btn.MouseEnter:Connect(function() tw(Btn, 0.12, { BackgroundColor3 = T.Panel2 }) end)
Btn.MouseLeave:Connect(function() tw(Btn, 0.12, { BackgroundColor3 = T.Panel }) end)

--==================================================================================
-- 10) ARRANQUE
--==================================================================================
local padre = parentSeguro()
proteger(GUI)
proteger(BtnGUI)
GUI.Parent = padre
BtnGUI.Parent = padre

UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == CFG.TeclaUI then GUI.Enabled = not GUI.Enabled end
end)

Paginas["Info"].Marco.Visible = true
Botones["Info"].marca.Visible = true
Botones["Info"].btn.BackgroundColor3 = T.Panel2
Botones["Info"].ic.TextColor3 = T.Acento
Botones["Info"].tx.TextColor3 = T.Texto

pcall(activarProteccion)
pcall(vigilarKick)

task.delay(0.4, function() aviso("APOLOKING cargado", "F8 para abrir / cerrar", 4) end)
print("[APOLOKING] Cargado. F8 para abrir / cerrar. Metodo anti-kick: " .. metodoAntiKick)

GENV.Apoloking = {
	Destruir = function()
		pcall(restaurarHitbox)
		pcall(limpiarESP)
		pcall(function() GUI:Destroy() end)
		pcall(function() BtnGUI:Destroy() end)
		GENV.Apoloking = nil
	end,
	CFG = CFG, Aimbot = Aimbot, ESP = ESP, Hitbox = Hitbox, Seg = Seg, CamLock = CamLock,
}
