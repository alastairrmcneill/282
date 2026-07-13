# Munro Bagging App - Component Library

A set of reusable Flutter widgets following the Munro Design System. Each widget uses `MyColors` for colour, `phosphor_flutter` for icons, and follows standard `StatelessWidget` / `StatefulWidget` patterns.

---

## Component Hierarchy

```
Base Widgets (Primitives)
├── AppText
├── AppButton
├── AppCard
└── AppAvatar

Compound Widgets (Built on Base)
├── AppHeader (uses AppButton, AppText)
├── AppListItem (uses AppText, AppAvatar)
├── UserHeader (uses AppAvatar, AppText)
├── SelectableCard (uses AppCard, CustomCheckbox)
├── PostCard (uses AppCard, UserHeader, AppButton)
└── BottomNavItem (uses Icon, AppText)

Layout Widgets
├── ScreenScaffold
└── AppSection
```

---

## 1. Layout Widgets

### ScreenScaffold

**Purpose**: Base scaffold for all screens. Wraps `Scaffold` with `SafeArea` and consistent background colour.

```dart
Scaffold(
  backgroundColor: MyColors.backgroundColor,
  appBar: AppHeader(title: 'Feed'),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [...]),
    ),
  ),
  bottomNavigationBar: AppBottomNav(...),
)
```

---

### AppSection

**Purpose**: Groups related content with an optional title and consistent vertical spacing.

**Parameters**: `title` (optional), `children`, `spacing` (tight=8, base=12, default=16, loose=24)

```dart
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    this.title,
    required this.children,
    this.spacing = 16,
  });

  final String? title;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          AppText(title!, variant: AppTextVariant.sectionHeader),
          SizedBox(height: spacing),
        ],
        ...children.map((child) => Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: child,
        )),
      ],
    );
  }
}
```

**Usage**:

```dart
AppSection(
  title: 'Recent Activity',
  children: [card1, card2],
)
```

---

## 2. Typography

### AppText

**Purpose**: Base text widget with all typography variants from the design system.

**Variants**: `pageTitle`, `sectionHeader`, `subsectionHeader`, `body`, `secondary`, `caption`, `label`

```dart
enum AppTextVariant {
  pageTitle,        // 24sp, bold,  textColor
  sectionHeader,    // 18sp, w500,  textColor
  subsectionHeader, // 16sp, w500,  textColor
  body,             // 14sp, normal textColor
  secondary,        // 14sp, normal mutedText
  caption,          // 12sp, normal mutedText
  label,            // 14sp, w500,  textColor
}

class AppText extends StatelessWidget {
  const AppText(this.text, {super.key, this.variant = AppTextVariant.body});

  final String text;
  final AppTextVariant variant;

  @override
  Widget build(BuildContext context) {
    final styles = {
      AppTextVariant.pageTitle:        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,    color: MyColors.textColor),
      AppTextVariant.sectionHeader:    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500,    color: MyColors.textColor),
      AppTextVariant.subsectionHeader: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,    color: MyColors.textColor),
      AppTextVariant.body:             const TextStyle(fontSize: 14,                                 color: MyColors.textColor),
      AppTextVariant.secondary:        const TextStyle(fontSize: 14,                                 color: MyColors.mutedText),
      AppTextVariant.caption:          const TextStyle(fontSize: 12,                                 color: MyColors.mutedText),
      AppTextVariant.label:            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,    color: MyColors.textColor),
    };
    return Text(text, style: styles[variant]);
  }
}
```

**Usage**:

```dart
AppText('Ben Nevis', variant: AppTextVariant.pageTitle)
AppText('Cairngorms · 1,309m', variant: AppTextVariant.secondary)
```

---

## 3. Button Widgets

### AppButton

**Purpose**: Base button with primary, secondary, and ghost variants.

**Parameters**: `label`, `onPressed`, `variant` (primary/secondary/ghost), `size` (small/base/large), `fullWidth`, `isLoading`

