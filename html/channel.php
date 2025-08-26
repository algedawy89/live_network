<?php
session_start(); 
include 'visitors_manager.php'; 

$isXAMPP = false; 
$port = '8088';


if (!isset($_GET['channel'])) {
    header("Location: index.php"); 
    exit();
}

$channel = $_GET['channel'];
$channel_dir = __DIR__ . DIRECTORY_SEPARATOR . 'temp/' . $channel . '/';
$m3u8_file = $channel_dir . 'output.m3u8';
$channel_number = str_replace('ch', '', $channel);


// التحقق من وجود ملف البث
if (!is_dir($channel_dir) || !file_exists($m3u8_file)) {
    $error_message = "القناة غير متاحة للبث حالياً";
}

// البحث عن القنوات المتاحة للتنقل بينها
$total_channels = 6;
$available_channels = [];
for ($i = 1; $i <= $total_channels; $i++) {
    $ch_dir = __DIR__ . DIRECTORY_SEPARATOR . 'temp/ch' . $i . '/';
    $ch_m3u8 = $ch_dir . 'output.m3u8';
    if (is_dir($ch_dir) && file_exists($ch_m3u8)) {
        $available_channels[] = $i;
    }
}

$link = toVir($channel, $port, $isXAMPP);
// These are not needed for the visitor counter, but kept for context if used elsewhere
$mxURL = open_player($link, 'mx');
$kmUrl = open_player($link, 'km');
$vlcUrl = open_player($link, '$vlcUrl');

// Initial visitor update on page load
if (!isset($error_message)) {
    updateVisitor($channel, session_id());
}

?>

<!DOCTYPE html>
<html lang="ar" dir="rtl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>البث المباشر - قناة <?= $channel_number ?></title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/sld.min.css">
    <link href="js/video-js.css" rel="stylesheet">
    <link href="css/channel.css" rel="stylesheet">


    <style>
        /* ... (Your existing styles) ... */
        .players-container {
            margin: 15px 0;
            padding: 10px;
            background: #3a46af;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .section-title {
            font-size: 16px;
            color: #ffffff;
            margin-bottom: 10px;
            padding-bottom: 5px;
            border-bottom: 1px solid #eee;
            text-align: center;
        }

        .players-list {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 10px;
        }

        .player-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-decoration: none;
            color: #ffffff;
            padding: 8px 12px;
            border-radius: 6px;
            transition: all 0.2s;
            width: 97px;
            overflow: hidden;
        }

        .player-item:hover {
            border: 1px solid #ffffff;
            transform: translateY(-2px);
        }

        .player-logo {
            width: 40px;
            height: 40px;
            object-fit: cover;
            margin-bottom: 5px;
            border-radius: 50%;
        }

        .player-item span {
            font-size: 12px;
            text-align: center;
        }

        @media (max-width: 480px) {
            .player-item {
                width: 70px;
                padding: 6px 8px;
            }

            .player-logo {
                width: 35px;
                height: 35px;
                object-fit: cover;
            }
        }

        /* New style for visitor counter */
        #visitor-count-container {
            text-align: center;
            margin-top: 20px;
            padding: 10px;
            background-color: #2c6bf7;
            /* Green background */
            color: white;
            border-radius: 5px;
            font-size: 1.1em;
            font-weight: bold;
        }
    </style>
</head>

