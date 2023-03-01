{ arkenfox, toUserJS }:

let
  self = {
    arkenfox = builtins.readFile "${arkenfox}";
    default = self.arkenfox + toUserJS {
      "keyword.enabled" = true; # 0801
      "signon.rememberSignons" = false; # 0901
      "security.nocertdb" = true; # 1222
      "media.peerconnection.enabled" = false; # 2001
      "media.peerconnection.ice.no_host" = true; # 2004
      "dom.allow_cut_copy" = true; # 2404
      "dom.battery.enabled" = false; # 2502
      "permissions.default.xr" = 2; # 2521
      "privacy.clearOnShutdown.siteSettings" = true; # 2811

      # Personal
      ## Warnings
      "browser.tabs.warnOnClose" = false;
      "browser.tabs.warnOnCloseOtherTabs" = false;
      ## Updates
      "app.update.auto" = false;
      "browser.search.update" = false;
      ## Appearance
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      ## Content behavior
      "clipboard.autocopy" = false;
      ## UX behavior
      "browser.quitShortcut.disabled" = true;
      "browser.tabs.closeWindowWithLastTab" = false;
      ## UX features
      "extensions.pocket.enabled" = false;
      "identity.fxaccounts.enabled" = false;
    };

    streaming = self.default + toUserJS {
      # Widevine (DRMs)
      "media.gmp-widevinecdm.enabled" = true;
      "media.eme.enabled" = true;
      # Cache
      "browser.cache.disk.enable" = true;
      "browser.cache.offline.storage" = true;
      # Privacy
      "privacy.clearOnShutdown.cache" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown.siteSettings" = false;
      "privacy.clearOnShutdown.offlineApps" = false;
      "privacy.resistFingerprinting" = false; # Netflix is whining
    };

    videoconferencing = self.default + toUserJS {
      # IMPORTANT: uncheck "Prevent WebRTC from leaking local IP addresses" in uBlock Origin's settings
      # NOTE: if using RFP (4501)
      # some sites, e.g. Zoom, need a canvas site exception [Right Click>View Page Info>Permissions]
      # Discord video does not work: it thinks you are FF78: use a separate profile or spoof the user agent
      "media.peerconnection.enabled" = true;
      "media.peerconnection.ice.no_host" = false; # may or may not be required
      "webgl.disabled" = false; # required for Zoom
      "webgl.min_capability_mode" = false;
      "media.getusermedia.screensharing.enabled" = true; # optional
      "media.autoplay.blocking_policy" =
        0; # optional (otherwise add site exceptions)
      "javascript.options.wasm" =
        true; # optional (some platforms may require this)
      "dom.webaudio.enabled" = true;
    };
  };
in self