```dart
enum AppButtonVariant { primary, secondary, ghost }
enum AppButtonSize { small, base, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.base,
    this.fullWidth = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final padding = switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      AppButtonSize.base  => const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      AppButtonSize.large => const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    };

    final child = isLoading
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w500));

    final button = switch (variant) {
      AppButtonVariant.primary   => ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(padding: padding), child: child),
      AppButtonVariant.secondary => OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(padding: padding), child: child),
      AppButtonVariant.ghost     => TextButton(onPressed: onPressed, style: TextButton.styleFrom(padding: padding), child: child),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
```

**Usage**:

```dart
AppButton(label: 'Follow', onPressed: handleFollow, fullWidth: true)
AppButton(label: 'Following', variant: AppButtonVariant.secondary, onPressed: handleUnfollow)
AppButton(label: 'Cancel', variant: AppButtonVariant.ghost, size: AppButtonSize.small, onPressed: () => Navigator.pop(context))
```

---

### CircularIconButton

**Purpose**: Circular tappable button for icon-only actions.

**Parameters**: `icon`, `onPressed`, `size` (small=32, base=40, large=48), `isActive`

```dart
class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size / 2),
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: size * 0.5,
          color: isActive ? MyColors.accentColor : MyColors.mutedText,
        ),
      ),
    );
  }
}
```

**Usage**:

```dart
CircularIconButton(icon: PhosphorIconsRegular.heart, onPressed: handleLike)
CircularIconButton(icon: PhosphorIconsFill.heart, isActive: true, onPressed: handleUnlike)
```

---

## 4. Card Widgets

### AppCard

**Purpose**: Base card with consistent border, radius, and padding.

**Parameters**: `child`, `padding` (default EdgeInsets.all(16)), `borderRadius` (default 16), `onTap`

```dart
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: MyColors.lightGrey),
        ),
        child: child,
      ),
    );
  }
}
```

**Usage**:

```dart
AppCard(
  child: Column(children: [
    AppText('Card Title', variant: AppTextVariant.subsectionHeader),
    AppText('Card content', variant: AppTextVariant.body),
  ]),
)

// Tappable card
AppCard(
  onTap: () => Navigator.of(context).pushNamed(MunroScreen.route, arguments: args),
  child: ...,
)
```

---

### SelectableCard

**Purpose**: Card with circular checkbox for selection (e.g. munro selection lists).

**Parameters**: `title`, `subtitle`, `detail` (optional, e.g. "1,345m"), `isSelected`, `onToggle`

