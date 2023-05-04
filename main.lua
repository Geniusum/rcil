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
    local vertices = {
        { x = self.x, y = self.y, z = self.z },
        { x = self.x + self.width, y = self.y, z = self.z },
        { x = self.x, y = self.y + self.height, z = self.z },
        { x = self.x + self.width, y = self.y + self.height, z = self.z },
        { x = self.x, y = self.y, z = self.z + self.depth },
        { x = self.x + self.width, y = self.y, z = self.z + self.depth },
        { x = self.x, y = self.y + self.height, z = self.z + self.depth },
        { x = self.x + self.width, y = self.y + self.height, z = self.z + self.depth },
    }

    local faces = {
        { vertices[1], vertices[2], vertices[4], vertices[3] },
        { vertices[1], vertices[2], vertices[6], vertices[5] },
        { vertices[1], vertices[3], vertices[7], vertices[5] },
        { vertices[2], vertices[4], vertices[8], vertices[6] },
        { vertices[3], vertices[4], vertices[8], vertices[7] },
        { vertices[5], vertices[6], vertices[8], vertices[7] },
    }

    for i, face in ipairs(faces) do
        local points = {}
        for j, vertex in ipairs(face) do
            local point = {
                x = vertex.x - camera.x,
                y = vertex.y - camera.y,
                z = vertex.z - camera.z
            }
            point.x, point.z = math.cos(camera.yaw) * point.x - math.sin(camera.yaw) * point.z, math.sin(camera.yaw) * point.x + math.cos(camera.yaw) * point.z
            point.y, point.z = math.cos(camera.pitch) * point.y - math.sin(camera.pitch) * point.z, math.sin(camera.pitch) * point.y + math.cos(camera.pitch) * point.z
            if point.z <= 0 then
                return
            end
            local scale = camera.fov / point.z
            point.x, point.y = point.x * scale, point.y * scale
            point.x, point.y = point.x + screenWidth / 2, point.y + screenHeight / 2
            points[j] = point
        end
        local color = self.color
        if i == 1 then
            color = colors.orange
        elseif i == 2 then
            color = colors.magenta
        elseif i == 3 then
            color = colors.lightBlue
        elseif i == 4 then
            color = colors.yellow
        elseif i == 5 then
            color = colors.lime
        elseif i == 6 then
            color = colors.pink
        end
        paintutils.drawPolygon(points, color)
    end
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
