Scriptname BRQuestPlayerAliasScript extends ReferenceAlias  

Cell property BREmpty auto

event OnPlayerLoadGame()
    Debug.Trace("Player load game")
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