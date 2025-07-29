{
  buildFirefoxXpiAddon,
  lib,
  ...
}:
{
  "add-custom-search-engine" = buildFirefoxXpiAddon {
    pname = "add-custom-search-engine";
    version = "4.2";
    addonId = "{af37054b-3ace-46a2-ac59-709e4412bec6}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3812756/add_custom_search_engine-4.2.xpi";
    sha256 = "86aaf173514ec2da55556eb339a9d7c115c6e070c5433ebff8db31baa8e165d5";
    meta = with lib; {
      description = "Add a custom search engine to the list of available search engines in the search bar and URL bar.";
      license = licenses.mpl20;
      mozPermissions = [
        "https://paste.mozilla.org/api/"
        "search"
      ];
      platforms = platforms.all;
    };
  };
  "canvasblocker" = buildFirefoxXpiAddon {
    pname = "canvasblocker";
    version = "1.10.1";
    addonId = "CanvasBlocker@kkapsner.de";
    url = "https://addons.mozilla.org/firefox/downloads/file/4262820/canvasblocker-1.10.1.xpi";
    sha256 = "dae3b648f0b559b8b08cdad8adaaba2fcde3aa7baf0ffe9b2cbca5a3373c98b7";
    meta = with lib; {
      homepage = "https://github.com/kkapsner/CanvasBlocker/";
      description = "Alters some JS APIs to prevent fingerprinting.";
      license = licenses.mpl20;
      mozPermissions = [
        "<all_urls>"
        "storage"
        "tabs"
        "webRequest"
        "webRequestBlocking"
        "contextualIdentities"
        "cookies"
        "privacy"
      ];
      platforms = platforms.all;
    };
  };
  "clearurls" = buildFirefoxXpiAddon {
    pname = "clearurls";
    version = "1.26.1";
    addonId = "{74145f27-f039-47ce-a470-a662b129930a}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4064884/clearurls-1.26.1.xpi";
    sha256 = "e20168d63cb1b8ba3ad0de4cdb42c540d99fe00aa9679b59f49bccc36f106291";
    meta = with lib; {
      homepage = "https://clearurls.xyz/";
      description = "Removes tracking elements from URLs";
      license = licenses.lgpl3;
      mozPermissions = [
        "<all_urls>"
        "webRequest"
        "webRequestBlocking"
        "storage"
        "unlimitedStorage"
        "contextMenus"
        "webNavigation"
        "tabs"
        "downloads"
        "*://*.google.com/*"
        "*://*.google.ad/*"
        "*://*.google.ae/*"
        "*://*.google.com.af/*"
        "*://*.google.com.ag/*"
        "*://*.google.com.ai/*"
        "*://*.google.al/*"
        "*://*.google.am/*"
        "*://*.google.co.ao/*"
        "*://*.google.com.ar/*"
        "*://*.google.as/*"
        "*://*.google.at/*"
        "*://*.google.com.au/*"
        "*://*.google.az/*"
        "*://*.google.ba/*"
        "*://*.google.com.bd/*"
        "*://*.google.be/*"
        "*://*.google.bf/*"
        "*://*.google.bg/*"
        "*://*.google.com.bh/*"
        "*://*.google.bi/*"
        "*://*.google.bj/*"
        "*://*.google.com.bn/*"
        "*://*.google.com.bo/*"
        "*://*.google.com.br/*"
        "*://*.google.bs/*"
        "*://*.google.bt/*"
        "*://*.google.co.bw/*"
        "*://*.google.by/*"
        "*://*.google.com.bz/*"
        "*://*.google.ca/*"
        "*://*.google.cd/*"
        "*://*.google.cf/*"
        "*://*.google.cg/*"
        "*://*.google.ch/*"
        "*://*.google.ci/*"
        "*://*.google.co.ck/*"
        "*://*.google.cl/*"
        "*://*.google.cm/*"
        "*://*.google.cn/*"
        "*://*.google.com.co/*"
        "*://*.google.co.cr/*"
        "*://*.google.com.cu/*"
        "*://*.google.cv/*"
        "*://*.google.com.cy/*"
        "*://*.google.cz/*"
        "*://*.google.de/*"
        "*://*.google.dj/*"
        "*://*.google.dk/*"
        "*://*.google.dm/*"
        "*://*.google.com.do/*"
        "*://*.google.dz/*"
        "*://*.google.com.ec/*"
        "*://*.google.ee/*"
        "*://*.google.com.eg/*"
        "*://*.google.es/*"
        "*://*.google.com.et/*"
        "*://*.google.fi/*"
        "*://*.google.com.fj/*"
        "*://*.google.fm/*"
        "*://*.google.fr/*"
        "*://*.google.ga/*"
        "*://*.google.ge/*"
        "*://*.google.gg/*"
        "*://*.google.com.gh/*"
        "*://*.google.com.gi/*"
        "*://*.google.gl/*"
        "*://*.google.gm/*"
        "*://*.google.gp/*"
        "*://*.google.gr/*"
        "*://*.google.com.gt/*"
        "*://*.google.gy/*"
        "*://*.google.com.hk/*"
        "*://*.google.hn/*"
        "*://*.google.hr/*"
        "*://*.google.ht/*"
        "*://*.google.hu/*"
        "*://*.google.co.id/*"
        "*://*.google.ie/*"
        "*://*.google.co.il/*"
        "*://*.google.im/*"
        "*://*.google.co.in/*"
        "*://*.google.iq/*"
        "*://*.google.is/*"
        "*://*.google.it/*"
        "*://*.google.je/*"
        "*://*.google.com.jm/*"
        "*://*.google.jo/*"
        "*://*.google.co.jp/*"
        "*://*.google.co.ke/*"
        "*://*.google.com.kh/*"
        "*://*.google.ki/*"
        "*://*.google.kg/*"
        "*://*.google.co.kr/*"
        "*://*.google.com.kw/*"
        "*://*.google.kz/*"
        "*://*.google.la/*"
        "*://*.google.com.lb/*"
        "*://*.google.li/*"
        "*://*.google.lk/*"
        "*://*.google.co.ls/*"
        "*://*.google.lt/*"
        "*://*.google.lu/*"
        "*://*.google.lv/*"
        "*://*.google.com.ly/*"
        "*://*.google.co.ma/*"
        "*://*.google.md/*"
        "*://*.google.me/*"
        "*://*.google.mg/*"
        "*://*.google.mk/*"
        "*://*.google.ml/*"
        "*://*.google.com.mm/*"
        "*://*.google.mn/*"
        "*://*.google.ms/*"
        "*://*.google.com.mt/*"
        "*://*.google.mu/*"
        "*://*.google.mv/*"
        "*://*.google.mw/*"
        "*://*.google.com.mx/*"
        "*://*.google.com.my/*"
        "*://*.google.co.mz/*"
        "*://*.google.com.na/*"
        "*://*.google.com.nf/*"
        "*://*.google.com.ng/*"
        "*://*.google.com.ni/*"
        "*://*.google.ne/*"
        "*://*.google.nl/*"
        "*://*.google.no/*"
        "*://*.google.com.np/*"
        "*://*.google.nr/*"
        "*://*.google.nu/*"
        "*://*.google.co.nz/*"
        "*://*.google.com.om/*"
        "*://*.google.com.pa/*"
        "*://*.google.com.pe/*"
        "*://*.google.com.pg/*"
        "*://*.google.com.ph/*"
        "*://*.google.com.pk/*"
        "*://*.google.pl/*"
        "*://*.google.pn/*"
        "*://*.google.com.pr/*"
        "*://*.google.ps/*"
        "*://*.google.pt/*"
        "*://*.google.com.py/*"
        "*://*.google.com.qa/*"
        "*://*.google.ro/*"
        "*://*.google.ru/*"
        "*://*.google.rw/*"
        "*://*.google.com.sa/*"
        "*://*.google.com.sb/*"
        "*://*.google.sc/*"
        "*://*.google.se/*"
        "*://*.google.com.sg/*"
        "*://*.google.sh/*"
        "*://*.google.si/*"
        "*://*.google.sk/*"
        "*://*.google.com.sl/*"
        "*://*.google.sn/*"
        "*://*.google.so/*"
        "*://*.google.sm/*"
        "*://*.google.sr/*"
        "*://*.google.st/*"
        "*://*.google.com.sv/*"
        "*://*.google.td/*"
        "*://*.google.tg/*"
        "*://*.google.co.th/*"
        "*://*.google.com.tj/*"
        "*://*.google.tk/*"
        "*://*.google.tl/*"
        "*://*.google.tm/*"
        "*://*.google.tn/*"
        "*://*.google.to/*"
        "*://*.google.com.tr/*"
        "*://*.google.tt/*"
        "*://*.google.com.tw/*"
        "*://*.google.co.tz/*"
        "*://*.google.com.ua/*"
        "*://*.google.co.ug/*"
        "*://*.google.co.uk/*"
        "*://*.google.com.uy/*"
        "*://*.google.co.uz/*"
        "*://*.google.com.vc/*"
        "*://*.google.co.ve/*"
        "*://*.google.vg/*"
        "*://*.google.co.vi/*"
        "*://*.google.com.vn/*"
        "*://*.google.vu/*"
        "*://*.google.ws/*"
        "*://*.google.rs/*"
        "*://*.google.co.za/*"
        "*://*.google.co.zm/*"
        "*://*.google.co.zw/*"
        "*://*.google.cat/*"
        "*://*.yandex.ru/*"
        "*://*.yandex.com/*"
        "*://*.ya.ru/*"
      ];
      platforms = platforms.all;
    };
  };
  "darkreader" = buildFirefoxXpiAddon {
    pname = "darkreader";
    version = "4.9.96";
    addonId = "addon@darkreader.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/4378073/darkreader-4.9.96.xpi";
    sha256 = "6e2f1a36d2398195b0cd7ee0fcb198ea4db6a57a1b3bf7b2cf5f17a8768f477e";
    meta = with lib; {
      homepage = "https://darkreader.org/";
      description = "Dark mode for every website. Take care of your eyes, use dark theme for night and daily browsing.";
      license = licenses.mit;
      mozPermissions = [
        "alarms"
        "contextMenus"
        "storage"
        "tabs"
        "theme"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "floccus" = buildFirefoxXpiAddon {
    pname = "floccus";
    version = "5.3.4";
    addonId = "floccus@handmadeideas.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/4389599/floccus-5.3.4.xpi";
    sha256 = "8a7c9e3626e0ab0a017a887b379d0af20e0653ecc05a5fbada17d0244629ba47";
    meta = with lib; {
      homepage = "https://floccus.org";
      description = "Sync your bookmarks and tabs across browsers via Nextcloud, any WebDAV service, any Git service, via a local file, via Google Drive.";
      license = licenses.mpl20;
      mozPermissions = [
        "*://*/*"
        "alarms"
        "bookmarks"
        "storage"
        "unlimitedStorage"
        "tabs"
        "identity"
      ];
      platforms = platforms.all;
    };
  };
  "multi-account-containers" = buildFirefoxXpiAddon {
    pname = "multi-account-containers";
    version = "8.2.0";
    addonId = "@testpilot-containers";
    url = "https://addons.mozilla.org/firefox/downloads/file/4355970/multi_account_containers-8.2.0.xpi";
    sha256 = "1ce35650853973572bc1ce770076d93e00b6b723b799f7b90c3045268c64b422";
    meta = with lib; {
      homepage = "https://github.com/mozilla/multi-account-containers/#readme";
      description = "Firefox Multi-Account Containers lets you keep parts of your online life separated into color-coded tabs. Cookies are separated by container, allowing you to use the web with multiple accounts and integrate Mozilla VPN for an extra layer of privacy.";
      license = licenses.mpl20;
      mozPermissions = [
        "<all_urls>"
        "activeTab"
        "cookies"
        "contextMenus"
        "contextualIdentities"
        "history"
        "idle"
        "management"
        "storage"
        "unlimitedStorage"
        "tabs"
        "webRequestBlocking"
        "webRequest"
      ];
      platforms = platforms.all;
    };
  };
  "neat-url" = buildFirefoxXpiAddon {
    pname = "neat-url";
    version = "5.0.0";
    addonId = "neaturl@hugsmile.eu";
    url = "https://addons.mozilla.org/firefox/downloads/file/3557562/neat_url-5.0.0.xpi";
    sha256 = "0b41899ea0eb424517bbe7ce067eae22de0ff659a0f171671e604edef86cfa2c";
    meta = with lib; {
      homepage = "https://github.com/Smile4ever/Neat-URL";
      description = "Remove garbage from URLs.";
      license = licenses.gpl2;
      mozPermissions = [
        "storage"
        "notifications"
        "contextMenus"
        "webRequest"
        "webRequestBlocking"
        "tabs"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "redirector" = buildFirefoxXpiAddon {
    pname = "redirector";
    version = "3.5.3";
    addonId = "redirector@einaregilsson.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/3535009/redirector-3.5.3.xpi";
    sha256 = "eddbd3d5944e748d0bd6ecb6d9e9cf0e0c02dced6f42db21aab64190e71c0f71";
    meta = with lib; {
      homepage = "http://einaregilsson.com/redirector/";
      description = "Automatically redirects to user-defined urls on certain pages";
      license = licenses.mit;
      mozPermissions = [
        "webRequest"
        "webRequestBlocking"
        "webNavigation"
        "storage"
        "tabs"
        "http://*/*"
        "https://*/*"
        "notifications"
      ];
      platforms = platforms.all;
    };
  };
  "smart-referer" = buildFirefoxXpiAddon {
    pname = "smart-referer";
    version = "0.2.15";
    addonId = "smart-referer@meh.paranoid.pk";
    url = "https://addons.mozilla.org/firefox/downloads/file/3470999/smart_referer-0.2.15.xpi";
    sha256 = "4751ab905c4d9d13b1f21c9fc179efed7d248e3476effb5b393268b46855bf1a";
    meta = with lib; {
      homepage = "https://gitlab.com/smart-referer/smart-referer";
      description = "Improve your privacy by limiting Referer information leak!\n\nPlease note that this extension has been largely superseded by better browser defaults for websites using HTTPS (almost all) and is not maintained anymore.";
      mozPermissions = [
        "menus"
        "storage"
        "theme"
        "webRequest"
        "webRequestBlocking"
        "*://*/*"
      ];
      platforms = platforms.all;
    };
  };
  "temporary-containers" = buildFirefoxXpiAddon {
    pname = "temporary-containers";
    version = "1.9.2";
    addonId = "{c607c8df-14a7-4f28-894f-29e8722976af}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3723251/temporary_containers-1.9.2.xpi";
    sha256 = "3340a08c29be7c83bd0fea3fc27fde71e4608a4532d932114b439aa690e7edc0";
    meta = with lib; {
      homepage = "https://github.com/stoically/temporary-containers";
      description = "Open tabs, websites, and links in automatically managed disposable containers which isolate the data websites store (cookies, storage, and more) from each other, enhancing your privacy and security while you browse.";
      license = licenses.mit;
      mozPermissions = [
        "<all_urls>"
        "contextMenus"
        "contextualIdentities"
        "cookies"
        "management"
        "storage"
        "tabs"
        "webRequest"
        "webRequestBlocking"
      ];
      platforms = platforms.all;
    };
  };
  "tree-style-tab" = buildFirefoxXpiAddon {
    pname = "tree-style-tab";
    version = "4.0.25";
    addonId = "treestyletab@piro.sakura.ne.jp";
    url = "https://addons.mozilla.org/firefox/downloads/file/4386321/tree_style_tab-4.0.25.xpi";
    sha256 = "c228594161f3a436b74778ac6bfef0288c00639eb1f2a1e5d6cddacfa8af2ea6";
    meta = with lib; {
      homepage = "http://piro.sakura.ne.jp/xul/_treestyletab.html.en";
      description = "Show tabs like a tree.";
      mozPermissions = [
        "activeTab"
        "contextualIdentities"
        "cookies"
        "menus"
        "menus.overrideContext"
        "notifications"
        "search"
        "sessions"
        "storage"
        "tabs"
        "theme"
      ];
      platforms = platforms.all;
    };
  };
  "ublock-origin" = buildFirefoxXpiAddon {
    pname = "ublock-origin";
    version = "1.61.2";
    addonId = "uBlock0@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/4391011/ublock_origin-1.61.2.xpi";
    sha256 = "ee3a724a46ff32c17d1723077fecc6ede7fdab742154020b51fb6253ddcbba14";
    meta = with lib; {
      homepage = "https://github.com/gorhill/uBlock#ublock-origin";
      description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
      license = licenses.gpl3;
      mozPermissions = [
        "alarms"
        "dns"
        "menus"
        "privacy"
        "storage"
        "tabs"
        "unlimitedStorage"
        "webNavigation"
        "webRequest"
        "webRequestBlocking"
        "<all_urls>"
        "http://*/*"
        "https://*/*"
        "file://*/*"
        "https://easylist.to/*"
        "https://*.fanboy.co.nz/*"
        "https://filterlists.com/*"
        "https://forums.lanik.us/*"
        "https://github.com/*"
        "https://*.github.io/*"
        "https://github.com/uBlockOrigin/*"
        "https://ublockorigin.github.io/*"
        "https://*.reddit.com/r/uBlockOrigin/*"
      ];
      platforms = platforms.all;
    };
  };
  "unpaywall" = buildFirefoxXpiAddon {
    pname = "unpaywall";
    version = "3.98";
    addonId = "{f209234a-76f0-4735-9920-eb62507a54cd}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3816853/unpaywall-3.98.xpi";
    sha256 = "6893bea86d3c4ed7f1100bf0e173591b526a062f4ddd7be13c30a54573c797fb";
    meta = with lib; {
      homepage = "https://unpaywall.org/products/extension";
      description = "Get free text of research papers as you browse, using Unpaywall's index of ten million legal, open-access articles.";
      license = licenses.mit;
      mozPermissions = [
        "*://*.oadoi.org/*"
        "storage"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
  "url-in-title" = buildFirefoxXpiAddon {
    pname = "url-in-title";
    version = "0.6resigned1";
    addonId = "{fcdb71fb-c9e5-48a3-9d04-e32713f5da88}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4271802/url_in_title-0.6resigned1.xpi";
    sha256 = "a20bc859e834f423c54140260e9401f6df1347e749b92effb561bd9cfee973a4";
    meta = with lib; {
      homepage = "https://github.com/cloutierjo/titleUrl";
      description = "Add the current host name to the windows title bar. It adds the possibility to recognize the window from other application that work based on windows titles like KeePass's autotype.";
      license = licenses.gpl3;
      mozPermissions = [
        "<all_urls>"
        "tabs"
        "storage"
      ];
      platforms = platforms.all;
    };
  };
}
