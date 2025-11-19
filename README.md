# 🛒 SmartMart - Flutter Marketplace App

> A comprehensive, production-ready marketplace application connecting local vendors with customers through an intuitive dual-role platform.

**SmartMart** is a full-featured e-commerce solution built with Flutter, offering seamless experiences for both buyers and sellers. With advanced product management, real-time notifications, smart discount systems, and beautiful UI, SmartMart sets a new standard for local marketplace applications.

## ✨ Highlights

- 🎯 **Dual-Role System**: Seamlessly switch between customer and vendor accounts
- 📸 **Advanced Image Carousel**: Swipeable galleries with progress indicators
- ⚡ **Instant Updates**: Optimistic UI with immediate visual feedback
- 🔔 **Smart Notifications**: Cloud-synced with persistent read status
- 💰 **Flexible Discounts**: Percentage or fixed-price with date scheduling
- ✏️ **Quick Edit Access**: Long-press menu for instant product editing
- 🎨 **Modern UI**: Material 3 design with custom animated components
- 🌈 **Unified Blue Theme**: Vendor-side azure palette now applied across the entire app
- 🔎 **Collapsing Search**: Scroll-driven search bar that morphs into header icon
- 📊 **Rich Analytics**: Comprehensive sales tracking and insights
- 🌐 **Cloud-First**: Firebase & Supabase for scalable backend
- ✨ **Shimmer Loading**: YouTube-style skeleton loading effects for smooth UX
- 🌊 **Liquid Navbar**: Frosted glass navigation with animated liquid effects
- 🔔 **Frosted Notifications**: Beautiful top-sliding notification banners with glassmorphism

## 🚀 Features

### 👥 Customer Features
- **🛍️ Browse Products**: Discover products from local vendors with rich product details and image carousels
- **🛒 Shopping Cart**: Add items to cart with quantity management and persistent storage
- **📦 Order Management**: Track order history, status, and delivery updates in real-time
- **👤 User Profile**: Manage personal information, preferences, and delivery addresses
- **🔍 Search & Filter**: Find products by category, price range, and search terms
- **🔎 Collapsing Search Bar**: Search field smoothly collapses into a header icon on scroll
- **🏷️ Exclusive Offers**: Shows only discounted products on the home screen
- **🧭 Header Location**: Current location in AppBar; search icon sits to its right when collapsed
- **🔄 Role Switching**: Switch to vendor mode if you have a vendor account
- **📍 Address Management**: Manage multiple delivery addresses with GPS integration
- **🗺️ Location Services**: Find nearby vendors and products with geolocation
- **🔔 Smart Notifications**: Get notified about orders, updates, and activities
- **📸 Image Carousel**: Swipe through multiple product images with progress indicators
- **💾 Cart Persistence**: Your cart is saved even when you close the app
- **✨ Shimmer Loading**: Beautiful skeleton loading effects while content loads
- **🔔 Frosted Notifications**: Elegant top-sliding notification banners with frosted glass effect

### 🏪 Vendor Features
- **📊 Real-time Dashboard**: View comprehensive sales analytics and business metrics
- **📦 Advanced Product Management**: 
  - 6-step product creation wizard with validation
  - Edit products with pre-filled data
  - Long-press menu for quick edit/delete access
  - Image gallery management with add/remove functionality
  - Review mode to preview products before saving
- **💰 Discount Management**: 
  - Apply percentage or fixed price discounts
  - Set discount start/end dates
  - Real-time discount badge display
  - Automatic notifications for discount changes
- **📋 Order Processing**: Handle incoming orders with real-time updates
- **💳 POS System**: Point of sale functionality for in-store transactions
- **📈 Advanced Analytics Dashboard**: 
  - Comprehensive analytics dashboard with real-time data
  - Today's sales, total sales, and inventory overview cards
  - Top-selling products with revenue tracking and progress bars
  - Sales trend visualization with interactive charts
  - Performance metrics with percentage indicators
  - Refresh functionality for updated data
- **🔔 Notification System**: 
  - Product activity notifications (add, edit, delete, discount)
  - Login alerts for account security
  - Persistent read/unread status synced with cloud
  - Notification popup with quick actions
  - Swipe to delete notifications
- **🔄 Role Switching**: Switch to customer mode to shop from other vendors
- **⚙️ Store Settings**: Manage store details, business information, and policies
- **📱 Real-time Inventory**: Monitor stock levels with automatic updates
- **✏️ In-line Editing**: Quick edit access via long-press on products
- **🔔 Frosted Notifications**: Beautiful notification banners for product actions (add, update, delete)

