package Desktop::Open;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;
use Log::ger;

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
                my $exit_code = $? < 0 ? $? : $? >> 8;
                last if $exit_code == 0 || $exit_code == 2; # 2 = file not found
                # my xdg-open returns 4 instead of 2 when file is not found, so
                # we test ourselves
                if ($exit_code == 4 && $path_or_url !~ m!\A\w+://! && !(-e $path_or_url)) {
                    log_trace "We changed xdg-open's exit code 4 to 2 since path $path_or_url does not exist";
                    $res = 2 << 8;
                    last;
                }
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

 use Desktop::Open qw(open_desktop);
 my $ok = open_desktop($path_or_url);
 # !defined($ok);       no recognized command found
 # $ok == 0;            command found and executed
 # $ok != 0;            command found, error while executing


=head1 DESCRIPTION

This module tries to open specified file or URL in the user's preferred
application. Here's how it does it.

1. If on Windows, use "start". If on other OS, use "xdg-open" if available.

2. If #1 fails, resort to using L<Browser::Open>'s C<open_browser>. Return its
return value. An exception is if #1 fails with "file/URL does not exist" error,
in which case we give up immediately.

TODO: On OSX, use "openit". Any taker?


=head1 FUNCTIONS

=head2 open_desktop


=head1 SEE ALSO

L<Browser::Open>, on which our module is modelled upon.

L<Open::This> also tries to do "The Right Thing" when opening files, but it's
heavily towards text editor and git/GitHub.

L<App::Open> and its CLI L<openit> also attempt to open file using appropriate
file. It requires setting up a configuration file to run.

=cut
