# Waiky App - Feature Demo Guide

## 🎯 Quick Start Guide

### First Launch
1. Open the app
2. Complete onboarding (if not already done)
3. Grant calendar access when prompted
4. HomeView will display with all new cards

---

## 📱 Feature Walkthroughs

### 1. Screen Time Tracking

**Initial State:**
```
┌─────────────────────────────────┐
│ Screen Time Today         [Log] │
│                                  │
│ 0 min          [●        ] 0%   │
│ Goal: 3 hrs                      │
└─────────────────────────────────┘
```

**After Logging (e.g., 120 minutes):**
```
┌─────────────────────────────────┐
│ Screen Time Today         [Log] │
│                                  │
│ 2 hr 0 min     [●●●●●   ] 67%  │
│ Goal: 3 hrs                      │
└─────────────────────────────────┘
```

**Steps to Test:**
1. Tap "Log" button on Screen Time card
2. Drag slider to desired value (e.g., 120 minutes)
3. Tap "Save"
4. Card updates with formatted time and progress

**Expected Behavior:**
- Progress bar is GREEN when under 180 minutes
- Progress bar turns RED when over 180 minutes (exceeded goal)
- Format displays as "X hr Y min" when hours > 0, otherwise "Y min"

---

### 2. Habit Tracker

**Default State (Today):**
```
┌─────────────────────────────────┐
│ Habits                           │
│                                  │
│ ✓  0/4 done today               │
│    Tap to track your habits  → │
└─────────────────────────────────┘
```

**After Completing 2 Habits:**
```
┌─────────────────────────────────┐
│ Habits                           │
│                                  │
│ ✓  2/4 done today               │
│    Tap to track your habits  → │
└─────────────────────────────────┘
```

**Inside Habit Tracker:**
```
┌─────────────────────────────────┐
│          Habit Tracker     Done │
│                                  │
│ TODAY'S HABITS                   │
│                                  │
│ ☑ Morning check-in              │
│ ○ No phone first 30 min         │
│ ☑ Movement break                │
│ ○ Wind down before bed          │
│                                  │
│ 2 of 4 completed                │
└─────────────────────────────────┘
```

**Steps to Test:**
1. Tap Habits card on HomeView
2. Tap circles to toggle habits on/off
3. Tap "Done" to return
4. HomeView card shows updated count

**Expected Behavior:**
- Each habit toggles with checkbox animation
- Completed habits show strikethrough text
- Count persists per day (resets at midnight)
- Completion message shows when all 4 done: "🎉 All habits complete!"

---

### 3. Calendar Integration

**With Access & Events:**
```
┌─────────────────────────────────┐
│ Today's Schedule                 │
│                                  │
│ Team Standup                     │
│ 9:00 AM                          │
│ ──────────────────────────       │
│ Design Review                    │
│ 11:30 AM                         │
│ ──────────────────────────       │
│ Lunch with Sarah                 │
│ 1:00 PM                          │
│                                  │
│ +2 more                          │
└─────────────────────────────────┘
```

**No Events:**
```
┌─────────────────────────────────┐
│ Today's Schedule                 │
│                                  │
│ 📅 No events today              │
│                                  │
└─────────────────────────────────┘
```

**No Access:**
```
┌─────────────────────────────────┐
│ Today's Schedule                 │
│                                  │
│ ⚠️ Calendar access not granted  │
│                                  │
└─────────────────────────────────┘
```

**Steps to Test:**
1. Add calendar events in iOS Calendar app
2. Open Waiky (will request permission)
3. Grant access
4. HomeView shows up to 3 events with times
5. Shows "+X more" if there are additional events

**Busy Day Detection:**
- If 4+ events exist, AI nudge includes busy day advice
- Example nudge: "You're doing okay! ... It looks like you have a busy day ahead—remember to take short breaks between meetings to recharge."

---

### 4. Premium Card

**Default Display:**
```
┌─────────────────────────────────┐
│ 🔒 Waiky Premium                │
│    Unlock trends, unlimited AI   │
│    chat, and custom habits       │
│                                  │
│ €4.99/mo           [ Upgrade ]  │
└─────────────────────────────────┘
```

**After Tapping Upgrade:**
```
┌─────────────────────────────────┐
│         Waiky Premium      Close│
│                                  │
│           ⭐                     │
│                                  │
│      Waiky Premium               │
│      You're currently on the     │
│      free plan                   │
│                                  │
│  📈 Advanced Trends              │
│     Track your wellness over     │
│     weeks and months             │
│                                  │
│  ✨ Unlimited AI Chat            │
│     Talk to your wellness coach  │
│     anytime                      │
│                                  │
│  ✅ Custom Habits                │
│     Create and track             │
│     personalized habits          │
│                                  │
│  🔔 Smart Reminders              │
│     Get nudged at the perfect    │
│     time                         │
│                                  │
│          €4.99                   │
│         per month                │
│                                  │
│     [ Coming Soon ]              │
│     Payment integration coming   │
└─────────────────────────────────┘
```

**Steps to Test:**
1. Scroll to bottom of HomeView
2. Tap Premium card (anywhere on card)
3. Premium sheet appears with features
4. "Coming Soon" button is disabled
5. Tap "Close" to dismiss

**Expected Behavior:**
- Card has gradient background (yellow → orange)
- Lock icon displayed
- Sheet shows all 4 premium features
- Button clearly marked as not functional yet

---

## 🔄 Integration with Existing Features

