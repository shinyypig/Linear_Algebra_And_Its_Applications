# $clean_ext .= ' %R.figlist %R-figure* %R.makefile fls.tmp';
$latex    = 'internal tikzlatex latex    %B %O %S';
$pdflatex = 'internal tikzlatex pdflatex %B %O %S';
$lualatex = 'internal tikzlatex lualatex %B %O %S';
$xelatex  = 'internal tikzlatex xelatex  %B %O %S';
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
                "\\def\\ImageFile{$transparent_png}\\input{$transparent_wrapper}";
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
push @generated_exts, 'pre', '%R-*.pdf', '%R-*.tex', '%R__.ps';

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

sub tikzlatex {
    my ($engine, $base, @args) = @_;
    my $ret = 0;
    if ($^O eq 'MSWin32') { 
        # For Windows systems
        print "Tikzlatex: ===Running '$engine @args'...\n";
        $ret = system( $engine, @args );
        print "Tikzlatex: Fixing .fls file ...\n";
        system "echo INPUT \"$aux_dir1$base.figlist\"  >  \"$aux_dir1$base.fls.tmp\"";
        system "echo INPUT \"$aux_dir1$base.makefile\" >> \"$aux_dir1$base.fls.tmp\"";

        system "type \"$aux_dir1$base.fls\" >> \"$aux_dir1$base.fls.tmp\"";

        rename "$aux_dir1$base.fls.tmp", "$aux_dir1$base.fls";

        if ($ret) { return $ret; }
            if ( -e "$aux_dir1$base.makefile" ) {
                if ($engine eq 'xelatex') {
                    print "Tikzlatex: ---Correcting '$aux_dir1$base.makefile' made under xelatex\n";
                    system("sed \"s/^\^\^I/\t/\" $aux_dir1$base.makefile > $aux_dir1$base.makefile.tmp");
                    rename "$aux_dir1$base.makefile.tmp", "$aux_dir1$base.makefile";
                }
                elsif ($engine eq 'latex') {
                    print "Tikzlatex: ---Correcting '$aux_dir1$base.makefile' made under latex\n";
                    system("sed \"s/\\.epsi/\\.ps/\" $aux_dir1$base.makefile > $aux_dir1$base.makefile.tmp");
                    rename "$aux_dir1$base.makefile.tmp", "$aux_dir1$base.makefile";
                }
                print "Tikzlatex: ---Running 'make -f $aux_dir1$base.makefile' ...\n";
                if ($aux_dir) {
                    system("sed \"s#$base.figlist#$aux_dir1$base.figlist#g\" $aux_dir1$base.makefile > $aux_dir1$base.makefile.tmp");
                    rename "$aux_dir1$base.makefile.tmp", "$aux_dir1$base.makefile";
                    system("sed \"s/mkdir -p/mkdir/\" $aux_dir1$base.makefile > $aux_dir1$base.makefile.tmp");
                    rename "$aux_dir1$base.makefile.tmp", "$aux_dir1$base.makefile";

                    system "for f in $aux_dir1$aux_dir1*.md5; do [ -e \"\$f\" ] && cp \"\$f\" $aux_dir1; done";

                    system "rm -rf $aux_dir1$aux_dir1";
                    $ret = system "sh make",  "-j", "10", "-f", "$aux_dir1$base.makefile";
                    unlink "$base.run.xml";
                }
                else {
                    $ret = system "make",  "-j", "10", "-f", "$base.makefile";
                }
                if ($ret) {
                    print "Tikzlatex: !!!!!!!!!!!!!! Error from make !!!!!!!!! \n",
                        "  The log files for making the figures '$aux_dir1$base-figure*.log'\n",
                        "  may have information\n";
                }
            }
        else {
            print "Tikzlatex: No '$aux_dir1$base.makefile', so I won't run make.\n";
        }
        return $ret;
    } elsif ($^O eq 'linux') {  # For linux systems
        print "Tikzlatex: ===Running '$engine @args'...\n";
        $ret = system( $engine, @args );
        print "Tikzlatex: Fixing .fls file ...\n";
        system "echo INPUT \"$aux_dir1$base.figlist\"  >  \"$aux_dir1$base.fls.tmp\"";
        system "echo INPUT \"$aux_dir1$base.makefile\" >> \"$aux_dir1$base.fls.tmp\"";

        system "cat \"$aux_dir1$base.fls\" >> \"$aux_dir1$base.fls.tmp\"";

        rename "$aux_dir1$base.fls.tmp", "$aux_dir1$base.fls";

        if ($ret) { return $ret; }
            if ( -e "$aux_dir1$base.makefile" ) {
                if ($engine eq 'xelatex') {
                    print "Tikzlatex: ---Correcting '$aux_dir1$base.makefile' made under xelatex\n";
                    system('sed', '-i', 's/^\^\^I/\t/g', "$aux_dir1$base.makefile");
                }
                elsif ($engine eq 'latex') {
                    print "Tikzlatex: ---Correcting '$aux_dir1$base.makefile' made under latex\n";
                    system('sed', '-i', 's/\.epsi/\.ps/g', "$aux_dir1$base.makefile");
                }
                print "Tikzlatex: ---Running 'make -f $aux_dir1$base.makefile' ...\n";
                if ($aux_dir) {
                    system("sed -i 's|$base.figlist|$aux_dir1$base.figlist|g' $aux_dir1$base.makefile");
                    system "for f in $aux_dir1$aux_dir1*.md5; do [ -e \"\$f\" ] && cp \"\$f\" $aux_dir1; done";
                    system "rm -rf $aux_dir1$aux_dir1";
                    $ret = system "make",  "-j", "128", "-f", "$aux_dir1$base.makefile";
                    unlink "$base.run.xml";
                }
                else {
                    $ret = system "make",  "-j", "128", "-f", "$base.makefile";
                }
                if ($ret) {
                    print "Tikzlatex: !!!!!!!!!!!!!! Error from make !!!!!!!!! \n",
                        "  The log files for making the figures '$aux_dir1$base-figure*.log'\n",
                        "  may have information\n";
                }
            }
        else {
            print "Tikzlatex: No '$aux_dir1$base.makefile', so I won't run make.\n";
        }
        return $ret;
    }
    else {  # For Unix-like systems
        print "Tikzlatex: ===Running '$engine @args'...\n";
        $ret = system( $engine, @args );
        print "Tikzlatex: Fixing .fls file ...\n";
        system "echo INPUT \"$aux_dir1$base.figlist\"  >  \"$aux_dir1$base.fls.tmp\"";
        system "echo INPUT \"$aux_dir1$base.makefile\" >> \"$aux_dir1$base.fls.tmp\"";

        system "cat \"$aux_dir1$base.fls\" >> \"$aux_dir1$base.fls.tmp\"";

        rename "$aux_dir1$base.fls.tmp", "$aux_dir1$base.fls";

        if ($ret) { return $ret; }
            if ( -e "$aux_dir1$base.makefile" ) {
                if ($engine eq 'xelatex') {
                    print "Tikzlatex: ---Correcting '$aux_dir1$base.makefile' made under xelatex\n";
                    system('sed', '-i', '', 's/^\^\^I/\t/', "$aux_dir1$base.makefile");
                }
                elsif ($engine eq 'latex') {
                    print "Tikzlatex: ---Correcting '$aux_dir1$base.makefile' made under latex\n";
                    system('sed', '-i', '', 's/\.epsi/\.ps/', "$aux_dir1$base.makefile");
                }
                print "Tikzlatex: ---Running 'make -f $aux_dir1$base.makefile' ...\n";
                if ($aux_dir) {
                    system('sed', '-i', '', "s#$base.figlist#$aux_dir1$base.figlist#g", "$aux_dir1$base.makefile");
                    system "for f in $aux_dir1$aux_dir1*.md5; do [ -e \"\$f\" ] && cp \"\$f\" $aux_dir1; done";
                    system "rm -rf $aux_dir1$aux_dir1";
                    $ret = system "make",  "-j", "10", "-f", "$aux_dir1$base.makefile";
                    unlink "$base.run.xml";
                }
                else {
                    $ret = system "make",  "-j", "10", "-f", "$base.makefile";
                }
                if ($ret) {
                    print "Tikzlatex: !!!!!!!!!!!!!! Error from make !!!!!!!!! \n",
                        "  The log files for making the figures '$aux_dir1$base-figure*.log'\n",
                        "  may have information\n";
                }
            }
        else {
            print "Tikzlatex: No '$aux_dir1$base.makefile', so I won't run make.\n";
        }
        return $ret;
    }
}
