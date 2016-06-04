# RxVisualDebugger
WIP! Very quick and very dirty test for a visual Rx debugger

```swift
btnDoh.rx_tap
    .debugRemote("Doh Button")
    .subscribeNext {_ in
        print("doh!")
    }
    .addDisposableTo(bag)
```

`debugRemote()` will log the emitted values. You can see the log if you point your browser to `localhost:9911`:

![](assets/demo.jpg)