### Check-In Flow Enhancement

**Before (without calendar integration):**
```
Check In → Enter mood/sleep → Generate Nudge
Nudge: "You're doing okay! A quick break or some deep breathing could help."
```

**After (with 5 calendar events today):**
```
Check In → Enter mood/sleep → Generate Nudge (with calendar context)
Nudge: "You're doing okay! A quick break or some deep breathing could help. 
        It looks like you have a busy day ahead—remember to take short 
        breaks between meetings to recharge."
```

**How to Test:**
1. Add 5+ events to your calendar for today
2. Open Waiky → Check In
3. Rate mood/sleep
4. Submit
5. Notice nudge includes "busy day" advice

---

## 🎨 Visual Layout (HomeView)

```
┌───────────────────────────────────────┐
│  ← Waiky                      👤      │
├───────────────────────────────────────┤
│                                        │
│  Good morning, John 👋                │
│                                        │
│  TODAY'S HEALTH                  Edit │
│  ┌────────────────────────────────┐   │
│  │  72         │  7.5              │   │
│  │  BPM        │  Hours Sleep      │   │
│  └────────────────────────────────┘   │
│                                        │
│  [Weekly Mood Chart]                   │
│                                        │
│  TODAY'S NUDGE                         │
│  ┌────────────────────────────────┐   │
│  │ You're feeling great! Keep...  │   │
│  └────────────────────────────────┘   │
│                                        │
│  [ ✓ Check In Now ]                   │
│  [ ⏱ Focus Session ]                   │
│                                        │
│  🆕 SCREEN TIME TODAY          Log    │
│  ┌────────────────────────────────┐   │
│  │ 2 hr 0 min    [●●●●●   ] 67%  │   │
│  └────────────────────────────────┘   │
│                                        │
│  🆕 HABITS                          → │
│  ┌────────────────────────────────┐   │
│  │ ✓ 2/4 done today               │   │
│  └────────────────────────────────┘   │
│                                        │
│  🆕 TODAY'S SCHEDULE                  │
│  ┌────────────────────────────────┐   │
│  │ Team Standup     9:00 AM       │   │
│  │ Design Review    11:30 AM      │   │
│  │ Lunch with Sarah 1:00 PM       │   │
│  │ +2 more                        │   │
│  └────────────────────────────────┘   │
│                                        │
│  🆕 PREMIUM                            │
│  ┌────────────────────────────────┐   │
│  │ 🔒 Waiky Premium               │   │
│  │ Unlock trends, unlimited AI... │   │
│  │ €4.99/mo        [ Upgrade ]    │   │
│  └────────────────────────────────┘   │
│                                        │
│                               [💬]    │
└───────────────────────────────────────┘
```

---

## 📊 Data Flow Diagram

```
┌─────────────┐
│  HomeView   │
└──────┬──────┘
       │
       ├─→ ScreenTimeManager → UserDefaults["todayScreenTime"]
       │
       ├─→ HabitTrackerView → UserDefaults["habits-2026-08-01"]
       │
       ├─→ CalendarManager → EventKit → todayEvents[]
       │
       └─→ PremiumView (modal only, no data)
```

```
┌──────────────┐
│ CheckInView  │
└──────┬───────┘
       │
       ├─→ HealthManager → HealthKit (HR, Sleep)
       │
       ├─→ CalendarManager → EventKit → isBusyDay
       │
       └─→ OpenAIManager.generateNudge(
               mood, sleep, HR, sleepHours, isBusyDay
           ) → AI Nudge
```

---

## 🐛 Troubleshooting

### Screen Time not saving
- Check UserDefaults key: `"todayScreenTime"`
- Verify ScreenTimeManager.shared.saveTodayScreenTime() is called
- Restart app to see if value persists

### Habits not persisting
- Check date format: `"habits-YYYY-MM-DD"`
- Verify timezone is correct
- Check if UserDefaults contains data for today's key

### Calendar not showing events
1. Check Info.plist has NSCalendarsUsageDescription
2. Verify permission granted in Settings → Privacy → Calendars
3. Add test events in Calendar app
4. Restart Waiky app to trigger fresh fetch

### Premium card not appearing
- Scroll to bottom of HomeView
- Check that PremiumCard is in the VStack
- Verify showPremium state variable exists

### Busy day context not appearing in nudge
- Verify 4+ calendar events exist for today
- Check CalendarManager.isBusyDay() returns true
- Enable mock AI responses to test logic
- Look for "busy day" in console logs

---

## 🎯 Success Criteria

✅ **Screen Time**
- [ ] Can log values from 0-600 minutes
- [ ] Progress bar updates correctly
- [ ] Data persists across app restarts
- [ ] Format shows hours when > 60 minutes

✅ **Habits**
- [ ] 4 default habits appear
- [ ] Checkboxes toggle and save
- [ ] Count updates on HomeView card
- [ ] New day resets habits

✅ **Calendar**
- [ ] Permission prompt appears
- [ ] Events display with times
- [ ] "No events" shows when empty
- [ ] Busy day affects AI nudge

✅ **Premium**
- [ ] Card displays at bottom
- [ ] Sheet opens with features
- [ ] Button is disabled
- [ ] Gradient renders correctly

---

## 🚀 Ready for Testing!

All four features are fully integrated and ready to test. Follow the walkthroughs above to verify each feature works as expected. Check the IMPLEMENTATION_SUMMARY.md for technical details and next steps for production.
