
var player = videojs('live_stream');

function playVideo() {
    player.play();
}

// تأكد من تشغيل الفيديو تلقائيًا عند تحميل الصفحة
window.onload = function() {
    setTimeout(function() {
        if (player.paused()) {
            player.play();
        }
    }, 2000);
};

// Check for dark mode preference
if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    document.documentElement.classList.add('dark');
}

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', event => {
    if (event.matches) {
        document.documentElement.classList.add('dark');
    } else {
        document.documentElement.classList.remove('dark');
    }
});
