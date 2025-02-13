#!/usr/bin/env perl
if (!$::Driver) { use FindBin; exec("$FindBin::Bin/bootstrap.pl", @ARGV, $0); die; }
# DESCRIPTION: Verilator: Verilog Test driver/expect definition
#
# Copyright 2003 by Wilson Snyder. This program is free software; you
# can redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License Version 3 or the Perl Artistic License
# Version 2.0.
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0

use IO::File;
use File::Spec::Functions 'catfile';

scenarios(dist => 1);

my $root = "..";
my $Debug;

if (!-r catfile($root, ".git")) {
    skip("Not in a git repository");
} else {
    ### Must trim output before and after our file list
    my $files = `cd $root && git ls-files --exclude-standard`;
    print "ST $files\n" if $Debug;
    foreach my $file (split /\n/, $files) {
        next if $file =~ m!include/vltstd/vpi_user.h!;  # IEEE Standard file - can't change it
        next if $file =~ m!include/gtkwave/!;  # Standard file - can't change it
        my $filename = catfile($root, $file);
        @lines = split /\n/, file_contents($filename);
        @include_lines = grep(/include/, @lines);
        foreach my $line (@include_lines) {
            my $hit;
            $hit = 1 if $line =~ /\bassert\.h/;
            $hit = 1 if $line =~ /\bctype\.h/;
            $hit = 1 if $line =~ /\berrno\.h/;
            $hit = 1 if $line =~ /\bfloat\.h/;
            $hit = 1 if $line =~ /\blimits\.h/;
            $hit = 1 if $line =~ /\blocale\.h/;
            $hit = 1 if $line =~ /\bmath\.h/;
            $hit = 1 if $line =~ /\bsetjmp\.h/;
            $hit = 1 if $line =~ /\bsignal\.h/;
            $hit = 1 if $line =~ /\bstdarg\.h/;
            $hit = 1 if $line =~ /\bstdbool\.h/;
            $hit = 1 if $line =~ /\bstddef\.h/;
            #Not yet: $hit = 1 if $line =~ /\bstdint\.h/;
            $hit = 1 if $line =~ /\bstdio\.h/;
            $hit = 1 if $line =~ /\bstdlib\.h/;
            $hit = 1 if $line =~ /\bstring\.h/;
            $hit = 1 if $line =~ /\btime\.h/ && $line !~ m!sys/time.h!;
            next if !$hit;
            $names{"$filename: $line"} = 1;
        }
    }
    if (keys %names) {
		error("Files like stdint.h instead of cstdint:\n    ", join("\n    ", sort keys %names));
    }
}

ok(1);
1;
