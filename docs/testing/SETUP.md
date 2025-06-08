# Testing Environment Setup Guide

This guide walks you through setting up your development environment for testing your project across all platforms.

## Prerequisites

### System Requirements

- **macOS**: 13.0+ (for iOS development)
- **JDK**: 17 or higher
- **Xcode**: 15.0+ (for iOS)
- **Android Studio**: Hedgehog | 2023.1.1 or newer
- **Node.js**: 18+ (for Supabase functions)

### Required Tools

```bash
# Check Java version
java -version  # Should be 17+

# Check Xcode version (macOS)
xcodebuild -version

# Check Android SDK
echo $ANDROID_HOME  # Should be set

# Check Node.js
node --version  # Should be 18+
```

## Development Environment Setup

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME
```

### 2. Install Kotlin Multiplatform

```bash
# Install SDKMAN (if not already installed)
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install Kotlin
sdk install kotlin
```

### 3. Android Setup

#### Install Android SDK
1. Open Android Studio
2. Go to **SDK Manager** (Tools → SDK Manager)
3. Install:
   - Android SDK Platform 34
   - Android SDK Build-Tools 34.0.0
   - Android SDK Platform-Tools
   - Android Emulator

#### Configure Environment Variables
```bash
# Add to ~/.bashrc or ~/.zshrc
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin

# Reload shell configuration
source ~/.bashrc  # or source ~/.zshrc
```

#### Create Android Emulator
```bash
# List available system images
sdkmanager --list | grep system-images

# Install a system image
sdkmanager "system-images;android-34;google_apis;arm64-v8a"

# Create AVD
avdmanager create avd -n "Pixel_7_API_34" -k "system-images;android-34;google_apis;arm64-v8a"

# Start emulator
emulator -avd Pixel_7_API_34
```

### 4. iOS Setup (macOS only)

#### Install Xcode Command Line Tools
```bash
xcode-select --install
```

#### Install CocoaPods
```bash
sudo gem install cocoapods
pod --version
```

#### Setup iOS Dependencies
```bash
cd iosApp
pod install
cd ..
```

#### Configure Signing (for device testing)
1. Open `iosApp/iosApp.xcworkspace` in Xcode
2. Select the project in navigator
3. Go to "Signing & Capabilities"
4. Select your development team
5. Update bundle identifier if needed

### 5. Supabase Local Setup

#### Install Supabase CLI
```bash
# macOS with Homebrew
brew install supabase/tap/supabase

# Or with npm
npm install -g supabase

# Verify installation
supabase --version
```

#### Start Local Supabase
```bash
# From project root
cd supabase
supabase start

# This will output connection details:
# API URL: http://localhost:54321
# DB URL: postgresql://postgres:postgres@localhost:54322/postgres
# Studio URL: http://localhost:54323
# Inbucket URL: http://localhost:54324
# anon key: eyJ...
# service_role key: eyJ...
```

#### Configure Environment
Create `.env.local` file in project root:
```bash
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your-anon-key-from-output
SUPABASE_SERVICE_KEY=your-service-key-from-output
```

## IDE Configuration

### Android Studio Setup

1. **Open Project**
   ```
   File → Open → Select project root directory
   ```

2. **Configure Gradle**
   - Preferences → Build, Execution, Deployment → Build Tools → Gradle
   - Gradle JDK: 17 or higher
   - Use Gradle from: gradle-wrapper.properties

3. **Enable KMM Plugin**
   - Plugins → Marketplace → Search "Kotlin Multiplatform Mobile"
   - Install and restart

4. **Configure Test Runner**
   - Run → Edit Configurations
   - Add → Android Instrumented Tests
   - Module: androidApp
   - Test: All in module

### Xcode Setup

1. **Open Workspace**
   ```bash
   open iosApp/iosApp.xcworkspace
   ```

2. **Configure Scheme for Testing**
   - Product → Scheme → Edit Scheme
   - Test → Options → Code Coverage: ✓
   - Test → Options → Gather coverage for all targets: ✓

3. **Add Test Targets** (if needed)
   ```bash
   cd iosApp
   ruby add_test_target.rb
   ruby add_ui_test_target.rb
   ```

### IntelliJ IDEA Setup

1. **Import Project**
   - File → Open → Select project root
   - Import as Gradle project

2. **Configure SDKs**
   - File → Project Structure → SDKs
   - Add Android SDK
   - Add JDK 17

3. **Enable Frameworks**
   - File → Project Structure → Facets
   - Add Android facet to androidApp
   - Add Kotlin facet to shared

## First Test Run

### Verify Setup with Quick Tests

#### 1. Run Shared Tests
```bash
./gradlew :shared:allTests

