<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>قنوات البث المباشر</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
   
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>قنوات البث المباشر</h1>
            <p>اختر القناة التي تريد مشاهدتها</p>
        </div>
        
        <div class="row">
            <?php
            $total_channels = 6;
            
            for ($i = 1; $i <= $total_channels; $i++):
                $channel_dir = __DIR__ . DIRECTORY_SEPARATOR . 'temp/ch' . $i . '/';
                $m3u8_file = $channel_dir . 'output.m3u8';
                $is_online = is_dir($channel_dir) && file_exists($m3u8_file);
            ?>
            <div class="col-md-6 col-lg-4">
                <div class="channel-card">
                    <div class="channel-number"><?= $i ?></div>
                    <div class="card-body text-center">
                        <div class="channel-title">
                            <i class="fas fa-tv"></i>
                            <span>القناة <?= $i ?></span>
                        </div>
                        
                        <div class="channel-status <?= $is_online ? 'status-online' : 'status-offline' ?>">
                            <?= $is_online ? 'متصل الآن' : 'غير متصل' ?>
                        </div>
                        
                        <a href="<?= $is_online ? 'channel.php?channel=ch'.$i : '#' ?>" 
                           class="watch-btn <?= !$is_online ? 'disabled' : '' ?>"
                           <?= !$is_online ? 'onclick="return false;"' : '' ?>>
                            <?= $is_online ? 'مشاهدة البث' : 'غير متاح' ?>
                        </a>
                    </div>
                </div>
            </div>
            <?php endfor; ?>
        </div>
        
        <div class="footer">
            <p>جميع الحقوق محفوظة &copy; <?= date('Y') ?></p>
        </div>
    </div>

    <script src="js/bootstrap.bundle.js"></script>
    <script>
        // يمكنك إضافة أي تفاعلات JavaScript هنا
        document.addEventListener('DOMContentLoaded', function() {
            // إضافة تأثير عند التمرير
            const channelCards = document.querySelectorAll('.channel-card');
            
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = 1;
                        entry.target.style.transform = 'translateY(0)';
                    }
                });
            }, { threshold: 0.1 });
            
            channelCards.forEach((card, index) => {
                card.style.opacity = 0;
                card.style.transform = 'translateY(20px)';
                card.style.transition = `all 0.5s ease ${index * 0.1}s`;
                observer.observe(card);
            });
        });
    </script>
</body>
</html>