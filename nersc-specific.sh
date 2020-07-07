# more bash functions to source:

function mreset () {
  # module purge leaves environment in a mess, this function returns 
  # it to a "clean" as-if-i-just-got-a-new-account-and-logged-in state
  module purge
  module load modules
  module load nsg
  module load intel
  module load craype
  module load PrgEnv-cray
  module swap PrgEnv-cray PrgEnv-intel
  case "$NERSC_HOST" in
    cori) module load craype-haswell ;;
    edison) module load craype-ivybridge ;
            export CRAY_CPU_TARGET=sandybridge ;;
  esac
  module load cray-mpich
  module load altd
  module load darshan
}

# when we usgrsu to a user account, it's nice to get the X forwarding stuff displayed upfront
# (paste the string this prints into the terminal as the user)
user ()
{
  [[ -z $DISPLAY ]] || echo "export DISPLAY=$DISPLAY ; xauth add `xauth list $DISPLAY`" ; usgrsu $*
}