```dart
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.detail,
    required this.isSelected,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final String? detail;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? MyColors.accentColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? MyColors.accentColor : MyColors.lightGrey),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? MyColors.accentColor : Colors.transparent,
                border: Border.all(color: isSelected ? MyColors.accentColor : context.colors.middleGrey),
              ),
              child: isSelected
                  ? const Icon(PhosphorIconsBold.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, variant: AppTextVariant.label),
                  AppText(
                    detail != null ? '$subtitle · $detail' : subtitle,
                    variant: AppTextVariant.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Usage**:

```dart
SelectableCard(
  title: 'Ben Nevis',
  subtitle: 'Grampians',
  detail: '1,345m',
  isSelected: selectedIds.contains(munro.id),
  onToggle: () => toggleSelection(munro.id),
)
```

---

## 5. Avatar Widget

### AppAvatar

**Purpose**: Circular avatar showing a profile image or initials fallback.

**Parameters**: `initials`, `size` (xs=24, sm=32, base=40, lg=48, xl=64, xxl=80), `imageUrl`, `color`

```dart
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.imageUrl,
    this.color,
  });

  final String initials;
  final double size;
  final String? imageUrl;
  final Color? color;

  static const _palette = [
    Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFF8B5CF6),
    Color(0xFFF97316), Color(0xFFEC4899), Color(0xFF6366F1),
  ];

  Color get _derivedColor => _palette[initials.codeUnitAt(0) % _palette.length];

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color ?? _derivedColor,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: size * 0.35,
              ),
            )
          : null,
    );
  }
}
```

**Usage**:

```dart
AppAvatar(initials: 'JD')
AppAvatar(initials: 'SM', size: 48)
AppAvatar(initials: 'AB', imageUrl: user.profileImageUrl)
```

---

## 6. List Widget

### AppListItem

**Purpose**: Tappable list row with leading, content, and optional trailing widget. Includes a bottom divider.

**Parameters**: `leading`, `title`, `subtitle`, `trailing`, `onTap`, `showDivider`

```dart
class AppListItem extends StatelessWidget {
  const AppListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: leading,
          title: AppText(title, variant: AppTextVariant.label),
          subtitle: subtitle != null
              ? AppText(subtitle!, variant: AppTextVariant.secondary)
              : null,
          trailing: trailing,
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
```

**Usage**:

```dart
AppListItem(
  leading: AppAvatar(initials: 'JD', size: 32),
  title: 'John Doe',
  subtitle: '2 hours ago',
  onTap: () => Navigator.of(context).pushNamed(ProfileScreen.route),
)
```

---

## 7. Input Widgets

### AppTextField

**Purpose**: Styled text field with consistent border, focus, and error states.

**Parameters**: `controller`, `placeholder`, `keyboardType`, `obscureText`, `errorText`, `enabled`, `onChanged`

```dart
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.errorText,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? placeholder;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: placeholder,
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: MyColors.lightGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: MyColors.accentColor)),
        errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }
}
```

**Usage**:

```dart
AppTextField(
  controller: emailController,
  placeholder: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
)
```

---

### AppToggle

**Purpose**: Toggle switch for boolean settings. Wraps Flutter's `Switch`.

```dart
Switch(
  value: notificationsEnabled,
  onChanged: (v) => setState(() => notificationsEnabled = v),
  activeColor: MyColors.accentColor,
)
```

---

### CustomCheckbox

**Purpose**: Circular or square checkbox for selection. Already implemented in `lib/widgets/custom_check_box.dart`.

```dart
CustomCheckbox(
  value: isComplete,
  onChanged: (v) => toggleComplete(),
)
```

---

## 8. Header Widget

### AppHeader

**Purpose**: `AppBar` with back button, centred title, and optional trailing action.

**Parameters**: `title`, `onBack` (optional — if omitted, no back button shown), `action` (optional trailing widget), `transparent`

```dart
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.action,
    this.transparent = false,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? action;
  final bool transparent;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transparent
          ? MyColors.backgroundColor.withValues(alpha: 0.95)
          : MyColors.backgroundColor,
      elevation: 0.5,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(PhosphorIconsRegular.caretLeft),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      automaticallyImplyLeading: onBack != null,
      title: AppText(title, variant: AppTextVariant.subsectionHeader),
      centerTitle: true,
      actions: action != null ? [action!, const SizedBox(width: 8)] : null,
    );
  }
}
```

**Usage**:

```dart
AppHeader(
  title: 'Ben Nevis',
  onBack: () => Navigator.of(context).pop(),
  action: TextButton(onPressed: handleEdit, child: const Text('Edit')),
)
```

---

## 9. Navigation

### BottomNavigationBar

**Purpose**: Tab bar with accent-coloured active state. Flutter's built-in `BottomNavigationBar` is used directly.

```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (i) => setState(() => _selectedIndex = i),
  selectedItemColor: MyColors.accentColor,
  unselectedItemColor: MyColors.mutedText,
  backgroundColor: MyColors.backgroundColor,
  type: BottomNavigationBarType.fixed,
  items: const [
    BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.mountains),      label: 'Discover'),
    BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.users),           label: 'Feed'),
    BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.bookmarkSimple),  label: 'Saved'),
    BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.user),            label: 'Profile'),
  ],
)
```

For badge counts, wrap the icon in a `Badge` widget:

```dart
BottomNavigationBarItem(
  icon: Badge(label: Text('3'), child: Icon(PhosphorIconsRegular.users)),
  label: 'Feed',
)
```

---

## 10. Compound Widgets

### UserHeader

**Purpose**: Row with avatar, username, and timestamp. Tappable if `onTap` is provided.

**Parameters**: `initials`, `userName`, `timestamp`, `imageUrl`, `onTap`

```dart
class UserHeader extends StatelessWidget {
  const UserHeader({
    super.key,
    required this.initials,
    required this.userName,
    required this.timestamp,
    this.imageUrl,
    this.onTap,
  });

