package main

import (
	"io"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"time"

	"barista.run"
	"barista.run/bar"
	"barista.run/colors"
	"barista.run/group"
	"barista.run/modules/battery"
	"barista.run/modules/clock"
	"barista.run/modules/diskspace"
	"barista.run/modules/funcs"
	"barista.run/modules/netinfo"
	"barista.run/modules/systemd"
	"barista.run/modules/volume"
	"barista.run/modules/volume/pulseaudio"
	"barista.run/modules/wlan"
	"barista.run/outputs"
	"barista.run/pango"
	"barista.run/pango/icons/mdi"
)

func main() {
	// Constants
	colors.LoadFromMap(map[string]string{
		// Color palette of Cezanne's Vue de la Baie de Marseille
		"good":     "#C5D294",
		"degraded": "#E9CC67",
		"bad":      "#FFBC88",
	})
	mdi.Load() // repo path will be inserted at build time

	// Display status of several services
	updateSuccessIcon := pango.Icon("mdi-reload")
	updatingIcon := pango.Icon("mdi-update")
	updateFailIcon := pango.Icon("mdi-reload-alert")
	garbageFullIcon := pango.Icon("mdi-delete")
	garbageEmptyingIcon := pango.Icon("mdi-delete-restore")
	garbageEmptyIcon := pango.Icon("mdi-delete-outline")
	barista.Add(group.Simple(systemd.Service("nixos-upgrade").Output(func(i systemd.ServiceInfo) bar.Output {
		state := i.UnitInfo.State
		var colorScheme string
		var output *pango.Node
		switch {
		case state == systemd.StateInactive:
			colorScheme = "good"
			output = updateSuccessIcon
		case state == systemd.StateActivating:
			colorScheme = "degraded"
			output = updatingIcon
		default:
			colorScheme = "bad"
			output = updateFailIcon
		}
		return outputs.Pango(output).Color(colors.Scheme(colorScheme))
	}),
		systemd.Service("nix-gc").Output(func(i systemd.ServiceInfo) bar.Output {
			state := i.UnitInfo.State
			var colorScheme string
			var output *pango.Node
			switch {
			case state == systemd.StateInactive:
				colorScheme = "good"
				output = garbageEmptyIcon
			case state == systemd.StateActivating:
				colorScheme = "degraded"
				output = garbageEmptyingIcon
			default:
				colorScheme = "bad"
				output = garbageFullIcon
			}
			return outputs.Pango(output).Color(colors.Scheme(colorScheme))
		})))

	// Display space left on /
	storageIcon := pango.Icon("mdi-database")
	barista.Add(diskspace.New("/").Output(func(i diskspace.Info) bar.Output {
		used := i.UsedPct()
		var colorScheme string
		if used >= 90 {
			colorScheme = "bad"
		} else if used >= 50 {
			colorScheme = "degraded"
		} else {
			colorScheme = "good"
		}
		return outputs.Pango(storageIcon, pango.Textf(" %d%%", used)).Color(colors.Scheme(colorScheme))
	}))

	// Check connection to the Mullvad VPN
	mullvadIsUpRe := regexp.MustCompile(`^You are connected to Mullvad`)
	mullvadServerRe := regexp.MustCompile(`\(server (.*)\)`)
	mullvadIpRe := regexp.MustCompile(`Your IP address is (.*)`)
	client := &http.Client{Timeout: 3 * time.Second}
	incognitoIcon := pango.Icon("mdi-incognito")
	incognitoOffIcon := pango.Icon("mdi-incognito-off")
	barista.Add(funcs.Every(5*time.Second, func(s bar.Sink) {
		icon := incognitoOffIcon
		message := pango.Text("")
		colorScheme := "bad"
		res, err := client.Get("https://am.i.mullvad.net/connected")
		if !s.Error(err) {
			status, err := io.ReadAll(res.Body)
			res.Body.Close()
			if !s.Error(err) {
				var re *regexp.Regexp
				if mullvadIsUpRe.Match(status) {
					re = mullvadServerRe
					colorScheme = "good"
					icon = incognitoIcon
				} else {
					re = mullvadIpRe
					colorScheme = "degraded"
				}
				result := re.FindSubmatch(status)
				if len(result) >= 2 {
					message = pango.Textf(" %s", result[1])
				}
			}
		}
		client.CloseIdleConnections()
		s.Output(outputs.Pango(icon, message).Color(colors.Scheme(colorScheme)))
	}))

	// Display the wifi status
	wifiOffIcon := pango.Icon("mdi-wifi-off")
	wifiRefreshIcon := pango.Icon("mdi-wifi-refresh")
	wifiOnIcon := pango.Icon("mdi-wifi")
	barista.Add(wlan.Named("wlp2s0").Output(func(w wlan.Info) bar.Output {
		var output *pango.Node
		var colorScheme string
		switch {
		case w.Connected():
			output = pango.New(wifiOnIcon, pango.Textf(" %s", w.SSID))
			colorScheme = "good"
		case w.Connecting():
			output = wifiRefreshIcon
			colorScheme = "degraded"
		default:
			output = wifiOffIcon
			colorScheme = "bad"
		}
		return outputs.Pango(output).Color(colors.Scheme(colorScheme))
	}))

	// Display the ethernet status
	ethernetCableOnIcon := pango.Icon("mdi-ethernet-cable")
	ethernetCableOffIcon := pango.Icon("mdi-ethernet-cable-off")
	barista.Add(netinfo.Prefix("e").Output(func(s netinfo.State) bar.Output {
		var output *pango.Node
		var colorScheme string
		switch {
		case s.Connected():
			ip := "<no ip>"
			if len(s.IPs) > 0 {
				ip = s.IPs[0].String()
			}
			output = pango.New(ethernetCableOnIcon, pango.Textf(" %s", ip))
			colorScheme = "good"
		case s.Connecting():
			output = ethernetCableOnIcon
			colorScheme = "degraded"
		default:
			output = ethernetCableOffIcon
			colorScheme = "bad"
		}
		return outputs.Pango(output).Color(colors.Scheme(colorScheme))
	}))

	// Display the battery status
	batteryIcons := [11]*pango.Node{pango.Icon("mdi-battery-outline"),
		pango.Icon("mdi-battery-10"),
		pango.Icon("mdi-battery-20"),
		pango.Icon("mdi-battery-30"),
		pango.Icon("mdi-battery-40"),
		pango.Icon("mdi-battery-50"),
		pango.Icon("mdi-battery-60"),
		pango.Icon("mdi-battery-70"),
		pango.Icon("mdi-battery-80"),
		pango.Icon("mdi-battery-90"),
		pango.Icon("mdi-battery")}
	batteryChargingIcons := [11]*pango.Node{pango.Icon("mdi-battery-charging-outline"),
		pango.Icon("mdi-battery-charging-10"),
		pango.Icon("mdi-battery-charging-20"),
		pango.Icon("mdi-battery-charging-30"),
		pango.Icon("mdi-battery-charging-40"),
		pango.Icon("mdi-battery-charging-50"),
		pango.Icon("mdi-battery-charging-60"),
		pango.Icon("mdi-battery-charging-70"),
		pango.Icon("mdi-battery-charging-80"),
		pango.Icon("mdi-battery-charging-90"),
		pango.Icon("mdi-battery-charging-100")}
	barista.Add(battery.All().Output(func(b battery.Info) bar.Output {
		switch b.Status {
		case battery.Disconnected, battery.Unknown:
			return nil
		default:
			var icons [11]*pango.Node
			var colorScheme string
			if b.Status == battery.Charging {
				icons = batteryChargingIcons
				colorScheme = "good"
			} else {
				icons = batteryIcons
				if b.RemainingPct() <= 10 {
					colorScheme = "bad"
				} else if b.RemainingPct() <= 20 {
					colorScheme = "degraded"
				} else {
					colorScheme = "good"
				}
			}
			icon := icons[b.RemainingPct()/10]
			return outputs.Pango(icon, pango.Textf(" %d%%", b.RemainingPct())).Color(colors.Scheme(colorScheme))
		}
	}))

	// Display brightness
	brightnessHighIcon := pango.Icon("mdi-lightbulb-on")
	brightnessMidIcon := pango.Icon("mdi-lightbulb-on-outline")
	brightnessLowIcon := pango.Icon("mdi-lightbulb-outline")
	ReadBrightness := func(name string) (int, error) {
		valueStr, err := os.ReadFile("/sys/class/backlight/intel_backlight/" + name)
		if err != nil {
			return 0, err
		}
		return strconv.Atoi(string(valueStr[:len(valueStr)-1]))
	}
	brightnessMax, _ := ReadBrightness("max_brightness") // always non-zero, unless there's an error
	barista.Add(funcs.Every(time.Second, func(s bar.Sink) {
		brightness, err := ReadBrightness("brightness")
		if !s.Error(err) {
			value := (brightness * 100) / brightnessMax
			var icon *pango.Node
			if value <= 30 {
				icon = brightnessLowIcon
			} else if value < 70 {
				icon = brightnessMidIcon
			} else {
				icon = brightnessHighIcon
			}
			s.Output(outputs.Pango(icon, pango.Textf(" %d%%", value)))
		}
	}))

	// Display output volume
	volumeOffIcon := pango.Icon("mdi-volume-variant-off")
	volumeLowIcon := pango.Icon("mdi-volume-low")
	volumeMidIcon := pango.Icon("mdi-volume-medium")
	volumeHighIcon := pango.Icon("mdi-volume-high")
	barista.Add(volume.New(pulseaudio.DefaultSink()).Output(func(v volume.Volume) bar.Output {
		volume := v.Pct()
		var icon *pango.Node
		if volume == 0 || v.Mute {
			icon = volumeOffIcon
		} else if volume <= 30 {
			icon = volumeLowIcon
		} else if volume <= 70 {
			icon = volumeMidIcon
		} else {
			icon = volumeHighIcon
		}
		return outputs.Pango(icon, pango.Textf(" %d%%", volume))
	}))

	// Display microphone volume
	microphoneOffIcon := pango.Icon("mdi-microphone-off")
	microphoneIcon := pango.Icon("mdi-microphone")
	barista.Add(volume.New(pulseaudio.DefaultSource()).Output(func(v volume.Volume) bar.Output {
		volume := v.Pct() // the value returned by pulseaudio may be weird
		var icon *pango.Node
		if volume == 0 || v.Mute {
			icon = microphoneOffIcon
		} else {
			icon = microphoneIcon
		}
		return outputs.Pango(icon, pango.Textf(" %d%%", volume))
	}))

	barista.Add(clock.Local().OutputFormat("2006-01-02 15:04:05"))

	panic(barista.Run())
}
