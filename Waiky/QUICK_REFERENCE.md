# Quick Reference - New Waiky Features

## 🆕 What's New

| Feature | Status | Location | Key File |
|---------|--------|----------|----------|
| Screen Time Tracking | ✅ Ready | HomeView → Screen Time Card | ScreenTimeManager.swift |
| Habit Tracker | ✅ Ready | HomeView → Habits Card | HabitTrackerView.swift |
| Calendar Integration | ✅ Ready | HomeView → Today's Schedule | CalendarManager.swift |
| Premium UI | ✅ Ready | HomeView → Premium Card | PremiumView.swift |

---

## 📋 Pre-Launch Checklist

### Required
- [ ] Add `NSCalendarsUsageDescription` to Info.plist
- [ ] Test screen time slider saves/loads correctly
- [ ] Verify habits persist across app restarts
- [ ] Confirm calendar events appear (with permission)
- [ ] Test all sheets open/close properly

### Optional
- [ ] Add `NSFamilyControlsUsageDescription` to Info.plist (future use)
- [ ] Test with 0, 3, and 5+ calendar events
- [ ] Verify busy day context in AI nudge
- [ ] Test Premium sheet layout on different devices

---

## 🔑 Key Methods

### ScreenTimeManager
```swift
ScreenTimeManager.shared.getTodayScreenTime() -> Int
ScreenTimeManager.shared.saveTodayScreenTime(_ minutes: Int)
ScreenTimeManager.shared.formatScreenTime(_ minutes: Int) -> String
```

### HabitTrackerView
```swift
HabitTrackerView.getTodayCompletion() -> (completed: Int, total: Int)
```

### CalendarManager
```swift
await CalendarManager.shared.requestCalendarAccess() -> Bool
await CalendarManager.shared.fetchTodayEvents() -> [EKEvent]
CalendarManager.shared.isBusyDay(events:) -> Bool
```

### OpenAIManager (Updated)
```swift
openAIManager.generateNudge(
    mood: Int,
    sleepQuality: Int,
    heartRate: Double?,
    sleepHours: Double?,
    isBusyDay: Bool = false,  // ← NEW
    completion: @escaping (String?) -> Void
)
```

---

## 📦 UserDefaults Keys

| Key | Type | Example Value |
|-----|------|---------------|
| `todayScreenTime` | Int | `120` (minutes) |
| `habits-2026-08-01` | Data | JSON-encoded [Habit] array |

---

## 🎨 Card Colors

| Card | Background Color | Accent |
|------|------------------|--------|
| Health | Blue | .blue.opacity(0.1) |
| Nudge | Green | .green.opacity(0.1) |
| Screen Time | Orange | .orange.opacity(0.1) |
| Habits | Green | .green.opacity(0.1) |
| Calendar | Purple | .purple.opacity(0.1) |
| Premium | Yellow Gradient | Yellow → Orange |

---

## 🔄 Feature Interactions

```
CheckInView
    ↓
CalendarManager.fetchTodayEvents()
    ↓
isBusyDay = events.count > 4
    ↓
OpenAIManager.generateNudge(..., isBusyDay: true)
    ↓
Nudge includes: "...busy day ahead—take breaks..."
```

---

## 🚨 Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Calendar not showing | Add Info.plist key, grant permission |
| Habits not saving | Check date format in UserDefaults key |
| Screen time resets | Verify saveTodayScreenTime() is called |
| Premium button tappable | It's disabled by design (coming soon) |
| Busy context missing | Need 4+ calendar events today |

---

## 📱 Supported Platforms

- ✅ iOS 16.0+
- ✅ iPadOS 16.0+
- ⚠️ macOS requires EventKit entitlements
- ❌ watchOS (no EventKit)

---

## 🎯 Test Scenarios

### Scenario 1: New User
1. First launch → Calendar permission prompt
2. All habits show 0/4
3. Screen time shows 0 min
4. No events → "No events today"

### Scenario 2: Power User
1. Logged 180 minutes screen time (at goal)
2. Completed 4/4 habits → "🎉 All habits complete!"
3. 5 calendar events → Busy day nudge
4. Premium card always visible

### Scenario 3: Denied Permissions
1. Calendar denied → Warning icon in CalendarCard
2. App still functional
3. No busy day context in nudge
4. Other features work normally

---

## 💡 Future Enhancements

### Screen Time
- [ ] DeviceActivityReport for real tracking
- [ ] Per-app breakdown
- [ ] Weekly trends chart
- [ ] Set custom goals

### Habits
- [ ] Custom habit creation (Premium)
- [ ] Streak tracking
- [ ] Habit analytics
- [ ] Notifications/reminders

### Calendar
- [ ] Event filtering (work/personal)
- [ ] Next event countdown
- [ ] Calendar-based focus sessions
- [ ] Meeting overload detection

### Premium
- [ ] StoreKit 2 integration
- [ ] Subscription management
- [ ] Feature gating
- [ ] Trial period

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `IMPLEMENTATION_SUMMARY.md` | Complete technical overview |
| `FEATURE_DEMO_GUIDE.md` | User-facing walkthroughs |
| `INFO_PLIST_SETUP.md` | Required permissions setup |
| `QUICK_REFERENCE.md` | This file |

---

## ✅ Build & Run

1. Open project in Xcode
2. Add Info.plist entries (see INFO_PLIST_SETUP.md)
3. Select target device/simulator
4. Build (⌘B) to verify no errors
5. Run (⌘R) and test each feature
6. Check console for debug logs

---

**Last Updated:** August 1, 2026  
**Version:** 1.0 (Initial Feature Release)  
**Status:** ✅ Ready for Testing
