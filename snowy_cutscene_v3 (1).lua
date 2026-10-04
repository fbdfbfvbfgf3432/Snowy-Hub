-- ╔══════════════════════════════════════════════════════════════╗
-- ║          Snowy Hub  |  Loading Cutscene  v3                 ║
-- ║          Made By Crscx                                      ║
-- ║          Runtime : Synapse X / KRNL / Delta / Fluxus        ║
-- ╚══════════════════════════════════════════════════════════════╝
--
-- SETUP — only one thing to fill:
--   SOUND_ASSET_ID  →  upload your MP3 on Roblox Creator Hub
--                      (Creator → Creations → Audio → Upload)
--                      then paste the numeric ID here.

-- ──────────────────────────────────────────────────────────────
-- 0.  CONFIGURATION
-- ──────────────────────────────────────────────────────────────
local CFG = {
    -- ┌─────────────────────────────────────────────────────────────┐
    -- │  SOUND SETUP                                                │
    -- │  You sent: "Gojo_Domain_Expansion_sound_effect_128k.mp3"   │
    -- │  Steps:                                                     │
    -- │  1. Go to roblox.com → Create → Creations → Audio          │
    -- │  2. Upload that MP3                                         │
    -- │  3. Copy the numeric ID and replace 000000000000 below     │
    -- └─────────────────────────────────────────────────────────────┘
    SOUND_ID        = "rbxassetid://137092984994527",
    LOAD_DURATION   = 10,    -- seconds the fake load runs
    SOUND_VOLUME    = 0.80,

    -- background gradient colours  (deep navy → dark teal)
    BG_DARK         = Color3.fromRGB(3,   9,  18),
    BG_MID          = Color3.fromRGB(0,  28,  48),
    BG_ACCENT       = Color3.fromRGB(0,  55,  80),

    -- neon snowflake colours
    FLAKE_CORE      = Color3.fromRGB(0,  245, 240),
    FLAKE_MID       = Color3.fromRGB(0,  200, 220),
    FLAKE_GLOW      = Color3.fromRGB(0,  130, 180),
    FLAKE_DEEP      = Color3.fromRGB(0,   70, 120),

    -- bokeh / scatter colours
    BOK_BRIGHT      = Color3.fromRGB(0,  220, 240),
    BOK_MID         = Color3.fromRGB(0,  160, 200),
    BOK_DIM         = Color3.fromRGB(0,   90, 140),

    -- text
    TEXT_TITLE      = Color3.fromRGB(230, 250, 255),
    TEXT_CREDIT     = Color3.fromRGB(0,   195, 220),
    TEXT_STATUS     = Color3.fromRGB(0,   155, 185),
    BAR_COLOR       = Color3.fromRGB(0,   210, 235),
}

-- ──────────────────────────────────────────────────────────────
-- 1.  SERVICES & LOCALS
-- ──────────────────────────────────────────────────────────────
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local CoreGui       = game:GetService("CoreGui")
local LocalPlayer   = Players.LocalPlayer
local RNG           = Random.new()

local VP            = workspace.CurrentCamera.ViewportSize
local CX, CY        = VP.X * 0.5, VP.Y * 0.40   -- flake centre

-- ──────────────────────────────────────────────────────────────
-- 2.  CLEANUP OLD INSTANCE
-- ──────────────────────────────────────────────────────────────
if CoreGui:FindFirstChild("SnowyLoad") then
    CoreGui:FindFirstChild("SnowyLoad"):Destroy()
end

-- ──────────────────────────────────────────────────────────────
-- 3.  ROOT SCREENGUI
-- ──────────────────────────────────────────────────────────────
local sg = Instance.new("ScreenGui")
sg.Name             = "SnowyLoad"
sg.ResetOnSpawn     = false
sg.IgnoreGuiInset   = true
sg.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
sg.Parent           = CoreGui

-- ──────────────────────────────────────────────────────────────
-- 4.  LAYERED BACKGROUND  (deep navy + teal bloom + vignette)
-- ──────────────────────────────────────────────────────────────

-- 4a. Solid dark base
local bgBase = Instance.new("Frame")
bgBase.Size             = UDim2.new(1,0,1,0)
bgBase.BackgroundColor3 = CFG.BG_DARK
bgBase.BorderSizePixel  = 0
bgBase.ZIndex           = 100
bgBase.Parent           = sg

