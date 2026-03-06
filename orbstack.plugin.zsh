# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name orbstack
# @brief Zsh plugin to set up environment for the OrbStack CLI.
# @repository https://github.com/johnstonskj/zsh-orbstack-plugin
#
# ### Public Variables
#
# * `ORB_HOME`; if set it does something magical.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

orbstack_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save orbstack ORB_HOME
    export ORB_HOME="${ORB_HOME:-${HOME}/.orbstack}"

    @zplugins_add_to_path orbstack "${ORB_HOME}/bin"

    if [[ "${OSTYPE}" == [Dd]arwin* ]] ; then
        @zplugins_add_to_fpath orbstack "/Applications/OrbStack.app/Contents/Resources/completions/zsh"
    fi
}

# @internal
orbstack_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore orbstack ORB_HOME
}
