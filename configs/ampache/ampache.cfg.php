;#<?php exit(); ?>##
;#########################################################
; General Config                                         #
;#########################################################
config_version = 63

;#########################################################
; Auto Update                                            #
;#########################################################
github_force_branch = "master"
composer_binary_path = "composer"
hide_ampache_messages = "false"

;#########################################################
; Path Vars                                              #
;#########################################################
;http_host = "localhost"
;http_port = 80
;web_path = ""
;local_web_path = "http://localhost/ampache"

;#########################################################
; Database                                               #
;#########################################################
database_name = ampache
database_hostname = localhost
database_port = 3306
database_username = root
;database_password = password
database_charset = "utf8mb4"
database_collation = "utf8mb4_unicode_ci"

;#########################################################
; Session and Security                                   #
;#########################################################
secret_key = "abcdefghijklmnoprqstuvwyz0123456"
session_length = 3600
stream_length = 7200
remember_length = 604800
session_name = ampache
session_cookielife = 0
session_cookiesecure = 0
auth_methods = "mysql"
;external_authenticator = "/usr/sbin/pwauth"
;auth_password_save = "true"
;logout_redirect = "http://sso.example.com/logout"
access_control = "true"
require_session = "true"
require_localnet_session = "true"
;prevent_multiple_logins = "true"
;disable_xframe_sameorigin = "true"

;#########################################################
; Metadata                                               #
;#########################################################
getid3_tag_order = "vorbiscomment,id3v2,id3v1,quicktime,matroska,ape,asf,avi,mpeg,riff"
;getid3_detect_id3v2_encoding = "true"
;write_id3 = "true"
;write_id3_art = "true"
metadata_order = "getID3,MusicBrainz,TheAudioDb,filename"
metadata_order_video = "filename,getID3"
deferred_ext_metadata = "true"
additional_genre_delimiters = "[/]{2}|[/\\\\|,;]"
;enable_custom_metadata = "true"

;#########################################################
; File Tags                                             #
;write_tags = "true"

;#########################################################
; Catalog                                                #
;#########################################################
catalog_file_pattern = "mp3|mpc|m4p|m4a|aac|ogg|oga|wav|aif|aiff|rm|wma|asf|flac|opus|spx|ra|ape|shn|wv"
catalog_video_pattern = "avi|mpg|mpeg|flv|m4v|mp4|webm|mkv|wmv|ogv|mov|divx|m2ts"
catalog_playlist_pattern = "m3u|m3u8|pls|asx|xspf"
catalog_prefix_pattern = "The|An|A|Die|Das|Ein|Eine|Les|Le|La"
;catalog_disable = "true"
;catalog_filter = "true"
;delete_from_disk = "true"
;catalog_verify_by_time = "true"

;#########################################################
; Program Settings                                       #
;#########################################################
;downsample_remote = "true"
;track_user_ip = "true"
;user_ip_cardinality = "42"
;allow_zip_download = "true"
;allow_zip_types = "album"
;art_zip_add = "true"
;file_zip_comment = "Ampache - Zip Batch Download"
;webplayer_debug = "true"
;waveform = "true"
;waveform_color = "#FF0000"
;waveform_height = 32
;waveform_width = 400
;tmp_dir_path = "/tmp"
;throttle_download = 10
;generate_video_preview = "true"
;no_symlinks = "true"
use_auth = "true"
default_auth_level = "guest"
;skip_timer = 20
ratings = "true"
;rating_browse_filter = "true"
;rating_browse_minimum_stars = 1
;rating_file_tag_user = 1
directplay = "true"
sociable = "true"
;licensing = "true"
;demo_mode = "true"
;simple_user_mode = "true"
;memory_cache = "true"
;memory_limit = 32
;album_art_preferred_filename = "folder.jpg"
;artist_art_preferred_filename = "folder.jpg"
;artist_art_folder = "/data/htdocs/www/art"
;album_art_store_disk = "true"
;local_metadata_dir = "/metadata"
;max_upload_size = 1048576
;album_art_min_width = 100
;album_art_max_width = 1024
;album_art_min_height = 100
;album_art_max_height = 1024
;resize_images = "true"
playlist_art = "true"
;statistical_graphs = "true"
art_order = "db,tags,folder,spotify,musicbrainz"
;gather_song_art = "true"
;show_song_art = "true"
;spotify_art_filter = "artist"
;art_search_limit = 15
;show_similar = "true"
;hide_search = "true"
;allow_upload_scripts = "true"