# Expected output:
# BUILD SUCCESSFUL
# All tests passed
```

#### 2. Run Android Unit Tests
```bash
./gradlew :androidApp:testDebugUnitTest

# Or from Android Studio:
# Right-click androidApp/src/test → Run 'All Tests'
```

#### 3. Run iOS Unit Tests
```bash
cd iosApp
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iosAppTests

# Or from Xcode:
# Product → Test (⌘U)
```

#### 4. Verify Supabase Connection
```bash
# Run integration test
./gradlew :shared:commonTest --tests "*SupabaseIntegrationTest"
```

## Troubleshooting Setup Issues

### Common Android Issues

**Issue**: Gradle sync failed
```bash
# Clear Gradle cache
./gradlew clean
rm -rf ~/.gradle/caches
./gradlew build --refresh-dependencies
```

**Issue**: Emulator won't start
```bash
# Check virtualization
emulator -accel-check

# Start with verbose logging
emulator -avd Pixel_7_API_34 -verbose
```

### Common iOS Issues

**Issue**: Pod install fails
```bash
# Clean and reinstall
cd iosApp
pod deintegrate
pod cache clean --all
pod install
```

**Issue**: Simulator not found
```bash
# List available simulators
xcrun simctl list devices

# Create new simulator
xcrun simctl create "iPhone 15" "iPhone 15" iOS17.0
```

### Common Supabase Issues

**Issue**: Supabase won't start
```bash
# Stop all containers
supabase stop

# Clean and restart
docker system prune -a
supabase start
```

**Issue**: Connection refused
```bash
# Check if services are running
docker ps

# Check logs
supabase logs
```

## Environment Validation

Run this script to validate your setup:

```bash
#!/bin/bash
# save as validate-setup.sh

echo "🔍 Validating project testing environment..."

# Check Java
if java -version 2>&1 | grep -q "version \"17"; then
    echo "✅ Java 17+ found"
else
    echo "❌ Java 17+ not found"
fi

# Check Android
if [ -n "$ANDROID_HOME" ]; then
    echo "✅ Android SDK configured"
else
    echo "❌ ANDROID_HOME not set"
fi

# Check Xcode (macOS)
if command -v xcodebuild &> /dev/null; then
    echo "✅ Xcode installed"
else
    echo "⚠️  Xcode not found (iOS development unavailable)"
fi

# Check Kotlin
if command -v kotlin &> /dev/null; then
    echo "✅ Kotlin installed"
else
    echo "❌ Kotlin not installed"
fi

# Check Supabase
if command -v supabase &> /dev/null; then
    echo "✅ Supabase CLI installed"
else
    echo "❌ Supabase CLI not installed"
fi

# Check Docker (for Supabase)
if docker ps &> /dev/null; then
    echo "✅ Docker is running"
else
    echo "❌ Docker not running or not installed"
fi

echo "🏁 Validation complete"
```

## Next Steps

Now that your environment is set up:

1. Read [WRITING_TESTS.md](./WRITING_TESTS.md) to learn how to write tests
2. Check [RUNNING_TESTS.md](./RUNNING_TESTS.md) for test execution details
3. Review [BEST_PRACTICES.md](./BEST_PRACTICES.md) for testing patterns

## Getting Help

- Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
- Review platform-specific documentation
- Ask in the team chat for environment-specific help