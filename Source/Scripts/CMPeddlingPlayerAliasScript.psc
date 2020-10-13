Scriptname CMPeddlingPlayerAliasScript extends ReferenceAlias  

CMPeddlingScript Property QuestScript Auto

event OnPlayerLoadGame()
	debug.Trace("CMPeddlingPlayerAliasScript OnPlayerLoadGame")
	QuestScript.Maintenance()
endEvent