### 🔧 Common Features
- **🔐 Secure Authentication**: Firebase Auth with email/password and Microsoft OAuth
- **👥 Role-based Access**: Optimized interfaces for customers and vendors
- **🔄 Smart Role Switching**: Seamlessly switch between roles with data persistence
- **☁️ Cloud Sync**: Real-time data synchronization with Firestore
- **🖼️ Hybrid Image Storage**: Firebase Storage for products, Supabase for profiles
- **📍 GPS Integration**: Location detection and address geocoding
- **🎨 Modern UI**: Material 3 design with custom animated components
- **🪄 Smooth Animations**: Implicit transforms/opacity for scroll-based morph effects
- **🧭 Floating Navigation Bar**: iOS-style navigation with smooth animations and liquid effects
- **📱 Cross-Platform**: Native performance on Android and iOS
- **💾 Smart Caching**: Optimized data loading with local storage fallback
- **🔄 Pull-to-Refresh**: Manual data refresh on all list screens
- **🎯 Haptic Feedback**: Touch feedback for better user experience
- **✨ Shimmer Effects**: Skeleton loading animations for better perceived performance
- **🌊 Liquid Animations**: Smooth liquid wave effects on navbar capsule and background
- **🔔 Frosted Glass UI**: Glassmorphism design with backdrop blur effects

## 🛠️ Technology Stack

### Core Framework
- **Flutter**: 3.0+ with Dart 3.0+
- **Material Design 3**: Modern UI components and theming

### State Management & Navigation
- **Provider**: Primary state management for data and auth
- **GetX**: Navigation and route management
- **GoRouter**: Declarative routing (legacy support)

### Backend & Cloud Services
- **Firebase**:
  - Authentication: Email/password, OAuth providers
  - Firestore: Real-time NoSQL database
  - Storage: Product image storage (legacy)
- **Supabase**:
  - Storage: Profile and product image hosting
  - API: RESTful backend services

### Data Persistence
- **SharedPreferences**: Local app settings and cart persistence
- **Firestore**: Cloud data sync for products, orders, notifications
- **Hybrid Storage**: Smart caching with cloud fallback

### UI & Visualization
- **Lucide Icons**: 250+ consistent icons throughout the app
- **FL Chart**: Beautiful charts for analytics visualization
- **Cached Network Image**: Optimized image loading and caching
- **Custom Widgets**: Reusable components (FloatingNavBar, ProductCard, etc.)

### Location & Maps
- **Geolocator**: GPS-based location detection
- **Geocoding**: Address conversion and location search
- **Flutter Map**: Interactive map integration

### Image Handling
- **Image Picker**: Camera and gallery image selection
- **CachedNetworkImage**: Network image optimization
- **Multi-image Support**: Gallery management with carousel view

