# --
# Kernel/Output/HTML/ToolBarTicketEscalated.pm
# Copyright (C) 2012 - 2014 Perl-Services.de, http://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ToolBarTicketEscalated;

use strict;
use warnings;

our $VERSION = 0.01;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check needed stuff
    for my $Needed (qw(Config)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my %ExtraOptions;

    my $Owners = $ConfigObject->Get( 'ToolBarTicketEscalated::TicketOwner' ) || 'me';
    if ( $Owners eq 'me' ) {
        $ExtraOptions{OwnerIDs} = [ $Self->{UserID} ];
    }

    # get user lock data
    my $Count = $TicketObject->TicketSearch(
        Result                           => 'COUNT',
        TicketEscalationTimeOlderMinutes => 0,
        UserID                           => 1,
        Permission                       => 'ro',
        %ExtraOptions,
    );

    my $Class    = $Param{Config}->{CssClass};
    my $Text     = $LayoutObject->{LanguageObject}->Translate('Escalated Tickets Total');
    my $URL      = $LayoutObject->{Baselink};
    my $Priority = $Param{Config}->{Priority};
    
    my %Return;
    if ($Count) {
        $Return{$Priority} = {
            Block       => 'ToolBarItem',
            Count       => $Count,
            Description => $Text,
            Class       => $Class,
            Link        => $URL . 'Action=AgentTicketEscalationView',
            AccessKey   => 'e',
        };
    }

    return %Return;
}

1;
