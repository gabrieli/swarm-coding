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
git clone https://github.com/<github-username>/<repo-name>.git
cd <repo-name>
```

### 2. Install Development Tools

```bash
# Install required development tools for your platform
# Examples:
# - Language-specific SDKs
# - Build tools (Gradle, Maven, npm, etc.)
# - Platform-specific tools

# Verify installations
./verify-tools.sh
```

*For specific technology stacks (e.g., Kotlin Multiplatform), see `docs/modules/`*

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

### 5. External Services Setup

#### Install Service Dependencies
```bash
# Install required CLI tools for external services
# Examples:
# - Database clients
# - API testing tools
# - Mock servers

# Verify installations
./verify-services.sh
```

#### Start Local Services
```bash
# Start any required local services
./start-local-services.sh

# This will output connection details for each service
```

#### Configure Environment
Create `.env.local` file in project root:
```bash
# Add your service configurations
SERVICE_URL=http://localhost:port
SERVICE_KEY=your-service-key
# Add other required environment variables
```

*Document specific service configurations in your project README.*

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

3. **Enable Required Plugins**
   - Plugins → Marketplace → Search for required plugins
   - Install plugins specific to your technology stack
   - Restart IDE after installation

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

#### 1. Run Core Tests
```bash
# Run your project's core test suite
./run-tests.sh --core

# Expected output:
# Tests passed successfully
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

#### 4. Verify External Service Connections
```bash
# Run integration tests to verify service connections
./run-integration-tests.sh
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

### Common Service Issues

**Issue**: Local services won't start
```bash
# Stop all services
./stop-services.sh

# Clean and restart
./clean-services.sh
./start-services.sh
```

**Issue**: Connection refused
```bash
# Check if services are running
./check-services.sh

# Check service logs
./service-logs.sh
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

# Check project-specific tools
# Add checks for your required tools here
# Example:
# if command -v your-tool &> /dev/null; then
#     echo "✅ Your tool installed"
# else
#     echo "❌ Your tool not installed"
# fi

# Check Docker (if using containerized services)
if command -v docker &> /dev/null && docker ps &> /dev/null; then
    echo "✅ Docker is running"
else
    echo "⚠️  Docker not running or not installed (if required)"
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