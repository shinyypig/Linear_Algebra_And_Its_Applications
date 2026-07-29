$hash_calc_ignore_pattern{'pdf'} = '^(/CreationDate|/ModDate|/ID)';
$hash_calc_ignore_pattern{'ps'} = '^%%CreationDate';

# Build external Asymptote sources on demand when \includegraphics requests
# the corresponding PDF.  Asymptote itself uses XeLaTeX for figure labels.
# OpenGL does not export a transparent canvas.  Render against black and white,
# recover the alpha channel, and then wrap the RGBA image in PDF.
sub asymptote_to_pdf {
    my ($base) = @_;
    require Cwd;
    require File::Basename;

    my $project_dir = Cwd::getcwd();
    my $figure_dir = File::Basename::dirname($base);
    my $figure_name = File::Basename::basename($base);

    # All figures import the shared style; keep it in latexmk's dependency
    # database so a style change invalidates every generated figure PDF.
    my $transparent_wrapper =
        "$project_dir/scripts/asymptote_transparent_wrapper.tex";
    my $alpha_recovery =
        "$project_dir/scripts/recover_asymptote_alpha.py";
    rdb_ensure_files_here("$project_dir/bookstyle.asy");
    rdb_ensure_files_here($transparent_wrapper);
    rdb_ensure_files_here($alpha_recovery);

    open my $asy_source, '<', "$base.asy" or return 1;
    local $/;
    my $asy_text = <$asy_source>;
    close $asy_source;
    my $transparent_render =
        $asy_text =~ /settings\.outformat\s*=\s*["']png["']/;
    my $image_size = '5.5cm';
    if ($asy_text =~ /\bsize\s*\(\s*([0-9]+(?:\.[0-9]+)?)\s*cm\b/) {
        $image_size = "$1cm";
    }

    chdir $figure_dir or return 1;
    my $ret = 0;
    if ($transparent_render) {
        for my $background ('black', 'white') {
            my $render_name = "$figure_name-$background";
            $ret = system(
                'xvfb-run', '-a', 'asy',
                '-user', "transparent-$background",
                '-dir', $project_dir, '-f', 'pdf',
                '-o', $render_name, "$figure_name.asy"
            );
            last if $ret != 0;
        }
        if ($ret == 0) {
            $ret = system(
                'python3', $alpha_recovery,
                "$figure_name-black.png", "$figure_name-white.png",
                "$figure_name.png"
            );
        }
    }
    else {
        $ret = system(
            'xvfb-run', '-a', 'asy', '-dir', $project_dir, '-f', 'pdf',
            '-o', $figure_name, "$figure_name.asy"
        );
    }

    if ($ret == 0 && $transparent_render) {
        my $transparent_png = "$figure_name.png";
        if (!-f $transparent_png) {
            warn "Latexmk: Asymptote did not create '$figure_dir/$transparent_png'\n";
            $ret = 1;
        }
        else {
            my $tex_input =
                "\\def\\ImageFile{$transparent_png}" .
                "\\def\\ImageSize{$image_size}" .
                "\\input{$transparent_wrapper}";
            $ret = system(
                'pdflatex', '-interaction=batchmode', '-halt-on-error',
                "-jobname=$figure_name", $tex_input
            );
        }
    }

    # The OpenGL renderer leaves this intermediate PostScript file behind.
    # It is not an input to subsequent builds, so remove it immediately.
    # Render intermediates and wrapper auxiliaries are fully embedded in PDF.
    my @temporary_files = ("${figure_name}__.ps");
    if ($transparent_render) {
        push @temporary_files,
            "$figure_name-black.png", "$figure_name-white.png",
            "$figure_name-black__.ps", "$figure_name-white__.ps",
            "$figure_name.png", "$figure_name.aux", "$figure_name.log";
    }
    for my $temporary_file (@temporary_files) {
        if (-f $temporary_file && !unlink $temporary_file) {
            warn "Latexmk: could not remove '$figure_dir/$temporary_file': $!\n";
        }
    }

    chdir $project_dir or return 1;
    return $ret;
}
add_cus_dep('asy', 'pdf', 0, 'asymptote_to_pdf');
push @generated_exts, 'pre', '%R__.ps';

sub pre_compile {
    if ($^O eq 'MSWin32') {  # For Windows systems
        system "mkdir .\\tmp";
        system "mkdir .\\tmp\\tmp";
        system "mkdir .\\tmp\\tex";
    } else {  # For Unix-like systems
        system "mkdir -p ./tmp";
        system "mkdir -p ./tmp/tmp";
        system "mkdir -p ./tmp/tex";
    }
};

pre_compile();
