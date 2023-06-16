﻿#include "StevesUiHelpers.h"

#include "Components/PanelWidget.h"

void StevesUiHelpers::InsertChildWidgetAt(UPanelWidget* Parent, UWidget* Child, int AtIndex)
{
	checkf(AtIndex <= Parent->GetChildrenCount(), TEXT("Insertion index %d is greater than child count"), AtIndex);
	
	// Short-circuit for simple case of insert at end
	const int OrigCount = Parent->GetChildrenCount();
	if (OrigCount == AtIndex)
	{
		Parent->AddChild(Child);
	}
	else
	{
		// Note: cannot use InsertChildAt, that's editor-only
		// There are a few options with the runtime API
		// 1. Remove all children and re-add them in the right order
		// 2. Remove all children on or after the insert point and re-add those after adding the new item
		// 3. Use ReplaceChildAt to insert a new item and move everything down, with AddChild at the end
		//
		// I'm going with 2. because that seems to blend best performance with the most well defined behaviour
		// I'm not sure ReplaceChildAt is designed to move children around (note: ShiftChild exists but again, editor-only)

		TArray<UWidget*> WidgetsToReplaceReversed;
		WidgetsToReplaceReversed.Reserve(OrigCount - AtIndex);
		// Go backwards so we can remove as we go and not remove from the middle
		for (int i = OrigCount - 1; i >= AtIndex; --i)
		{
			WidgetsToReplaceReversed.Add(Parent->GetChildAt(i));
			Parent->RemoveChildAt(i);
		}
		// insert item
		Parent->AddChild(Child);
		// add back previous, reverse order
		for (int i = WidgetsToReplaceReversed.Num()  - 1; i >= 0; --i)
		{
			Parent->AddChild(WidgetsToReplaceReversed[i]);
		}
		
	}
	
}