### Additional Features
- **HTTP Client**: RESTful API communication
- **Flutter AppAuth**: OAuth 2.0 authentication
- **Intl**: Date formatting and localization support
- **Country Picker**: International country selection

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point with GetX routing
├── firebase_options.dart               # Firebase configuration
├── supabase_config.dart                # Supabase configuration
│
├── models/                             # Data models
│   ├── user.dart                      # User, Vendor, Customer models with roles
│   ├── product.dart                   # Product model with discounts & inventory
│   ├── order.dart                     # Order, CartItem, POSTransaction models
│   ├── address.dart                   # Address and LocationData models
│   └── analytics.dart                 # SalesData, Notification, VendorStats models
│
├── providers/                          # State management
│   ├── auth_provider.dart             # Authentication, role switching, OAuth
│   └── data_provider.dart             # Products, orders, cart, notifications
│
├── screens/                            # UI screens
│   ├── splash_screen.dart             # App splash screen
│   ├── onboarding_screen.dart         # First-time user onboarding
│   ├── product_detail_screen.dart     # Product details with image carousel
│   │
│   ├── auth/                          # Authentication flow
│   │   ├── login_screen.dart         # Login with email/password
│   │   ├── register_screen.dart       # Initial registration
│   │   ├── role_selection_screen.dart # Choose customer or vendor
│   │   ├── customer_location_screen.dart
│   │   ├── customer_account_screen.dart
│   │   ├── customer_phone_screen.dart
│   │   ├── vendor_register_screen.dart
│   │   ├── vendor_location_screen.dart
│   │   └── vendor_delivery_screen.dart
│   │
│   ├── customer/                      # Customer interface
│   │   ├── customer_home_screen.dart  # Home with products & notifications
│   │   ├── browse_screen.dart         # Product browsing with filters
│   │   ├── cart_screen.dart           # Shopping cart management
│   │   ├── orders_screen.dart         # Order history & tracking
│   │   ├── profile_screen.dart        # User profile & settings
│   │   ├── edit_profile_screen.dart   # Profile editing
│   │   ├── notifications_screen.dart  # Notification center
│   │   ├── addresses_screen.dart      # Address management
│   │   └── add_edit_address_screen.dart
│   │
│   └── vendor/                        # Vendor interface
│       ├── vendor_home_screen.dart    # Dashboard with analytics
│       ├── products_screen.dart       # Product list with edit/delete
│       ├── add_product_screen.dart    # Legacy add product
│       ├── add_product_stepper_screen.dart  # 6-step wizard (add/edit)
│       ├── add_product_step1_screen.dart    # Images, name, description
│       ├── add_product_step2_screen.dart    # Category, price, stock
│       ├── add_product_step3_screen.dart    # Brand, origin, barcode
│       ├── add_product_step4_screen.dart    # Details, features, storage
│       ├── add_product_step5_screen.dart    # Nutrition information
│       ├── add_product_step6_screen.dart    # Tags & metadata
│       ├── orders_screen.dart         # Vendor order management
│       ├── pos_screen.dart            # Point of sale system
│       ├── profile_screen.dart        # Vendor profile
│       ├── vendor_analytics_screen.dart # Analytics dashboard
│       └── store_settings_screen.dart # Store configuration
│
├── widgets/                            # Reusable components
│   ├── custom_button.dart             # Styled button widget
│   ├── custom_input.dart              # Styled text input
│   ├── custom_card.dart               # Card component
│   ├── custom_icon.dart               # Icon wrapper for assets
│   ├── product_card.dart              # Product display card
│   ├── floating_nav_bar.dart          # iOS-style animated navigation with liquid effects
│   ├── discount_dialog.dart           # Discount management dialog
│   ├── sales_chart.dart               # Analytics visualization
│   ├── shimmer.dart                   # Shimmer loading animation widget
│   ├── skeleton_loaders.dart          # Skeleton loading components
│   └── frosted_notification_banner.dart # Frosted glass notification banner
│
├── services/                           # External integrations
│   ├── firestore_service.dart         # Firestore CRUD operations
│   ├── microsoft_oauth.dart           # Microsoft authentication
│   ├── onedrive_storage_service.dart  # OneDrive integration
│   ├── supabase_storage_service.dart  # Supabase image storage
│   └── notification_service.dart     # Frosted notification banner service
│
├── router/                             # Navigation
│   └── app_router.dart                # GoRouter configuration (legacy)
│
├── theme/                              # Styling
│   └── app_theme.dart                 # Material 3 theme & colors
│
├── data/                               # Static data
│   └── cities_data.dart               # City listings for Pakistan
│
└── utils/                              # Helper functions
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.0 or higher
- **Dart SDK**: 3.0 or higher  
- **IDE**: Android Studio / VS Code / IntelliJ IDEA
- **Device**: Android/iOS device or emulator
- **Firebase Account**: For authentication and database
- **Supabase Account**: For image storage

### 📦 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart_mart
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication and Firestore
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place files in respective platform directories

4. **Supabase Setup**
   - Create a Supabase project
   - Configure storage bucket for images
   - Update `supabase_config.dart` with your credentials

5. **Configure environment**
   - Update `lib/supabase_config.dart` with your Supabase URL and anon key
   - Ensure `firebase_options.dart` is generated via FlutterFire CLI
   
6. **Run the app**
   ```bash
   flutter run
   ```

### 🔧 Configuration Files

#### Firebase Setup (`firebase_options.dart`)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate Firebase options
flutterfire configure
```

#### Supabase Setup (`lib/supabase_config.dart`)
```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

#### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 🐛 Troubleshooting

#### Common Issues

**Issue**: Products not loading
- **Solution**: Check Firebase configuration and internet connection
- Verify Firestore rules allow read access
- Check console for error messages

**Issue**: Images not uploading
- **Solution**: Verify Supabase storage bucket permissions
- Check storage quota limits
- Ensure image picker permissions in AndroidManifest.xml/Info.plist

**Issue**: Notifications not persisting
- **Solution**: Ensure Firestore notification collection is created
- Check notification update/read methods are being called
- Verify cloud sync is working (check console logs)

**Issue**: Edit mode not showing images
- **Solution**: Existing images are URLs, displayed via CachedNetworkImage
- New images are Files, displayed via Image.file
- Both types are supported in the carousel

