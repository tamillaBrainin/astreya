# UI Direction

Please restyle the Flutter UI to match this exact visual direction.

## Target Style

- premium astrology mobile UI
- soft pastel lilac background
- bright dreamy cosmic atmosphere
- glassmorphism cards
- slightly darker inner screen surfaces for contrast
- glowing white-lilac borders
- rich but clean lilac tones
- not pale, not washed out
- not muddy purple
- not grey-violet

## Important

The overall app background should stay light and dreamy.

But the main content cards / phone surfaces / hero sections should be deeper lilac for contrast, like in a polished concept mockup.

## Color System

### App background gradient

- `Color(0xFFF4ECFF)`
- `Color(0xFFE8DAFF)`
- `Color(0xFFD9C4FF)`

### Hero / dark glass surface gradient

- `Color(0xFF7C68C8)`
- `Color(0xFF6B57B8)`
- `Color(0xFF5A469F)`

### Card fill (glass)

- `Colors.white.withOpacity(0.16)` for dark glass cards
- `Colors.white.withOpacity(0.22)` for light glass cards

### Card borders

- `Colors.white.withOpacity(0.34)`

### Main text on dark surfaces

- `Colors.white`
- `Color(0xFFF3ECFF)`

### Main text on light surfaces

- `Color(0xFF35285B)`

### Secondary text

- `Color(0xFF7E6FA8)`

### Muted labels

- `Color(0xFF9A8ABC)`

### Primary accent

- `Color(0xFFA88CF6)`

### Stronger accent

- `Color(0xFF8F73E8)`

### Soft icon bubble gradient

```dart
LinearGradient(
  colors: [
    Color(0xFFF1E6FF),
    Color(0xFFD9C5FF),
  ],
)
```

### Active button / selected tab gradient

```dart
LinearGradient(
  colors: [
    Color(0xFFE8D7FF),
    Color(0xFFB493F7),
  ],
)
```

### Glow colors

- `Color(0x55F3E8FF)`
- `Color(0x44DCC8FF)`
- `Color(0x33CDB7FF)`

## Rules

1. Keep outer page background light and airy.
2. Make hero blocks and important surfaces deeper lilac, not pale.
3. Keep borders glowing white-lilac.
4. Do not use dusty purple, grey violet, or muted plum.
5. Do not flatten the UI.
6. Maintain contrast between:
   - light dreamy background
   - darker lilac cards/screens
7. Keep the UI elegant, celestial, glossy, and premium.

## Update Scope

Please update:

- scaffold background
- page gradients
- hero section gradients
- card fills
- borders
- icon colors
- selected tabs
- chips
- nav buttons
- text colors

## Layout Constraint

Do not redesign layout.

Only restyle colors and gradients to match a polished premium lilac astrology app concept.