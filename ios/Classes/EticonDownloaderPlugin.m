#import "EticonDownloaderPlugin.h"
#if __has_include(<eticon_downloader/eticon_downloader-Swift.h>)
#import <eticon_downloader/eticon_downloader-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "eticon_downloader-Swift.h"
#endif

@implementation EticonDownloaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEticonDownloaderPlugin registerWithRegistrar:registrar];
}
@end
