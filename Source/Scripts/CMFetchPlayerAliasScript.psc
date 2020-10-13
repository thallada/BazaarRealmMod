Scriptname CMFetchPlayerAliasScript extends ReferenceAlias  

CMFetchThreadManager Property ThreadManagerScript Auto

event OnPlayerLoadGame()
    debug.Trace("CMFetchPlayerAliasScript OnPlayerLoadGame")
    MyClass.Init()
    ThreadManagerScript.Init()
    String uuid = MyClass.CreateUuid()
    debug.Trace("uuid: " + uuid)
    debug.Notification("Your uuid: " + uuid)
endEvent