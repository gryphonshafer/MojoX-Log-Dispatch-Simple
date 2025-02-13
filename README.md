# NAME

MojoX::Log::Dispatch::Simple - Simple Log::Dispatch replacement of Mojo::Log

# VERSION

version 1.13

[![test](https://github.com/gryphonshafer/MojoX-Log-Dispatch-Simple/workflows/test/badge.svg)](https://github.com/gryphonshafer/MojoX-Log-Dispatch-Simple/actions?query=workflow%3Atest)
[![codecov](https://codecov.io/gh/gryphonshafer/MojoX-Log-Dispatch-Simple/graph/badge.svg)](https://codecov.io/gh/gryphonshafer/MojoX-Log-Dispatch-Simple)

# SYNOPSIS

    # from inside your startup() most likely...

    use Log::Dispatch;
    use MojoX::Log::Dispatch::Simple;

    my $mojo_logger = MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    );

    my ($self) = @_; # Mojolicious object from inside startup()
    $self->log($mojo_logger);

    # ...then later inside a controller...

    $self->app->log->debug('Debug-level message');
    $self->app->log->info('Info-level message');

    # ...or back to your startup() to setup some helpers...

    $mojo_logger->helpers($self);
    $mojo_logger->helpers( $self, qw( debug info warn error ) );

    # ...so that in your controllers you can...

    $self->debug('Debug-level message');
    $self->info('Info-level message');

    # ...or do it all at once, in the startup() most likely...

    $self->log( MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    )->helpers($self) );

# DESCRIPTION

This module provides a really simple way to replace the built-in [Mojo::Log](https://metacpan.org/pod/Mojo%3A%3ALog)
with a [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) object, and yet still support all the [Mojo::Log](https://metacpan.org/pod/Mojo%3A%3ALog)
log levels and other functionality [Mojolicious](https://metacpan.org/pod/Mojolicious) assumes exists. To make it
even easier, you can install helpers to all the log levels, all from the same
single line of code.

    $self->log( MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    )->helpers($self) );

The module tries not to make any assumptions about how you want to use
[Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch). In fact, you can if desired use an alternate [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch)
library so long as it offers a similar interface.

# PRIMARY METHODS

These are methods that you would likely use from within your [Mojolicious](https://metacpan.org/pod/Mojolicious)
`startup()` subroutine.

## new

This method instantiates an object. It requires a "dispatch" parameter, which
should be a [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) object (or an object with a similar signature).
The method allow accepts an optional "level" parameter, which is used to set
the log level for your [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

    my $mojo_logger = MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    );

Optionally, you can also provide a "format\_cb" value, which should be a
reference to a subroutine that will be used to provide custom formatting to
entries that appear on the [Mojolicious](https://metacpan.org/pod/Mojolicious) error reporting web page. This
formatting will have nothing at all to do with whatever your [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch)
does; it only formats log entries that appear on the [Mojolicious](https://metacpan.org/pod/Mojolicious) error
reporting web page.

    my $mojo_logger = MojoX::Log::Dispatch::Simple->new(
        dispatch  => Log::Dispatch->new,
        level     => 'debug',
        format_cb => sub {
            localtime(shift) . ' [' . shift() . '] ' . join( "\n", @_, '' )
        },
    );

By default, when you're looking at one of these [Mojolicious](https://metacpan.org/pod/Mojolicious) error reporting
web pages, you'll see the past 10 log entries listed. You can change that
by passing in a "max\_history\_size" value.

    my $mojo_logger = MojoX::Log::Dispatch::Simple->new(
        dispatch         => Log::Dispatch->new,
        max_history_size => 20,
    );

## helpers

You can optionally tell this library to create helpers to each of the log
levels, or to a selection of them. This method requires that you pass in
a reference to the [Mojolicious](https://metacpan.org/pod/Mojolicious) object. If that's all you pass in, the
method will create a helper for every log level.

    # from inside your startup()...
    $mojo_logger->helpers($mojo_obj);

    # now later from inside a controller...
    $c->debug('Debug message');

    $c->app->log->debug("This is what you'd have to type without the helper");

You can optionally pass in the names of the log levels you want helpers created
for, and the method will only create methods for those levels.

    $mojo_logger->helpers( $mojo_obj, qw( debug info warn ) );

# LOG LEVELS

Unfortunately, [Mojolicious](https://metacpan.org/pod/Mojolicious) and [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) have somewhat different
ideas as to what log levels should exist. Since this module is a bridge between
them, it attempts to support all levels from both sides. That being said, when
calling log levels in your application, you will probably want to only use
the log levels from [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) if you use your [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) code
in non-Mojo-app areas of your ecosystem, thus keeping things uniform everywhere.

For the purposes of understanding log levels relative to each other, all log
levels are assigned a "rank" value. Since [Mojolicious](https://metacpan.org/pod/Mojolicious) has fewer levels than
[Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) and there are 5 of them, a level's "rank" is an integer
between 1 and 5.

## Log::Dispatch Log Levels

The following are [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) log levels along with their corresponding
"rank" integer and any supported aliases:

- debug (1)
- info (2)
- notice (2)
- warning, warn (3)
- error, err (4)
- critical, crit (4)
- alert (5)
- emergency, emerg (5)

## Mojolicious Log Levels

The following are [Mojolicious](https://metacpan.org/pod/Mojolicious) log levels along with their corresponding
"rank" integer and any supported aliases:

- debug (1)
- info (2)
- warn (3)
- error (4)
- fatal (5)

You can check what log level you're set at by either just reading `$obj-`level>
or by running an "is\_\*" method. For every log level, there's a corresponding
"is\_\*" method.

    my $log_level_at_or_above_notice = $obj->is_notice;

Note that this gets somewhat confusing when dealing with [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) log
levels because from the perspective of [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch), the "notice" level is
a unique level that's lower than a "warning" and higher than the "info" level.
However, from the perspective of [Mojolicious](https://metacpan.org/pod/Mojolicious), there's no such log level.
It will assume you're set at the "info" log level. Ergo, if you call
`is_notice()` or `is_info()`, you'll get the same result.

# POST-INSTANTIATION MEDDLING

Following the creation of the object from this library, you can still
manipulate various attributes, which are:

- dispatch (a [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) object)
- level
- max\_history\_size
- format\_cb (a subref)
- history (an arrayref)

So you can do things like:

    $obj->dispatch->remove('debug');

This also means you can manipulate the log history. Why you'd ever want to do
that, I can't say; but you can. Freedom is messy.

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch).

You can also look for additional information at:

- [GitHub](https://github.com/gryphonshafer/MojoX-Log-Dispatch-Simple)
- [MetaCPAN](https://metacpan.org/pod/MojoX::Log::Dispatch::Simple)
- [GitHub Actions](https://github.com/gryphonshafer/MojoX-Log-Dispatch-Simple/actions)
- [Codecov](https://codecov.io/gh/gryphonshafer/MojoX-Log-Dispatch-Simple)
- [CPANTS](http://cpants.cpanauthors.org/dist/MojoX-Log-Dispatch-Simple)
- [CPAN Testers](http://www.cpantesters.org/distro/M/MojoX-Log-Dispatch-Simple.html)

# GRATITUDE

Special thanks to the following for contributing to this module:

- Tomohiro Hosaka

# AUTHOR

Gryphon Shafer <gryphon@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2015-2050 by Gryphon Shafer.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
