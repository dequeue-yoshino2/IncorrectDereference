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
        let mode = 3
        
        switch(mode) {
        case 0: testCode1a()
        case 1: testCode1b()
        case 2: testCode2a()
        case 3: testCode2b()
        default: break
        }
        
        return true
    }
}

class ObjectFromSwift {
    var message: String
    
    init(message: String) {
        self.message = message
    }
}

// MARK: - Swift製classのインスタンスを使った場合

// メインスレッドで生成したインスタンスのプロパティを他のスレッドで読む
func testCode1a() {
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

// (Raptorで言う所の)Pull通信スレッドで生成したインスタンスのプロパティをPush通信スレッドで読む
func testCode1b() {
    var o: ObjectFromSwift! = nil
    
    DispatchQueue(label: "HTTP pull thread").async {
        o = ObjectFromSwift(message: "hoge")
        
        let text1 = o.message
        
        print("\(Thread.current.debugDescription): \(text1)")
    }
    
    // 以降、任意のタイミングで
    sleep(1)
    
    DispatchQueue(label: "Websocket push thread").async {
        let text2 = o.message
        
        print("\(Thread.current.debugDescription): \(text2)")
    }
    
    /* Output
     
     <NSThread: 0x6000027e5040>{number = 4, name = (null)}: hoge
     <NSThread: 0x600002786c00>{number = 6, name = (null)}: hoge
     
     */
}

// MARK: - Kotlin製classのインスタンスを使った場合

/* Kotlinのソースコード
 
 class ObjectFromKotlin(var message: String)

 */

// メインスレッドで生成したインスタンスのプロパティを他のスレッドで読む
func testCode2a() {
    let o = ObjectFromKotlin(message: "hoge")
    let text1 = o.message
    
    print("\(Thread.current.debugDescription): \(text1)")
    
    DispatchQueue(label: "Other thread").async {
        let text2 = o.message // throw IncorrectDereferenceException
        
        print("\(Thread.current.debugDescription): \(text2)")
    }
    
    /* Output
     
     <_NSMainThread: 0x600003ee0000>{number = 1, name = main}: hoge
     Uncaught Kotlin exception: kotlin.native.IncorrectDereferenceException: illegal attempt to access non-shared com.example.incorrectdereference.ObjectFromKotlin@2bda948 from other thread
     2021-12-03 12:09:22.381772+0900 iosApp[59480:750900] [Unknown process name] copy_read_only: vm_copy failed: status 1.
         at 0   iosApp                              0x000000010d0c51e1 kfun:kotlin.Throwable#<init>(kotlin.String?){} + 97
         at 1   iosApp                              0x000000010d0bfa2d kfun:kotlin.Exception#<init>(kotlin.String?){} + 93
         at 2   iosApp                              0x000000010d0bfb2d kfun:kotlin.RuntimeException#<init>(kotlin.String?){} + 93
         at 3   iosApp                              0x000000010d0dfc0d kfun:kotlin.native.IncorrectDereferenceException#<init>(kotlin.String){} + 93
         at 4   iosApp                              0x000000010d0e145f ThrowIllegalObjectSharingException + 623
         at 5   iosApp                              0x000000010d1e7412 _ZN12_GLOBAL__N_128throwIllegalSharingExceptionEP9ObjHeader + 34
         at 6   iosApp                              0x000000010d1e773d _ZN12_GLOBAL__N_136terminateWithIllegalSharingExceptionEP9ObjHeader + 13
         at 7   iosApp                              0x000000010d1e78b9 _ZNK27BackRefFromAssociatedObject3refIL11ErrorPolicy3EEEP9ObjHeaderv + 185
         at 8   iosApp                              0x000000010d0b9c35 -[KotlinBase toKotlin:] + 21
         at 9   iosApp                              0x000000010d1e04de Kotlin_ObjCExport_refFromObjC + 78
         at 10  iosApp                              0x000000010d0b4d1f objc2kotlin.7 + 143
         at 11  iosApp                              0x000000010d0b2730 $s6iosApp10testCode2ayyFyycfU_ + 48 (/Users/work/Documents/repos/IncorrectDereference/iosApp/iosApp/iOSApp.swift:106:23)
         at 12  iosApp                              0x000000010d0b1b48 $sIeg_IeyB_TR + 40
         at 13  libdispatch.dylib                   0x000000010d47ea28 _dispatch_call_block_and_release + 12
         at 14  libdispatch.dylib                   0x000000010d47fc0c _dispatch_client_callout + 8
         at 15  libdispatch.dylib                   0x000000010d48660f _dispatch_lane_serial_drain + 858
         at 16  libdispatch.dylib                   0x000000010d4872fe _dispatch_lane_invoke + 436
         at 17  libdispatch.dylib                   0x000000010d49359b _dispatch_workloop_worker_thread + 900
         at 18  libsystem_pthread.dylib             0x00007fff6bfeb45d _pthread_wqthread + 314
         at 19  libsystem_pthread.dylib             0x00007fff6bfea42f start_wqthread + 15

     */
}

// (Raptorで言う所の)Pull通信スレッドで生成したインスタンスのプロパティをPush通信スレッドで読む
func testCode2b() {
    var o: ObjectFromKotlin! = nil

    DispatchQueue(label: "HTTP pull thread").async {
        o = ObjectFromKotlin(message: "hoge")
        
        let text1 = o.message
        
        print("\(Thread.current.debugDescription): \(text1)")
    }
    
    // 以降、任意のタイミングで
    sleep(1)
    
    DispatchQueue(label: "Websocket push thread").async {
        let text2 = o.message

        print("\(Thread.current.debugDescription): \(text2)")
    }
    
    /* Output
     
     <NSThread: 0x6000020ac900>{number = 4, name = (null)}: hoge
     Uncaught Kotlin exception: kotlin.native.IncorrectDereferenceException: illegal attempt to access non-shared com.example.incorrectdereference.ObjectFromKotlin@35f8288 from other thread
         at 0   iosApp                              0x0000000106ca31e1 kfun:kotlin.Throwable#<init>(kotlin.String?){} + 97
         at 1   iosApp                              0x0000000106c9da2d kfun:kotlin.Exception#<init>(kotlin.String?){} + 93
         at 2   iosApp                              0x0000000106c9db2d kfun:kotlin.RuntimeException#<init>(kotlin.String?){} + 93
         at 3   iosApp                              0x0000000106cbdc0d kfun:kotlin.native.IncorrectDereferenceException#<init>(kotlin.String){} + 93
         at 4   iosApp                              0x0000000106cbf45f ThrowIllegalObjectSharingException + 623
         at 5   iosApp                              0x0000000106dc5412 _ZN12_GLOBAL__N_128throwIllegalSharingExceptionEP9ObjHeader + 34
         at 6   iosApp                              0x0000000106dc573d _ZN12_GLOBAL__N_136terminateWithIllegalSharingExceptionEP9ObjHeader + 13
         at 7   iosApp                              0x0000000106dc58b9 _ZNK27BackRefFromAssociatedObject3refIL11ErrorPolicy3EEEP9ObjHeaderv + 185
         at 8   iosApp                              0x0000000106c97c35 -[KotlinBase toKotlin:] + 21
         at 9   iosApp                              0x0000000106dbe4de Kotlin_ObjCExport_refFromObjC + 78
         at 10  iosApp                              0x0000000106c92d1f objc2kotlin.7 + 143
         at 11  iosApp                              0x0000000106c911c1 $s6iosApp10testCode2byyFyycfU0_ + 257 (/Users/work/Documents/repos/IncorrectDereference/iosApp/iosApp/iOSApp.swift:156:23)
         at 12  iosApp                              0x0000000106c8fb48 $sIeg_IeyB_TR + 40
         at 13  libdispatch.dylib                   0x000000010705ca28 _dispatch_call_block_and_release + 12
         at 14  libdispatch.dylib                   0x000000010705dc0c _dispatch_client_callout + 8
         at 15  libdispatch.dylib                   0x000000010706460f _dispatch_lane_serial_drain + 858
         at 16  libdispatch.dylib                   0x00000001070652fe _dispatch_lane_invoke + 436
         at 17  libdispatch.dylib                   0x000000010707159b _dispatch_workloop_worker_thread + 900
         at 18  libsystem_pthread.dylib             0x00007fff6bfeb45d _pthread_wqthread + 314
         at 19  libsystem_pthread.dylib             0x00007fff6bfea42f start_wqthread + 15

     */
}