-- 4b. Diagonal teal sweep (matches the reference's diagonal light sweep)
local sweep = Instance.new("Frame")
sweep.Size              = UDim2.new(1.8, 0, 1.8, 0)
sweep.AnchorPoint       = Vector2.new(0.5, 0.5)
sweep.Position          = UDim2.new(0.5, 0, 0.5, 0)
sweep.BackgroundColor3  = CFG.BG_ACCENT
sweep.BackgroundTransparency = 0.0
sweep.BorderSizePixel   = 0
sweep.ZIndex            = 101
sweep.Parent            = bgBase
local sweepGrad = Instance.new("UIGradient")
sweepGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, CFG.BG_DARK),
    ColorSequenceKeypoint.new(0.30, CFG.BG_MID),
    ColorSequenceKeypoint.new(0.55, CFG.BG_ACCENT),
    ColorSequenceKeypoint.new(0.75, CFG.BG_MID),
    ColorSequenceKeypoint.new(1.00, CFG.BG_DARK),
})
sweepGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.00, 1.0),
    NumberSequenceKeypoint.new(0.25, 0.55),
    NumberSequenceKeypoint.new(0.50, 0.0),
    NumberSequenceKeypoint.new(0.75, 0.55),
    NumberSequenceKeypoint.new(1.00, 1.0),
})
sweepGrad.Rotation = 38   -- diagonal like the reference
sweepGrad.Parent   = sweep

-- 4c. Centre radial bloom behind the snowflake
local bloom = Instance.new("Frame")
bloom.Size              = UDim2.new(0, 500, 0, 500)
bloom.AnchorPoint       = Vector2.new(0.5, 0.5)
bloom.Position          = UDim2.new(0.5, 0, 0.40, 0)
bloom.BackgroundColor3  = Color3.fromRGB(0, 90, 130)
bloom.BackgroundTransparency = 1    -- fades in
bloom.BorderSizePixel   = 0
bloom.ZIndex            = 102
bloom.Parent            = bgBase
Instance.new("UICorner", bloom).CornerRadius = UDim.new(1, 0)
local bloomGrad = Instance.new("UIGradient")
bloomGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 110, 150)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,  50,  80)),
    ColorSequenceKeypoint.new(1,   CFG.BG_DARK),
})
bloomGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   0),
    NumberSequenceKeypoint.new(0.6, 0.6),
    NumberSequenceKeypoint.new(1,   1),
})
bloomGrad.Parent = bloom

-- 4d. Hard vignette (edges dark)
local vig = Instance.new("Frame")
vig.Size             = UDim2.new(1,0,1,0)
vig.BackgroundColor3 = Color3.fromRGB(0,0,0)
vig.BackgroundTransparency = 0.0
vig.BorderSizePixel  = 0
vig.ZIndex           = 103
vig.Parent           = bgBase
local vigGrad = Instance.new("UIGradient")
vigGrad.Color = ColorSequence.new(Color3.fromRGB(0,0,0))
vigGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.00, 0.0),
    NumberSequenceKeypoint.new(0.18, 0.75),
    NumberSequenceKeypoint.new(0.50, 1.00),
    NumberSequenceKeypoint.new(0.82, 0.75),
    NumberSequenceKeypoint.new(1.00, 0.0),
})
vigGrad.Parent = vig

-- second-axis vignette (top/bottom)
local vig2 = Instance.new("Frame")
vig2.Size             = UDim2.new(1,0,1,0)
vig2.BackgroundColor3 = Color3.fromRGB(0,0,0)
vig2.BackgroundTransparency = 0.0
vig2.BorderSizePixel  = 0
vig2.ZIndex           = 104
vig2.Parent           = bgBase
local vig2Grad = Instance.new("UIGradient")
vig2Grad.Color = ColorSequence.new(Color3.fromRGB(0,0,0))
vig2Grad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.00, 0.0),
    NumberSequenceKeypoint.new(0.14, 0.80),
    NumberSequenceKeypoint.new(0.50, 1.00),
    NumberSequenceKeypoint.new(0.86, 0.80),
    NumberSequenceKeypoint.new(1.00, 0.0),
})
vig2Grad.Rotation = 90
vig2Grad.Parent   = vig2

-- ──────────────────────────────────────────────────────────────
-- 5.  HELPER: Drawing wrappers
--     All Drawing objects are tracked in `allDrawings`
--     so we can fade and remove them at the end without leaking.
-- ──────────────────────────────────────────────────────────────
local allDrawings = {}   -- { obj, baseAlpha }

