<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>حدث خطأ - الموقع قيد الصيانة</title>
    <!-- Bootstrap RTL -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="css/sld.min.css">
    <style>
        :root {
            --primary-color: #3498db;
            --secondary-color: #2980b9;
            --dark-color: #2c3e50;
            --light-color: #ecf0f1;
        }
        
        body {
            font-family: 'Tajawal', sans-serif;
            background-color: #f8f9fa;
            color: var(--dark-color);
            height: 100vh;
            display: flex;
            align-items: center;
        }
        
        .error-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            background-color: white;
            text-align: center;
            border-top: 5px solid var(--primary-color);
        }
        
        .error-icon {
            font-size: 5rem;
            color: var(--primary-color);
            margin-bottom: 1.5rem;
        }
        
        .error-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: var(--dark-color);
        }
        
        .error-message {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            line-height: 1.6;
        }
        
        .error-code {
            background-color: var(--light-color);
            padding: 0.5rem 1rem;
            border-radius: 5px;
            font-family: monospace;
            display: inline-block;
            margin-bottom: 2rem;
        }
        
        .btn-home {
            background-color: var(--primary-color);
            color: white;
            padding: 0.8rem 2rem;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s;
            border: none;
        }
        
        .btn-home:hover {
            background-color: var(--secondary-color);
            transform: translateY(-2px);
            box-shadow: 0 5px 10px rgba(0, 0, 0, 0.1);
            color: white;
        }
        
        .contact-info {
            margin-top: 2rem;
            font-size: 0.9rem;
            color: #7f8c8d;
        }
        
        @media (max-width: 768px) {
            .error-container {
                padding: 1.5rem;
            }
            
            .error-title {
                font-size: 2rem;
            }
            
            .error-message {
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="error-container">
            <div class="error-icon">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <h1 class="error-title">حدث خطأ غير متوقع</h1>
            <p class="error-message">
                نعتذر عن هذا الإزعاج، يبدو أن هناك مشكلة تقنية في الموقع.<br>
                فريقنا يعمل على حل المشكلة حالياً، الرجاء المحاولة مرة أخرى لاحقاً.
            </p>
            <div class="error-code">رمز الخطأ: 500</div>
            <a href="index.php" class="btn btn-home">
                <i class="fas fa-home me-2"></i> العودة للصفحة الرئيسية
            </a>
            <div class="contact-info">
                <p>للتواصل في حال استمرار المشكلة: <a href="mailto:algedawy89@gmail.com">algedawy89@gmail.com</a></p>
                <div class="social-links mt-3">
                    <a href="#" class="text-dark me-2"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="text-dark me-2"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="text-dark me-2"><i class="fab fa-instagram"></i></a>
                    <a href="#" class="text-dark"><i class="fab fa-whatsapp"></i></a>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>