;#########################################################
;      API keys                                          #
;#########################################################
lastfm_api_key = "d5df942424c71b754e54ce1832505ae2"
lastfm_api_secret = ""

;spotify_client_id = ""
;spotify_client_secret = ""
;wanted = "true"
wanted_types = "album,official"
;wanted_auto_accept = "true"
;label = "true"
;broadcast = "true"
live_stream = "true"
podcast = "true"
;websocket_address = "ws://localhost:8100"
refresh_limit = "60"
;use_now_playing_embedded = "true"
;now_playing_refresh_limit = "-1"
;now_playing_css_file = "templates/now-playing.css"
show_footer_statistics = "true"
;use_rss = "true"
;allow_php_themes = "true"

;#########################################################
; Debugging                                              #
;#########################################################
debug = "false"
debug_level = 2
log_path = "/data/logs/httpd"
log_filename = "ampache.log"

;#########################################################
; Encoding Settings                                      #
;#########################################################
site_charset = UTF-8
;lc_charset = "ISO8859-1"
;mb_detect_order = "ASCII,UTF-8,EUC-JP,ISO-2022-JP,SJIS,JIS"

;#########################################################
; Custom actions (optional)                              #
;#########################################################
;custom_play_action_title_0 = ""
;custom_play_action_icon_0 = ""
;custom_play_action_run_0 = ""

; Example for Karaoke playing
;custom_play_action_title_0 = "Karaoke"
;custom_play_action_icon_0 = "microphone"
;custom_play_action_run_0 = "sox \"%f\" -p oops | ffmpeg -i pipe:0 -f %c pipe:1"

;#########################################################
; LDAP login info (optional)                             #
;#########################################################
;ldap_url = "ldap://localhost/"
;ldap_url = "ldaps://localhost/"
;ldap_username = ""
;ldap_password = ""
;ldap_search_dn = "ou=People,dc=yoursubdomain,dc=yourdomain,dc=yourtld"
;ldap_objectclass = "posixAccount"          ; OpenLDAP
;ldap_objectclass = "organizationalPerson"  ; Microsoft Active Directory
;ldap_filter = "(uid=%v)"                   ; OpenLDAP
;ldap_filter = "(sAMAccountName=%v)"        ; Microsoft Active Directory
;ldap_require_group = "cn=yourgroup,ou=yourorg,dc=yoursubdomain,dc=yourdomain,dc=yourtld"
;ldap_name_field = "cn"
;ldap_name_field = "displayName"
;ldap_email_field = "mail"
;ldap_avatar_field = "jpegPhoto"
;ldap_avatar_mime = "image/jpeg"
;ldap_protocol_version = 3
;ldap_start_tls = "true"
;ldap_member_attribute = "member"
;ldap_member_attribute = "memberuid"

;#########################################################
; OpenID login info (optional)                           #
;#########################################################
;openid_required_pape = ""

;#########################################################
; Public Registration settings, defaults to disabled     #
;#########################################################
;auto_create = "true"
;external_auto_update = "true"
;allow_public_registration = "true"
;captcha_public_reg = "true"
;admin_notify_reg = "true"
;admin_enable_required = "true"
;auto_user = "guest"
;user_agreement = "true"
;user_no_email_confirm = "true"
;cookie_disclaimer = "true"
registration_display_fields = "fullname,website"
registration_mandatory_fields = "fullname"

;#########################################################
; These options control the dynamic downsampling based   #
; on current usage                                       #
; *Note* Transcoding must be enabled and working         #
;#########################################################
;max_bit_rate = 576
;min_bit_rate = 48

