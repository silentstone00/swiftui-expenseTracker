# App Icon and Launch Screen Guide

## Overview

This guide explains how to add custom app icons and configure the launch screen for the Expense Tracker app.

## App Icon Configuration

### Current Setup

The app icon is configured in `expense_tracker/Assets.xcassets/AppIcon.appiconset/`. The configuration uses a single 1024x1024px image that iOS automatically scales to all required sizes.

### Design Guidelines

The app icon should reflect the expense tracker theme:

**Color Scheme:**
- Primary: Teal/Cyan (#66CCBF or RGB: 102, 204, 191)
- Secondary: Peach/Beige (#F2D9BF or RGB: 242, 217, 191)
- Background: Dark (#0D0D0D or RGB: 13, 13, 13)

**Design Recommendations:**
- Use a simple, recognizable symbol (e.g., dollar sign, wallet, chart)
- Apply the gradient from peach to teal for visual consistency
- Ensure the icon is clear and readable at small sizes (20x20px)
- Avoid text or fine details that won't scale well
- Consider using SF Symbols as inspiration (dollarsign.circle, chart.bar, wallet.pass)

### Adding Your Custom App Icon

#### Step 1: Create the Icon Image

Create a 1024x1024px PNG image with the following specifications:
- **Format:** PNG (no transparency for iOS app icons)
- **Size:** 1024x1024 pixels
- **Color Space:** sRGB or Display P3
- **Resolution:** 72 DPI minimum

**Design Tools:**
- Figma, Sketch, or Adobe Illustrator for vector design
- Export as PNG at 1024x1024px
- Use a solid background color (no transparency)

**Simple Icon Example:**
```
1. Create a 1024x1024px canvas with dark background (#0D0D0D)
2. Add a circular gradient from peach (#F2D9BF) to teal (#66CCBF)
3. Place a white dollar sign symbol in the center
4. Export as PNG
```

#### Step 2: Add the Icon to Xcode

1. **Locate the AppIcon folder:**
   - Navigate to `expense_tracker/Assets.xcassets/AppIcon.appiconset/`

2. **Add your icon file:**
   - Name your 1024x1024px icon file: `app-icon-1024.png`
   - Copy it into the `AppIcon.appiconset` folder
   - The `Contents.json` file is already configured to reference this filename

3. **Verify in Xcode:**
   - Open `expense_tracker.xcodeproj` in Xcode
   - Navigate to Assets.xcassets → AppIcon
   - You should see your icon displayed in the Universal iOS slot
   - Xcode will automatically generate all required sizes

#### Step 3: Build and Test

1. Clean build folder: `Product → Clean Build Folder` (Cmd+Shift+K)
2. Build and run on simulator or device
3. Check the home screen to see your new app icon
4. Verify the icon appears correctly in Settings and Spotlight search

### Icon Size Requirements (Handled Automatically)

iOS automatically generates these sizes from your 1024x1024px image:
- 20x20pt (2x, 3x) - Notifications, Settings
- 29x29pt (2x, 3x) - Settings
- 40x40pt (2x, 3x) - Spotlight
- 60x60pt (2x, 3x) - App icon on home screen
- 76x76pt (2x) - iPad
- 83.5x83.5pt (2x) - iPad Pro
- 1024x1024pt - App Store

### Troubleshooting

**Icon not appearing:**
- Ensure the filename matches exactly: `app-icon-1024.png`
- Verify the image is exactly 1024x1024 pixels
- Clean build folder and rebuild
- Delete the app from simulator/device and reinstall

**Icon looks blurry:**
- Ensure you're using a high-quality source image
- Export at exact 1024x1024px (not scaled)
- Use vector graphics when possible, then export to PNG

**Icon has wrong colors:**
- Check color space is sRGB or Display P3
- Verify colors match the theme (teal #66CCBF, peach #F2D9BF)

## Launch Screen Configuration

### Current Setup

The launch screen is implemented as a SwiftUI view in `expense_tracker/Views/LaunchScreenView.swift`.

### Launch Screen Design

The launch screen matches the app's dark theme:
- **Background:** Dark (#0D0D0D)
- **Icon:** Circular gradient (peach to teal) with dollar sign
- **Text:** "Expense Tracker" in white, "Track your finances" in gray
- **Style:** Minimal, clean, professional

### Customizing the Launch Screen

#### Option 1: Modify the SwiftUI View (Recommended)

Edit `expense_tracker/Views/LaunchScreenView.swift`:

```swift
// Change the icon
Image(systemName: "dollarsign.circle.fill") // Replace with your preferred SF Symbol

// Change the app name
Text("Expense Tracker") // Update to your app name

// Change the tagline
Text("Track your finances") // Update to your tagline

// Adjust colors
.foregroundColor(AppTheme.primaryText) // Use theme colors
```

#### Option 2: Use a Static Image

1. Create a 1170x2532px image (iPhone 14 Pro Max size)
2. Add it to Assets.xcassets
3. Update LaunchScreenView.swift to use the image:

```swift
Image("LaunchScreenImage")
    .resizable()
    .ignoresSafeArea()
```

### Launch Screen Best Practices

**Do:**
- Keep it simple and fast to load
- Match your app's visual style
- Use the same background color as your first screen
- Test on multiple device sizes

**Don't:**
- Add animations (not supported in launch screens)
- Include text that needs localization
- Use images with transparency
- Make it look like a loading screen with progress indicators

### Testing the Launch Screen

1. Build and run the app
2. The launch screen appears briefly when the app starts
3. To see it again, force quit and relaunch the app
4. Test on different device sizes in the simulator

## App Store Assets (Future)

When preparing for App Store submission, you'll need:

### App Store Icon
- 1024x1024px PNG (same as your app icon)
- No transparency, no rounded corners
- Upload directly to App Store Connect

### Screenshots
Required sizes for iPhone:
- 6.7" display (iPhone 14 Pro Max): 1290x2796px
- 6.5" display (iPhone 11 Pro Max): 1242x2688px
- 5.5" display (iPhone 8 Plus): 1242x2208px

Recommended screenshots:
1. Home screen with balance card
2. Transaction list with categories
3. Add transaction form
4. Monthly summary view
5. Dark mode showcase

### App Preview Video (Optional)
- 15-30 seconds
- Portrait orientation
- Show key features: adding transactions, viewing balance, categories

## Quick Reference

### File Locations
```
expense_tracker/
├── Assets.xcassets/
│   └── AppIcon.appiconset/
│       ├── Contents.json
│       └── app-icon-1024.png (add your icon here)
└── Views/
    └── LaunchScreenView.swift (customize launch screen)
```

### Theme Colors
```swift
Background:      #0D0D0D (RGB: 13, 13, 13)
Card Background: #1F1F1F (RGB: 31, 31, 31)
Primary Accent:  #66CCBF (RGB: 102, 204, 191) - Teal
Secondary:       #F2D9BF (RGB: 242, 217, 191) - Peach
Primary Text:    #FFFFFF (White)
Secondary Text:  #808080 (Gray)
```

### Design Resources

**Free Icon Design Tools:**
- [Figma](https://www.figma.com) - Professional design tool
- [Canva](https://www.canva.com) - Easy icon templates
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Apple's icon library

**Icon Generators:**
- [App Icon Generator](https://appicon.co) - Generate all sizes from one image
- [MakeAppIcon](https://makeappicon.com) - Free icon resizing

**Color Tools:**
- [Coolors](https://coolors.co) - Color palette generator
- [Adobe Color](https://color.adobe.com) - Color wheel and schemes

## Support

For questions or issues:
1. Check the troubleshooting section above
2. Review Apple's [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
3. Consult the [iOS App Icon specifications](https://developer.apple.com/design/human-interface-guidelines/app-icons#Specifications)
