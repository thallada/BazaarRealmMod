Scriptname BRQuestPlayerAliasScript extends ReferenceAlias  

Quest property BRQuest auto
Cell property BREmpty auto

event OnPlayerLoadGame()
    Debug.Trace("Player load game")
    BRQuestScript BRScript = BRQuest as BRQuestScript
    BRScript.Maintenance()
    Cell currentCell = self.GetReference().GetParentCell()
    if currentCell == BREmpty
        Debug.Trace("Player's loaded cell is BREmpty, resetting merch")
    endif
endEvent

event OnCellLoad()
    Debug.Trace("Player load cell")
    Cell currentCell = self.GetReference().GetParentCell()
    if currentCell == BREmpty
        Debug.Trace("Player's loaded cell is BREmpty, resetting merch")
    endif
endEvent