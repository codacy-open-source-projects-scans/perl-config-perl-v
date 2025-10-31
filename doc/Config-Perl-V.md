# NAME

Config::Perl::V - Structured data retrieval of perl -V output

# SYNOPSIS

    use Config::Perl::V;

    my $local_config = Config::Perl::V::myconfig ();
    print $local_config->{config}{osname};

# DESCRIPTION

## $conf = myconfig ()

This function will collect the data described in ["The hash structure"](#the-hash-structure) below,
and return that as a hash reference. It optionally accepts an option to
include more entries from %ENV. See ["environment"](#environment) below.

Note that this will not work on uninstalled perls when called with
`-I/path/to/uninstalled/perl/lib`, but it works when that path is in
`$PERL5LIB` or in `$PERL5OPT`, as paths passed using `-I` are not
known when the `-V` information is collected.

## $conf = plv2hash ($text \[, ...\])

Convert a sole 'perl -V' text block, or list of lines, to a complete
myconfig hash.  All unknown entries are defaulted.

## $info = summary (\[$conf\])

Return an arbitrary selection of the information. If no `$conf` is
given, `myconfig ()` is used instead.

## $md5 = signature (\[$conf\])

Return the MD5 of the info returned by `summary ()` without the
`config_args` entry.

If `Digest::MD5` is not available, it return a string with only `0`'s.

## The hash structure

The returned hash consists of 4 parts:

- build

    This information is extracted from the second block that is emitted by
    `perl -V`, and usually looks something like

        Characteristics of this binary (from libperl):
          Compile-time options: DEBUGGING USE_64_BIT_INT USE_LARGE_FILES
          Locally applied patches:
                defined-or
                MAINT24637
          Built under linux
          Compiled at Jun 13 2005 10:44:20
          @INC:
            /usr/lib/perl5/5.8.7/i686-linux-64int
            /usr/lib/perl5/5.8.7
            /usr/lib/perl5/site_perl/5.8.7/i686-linux-64int
            /usr/lib/perl5/site_perl/5.8.7
            /usr/lib/perl5/site_perl
            .

    or

        Characteristics of this binary (from libperl):
          Compile-time options: DEBUGGING MULTIPLICITY
                                PERL_DONT_CREATE_GVSV PERL_IMPLICIT_CONTEXT
                                PERL_MALLOC_WRAP PERL_TRACK_MEMPOOL
                                PERL_USE_SAFE_PUTENV USE_ITHREADS
                                USE_LARGE_FILES USE_PERLIO
                                USE_REENTRANT_API
          Built under linux
          Compiled at Jan 28 2009 15:26:59

    This information is not available anywhere else, including `%Config`,
    but it is the information that is only known to the perl binary.

    The extracted information is stored in 5 entries in the `build` hash:

    - osname

        This is most likely the same as `$Config{osname}`, and was the name
        known when perl was built. It might be different if perl was cross-compiled.

        The default for this field, if it cannot be extracted, is to copy
        `$Config{osname}`. The two may be differing in casing (OpenBSD vs openbsd).

    - stamp

        This is the time string for which the perl binary was compiled. The default
        value is 0.

    - options

        This is a hash with all the known defines as keys. The value is either 0,
        which means unknown or unset, or 1, which means defined.

    - derived

        As some variables are reported by a different name in the output of `perl -V`
        than their actual name in `%Config`, I decided to leave the `config` entry
        as close to reality as possible, and put in the entries that might have been
        guessed by the printed output in a separate block.

    - patches

        This is a list of optionally locally applied patches. Default is an empty list.

- environment

    By default this hash is only filled with the environment variables
    out of %ENV that start with `PERL`, but you can pass the `env` option
    to myconfig to get more

        my $conf = Config::Perl::V::myconfig ({ env => qr/^ORACLE/ });
        my $conf = Config::Perl::V::myconfig ([ env => qr/^ORACLE/ ]);

- config

    This hash is filled with the variables that `perl -V` fills its report
    with, and it has the same variables that `Config::myconfig` returns
    from `%Config`.

- inc

    This is the list of default @INC.

# REASONING

This module was written to be able to return the configuration for the
currently used perl as deeply as needed for the CPANTESTERS framework.
Up until now they used the output of myconfig as a single text blob,
and so it was missing the vital binary characteristics of the running
perl and the optional applied patches.

# BUGS

Please feedback what is wrong

# TODO

    * Implement retrieval functions/methods
    * Documentation
    * Error checking
    * Tests

# AUTHOR

H.Merijn Brand <h.m.brand@xs4all.nl>

# COPYRIGHT AND LICENSE

Copyright (C) 2009-2025 H.Merijn Brand

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
