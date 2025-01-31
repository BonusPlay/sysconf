# this is no longer used, as I chose to use ntfy server
# however, I'm leaving this here as a reminder on how to
# create nextcloud apps using overlays
#let
#  data = builtins.fromJSON ''
#    {
#      "hash": "sha256-Ma91dacjCiCVFbJydrfbDxd21UXhAnPWPL5bF3BHxWI=",
#      "url": "https://codeberg.org/NextPush/uppush/archive/2.1.3.tar.gz",
#      "version": "2.1.2",
#      "description": "Once the mobile phone is connected with NextPush, push notifications can be forwarded to applications implementing UnifiedPush.\n\nMore information about UnifiedPush at https://unifiedpush.org",
#      "homepage": "",
#      "licenses": [
#        "agpl"
#      ]
#    }
#  '';
#in
#final: prev: {
#  nextcloud30Packages = prev.nextcloud30Packages.extend(nfinal: nprev: {
#    apps = nprev.apps.extend(afinal: aprev: {
#      uppush = prev.fetchNextcloudApp {
#        appName = "uppush";
#        appVersion = data.version;
#        license = "agpl3Plus";
#        inherit (data)
#          url
#          hash
#          description
#          homepage
#          ;
#      };
#    });
#  });
#}
