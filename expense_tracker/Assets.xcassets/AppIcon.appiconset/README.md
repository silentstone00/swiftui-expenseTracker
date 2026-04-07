# App Icon Setup

## Quick Start

Add your custom app icon by placing a 1024x1024px PNG file named `app-icon-1024.png` in this directory.

## Design Specifications

**Required:**
- **Filename:** `app-icon-1024.png`
- **Size:** 1024x1024 pixels
- **Format:** PNG
- **Color Space:** sRGB or Display P3
- **Background:** Solid color (no transparency)

## Recommended Design

To match the Expense Tracker app theme:

**Colors:**
- Teal: #66CCBF (RGB: 102, 204, 191)
- Peach: #F2D9BF (RGB: 242, 217, 191)
- Dark: #0D0D0D (RGB: 13, 13, 13)

**Design Ideas:**
1. **Simple Dollar Sign:**
   - Dark background (#0D0D0D)
   - Circular gradient (peach to teal)
   - White dollar sign symbol in center

2. **Wallet Icon:**
   - Gradient background
   - Minimalist wallet outline
   - Clean, modern style

3. **Chart Symbol:**
   - Bar chart or line graph
   - Gradient colors
   - Financial theme

## Creating Your Icon

### Using Figma (Recommended)

1. Create a 1024x1024px frame
2. Add a dark background rectangle (#0D0D0D)
3. Create a circle with gradient fill:
   - Start color: #F2D9BF (peach)
   - End color: #66CCBF (teal)
   - Angle: 135° (top-left to bottom-right)
4. Add a white dollar sign or financial symbol
5. Export as PNG at 1x (1024x1024px)
6. Save as `app-icon-1024.png`

### Using SF Symbols

1. Open SF Symbols app (free from Apple)
2. Find a suitable symbol: `dollarsign.circle.fill`, `chart.bar.fill`, `wallet.pass.fill`
3. Export at large size
4. Import into your design tool
5. Apply gradient and export

### Using Online Tools

**Quick Icon Generator:**
1. Visit [appicon.co](https://appicon.co)
2. Upload a 1024x1024px design
3. Download the generated icon set
4. Copy `app-icon-1024.png` to this folder

## Verification

After adding your icon:

1. Open Xcode
2. Navigate to Assets.xcassets → AppIcon
3. Verify the icon appears in the Universal iOS slot
4. Build and run the app
5. Check the home screen for your icon

## Current Status

⚠️ **No custom icon added yet**

The app will use the default iOS placeholder icon until you add `app-icon-1024.png` to this directory.

## Need Help?

See the complete guide: `APP_ICON_GUIDE.md` in the project root directory.
