Scriptname CMFetchThread extends Quest hidden

Bool threadQueued = false

String function GetAsync()
    threadQueued = true
endFunction

Bool function IsQueued()
    return threadQueued
endFunction

Bool function ForceUnlock()
    threadQueued = false
    return true
endFunction

Event OnFetch()
    debug.Trace("CMFetchThread OnFetch")
    if threadQueued
        String helloWorld = MyClass.HelloWorld()
        debug.Trace("helloWorld: " + helloWorld)
        RaiseEvent_FetchReturnedCallback(helloWorld)
        threadQueued = false
    endif
endEvent

function RaiseEvent_FetchReturnedCallback(String response)
    debug.Trace("CMFetchThread RaiseEvent_FetchReturnedCallback")
    int handle = ModEvent.Create("Shopkeeping_FetchReturnedCallback")
    if handle
    	ModEvent.PushString(handle, response)
        ModEvent.Send(handle)
    else
        ;pass
    endif
endFunction