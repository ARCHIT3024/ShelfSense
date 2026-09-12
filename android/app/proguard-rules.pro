# google_mlkit_text_recognition references the optional script-specific recognisers
# (Chinese / Devanagari / Japanese / Korean) at compile time even though we only bundle
# the Latin model. R8 otherwise fails the release build on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# tflite_flutter loads the TensorFlow Lite runtime via JNI/reflection.
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# ML Kit discovers its components reflectively via no-arg registrar constructors;
# logcat showed R8 stripping them ("NoSuchMethodException: ...Registrar.<init> []").
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
