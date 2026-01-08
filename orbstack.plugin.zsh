# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: orbstack
# Description: Zsh plugin to set up environment for the OrbStack CLI.
# Repository: https://github.com/johnstonskj/zsh-orbstack-plugin
#
# Public variables:
#
# * `ORBSTACK`; plugin-defined global associative array with the following keys:
#   * `_ALIASES`; a list of all aliases defined by the plugin.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_OLD_ORB_HOME`; the previous value of the `ORB_HOME` environment variable.
# * `ORB_HOME`; if set it does something magical.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA ORBSTACK
ORBSTACK[_PLUGIN_DIR]="${0:h}"
ORBSTACK[_FUNCTIONS]=""

# Saving the current state for any modified global environment variables.
ORBSTACK[_OLD_ORB_HOME]="${ORB_HOME}"

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `ORBSTACK[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.orbstack_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${ORBSTACK[_FUNCTIONS]}" ]]; then
        ORBSTACK[_FUNCTIONS]="${fn_name}"
    elif [[ ",${ORBSTACK[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        ORBSTACK[_FUNCTIONS]="${ORBSTACK[_FUNCTIONS]},${fn_name}"
    fi
}
.orbstack_remember_fn .orbstack_remember_fn

#
# This function does the initialization of variables in the global variable
# `ORBSTACK`. It also adds to `path` and `fpath` as necessary.
#
orbstack_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    export ORB_HOME="${ORB_HOME:-${HOME}/.orbstack}"

    path+=( "${ORB_HOME}/bin" )

    if [[ "${OSTYPE}" == [Dd]arwin* ]] ; then
        fpath+=( "/Applications/OrbStack.app/Contents/Resources/completions/zsh" )
    fi
}
.orbstack_remember_fn orbstack_plugin_init

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
orbstack_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${ORBSTACK[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done

    # Removing path and fpath entries.
    path=( "${(@)path:#${ORB_HOME}/bin}" )
    fpath=( "${(@)fpath:#/Applications/OrbStack.app/Contents/Resources/completions/zsh}" )

    # Reset global environment variables .
    export ORB_HOME="${ORBSTACK[_OLD_ORB_HOME]}"

    # Remove the global data variable.
    unset ORBSTACK

    # Remove this function.
    unfunction orbstack_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

orbstack_plugin_init

true
