use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Data::Dumper::Simple',
    'VERSION_FROM'	=> 'lib/Data/Dumper/Simple.pm',
    'PREREQ_PM'		=> {
        'Filter::Simple' => '0.77',
    },
    ($] >= 5.005
        ? (
            ABSTRACT_FROM => 'lib/Data/Dumper/Simple.pm',
            AUTHOR        => 'Curtis "Ovid" Poe'
          )
        : ()
    ),
);
