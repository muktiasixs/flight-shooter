-- audio.lua
-- Simple audio manager (memuat ww4git dari src/ww4git.lua)

local Audio = {}
Audio.musicVolume = 1.0
Audio.sfxVolume = 1.0
Audio.sources = {
    music = nil,
    sfx = {}
}
Audio.rsc = {}

local function safeExists(path)
    return path and love.filesystem.getInfo(path)
end

function Audio.load()
    local ok, r = pcall(require, "ww4git")
    if ok and type(r) == "table" then
        Audio.rsc = r
    else
        Audio.rsc = {}
    end

    -- load music (stream) if present
    if safeExists(Audio.rsc.theme_song) then
        if Audio.sources.music then Audio.sources.music:stop() end
        Audio.sources.music = love.audio.newSource(Audio.rsc.theme_song, "stream")
        Audio.sources.music:setLooping(true)
        Audio.sources.music:setVolume(Audio.musicVolume)
    else
        Audio.sources.music = nil
    end

    -- load sfx as static sources
    local sfxNames = { "bullet", "enemy", "player", "menu" }
    for _, name in ipairs(sfxNames) do
        local path = Audio.rsc[name]
        if safeExists(path) then
            local src = love.audio.newSource(path, "static")
            src:setVolume(Audio.sfxVolume)
            Audio.sources.sfx[name] = src
        else
            Audio.sources.sfx[name] = nil
        end
    end
end

function Audio.playMusic(name)
    if name == "theme_song" and Audio.sources.music then
        if not Audio.sources.music:isPlaying() then
            Audio.sources.music:play()
        end
        Audio.sources.music:setVolume(Audio.musicVolume)
    end
end

function Audio.stopMusic()
    if Audio.sources.music and Audio.sources.music:isPlaying() then
        Audio.sources.music:stop()
    end
end

function Audio.pauseMusic()
    if Audio.sources.music and Audio.sources.music:isPlaying() then
        Audio.sources.music:pause()
    end
end

function Audio.resumeMusic()
    if Audio.sources.music then
        -- :play() will resume if paused, or start if stopped
        Audio.sources.music:play()
        Audio.sources.music:setVolume(Audio.musicVolume)
    end
end

function Audio.setMusicVolume(v)
    Audio.musicVolume = math.max(0, math.min(1, v))
    if Audio.sources.music then
        Audio.sources.music:setVolume(Audio.musicVolume)
    else
        love.audio.setVolume(Audio.musicVolume) -- fallback
    end
end

function Audio.setSFXVolume(v)
    Audio.sfxVolume = math.max(0, math.min(1, v))
    for _, src in pairs(Audio.sources.sfx) do
        if src then src:setVolume(Audio.sfxVolume) end
    end
end

function Audio.getMusicVolume() return Audio.musicVolume end
function Audio.getSFXVolume() return Audio.sfxVolume end

-- play SFX by name (clone for overlap)
function Audio.playSFX(name)
    local src = Audio.sources.sfx[name]
    if src then
        local s = src:clone()
        s:setVolume(Audio.sfxVolume)
        s:play()
    end
end

-- initialize on require
Audio.load()

return Audio