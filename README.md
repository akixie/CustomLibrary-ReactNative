# ReactNative-CustomLibraryExample
ReactNaitve关联ios静态库，  原生模块组件属性，方法与回调函数的调用。xcode创建的静态库,关联到ReactNative.  

准备工作：

创建ReactNative工程

我们需要先创建一个ReactNative工程，使用如下命令创建。

react native init TestProject
创建好工程之后，我们使用xcode打开TestProject/ios/下的iOS工程。

创建静态库，并将这个静态库手动链接到工程中

首先，我们在前面创建的ReactNative工程下的node_modules创建一个文件夹react-native-BGNativeModuleExample，然后我们在新创建的文件夹下再创建一个ios文件夹。

 
$ cd TestProject/node_modules
$ mkdir react-native-BGNativeModuleExample
$ cd react-native-BGNativeModuleExample
$ mkdir ios

然后，由于ReactNative的组件都是一个个静态库，我们发布到npm给别人使用的话，也需要建立静态库。我们使用Xcode建立静态库，取名为BGNativeModuleExample。建立之后，我们将创建的静态库中的文件全部copy到node_modules/react-native-BGNativeModuleExample/ios目录下。

iOS文件目录如下：



|____BGNativeModuleExample

| |____BGNativeModuleExample.h

| |____BGNativeModuleExample.m

|____BGNativeModuleExample.xcodeproj

最后，我们需要手动将这个静态库链接到工程中。

1、使用xcode打开创建的静态库，添加一行Header Search Paths，值为$(SRCROOT)/../../react-native/React，并设置为recursive。



2、将BGNativeModuleExample静态库工程拖动到工程中的Library中。 



3、选中 TARGETS => TestProject => Build Settings => Link Binary With Libraries，添加libBGNativeModuleExample.a这个静态库 



到此，我们准备工作完成了。我们这里这么准备是有用意的，那就是模拟npm链接的过程，建立好了环境，避免了发布到npm上后别人使用找不到静态库的问题。