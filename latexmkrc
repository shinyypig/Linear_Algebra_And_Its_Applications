$hash_calc_ignore_pattern{'pdf'} = '^(/CreationDate|/ModDate|/ID)';
$hash_calc_ignore_pattern{'ps'} = '^%%CreationDate';
$asymptote_jobs = 4;

require Cwd;

sub pre_compile {
    my $project_dir = Cwd::getcwd();
    if ($^O eq 'MSWin32') {  # For Windows systems
        system "mkdir .\\tmp";
        # system "mkdir .\\tmp\\tmp";
        # system "mkdir .\\tmp\\tex";
    } else {  # For Unix-like systems
        system "mkdir -p ./tmp";
        # system "mkdir -p ./tmp/tmp";
        # system "mkdir -p ./tmp/tex";
    }

    my $builder = "$project_dir/scripts/build_asymptote_figures.pl";
    my $result = system(
        $^X, $builder, $project_dir, "$project_dir/tmp", $asymptote_jobs,
    );
    die "Latexmk: Asymptote figure build failed\n" if $result != 0;
};

pre_compile();