  final String initials;
  final String userName;
  final String timestamp;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(initials: initials, imageUrl: imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(userName, variant: AppTextVariant.label),
                AppText(timestamp, variant: AppTextVariant.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Usage**:

```dart
UserHeader(
  initials: 'JD',
  userName: 'John Doe',
  timestamp: '2 hours ago',
  onTap: () => Navigator.of(context).pushNamed(ProfileScreen.route),
)
```

---

### PostCard

**Purpose**: Full post card with header, square image, and engagement actions (like, comment, share).

**Parameters**: user info fields, `munroName`, `postImageUrl`, `caption`, `likes`, `isLiked`, `comments`, action callbacks

```dart
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.initials,
    required this.userName,
    required this.timestamp,
    this.avatarImageUrl,
    this.munroName,
    required this.postImageUrl,
    this.caption,
    required this.likes,
    required this.isLiked,
    required this.comments,
    this.onUserTap,
    this.onImageTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  // ... fields as above

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserHeader(
                  initials: initials,
                  userName: userName,
                  timestamp: timestamp,
                  imageUrl: avatarImageUrl,
                  onTap: onUserTap,
                ),
                if (munroName != null) ...[
                  const SizedBox(height: 8),
                  AppText('Climbed $munroName', variant: AppTextVariant.secondary),
                ],
              ],
            ),
          ),
          // Square image
          GestureDetector(
            onTap: onImageTap,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(postImageUrl, fit: BoxFit.cover),
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircularIconButton(
                    icon: isLiked ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
                    isActive: isLiked, onPressed: onLike,
                  ),
                  CircularIconButton(icon: PhosphorIconsRegular.chatCircle, onPressed: onComment),
                  CircularIconButton(icon: PhosphorIconsRegular.shareNetwork, onPressed: onShare),
                ]),
                if (likes > 0) AppText('$likes ${likes == 1 ? "like" : "likes"}', variant: AppTextVariant.label),
                if (caption != null) ...[
                  const SizedBox(height: 4),
                  RichText(text: TextSpan(children: [
                    TextSpan(text: '$userName ', style: const TextStyle(fontWeight: FontWeight.w500, color: MyColors.textColor)),
                    TextSpan(text: caption, style: const TextStyle(color: MyColors.textColor)),
                  ])),
                ],
                if (comments > 0)
                  GestureDetector(
                    onTap: onComment,
                    child: AppText('View all $comments comments', variant: AppTextVariant.secondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Usage**:

```dart
PostCard(
  initials: 'JD',
  userName: 'John Doe',
  timestamp: '2 hours ago',
  munroName: 'Ben Nevis',
  postImageUrl: post.imageUrl,
  caption: 'Amazing views from the top!',
  likes: 42,
  isLiked: false,
  comments: 5,
  onUserTap: () => Navigator.of(context).pushNamed(ProfileScreen.route),
  onImageTap: () => Navigator.of(context).pushNamed(PostScreen.route, arguments: post.id),
  onLike: handleLike,
  onComment: () => Navigator.of(context).pushNamed(PostScreen.route, arguments: post.id),
  onShare: handleShare,
)
```

---

## 11. Badge Widgets

### AppBadge

**Purpose**: Small pill label with semantic colour variants.

**Variants**: `success`, `error`, `warning`, `info`, `neutral`

```dart
enum AppBadgeVariant { success, error, warning, info, neutral }

class AppBadge extends StatelessWidget {
  const AppBadge(this.label, {super.key, this.variant = AppBadgeVariant.neutral});

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      AppBadgeVariant.success => (const Color(0x1A10B981), const Color(0xFF10B981)),
      AppBadgeVariant.error   => (const Color(0x1AEF4444), const Color(0xFFEF4444)),
      AppBadgeVariant.warning => (const Color(0x1AF97316), const Color(0xFFF97316)),
      AppBadgeVariant.info    => (const Color(0x1A3B82F6), const Color(0xFF3B82F6)),
      AppBadgeVariant.neutral => (MyColors.lightGrey,       MyColors.mutedText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}
```

**Usage**:

```dart
AppBadge('Completed', variant: AppBadgeVariant.success)
AppBadge('In Progress')
```

---

### UnreadDot

**Purpose**: Small dot indicator for unread / notification states.

```dart
class UnreadDot extends StatelessWidget {
  const UnreadDot({super.key, this.show = true, this.color});

  final bool show;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color ?? MyColors.accentColor),
    );
  }
}
```

---

## 12. Progress Widget

### AppProgressBar

**Purpose**: Linear progress indicator.

**Parameters**: `value` (0.0–1.0), `height` (default 8), `showLabel`

```dart
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.showLabel = false,
  });

  final double value;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: MyColors.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(MyColors.accentColor),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          AppText('${(value * 100).round()}%', variant: AppTextVariant.caption),
        ],
      ],
    );
  }
}
```

**Usage**:

```dart
AppProgressBar(value: 0.67, showLabel: true)
```

---

## 13. State Widgets

### LoadingSpinner

**Purpose**: Centred loading indicator. Already implemented in `lib/widgets/loading_widget.dart`.

```dart
// Simple centred spinner
const Center(child: CircularProgressIndicator(color: MyColors.accentColor))