**Issue**: Navigation not working after update
- **Solution**: Use `Get.offNamed()` instead of `Get.back()`
- Ensure route is registered in main.dart GetPages
- Check for loading state blocking navigation

## 📖 Usage Guide

### First Time Setup

1. **Launch the app** - Splash screen with initialization
2. **Complete onboarding** - Learn about SmartMart features
3. **Choose your role** - Select Customer or Vendor
4. **Registration flow**:
   - **Customer**: Location → Account details → Phone verification
   - **Vendor**: Shop details → Location → Delivery settings
5. **Start exploring** - Access role-specific features

### For Customers

1. **Browse products** from the home screen with category filters
2. **View product details** - Swipe through image carousel with progress bar
3. **Add to cart** - Manage quantities with persistent cart storage
4. **View notifications** - Tap notification icon to see updates
5. **Track orders** in the orders section with real-time status
6. **Manage addresses** - Add/edit multiple delivery locations
7. **Switch to vendor** - Become a seller if you have vendor account

### 🎯 Customer Workflows

#### Shopping Flow
```
Browse Products → View Details (swipe images) → Add to Cart → Checkout → Track Order
```

#### Notification Flow
```
Click Notification Icon → View Popup → Click Notification → Navigate to Details
└─ Auto-marks all as read when popup opens
```

### For Vendors

1. **Dashboard** - Real-time analytics with sales metrics and activity feed
2. **Add Products** - 6-step creation wizard:
   - **Step 1**: Upload up to 5 images + product name & description
   - **Step 2**: Category, price, unit, stock quantity (required)
   - **Step 3**: Brand, origin, expiry, barcode, manufacturer (optional)
   - **Step 4**: Detailed description, features, storage, allergens (optional)
   - **Step 5**: Nutrition information (optional)
   - **Step 6**: Tags and metadata (optional)
   - **Review**: Preview product with full detail view before saving
3. **Edit Products**: Long-press any product → Choose Edit or Delete
   - All fields pre-filled with existing data
   - Manage existing images (remove/keep) and add new ones
   - Changes reflect immediately in product list
4. **Manage Discounts**:
   - Apply percentage (e.g., 20% off) or fixed price discounts
   - Set start/end dates for limited-time offers
   - Discount badge automatically displays on products
   - Get notifications when discounts are applied/removed
5. **Process Orders** - View and manage customer orders
6. **POS System** - Handle in-store transactions with receipt generation
7. **Analytics Dashboard** - Comprehensive analytics with:
   - Today's sales, total sales, and inventory overview
   - Top-selling products with revenue tracking
   - Interactive sales trend charts
   - Performance metrics and indicators
   - Real-time data refresh functionality
8. **Notifications** - Product activities, login alerts, and order updates
9. **Switch to Customer** - Shop from other vendors
10. **Store Settings** - Manage business information and policies

### 🎯 Vendor Workflows

#### Product Management Flow
```
Add Product:
Products Screen → + Button → 6-Step Wizard → Review → Update → Products List

Edit Product:
Long-press Product → Edit → Wizard (pre-filled) → Review → Update → Updated List

Quick Discount:
Products Screen → Tap Discount Icon → Set Discount → Apply → Instant Update
```

#### Notification Flow
```
Product Action (add/edit/delete/discount) → Auto-create Notification → Sync to Cloud
Click Notification Icon → Auto-mark all as read → View Notifications
```

### Role Switching

SmartMart supports seamless role switching:

- **From Customer to Vendor**: 
  - If you have a vendor account → Automatically switches to vendor mode
  - If you don't have a vendor account → Redirects to vendor registration

- **From Vendor to Customer**:
  - If you have a customer account → Automatically switches to customer mode  
  - If you don't have a customer account → Redirects to customer registration

- **Access**: Use the "Switch to Selling" or "Switch to Buying" cards in your profile

## 💾 Data Architecture

The app uses a sophisticated hybrid storage approach for optimal performance:

### Cloud Storage (Firebase Firestore)
- **Users Collection**: User profiles, authentication data, roles
- **Products Collection**: Product catalog with full details and metadata
- **Notifications Collection**: Notification history with read/unread status
- **Orders Collection**: Order history and transaction data (planned)
- **Real-time Sync**: Automatic synchronization across devices

### Local Storage (SharedPreferences)
- **Cart Persistence**: Shopping cart saved locally for offline access
- **User Preferences**: App settings and user choices
- **Cached Data**: Product and order data for faster loading
- **Notifications Cache**: Quick access to notification history

