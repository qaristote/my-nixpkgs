{
  arkenfox,
  toUserJS,
}:
let
  self = {
    arkenfox = builtins.readFile "${arkenfox}";
    default =
      self.arkenfox
      + toUserJS {
        "signon.rememberSignons" = false; # 0901
        "security.nocertdb" = true; # 1222
        "media.peerconnection.enabled" = false; # 2001
        "media.peerconnection.ice.no_host" = true; # 2004
        "dom.allow_cut_copy" = true; # 2404
        "dom.battery.enabled" = false; # 2502
        "permissions.default.xr" = 2; # 2521
        "browser.search.separatePrivateDefault" = false; # 0830
        "browser.search.separatePrivateDefault.ui.enabled" = false; # 0830

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

    streaming =
      self.default
      + toUserJS {
        # Cache
        "browser.cache.disk.enable" = true;
        "browser.cache.offline.storage" = true;
        # Privacy
        "privacy.clearOnShutdown_v2.cache" = false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      };

    videoconferencing =
      self.default
      + toUserJS {
        # IMPORTANT: uncheck "Prevent WebRTC from leaking local IP addresses" in uBlock Origin's settings
        # NOTE: if using RFP (4501)
        # some sites, e.g. Zoom, need a canvas site exception [Right Click>View Page Info>Permissions]
        # Discord video does not work: it thinks you are FF78: use a separate profile or spoof the user agent
        "media.peerconnection.enabled" = true;
        "media.peerconnection.ice.no_host" = false; # may or may not be required
        "webgl.min_capability_mode" = true;
        "media.autoplay.blocking_policy" = 0; # optional (otherwise add site exceptions)
        "javascript.options.wasm" = true; # optional (some platforms may require this)
        "dom.webaudio.enabled" = true;
      };
  };
in
self
