# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    #./hardware-configuration.nix
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    inputs.nur.nixosModules.nur
    inputs.stylix.nixosModules.stylix
  ];
  #stylix.image = "/home/main/Pictures/lenin_in_smolny.png";
  #stylix.image = "/home/main/Pictures/desert-unsplash.jpg";
  stylix.image = "/home/main/Pictures/frost.jpg";
  #stylix.base16Scheme = "${inputs.base16-schemes}/catppuccin-latte.yaml";
  stylix.base16Scheme = "${inputs.base16-schemes}/one-light.yaml";
  stylix.fonts = {
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };

    sansSerif = {
      package = pkgs.roboto;
      name = "Roboto Light";
    };

    monospace = {
      package = pkgs.roboto-mono;
      name = "Roboto Mono Light";
    };
    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
    sizes = { desktop = 13; };
  };
  stylix.autoEnable = true;
  programs.dconf.enable = true;
  nixpkgs.overlays = [ inputs.nur.overlay inputs.emacs.overlay ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod;
  boot.kernelParams = [ "i915.enable_guc=0" "i915.enable_gvt=1" "intel_iommu=on"
                        "usbhid.mousepoll=1" "usbhid.kbpoll=1"
                        #"mitigations=off"
                      ];
  environment.persistence."/nix/persist/system" = {
    directories = [
      #"/etc/nixos" # bind mounted from /nix/persist/system/etc/nixos to /etc/nixos
      "/etc/NetworkManager"
      "/etc/mullvad-vpn"
      "/var/log"
      "/var/lib"
    ];
    files = [ "/etc/nix/id_rsa" ];
  };
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-unstable";
  };
  programs.hyprland.enable = true;

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
  services.throttled = {
    enable = true;
    extraConfig = ''
      [GENERAL]
      # Enable or disable the script execution
      Enabled: True
      # SYSFS path for checking if the system is running on AC power
      Sysfs_Power_Path: /sys/class/power_supply/AC*/online
      # Auto reload config on changes
      Autoreload: True

      ## Settings to apply while connected to Battery power
      [BATTERY]
      # Update the registers every this many seconds
      Update_Rate_s: 30
      # Max package power for time window #1
      PL1_Tdp_W: 29
      # Time window #1 duration
      PL1_Duration_s: 28
      # Max package power for time window #2
      PL2_Tdp_W: 44
      # Time window #2 duration
      PL2_Duration_S: 0.002
      # Max allowed temperature before throttling
      Trip_Temp_C: 85
      # Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
      cTDP: 0
      # Disable BDPROCHOT (EXPERIMENTAL)
      Disable_BDPROCHOT: False

      ## Settings to apply while connected to AC power
      [AC]
      # Update the registers every this many seconds
      Update_Rate_s: 5
      # Max package power for time window #1
      PL1_Tdp_W: 44
      # Time window #1 duration
      PL1_Duration_s: 28
      # Max package power for time window #2
      PL2_Tdp_W: 44
      # Time window #2 duration
      PL2_Duration_S: 0.002
      # Max allowed temperature before throttling
      Trip_Temp_C: 95
      # Set HWP energy performance hints to 'performance' on high load (EXPERIMENTAL)
      # Uncomment only if you really want to use it
      # HWP_Mode: False
      # Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
      cTDP: 0
      # Disable BDPROCHOT (EXPERIMENTAL)
      Disable_BDPROCHOT: False

      # All voltage values are expressed in mV and *MUST* be negative (i.e. undervolt)! 
      [UNDERVOLT.BATTERY]
      # CPU core voltage offset (mV)
      CORE: -100
      # Integrated GPU voltage offset (mV)
      GPU: -50
      # CPU cache voltage offset (mV)
      CACHE: -100
      # System Agent voltage offset (mV)
      UNCORE: 0
      # Analog I/O voltage offset (mV)
      ANALOGIO: 0

      # All voltage values are expressed in mV and *MUST* be negative (i.e. undervolt)!
      [UNDERVOLT.AC]
      # CPU core voltage offset (mV)
      CORE: -100
      # Integrated GPU voltage offset (mV)
      GPU: -50
      # CPU cache voltage offset (mV)
      CACHE: -100
      # System Agent voltage offset (mV)
      UNCORE: 0
      # Analog I/O voltage offset (mV)
      ANALOGIO: 0

      # [ICCMAX.AC]
      # # CPU core max current (A)
      # CORE: 
      # # Integrated GPU max current (A)
      # GPU: 
      # # CPU cache max current (A)
      # CACHE: 

      # [ICCMAX.BATTERY]
      # # CPU core max current (A)
      # CORE: 
      # # Integrated GPU max current (A)
      # GPU: 
      # # CPU cache max current (A)
      # CACHE: 
    '';
  };
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = 8;
      auto-optimise-store = true;

      cores = 8;
      substituters =
        [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    git
    linuxKernel.packages.linux_xanmod.cpupower
    ncdu
    neovim
    nixfmt
    hyprland
    xwayland
    wayland
    glib
    glibc
    swaylock
    swayidle
    wob
    grim
    slurp
    wl-clipboard
    bemenu
    mako
    sqlite
    gcc
    gcc-unwrapped.lib
    python3
    gotop
    brightnessctl
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk 
    #pkgs.xdg-desktop-portal-wlr 
    ];
    gtkUsePortal = true;
  };
  services.auto-cpufreq = { enable = true; };
  services.thermald.enable = true;

  # enable sway window manager
  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
    wrapperFeatures.gtk = true;
  };

  services.locate = {
    enable = true;
    locate = pkgs.mlocate;
    interval = "daily";
  };

  services.gvfs.enable = true;
  # just get graphics stuff set up ezpz
  #programs.steam = {
    #enable = true;
    #package = with pkgs; steam.override { extraPkgs = pkgs: [ attr ]; };
    #remotePlay.openFirewall =
      #true; # Open ports in the firewall for Steam Remote Play
    #dedicatedServer.openFirewall =
      #true; # Open ports in the firewall for Source Dedicated Server
  #};
  security.polkit.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver vaapiIntel ];
  };
  #zramSwap.enable = true;
  networking.firewall.checkReversePath = "loose";
  networking.wireguard.enable = true;
  services.mullvad-vpn.enable = true;

  location.provider = "geoclue2";
  services.redshift = { enable = true; };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  hardware.bluetooth.enable = true;

  networking.hostName = "t480"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.desktopManager.gnome3.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "gb";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.adb.enable = true;
  users.mutableUsers = false;
  programs.zsh.enable=true;
  users.defaultUserShell = pkgs.zsh;
  users.users.root.initialHashedPassword =
    "$6$uWf3HxeGw5sp8J93$f0QkwIq1wGx6.gl3Oxpgc3gjATBhM2TIIBP8G7moyH1viVsP2U2Ht4UwFL8U30y2S6FRnI/Z3/FuRzV2mO7NB1";
  users.users.main = {
    isNormalUser = true;
    initialHashedPassword =
      "$6$uWf3HxeGw5sp8J93$f0QkwIq1wGx6.gl3Oxpgc3gjATBhM2TIIBP8G7moyH1viVsP2U2Ht4UwFL8U30y2S6FRnI/Z3/FuRzV2mO7NB1";
    description = "T480-main";
    extraGroups = [ "libvirtd" "kvm" "video" "mlocate" "adbusers" "networkmanager" "wheel" ];
  };

  programs.light.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  programs.fuse.userAllowOther = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.main = { pkgs, ... }: {
      # New: Import a persistence module for home-manager.
      imports = [
        inputs.impermanence.nixosModules.home-manager.impermanence
        inputs.nur.hmModules.nur
	#inputs.nur-comb.repos.rycee.hmModules.emacs-init
      ];
      programs.git = {
        enable = true;
        userName = "poggers-donkey";
        userEmail = "yuvrajsinghka@gmail.com";
      };
  
         programs.home-manager.enable = true;
      home.packages = with pkgs; [
        sc-controller
        texlive.combined.scheme-full
        font-awesome
        ani-cli
        discord
        nyxt
        pavucontrol
        roboto
        roboto-mono
        unzip
        wayland-utils
        grim
        slurp
        zathura
        yt-dlp
        mullvad-vpn
        spotify
        wtype
        pamixer
        libnotify
        dunst
        pcmanfm
        #prismlauncher
        pulsemixer
        ripgrep
        udiskie
        ungoogled-chromium
      ];
      home.homeDirectory = "/home/main";
      programs.fzf = {
        enable = true;
        defaultCommand = "fd --type f -H";
        fileWidgetCommand = "fd --type f -H";
        changeDirWidgetCommand = "fd --type f -H";
      };
      services.udiskie = {
        enable = true;
        notify = false;
      };
      wayland.windowManager.sway = {
        enable = true;
        #systemd.enable=true;
        config = {
	  bars = [];
	  window.border = 1;
	  floating = {
	  border = 1;
          modifier = "${config.home-manager.users.main.wayland.windowManager.sway.config.modifier}";
	  };
	  gaps = {
	  inner = 20;
	  };
          left = "h";
          right = "l";
          down = "j";
          up = "k";
          modifier = "Mod4";
          terminal = "${pkgs.foot}/bin/footclient";
          input = {
            "*" = {
              xkb_layout = "gb,in(guru)";
              xkb_options = "caps:escape,compose:ralt,grp:rctrl_toggle";
              repeat_delay = "200";
              repeat_rate = "30";
            };
            "2:10:TPPS/2_IBM_Trackpoint" = { pointer_accel = "0.4"; };
            "type:touchpad" = {
              dwt = "disabled";
              tap = "enabled";
              middle_emulation = "enabled";
            };
            "type:pointer" = {
              accel_profile = "flat";
              pointer_accel = "0";
            };
            "1241:41208:HOLDCHIP_USB_Gaming_Keyboard" = {
              xkb_layout = "us,in(guru)";
            };
          };
          output = {
            # inherited from stylix
            #"*" = {
            #bg = "~/Pictures/desert-unsplash.jpg";
            #};
            "eDP-1" = {
              scale = "1";
              max_render_time = "6";
            };
          };
          menu = "${pkgs.bemenu}/bin/bemenu-run";
          keybindings = let
            mod =
              config.home-manager.users.main.wayland.windowManager.sway.config.modifier;
            inherit (config.home-manager.users.main.wayland.windowManager.sway.config)
              left down up right menu terminal;
          in {
            "${mod}+Return" = "exec ${terminal}";
            "${mod}+Shift+q" = "kill";
            "${mod}+d" = "exec ${menu}";
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+e" =
              "exec swaynat -t warning -m 'exit' -B 'yes' 'swaymsg exit'";
            "${mod}+${left}" = "focus left";
            "${mod}+${right}" = "focus right";
            "${mod}+${up}" = "focus up";
            "${mod}+${down}" = "focus down";
            "${mod}+Shift+${left}" = "move left";
            "${mod}+Shift+${right}" = "move right";
            "${mod}+Shift+${up}" = "move up";
            "${mod}+Shift+${down}" = "move down";

            "${mod}+1" = "workspace number 1";
            "${mod}+2" = "workspace number 2";
            "${mod}+3" = "workspace number 3";
            "${mod}+4" = "workspace number 4";
            "${mod}+5" = "workspace number 5";
            "${mod}+6" = "workspace number 6";
            "${mod}+7" = "workspace number 7";
            "${mod}+8" = "workspace number 8";
            "${mod}+9" = "workspace number 9";
            "${mod}+0" = "workspace number 10";
            "${mod}+Shift+1" = "move container to workspace number 1";
            "${mod}+Shift+2" = "move container to workspace number 2";
            "${mod}+Shift+3" = "move container to workspace number 3";
            "${mod}+Shift+4" = "move container to workspace number 4";
            "${mod}+Shift+5" = "move container to workspace number 5";
            "${mod}+Shift+6" = "move container to workspace number 6";
            "${mod}+Shift+7" = "move container to workspace number 7";
            "${mod}+Shift+8" = "move container to workspace number 8";
            "${mod}+Shift+9" = "move container to workspace number 9";
            "${mod}+Shift+0" = "move container to workspace number 10";

            "${mod}+b" = "splith";
            "${mod}+v" = "splitv";
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+e" = "layout toggle split";
            "${mod}+f" = "fullscreen";
            "${mod}+Shift+space" = "floating toggle";
            "${mod}+space" = "focus mode_toggle";
            "${mod}+a" = "foocs parent";
            "${mod}+Shift+minus" = "move scratchpad";
            "${mod}+minus" = "scratchpad show";
            "${mod}+r" = ''mode "resize"'';
            "Print" = ''
              exec '${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | wl-copy'';
            "Mod1+h" = "wtype -P left";
            "Mod1+j" = "wtype -P down";
            "Mod1+k" = "wtype -P up";
            "Mod1+l" = "wtype -P right";
            "${mod}+p" = ''exec 'foot --title="sneed" -e pulsemixer'';
            "${mod}+Shift+o" = ''exec 'emacsclient -c -e "(org-anywhere)"'';
            "${mod}+o" = ''exec 'emacsclient -c -e "(switch-to-buffer nil)"'';
            "${mod}+Mod1+o" = "chromium --new-window --app=http://127.0.0.1";
            #"${mod}+" = "reload";
          };
          modes = {
            resize = {
              Left = "resize shrink width 10px";
              Right = "resize grow width 10px";
              Up = "resize shrink height 10px";
              Down = "resize grow height 10px";
              Return = ''mode "default"'';
              Escape = ''mode "default"'';
            };
          };
        };
      };

      programs.firefox = {
        enable = true;
        package = pkgs.firefox-wayland.override {
          cfg = {
            # Tridactyl native connector
            enableTridactylNative = true;
          };
        };
        profiles.default.extensions =
          with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            old-reddit-redirect
            #darkreader
            i-dont-care-about-cookies
            tree-style-tab
            auto-tab-discard
            tridactyl
            #sponsorblock
          ];
        profiles.default = {
          id = 0;
          name = "Default";
          isDefault = true;
        };
	profiles.default.userContent = ''
	@-moz-document url-prefix(about:blank) {*{background-color: ${config.lib.stylix.colors.withHashtag.base00};}}
	'';
        profiles.default.userChrome = ''
          #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar>.toolbar-items {
          opacity: 0;
          pointer-events: none;
          }

          #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
          visibility: collapse !important;
          }

          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
          display: none;
          }
	  #tabbrowser-tabpanels {
  background: ${config.lib.stylix.colors.withHashtag.base00} !important;
}

          .tab {
          margin-left: 1px;
          margin-right: 1px;
          }
