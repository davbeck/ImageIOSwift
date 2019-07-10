#if os(iOS)
    import QuartzCore
    
    extension CADisplayLink {
        private class Proxy {
            let callback: (CADisplayLink) -> Void
            init(callback: @escaping (CADisplayLink) -> Void) {
                self.callback = callback
            }
            
            @objc func fire(_ link: CADisplayLink) {
                self.callback(link)
            }
        }
        
        convenience init(callback: @escaping (CADisplayLink) -> Void) {
            let proxy = Proxy(callback: callback)
            
            self.init(target: proxy, selector: #selector(Proxy.fire))
        }
    }
#endif