;#########################################################
; Transcode Settings                                     #
;#########################################################
;transcode_m4a = "allowed"
;transcode_flac = "required"
;transcode_mpc = "required"
;transcode_ogg = "required"
;transcode_oga = "required"
;transcode_opus = "required"
;transcode_wav = "required"
;transcode_wma = "required"
;transcode_aif = "required"
;transcode_aiff = "required"
;transcode_ape = "required"
;transcode_shn = "required"
transcode_mp3 = "allowed"
;transcode_avi = "allowed"
;transcode_flv = "allowed"
;transcode_mkv = "allowed"
;transcode_mpg = "allowed"
;transcode_mpeg = "allowed"
;transcode_m4v = "allowed"
;transcode_mp4 = "allowed"
;transcode_mov = "allowed"
;transcode_wmv = "allowed"
;transcode_ogv = "allowed"
;transcode_divx = "allowed"
;transcode_m2ts = "allowed"
;transcode_webm = "allowed"
;encode_target = mp3
;encode_video_target = webm
;encode_target_flac = opus
;transcode_player_webplayer_m4a = "required"
;transcode_player_webplayer_flac = "required"
;transcode_player_webplayer_mpc = "required"
;encode_player_webplayer_target = mp3
;encode_player_api_target = mp3
transcode_player_customize = "true"
;transcode_cmd = "ffmpeg"
;transcode_cmd = "avconv"
;transcode_cmd = "/usr/bin/neatokeen"
transcode_input = "-i %FILE%"
;transcode_cmd_mid = "timidity -Or -o – %FILE% | ffmpeg -f s16le -i pipe:0"
encode_args_mp3 = "-vn -b:a %BITRATE%K -c:a libmp3lame -f mp3 pipe:1"
encode_args_ogg = "-vn -b:a %BITRATE%K -c:a libvorbis -f ogg pipe:1"
encode_args_opus = "-vn -b:a %BITRATE%K -c:a libopus -compression_level 10 -vsync 2 -f ogg pipe:1"
encode_args_m4a = "-vn -b:a %BITRATE%K -c:a libfdk_aac -f adts pipe:1"
encode_args_wav = "-vn -b:a %BITRATE%K -c:a pcm_s16le -f wav pipe:1"
encode_args_flv = "-b:a %BITRATE%K -ar 44100 -ac 2 -v 0 -f flv -c:v libx264 -preset superfast -threads 0 pipe:1"
encode_args_webm = "-b:a %BITRATE%K -f webm -c:v libvpx -preset superfast -threads 0 pipe:1"
encode_args_ts = "-q %QUALITY% -s %RESOLUTION% -f mpegts -c:v libx264 -c:a libmp3lame -maxrate %MAXBITRATE%k -preset superfast -threads 0 pipe:1"
encode_args_ogv = "-codec:v libtheora -qscale:v 7 -codec:a libvorbis -qscale:a 5 -f ogg pipe:1"
encode_get_image = "-ss %TIME% -f image2 -vframes 1 pipe:1"
encode_srt = "-vf \"subtitles='%SRTFILE%'\""
encode_ss_frame = "-ss %TIME%"
encode_ss_duration = "-t %DURATION%"
send_full_stream = "webplayer"

;#########################################################
; Transcode Caching                                      #
;#########################################################
;cache_path = "/tmp"
;cache_target = "mp3"
;cache_m4a = "true"
;cache_flac = "true"
;cache_mpc = "true"
;cache_ogg = "true"
;cache_oga = "true"
;cache_opus = "true"
;cache_wav = "true"
;cache_wma = "true"
;cache_aif = "true"
;cache_aiff = "true"
;cache_ape = "true"
;cache_shn = "true"
;cache_mp3 = "true"
;cache_remote = "true"

;#########################################################
; Proxy Settings (optional)                              #
;#########################################################
;proxy_host = "192.168.0.1"
;proxy_port = "8080"
;proxy_user = ""
;proxy_pass = ""
;force_ssl = "true"

;#########################################################
;  Mail Settings                                         #
;#########################################################
;mail_enable = "true"
;mail_type = "php"
;mail_domain = "example.com"
;mail_user = "info"
;mail_name = "Ampache"
;mail_check = "strict"

;#########################################################
;  sendmail Settings                                     #
;#########################################################
;sendmail_path = "/usr/sbin/sendmail"

;#########################################################
;  SMTP Settings                                         #
;#########################################################
;mail_host = "localhost"
;mail_port = 25
;mail_secure_smtp = tls
;mail_auth = "true"
;mail_auth_user = ""
;mail_auth_pass = ""

;#########################################################
;   Abbreviation Filter                                  #
;#########################################################
common_abbr = "divx,xvid,dvdrip,hdtv,lol,axxo,repack,xor,pdtv,real,vtv,caph,2hd,proper,fqm,uncut,topaz,tvt,notv,fpn,fov,orenji,0tv,omicron,dsr,ws,sys,crimson,wat,hiqt,internal,brrip,boheme,vost,vostfr,fastsub,addiction,x264,LOL,720p,1080p,YIFY,evolve,fihtv,first,bokutox,bluray,tvboom,info"
