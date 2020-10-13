Scriptname CMFetchThreadManager extends Quest
 
Quest Property CMFetchQuest Auto
 
CMFetchThread01 thread01

Event OnInit()
    debug.Trace("CMFetchThreadManager OnInit")
    ;Init()
endEvent
 
function Init()
    debug.Trace("CMFetchThreadManager Init")
    RegisterForModEvent("Shopkeeping_OnFetch", "OnFetch")
    RegisterForModEvent("Shopkeeping_FetchReturnedCallback", "FetchReturnedCallback")
 
    thread01 = CMFetchQuest as CMFetchThread01

    debug.Trace("CMFetchThreadManager starting fetch async")
    FetchAsync()
    WaitAll()
endFunction
 
function FetchAsync()
    debug.Trace("CMFetchThreadManager FetchAsync")
    if !thread01.IsQueued()
        thread01.GetAsync()
    else
        debug.Trace("CMFetchThreadManager FetchAsync thread already queued!")
        WaitAll()
        FetchAsync()
	endif
endFunction
 
function WaitAll()
    RaiseEvent_OnFetch()
    BeginWaiting()
endFunction
 
function BeginWaiting()
    Bool waiting = true
    Int i = 0
    while waiting
        if thread01.IsQueued()
            i += 1
            Utility.wait(0.1)
            if i >= 100
                debug.trace("Error: A catastrophic error has occurred. All threads have become unresponsive. Please debug this issue or notify the author.")
                i = 0
                ;Fail by returning None. The mod needs to be fixed.
                return
            endif
        else
            waiting = false
        endif
    endWhile
endFunction
 
function RaiseEvent_OnFetch()
    Int handle = ModEvent.Create("Shopkeeping_OnFetch")
    if handle
        ModEvent.Send(handle)
    else
        ;pass
    endif
endFunction

Event FetchReturnedCallback(String response)
    debug.Trace("FetchReturnedCallback: " + response)
    debug.Notification(response)
    debug.MessageBox(response)
endEvent