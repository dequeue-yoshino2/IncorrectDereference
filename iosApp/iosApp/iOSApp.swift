import SwiftUI
import shared

@main
struct iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        testCode2()
        
        return true
    }
}

class ObjectFromSwift {
    var message: String
    
    init(message: String) {
        self.message = message
    }
}

func testCode1() {
    let o = ObjectFromSwift(message: "hoge")
    let text1 = o.message
    
    print("\(Thread.current.debugDescription): \(text1)")
    
    DispatchQueue(label: "Any worker thread").async {
        let text2 = o.message
        
        print("\(Thread.current.debugDescription): \(text2)")
    }
    
    /* Output
     
     <_NSMainThread: 0x600003a04b00>{number = 1, name = main}: hoge
     <NSThread: 0x600003a3ff80>{number = 6, name = (null)}: hoge
     
     */
}

func testCode2() {
    let o = ObjectFromKotlin(message: "hoge")
    let text1 = o.message
    
    print("\(Thread.current.debugDescription): \(text1)")
    
    DispatchQueue(label: "Other thread").async {
        let text2 = o.message // throw IncorrectDereferenceException
        
        print("\(Thread.current.debugDescription): \(text2)")
    }
    
    /* Output
     
     <_NSMainThread: 0x600000188100>{number = 1, name = main}: hoge
     Uncaught Kotlin exception: kotlin.native.IncorrectDereferenceException: illegal attempt to access non-shared com.example.incorrectdereference.ObjectFromKotlin@149a0a8 from other thread
     2021-12-03 10:21:43.446730+0900 iosApp[47967:604726] [Unknown process name] copy_read_only: vm_copy failed: status 1.
         at 0   iosApp                              0x000000010badf311 kfun:kotlin.Throwable#<init>(kotlin.String?){} + 97
         at 1   iosApp                              0x000000010bad9b5d kfun:kotlin.Exception#<init>(kotlin.String?){} + 93
         at 2   iosApp                              0x000000010bad9c5d kfun:kotlin.RuntimeException#<init>(kotlin.String?){} + 93
         at 3   iosApp                              0x000000010baf9d3d kfun:kotlin.native.IncorrectDereferenceException#<init>(kotlin.String){} + 93
         at 4   iosApp                              0x000000010bafb58f ThrowIllegalObjectSharingException + 623
         at 5   iosApp                              0x000000010bc01542 _ZN12_GLOBAL__N_128throwIllegalSharingExceptionEP9ObjHeader + 34
         at 6   iosApp                              0x000000010bc0186d _ZN12_GLOBAL__N_136terminateWithIllegalSharingExceptionEP9ObjHeader + 13
         at 7   iosApp                              0x000000010bc019e9 _ZNK27BackRefFromAssociatedObject3refIL11ErrorPolicy3EEEP9ObjHeaderv + 185
         at 8   iosApp                              0x000000010bad3d65 -[KotlinBase toKotlin:] + 21
         at 9   iosApp                              0x000000010bbfa60e Kotlin_ObjCExport_refFromObjC + 78
         at 10  iosApp                              0x000000010bacee4f objc2kotlin.7 + 143
         at 11  iosApp                              0x000000010bacd270 $s6iosApp9testCode2yyFyycfU_ + 48 (/Users/work/Documents/repos/IncorrectDereference/iosApp/iosApp/iOSApp.swift:57:23)
         at 12  iosApp                              0x000000010bacd0b8 $sIeg_IeyB_TR + 40
         at 13  libdispatch.dylib                   0x000000010be98a28 _dispatch_call_block_and_release + 12
         at 14  libdispatch.dylib                   0x000000010be99c0c _dispatch_client_callout + 8
         at 15  libdispatch.dylib                   0x000000010bea060f _dispatch_lane_serial_drain + 858
         at 16  libdispatch.dylib                   0x000000010bea12fe _dispatch_lane_invoke + 436
         at 17  libdispatch.dylib                   0x000000010bead59b _dispatch_workloop_worker_thread + 900
         at 18  libsystem_pthread.dylib             0x00007fff6bfeb45d _pthread_wqthread + 314
         at 19  libsystem_pthread.dylib             0x00007fff6bfea42f start_wqthread + 15

     */
}
