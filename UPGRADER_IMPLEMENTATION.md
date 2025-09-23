# การใช้งานระบบ Upgrader สำหรับแอป Flutter

## ภาพรวม
ระบบ Upgrader ได้ถูกติดตั้งและกำหนดค่าเรียบร้อยแล้วเพื่อให้แอป Flutter สามารถอัปเดทเวอร์ชั่นจาก Store ได้โดยอัตโนมัติ โดยไม่ต้องลบแอปแล้วลงใหม่

## ไฟล์ที่เกี่ยวข้อง

### 1. `pubspec.yaml`
```yaml
dependencies:
  upgrader: ^12.1.0
```

### 2. `lib/main.dart`
- เพิ่ม import `package:upgrader/upgrader.dart`
- เพิ่ม import `package:gcargo/services/upgrader_service.dart`
- ห่อ `AuthWrapper` ด้วย `UpgradeAlert` widget

### 3. `lib/services/upgrader_service.dart`
- สร้าง `UpgraderService` class สำหรับจัดการการกำหนดค่า
- สร้าง `ThaiUpgraderMessages` class สำหรับข้อความภาษาไทย

### 4. `lib/widgets/upgrade_test_widget.dart`
- หน้าทดสอบระบบ upgrader
- มีปุ่มสำหรับทดสอบแสดง dialog อัปเดท

### 5. `lib/home/homePage.dart`
- เพิ่ม FloatingActionButton สำหรับเข้าหน้าทดสอบ upgrader

## การทำงาน

### การตรวจสอบอัปเดท
1. **อัตโนมัติ**: ระบบจะตรวจสอบเวอร์ชั่นใหม่จาก Store เมื่อเปิดแอป
2. **ความถี่**: แสดงแจ้งเตือนทุก 1 วัน (กำหนดใน `durationUntilAlertAgain`)
3. **แพลตฟอร์ม**: รองรับทั้ง Android (Google Play Store) และ iOS (App Store)

### ข้อความภาษาไทย
- **หัวข้อ**: "อัปเดทแอป"
- **เนื้อหา**: "เวอร์ชั่นใหม่ {{currentAppStoreVersion}} พร้อมให้ใช้งานแล้ว คุณกำลังใช้เวอร์ชั่น {{currentInstalledVersion}}"
- **ปุ่ม**: "อัปเดท", "ภายหลัง", "ข้าม"

### การกำหนดค่า
```dart
Upgrader(
  durationUntilAlertAgain: const Duration(days: 1),
  debugDisplayAlways: false, // ตั้งเป็น true เพื่อทดสอบ
  debugLogging: true,
  countryCode: 'TH',
  languageCode: 'th',
  messages: ThaiUpgraderMessages(),
)
```

## การทดสอบ

### 1. ทดสอบในแอป
- กดปุ่ม FloatingActionButton (ไอคอน system_update) ในหน้า HomePage
- เข้าหน้า "ทดสอบ Upgrader"
- กดปุ่ม "ทดสอบแสดง Dialog อัปเดท" เพื่อดู dialog ตัวอย่าง

### 2. ทดสอบการทำงานจริง
- ต้องมีเวอร์ชั่นใหม่บน Store ที่สูงกว่าเวอร์ชั่นปัจจุบัน
- ระบบจะแสดง dialog อัปเดทเมื่อเปิดแอป (หากไม่ได้ข้ามไปแล้ว)

## Log การทำงาน
```
I/flutter: upgrader: instantiated
I/flutter: upgrader: initialize called
I/flutter: upgrader: packageInfo version: 1.0.3
I/flutter: upgrader: appStoreVersion: 1.0.4
I/flutter: upgrader: isUpdateAvailable: true
I/flutter: upgrader: shouldDisplayUpgrade: false (เพราะ isTooSoon: true)
```

## ข้อกำหนดสำคัญ

### สำหรับการทำงานจริง
1. **แอปต้องอยู่บน Store**: Google Play Store หรือ App Store
2. **เวอร์ชั่นใหม่**: ต้องมีเวอร์ชั่นใหม่บน Store ที่สูงกว่าเวอร์ชั่นปัจจุบัน
3. **อินเทอร์เน็ต**: ผู้ใช้ต้องมีการเชื่อมต่ออินเทอร์เน็ต
4. **Package Name**: ต้องตรงกับที่ลงทะเบียนบน Store

### การกำหนดเวอร์ชั่น
- **pubspec.yaml**: `version: 1.0.3+5`
- **Android**: `versionCode` และ `versionName` ใน `build.gradle`
- **iOS**: `CFBundleShortVersionString` และ `CFBundleVersion` ใน `Info.plist`

## การปรับแต่ง

### เปลี่ยนความถี่การแจ้งเตือน
```dart
durationUntilAlertAgain: const Duration(hours: 12), // ทุก 12 ชั่วโมง
```

### เปิดโหมดทดสอบ
```dart
debugDisplayAlways: true, // แสดง dialog เสมอ
debugDisplayOnce: true,   // แสดงครั้งเดียวต่อการเปิดแอป
```

### ปรับแต่งข้อความ
แก้ไขใน `lib/services/upgrader_service.dart` ใน class `ThaiUpgraderMessages`

## สถานะปัจจุบัน
✅ ติดตั้งและกำหนดค่าเรียบร้อย
✅ ตรวจสอบเวอร์ชั่นจาก Store ได้
✅ แสดงข้อความภาษาไทย
✅ รองรับทั้ง Android และ iOS
✅ มีหน้าทดสอบสำหรับ Developer

## การใช้งานต่อไป
1. อัปโหลดแอปเวอร์ชั่นใหม่ขึ้น Store
2. ระบบจะแจ้งเตือนผู้ใช้อัตโนมัติเมื่อมีการอัปเดท
3. ผู้ใช้สามารถเลือกอัปเดททันที หรือข้ามไปก่อนได้