<body>
    <div class="container">
        <div class="header">
            <h1>البث المباشر - قناة <?= $channel_number ?></h1>
        </div>

        <?php if (isset($error_message)): ?>
            <div class="error-container">
                <i class="fas fa-exclamation-triangle"></i>
                <h2>حدث خطأ</h2>
                <p><?= $error_message ?></p>
                <a href="index.php" class="back-btn">
                    <i class="fas fa-arrow-right"></i> العودة إلى قائمة القنوات
                </a>
            </div>
        <?php else: ?>
            <div class="video-container">
                <video-js id="live_stream" class="video-js vjs-default-skin vjs-big-play-centered" controls preload="auto" autoplay="true" poster="img/logo.jpg">
                    <source src="temp/<?= $channel ?>/output.m3u8" type="application/x-mpegURL">
                    <p class='vjs-no-js'>
                        لتشغيل الفيديو، يرجى تمكين JavaScript أو استخدام متصفح يدعم HTML5.
                    </p>
                </video-js>
            </div>

            <div id="visitor-count-container">
                visitors: <span id="active-visitors-count">0</span>
            </div>

            <?php if (!empty($available_channels)): ?>
                <div class="channels-nav">
                    <?php for ($i = 1; $i <= $total_channels; $i++): ?>
                        <?php
                        $is_available = in_array($i, $available_channels);
                        $is_active = ($i == $channel_number);
                        ?>
                        <a href="<?= $is_available ? 'channel.php?channel=ch' . $i : '#' ?>"
                            class="channel-btn <?= $is_active ? 'active' : '' ?> <?= !$is_available ? 'disabled' : '' ?>"
                            <?= !$is_available ? 'onclick="return false;"' : '' ?>>
                            <?= $i ?>
                        </a>
                    <?php endfor; ?>
                </div>
            <?php endif; ?>


            <?php if (isAndroid()): ?>
                <div class="players-container">
                    <h3 class="section-title">تشغيل عبر التطبيقات</h3>
                    <div class="players-list">
                        <a href="javascript:void(0)" onclick="openPlayer('<?= $link ?>','mx')" class="player-item">
                            <img src="img/mx.jpg" alt="MX Player" class="player-logo">
                            <span>MX Player</span>
                        </a>

                        <a href="javascript:void(0)" onclick="openPlayer('<?= $link ?>','km')" class="player-item">
                            <img src="img/km.png" alt="KM Player" class="player-logo">
                            <span>KM Player</span>
                        </a>

                        <a href="javascript:void(0)" onclick="openPlayer('<?= $link ?>','vlc')" class="player-item">
                            <img src="img/vlc.jpg" alt="VLC Player" class="player-logo">
                            <span>VLC Player</span>
                        </a>
                    </div>
                </div>
            <?php endif; ?>

        <?php endif; ?>
    </div>

    <script src="js/video.min.js"></script>
    <script>
        <?php if (!isset($error_message)): ?>
            var player = videojs('live_stream');

            window.onload = function() {
                setTimeout(function() {
                    if (player.paused()) {
                        player.play();
                    }
                }, 2000);
            };

            // Addition for visitor counter
            const channelName = "<?= $channel ?>"; // Get the current channel from PHP
            const visitorId = "<?= session_id() ?>"; // Get the session ID from PHP


            // Function to only fetch the count
            function fetchVisitorCount() {
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'visitors_manager.php', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.onload = function() {
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.status === 'success') {
                                document.getElementById('active-visitors-count').textContent = response.count;
                            } else {
                                console.error('Error fetching visitor count:', response.message);
                            }
                        } catch (e) {
                            console.error('Error parsing JSON response:', e, xhr.responseText);
                        }
                    } else {
                        console.error('Server error:', xhr.status, xhr.statusText);
                    }
                };
                xhr.send('action=get_count&channel=' + channelName);
            }


            function updateVisitorCount() {
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'visitors_manager.php', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.onload = function() {
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.status === 'success') {
                                document.getElementById('active-visitors-count').textContent = response.count;
                            } else {
                                console.error('Error updating visitor count:', response.message);
                            }
                        } catch (e) {
                            console.error('Error parsing JSON response:', e, xhr.responseText);
                        }
                    } else {
                        console.error('Server error:', xhr.status, xhr.statusText);
                    }
                };
                // Send heartbeat and request the latest count
                xhr.send('action=heartbeat&channel=' + channelName + '&visitor_id=' + visitorId);
            }

            // Initial count update on page load
            updateVisitorCount();

            // Set interval for heartbeat and count updates (e.g., every 5 seconds)
            setInterval(updateVisitorCount, 5000); // INACTIVITY_TIMEOUT is 15s, so 5s heartbeat is good

            // Attempt to remove visitor on page unload (best effort)
            window.addEventListener('beforeunload', function() {
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'visitors_manager.php', false); // Synchronous request
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.send('action=remove_visitor&channel=' + channelName + '&visitor_id=' + visitorId);
            });


            // ... (Your existing JavaScript code for channel navigation and player opening) ...

            // إضافة تأثيرات للتنقل بين القنوات
            document.querySelectorAll('.channel-btn:not(.disabled)').forEach(btn => {
                btn.addEventListener('mouseenter', function() {
                    if (!this.classList.contains('active')) {
                        this.style.transform = 'translateY(-3px) scale(1.1)';
                    }
                });

                btn.addEventListener('mouseleave', function() {
                    if (!this.classList.contains('active')) {
                        this.style.transform = '';
                    }
                });
            });

            function openPlayer(url, player = "mx") {
                // استبدال http بـ intent
                let intentUrl = url.replace(/^http/i, 'intent');

                // إضافة الجزء الخاص بالمشغل
                switch (player) {
                    case "mx":
                        intentUrl += "#Intent;scheme=http;type=video/mp4;package=com.mxtech.videoplayer.ad;end";
                        break;
                    case "km":
                        intentUrl += "#Intent;scheme=http;type=video/mp4;package=com.kmplayer;end";
                        break;
                    case "vlc":
                        intentUrl += "#Intent;scheme=http;type=video/mp4;package=org.videolan.vlc;end";
                        break;
                    default:
                        intentUrl += "#Intent;scheme=http;type=video/mp4;package=com.mxtech.videoplayer.ad;end";
                }

                // محاولة فتح الرابط
                try {
                    window.location.href = intentUrl;

                    // إذا لم يفتح التطبيق خلال ثانيتين، عرض رسالة
                    setTimeout(() => {
                        if (!document.hidden) {
                            throw new Error('التطبيق غير مثبت');
                        }
                    }, 2000);

                } catch (e) {
                    const playerNames = {
                        'mx': 'MX Player',
                        'km': 'KM Player',
                        'vlc': 'VLC'
                    };

                    alert(`حدث خطأ في فتح المشغل، يرجى تثبيت ${playerNames[player] || playerNames['mx']}`);

                    // فتح رابط التحميل كبديل
                    window.open(getStoreLink(player), '_blank');
                }
            }

            // دالة مساعدة للحصول على روابط المتاجر
            function getStoreLink(player) {
                const storeLinks = {
                    'mx': 'https://play.google.com/store/apps/details?id=com.mxtech.videoplayer.ad',
                    'km': 'https://play.google.com/store/apps/details?id=com.kmplayer',
                    'vlc': 'https://play.google.com/store/apps/details?id=org.videolan.vlc'
                };

                return storeLinks[player] || storeLinks['mx'];
            }

        <?php endif; ?>
    </script>
