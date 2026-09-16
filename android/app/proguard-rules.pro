# Flutter ProGuard rules for Sanctuary: Relax & Mindfulness
# These rules prevent just_audio, audio_session, and Flutter plugins from being stripped

# Keep Flutter framework classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep just_audio / ExoPlayer classes
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Keep audio_session
-keep class com.ryanheise.audio_session.** { *; }

# Keep url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Keep package_info_plus
-keep class io.flutter.plugins.packageinfo.** { *; }

# Keep Kotlin coroutines
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# General Android rules
-dontwarn sun.misc.**
-keep class * implements android.os.Parcelable { *; }
-keepclassmembers class * implements java.io.Serializable { *; }
