local terminal = "ghostty"
local fileManager = "yazi"
local menu = "wofi --show drun"
local wallpaper_manager = "eval $WALLPAPER_MANAGER"

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us,us",
		kb_variant = ",dvorak",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind("CTRL + SUPER + ALT + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
-- Vim keybindings
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- resize keybindings
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
	hl.bind("H", hl.dsp.window.resize({ x = -15, y = 0, relative = true }), { repeating = true })
	hl.bind("L", hl.dsp.window.resize({ x = 15, y = 0, relative = true }), { repeating = true })
	hl.bind("K", hl.dsp.window.resize({ x = 0, y = -15, relative = true }), { repeating = true })
	hl.bind("J", hl.dsp.window.resize({ x = 0, y = 15, relative = true }), { repeating = true })

	hl.bind("left", hl.dsp.window.resize({ x = -15, y = 0, relative = true }), { repeating = true })
	hl.bind("right", hl.dsp.window.resize({ x = 15, y = 0, relative = true }), { repeating = true })
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = -15, relative = true }), { repeating = true })
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = 15, relative = true }), { repeating = true })

	-- Move focus with mainMod + arrow keys
	hl.bind("ALT" .. " + left", hl.dsp.focus({ direction = "left" }))
	hl.bind("ALT" .. " + right", hl.dsp.focus({ direction = "right" }))
	hl.bind("ALT" .. " + up", hl.dsp.focus({ direction = "up" }))
	hl.bind("ALT" .. " + down", hl.dsp.focus({ direction = "down" }))

	hl.bind("ALT" .. " + H", hl.dsp.focus({ direction = "left" }))
	hl.bind("ALT" .. " + L", hl.dsp.focus({ direction = "right" }))
	hl.bind("ALT" .. " + K", hl.dsp.focus({ direction = "up" }))
	hl.bind("ALT" .. " + J", hl.dsp.focus({ direction = "down" }))

	-- Allow to move to other modes
	hl.bind(mainMod .. " + B", hl.dsp.submap("move"))
	hl.bind(mainMod .. " + O", hl.dsp.submap("session"))

	-- Bind submap escape key
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- window move keybindings
hl.bind(mainMod .. " + B", hl.dsp.submap("move"))

hl.define_submap("move", function()
	hl.bind("H", hl.dsp.window.move({ direction = "left" }), { repeating = true })
	hl.bind("L", hl.dsp.window.move({ direction = "right" }), { repeating = true })
	hl.bind("K", hl.dsp.window.move({ direction = "up" }), { repeating = true })
	hl.bind("J", hl.dsp.window.move({ direction = "down" }), { repeating = true })

	hl.bind("left", hl.dsp.window.move({ direction = "left" }), { repeating = true })
	hl.bind("right", hl.dsp.window.move({ direction = "right" }), { repeating = true })
	hl.bind("up", hl.dsp.window.move({ direction = "up" }), { repeating = true })
	hl.bind("down", hl.dsp.window.move({ direction = "down" }), { repeating = true })

	-- Move focus with mainMod + arrow keys
	hl.bind("ALT" .. " + left", hl.dsp.focus({ direction = "left" }))
	hl.bind("ALT" .. " + right", hl.dsp.focus({ direction = "right" }))
	hl.bind("ALT" .. " + up", hl.dsp.focus({ direction = "up" }))
	hl.bind("ALT" .. " + down", hl.dsp.focus({ direction = "down" }))

	hl.bind("ALT" .. " + H", hl.dsp.focus({ direction = "left" }))
	hl.bind("ALT" .. " + L", hl.dsp.focus({ direction = "right" }))
	hl.bind("ALT" .. " + K", hl.dsp.focus({ direction = "up" }))
	hl.bind("ALT" .. " + J", hl.dsp.focus({ direction = "down" }))

	-- Allow to move to other modes
	hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
	hl.bind(mainMod .. " + O", hl.dsp.submap("session"))

	-- Bind submap escape keybindings
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Session options
hl.bind(mainMod .. " + O", hl.dsp.submap("session"))

hl.define_submap("session", function()
	hl.bind(
		"M",
		hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
	)
	hl.bind("S", hl.dsp.exec_cmd("shutdown now"))
	hl.bind("R", hl.dsp.exec_cmd("reboot"))

	hl.bind("N", function()
		hl.dispatch(hl.dsp.exec_cmd("eval $NOTIFICATION_OPEN"))
		hl.dispatch(hl.dsp.submap("reset"))
	end)

	-- Allow to move to other modes
	hl.bind(mainMod .. " + B", hl.dsp.submap("move"))
	hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

	-- Bind submap escape keybindings
	hl.bind("escape", hl.dsp.submap("reset"))
end)

for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e2 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e2 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
