<?php

// تحديد مسار ملف بيانات الزوار
define('VISITORS_FILE', __DIR__ . '/visitors.json');
// تحديد المهلة الزمنية لعدم النشاط (بالثواني). يجب أن تكون أكبر من فترة "نبضات القلب".
define('INACTIVITY_TIMEOUT', 15); // زدناها من 15 إلى 25 لزيادة الأمان

// وظيفة لقراءة بيانات الزوار من الملف مع استخدام قفل الملف
function getVisitorsData() {
    $data = [];
    // 'c+' لفتح الملف للقراءة والكتابة، وإنشاء الملف إذا لم يكن موجودًا
    $file_handle = fopen(VISITORS_FILE, 'c+');
    if ($file_handle) {
        // الحصول على قفل مشارك للقراءة (LOCK_SH)
        if (flock($file_handle, LOCK_SH)) {
            // مسح ذاكرة التخزين المؤقت لحالة الملف للتأكد من قراءة أحدث نسخة
            clearstatcache(true, VISITORS_FILE);
            // التأكد من أن الملف ليس فارغًا قبل محاولة قراءته
            if (filesize(VISITORS_FILE) > 0) {
                $data_str = fread($file_handle, filesize(VISITORS_FILE));
                // فك تشفير JSON، وإذا فشل، إرجاع مصفوفة فارغة
                $data = json_decode($data_str, true) ?: [];
            }
            // تحرير القفل
            flock($file_handle, LOCK_UN);
        }
        fclose($file_handle); // إغلاق الملف
    }
    return $data;
}

// وظيفة لحفظ بيانات الزوار إلى الملف مع استخدام قفل الملف
function saveVisitorsData($data) {
    $file_handle = fopen(VISITORS_FILE, 'c+');
    if ($file_handle) {
        // الحصول على قفل حصري للكتابة (LOCK_EX)
        if (flock($file_handle, LOCK_EX)) {
            ftruncate($file_handle, 0); // مسح محتويات الملف بالكامل
            rewind($file_handle); // إعادة مؤشر الملف إلى البداية
            // كتابة البيانات الجديدة بتنسيق JSON مع تنسيق جميل
            fwrite($file_handle, json_encode($data, JSON_PRETTY_PRINT));
            // تحرير القفل
            flock($file_handle, LOCK_UN);
        }
        fclose($file_handle); // إغلاق الملف
    }
}

// وظيفة لتنظيف الزوار غير النشطين من البيانات
function cleanupInactiveVisitors($visitors_data) {
    $cleaned_data = [];
    foreach ($visitors_data as $channel => $visitors) {
        $cleaned_visitors = [];
        foreach ($visitors as $id => $timestamp) {
            // إذا كان المستخدم لا يزال نشطًا (لم يتجاوز وقت عدم النشاط)
            if ((time() - $timestamp) <= INACTIVITY_TIMEOUT) {
                $cleaned_visitors[$id] = $timestamp;
            }
        }
        // إذا كان هناك أي زوار نشطين في هذه القناة، قم بإضافتهم
        if (!empty($cleaned_visitors)) {
            $cleaned_data[$channel] = $cleaned_visitors;
        }
    }
    return $cleaned_data;
}

// وظيفة لتحديث وقت نشاط الزائر
function updateVisitor($channel, $visitorId) {
    // 1. قراءة البيانات الحالية
    $visitors = getVisitorsData();
    // 2. تنظيف الزوار غير النشطين من البيانات قبل التحديث
    $visitors = cleanupInactiveVisitors($visitors);

    // التأكد من وجود القناة في المصفوفة
    if (!isset($visitors[$channel])) {
        $visitors[$channel] = [];
    }
    // تحديث الطابع الزمني لآخر نشاط للزائر الحالي
    $visitors[$channel][$visitorId] = time();

    // 3. حفظ البيانات المحدثة والمنظفة
    saveVisitorsData($visitors);
}

// وظيفة لإزالة زائر محدد (تُستخدم عند مغادرة الصفحة إن أمكن)
function removeVisitor($channel, $visitorId) {
    $visitors = getVisitorsData();
    if (isset($visitors[$channel][$visitorId])) {
        unset($visitors[$channel][$visitorId]);
        saveVisitorsData($visitors);
    }
}

// وظيفة للحصول على عدد الزوار النشطين لقناة معينة
function getActiveVisitorsCount($channel) {
    $visitors = getVisitorsData();
    // قم بالتنظيف مرة أخرى قبل العد مباشرة لضمان أحدث البيانات
    $visitors = cleanupInactiveVisitors($visitors);
    // احفظ البيانات بعد التنظيف مباشرة للحفاظ على حالة الملف نظيفة
    saveVisitorsData($visitors);

    // إرجاع عدد الزوار النشطين في القناة المحددة
    return isset($visitors[$channel]) ? count($visitors[$channel]) : 0;
}

// البدء في الجلسة إذا لم تكن قد بدأت بالفعل (ضروري للحصول على session_id())
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

// معالجة طلبات AJAX
if (isset($_POST['action'])) {
    $channel = $_POST['channel'] ?? '';
    // استخدم session_id() كمعرف فريد. تأكد من أن session_start() يعمل بشكل صحيح.
    $visitorId = session_id(); 

    // إذا كان معرف الجلسة فارغًا لأي سبب (يجب ألا يحدث إذا تم session_start() بشكل صحيح)
    if (empty($visitorId)) {
        // يمكنك استخدام معرف فريد من جانب العميل كحل بديل (مثل $_POST['unique_client_id'])
        // لكن من الأفضل إصلاح مشكلة session_id()
        $visitorId = 'unknown_visitor_' . uniqid(); 
    }

    if (empty($channel)) {
        echo json_encode(['status' => 'error', 'message' => 'القناة مطلوبة']);
        exit();
    }

    switch ($_POST['action']) {
        case 'heartbeat':
            // يقوم هذا الإجراء بتحديث وقت نشاط الزائر ثم يعيد العدد الجديد
            updateVisitor($channel, $visitorId);
            echo json_encode(['status' => 'success', 'count' => getActiveVisitorsCount($channel)]);
            break;
        case 'get_count':
            // يقوم هذا الإجراء فقط بإعادة العدد، ويمكن استخدامه إذا كنت لا تريد تحديث نشاط الزائر
            echo json_encode(['status' => 'success', 'count' => getActiveVisitorsCount($channel)]);
            break;
        case 'remove_visitor': // يتم استدعاؤه عند محاولة مغادرة الصفحة (أفضل جهد ممكن)
            removeVisitor($channel, $visitorId);
            echo json_encode(['status' => 'success']);
            break;
        default:
            echo json_encode(['status' => 'error', 'message' => 'إجراء غير صالح']);
            break;
    }
    exit();
}

?>