#nav-bar {
  /* customize this value. */
  --navbar-margin: -38px;

  margin-top: var(--navbar-margin);
  margin-bottom: 0;
  z-index: -100;
  transition: all 0.3s ease !important;
  opacity: 0;
}

#navigator-toolbox:focus-within > #nav-bar,
#navigator-toolbox:hover > #nav-bar
{
  margin-top: 0;
  margin-bottom: var(--navbar-margin);
  z-index: 100;
  opacity: 1;
}
          		    '';
        profiles.default.extraConfig = ''

                  //
                  /* You may copy+paste this file and use it as it is.
                   *
                   * If you make changes to your about:config while the program is running, the
                   * changes will be overwritten by the user.js when the application restarts.
                   *
                   * To make lasting changes to preferences, you will have to edit the user.js.
                   */

                  /****************************************************************************
                   * Betterfox                                                                *
                   * "Ad meliora"                                                             *
                   * version: 110                                                             *
                   * url: https://github.com/yokoffing/Betterfox                              *
                  ****************************************************************************/

                  /****************************************************************************
                   * SECTION: FASTFOX                                                         *
                  ****************************************************************************/
                  user_pref("nglayout.initialpaint.delay", 0);
                  user_pref("nglayout.initialpaint.delay_in_oopif", 0);
                  user_pref("content.notify.interval", 100000);
                  user_pref("browser.startup.preXulSkeletonUI", false);

                  /** EXPERIMENTAL ***/
                  user_pref("layout.css.grid-template-masonry-value.enabled", true);
                  user_pref("layout.css.animation-composition.enabled", true);
                  user_pref("dom.enable_web_task_scheduling", true);

                  /** GFX ***/
                  user_pref("gfx.webrender.all", true);
                  user_pref("gfx.webrender.precache-shaders", true);
                  user_pref("gfx.webrender.compositor", true);
                  user_pref("layers.gpu-process.enabled", true);
                  user_pref("media.hardware-video-decoding.enabled", true);
                  user_pref("gfx.canvas.accelerated", true);
                  user_pref("gfx.canvas.accelerated.cache-items", 32768);
                  user_pref("gfx.canvas.accelerated.cache-size", 4096);
                  user_pref("gfx.content.skia-font-cache-size", 80);
                  user_pref("image.cache.size", 10485760);
                  user_pref("image.mem.decode_bytes_at_a_time", 131072);
                  user_pref("image.mem.shared.unmap.min_expiration_ms", 120000);
                  user_pref("media.memory_cache_max_size", 1048576);
                  user_pref("media.memory_caches_combined_limit_kb", 2560000);
                  user_pref("media.cache_readahead_limit", 9000);
                  user_pref("media.cache_resume_threshold", 6000);

                  /** BROWSER CACHE ***/
                  user_pref("browser.cache.memory.max_entry_size", 153600);

                  /** NETWORK ***/
                  user_pref("network.buffer.cache.size", 262144);
                  user_pref("network.buffer.cache.count", 128);
                  user_pref("network.ssl_tokens_cache_capacity", 32768);

                  /****************************************************************************
                   * SECTION: SECUREFOX                                                       *
                  ****************************************************************************/
                  /** TRACKING PROTECTION ***/
                  user_pref("browser.contentblocking.category", "strict");
                  user_pref("privacy.trackingprotection.emailtracking.enabled", true);
                  user_pref("urlclassifier.trackingSkipURLs", "*.reddit.com, *.twitter.com, *.twimg.com, *.tiktok.com");
                  user_pref("urlclassifier.features.socialtracking.skipURLs", "*.instagram.com, *.twitter.com, *.twimg.com");
                  user_pref("privacy.query_stripping.strip_list", "__hsfp __hssc __hstc __s _hsenc _openstat dclid fbclid gbraid gclid hsCtaTracking igshid mc_eid ml_subscriber ml_subscriber_hash msclkid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id rb_clickid s_cid twclid vero_conv vero_id wbraid wickedid yclid");
                  user_pref("browser.uitour.enabled", false);

                  /** OCSP & CERTS / HPKP ***/
                  user_pref("security.OCSP.enabled", 0);
                  user_pref("security.remote_settings.crlite_filters.enabled", true);
                  user_pref("security.pki.crlite_mode", 2);
                  user_pref("security.cert_pinning.enforcement_level", 2);

                  /** SSL / TLS ***/
                  user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
                  user_pref("browser.xul.error_pages.expert_bad_cert", true);
                  user_pref("security.tls.enable_0rtt_data", false);

                  /** DISK AVOIDANCE ***/
                  user_pref("browser.cache.disk.enable", false);
                  user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);
                  user_pref("browser.sessionstore.privacy_level", 2);

                  /** SHUTDOWN & SANITIZING ***/
                  user_pref("privacy.history.custom", true);

                  /** SPECULATIVE CONNECTIONS ***/
                  user_pref("network.http.speculative-parallel-limit", 0);
                  user_pref("network.dns.disablePrefetch", true);
                  user_pref("browser.urlbar.speculativeConnect.enabled", false);
                  user_pref("browser.places.speculativeConnect.enabled", false);
                  user_pref("network.prefetch-next", false);
                  user_pref("network.predictor.enabled", false);
                  user_pref("network.predictor.enable-prefetch", false);

                  /** SEARCH / URL BAR ***/
                  user_pref("browser.search.separatePrivateDefault.ui.enabled", true);
                  user_pref("browser.urlbar.update2.engineAliasRefresh", true);
                  user_pref("browser.search.suggest.enabled", false);
                  user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
                  user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
                  user_pref("security.insecure_connection_text.enabled", true);
                  user_pref("security.insecure_connection_text.pbmode.enabled", true);
                  user_pref("network.IDN_show_punycode", true);

                  /** HTTPS-FIRST MODE ***/
                  user_pref("dom.security.https_first", true);

                  /** PROXY / SOCKS / IPv6 ***/
                  user_pref("network.proxy.socks_remote_dns", true);
                  user_pref("network.file.disable_unc_paths", true);
                  user_pref("network.gio.supported-protocols", "");

                  /** PASSWORDS AND AUTOFILL ***/
                  user_pref("signon.formlessCapture.enabled", false);
                  user_pref("signon.privateBrowsingCapture.enabled", false);
                  user_pref("signon.autofillForms", false);
                  user_pref("signon.rememberSignons", false);
                  user_pref("editor.truncate_user_pastes", false);
                  user_pref("layout.forms.reveal-password-context-menu.enabled", true);

                  /** ADDRESS + CREDIT CARD MANAGER ***/
                  user_pref("extensions.formautofill.addresses.enabled", false);
                  user_pref("extensions.formautofill.creditCards.enabled", false);
                  user_pref("extensions.formautofill.heuristics.enabled", false);
                  user_pref("browser.formfill.enable", false);

                  /** MIXED CONTENT + CROSS-SITE ***/
                  user_pref("network.auth.subresource-http-auth-allow", 1);
                  user_pref("pdfjs.enableScripting", false);
                  user_pref("extensions.postDownloadThirdPartyPrompt", false);
                  user_pref("permissions.delegation.enabled", false);

                  /** HEADERS / REFERERS ***/
                  user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

                  /** CONTAINERS ***/
                  user_pref("privacy.userContext.ui.enabled", true);

                  /** WEBRTC ***/
                  user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);
                  user_pref("media.peerconnection.ice.default_address_only", true);

                  /** SAFE BROWSING ***/
                  user_pref("browser.safebrowsing.downloads.remote.enabled", false);

                  /** MOZILLA ***/
                  user_pref("accessibility.force_disabled", 1);
                  user_pref("identity.fxaccounts.enabled", false);
                  user_pref("browser.tabs.firefox-view", false);
                  user_pref("permissions.default.desktop-notification", 2);
                  user_pref("permissions.default.geo", 2);
                  user_pref("geo.provider.network.url", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");
                  user_pref("geo.provider.ms-windows-location", false); // WINDOWS
                  user_pref("geo.provider.use_corelocation", false); // MAC
                  user_pref("geo.provider.use_gpsd", false); // LINUX
                  user_pref("geo.provider.use_geoclue", false); // LINUX
                  user_pref("permissions.manager.defaultsUrl", "");
                  user_pref("webchannel.allowObject.urlWhitelist", "");

                  /** TELEMETRY ***/
                  user_pref("toolkit.telemetry.unified", false);
                  user_pref("toolkit.telemetry.enabled", false);
                  user_pref("toolkit.telemetry.server", "data:,");
                  user_pref("toolkit.telemetry.archive.enabled", false);
                  user_pref("toolkit.telemetry.newProfilePing.enabled", false);
                  user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
                  user_pref("toolkit.telemetry.updatePing.enabled", false);
                  user_pref("toolkit.telemetry.bhrPing.enabled", false);
                  user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
                  user_pref("toolkit.telemetry.coverage.opt-out", true);
                  user_pref("toolkit.coverage.opt-out", true);
                  user_pref("datareporting.healthreport.uploadEnabled", false);
                  user_pref("datareporting.policy.dataSubmissionEnabled", false);
                  user_pref("app.shield.optoutstudies.enabled", false);
                  user_pref("browser.discovery.enabled", false);
                  user_pref("breakpad.reportURL", "");
                  user_pref("browser.tabs.crashReporting.sendReport", false);
                  user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);
                  user_pref("captivedetect.canonicalURL", "");
                  user_pref("network.captive-portal-service.enabled", false);
                  user_pref("network.connectivity-service.enabled", false);
                  user_pref("default-browser-agent.enabled", false);
                  user_pref("app.normandy.enabled", false);
                  user_pref("app.normandy.api_url", "");
                  user_pref("browser.ping-centre.telemetry", false);
                  user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
                  user_pref("browser.newtabpage.activity-stream.telemetry", false);

                  /****************************************************************************
                   * SECTION: PESKYFOX                                                        *
                  ****************************************************************************/
                  /** MOZILLA UI ***/
                  user_pref("layout.css.prefers-color-scheme.content-override", 2);
                  user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
                  user_pref("app.update.suppressPrompts", true);
                  user_pref("browser.compactmode.show", true);
                  user_pref("browser.privatebrowsing.vpnpromourl", "");
                  user_pref("extensions.getAddons.showPane", false);
                  user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
                  user_pref("browser.shell.checkDefaultBrowser", false);
                  user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
                  user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
                  user_pref("browser.preferences.moreFromMozilla", false);
                  user_pref("browser.tabs.tabmanager.enabled", false);
                  user_pref("browser.aboutwelcome.enabled", false);
                  user_pref("findbar.highlightAll", true);
                  user_pref("middlemouse.contentLoadURL", false);
                  user_pref("browser.privatebrowsing.enable-new-indicator", false);

                  /** FULLSCREEN ***/
                  user_pref("full-screen-api.transition-duration.enter", "0 0");
                  user_pref("full-screen-api.transition-duration.leave", "0 0");
                  user_pref("full-screen-api.warning.delay", 0);
                  user_pref("full-screen-api.warning.timeout", 0);

                  /** URL BAR ***/
                  user_pref("browser.urlbar.suggest.engines", false);
                  user_pref("browser.urlbar.suggest.topsites", false);
                  user_pref("browser.urlbar.suggest.calculator", true);
                  user_pref("browser.urlbar.unitConversion.enabled", true);

                  /** NEW TAB PAGE ***/
                  user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
                  user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);

                  /*** POCKET ***/
                  user_pref("extensions.pocket.enabled", false);

                  /** DOWNLOADS ***/
                  user_pref("browser.download.useDownloadDir", false);
                  user_pref("browser.download.alwaysOpenPanel", false);
                  user_pref("browser.download.manager.addToRecentDocs", false);
                  user_pref("browser.download.always_ask_before_handling_new_types", true);

                  /** PDF ***/
                  user_pref("browser.download.open_pdf_attachments_inline", true);

                  /** TAB BEHAVIOR ***/
                  user_pref("browser.link.open_newwindow.restriction", 0);
                  user_pref("dom.disable_window_move_resize", true);
                  user_pref("browser.tabs.loadBookmarksInTabs", true);
                  user_pref("browser.bookmarks.openInTabClosesMenu", false);
                  user_pref("dom.popup_allowed_events", "change click dblclick auxclick mousedown mouseup pointerdown pointerup notificationclick reset submit touchend contextmenu"); // reset pref; remove in v.111
                  user_pref("layout.css.has-selector.enabled", true);

                  /****************************************************************************
                   * SECTION: SMOOTHFOX                                                       *
                  ****************************************************************************/
                  // visit https://github.com/yokoffing/Betterfox/blob/master/Smoothfox.js
                  // Enter your scrolling prefs below this line:
                  // For 60hz
                  user_pref("general.smoothScroll",                       true); // DEFAULT
                  user_pref("mousewheel.default.delta_multiplier_y",      275);  // 250-400

                  /****************************************************************************
                   * START: MY OVERRIDES                                                      *
                  ****************************************************************************/
                  // Enter your personal prefs below this line:
                  user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
                  user_pref("extensions.autoDisableScopes", 0);
                  user_pref("browser.tabs.inTitlebar", 0);
                  user_pref("extensions.activeThemeID", "default-theme@mozilla.org");
          	  user_pref("media.ffmpeg.vaapi.enabled", true);
                  /****************************************************************************
                   * END: BETTERFOX                                                           *
                  ****************************************************************************/
        '';
      };
      #wayland.windowManager.hyprland = {
      #enable = true;
      #extraConfig = ''
      #hyprland.conf here…
      #'';
      #};
      programs.foot = {
        enable = true;
        server.enable = true;
        settings = {
          main = {
            term = "xterm-256color";
            pad = "20x20";

            #  font = "Roboto Mono:size=8";
            #dpi-aware = lib.mkOverride 1 "yes";
          };

          mouse = { hide-when-typing = "yes"; };
        };
      };
      gtk.enable = true;
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;
      };
      services.dunst.enable = true;
      programs.zathura = {
        enable = true;
        options.recolor= lib.mkOverride 1 "true";
      };

      home.stateVersion = "22.05";
      home.sessionVariables = { MOZ_ENABLE_WAYLAND = 1; };
      home.persistence."/nix/persist/home/main/" = {
        directories = [
          "org-roam"
          "notes"
          ".ssh"
          ".mail"
          "Downloads"
          "Documents"
          "Pictures"
          ".config/discord"
          ".config/spotify"
          ".cache/spotify"
	  ".config/zsh"
          #".zotero"
          #".local/share/lutris"
          #".local/share/Steam"
          #".local/share/grapejuice"
          #".local/share/PrismLauncher"
          #".local/share/sm64ex"
          #".local/share/nyxt"
          ".elfeed"
          ".local/share/Anki2"
        ];
        files = [ ".bash_history" ];
        allowOther = true;
      };
      programs.zsh = {
  enable = true;
  shellAliases = {
    ll = "ls -l";
  };
  history = {
    size = 10000;
    path = ".config/zsh/history";
  };
};
      programs.waybar = let
        battery = { name }: {
          bat = name;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        media = { number }: {
          format = "{icon} {}";
          return-type = "json";
          max-length = 55;
          format-icons = {
            Playing = "";
            Paused = "";
          };
          exec = "mediaplayer ${toString number}";
          exec-if = "[ $(playerctl -l 2>/dev/null | wc -l) -ge ${
              toString (number + 1)
            } ]";
          interval = 1;
          on-click = "play-pause ${toString number}";
        };
      in {
        enable = true;
        systemd = {
          enable = true;
          target = "sway-session.target";
        };
        settings = [{
          height = 40;
          modules-left = [ "sway/workspaces" "sway/mode" ];
          modules-center = [ ];
          modules-right = [
            "network"
            "memory"
            "pulseaudio"
            "cpu"
            "backlight"
            "battery#bat0"
            "battery#bat1"
            "clock"
            #"custom/power"
            "tray"
          ];
          "sway/workspaces" = {
            all-outputs = true;
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "9" = "";
              "10" = "";
              #focused = "";
              urgent = "";
              default = "";
            };
          };
          tray = { spacing = 10; };
          clock = {
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
            format-alt = "{:%A, %d %b}";
          };
          cpu = { format = "{usage}% "; };
          memory = { format = "{}% "; };
          backlight = {
            format = "{icon}";
            format-alt = "{percent}% {icon}";
            format-alt-click = "click-right";
            format-icons = [ "○" "◐" "●" ];
            on-scroll-down = "light -U 10";
            on-scroll-up = "light -A 10";
          };
          "battery#bat0" = battery { name = "BAT0"; };
          "battery#bat1" = battery { name = "BAT1"; };
          network = {
            format-wifi = "({signalStrength}%) ";
            format-ethernet = "Ethernet ";
            format-linked = "Ethernet (No IP) ";
            format-disconnected = "Disconnected ";
            format-alt = "{bandwidthDownBits}/{bandwidthUpBits}";
            on-click-middle = "nm-connection-editor";
          };
          pulseaudio = {
            scroll-step = 1;
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
            on-click = "pavucontrol";
          };
          "custom/power" = {
            format = "";
            on-click = "nwgbar -o 0.2";
            escape = true;
            tooltip = false;
          };

        }];
      };
      home.persistence."/nix/persist/home/main/dotfiles" = {
        directories = [
          ".config/emacs"
        ];
        allowOther = true;
      };
      systemd.user.startServices=true;
      stylix.targets.waybar.enable=false;
      home.file = {
        ".config/tridactyl/tridactylrc" = {
          text = ''
            colourscheme shydactyl-stylix
            blacklistadd monkeytype.com
unbind <F1>
          '';
        };
	".config/waybar/style.css" = 
	with config.lib.stylix.colors.withHashtag;
with config.stylix.fonts;
	{
text = ''
    @define-color base00 ${base00}; @define-color base01 ${base01}; @define-color base02 ${base02}; @define-color base03 ${base03};
    @define-color base04 ${base04}; @define-color base05 ${base05}; @define-color base06 ${base06}; @define-color base07 ${base07};

    @define-color base08 ${base08}; @define-color base09 ${base09}; @define-color base0A ${base0A}; @define-color base0B ${base0B};
    @define-color base0C ${base0C}; @define-color base0D ${base0D}; @define-color base0E ${base0E}; @define-color base0F ${base0F};
* {
    font-family: Roboto Light;
    font-size: 13px;
}

window#waybar, tooltip {
    background: alpha(@base00, 0.000000);
    color: @base05;
    margin-top: 8px;
}

tooltip {
    border-color: @base0D;
}
#wireplumber,
#pulseaudio,
#sndio {
     padding-right: 10px;
    padding-left: 10px;
       margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
 padding: 0 5px;
}
#wireplumber.muted,
#pulseaudio.muted,
#sndio.muted {
     padding-right: 10px;
    padding-left: 10px;
       margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
 padding: 0 5px;
}
#upower,
#battery {
     padding-right: 10px;
    padding-left: 10px;
      margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
  padding: 0 5px;
}
#upower.charging,
#battery.Charging {
     padding-right: 10px;
    padding-left: 10px;
     margin-right: 10px;
    margin-left: 10px;
     padding-right: 10px;
    padding-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;
}
#network {
     padding-right: 10px;
    padding-left: 10px;
     margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;
}
#tray {
     padding-right: 10px;
    padding-left: 10px;
     margin-right: 20px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;
}
#workspaces {
     padding-right: 20px;
    padding-left: 20px;
     margin-right: 10px;
    margin-left: 20px;
    background: alpha(@base00, 0.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;
}
#workspaces button {
    border-radius: 5px;
      margin-right: 20px;
   background: alpha(@base00, 1.000000);
}
#mode {
     padding-right: 10px;
    padding-left: 10px;
     margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;
}
#power {
     padding-right: 10px;
    padding-left: 10px;
     margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;
}
#network.disconnected {
     padding-right: 10px;
    padding-left: 10px;
     margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;
}
#user {
     padding-right: 10px;
    padding-left: 10px;
     margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;

}
#clock {
     padding-right: 10px;
    padding-left: 10px;
      margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
  padding: 0 5px;
}
#backlight {
     padding-right: 10px;
    padding-left: 10px;
     margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;
}
#cpu {
     padding-right: 10px;
    padding-left: 10px;
    padding: 0 5px;
    margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
}
#disk {
    padding: 0 5px;
}
#idle_inhibitor {
    padding: 0 5px;
}
#temperature {
    padding: 0 5px;
}
#mpd {
    padding: 0 5px;
}
#language {
    padding: 0 5px;
}
#keyboard-state {
    padding: 0 5px;
}
#memory {
     padding-right: 10px;
    padding-left: 10px;
     margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
   padding: 0 5px;
}
#window {
     padding-right: 10px;
    padding-left: 10px;
      margin-right: 10px;
    margin-left: 10px;
    background: alpha(@base00, 1.000000);
    border-radius: 5px;
    margin-top: 8px;
  padding: 0 5px;
}
.modules-left #workspaces button {
    border-bottom: 3px solid transparent;
}
.modules-left #workspaces button.focused,
.modules-left #workspaces button.active {
    border-bottom: 3px solid @base05; }
