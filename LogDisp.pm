# Sample prg by NKS on perl oops with Export method
#

package LogDisp;

use strict;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(logInfo logDie);
our @EXPORT_OK = qw(logDesign);

sub logInfo {
    my ($fileHandler,$content) = @_;

    print $fileHandler  $content;
    print $fileHandler "\n";
    print "INFO :$content\n";
}

sub logDie {
    my ($fileHandler,$content) = @_;

    print $fileHandler  $content;
    print $fileHandler "\n";
    print "ERROR :$content\n";
    exit 0;

}
sub logDesign {
    my ($content) = @_;

    print '-' x 120;
    print "\n";
    print "DETAIL   :$content\n";
    print '-' x 120;
    print "\n\n";

}
1;