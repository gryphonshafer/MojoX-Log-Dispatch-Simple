# NAME

MojoX::Log::Dispatch::Simple - Simple Log::Dispatch replacement of Mojo::Log

# VERSION

version 0.001

[![Build Status](https://travis-ci.org/gryphonshafer/MojoX-Log-Dispatch-Simple.svg)](https://travis-ci.org/gryphonshafer/MojoX-Log-Dispatch-Simple)
[![Coverage Status](https://coveralls.io/repos/gryphonshafer/MojoX-Log-Dispatch-Simple/badge.png)](https://coveralls.io/r/gryphonshafer/MojoX-Log-Dispatch-Simple)

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

This module provides a really simple way to replace the built-in [Mojo::Log](https://metacpan.org/pod/Mojo::Log)
with a [Log::Dispatch](https://metacpan.org/pod/Log::Dispatch) object, and yet still support all the [Mojo::Log](https://metacpan.org/pod/Mojo::Log)
log levels and other functionality [Mojolicious](https://metacpan.org/pod/Mojolicious) assumes exists. To make it
even easier, you can install helpers to all the log levels, all from the same
single line of code.

    $self->log( MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    )->helpers($self) );

The module makes absolutely no assumptions about how you want to use
[Log::Dispatch](https://metacpan.org/pod/Log::Dispatch). In fact, it's entirely neutral about [Log::Dispatch](https://metacpan.org/pod/Log::Dispatch). If you
want to use a library that offers a similar interface, go for it.

# PRIMARY METHODS

These are methods that you would likely use from within your `startup()`
subroutine:

## new

This method instantiates an object. It requires a "dispatch" parameter, which
should be a [Log::Dispatch](https://metacpan.org/pod/Log::Dispatch) object (or an object with a similar signature).
The method allow accepts an optional "level" parameter, which is used to set
the log level for your [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

    my $mojo_logger = MojoX::Log::Dispatch::Simple->new(
        dispatch => Log::Dispatch->new,
        level    => 'debug'
    );

Optionally, you can also provide a "format\_cb" value, which should be a
reference to a subroutine that will be used to format entries that appear
on the [Mojolicious](https://metacpan.org/pod/Mojolicious) error reporting web page. This formatting will have
nothing at all to do with whatever your [Log::Dispatch](https://metacpan.org/pod/Log::Dispatch) does.

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

    $mojo_logger->helpers($mojo_obj);

You can optionally pass in the names of the log levels you want helpers created
for, and the method will only create methods for those levels.

    $mojo_logger->helpers( $mojo_obj, qw( debug info warn ) );

# LOG LEVELS

Unfortunately, [Mojolicious](https://metacpan.org/pod/Mojolicious) and [Log::Dispatch](https://metacpan.org/pod/Log::Dispatch) have slightly different
ideas as to what log levels should exist. This module supports all of them,
because why not, right? Here's a list of the supported log levels, some with
aliases.

- debug
- info
- notice
- warn, warning
- error, err
- critical, crit
- alert
- emergency, emerg, fatal

You can also test for log level by either just reading `$obj-`level> or by
running an "is\_\*" method. For every log level listed above, there's a
corresponding "is\_\*" method.

    my $log_level_at_or_above_notice = $obj->is_notice;

# POST-INSTANTIATION MEDDLING

Following the creation of the object from this library, you can still
manipulate various attributes, which are:

- dispatch (a [Log::Dispatch](https://metacpan.org/pod/Log::Dispatch) object)
- level
- max\_history\_size
- format\_cb (a subref)
- history (an arrayref)

So you can do things like:

    $obj->dispatch->remove('debug');

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Log::Dispatch](https://metacpan.org/pod/Log::Dispatch).

You can also look for additional information at:

- [GitHub](https://github.com/gryphonshafer/MojoX-Log-Dispatch-Simple)
- [CPAN](http://search.cpan.org/dist/MojoX-Log-Dispatch-Simple)
- [MetaCPAN](https://metacpan.org/pod/MojoX::Log::Dispatch::Simple)
- [AnnoCPAN](http://annocpan.org/dist/MojoX-Log-Dispatch-Simple)
- [Travis CI](https://travis-ci.org/gryphonshafer/MojoX-Log-Dispatch-Simple)
- [Coveralls](https://coveralls.io/r/gryphonshafer/MojoX-Log-Dispatch-Simple)
- [CPANTS](http://cpants.cpanauthors.org/dist/MojoX-Log-Dispatch-Simple)
- [CPAN Testers](http://www.cpantesters.org/distro/M/MojoX-Log-Dispatch-Simple.html)

# AUTHOR

Gryphon Shafer <gryphon@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Gryphon Shafer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
