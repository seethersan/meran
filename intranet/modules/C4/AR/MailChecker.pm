# Meran - MERAN UNLP is a ILS (Integrated Library System) wich provides Catalog,
# Circulation and User's Management. It's written in Perl, and uses Apache2
# Web-Server, MySQL database and Sphinx 2 indexing.
# Copyright (C) 2009-2013 Grupo de desarrollo de Meran CeSPI-UNLP 
# <desarrollo@cespi.unlp.edu.ar>
#
# This file is part of Meran.
#
# Meran is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Meran is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::AR::MailChecker;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw( valid validlist );
@EXPORT = qw(
    
);
$VERSION = '0.4';
my $rfc822re;
my $lwsp = "(?:(?:\\r\\n)?[ \\t])";
my $char = '[\\000-\\177]';
sub make_rfc822re {
    my $specials = '()<>@,;:\\\\".\\[\\]';
    my $controls = '\\000-\\037\\177';
    my $dtext = "[^\\[\\]\\r\\\\]";
    my $domain_literal = "\\[(?:$dtext|\\\\.)*\\]$lwsp*";
    my $quoted_string = "\"(?:[^\\\"\\r\\\\]|\\\\.|$lwsp)*\"$lwsp*";
    my $atom = "[^$specials $controls]+(?:$lwsp+|\\Z|(?=[\\[\"$specials]))";
    my $word = "(?:$atom|$quoted_string)";
    my $localpart = "$word(?:\\.$lwsp*$word)*";
    my $sub_domain = "(?:$atom|$domain_literal)";
    my $domain = "$sub_domain(?:\\.$lwsp*$sub_domain)*";
    my $addr_spec = "$localpart\@$lwsp*$domain";
    my $phrase = "$word*";
    my $route = "(?:\@$domain(?:,\@$lwsp*$domain)*:$lwsp*)";
    my $route_addr = "\\<$lwsp*$route?$addr_spec\\>$lwsp*";
    my $mailbox = "(?:$addr_spec|$phrase$route_addr)";
    my $group = "$phrase:$lwsp*(?:$mailbox(?:,\\s*$mailbox)*)?;\\s*";
    my $address = "(?:$mailbox|$group)";
    return "$lwsp*$address";
}
sub strip_comments {
    my $s = shift;
    while ($s =~ s/^((?:[^"\\]|\\.)*
                    (?:"(?:[^"\\]|\\.)*"(?:[^"\\]|\\.)*)*)
                    \((?:[^()\\]|\\.)*\)/$1 /osx) {}
    return $s;
}
sub valid ($) {
    my $s = strip_comments(shift);
    if (!$rfc822re) {
        $rfc822re = make_rfc822re();
    }
    return $s =~ m/^$rfc822re$/so && $s =~ m/^$char*$/;
}
sub validlist ($) {
    my $s = strip_comments(shift);
    if (!$rfc822re) {
        $rfc822re = make_rfc822re();
    }
    # * null list items are valid according to the RFC
    # * the '1' business is to aid in distinguishing failure from no results
    my @r;
    if($s =~ m/^(?:$rfc822re)?(?:,(?:$rfc822re)?)*$/so && $s =~ m/^$char*$/) {
        while($s =~ m/(?:^|,$lwsp*)($rfc822re)/gos) {
            push @r, $1;
        }
        return wantarray ? (scalar(@r), @r) : 1;
    }
    else {
        return wantarray ? () : 0;
    }
}
1;
__END__