### Image Storage (Hybrid)
- **Supabase Storage**: Profile images with public URLs
- **Firebase Storage**: Product images (legacy support)
- **Local Files**: Temporary image storage during upload

### Data Flow
```
User Action → Local Update (instant UI) → Cloud Sync (background) → Notify Listeners
                   ↓
              UI Updates Immediately
```

### Key Features:
- ✅ **Instant Updates**: Changes appear immediately without waiting for cloud
- ✅ **Automatic Sync**: Background synchronization with Firestore
- ✅ **Offline Support**: Cart and cached data work offline
- ✅ **Smart Loading**: Load from cache first, sync with cloud in background

## ⚙️ Architecture & Patterns

### State Management Strategy
- **Provider Pattern**: Used for global state (auth, data)
- **ChangeNotifier**: Custom providers extend ChangeNotifier
- **Consumer Widgets**: Efficient rebuilds for specific data changes
- **Safe Notify**: `_safeNotifyListeners()` prevents build-phase errors

### Navigation Architecture
- **GetX Routes**: Named routes defined in `main.dart`
- **Route Parameters**: Product IDs and data passed via Get.arguments
- **Navigation Stack**: Proper back navigation and route replacement
- **Deep Linking**: Support for `/product/:id` pattern

### Data Flow Pattern
```
UI Layer (Screens/Widgets)
    ↓
State Layer (Providers)
    ↓
Service Layer (Firestore/Supabase)
    ↓
Firebase/Supabase Cloud
```

### Update Strategy (Optimistic UI)
```
1. User Action
2. Update Local State → UI updates instantly
3. Update Cloud (async) → Sync in background
4. On Success: Data persisted
5. On Error: Rollback local state (future)
```

### Key Technical Decisions
- **Why Provider?** Simple, efficient, and built-in with Flutter
- **Why GetX?** Easy navigation and route management
- **Why Firestore?** Real-time sync and scalable NoSQL database
- **Why Supabase?** Cost-effective image storage with public URLs
- **Why Hybrid Storage?** Balance between speed and data persistence

## 🛠️ Customization

### Theming

Modify `lib/theme/app_theme.dart` to customize:
- **Color Scheme**: Primary, secondary, surface colors
- **Typography**: Font families, sizes, weights
- **Component Styles**: Button, card, input field styles
- **Material 3**: Elevation, shapes, state layers

### Adding New Features

1. **Create Model**: Add to `lib/models/` with `fromJson/toJson`
2. **Update Provider**: Add state management in providers
3. **Create Screen**: Add to appropriate directory in `lib/screens/`
4. **Build UI**: Use custom widgets from `lib/widgets/`
5. **Add Route**: Register in `main.dart` GetPages
6. **Test**: Verify functionality on both platforms

### Extending Product Model

