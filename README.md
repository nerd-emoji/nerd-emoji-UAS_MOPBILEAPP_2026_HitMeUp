run dengan emulator pakai: 
flutter run

run dengan handphone beneran pakai:
flutter run --dart-define=SIGNUP_ANDROID_PHYSICAL_API_BASE_URL=http://YOUR_LAN_IP:8000
dengan http://YOUR_LAN_IP:8000 itu adalah ipv4 di laptop atau pc

sebelum run server pakai venv dulu
venv/Scripts/activate
lalu:
$env:GEMINI_API_KEY="YOUR_GEMINI_KEY"
$env:GEMINI_MODEL="gemini-2.5-flash"
py .\manage.py runserver 0.0.0.0:8000
gemini key tidak bisa taruh di github atau nanti diblokir, harus bikin sendiri