local function NewLine(col, thick)
    local l = Drawing.new("Line")
    l.Color       = col
    l.Thickness   = thick
    l.Transparency = 1   -- start invisible
    l.Visible     = true
    allDrawings[#allDrawings+1] = { obj=l, baseAlpha=1 }
    return l
end

local function NewCircle(col, radius, filled, thick)
    local c = Drawing.new("Circle")
    c.Color        = col
    c.Radius       = radius
    c.Filled       = filled
    c.Thickness    = thick or 1
    c.Transparency = 1
    c.Visible      = true
    allDrawings[#allDrawings+1] = { obj=c, baseAlpha=1 }
    return c
end

local function NewQuad(col)
    local q = Drawing.new("Quad")
    q.Color        = col
    q.Filled       = true
    q.Thickness    = 1
    q.Transparency = 1
    q.Visible      = true
    allDrawings[#allDrawings+1] = { obj=q, baseAlpha=1 }
    return q
end

local function Vec2(x,y) return Vector2.new(x,y) end

-- ──────────────────────────────────────────────────────────────
-- 6.  BOKEH / SCATTER PARTICLES
--     Large blurred circles (unfocused light), medium dots,
--     tiny sparkle points.  They LIVE ONLY DURING THE CUTSCENE:
--     tracked in `allDrawings`, removed on cleanup.
-- ──────────────────────────────────────────────────────────────

local bokehs = {}   -- { obj:Circle, x,y,vx,vy,pulseOffset,baseA }

-- Large unfocused bokeh (the big blurry circles in the reference)
local LARGE_COUNT = 14
for i = 1, LARGE_COUNT do
    local r   = RNG:NextNumber(18, 55)
    local col = (RNG:NextNumber() > 0.5) and CFG.BOK_BRIGHT or CFG.BOK_MID
    local c   = Drawing.new("Circle")
    c.Radius      = r
    c.Color       = col
    c.Filled      = true
    c.Thickness   = 1
    c.Transparency = 1
    c.Visible     = true
    allDrawings[#allDrawings+1] = { obj=c, baseAlpha=RNG:NextNumber(0.55,0.82) }
    bokehs[#bokehs+1] = {
        obj          = c,
        x            = RNG:NextNumber(0, VP.X),
        y            = RNG:NextNumber(0, VP.Y),
        vx           = RNG:NextNumber(-0.08, 0.08),
        vy           = RNG:NextNumber(-0.04, 0.04),
        pulseOffset  = RNG:NextNumber(0, math.pi*2),
        baseA        = RNG:NextNumber(0.55, 0.82),
        pulseSpeed   = RNG:NextNumber(0.4, 1.1),
        large        = true,
    }
end

-- Medium dots
local MED_COUNT = 35
for i = 1, MED_COUNT do
    local r   = RNG:NextNumber(3, 9)
    local c   = Drawing.new("Circle")
    c.Radius      = r
    c.Color       = (RNG:NextNumber()>0.6) and CFG.BOK_BRIGHT or CFG.BOK_MID
    c.Filled      = true
    c.Thickness   = 1
    c.Transparency = 1
    c.Visible     = true
    allDrawings[#allDrawings+1] = { obj=c, baseAlpha=RNG:NextNumber(0.4,0.70) }
    bokehs[#bokehs+1] = {
        obj          = c,
        x            = RNG:NextNumber(0, VP.X),
        y            = RNG:NextNumber(0, VP.Y),
        vx           = RNG:NextNumber(-0.15, 0.15),
        vy           = RNG:NextNumber(-0.08, 0.12),
        pulseOffset  = RNG:NextNumber(0, math.pi*2),
        baseA        = RNG:NextNumber(0.40, 0.70),
        pulseSpeed   = RNG:NextNumber(0.6, 1.8),
        large        = false,
    }
end

-- Tiny sparkle points
local TINY_COUNT = 60
for i = 1, TINY_COUNT do
    local c   = Drawing.new("Circle")
    c.Radius      = RNG:NextNumber(0.8, 2.2)
    c.Color       = CFG.BOK_BRIGHT
    c.Filled      = true
    c.Thickness   = 1
    c.Transparency = 1
    c.Visible     = true
    allDrawings[#allDrawings+1] = { obj=c, baseAlpha=RNG:NextNumber(0.2,0.65) }
    bokehs[#bokehs+1] = {
        obj          = c,
        x            = RNG:NextNumber(0, VP.X),
        y            = RNG:NextNumber(0, VP.Y),
        vx           = RNG:NextNumber(-0.3, 0.3),
        vy           = RNG:NextNumber(-0.1, 0.22),
        pulseOffset  = RNG:NextNumber(0, math.pi*2),
        baseA        = RNG:NextNumber(0.20, 0.65),
        pulseSpeed   = RNG:NextNumber(1.0, 3.0),
        large        = false,
    }
end

-- ──────────────────────────────────────────────────────────────
-- 7.  BACKGROUND SNOWFLAKES
--     Scattered large snowflakes in the background (dim, static,
--     like the big ice-crystal shapes in the reference image).
-- ──────────────────────────────────────────────────────────────

local bgFlakes = {}   -- { armDefs, cx, cy, rot, rotSpeed, alpha }

local function BuildSnowflakeDefs(cx, cy, armLen, branchLen, numArms)
    local defs = {}
    for arm = 0, numArms-1 do
        local base = (arm/numArms)*math.pi*2

        -- main arm  (glow outer, mid, core)
        defs[#defs+1] = {
            fromFn = function(r) return Vec2(cx, cy) end,
            toFn   = function(r)
                local a = base+r
                return Vec2(cx+math.cos(a)*armLen, cy+math.sin(a)*armLen)
            end,
            layers = {
                NewLine(CFG.FLAKE_DEEP, 7),
                NewLine(CFG.FLAKE_GLOW, 3),
                NewLine(CFG.FLAKE_MID,  1.2),
            },
            layerAlpha = {0.12, 0.30, 0.55},
        }

        -- branches at 35%, 60%, 85%
        for _, frac in ipairs({0.35, 0.60, 0.85}) do
            for _, side in ipairs({1,-1}) do
                defs[#defs+1] = {
                    fromFn = function(r)
                        local a=base+r
                        return Vec2(cx+math.cos(a)*armLen*frac, cy+math.sin(a)*armLen*frac)
                    end,
                    toFn = function(r)
                        local a=base+r
                        local bx=cx+math.cos(a)*armLen*frac
                        local by=cy+math.sin(a)*armLen*frac
                        local ba=a+side*(math.pi/3)
                        return Vec2(bx+math.cos(ba)*branchLen, by+math.sin(ba)*branchLen)
                    end,
                    layers = {
                        NewLine(CFG.FLAKE_DEEP, 5),
                        NewLine(CFG.FLAKE_GLOW, 2),
                        NewLine(CFG.FLAKE_MID,  0.8),
                    },
                    layerAlpha = {0.10, 0.25, 0.45},
                }
            end
        end
    end
    return defs
end

-- 3 background flakes scattered around (dim, different sizes)
local BG_FLAKE_DATA = {
    { x=0.18, y=0.25, armLen=55, branchLen=14, rotSpeed= 0.06 },
    { x=0.82, y=0.22, armLen=65, branchLen=17, rotSpeed=-0.05 },
    { x=0.65, y=0.72, armLen=48, branchLen=12, rotSpeed= 0.08 },
}

for _, fd in ipairs(BG_FLAKE_DATA) do
    local fx = VP.X * fd.x
    local fy = VP.Y * fd.y
    bgFlakes[#bgFlakes+1] = {
        defs     = BuildSnowflakeDefs(fx, fy, fd.armLen, fd.branchLen, 6),
        rot      = RNG:NextNumber(0, math.pi*2),
        rotSpeed = fd.rotSpeed,
    }
end

-- ──────────────────────────────────────────────────────────────
-- 8.  CENTRE SNOWFLAKE  (main neon hero flake)
-- ──────────────────────────────────────────────────────────────

local function BuildCentreFlake(cx, cy)
    local defs = {}
    local ARM_LEN    = 95
    local NUM_ARMS   = 6

    -- branch configs: fraction along arm, branch length, layer widths
    local BRANCH_FRACS = {
        { frac=0.32, len=32, widths={9,4,1.6} },
        { frac=0.56, len=26, widths={7,3,1.2} },
        { frac=0.78, len=18, widths={5,2,0.8} },
    }

    for arm = 0, NUM_ARMS-1 do
        local base = (arm/NUM_ARMS)*math.pi*2

        -- main arm: 4 glow layers (deep bloom, outer glow, mid, neon core)
        defs[#defs+1] = {
            fromFn = function(r) return Vec2(cx, cy) end,
            toFn   = function(r)
                local a=base+r
                return Vec2(cx+math.cos(a)*ARM_LEN, cy+math.sin(a)*ARM_LEN)
            end,
            layers = {
                NewLine(CFG.FLAKE_DEEP, 18),
                NewLine(CFG.FLAKE_GLOW, 9),
                NewLine(CFG.FLAKE_MID,  3.5),
                NewLine(CFG.FLAKE_CORE, 1.4),
            },
            layerAlpha = {0.18, 0.55, 0.80, 1.0},
        }

        -- branches
        for _, bc in ipairs(BRANCH_FRACS) do
            for _, side in ipairs({1,-1}) do
                defs[#defs+1] = {
                    fromFn = function(r)
                        local a=base+r
                        return Vec2(cx+math.cos(a)*ARM_LEN*bc.frac, cy+math.sin(a)*ARM_LEN*bc.frac)
                    end,
                    toFn = function(r)
                        local a=base+r
                        local bx=cx+math.cos(a)*ARM_LEN*bc.frac
                        local by=cy+math.sin(a)*ARM_LEN*bc.frac
                        local ba=a+side*(math.pi/3)
                        return Vec2(bx+math.cos(ba)*bc.len, by+math.sin(ba)*bc.len)
                    end,
                    layers = {
                        NewLine(CFG.FLAKE_DEEP, bc.widths[1]),
                        NewLine(CFG.FLAKE_MID,  bc.widths[2]),
                        NewLine(CFG.FLAKE_CORE, bc.widths[3]),
                    },
                    layerAlpha = {0.15, 0.65, 1.0},
                }
            end
        end
    end
    return defs
end

local centreDefs = BuildCentreFlake(CX, CY)

-- Centre rings (concentric glow circles at hub)
local RINGS = {
    { r=4,  col=CFG.FLAKE_CORE, thick=2.0, alpha=1.0 },
    { r=10, col=CFG.FLAKE_MID,  thick=1.4, alpha=0.8 },
    { r=18, col=CFG.FLAKE_GLOW, thick=1.0, alpha=0.5 },
    { r=28, col=CFG.FLAKE_DEEP, thick=0.8, alpha=0.3 },
}
local ringObjs = {}
for _, rd in ipairs(RINGS) do
    local c = Drawing.new("Circle")
    c.Radius      = rd.r
    c.Color       = rd.col
    c.Filled      = (rd.r <= 4)
    c.Thickness   = rd.thick
    c.Transparency = 1
    c.Visible     = true
    allDrawings[#allDrawings+1] = { obj=c, baseAlpha=rd.alpha }
    ringObjs[#ringObjs+1] = { obj=c, alpha=rd.alpha }
end

-- ──────────────────────────────────────────────────────────────
-- 9.  GUI LABELS — Title, Credit, Bar, Status
-- ──────────────────────────────────────────────────────────────

local function MakeLabel(parent, font, text, color, size, axAlign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font            = font
    l.Text            = text
    l.TextColor3      = color
    l.TextSize        = size
    l.TextTransparency = 1
    l.TextXAlignment  = axAlign or Enum.TextXAlignment.Center
    l.BorderSizePixel = 0
    l.Parent          = parent
    return l
end

local titleLbl = MakeLabel(bgBase, Enum.Font.GothamBold, "SnowyHub",     CFG.TEXT_TITLE,  40)
titleLbl.Size     = UDim2.new(0,500,0,54)
titleLbl.AnchorPoint = Vector2.new(0.5,0)
titleLbl.Position = UDim2.new(0.5,0,0.525,0)
titleLbl.ZIndex   = 200

local creditLbl = MakeLabel(bgBase, Enum.Font.Gotham, "Made By Crscx", CFG.TEXT_CREDIT, 13)
creditLbl.Size     = UDim2.new(0,400,0,22)
creditLbl.AnchorPoint = Vector2.new(0.5,0)
creditLbl.Position = UDim2.new(0.5,0,0.607,0)
creditLbl.ZIndex   = 200

-- progress bar track
local barTrack = Instance.new("Frame")
barTrack.Size              = UDim2.new(0,320,0,2)
barTrack.AnchorPoint       = Vector2.new(0.5,0)
barTrack.Position          = UDim2.new(0.5,0,0.657,0)
barTrack.BackgroundColor3  = Color3.fromRGB(8,30,45)
barTrack.BackgroundTransparency = 1
barTrack.BorderSizePixel   = 0
barTrack.ZIndex            = 200
barTrack.Parent            = bgBase
Instance.new("UICorner",barTrack).CornerRadius = UDim.new(1,0)

-- bar fill
local barFill = Instance.new("Frame")
barFill.Size              = UDim2.new(0,0,1,0)
barFill.BackgroundColor3  = CFG.BAR_COLOR
barFill.BorderSizePixel   = 0
barFill.ZIndex            = 201
barFill.Parent            = barTrack
Instance.new("UICorner",barFill).CornerRadius = UDim.new(1,0)

-- bar neon glow strip
local barGlow1 = Instance.new("Frame")
barGlow1.Size             = UDim2.new(1,0,0,10)
barGlow1.Position         = UDim2.new(0,0,-4,0)
barGlow1.BackgroundColor3 = Color3.fromRGB(0,230,250)
barGlow1.BackgroundTransparency = 0.60
barGlow1.BorderSizePixel  = 0
barGlow1.ZIndex           = 201
barGlow1.Parent           = barFill
Instance.new("UICorner",barGlow1).CornerRadius = UDim.new(1,0)

local barGlow2 = Instance.new("Frame")
barGlow2.Size             = UDim2.new(1,0,0,18)
barGlow2.Position         = UDim2.new(0,0,-8,0)
barGlow2.BackgroundColor3 = Color3.fromRGB(0,180,220)
barGlow2.BackgroundTransparency = 0.82
barGlow2.BorderSizePixel  = 0
barGlow2.ZIndex           = 200
barGlow2.Parent           = barFill
Instance.new("UICorner",barGlow2).CornerRadius = UDim.new(1,0)

-- status text
local statusLbl = MakeLabel(bgBase, Enum.Font.Gotham, "initializing...", CFG.TEXT_STATUS, 11)
statusLbl.Size     = UDim2.new(0,320,0,18)
statusLbl.AnchorPoint = Vector2.new(0.5,0)
statusLbl.Position = UDim2.new(0.5,0,0.676,0)
statusLbl.ZIndex   = 200

-- ── percentage counter  (big neon number, left of bar)
-- sits to the right of the bar, glows bright cyan, counts 0% → 100%
-- the displayed value jumps in uneven increments (10, 14, 23 …) so it
-- feels like a real async loader rather than a smooth counter.

-- pre-baked "realistic" percentage checkpoints that feel async:
local PCT_JUMPS = {
    0, 4, 10, 14, 19, 23, 27, 31, 36, 40,
    43, 47, 51, 55, 58, 62, 65, 68, 72, 75,
    78, 81, 84, 87, 89, 91, 93, 95, 97, 99, 100
}
local displayedPct   = 0   -- what we actually show (lags behind real pct)
local lastJumpTime   = tick()
local jumpInterval   = 0   -- seconds until next displayed jump (randomised)
local jumpIdx        = 1   -- current index into PCT_JUMPS

-- percentage label: centred directly under the bar, between status and bar
-- AnchorPoint (0.5, 0) — centred horizontally, aligned to bar's Y slot
local pctLbl = MakeLabel(bgBase, Enum.Font.GothamBold, "0%", CFG.FLAKE_CORE, 18)
pctLbl.Size        = UDim2.new(0, 320, 0, 22)
pctLbl.AnchorPoint = Vector2.new(0.5, 0)
-- same X centre as barTrack; sits just above it (barTrack is at 0.657, bar height 2px)
pctLbl.Position    = UDim2.new(0.5, 0, 0.636, 0)
pctLbl.ZIndex      = 202
pctLbl.TextXAlignment = Enum.TextXAlignment.Right   -- right-aligned inside the 320px width

-- glow clone
local pctGlowLbl = MakeLabel(bgBase, Enum.Font.GothamBold, "0%", Color3.fromRGB(0,200,230), 18)
pctGlowLbl.Size        = UDim2.new(0, 320, 0, 22)
pctGlowLbl.AnchorPoint = Vector2.new(0.5, 0)
pctGlowLbl.Position    = UDim2.new(0.5, 0, 0.636, 0)
pctGlowLbl.ZIndex      = 201
pctGlowLbl.TextXAlignment  = Enum.TextXAlignment.Right
pctGlowLbl.TextTransparency = 0.60

local STATUS_MSGS = {
    {t=0.00, msg="initializing..."},
    {t=0.12, msg="loading assets..."},
    {t=0.28, msg="connecting to rivals..."},
    {t=0.45, msg="checking integrity..."},
    {t=0.62, msg="warming up modules..."},
    {t=0.78, msg="almost there..."},
    {t=0.95, msg="ready"},
}

-- ──────────────────────────────────────────────────────────────
-- 10.  SOUND
-- ──────────────────────────────────────────────────────────────
local snd = Instance.new("Sound")
snd.SoundId = CFG.SOUND_ID
snd.Volume  = CFG.SOUND_VOLUME
snd.Looped  = false
snd.Parent  = CoreGui

task.spawn(function()
    -- Best executor audio trick: parent to SoundService directly
    -- SoundService plays sounds globally without 3D attenuation
    -- and most executors allow loading from there
    snd.Parent = game:GetService("SoundService")

    -- give it a moment to register
    task.wait(0.05)

    local tries = 0
    repeat task.wait(0.1); tries = tries + 1 until snd.IsLoaded or tries > 80

    if snd.IsLoaded then
        snd:Play()
    else
        -- last resort: clone into Players LocalPlayer
        snd.Parent = LocalPlayer
        tries = 0
        repeat task.wait(0.1); tries = tries + 1 until snd.IsLoaded or tries > 40
        if snd.IsLoaded then snd:Play() end
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 11.  FADE-IN SEQUENCER
-- ──────────────────────────────────────────────────────────────
local globalAlpha   = 0     -- 0→1 over ~1s, drives all Drawing transparency
local guiAlpha      = 0     -- 0→1 for ScreenGui elements
local FADE_START    = tick()
local FADE_DUR      = 1.1
local GUI_FADE_DELAY = 0.7  -- text fades in slightly after the flake

-- start bloom fade after short delay
task.delay(0.2, function()
    TweenService:Create(bloom, TweenInfo.new(1.2, Enum.EasingStyle.Quad),
        {BackgroundTransparency = 0.0}):Play()
end)

-- ──────────────────────────────────────────────────────────────
-- 12.  MAIN RENDER LOOP
-- ──────────────────────────────────────────────────────────────
local LOAD_START    = tick()
local TOTAL_TIME    = CFG.LOAD_DURATION
local centreRot     = 0
local loadDone      = false
local lastStatus    = ""
local time          = 0

local mainConn
mainConn = RunService.RenderStepped:Connect(function(dt)
    time = time + dt

    -- ── global alpha ramp (all Drawing objects fade in together)
    globalAlpha = math.clamp((time - 0.2) / FADE_DUR, 0, 1)
    -- smooth with ease-out
    local ga = globalAlpha * globalAlpha * (3 - 2*globalAlpha)   -- smoothstep

    -- ── GUI alpha (slightly delayed)
    guiAlpha = math.clamp((time - GUI_FADE_DELAY) / 0.8, 0, 1)
    local gua = guiAlpha * guiAlpha * (3 - 2*guiAlpha)

    -- ── progress
    local elapsed = tick() - LOAD_START
    local pct     = math.clamp(elapsed / TOTAL_TIME, 0, 1)

    -- ── 12a. Centre snowflake rotation (smooth, slow, elegant)
    centreRot = centreRot + dt * 0.35

    -- update centre flake segments
    for _, def in ipairs(centreDefs) do
        local from = def.fromFn(centreRot)
        local to   = def.toFn(centreRot)
        for li, line in ipairs(def.layers) do
            line.From        = from
            line.To          = to
            -- transparency: 1=invisible, approach baseAlpha × ga
            line.Transparency = 1 - def.layerAlpha[li] * ga
        end
    end

    -- centre rings
    for _, rd in ipairs(ringObjs) do
        rd.obj.Position    = Vec2(CX, CY)
        rd.obj.Transparency = 1 - rd.alpha * ga
    end

    -- ── 12b. Background flakes (slow counter-rotation, dimmer)
    for _, bf in ipairs(bgFlakes) do
        bf.rot = bf.rot + dt * bf.rotSpeed
        for _, def in ipairs(bf.defs) do
            local from = def.fromFn(bf.rot)
            local to   = def.toFn(bf.rot)
            for li, line in ipairs(def.layers) do
                line.From        = from
                line.To          = to
                -- bg flakes are dimmer — cap at layerAlpha * 0.6 * ga
                line.Transparency = 1 - def.layerAlpha[li] * 0.6 * ga
            end
        end
    end

    -- ── 12c. Bokeh particles — pulse + drift, CONSTRAINED to screen
    for _, pd in ipairs(bokehs) do
        -- drift
        pd.x = pd.x + pd.vx
        pd.y = pd.y + pd.vy

        -- wrap within viewport (not off screen)
        if pd.x < -60 then pd.x = VP.X + 50 end
        if pd.x > VP.X+60 then pd.x = -50 end
        if pd.y < -60 then pd.y = VP.Y + 50 end
        if pd.y > VP.Y+60 then pd.y = -50 end

        -- pulse alpha
        local pulse = 0.5 + 0.5*math.sin(time*pd.pulseSpeed + pd.pulseOffset)
        local finalA = pd.baseA * (0.55 + 0.45*pulse) * ga

        pd.obj.Position    = Vec2(pd.x, pd.y)
        pd.obj.Transparency = 1 - finalA
    end

    -- ── 12d. GUI elements
    if gua > 0 then
        titleLbl.TextTransparency    = 1 - gua
        creditLbl.TextTransparency   = 1 - gua
        statusLbl.TextTransparency   = 1 - gua
        barTrack.BackgroundTransparency = 1 - gua * 0.85
        pctLbl.TextTransparency      = 1 - gua
        pctGlowLbl.TextTransparency  = math.max(0.55, 1 - gua * 0.45)
    end

    -- bar fill
    barFill.Size = UDim2.new(pct, 0, 1, 0)

    -- ── displayed percentage — jumps in uneven increments, lags slightly
    --    behind the real progress so it feels like an async loader.
    do
        local now = tick()
        local realDisplay = math.floor(pct * 100)

        if now - lastJumpTime >= jumpInterval then
            -- find the next checkpoint that is <= real progress
            local target = realDisplay
            for i = jumpIdx, #PCT_JUMPS do
                if PCT_JUMPS[i] <= realDisplay then
                    target   = PCT_JUMPS[i]
                    jumpIdx  = i
                else
                    break
                end
            end

            if target ~= displayedPct then
                displayedPct  = target
                local txt     = tostring(displayedPct) .. "%"
                pctLbl.Text      = txt
                pctGlowLbl.Text  = txt
            end

            -- randomise next jump delay  (0.15 – 0.55 s)
            jumpInterval  = 0.15 + math.random() * 0.40
            lastJumpTime  = now
        end

        -- always snap to 100 when done
        if pct >= 1 and displayedPct < 100 then
            displayedPct = 100
            pctLbl.Text     = "100%"
            pctGlowLbl.Text = "100%"
        end
    end

    -- status text
    local msg = STATUS_MSGS[1].msg
    for _, e in ipairs(STATUS_MSGS) do
        if pct >= e.t then msg = e.msg end
    end
    if msg ~= lastStatus then
        statusLbl.Text = msg
        lastStatus = msg
    end

    -- ── 12e. DONE — fade everything out and clean up
    if pct >= 1 and not loadDone then
        loadDone = true
        mainConn:Disconnect()

        task.wait(0.55)   -- brief "ready" pause

        -- fade out all GUI frames
        local fi = TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(bgBase,      fi, {BackgroundTransparency=1}):Play()
        TweenService:Create(bloom,       fi, {BackgroundTransparency=1}):Play()
        TweenService:Create(titleLbl,    fi, {TextTransparency=1}):Play()
        TweenService:Create(creditLbl,   fi, {TextTransparency=1}):Play()
        TweenService:Create(statusLbl,   fi, {TextTransparency=1}):Play()
        TweenService:Create(pctLbl,      fi, {TextTransparency=1}):Play()
        TweenService:Create(pctGlowLbl,  fi, {TextTransparency=1}):Play()
        TweenService:Create(barTrack,    fi, {BackgroundTransparency=1}):Play()
        TweenService:Create(snd,         TweenInfo.new(0.9), {Volume=0}):Play()

        -- fade out + REMOVE all Drawing objects, then destroy GUI
        -- NOTE: Drawing objects live on the renderer, NOT inside sg.
        -- We must :Remove() every one before destroying sg, or they
        -- linger on screen forever (the blue dots bug).
        task.spawn(function()
            local fs  = tick()
            local dur = 1.1
            local done = false
            local fadeConn
            fadeConn = RunService.RenderStepped:Connect(function()
                local a = 1 - math.clamp((tick()-fs)/dur, 0, 1)
                a = a*a   -- ease-in quad

                -- centre flake
                for _, def in ipairs(centreDefs) do
                    for li, line in ipairs(def.layers) do
                        line.Transparency = 1 - def.layerAlpha[li] * a
                    end
                end
                -- bg flakes
                for _, bf in ipairs(bgFlakes) do
                    for _, def in ipairs(bf.defs) do
                        for li, line in ipairs(def.layers) do
                            line.Transparency = 1 - def.layerAlpha[li] * 0.6 * a
                        end
                    end
                end
                -- rings
                for _, rd in ipairs(ringObjs) do
                    rd.obj.Transparency = 1 - rd.alpha * a
                end
                -- bokeh / particles
                for _, pd in ipairs(bokehs) do
                    pd.obj.Transparency = 1 - pd.baseA * a
                end

                if a <= 0 and not done then
                    done = true
                    fadeConn:Disconnect()

                    -- Hard-remove every Drawing object immediately.
                    -- This must happen BEFORE sg:Destroy() so nothing
                    -- is left rendered on the screen afterwards.
                    for _, entry in ipairs(allDrawings) do
                        pcall(function() entry.obj:Remove() end)
                    end
                    table.clear(allDrawings)
                    table.clear(bokehs)
                    table.clear(ringObjs)
                    table.clear(centreDefs)
                    table.clear(bgFlakes)

                    -- Now safe to destroy the ScreenGui
                    sg:Destroy()
                end
            end)
        end)

        -- ══════════════════════════════════════════════════════
        -- PASTE YOUR MAIN SNOWY HUB SCRIPT BELOW THIS LINE
        -- ══════════════════════════════════════════════════════
    end
end)