To add new product fields:
```dart
// 1. Update model (lib/models/product.dart)
class Product {
  final String newField;
  // ... add to constructor, fromJson, toJson, copyWith
}

// 2. Update Firestore service
// 3. Update UI in step screens
// 4. Test thoroughly
```

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management & Navigation
  provider: ^6.1.2              # Primary state management
  get: ^4.6.6                   # Navigation and dialogs
  go_router: ^16.2.1            # Declarative routing (legacy)
  
  # Firebase Backend
  firebase_core: ^4.1.0         # Firebase initialization
  firebase_auth: ^6.0.2         # Authentication with OAuth
  cloud_firestore: ^6.0.1       # NoSQL database
  firebase_storage: ^13.0.1     # File storage
  
  # Storage & Caching
  shared_preferences: ^2.2.3    # Local key-value storage
  supabase_flutter: ^2.6.0      # Supabase client for images
  cached_network_image: ^3.4.1  # Image caching and optimization
  
  # UI & Design
  lucide_icons: ^0.257.0        # 250+ modern icons
  cupertino_icons: ^1.0.8       # iOS-style icons
  flutter_svg: ^2.0.10+1        # SVG support
  fl_chart: ^1.1.0              # Charts and graphs
  
  # Forms & Input
  image_picker: ^1.1.2          # Camera and gallery picker
  country_picker: ^2.0.25       # Country selection
  
  # Location Services
  geolocator: ^14.0.2           # GPS location detection
  geocoding: ^4.0.0             # Address geocoding
  flutter_map: ^6.1.0           # Interactive maps
  latlong2: ^0.9.0              # Latitude/longitude utilities
  
  # Networking & Auth
  http: ^1.2.2                  # HTTP client
  flutter_appauth: ^6.0.5       # OAuth 2.0 flows
  
  # Utilities
  intl: ^0.20.2                 # Date formatting and i18n

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0         # Linting rules
```

### Why These Packages?

- **Provider**: Recommended by Flutter team, simple and efficient
- **GetX**: Powerful navigation with minimal boilerplate
- **Firebase**: Industry-standard backend with real-time capabilities
- **Supabase**: Open-source Firebase alternative, cost-effective storage
- **Lucide Icons**: Consistent, modern icon library
- **CachedNetworkImage**: Performance optimization for image-heavy apps

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the code comments

## 📱 Screenshots

*Screenshots will be added here showing the app's key features and user interface.*

## 🔄 Recent Updates

### v1.4.0 - UI Enhancements & Frosted Glass Design (Latest)
- ✅ **Shimmer Loading Effects**: YouTube-style skeleton loading on home and browse screens
- ✅ **Frosted Glass Navbar**: Beautiful glassmorphism navigation with backdrop blur
- ✅ **Liquid Animations**: 
  - Liquid wave effects on navbar capsule borders
  - Morphing animations during tab transitions
  - Background liquid waves that flow across navbar
- ✅ **Frosted Notification Banners**: 
  - Top-sliding notification banners with frosted glass effect
  - Auto-dismiss after 3 seconds
  - Smooth slide-in/slide-out animations
  - Replaces all snackbars with elegant banners
- ✅ **Enhanced UI Polish**: 
  - Light gray backgrounds for notification screens
  - White notification tiles with borders and elevation
  - Improved icon sizing and styling
  - Better visual hierarchy throughout the app

### v1.3.2 - Blue Theme Refresh
- ✅ **Global Theme Sync**: Vendor product screen's blue palette now powers buttons, links, and highlights across the app
- ✅ **Consistent Accent Color**: Primary/secondary colors standardized for both customer and vendor flows

### v1.3.1 - Home UX Polish
- ✅ **Collapsing Search Bar**: Search field now morphs into a circular icon inside the AppBar while scrolling; solid AppBar background maintained
- ✅ **Header Location Update**: Location text appears in the AppBar; fades on collapse; search icon aligns to its right
- ✅ **Exclusive Offers Filter**: Section now lists only discounted products; hides if none available
- ✅ **Explore More**: Renamed the Groceries section heading to "Explore More"

### v1.3.0 - Analytics Dashboard & Enhanced Features
- ✅ **Analytics Dashboard**: Comprehensive vendor analytics with real-time sales data
- ✅ **Summary Cards**: Today's sales, total sales, and inventory overview with performance indicators
- ✅ **Top Selling Products**: Revenue tracking with progress bars and product images
- ✅ **Sales Trend Charts**: Interactive visualization of sales performance over time
- ✅ **Data Refresh**: Manual refresh functionality for updated analytics data
- ✅ **Loading States**: Smooth loading animations and empty state handling
- ✅ **Theme Integration**: Consistent styling with app's Material 3 design system

### v1.2.0 - Enhanced Product Management & Notifications
- ✅ **Image Carousel**: Swipeable product image gallery with progress indicators
- ✅ **Product Review Mode**: Preview products before saving with full detail view
- ✅ **Quick Edit Menu**: Long-press products for instant edit/delete access
- ✅ **Discount Notifications**: Automatic notifications for discount changes
- ✅ **Persistent Notifications**: Read status synced with Firestore cloud
- ✅ **Smart Notification Badge**: Auto-clears when viewing notifications
- ✅ **Immediate UI Updates**: Product changes reflect instantly without refresh
- ✅ **Enhanced Edit Flow**: Full product editing with pre-filled data in 6-step wizard

### v1.1.0 - Notification System & UI Improvements
- ✅ **Notification Center**: Complete notification system with popup and full screen
- ✅ **Floating Nav Bar**: iOS-style animated navigation with drag support
- ✅ **Notification Popup**: Quick view with blur background and dismissible tiles
- ✅ **Mark as Read**: Persistent read status across app restarts
- ✅ **Activity Feed**: Recent activity section on vendor dashboard
- ✅ **Product Activity Tracking**: Notifications for add, edit, delete, discount actions

### v1.0.0 - Initial Release
- ✅ **Complete Marketplace**: Full-featured marketplace for customers and vendors
- ✅ **Smart Role Switching**: Seamlessly switch between customer and vendor accounts
- ✅ **Firebase Integration**: Secure authentication and real-time database
- ✅ **Supabase Storage**: Image storage and management
- ✅ **Location Services**: GPS-based location detection and address management
- ✅ **Analytics Dashboard**: Comprehensive sales analytics for vendors
- ✅ **POS System**: Point of sale functionality for in-store transactions
- ✅ **Modern UI**: Material 3 design with custom components
- ✅ **Cross-Platform**: Native performance on Android and iOS

## 🗺️ Roadmap

### Phase 1 - Core Features (✅ Completed)
- [x] User authentication and registration with multi-step flows
- [x] Product catalog with image galleries
- [x] Shopping cart with persistent storage
- [x] Order processing and management
- [x] Role switching between customer and vendor
- [x] Analytics dashboard with sales metrics
- [x] POS system for in-store transactions

### Phase 2 - Enhanced Features (✅ Completed)
- [x] **Notification System**: Complete notification center with cloud sync
- [x] **Product Editing**: Full edit capability with 6-step wizard
- [x] **Discount Management**: Flexible discount system with notifications
- [x] **Image Carousel**: Swipeable product images with progress indicators
- [x] **Quick Actions**: Long-press menu for edit/delete operations
- [x] **Real-time Updates**: Instant UI updates for all product changes
- [x] **Floating Navigation**: iOS-style animated bottom navigation
- [x] **Smart Notifications**: Badge system with auto-clear on view
- [x] **Analytics Dashboard**: Comprehensive vendor analytics with sales insights

### Phase 3 - Payment & Tracking (In Progress)
- [ ] **Payment Integration**: Stripe/PayPal payment processing
- [ ] **Order Tracking**: Real-time delivery tracking with maps
- [ ] **Inventory Alerts**: Low-stock notifications and auto-reorder
- [ ] **Advanced Search**: AI-powered search with recommendations
- [ ] **Customer Reviews**: Rating and review system for products

### Phase 4 - Advanced Features (Planned)
- [ ] **Multi-language Support**: Internationalization for global markets
- [ ] **Dark Mode**: Theme switching and customization
- [ ] **Offline Mode**: Enhanced offline functionality with sync
- [ ] **Chat System**: Direct messaging between customers and vendors
- [ ] **Wishlist**: Save favorite products for later
- [ ] **Loyalty Program**: Points system and rewards
- [ ] **Promotional Campaigns**: Discount codes and vouchers
- [ ] **Vendor Verification**: Enhanced vendor onboarding and badge system
- [ ] **Push Notifications**: FCM integration for real-time alerts
- [ ] **Social Sharing**: Share products on social media platforms
- [ ] **Advanced Filters**: Multi-criteria product filtering
- [ ] **Subscription Plans**: Premium features for vendors

## 🤝 Contributing

We welcome contributions to SmartMart! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**: Follow the coding standards and add tests
4. **Test thoroughly**: Ensure all tests pass and the app works correctly
5. **Commit your changes**: Use clear, descriptive commit messages
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**: Describe your changes and link any related issues

### Development Guidelines

- Follow Flutter/Dart coding conventions and best practices
- Write comprehensive tests for new features
- Update documentation for API changes
- Ensure cross-platform compatibility (Android & iOS)
- Test on both physical devices and emulators
- Use Provider for state management, GetX for navigation
- Maintain code comments and inline documentation
- Follow Material 3 design principles

## 🎨 Key Features Deep Dive

### Image Carousel System
- **PageView-based**: Smooth horizontal scrolling between images
- **Progress Indicators**: 
  - Top bar showing segments for each image (Instagram-style)
  - Bottom counter badge displaying "2/5" format
- **Navigation Hints**: Chevron indicators showing swipe direction
- **Smart Loading**: 
  - Network images with `CachedNetworkImage`
  - Local files with `Image.file` for review mode
  - Loading placeholders and error handling

### Notification System
- **Cloud-Synced**: Read/unread status persists in Firestore
- **Auto-Mark Read**: Opening notification popup marks all as read
- **Activity Types**:
  - Product Added/Deleted/Discounted
  - Login Alerts (security)
  - Order Updates (planned)
- **UI Features**:
  - Popup overlay with blur background
  - Swipe to delete notifications
  - Badge counter on notification icon
  - Timestamp formatting (Just now, 5m ago, Today, etc.)

### Product Management
- **6-Step Wizard**: Comprehensive product creation with validation
- **Edit Mode**: Pre-fills all fields with existing product data
- **Image Management**:
  - Upload up to 5 images per product
  - Existing images show "Saved" badge in edit mode
  - Remove/keep existing images, add new ones
- **Discount System**:
  - Percentage discounts (1-99%)
  - Fixed price discounts
  - Start/end date scheduling
  - Visual discount badge on product cards
  - Automatic notification creation
- **Review Before Save**: Full product preview with Update button

### Floating Navigation Bar
- **iOS-style Design**: Animated capsule indicator with liquid effects
- **Frosted Glass Background**: Backdrop blur with theme-aware transparency
- **Liquid Animations**: 
  - Wave effects on capsule borders that morph during transitions
  - Liquid background waves that flow across the navbar
  - Smooth morphing animations with elastic bounce
- **Weighted Layout**: Selected item gets more space
- **Drag Support**: Long-press and drag to switch tabs
- **Smooth Animations**: 400-600ms easeOutCubic transitions
- **Icon + Label**: Selected item shows icon and text with fade animations
- **Theme-Aware**: Adapts to light/dark mode automatically

### Shimmer Loading Effects
- **Skeleton Loaders**: YouTube-style loading placeholders
- **Smooth Animations**: Gradient shimmer effect that sweeps across placeholders
- **Multiple Components**:
  - Product card skeletons
  - Mart card skeletons
  - Search bar skeletons
  - Section header skeletons
  - Promo carousel skeletons
- **Smart Loading**: Automatically hides when data is loaded
- **Performance Optimized**: Lightweight animations with minimal CPU usage

### Frosted Notification Banners
- **Glassmorphism Design**: Frosted glass effect with backdrop blur
- **Top Slide Animation**: Slides in from top with smooth fade
- **Auto-Dismiss**: Automatically disappears after 3 seconds
- **Manual Close**: X button for immediate dismissal
- **Theme-Aware**: Adapts colors for light/dark mode
- **Multiple Types**:
  - Success notifications (green)
  - Error notifications (red)
  - Info notifications (blue)
  - Product actions (add, update, delete)
  - Cart notifications
- **Smooth Transitions**: 400ms slide-in, 300ms slide-out animations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:

- 📧 **Email**: Create an issue in the repository
- 📚 **Documentation**: Check the code comments and inline documentation
- 🐛 **Bug Reports**: Use the issue tracker with detailed reproduction steps
- 💡 **Feature Requests**: Submit enhancement requests with use cases
- 💬 **Discussions**: Join community discussions for help and ideas

## 🚀 Performance Optimizations

### Implemented Optimizations
- **Optimistic UI Updates**: Local updates before cloud sync for instant feedback
- **Image Caching**: `CachedNetworkImage` for efficient image loading
- **Lazy Loading**: Products load on-demand, not all at once
- **Smart Refresh**: Only refresh when data actually changes
- **Safe Notify Listeners**: Prevents unnecessary rebuilds during build phase
- **Background Sync**: Cloud operations don't block UI interactions

### Best Practices
- Provider usage with `listen: false` for non-UI operations
- Proper dispose methods for controllers and listeners
- Efficient list rendering with `ListView.builder`
- Image optimization with proper resizing
- Debounced search and filter operations

## 📊 App Statistics

- **20+ Screens**: Comprehensive UI coverage
- **9 Custom Widgets**: Reusable, maintainable components
- **2 State Providers**: Centralized state management
- **4 Service Layers**: Clean separation of concerns
- **5 Data Models**: Well-structured data architecture
- **30+ Routes**: Complete navigation system
- **Multiple Asset Icons**: Custom iconography throughout

## 🎓 Learning Resources

This project demonstrates:
- ✅ Clean Architecture with separation of concerns
- ✅ Provider + GetX hybrid state management
- ✅ Firebase integration (Auth, Firestore, Storage)
- ✅ Supabase integration for image hosting
- ✅ Multi-step form wizards with validation
- ✅ Image carousel with PageView
- ✅ Notification system with cloud persistence
- ✅ Optimistic UI updates for better UX
- ✅ Role-based access control
- ✅ Material 3 theming and design

## 🙏 Acknowledgments

- **Flutter Team**: For the incredible cross-platform framework
- **Firebase**: For scalable backend services and real-time database
- **Supabase**: For cost-effective image storage and management
- **Material Design**: For the comprehensive design system
- **Lucide Icons**: For beautiful, consistent iconography
- **Open Source Community**: For the amazing packages and libraries

---

<div align="center">

**Built with ❤️ using Flutter**

*SmartMart - Empowering local vendors, delighting customers*

[Report Bug](https://github.com/your-repo/issues) · [Request Feature](https://github.com/your-repo/issues) · [Documentation](https://github.com/your-repo/wiki)

</div>
# smart-mart
# smart-mart
