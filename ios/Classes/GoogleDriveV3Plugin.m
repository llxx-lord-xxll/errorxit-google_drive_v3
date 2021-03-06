#import "GoogleDriveV3Plugin.h"
#if __has_include(<google_drive_v3/google_drive_v3-Swift.h>)
#import <google_drive_v3/google_drive_v3-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "google_drive_v3-Swift.h"
#endif

@implementation GoogleDriveV3Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGoogleDriveV3Plugin registerWithRegistrar:registrar];
}
@end