</body>

</html>

<?php
// ... (Your existing PHP functions: open_player, isMobileDevice, isAndroid, toVir) ...
function open_player($str, $player = "mx")
{
    $str = preg_replace("/http/i", "intent", $str);

    switch ($player) {
        case "mx":
            $str .= "#Intent;scheme=http;type=video/mp4;package=com.mxtech.videoplayer.ad;end";
            break;
        case "km":
            $str .= "#Intent;scheme=http;type=video/mp4;package=com.kmplayer;end";
            break;
        case "vlc":
            $str .= "#Intent;scheme=http;type=video/mp4;package=org.videolan.vlc;end";
            break;
        default:
            $str .= "#Intent;scheme=http;type=video/mp4;package=com.mxtech.videoplayer.ad;end";
    }

    return $str;
}


function isMobileDevice()
{
    $userAgent = $_SERVER['HTTP_USER_AGENT'];
    return preg_match('/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i', $userAgent);
}

function isAndroid()
{
    return strpos($_SERVER['HTTP_USER_AGENT'], 'Android') !== false;
}
function toVir($channel = "ch1", $port = '80', $xampp = false)
{

    if ($xampp) {
        $dir = __DIR__;
        $dir = basename(dirname($dir));
        $dir = $dir . '/' . basename(__DIR__);
        return 'http://' . $_SERVER['HTTP_HOST'] . '/' . $dir . '/temp' . '/' . $channel . '/output.m3u8';
    } else {
        return 'http://' . $_SERVER['HTTP_HOST'] . ":$port" . '/temp' . '/' . $channel . '/output.m3u8';
    }
}
?>