#!/bin/bash

#himma kagehus glytt
function fubbick ()
{
    case "$1" in
    jubba) shift; git init "$@";;
    abekatta) shift; git clone "$@";;
    asa) shift; git pull "$@";;
    prega) shift; git push "$@";;
    fedeprega) shift; git push --force "${@}";;
    pela) shift; git fetch "$@";;
    spåga) shift; git branch "$@";;
    åsso) shift; git add "$@";;
    hutta) shift; git commit "$@";;
    nimma) shift; git rebase "$@";;
    klydda) shift; git merge "$@";;
    tocka) shift; git stash "$@";;
    pelapäror) shift; git cherry-pick "$@";;
    gaffla) shift; git blame "$@";;
    henka) shift; git checkout "$@";;
    härförleden) shift; git log "$@";;
    ude) shift; git remote "$@";;
    *) git "${@}"
    esac
}
