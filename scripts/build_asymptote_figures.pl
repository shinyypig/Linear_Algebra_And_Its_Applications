#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(getcwd);
use Digest::SHA qw(sha256_hex);
use File::Basename qw(basename dirname);
use File::Find qw(find);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempfile);

my ($project_dir, $output_root, $max_jobs) = @ARGV;
die "Usage: $0 PROJECT_DIR OUTPUT_ROOT MAX_JOBS\n"
    unless defined $project_dir && defined $output_root && defined $max_jobs;
die "Asymptote: MAX_JOBS must be a positive integer\n"
    unless $max_jobs =~ /^\d+$/ && $max_jobs >= 1;

$project_dir = File::Spec->rel2abs($project_dir);
$output_root = File::Spec->rel2abs($output_root, $project_dir);

my $style_file = "$project_dir/bookstyle.asy";
my $transparent_wrapper =
    "$project_dir/scripts/asymptote_transparent_wrapper.tex";
my $alpha_recovery =
    "$project_dir/scripts/recover_asymptote_alpha.lua";
my $builder_file = File::Spec->rel2abs(__FILE__);

sub read_file {
    my ($path) = @_;
    open my $handle, '<:raw', $path
        or die "Asymptote: cannot read '$path': $!\n";
    local $/;
    my $content = <$handle>;
    close $handle;
    return $content;
}

