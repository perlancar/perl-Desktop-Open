package Desktop::Open;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(open_desktop);

sub open_desktop {
    my $path_or_url = shift;

    my $res;
  OPEN: {
        if ($^O eq 'MSWin32') {
            system "start", $path_or_url;
            $res = $?;
            last if $res == 0;
        } else {
            require File::Which;
            if (File::Which::which("xdg-open")) {
                system "xdg-open", $path_or_url;
                $res = $?;
                last if $res == 0;
            }
        }

        require Browser::Open;
        $res = Browser::Open::open_browser($path_or_url);
    }
    $res;
}

1;
#ABSTRACT: Open a file or URL in the user's preferred application

=head1 SYNOPSIS

 use Desktop::Open qw(desktop_open);
 my $ok = desktop_open($path_or_url);
 # !defined($ok);       no recognized command found
 # $ok == 0;            command found and executed
 # $ok != 0;            command found, error while executing


=head1 DESCRIPTION

This module tries to open specified file or URL in the user's preferred
application. Here's how it does it.

1. If on Windows, use "start". If on other OS, use "xdg-open" if available.

2. If #1 fails, resort to using L<Browser::Open>'s C<open_browser>. Return its
return value.

TODO: On OSX, use "openit". Any taker?


=head1 FUNCTIONS

=head2 desktop_open


=head1 SEE ALSO

L<Browser::Open>, on which our module is modelled upon.

L<Open::This> also tries to do "The Right Thing" when opening files, but it's
heavily towards text editor and git/GitHub.

L<App::Open> and its CLI L<openit> also attempt to open file using appropriate
file. It requires setting up a configuration file to run.

=cut
