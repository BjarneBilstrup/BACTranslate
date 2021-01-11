page 78604 "BAC Translation Notes"
{
  PageType = Listpart;
  SourceTable = "BAC Translation Notes";
  Caption = 'Translation Notes';
  Editable = false;

  layout
  {
    area(Content)
    {
      repeater(GroupName)
      {
        field(From;rec.From)
        {
          ApplicationArea = All;
        }
        field(Annotates;rec.Annotates)
        {
          ApplicationArea = All;
        }
        field(Note;rec.Note)
        {
          ApplicationArea = All;
        }
        field(Priority;rec.Priority)
        {
          ApplicationArea = All;
          Visible = false;
        }
      }
    }
  }
}