sub is_transparent_figure {
    my ($source_text) = @_;
    return $source_text =~ /settings\.outformat\s*=\s*["']png["']/;
}

sub asymptote_command {
    my @headless_options = (
        '-q',
        '-noView',
        '-nobatchView',
        '-nointeractiveView',
        '-nomultipleView',
        '-iconify',
    );
    if ($^O eq 'linux') {
        for my $directory (File::Spec->path()) {
            my $xvfb_run = File::Spec->catfile($directory, 'xvfb-run');
            return ('xvfb-run', '-a', 'asy', @headless_options)
                if -x $xvfb_run;
        }
    }
    return ('asy', @headless_options);
}

sub figure_fingerprint {
    my ($source_file, $source_text, $transparent) = @_;
    my @inputs = ($builder_file, $source_file, $style_file);
    push @inputs, $transparent_wrapper, $alpha_recovery if $transparent;

    my $material = '';
    for my $path (@inputs) {
        my $content = $path eq $source_file ? $source_text : read_file($path);
        $material .= length($content) . ":$content";
    }
    return sha256_hex($material);
}

sub run_command {
    my (@command) = @_;
    my ($log_handle, $log_path) = tempfile(
        'asymptote-command-XXXXXX',
        TMPDIR => 1,
        UNLINK => 0,
    );
    my $result;
    open my $saved_stdout, '>&', \*STDOUT
        or die "Asymptote: cannot preserve command output: $!\n";
    open my $saved_stderr, '>&', \*STDERR
        or die "Asymptote: cannot preserve command errors: $!\n";
    open STDOUT, '>&', $log_handle
        or die "Asymptote: cannot redirect command output: $!\n";
    open STDERR, '>&', $log_handle
        or die "Asymptote: cannot redirect command errors: $!\n";
    $result = system(@command);
    open STDOUT, '>&', $saved_stdout
        or die "Asymptote: cannot restore command output: $!\n";
    open STDERR, '>&', $saved_stderr
        or die "Asymptote: cannot restore command errors: $!\n";

    my $exit_code = $result == -1 ? 127 : $result >> 8;
    if ($exit_code != 0) {
        seek $log_handle, 0, 0;
        local $/;
        my $diagnostics = <$log_handle> // '';
        warn $diagnostics if length $diagnostics;
    }
    close $log_handle;
    unlink $log_path
        or warn "Asymptote: cannot remove command log '$log_path': $!\n";
    return $exit_code;
}

sub cleanup_files {
    for my $path (@_) {
        next unless -f $path;
        unlink $path or warn "Asymptote: cannot remove '$path': $!\n";
    }
}

sub build_figure {
    my ($source_file, $output_pdf, $source_text, $transparent) = @_;
    my $source_dir = dirname($source_file);
    my $source_name = basename($source_file);
    my $figure_name = basename($source_file, '.asy');
    my $output_dir = dirname($output_pdf);
    my $output_base = "$output_dir/$figure_name";
    my @asy_command = asymptote_command();

    make_path($output_dir);
    my $original_dir = getcwd();
    chdir $source_dir
        or die "Asymptote: cannot enter '$source_dir': $!\n";

    my $result = 0;
    if ($transparent) {
        for my $background ('black', 'white') {
            $result = run_command(
                @asy_command,
                '-user', "transparent-$background",
                '-dir', $project_dir,
                '-f', 'pdf',
                '-o', "$output_base-$background",
                $source_name,
            );
            last if $result != 0;
        }

        if ($result == 0) {
            $result = run_command(
                'texlua', $alpha_recovery,
                "$output_base-black.png",
                "$output_base-white.png",
                "$output_base.png",
            );
        }

        if ($result == 0 && !-f "$output_base.png") {
            warn "Asymptote: alpha recovery did not create '$output_base.png'\n";
            $result = 1;
        }

        if ($result == 0) {
            my $image_size = '5.5cm';
            if ($source_text =~ /\bsize\s*\(\s*([0-9]+(?:\.[0-9]+)?)\s*cm\b/) {
                $image_size = "$1cm";
            }
            my $tex_input =
                "\\def\\ImageFile{$figure_name.png}" .
                "\\def\\ImageSize{$image_size}" .
                "\\input{$transparent_wrapper}";

            chdir $output_dir
                or die "Asymptote: cannot enter '$output_dir': $!\n";
            $result = run_command(
                'pdflatex',
                '-interaction=batchmode',
                '-halt-on-error',
                "-jobname=$figure_name",
                $tex_input,
            );
        }
    }
    else {
        $result = run_command(
            @asy_command,
            '-dir', $project_dir,
            '-f', 'pdf',
            '-o', $output_base,
            $source_name,
        );
    }

    chdir $original_dir
        or die "Asymptote: cannot return to '$original_dir': $!\n";

    cleanup_files(
        "${output_base}__.ps",
        "$output_base-black.png",
        "$output_base-white.png",
        "$output_base-black__.ps",
        "$output_base-white__.ps",
        "$output_base.png",
        "$output_base.aux",
        "$output_base.log",
    );

    die "Asymptote: failed to build '$source_file' (exit $result)\n"
        if $result != 0;
    die "Asymptote: build succeeded but '$output_pdf' is missing\n"
        unless -f $output_pdf;
}

my @source_files;
find(
    {
        no_chdir => 1,
        wanted => sub {
            push @source_files, $File::Find::name
                if -f $File::Find::name && $File::Find::name =~ /\.asy$/;
        },
    },
    "$project_dir/img",
);

my @pending_figures;
for my $source_file (sort @source_files) {
    my $relative_source = File::Spec->abs2rel($source_file, $project_dir);
    (my $relative_pdf = $relative_source) =~ s/\.asy$/.pdf/;
    my $output_pdf = "$output_root/$relative_pdf";
    my $fingerprint_file = "$output_pdf.sha256";
    my $source_text = read_file($source_file);
    my $transparent = is_transparent_figure($source_text);
    my $fingerprint =
        figure_fingerprint($source_file, $source_text, $transparent);

    my $saved_fingerprint = '';
    if (-f $fingerprint_file) {
        $saved_fingerprint = read_file($fingerprint_file);
        $saved_fingerprint =~ s/\s+\z//;
    }
    next if -f $output_pdf && $saved_fingerprint eq $fingerprint;

    push @pending_figures, {
        source_file => $source_file,
        relative_source => $relative_source,
        relative_pdf => $relative_pdf,
        output_pdf => $output_pdf,
        fingerprint_file => $fingerprint_file,
        source_text => $source_text,
        transparent => $transparent,
        fingerprint => $fingerprint,
    };
}

sub build_pending_figure {
    my ($figure) = @_;
    build_figure(
        $figure->{source_file},
        $figure->{output_pdf},
        $figure->{source_text},
        $figure->{transparent},
    );

    open my $fingerprint_handle, '>:raw', $figure->{fingerprint_file}
        or die "Asymptote: cannot write '$figure->{fingerprint_file}': $!\n";
    print {$fingerprint_handle} "$figure->{fingerprint}\n";
    close $fingerprint_handle;
}

$max_jobs = 1 if $^O eq 'MSWin32';
$max_jobs = scalar @pending_figures
    if @pending_figures && $max_jobs > @pending_figures;

my $built = 0;
$| = 1;
if ($max_jobs == 1) {
    for my $figure (@pending_figures) {
        print "Asymptote: building $figure->{relative_source} -> " .
            "$output_root/$figure->{relative_pdf}\n";
        build_pending_figure($figure);
        $built++;
    }
}
elsif (@pending_figures) {
    print "Asymptote: building " . scalar(@pending_figures) .
        " figure(s) with $max_jobs parallel jobs\n";
    my %children;
    my @failures;
    while (@pending_figures || %children) {
        while (@pending_figures && scalar(keys %children) < $max_jobs) {
            my $figure = shift @pending_figures;
            print "Asymptote: building $figure->{relative_source} -> " .
                "$output_root/$figure->{relative_pdf}\n";
            my $pid = fork();
            die "Asymptote: cannot start parallel worker: $!\n"
                unless defined $pid;
            if ($pid == 0) {
                my $ok = eval {
                    build_pending_figure($figure);
                    1;
                };
                warn $@ unless $ok;
                exit($ok ? 0 : 1);
            }
            $children{$pid} = $figure->{relative_source};
        }

        my $pid = wait();
        die "Asymptote: failed while waiting for parallel workers\n"
            if $pid == -1;
        my $relative_source = delete $children{$pid};
        if ($? != 0) {
            @pending_figures = ();
            push @failures, $relative_source;
        }
        else {
            $built++;
        }
    }
    die "Asymptote: parallel worker failed for " . join(', ', @failures) . "\n"
        if @failures;
}

print "Asymptote: $built figure(s) rebuilt\n" if $built;
