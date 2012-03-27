#!/bin/awk -f

## usage: getopts(optstring [, longopt_array ])
## "optstring" is of the form "ab:c". each letter is a possible option. if the
## letter is followed by a colon (:), then the option requires an argument. if
## an argument is not provided, or an invalid option is given, getopts will
## print the appropriate error message, set "err" to 1, and exit (make sure you
## check this in your END block). returns each option as it's read, and -1
## when no options are left. "optind" will be set to the index of the next
## non-option argument when finished. "optarg" will be set to the option's
## argument, when required. if not required, "optarg" will be empty.  getopts
## will delete each option and argument that it successfully reads, so awk
## will be able to treat whatever's left as filenames/assignments, as usual.
## if provided, "longopt_array" is the name of an associative array that maps
## long options to the appropriate short option. (do not include the hyphens on
## either).
## sample usage can be found at http://auriga.kiwilight.com/~freak/awk_getopts
function getopts(optstring, longarr,    opt, trimmed, hasarg, repeat) {
  hasarg = repeat = 0;

  # increment optind
  optind++;

  # return -1 if the current arg is not an option or there are no args left
  if (ARGV[optind] !~ /^-/ || optind >= ARGC) {
    return -1;
  }

  # if option is "--" (end of options), delete arg and return -1
  if (ARGV[optind] == "--") {
    for (i=1; i<=optind; i++) {
      delete ARGV[i];
    }

    return -1;
  }

  # if the option is a long argument...
  if (ARGV[optind] ~ /^--/) {
    # trim hyphens
    trimmed = substr(ARGV[optind], 3);
    # if it's of the format --foo=bar, split the two. assign 'bar' to optarg and
    # set hasarg to 1
    if (trimmed ~ /.*=.*/) {
      optarg = trimmed;
      sub(/=.*/, "", trimmed);
      sub(/^[^=]*=/, "", optarg);
      hasarg = 1;
    }
    
    # invalid long opt
    if (!(trimmed in longarr)) {
      printf("unrecognized option -- '%s'\n", ARGV[optind]) > "/dev/stderr";
      err = 1;
      exit err;
    }

    opt = longarr[trimmed];

  # otherwise, it's a short option
  } else {
    # remove the hyphen, and get just the option letter
    opt = substr(ARGV[optind], 2, 1);
    # set trimmed to whatever's left
    trimmed = substr(ARGV[optind], 3);

    # invalid option
    if (!index(optstring, opt)) {
      printf("invalid option -- '%s'\n", opt) > "/dev/stderr";
      err = 1;
      exit err;
    }

    # if there's more to the argument than just -o
    if (length(trimmed)) {
      # if option requires an argument, set the rest to optarg and hasarg to 1
      if (index(optstring, opt ":")) {
        optarg = trimmed;
        hasarg = 1;

      # otherwise, prepend a hyphen to the rest and set repeat to 1, so the
      # same arg is processed again without the first option
      } else {
        ARGV[optind] = "-" trimmed;
        repeat = 1;
      }
    }
  }

  # if the option requires an arg and hasarg is 0
  if (index(optstring, opt ":") && !hasarg) {
    # increment optind, check if no arguments are left
    if (++optind >= ARGC) {
      printf("option requires an argument -- '%s'\n", opt) > "/dev/stderr";
      err = 1;
      exit err;
    }

    # set optarg
    optarg = ARGV[optind];

  # if repeat is set, decrement optind so we process the same arg again
  # mutually exclusive to needing an argument, otherwise hasarg would be set
  } else if (repeat) {
    optind--;
  }

  # delete all arguments up to this point, just to make sure
  for (i=1; i<=optind; i++) {
    delete ARGV[i];
  }

  # return the option letter
  return opt;
}
