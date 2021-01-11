page 78611 "BAC Languages"
{
  Caption = 'Languages (Translate Module)';
  PageType = List;
  ApplicationArea = All;
  UsageCategory = Lists;
  SourceTable = Language;

  layout
  {
    area(Content)
    {
      repeater(GroupName)
      {
        field(Code;rec.Code)
        {
          ApplicationArea = All;
        }
        field(Name;rec.Name)
        {
          ApplicationArea = All;
        }
        field("Windows Language ID";rec."Windows Language ID")
        {
          ApplicationArea = All;
        }
        field("Windows Language Name";rec."Windows Language Name")
        {
          ApplicationArea = All;
        }
        field("BAC ISO code";rec."BAC ISO code")
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
