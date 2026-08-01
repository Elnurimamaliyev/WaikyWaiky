# Info.plist Required Entries

Add these entries to your Info.plist file for the new features to work properly:

## Calendar Access (Required)

```xml
<key>NSCalendarsUsageDescription</key>
<string>Waiky needs calendar access to provide personalized wellness nudges based on your daily schedule.</string>
```

## Family Controls (Optional - for future screen time tracking)

```xml
<key>NSFamilyControlsUsageDescription</key>
<string>Waiky uses screen time data to help you maintain a healthy digital balance.</string>
```

---

## Full Info.plist Snippet

If you need to copy the complete entry:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing keys... -->
    
    <!-- CALENDAR ACCESS - REQUIRED FOR CALENDAR INTEGRATION -->
    <key>NSCalendarsUsageDescription</key>
    <string>Waiky needs calendar access to provide personalized wellness nudges based on your daily schedule.</string>
    
    <!-- FAMILY CONTROLS - OPTIONAL (for future screen time features) -->
    <key>NSFamilyControlsUsageDescription</key>
    <string>Waiky uses screen time data to help you maintain a healthy digital balance.</string>
    
    <!-- Existing keys... -->
</dict>
</plist>
```

---

## How to Add in Xcode

1. Open your project in Xcode
2. Select your target → Info tab
3. Click the **+** button to add a new key
4. Type `NSCalendarsUsageDescription`
5. Set the value to: `Waiky needs calendar access to provide personalized wellness nudges based on your daily schedule.`
6. (Optional) Repeat for `NSFamilyControlsUsageDescription`

---

## Testing Permissions

### Calendar Permission
- On first launch with calendar features, iOS will prompt the user
- If denied, the CalendarCard will show "Calendar access not granted"
- Users can re-enable in Settings → Privacy & Security → Calendars → Waiky

### Family Controls Permission
- Currently requested by ScreenTimeManager but not actively enforced
- Will be needed when implementing real DeviceActivityReport tracking
- Can be tested by uncommenting authorization calls in ScreenTimeManager

---

## Privacy Best Practices

✅ **Clear descriptions**: Both strings explain WHY access is needed
✅ **Feature-specific**: Only request calendar access when needed
✅ **Graceful degradation**: App works without permissions (shows warnings)
✅ **User control**: All cards show access status and guide users

⚠️ **Important**: Apple reviews apps carefully for privacy. Make sure your App Store description also mentions calendar integration and screen time features.
