# Munro Bagging App - Design System

## Overview

A dark, modern, inspiring design system for a Scottish mountain climbing (Munro bagging) app with glassmorphic effects and emerald green accents.

---

## Color Palette

### Primary Colors

- **Emerald Green (Primary Action)**: `#10B981` / `bg-emerald-500` / `text-emerald-500`
  - Used for: Primary buttons, active states, progress indicators, unread dots, links
  - Hover state: `bg-emerald-600` / `hover:bg-emerald-600`

### Dark Theme (Default)

- **Background**: `bg-gray-900` (#111827 / oklch(0.145 0 0))
- **Surface/Cards**: `bg-gray-800` (#1F2937) or glassmorphic
- **Text Primary**: `text-white` / `text-gray-100`
- **Text Secondary**: `text-gray-400` / `text-gray-500`
- **Borders**: `border-gray-800` / `border-gray-700`
- **Hover Overlays**: `hover:bg-white/5` or `hover:bg-white/10`

### Light Theme

- **Background**: `bg-gray-50` (#F9FAFB)
- **Surface/Cards**: `bg-white`
- **Text Primary**: `text-gray-900` / `text-gray-800`
- **Text Secondary**: `text-gray-600` / `text-gray-500`
- **Borders**: `border-gray-200` / `border-gray-300`
- **Hover Overlays**: `hover:bg-gray-50` or `hover:bg-gray-100`

### Semantic Colors

- **Success**: `bg-emerald-500` / `text-emerald-500`
- **Error/Destructive**: `bg-red-500` / `text-red-500`
- **Warning**: `bg-orange-500` / `text-orange-500`
- **Info**: `bg-blue-500` / `text-blue-500`

### Avatar/Profile Colors (Random Assignment)

```javascript
const colors = ["bg-emerald-600", "bg-blue-600", "bg-purple-600", "bg-orange-600", "bg-pink-600", "bg-indigo-600"];
```

---

## Typography

### Font Family

- **Primary Font**: System font stack (default Tailwind)
  ```css
  font-family:
    ui-sans-serif,
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    Roboto,
    "Helvetica Neue",
    Arial,
    sans-serif;
  ```
- **Application**: Applied globally, no custom fonts needed

### Font Weights

- **Normal**: `font-normal` (400) - Default body text
- **Medium**: `font-medium` (500) - **Preferred for most UI elements** (buttons, labels, list items, card titles)
- **Semibold**: `font-semibold` (600) - **Use sparingly, avoid in lists** (section headers only)
- **Bold**: `font-bold` (700) - **Only for page titles** (H1 elements)

### Font Sizes (with px equivalents)

- **3XL**: `text-3xl` - 30px / 1.875rem - Hero headings
- **2XL**: `text-2xl` - 24px / 1.5rem - Page titles, H1
- **XL**: `text-xl` - 20px / 1.25rem - Section headers, H2
- **LG**: `text-lg` - 18px / 1.125rem - Subheaders, H3
- **Base**: `text-base` - 16px / 1rem - Body text, default (most common)
- **SM**: `text-sm` - 14px / 0.875rem - Secondary text, captions
- **XS**: `text-xs` - 12px / 0.75rem - Timestamps, labels, helper text

### Line Heights (with values)

- **Tight**: `leading-tight` (1.25) - 20px for 16px text - Used for headings
- **Normal**: `leading-normal` (1.5) - 24px for 16px text - Default for body text
- **Relaxed**: `leading-relaxed` (1.625) - 26px for 16px text - Used for longer text blocks

### Text Patterns with Complete Specifications

- **Page Titles**:
  - Classes: `text-2xl font-bold`
  - Size: 24px / Weight: 700 / Line-height: 32px (1.33)
  - Color: `text-white` (dark) / `text-gray-900` (light)
- **Section Headers**:
  - Classes: `text-lg font-medium`
  - Size: 18px / Weight: 500 / Line-height: 28px (1.56)
  - Color: `text-white` (dark) / `text-gray-900` (light)
- **Subsection Headers / Card Titles**:
  - Classes: `font-medium` (inherits base size)
  - Size: 16px / Weight: 500 / Line-height: 24px (1.5)
  - Color: `text-white` (dark) / `text-gray-900` (light)
- **Body Text**:
  - Classes: `text-sm`
  - Size: 14px / Weight: 400 / Line-height: 20px (1.43)
  - Color: `text-gray-200` (dark) / `text-gray-800` (light)
- **Secondary Text / Metadata**:
  - Classes: `text-sm`
  - Size: 14px / Weight: 400 / Line-height: 20px (1.43)
  - Color: `text-gray-400` (dark) / `text-gray-600` (light)
- **Timestamps / Small Labels**:
  - Classes: `text-xs`
  - Size: 12px / Weight: 400 / Line-height: 16px (1.33)
  - Color: `text-gray-500` (both themes)

### Text Hierarchy Best Practices

- Avoid overusing bold/semibold - prefer `font-medium` for UI elements
- Use font size and color to create hierarchy, not just weight
- Reserve `font-semibold` and `font-bold` for true emphasis only
- Default to `font-medium` (500) for all interactive elements and labels

### Text Separators

- **Preferred**: Use centered dot `·` (Alt+0183 or &middot;) for inline separators
- **Example**: `Cairngorms · 1,309m` instead of `Cairngorms - 1,309m`
- Creates better visual hierarchy and looks more refined

---

## Spacing

### Standard Spacing Scale (Tailwind with px values)

- **XS**: `gap-1` / `p-1` - 4px / 0.25rem
- **SM**: `gap-2` / `p-2` - 8px / 0.5rem
- **MD**: `gap-3` / `p-3` - 12px / 0.75rem
- **Base**: `gap-4` / `p-4` - 16px / 1rem - **Most common, default for screens and cards**
- **LG**: `gap-6` / `p-6` - 24px / 1.5rem
- **XL**: `gap-8` / `p-8` - 32px / 2rem
- **2XL**: `gap-12` / `p-12` - 48px / 3rem

### Default Padding Specifications

- **Screen Padding**: `p-4` (16px all sides)
- **Card Internal Padding**: `p-4` (16px) or `p-6` (24px for larger cards)
- **Header Padding**: `p-4` (16px)
- **Bottom Navigation Padding**: `p-4` (16px)
- **List Item Padding**: `px-4 py-4` (16px horizontal, 16px vertical)
- **Button Padding**:
  - Small: `py-2 px-3` (8px vertical, 12px horizontal)
  - Base: `py-3 px-4` (12px vertical, 16px horizontal)
  - Large: `py-4 px-6` (16px vertical, 24px horizontal)

### Component Gaps (between elements)

- **Tight**: `gap-2` (8px) - Between closely related items
- **Base**: `gap-3` (12px) - Standard component gap
- **Default**: `gap-4` (16px) - **Most common, between cards/sections**
- **Loose**: `gap-6` (24px) - Between major sections

### Vertical Spacing (stacked elements)

- **Tight**: `space-y-2` (8px between items)
- **Base**: `space-y-3` (12px between items)
- **Default**: `space-y-4` (16px between items) - **Most common**
- **Loose**: `space-y-6` (24px between items)

### Special Spacing

- **Bottom Navigation Clearance**: `pb-24` (96px) - Added to screen content to clear fixed bottom nav
- **Margin Bottom (sections)**: `mb-3` (12px), `mb-4` (16px), `mb-6` (24px)

---

## Border Radius

### Sizes (with px values)

- **SM**: `rounded-sm` - 2px / 0.125rem
- **Base**: `rounded` - 4px / 0.25rem
- **MD**: `rounded-md` - 6px / 0.375rem
- **LG**: `rounded-lg` - 8px / 0.5rem
- **XL**: `rounded-xl` - 12px / 0.75rem - **Buttons, inputs, small cards**
- **2XL**: `rounded-2xl` - 16px / 1rem - **Standard for cards and glassmorphic elements**
- **3XL**: `rounded-3xl` - 24px / 1.5rem - **Large cards, hero sections, post cards**
- **Full**: `rounded-full` - 9999px - **Circular elements (avatars, icon buttons, pills)**

### Common Patterns with Specifications

- **Standard Cards**: `rounded-2xl` (16px)
- **Large/Post Cards**: `rounded-3xl` (24px)
- **Text Buttons**: `rounded-xl` (12px)
- **Icon Buttons**: `rounded-full` (circular)
- **Avatars**: `rounded-full` (circular)
- **Images in Cards**: `rounded-xl` (12px) or `rounded-2xl` (16px)
- **Text Inputs**: `rounded-xl` (12px)
- **Badges/Pills**: `rounded-full` (circular)
- **Checkboxes (circular)**: `rounded-full` (circular)
- **Checkboxes (square)**: `rounded-md` (6px)

---

## Borders

### Thickness (with px values)

- **Default**: `border` - 1px - **Most common, use for all cards and UI elements**
- **Thin**: `border-0.5` - 0.5px - Subtle dividers (rarely used)
- **Thick**: `border-2` - 2px - **Avoid in most cases, creates visual heaviness**
  - Only use for: Outline buttons when `border-2` is needed for emphasis
- **None**: `border-0` - 0px - Remove borders

### Colors (with hex codes)

**Dark Theme:**

- **Standard Card Border**: `border-white/10` - White at 10% opacity
- **Solid Border**: `border-gray-800` - #1F2937
- **Divider**: `border-gray-800` - #1F2937
- **Active/Selected**: `border-emerald-500` - #10B981
- **Soft Active**: `border-emerald-500/50` - #10B981 at 50% opacity
- **Hover State**: `border-emerald-500/50` - #10B981 at 50% opacity
- **Checkbox Unselected**: `border-gray-600` - #4B5563

**Light Theme:**

- **Standard Card Border**: `border-gray-200` - #E5E7EB
- **Divider**: `border-gray-100` or `border-gray-200` - #F3F4F6 or #E5E7EB
- **Active/Selected**: `border-emerald-500` - #10B981
- **Soft Active**: `border-emerald-500/50` - #10B981 at 50% opacity
- **Hover State**: `border-emerald-500/50` - #10B981 at 50% opacity
- **Checkbox Unselected**: `border-gray-300` - #D1D5DB

### Common Patterns with Full Specifications

- **Standard Card Border**:
  - Dark: `border border-white/10` (1px, white 10% opacity)
  - Light: `border border-gray-200` (1px, #E5E7EB)
- **Glassmorphic Card Border**:
  - Dark: `border border-white/10` (1px, white 10% opacity)
  - Light: `border border-gray-200` (1px, #E5E7EB)
- **Selected Card Border**:
  - Dark: `border border-emerald-500` (1px, #10B981)
  - Light: `border border-emerald-500` (1px, #10B981)
- **Hover State Border**:
  - Dark: `border-emerald-500/50` (1px, #10B981 50% opacity)
  - Light: `border-emerald-500/50` (1px, #10B981 50% opacity)
- **Horizontal Dividers**:
  - Dark: `border-b border-gray-800` (1px bottom, #1F2937)
  - Light: `border-b border-gray-200` (1px bottom, #E5E7EB)
- **List Item Dividers**:
  - Dark: `border-b border-white/5` (1px bottom, white 5% opacity)
  - Light: `border-b border-gray-100` (1px bottom, #F3F4F6)

### Border Best Practices

- Default to `border` (1px) for clean, refined appearance
- Avoid `border-2` except for outline buttons where emphasis is needed
- Use opacity variations (`border-emerald-500/50`) for softer, less aggressive emphasis
- Use `border-white/10` for glassmorphic cards in dark mode
- Use `border-gray-800` for solid borders in dark mode

---

## Shadows

### Standard Shadows

- **SM**: `shadow-sm` - Subtle elevation
- **Base**: `shadow` - Default shadow
- **MD**: `shadow-md` - Cards
- **LG**: `shadow-lg` - Modals, popups
- **XL**: `shadow-xl` - Hero sections
- **2XL**: `shadow-2xl` - Overlays

### Custom Shadows

- **None**: `shadow-none` - For glassmorphic effects where shadow conflicts with backdrop blur

### Common Patterns

- **Cards**: Usually no shadow in dark theme, rely on borders and glassmorphic effects
- **Bottom Sheets**: `shadow-lg` or `shadow-xl`
- **Floating Buttons**: `shadow-lg`

---

## Glassmorphic Effects

### Standard Glass Pattern

```jsx
className={`
  rounded-2xl
  ${theme === 'dark'
    ? 'glass-effect border border-white/10'
    : 'bg-white border border-gray-200'
  }
`}
```

### Glass Effect CSS (if using custom class)

```css
.glass-effect {
  background: rgba(31, 41, 55, 0.6);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}
```

### Backdrop Blur Alternatives (Tailwind)

- **SM**: `backdrop-blur-sm` (4px)
- **Base**: `backdrop-blur` (8px)
- **MD**: `backdrop-blur-md` (12px) - **Standard for glass**
- **LG**: `backdrop-blur-lg` (16px)

### Glass Background Colors (Dark Theme)

- `bg-gray-800/60` - 60% opacity
- `bg-gray-800/80` - 80% opacity
- `bg-gray-900/95` - Sticky headers (95% opacity)

---

## Buttons

### Primary Button (Emerald)

```jsx
<button className="w-full py-3 px-4 bg-emerald-500 hover:bg-emerald-600 text-white font-medium rounded-xl transition-colors">
  Follow
</button>
```

### Secondary Button (Outline)

```jsx
<button
  className={`
  w-full py-3 px-4 
  border-2 border-emerald-500 
  text-emerald-500 
  font-medium rounded-xl 
  transition-colors
  ${theme === "dark" ? "hover:bg-emerald-500/10" : "hover:bg-emerald-50"}
`}
>
  Following
</button>
```

### Ghost/Text Button

```jsx
<button
  className={`
  px-4 py-2 
  rounded-lg 
  transition-colors
  ${theme === "dark" ? "hover:bg-white/5 text-gray-400" : "hover:bg-gray-100 text-gray-600"}
`}
>
  Action
</button>
```

### Icon Button (Circular)

```jsx
<button
  className={`
  w-10 h-10 
  rounded-full 
  flex items-center justify-center 
  transition-colors
  ${theme === "dark" ? "hover:bg-white/10 text-white" : "hover:bg-gray-100 text-gray-900"}
`}
>
  <Icon className="w-5 h-5" />
</button>
```

### Button Sizes

- **Small**: `py-2 px-3 text-sm`
- **Base**: `py-3 px-4 text-base` - **Most common**
- **Large**: `py-4 px-6 text-lg`

---

## Cards

### Standard Card

```jsx
<div
  className={`
  rounded-2xl p-4
  ${theme === "dark" ? "glass-effect border border-white/10" : "bg-white border border-gray-200"}
`}
>
  {/* Content */}
</div>
```

### Post Card

```jsx
<div
  className={`
  rounded-2xl overflow-hidden
  ${theme === "dark" ? "glass-effect border border-white/10" : "bg-white border border-gray-200"}
`}
>
  {/* Header */}
  <div className="p-4">...</div>

  {/* Image */}
  <div className="relative">...</div>

  {/* Footer */}
  <div className="p-4">...</div>
</div>
```

### Interactive Card

```jsx
<button
  className={`
  w-full rounded-2xl p-4 text-left
  transition-all duration-200
  ${
    theme === "dark"
      ? "glass-effect border border-white/10 hover:border-emerald-500/50 hover:bg-white/5"
      : "bg-white border border-gray-200 hover:border-emerald-500 hover:shadow-md"
  }
`}
>
  {/* Content */}
</button>
```

### Selectable Card (Munro/Item Selection)

```jsx
<button
  onClick={() => toggleSelection(id)}
  className={`w-full rounded-2xl p-4 text-left transition-all ${
    isSelected
      ? theme === "dark"
        ? "bg-emerald-500/10 border border-emerald-500"
        : "bg-emerald-50 border border-emerald-500"
      : theme === "dark"
        ? "glass-effect border border-white/10 hover:border-emerald-500/50"
        : "bg-white border border-gray-200 hover:border-emerald-500/50"
  }`}
>
  <div className="flex items-center gap-3">
    {/* Checkbox */}
    <div
      className={`w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 transition-colors ${
        isSelected ? "bg-emerald-500" : theme === "dark" ? "border border-gray-600" : "border border-gray-300"
      }`}
    >
      {isSelected && <Check className="w-4 h-4 text-white" />}
    </div>

    {/* Content */}
    <div className="flex-1">
      <div className={`font-medium ${theme === "dark" ? "text-white" : "text-gray-900"}`}>{title}</div>
      <div className={`text-sm ${theme === "dark" ? "text-gray-400" : "text-gray-600"}`}>
        {subtitle} · {detail}
      </div>
    </div>
  </div>
</button>
```

### Clickable Post Card

```jsx
<div
  className={`rounded-3xl overflow-hidden ${
    theme === "dark" ? "glass-effect border border-white/10" : "bg-white border border-gray-200"
  }`}
>
  {/* Header */}
  <div className="p-4">...</div>

  {/* Clickable Image */}
  <button onClick={() => onPostClick(postId)} className="relative -mx-4 mb-3 w-[calc(100%+2rem)] block">
    <img src={photo} alt={alt} className="w-full h-full object-cover aspect-square" />
  </button>

  {/* Footer */}
  <div className="p-4">...</div>
</div>
```

---

## Lists & Notifications

### List Item

```jsx
<button
  className={`
  w-full flex items-center gap-3 px-4 py-4
  transition-colors
  ${theme === "dark" ? "hover:bg-white/5 border-b border-gray-800" : "hover:bg-gray-50 border-b border-gray-200"}
`}
>
  {/* Icon/Avatar */}
  <div className="flex-shrink-0">...</div>

  {/* Content */}
  <div className="flex-1 text-left">...</div>

  {/* Action */}
  <div>...</div>
</button>
```

### Unread Indicator

```jsx
<div className="w-2 h-2 bg-emerald-500 rounded-full" />
```

---

## Avatars

### Circular Avatar with Initials

```jsx
<div
  className={`
  w-10 h-10 
  rounded-full 
  flex items-center justify-center 
  text-white text-sm font-medium
  ${profileColor}
`}
>
  {initials}
</div>
```

### Avatar Sizes

- **XS**: `w-6 h-6 text-xs` (24px)
- **SM**: `w-8 h-8 text-xs` (32px)
- **Base**: `w-10 h-10 text-sm` (40px) - **Most common**
- **LG**: `w-12 h-12 text-base` (48px)
- **XL**: `w-16 h-16 text-lg` (64px)
- **2XL**: `w-20 h-20 text-xl` (80px)

---

## Headers (Sticky)

### Standard Header

```jsx
<div
  className={`
  sticky top-0 z-10
  ${theme === "dark" ? "bg-gray-900 backdrop-blur-lg" : "bg-white backdrop-blur-lg"}
  border-b 
  ${theme === "dark" ? "border-gray-800" : "border-gray-200"}
`}
>
  <div className="flex items-center justify-between p-4">
    {/* Back button */}
    {/* Title */}
    {/* Action */}
  </div>
</div>
```

### Header with Transparency

```jsx
className={`
  sticky top-0 z-10
  ${theme === 'dark'
    ? 'bg-gray-900/95 backdrop-blur-lg'
    : 'bg-white/95 backdrop-blur-lg'
  }
  border-b
  ${theme === 'dark' ? 'border-gray-800' : 'border-gray-200'}
`}
```

---

## Forms & Inputs

### Text Input

```jsx
<input
  type="text"
  className={`
    w-full px-4 py-3 
    rounded-xl 
    border 
    ${
      theme === "dark"
        ? "bg-gray-800 border-gray-700 text-white placeholder-gray-500 focus:border-emerald-500"
        : "bg-white border-gray-200 text-gray-900 placeholder-gray-400 focus:border-emerald-500"
    }
    outline-none transition-colors
  `}
  placeholder="Enter text..."
/>
```

### Toggle Switch

```jsx
<button
  onClick={toggle}
  className={`
    relative w-12 h-7 rounded-full 
    transition-colors flex-shrink-0
    ${isEnabled ? "bg-emerald-500" : theme === "dark" ? "bg-white/20" : "bg-gray-300"}
  `}
>
  <div
    className={`
    absolute top-1 w-5 h-5 rounded-full bg-white 
    transition-transform
    ${isEnabled ? "translate-x-6" : "translate-x-1"}
  `}
  />
</button>
```

---

## Icons

### Icon Library

**Lucide React** is the primary icon library

### Icon Sizes

- **XS**: `w-3 h-3` (12px)
- **SM**: `w-4 h-4` (16px)
- **Base**: `w-5 h-5` (20px) - **Most common**
- **LG**: `w-6 h-6` (24px)
- **XL**: `w-8 h-8` (32px)

### Icon Colors

- **Dark Theme**: `text-gray-400` (inactive), `text-white` (active), `text-emerald-500` (primary)
- **Light Theme**: `text-gray-600` (inactive), `text-gray-900` (active), `text-emerald-500` (primary)

---

## Progress Bars

### Linear Progress

```jsx
<div
  className={`
  h-2 rounded-full overflow-hidden
  ${theme === "dark" ? "bg-gray-800" : "bg-gray-200"}
`}
>
  <div className="h-full bg-emerald-500 transition-all duration-300" style={{ width: `${percentage}%` }} />
</div>
```

### Circular Progress (SVG)

```jsx
<svg className="w-16 h-16 transform -rotate-90">
  {/* Background circle */}
  <circle
    cx="32"
    cy="32"
    r="28"
    stroke="currentColor"
    strokeWidth="4"
    fill="none"
    className={theme === "dark" ? "text-gray-800" : "text-gray-200"}
  />
  {/* Progress circle */}
  <circle
    cx="32"
    cy="32"
    r="28"
    stroke="currentColor"
    strokeWidth="4"
    fill="none"
    className="text-emerald-500"
    strokeDasharray={circumference}
    strokeDashoffset={circumference - (percentage / 100) * circumference}
    strokeLinecap="round"
  />
</svg>
```

---

## Transitions & Animations

### Standard Transitions

- **Colors**: `transition-colors`
- **All**: `transition-all`
- **Transform**: `transition-transform`
- **Duration**: `duration-200` (most common), `duration-300`

### Hover States

- **Opacity Change**: `hover:opacity-80`
- **Background Overlay**: `hover:bg-white/5` (dark) / `hover:bg-gray-50` (light)
- **Scale**: `hover:scale-105 transition-transform`

---

## Z-Index Layers

- **Bottom Nav**: `z-10`
- **Sticky Headers**: `z-10`
- **Dropdown Menus**: `z-20`
- **Modals/Overlays**: `z-30`
- **Bottom Sheets**: `z-40`
- **Toasts**: `z-50`

---

## Bottom Navigation

### Standard Bottom Nav

```jsx
<div
  className={`
  fixed bottom-0 left-0 right-0 z-10
  ${theme === "dark" ? "bg-gray-900 border-t border-gray-800" : "bg-white border-t border-gray-200"}
`}
>
  <div className="flex items-center justify-around p-4">{/* Nav items */}</div>
</div>
```

### Active Tab Indicator

```jsx
className={`
  text-sm font-medium
  ${isActive
    ? 'text-emerald-500'
    : theme === 'dark' ? 'text-gray-400' : 'text-gray-600'
  }
`}
```

---

## Badges & Pills

### Badge

```jsx
<span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-emerald-500/10 text-emerald-500">
  New
</span>
```

### Notification Badge (Red Dot)

```jsx
<div className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />
```

### Count Badge

```jsx
<span className="absolute -top-1 -right-1 min-w-5 h-5 flex items-center justify-center px-1 rounded-full text-xs font-medium bg-red-500 text-white">
  {count}
</span>
```

---

## Images

### Image Container with Aspect Ratio

```jsx
<div className="relative aspect-square rounded-xl overflow-hidden">
  <img src={url} alt={alt} className="w-full h-full object-cover" />
</div>
```

### Image Carousel Dots

```jsx
<div className="absolute bottom-2 left-0 right-0 flex justify-center gap-1">
  {photos.map((_, index) => (
    <div
      key={index}
      className={`
        w-1.5 h-1.5 rounded-full transition-colors
        ${index === activeIndex ? "bg-white" : "bg-white/50"}
      `}
    />
  ))}
</div>
```

---

## Breakpoints (Responsive)

Standard Tailwind breakpoints:

- **SM**: `sm:` - 640px
- **MD**: `md:` - 768px
- **LG**: `lg:` - 1024px
- **XL**: `xl:` - 1280px
- **2XL**: `2xl:` - 1536px

Most components are mobile-first and don't need extensive responsive changes.

---

## Accessibility

### Focus States

- **Outline**: Default Tailwind focus ring with emerald color
- **Custom Focus**: `focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2`

### Interactive Elements

- Always use semantic HTML (`<button>`, `<a>`, `<input>`)
- Include `aria-label` for icon-only buttons
- Use `sr-only` class for screen reader text

---

## Common Component Patterns

### User Header (in posts/notifications)

```jsx
<div className="flex items-center gap-3">
  {/* Avatar */}
  <div
    className={`w-10 h-10 rounded-full flex items-center justify-center text-white text-sm font-medium ${profileColor}`}
  >
    {initials}
  </div>

  {/* User info */}
  <div className="flex-1">
    <p className={`font-medium text-sm ${theme === "dark" ? "text-white" : "text-gray-900"}`}>{userName}</p>
    <p className={`text-xs ${theme === "dark" ? "text-gray-500" : "text-gray-600"}`}>{timestamp}</p>
  </div>
</div>
```

### Loading State

```jsx
<div className="flex items-center justify-center py-8">
  <div className="w-8 h-8 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin" />
</div>
```

### Empty State

```jsx
<div className="flex flex-col items-center justify-center py-12 px-4 text-center">
  <Icon className={`w-12 h-12 mb-4 ${theme === "dark" ? "text-gray-600" : "text-gray-400"}`} />
  <p className={`text-lg font-medium mb-1 ${theme === "dark" ? "text-white" : "text-gray-900"}`}>No items yet</p>
  <p className={`text-sm ${theme === "dark" ? "text-gray-400" : "text-gray-600"}`}>Your items will appear here</p>
</div>
```

---

## Key Design Principles

1. **Dark First**: Design primarily for dark mode, ensure light mode works as fallback
2. **Glassmorphism**: Use blur effects and transparency for depth and modern feel
3. **Emerald Accent**: Use emerald green (#10B981) sparingly for primary actions and active states
4. **Generous Spacing**: Use `p-4` and `gap-4` as baseline for comfortable layouts
5. **Rounded Corners**: Prefer `rounded-2xl` for cards and `rounded-xl` for buttons
6. **Subtle Borders**: Use thin borders with low opacity for definition
7. **Consistent Icons**: Use Lucide React icons at `w-5 h-5` for consistency
8. **Mobile First**: Optimize for mobile with touch-friendly targets (min 44px height)
9. **Smooth Transitions**: Add `transition-colors` or `transition-all` to interactive elements
10. **Clear Hierarchy**: Use font size, weight, and color to establish information hierarchy
