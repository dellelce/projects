#
# penv
#
# Based on "jenv"

#

## "local" doc:
#
#  split (some_string, array_var [, field-seperator])
#
# 
    BEGIN \
    {
# (set by -v option)      postfix=ENVIRON["envpostix"];

      if (postfix=="") postfix="env.txt";
      if (envdir=="") envdir=ENVIRON["SRCCONFIG"];
    }

    {
	in_cnt = split($0, in_a, "=");
        var=in_a[1];
	gsub(/ /,"_",var);
        envfile=envdir"/"var"."postfix;
        value=in_a[2];


        if (in_cnt == 1 && del != 1)
        {
         print "[ -s "envfile" ] && cat "envfile" || echo variable "var" not set.";
	}

        if (in_cnt == 1 && del == 1)
        {
         print "[ -s "envfile" ] && rm "envfile" || echo variable "var" not set.";
	}

        if (in_cnt == 2)
        {
         printf "echo %s > %s\n", value, envfile;
	}

#        print in_cnt;
#	print "in_a[1] = " in_a[1];
#	print "in_a[2] = " in_a[2];

    }


## EOF ##
