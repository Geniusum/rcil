-- Configuration
local screenWidth, screenHeight = term.getSize()
local camera = { x = 0, y = 0, z = 0, yaw = 0, pitch = 0, fov = 90 }
local world = {}

-- Classe Cube
local Cube = {}
Cube.__index = Cube

function Cube.new(x, y, z, width, height, depth, color)
    local self = setmetatable({}, Cube)
    self.x = x
    self.y = y
    self.z = z
    self.width = width
    self.height = height
    self.depth = depth
    self.color = color or colors.white
    return self
end

function Cube:draw()
    local points = {}
    local function addPoint(x, y)
        table.insert(points, {x, y})
    end

    -- Calcul des coordonnées 3D du cube dans le référentiel de la caméra
    local cosYaw = math.cos(-camera.yaw)
    local sinYaw = math.sin(-camera.yaw)
    local cosPitch = math.cos(-camera.pitch)
    local sinPitch = math.sin(-camera.pitch)
    local cx = self.x - camera.x
    local cy = self.y - camera.y
    local cz = self.z - camera.z
    local dx = cosYaw * (sinPitch * cz + cosPitch * (sinYaw * cy + cosYaw * cx)) - sinYaw * sinPitch * cx
    local dy = cosPitch * cy - sinPitch * (cosYaw * cz - sinYaw * cx)
    local dz = sinYaw * (sinPitch * cz + cosPitch * (sinYaw * cy + cosYaw * cx)) + cosYaw * sinPitch * cx

    -- Projection en 2D
    local scaleFactor = (camera.fov / dz)
    local x = math.floor(0.5 * term.getSize() + scaleFactor * dx)
    local y = math.floor(0.5 * term.getSize() - scaleFactor * dy)

    -- Dessin des faces
    local color = self.color
    local function drawFace(p1, p2, p3, p4)
        paintutils.drawLine(p1[1], p1[2], p2[1], p2[2], color)
        paintutils.drawLine(p2[1], p2[2], p3[1], p3[2], color)
        paintutils.drawLine(p3[1], p3[2], p4[1], p4[2], color)
        paintutils.drawLine(p4[1], p4[2], p1[1], p1[2], color)
    end
    -- Face avant
    addPoint(x - self.width * scaleFactor, y - self.height * scaleFactor)
    addPoint(x + self.width * scaleFactor, y - self.height * scaleFactor)
    addPoint(x + self.width * scaleFactor, y + self.height * scaleFactor)
    addPoint(x - self.width * scaleFactor, y + self.height * scaleFactor)
    drawFace(points[1], points[2], points[3], points[4])
    points = {}
    -- Face arrière
    addPoint(x + self.width * scaleFactor, y - self.height * scaleFactor)
    addPoint(x - self.width * scaleFactor, y - self.height * scaleFactor)
    addPoint(x - self.width * scaleFactor, y + self.height * scaleFactor)
    addPoint(x + self.width * scaleFactor, y + self.height * scaleFactor)
    drawFace(points[1], points[2], points[3], points[4])
    points = {}
    -- Face gauche
    addPoint(x - self.width * scaleFactor, y - self.height * scaleFactor)
    addPoint(x - self.width * scaleFactor, y + self.height * scaleFactor)
    addPoint(x, y + self.height * scaleFactor * 0.5)
    addPoint(x, y - self.height * scaleFactor * 0.5)
    drawFace(points[1], points[2], points[3], points[4])
    points = {}
    -- Face droite
    addPoint(x + self.width * scaleFactor, y - self.height * scaleFactor)
    addPoint(x + self.width * scaleFactor, y + self.height * scaleFactor)
    addPoint(x, y + self.height * scaleFactor * 0.5)
    addPoint(x, y - self.height * scaleFactor * 0.5)
    drawFace(points[1], points[2], points[3], points[4])
    points = {}
    -- Face supérieure
    addPoint(x - self.width * scaleFactor, y - self.height * scaleFactor)
    addPoint(x, y - self.height * scaleFactor * 0.5)
    addPoint(x + self.width * scaleFactor, y - self.height * scaleFactor)
    addPoint(x, y + self.height * scaleFactor * 0.5)
    drawFace(points[1], points[2], points[3], points[4])
    points = {}
    -- Face inférieure
    addPoint(x - self.width * scaleFactor, y + self.height * scaleFactor)
    addPoint(x, y + self.height * scaleFactor * 0.5)
    addPoint(x + self.width * scaleFactor, y + self.height * scaleFactor)
    addPoint(x, y - self.height * scaleFactor * 0.5)
    drawFace(points[1], points[2], points[3], points[4])
end

-- Fonction pour ajouter des cubes à la scène
function addCube(x, y, z, width, height, depth, color)
    table.insert(world, Cube.new(x, y, z, width, height, depth, color))
end

-- Fonction de mise à jour de la caméra
function updateCamera(dx, dy, dz, dyaw, dpitch, dfov)
    camera.x = camera.x + (dx or 0)
    camera.y = camera.y + (dy or 0)
    camera.z = camera.z + (dz or 0)
    camera.yaw = camera.yaw + (dyaw or 0)
    camera.pitch = camera.pitch + (dpitch or 0)
    camera.fov = camera.fov + (dfov or 0)
end

-- Fonction de rendu de la scène
function render()
    term.clear()
    term.setCursorPos(1, 1)
    for i, cube in ipairs(world) do
        cube:draw()
    end
end

-- Exemple d'utilisation
addCube(0, 0, 0, 1, 1, 1, colors.red)
addCube(2, 0, 0, 1, 2, 1, colors.green)
addCube(0, 2, 0, 2, 1, 1, colors.blue)

updateCamera(0, 0, -5)

while true do
    render()
    local event, key = os.pullEvent("key")
    if key == keys.w then
        updateCamera(nil, nil, 1)
    elseif key == keys.a then
        updateCamera(-1)
    elseif key == keys.s then
        updateCamera(nil, nil, -1)
    elseif key == keys.d then
        updateCamera(1)
    elseif key == keys.up then
        updateCamera(nil, 1)
    elseif key == keys.down then
        updateCamera(nil, -1)
    elseif key == keys.left then
        updateCamera(nil, nil, nil, -0.1)
    elseif key == keys.right then
        updateCamera(nil, nil, nil, 0.1)
    elseif key == keys.pageUp then
        updateCamera(nil, nil, nil, nil, 0.1)
    elseif key == keys.pageDown then
        updateCamera(nil, nil, nil, nil, -0.1)
    elseif key == keys.space then
        updateCamera(nil, nil, nil, nil, nil, 1)
    elseif key == keys.leftShift then
        updateCamera(nil, nil, nil, nil, nil, -1)
    end
end