.modules-center #workspaces button {
    border-bottom: 3px solid transparent;
}
.modules-center #workspaces button.focused,
.modules-center #workspaces button.active {
    border-bottom: 3px solid @base05;
}
.modules-right #workspaces button {
    border-bottom: 3px solid transparent;
}
.modules-right #workspaces button.focused,
.modules-right #workspaces button.active {
    border-bottom: 3px solid @base05;
}

'';
	};
        ".config/tridactyl/themes/shydactyl-stylix.css" =
          with config.lib.stylix.colors.withHashtag;
          with config.stylix.fonts; {
            text = ''
                  :root {
                  --tridactyl-font-family: \"${sansSerif.name}\", sans-serif;

                  --tridactyl-cmdl-font-size: 1.5rem;
                  --tridactyl-cmdl-line-height: 1.5;

                  --tridactyl-cmplt-option-height: 1.4em;
                  --tridactyl-cmplt-font-size: var(--tridactyl-small-font-size);
                  --tridactyl-cmplt-border-top: unset;
                  --tridactyl-fg: ${base07};
                  --tridactyl-cmdl-fg: ${base07};
                  --tridactyl-bg: ${base00};
                  --tridactyl-cmdl-bg: ${base00};

                  --tridactyl-status-font-size: 9px;
                  --tridactyl-status-font-family: \"${monospace.name}\", monospace;
                  --tridactyl-status-border: 1px var(--tridactyl-fg) solid;

                  --tridactyl-header-font-size: var(--tridactyl-small-font-size);
                  --tridactyl-header-font-weight: 200;
                  --tridactyl-header-border-bottom: unset;

                  --tridactyl-hintspan-font-size: var(--tridactyl-font-size);
              }

              :root #command-line-holder {
                  order: 1;
                  border: 2px solid var(--tridactyl-cmdl-fg);
                  color: var(--tridactyl-cmdl-bg);
              }

              :root #tridactyl-input {
                  width: 90%;
                  padding: 1rem;
              }

              :root #completions table {
                  font-size: 0.8rem;
                  font-weight: 200;
                  border-spacing: 0;
                  table-layout: fixed;
                  padding: 1rem;
                  padding-top: 0;
              }

              :root #completions > div {
                  max-height: calc(20 * var(--tridactyl-cmplt-option-height));
                  min-height: calc(10 * var(--tridactyl-cmplt-option-height));
              }

              /* COMPLETIONS */

              :root #completions {
                  font-weight: 200;
                  order: 2;
              }

              /* Olie doesn't know how CSS inheritance works */
              :root #completions .HistoryCompletionSource {
                  max-height: unset;
                  min-height: unset;
              }

              :root #completions .HistoryCompletionSource table {
                  width: 100%;
                  font-size: 9pt;
                  border-spacing: 0;
                  table-layout: fixed;
              }

              /* redundancy 2: redundancy 2: more redundancy */
              :root #completions .BmarkCompletionSource {
                  max-height: unset;
                  min-height: unset;
              }

              :root #completions table tr td.prefix,
              :root #completions table tr td.privatewindow,
              :root #completions table tr td.container,
              :root #completions table tr td.icon {
                  display: none;
              }

              :root #completions .BufferCompletionSource table {
                  width: unset;
                  font-size: unset;
                  border-spacing: unset;
                  table-layout: unset;
              }

              :root #completions table tr {
                  white-space: nowrap;
                  overflow: hidden;
                  text-overflow: ellipsis;
              }

              :root #completions .sectionHeader {
                  background: unset;
                  padding: 1rem !important;
                  padding-left: unset;
                  padding-bottom: 0.2rem;
              }

              :root #cmdline_iframe {
                  position: fixed !important;
                  bottom: unset;
                  top: 25% !important;
                  left: 10% !important;
                  z-index: 2147483647 !important;
                  width: 80% !important;
                  box-shadow: rgba(0, 0, 0, 0.5) 0px 0px 15px !important;
              }

              :root .TridactylStatusIndicator {
                  position: fixed !important;
                  bottom: 0 !important;
                  font-weight: 200 !important;
                  padding: 0.8ex !important;
              }
            '';
          };
      };
    };
  };
}