// Or use the existing animated widget
const LoadingWidget()
```

---

### EmptyState

**Purpose**: Centred empty state with icon, title, optional description, and optional action button.

**Parameters**: `icon`, `title`, `description`, `action`

```dart
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: context.colors.middleGrey),
          const SizedBox(height: 16),
          AppText(title, variant: AppTextVariant.subsectionHeader),
          if (description != null) ...[
            const SizedBox(height: 8),
            AppText(description!, variant: AppTextVariant.secondary),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
```

**Usage**:

```dart
EmptyState(
  icon: PhosphorIconsRegular.mountains,
  title: 'No munros yet',
  description: 'Start exploring to find your next adventure',
  action: AppButton(label: 'Discover Munros', onPressed: () => ...),
)
```

---

## 14. Utility Widgets

### AppDivider

**Purpose**: Horizontal rule. Wraps Flutter's `Divider`.

```dart
// Standard
const Divider(height: 1, color: MyColors.lightGrey)

// With vertical spacing
const Padding(
  padding: EdgeInsets.symmetric(vertical: 16),
  child: Divider(height: 1, color: MyColors.lightGrey),
)
```

---

## Usage Examples

### Complete Feed Screen

```dart
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: const AppHeader(title: 'Feed'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: posts.map((p) => PostCard(
            initials: p.initials,
            userName: p.userName,
            timestamp: p.timestamp,
            postImageUrl: p.imageUrl,
            likes: p.likes,
            isLiked: p.isLiked,
            comments: p.commentCount,
            onLike: () => likePost(p.id),
            onComment: () => Navigator.of(context).pushNamed(PostScreen.route, arguments: p.id),
            onShare: () => sharePost(p),
          )).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: MyColors.accentColor,
        unselectedItemColor: MyColors.mutedText,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.mountains),     label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.users),          label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.bookmarkSimple), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.user),           label: 'Profile'),
        ],
      ),
    );
  }
}
```

### Settings Screen (Form Example)

```dart
class _SettingsScreenState extends State<SettingsScreen> {
  final _emailController = TextEditingController();
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppHeader(title: 'Settings', onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Email', variant: AppTextVariant.label),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _emailController,
                    placeholder: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: MyColors.lightGrey),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText('Notifications', variant: AppTextVariant.label),
                          AppText('Receive push notifications', variant: AppTextVariant.secondary),
                        ],
                      ),
                      Switch(
                        value: _notifications,
                        onChanged: (v) => setState(() => _notifications = v),
                        activeColor: MyColors.accentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(label: 'Save Changes', onPressed: handleSave, fullWidth: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
