# Kotlin Multiplatform Module

This module contains specific guidance for projects using Kotlin Multiplatform Mobile (KMM).

## Architecture Overview

For KMM projects, our testing architecture includes:

- **Shared Module**: Common business logic and data models
- **iOS App**: SwiftUI-based iOS application
- **Android App**: Jetpack Compose-based Android application

### Directory Structure
```
project/
├── shared/
│   ├── src/
│   │   ├── commonMain/    # Shared code
│   │   ├── commonTest/    # Shared tests
│   │   ├── iosMain/       # iOS-specific code
│   │   ├── iosTest/       # iOS-specific tests
│   │   ├── androidMain/   # Android-specific code
│   │   └── androidTest/   # Android-specific tests
├── iosApp/               # iOS application
└── androidApp/           # Android application
```

## Testing Setup

### Kotlin Multiplatform Configuration

Add to your `shared/build.gradle.kts`:
```kotlin
kotlin {
    sourceSets {
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
            }
        }
    }
}
```

## Architecture Best Practices

### Consolidation over Options
When working with KMM:
- **Use kotlin.test for KMM testing** rather than platform-specific frameworks
- Example: Test actual ViewModel with kotlin.test rather than abstract examples

### Example Test
```kotlin
@Test
fun testActualProjectCode() {
    // Test using real project components
    // Proves the setup works correctly
}
```

## Platform-Specific Development

### iOS Development with KMM
- Use SwiftUI for UI components
- Follow iOS Human Interface Guidelines
- Handle Kotlin/Native interop carefully

### Android Development with KMM
- Use Jetpack Compose for UI
- Follow Material Design guidelines
- Leverage Kotlin language features

### Shared Code Guidelines
- Use expect/actual pattern for platform-specific implementations
- Keep platform-specific code minimal
- Test on all platforms
- Document platform differences

## Known Issues and Workarounds

### KotlinByteArray Conversion Crash (iOS)

**Issue**: App crashes when converting large image data (368KB+) from Swift Data to KotlinByteArray in KMP projects.

**Symptoms**:
- Crash occurs after "Creating KotlinByteArray..." log
- Works fine with small test data (10 bytes)
- Fails with actual image data

**Current Workaround**:
```swift
// Convert image to base64 for future use
let base64String = imageData.base64EncodedString()

// Create minimal test data for KotlinByteArray
let testData = Data("test".utf8)
let byteArray = KotlinByteArray(size: Int32(testData.count))
for i in 0..<testData.count {
    byteArray.set(index: Int32(i), value: Int8(bitPattern: testData[i]))
}
```

**Future Solutions to Explore**:
1. Update Kotlin Multiplatform version
2. Use base64 string passing instead of byte arrays
3. Implement server-side processing
4. Research Kotlin/Native memory interop issues