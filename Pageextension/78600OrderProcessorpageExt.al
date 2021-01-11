pageextension 78600 "BAL Orderprocessor Extention" extends "Order Processor Role Center"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {

        addafter(SetupAndExtensions)
        {
            Group("Translate menu")
            {
                Caption = 'Translate Menu';
                Group(Translate)
                {
                    caption = 'Translate';
                    action(Contact)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Projects';
                        Image = Customer;
                        RunObject = Page "BAC Trans Project List";
                        ToolTip = 'View or edit Translate projects';
                    }
                    action("Translate Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Translate Setup';
                        Image = Customer;
                        RunObject = Page "BAC Translation Setup";
                        ToolTip = 'View or edit Translate Setup';
                    }
                    action(Languages)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Languages';
                        Image = Customer;
                        RunObject = Page "BAC Languages";
                        ToolTip = 'Edit Languages';
                    }
                }
            }
        }
    }
}